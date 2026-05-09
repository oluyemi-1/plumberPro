import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import 'ai_tutor_service.dart';
import 'bookmarks_service.dart';
import 'customer_service.dart';
import 'diagnostics_service.dart';
import 'expense_service.dart';
import 'inventory_service.dart';
import 'job_log_service.dart';
import 'job_template_service.dart';
import 'notifications_service.dart';
import 'progress_service.dart';
import 'quote_service.dart';
import 'reminder_service.dart';
import 'srs_service.dart';
import 'theme_service.dart';
import 'user_profile_service.dart';

/// File-based backup and restore for the entire app state. Bundles every
/// `shared_preferences` key plus every job-photo file into a single zip
/// the user can email to themselves, save to Drive, etc., and re-import on
/// another device.
///
/// This is a manual replacement for true cloud sync — see README for the
/// optional Firebase upgrade path.
class BackupService {
  static const _kManifestVersion = 1;
  static const _kPhotosFolder = 'job_photos';
  static const _kVoiceNotesFolder = 'job_voice_notes';

  /// Build the backup zip in memory and trigger the system share sheet.
  /// The user picks where to save it (Files, email, Drive, etc).
  ///
  /// Returns a [BackupExportResult] describing how many photos were
  /// successfully bundled vs. expected — so the caller can warn the user if
  /// the zip is missing photos.
  static Future<BackupExportResult> exportBackup() async {
    final result = await _buildZip();
    final tmpDir = await getTemporaryDirectory();
    final ts = DateTime.now();
    final fname =
        'pipesmart-backup-${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}.zip';
    final tmp = File('${tmpDir.path}/$fname');
    await tmp.writeAsBytes(result.bytes, flush: true);
    await Share.shareXFiles(
      [XFile(tmp.path, mimeType: 'application/zip', name: fname)],
      subject: 'PipeSmart backup',
      text:
          'PipeSmart app backup. Open PipeSmart on the new device and tap Restore from backup.',
    );
    return result;
  }

  /// Restore from the supplied zip bytes. Overwrites local data — caller
  /// should confirm with the user first.
  ///
  /// Returns a short summary of what was restored, suitable for a SnackBar.
  static Future<String> restoreFromBytes(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    String? jsonString;
    final photoFiles = <ArchiveFile>[];
    final voiceNoteFiles = <ArchiveFile>[];
    for (final f in archive) {
      if (!f.isFile) continue;
      if (f.name == 'data.json') {
        jsonString = utf8.decode(f.content as List<int>);
      } else if (f.name.startsWith('$_kPhotosFolder/')) {
        photoFiles.add(f);
      } else if (f.name.startsWith('$_kVoiceNotesFolder/')) {
        voiceNoteFiles.add(f);
      }
    }
    if (jsonString == null) {
      throw const FormatException(
          'Not a valid PipeSmart backup — data.json missing.');
    }
    final manifest = jsonDecode(jsonString) as Map<String, dynamic>;
    final version = manifest['version'] as int? ?? 0;
    if (version > _kManifestVersion) {
      throw FormatException(
          'Backup format version $version is newer than this app supports.');
    }
    final prefsMap =
        (manifest['prefs'] as Map?)?.cast<String, dynamic>() ?? const {};

    // Restore prefs.
    final prefs = await SharedPreferences.getInstance();
    // Clear only our own keys to avoid wiping unrelated SDK prefs.
    for (final k in prefs.getKeys()) {
      if (_ourKey(k)) await prefs.remove(k);
    }
    for (final entry in prefsMap.entries) {
      final v = entry.value;
      if (v is bool) {
        await prefs.setBool(entry.key, v);
      } else if (v is int) {
        await prefs.setInt(entry.key, v);
      } else if (v is double) {
        await prefs.setDouble(entry.key, v);
      } else if (v is String) {
        await prefs.setString(entry.key, v);
      } else if (v is List) {
        await prefs.setStringList(entry.key, v.cast<String>());
      }
    }

    // Restore photo files.
    final docs = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${docs.path}/$_kPhotosFolder');
    if (await photosDir.exists()) {
      // Clear existing photos so old / orphaned files don't linger.
      try {
        await photosDir.delete(recursive: true);
      } catch (_) {/* best-effort */}
    }
    await photosDir.create(recursive: true);
    for (final pf in photoFiles) {
      final relPath = pf.name.substring('$_kPhotosFolder/'.length);
      final dest = File('${photosDir.path}/$relPath');
      await dest.parent.create(recursive: true);
      await dest.writeAsBytes(pf.content as List<int>, flush: true);
    }

    // Restore voice-note files.
    final voiceDir = Directory('${docs.path}/$_kVoiceNotesFolder');
    if (await voiceDir.exists()) {
      try {
        await voiceDir.delete(recursive: true);
      } catch (_) {/* best-effort */}
    }
    await voiceDir.create(recursive: true);
    for (final vf in voiceNoteFiles) {
      final relPath = vf.name.substring('$_kVoiceNotesFolder/'.length);
      final dest = File('${voiceDir.path}/$relPath');
      await dest.parent.create(recursive: true);
      await dest.writeAsBytes(vf.content as List<int>, flush: true);
    }

    // Reload in-memory state across all services.
    await _reloadAll();

    final photoCount = photoFiles.length;
    final voiceCount = voiceNoteFiles.length;
    final totalKeys = prefsMap.length;
    final voicePart = voiceCount == 0
        ? ''
        : ', $voiceCount voice note${voiceCount == 1 ? '' : 's'}';
    return 'Restored $totalKeys settings and $photoCount photo${photoCount == 1 ? '' : 's'}$voicePart.';
  }

  /// Returns a one-line description of what's in the backup, useful for the
  /// "are you sure you want to restore?" confirmation.
  static Future<BackupSummary?> peekBackup(Uint8List bytes) async {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      String? jsonString;
      var photoCount = 0;
      for (final f in archive) {
        if (!f.isFile) continue;
        if (f.name == 'data.json') {
          jsonString = utf8.decode(f.content as List<int>);
        } else if (f.name.startsWith('$_kPhotosFolder/')) {
          photoCount++;
        }
      }
      if (jsonString == null) return null;
      final manifest = jsonDecode(jsonString) as Map<String, dynamic>;
      final created = manifest['createdAt'] as String?;
      final summary =
          (manifest['summary'] as Map?)?.cast<String, dynamic>() ?? const {};
      return BackupSummary(
        createdAt: created == null ? null : DateTime.tryParse(created),
        jobsCount: summary['jobs'] as int? ?? 0,
        customersCount: summary['customers'] as int? ?? 0,
        bookmarksCount: summary['bookmarks'] as int? ?? 0,
        photosCount: photoCount,
        version: manifest['version'] as int? ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  // ─── Internal ──────────────────────────────────────────────────────

  /// Returns true if the prefs key belongs to this app (so we can safely
  /// clear it during restore without touching other SDK prefs).
  static bool _ourKey(String k) {
    const ours = <String>[
      'tts_rate', 'tts_pitch', 'tts_enabled', 'tts_language',
      'tts_voice_name', 'tts_voice_locale',
      'profile_onboarded', 'profile_role', 'profile_goals',
      'profile_name',
      'progress_visited_v1', 'progress_recent_v1',
      'progress_streak_v1', 'progress_last_date_v1',
      'bookmarks_v1',
      'srs_cards_v1',
      'job_log_jobs_v1', 'job_log_default_rate_v1',
      'job_log_business_name_v1', 'job_log_business_contact_v1',
      'job_log_vat_rate_v1',
      'customers_v1',
      'job_templates_v1', 'job_templates_seeded_v1',
      'expenses_v1', 'mileage_rate_v1',
      'reminders_v1',
      'quotes_v1',
      'inventory_v1', 'inventory_seeded_v1',
      'reminder_enabled_v1', 'reminder_hour_v1', 'reminder_minute_v1',
      'anthropic_api_key', 'anthropic_model', 'anthropic_cache_hits',
      'l8_answers_v1',
      'heat_loss_rooms_v1', 'heat_loss_oat_v1', 'heat_loss_region_v1',
      'theme_mode_v1',
    ];
    if (ours.contains(k)) return true;
    if (k.startsWith('quiz_')) return true;
    if (k.startsWith('checklist_')) return true;
    if (k.startsWith('synoptic_')) return true;
    return false;
  }

  static Future<BackupExportResult> _buildZip() async {
    final archive = Archive();
    final prefs = await SharedPreferences.getInstance();

    final prefsMap = <String, Object?>{};
    for (final k in prefs.getKeys()) {
      if (!_ourKey(k)) continue;
      final v = prefs.get(k);
      prefsMap[k] = v;
    }

    final summary = await _buildSummary();

    final manifest = {
      'version': _kManifestVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'app': 'PipeSmart',
      'summary': summary,
      'prefs': prefsMap,
    };

    final jsonBytes = utf8.encode(jsonEncode(manifest));
    archive.addFile(ArchiveFile('data.json', jsonBytes.length, jsonBytes));

    // The set of photo filenames we expect to bundle, taken from job records.
    final expectedPhotoNames = <String>{
      for (final job in JobLogService.instance.jobs)
        for (final photo in job.photos) photo.fileName,
    };
    final bundledPhotoNames = <String>{};
    final failedPhotoNames = <String>{};

    // Photos
    try {
      final docs = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${docs.path}/$_kPhotosFolder');
      if (await photosDir.exists()) {
        await for (final entity in photosDir.list(followLinks: false)) {
          if (entity is File) {
            final fileName =
                entity.path.split(Platform.pathSeparator).last;
            try {
              final bytes = await entity.readAsBytes();
              archive.addFile(ArchiveFile(
                  '$_kPhotosFolder/$fileName', bytes.length, bytes));
              bundledPhotoNames.add(fileName);
            } catch (e, st) {
              failedPhotoNames.add(fileName);
              DiagnosticsService.instance.warning(
                'BackupService',
                'Could not read $fileName for backup — photo will be missing from the zip.',
                '$e\n$st',
              );
            }
          }
        }
      }
    } catch (e, st) {
      DiagnosticsService.instance.error(
        'BackupService',
        'Photo bundling skipped — backup will be missing every photo.',
        '$e\n$st',
      );
    }

    // Photos referenced by jobs but not present on disk are also missing.
    final missingFromDisk =
        expectedPhotoNames.difference(bundledPhotoNames).difference(failedPhotoNames);
    if (missingFromDisk.isNotEmpty) {
      DiagnosticsService.instance.warning(
        'BackupService',
        'Backup expected ${expectedPhotoNames.length} photo${expectedPhotoNames.length == 1 ? '' : 's'} but ${missingFromDisk.length} were not found on disk.',
        'Missing: ${missingFromDisk.take(10).join(', ')}'
            '${missingFromDisk.length > 10 ? ' …' : ''}',
      );
    }

    // Voice notes — same integrity-tracked bundling as photos.
    final expectedVoiceNoteNames = <String>{
      for (final job in JobLogService.instance.jobs)
        for (final note in job.voiceNotes) note.fileName,
    };
    final bundledVoiceNoteNames = <String>{};
    final failedVoiceNoteNames = <String>{};
    try {
      final docs = await getApplicationDocumentsDirectory();
      final voiceDir = Directory('${docs.path}/$_kVoiceNotesFolder');
      if (await voiceDir.exists()) {
        await for (final entity in voiceDir.list(followLinks: false)) {
          if (entity is File) {
            final fileName =
                entity.path.split(Platform.pathSeparator).last;
            try {
              final bytes = await entity.readAsBytes();
              archive.addFile(ArchiveFile(
                  '$_kVoiceNotesFolder/$fileName', bytes.length, bytes));
              bundledVoiceNoteNames.add(fileName);
            } catch (e, st) {
              failedVoiceNoteNames.add(fileName);
              DiagnosticsService.instance.warning(
                'BackupService',
                'Could not read voice note $fileName for backup — it will be missing from the zip.',
                '$e\n$st',
              );
            }
          }
        }
      }
    } catch (e, st) {
      DiagnosticsService.instance.error(
        'BackupService',
        'Voice-note bundling skipped — backup will be missing every voice note.',
        '$e\n$st',
      );
    }

    final missingVoiceNotes = expectedVoiceNoteNames
        .difference(bundledVoiceNoteNames)
        .difference(failedVoiceNoteNames);
    if (missingVoiceNotes.isNotEmpty) {
      DiagnosticsService.instance.warning(
        'BackupService',
        'Backup expected ${expectedVoiceNoteNames.length} voice note${expectedVoiceNoteNames.length == 1 ? '' : 's'} but ${missingVoiceNotes.length} were not found on disk.',
        'Missing: ${missingVoiceNotes.take(10).join(', ')}'
            '${missingVoiceNotes.length > 10 ? ' …' : ''}',
      );
    }

    final encoded = ZipEncoder().encode(archive) ?? const <int>[];
    return BackupExportResult(
      bytes: Uint8List.fromList(encoded),
      photosExpected: expectedPhotoNames.length,
      photosBundled: bundledPhotoNames.length,
      voiceNotesExpected: expectedVoiceNoteNames.length,
      voiceNotesBundled: bundledVoiceNoteNames.length,
    );
  }

  static Future<Map<String, int>> _buildSummary() async {
    await JobLogService.instance.ensureLoaded();
    await CustomerService.instance.ensureLoaded();
    await BookmarksService.instance.ensureLoaded();
    return {
      'jobs': JobLogService.instance.jobs.length,
      'customers': CustomerService.instance.customers.length,
      'bookmarks': BookmarksService.instance.ids.length,
    };
  }

  static Future<void> _reloadAll() async {
    // Each service exposes a reload method (added for restore support).
    await UserProfileService.instance.reload();
    await ProgressService.instance.reload();
    await BookmarksService.instance.reload();
    await SrsService.instance.reload();
    await JobLogService.instance.reload();
    await JobTemplateService.instance.reload();
    await ExpenseService.instance.reload();
    await ReminderService.instance.reload();
    await QuoteService.instance.reload();
    await InventoryService.instance.reload();
    await CustomerService.instance.reload();
    await AiTutorService.instance.reload();
    await ThemeService.instance.reload();
    await NotificationsService.instance.reload();
    // TtsService settings auto-pick up on next speak; no reload needed.
  }
}

class BackupSummary {
  final DateTime? createdAt;
  final int jobsCount;
  final int customersCount;
  final int bookmarksCount;
  final int photosCount;
  final int version;
  const BackupSummary({
    required this.createdAt,
    required this.jobsCount,
    required this.customersCount,
    required this.bookmarksCount,
    required this.photosCount,
    required this.version,
  });
}

/// Result of a backup export — surfaces integrity info so the caller can
/// flag a partial backup to the user instead of pretending everything went
/// in fine.
class BackupExportResult {
  final Uint8List bytes;
  final int photosExpected;
  final int photosBundled;
  final int voiceNotesExpected;
  final int voiceNotesBundled;

  const BackupExportResult({
    required this.bytes,
    required this.photosExpected,
    required this.photosBundled,
    this.voiceNotesExpected = 0,
    this.voiceNotesBundled = 0,
  });

  bool get isComplete =>
      photosBundled >= photosExpected &&
      voiceNotesBundled >= voiceNotesExpected;
  int get photosMissing => (photosExpected - photosBundled).clamp(0, 1 << 31);
  int get voiceNotesMissing =>
      (voiceNotesExpected - voiceNotesBundled).clamp(0, 1 << 31);
}

import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../data/job_log_data.dart';
import 'diagnostics_service.dart';
import 'job_log_service.dart';

/// Per-job storage rollup — populated by [StorageService.scan].
class JobStorage {
  final String jobId;
  final String customerName;
  final JobStatus status;
  final DateTime? completedAt;
  final int photoBytes;
  final int voiceNoteBytes;
  final int photoCount;
  final int voiceNoteCount;

  const JobStorage({
    required this.jobId,
    required this.customerName,
    required this.status,
    required this.completedAt,
    required this.photoBytes,
    required this.voiceNoteBytes,
    required this.photoCount,
    required this.voiceNoteCount,
  });

  int get totalBytes => photoBytes + voiceNoteBytes;
  int get fileCount => photoCount + voiceNoteCount;
}

/// Summary of every photo + voice-note file the app has on disk, attributed
/// back to its job (or flagged as orphaned). Used by the Storage screen to
/// help the user keep their phone's free space sane.
class StorageScan {
  final int photoBytes;
  final int voiceNoteBytes;
  final int photoCount;
  final int voiceNoteCount;
  final List<JobStorage> byJob; // sorted descending by totalBytes
  final List<String> orphanPhotoFiles;
  final List<String> orphanVoiceFiles;
  final int orphanBytes;

  const StorageScan({
    required this.photoBytes,
    required this.voiceNoteBytes,
    required this.photoCount,
    required this.voiceNoteCount,
    required this.byJob,
    required this.orphanPhotoFiles,
    required this.orphanVoiceFiles,
    required this.orphanBytes,
  });

  int get totalBytes => photoBytes + voiceNoteBytes + orphanBytes;
  int get totalCount =>
      photoCount + voiceNoteCount + orphanPhotoFiles.length + orphanVoiceFiles.length;

  static const empty = StorageScan(
    photoBytes: 0,
    voiceNoteBytes: 0,
    photoCount: 0,
    voiceNoteCount: 0,
    byJob: [],
    orphanPhotoFiles: [],
    orphanVoiceFiles: [],
    orphanBytes: 0,
  );
}

/// One-stop service for "how much disk is the app using?" plus a couple of
/// safe cleanup actions.
class StorageService {
  static const _kPhotosFolder = 'job_photos';
  static const _kVoiceNotesFolder = 'job_voice_notes';

  /// Walk the photo + voice-note folders, attribute each file back to the
  /// job that referenced it, and flag anything left over as orphaned.
  static Future<StorageScan> scan() async {
    final docs = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${docs.path}/$_kPhotosFolder');
    final voiceDir = Directory('${docs.path}/$_kVoiceNotesFolder');

    // Reverse map: filename → (jobId, kind) using the JobLogService as
    // source-of-truth for what *should* be on disk.
    final photoOwner = <String, String>{};
    final voiceOwner = <String, String>{};
    for (final j in JobLogService.instance.jobs) {
      for (final p in j.photos) {
        photoOwner[p.fileName] = j.id;
      }
      for (final v in j.voiceNotes) {
        voiceOwner[v.fileName] = j.id;
      }
    }

    final perJobPhotoBytes = <String, int>{};
    final perJobVoiceBytes = <String, int>{};
    final perJobPhotoCount = <String, int>{};
    final perJobVoiceCount = <String, int>{};
    final orphanPhotos = <String>[];
    final orphanVoices = <String>[];
    var ownedPhotoBytes = 0;
    var ownedVoiceBytes = 0;
    var ownedPhotoCount = 0;
    var ownedVoiceCount = 0;
    var orphanBytes = 0;

    Future<int> safeLen(File f) async {
      try {
        return await f.length();
      } catch (e, st) {
        DiagnosticsService.instance.warning(
          'StorageService',
          'Could not stat ${f.path}.',
          '$e\n$st',
        );
        return 0;
      }
    }

    if (await photosDir.exists()) {
      try {
        await for (final entity in photosDir.list(followLinks: false)) {
          if (entity is! File) continue;
          final name = entity.path.split(Platform.pathSeparator).last;
          final size = await safeLen(entity);
          final owner = photoOwner[name];
          if (owner == null) {
            orphanPhotos.add(name);
            orphanBytes += size;
          } else {
            ownedPhotoBytes += size;
            ownedPhotoCount++;
            perJobPhotoBytes[owner] =
                (perJobPhotoBytes[owner] ?? 0) + size;
            perJobPhotoCount[owner] =
                (perJobPhotoCount[owner] ?? 0) + 1;
          }
        }
      } catch (e, st) {
        DiagnosticsService.instance.error(
          'StorageService',
          'Photos directory walk failed.',
          '$e\n$st',
        );
      }
    }

    if (await voiceDir.exists()) {
      try {
        await for (final entity in voiceDir.list(followLinks: false)) {
          if (entity is! File) continue;
          final name = entity.path.split(Platform.pathSeparator).last;
          final size = await safeLen(entity);
          final owner = voiceOwner[name];
          if (owner == null) {
            orphanVoices.add(name);
            orphanBytes += size;
          } else {
            ownedVoiceBytes += size;
            ownedVoiceCount++;
            perJobVoiceBytes[owner] =
                (perJobVoiceBytes[owner] ?? 0) + size;
            perJobVoiceCount[owner] =
                (perJobVoiceCount[owner] ?? 0) + 1;
          }
        }
      } catch (e, st) {
        DiagnosticsService.instance.error(
          'StorageService',
          'Voice-notes directory walk failed.',
          '$e\n$st',
        );
      }
    }

    final byJob = <JobStorage>[];
    for (final j in JobLogService.instance.jobs) {
      final pb = perJobPhotoBytes[j.id] ?? 0;
      final vb = perJobVoiceBytes[j.id] ?? 0;
      if (pb == 0 && vb == 0) continue;
      byJob.add(JobStorage(
        jobId: j.id,
        customerName: j.customer,
        status: j.status,
        completedAt: j.completedAt,
        photoBytes: pb,
        voiceNoteBytes: vb,
        photoCount: perJobPhotoCount[j.id] ?? 0,
        voiceNoteCount: perJobVoiceCount[j.id] ?? 0,
      ));
    }
    byJob.sort((a, b) => b.totalBytes.compareTo(a.totalBytes));

    return StorageScan(
      photoBytes: ownedPhotoBytes,
      voiceNoteBytes: ownedVoiceBytes,
      photoCount: ownedPhotoCount,
      voiceNoteCount: ownedVoiceCount,
      byJob: byJob,
      orphanPhotoFiles: orphanPhotos,
      orphanVoiceFiles: orphanVoices,
      orphanBytes: orphanBytes,
    );
  }

  /// Delete every orphaned media file (file on disk that no job references)
  /// from both folders. Returns the bytes freed.
  static Future<int> deleteOrphans(StorageScan scan) async {
    final docs = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${docs.path}/$_kPhotosFolder');
    final voiceDir = Directory('${docs.path}/$_kVoiceNotesFolder');
    var freed = 0;
    for (final name in scan.orphanPhotoFiles) {
      try {
        final f = File('${photosDir.path}/$name');
        if (await f.exists()) {
          freed += await f.length();
          await f.delete();
        }
      } catch (e, st) {
        DiagnosticsService.instance.warning(
          'StorageService',
          'Failed to delete orphan photo $name.',
          '$e\n$st',
        );
      }
    }
    for (final name in scan.orphanVoiceFiles) {
      try {
        final f = File('${voiceDir.path}/$name');
        if (await f.exists()) {
          freed += await f.length();
          await f.delete();
        }
      } catch (e, st) {
        DiagnosticsService.instance.warning(
          'StorageService',
          'Failed to delete orphan voice note $name.',
          '$e\n$st',
        );
      }
    }
    return freed;
  }

  /// For every job that's been completed for at least [age], drop its
  /// photos *and* voice notes from disk and from the job's metadata. Used
  /// by the Storage screen's "Free up space" actions.
  ///
  /// Returns the number of files deleted.
  static Future<int> purgeOldCompletedJobsMedia(Duration age) async {
    final cutoff = DateTime.now().subtract(age);
    var deleted = 0;
    for (final job in List<Job>.from(JobLogService.instance.jobs)) {
      if (job.status != JobStatus.completed) continue;
      final when = job.completedAt;
      if (when == null) continue;
      if (when.isAfter(cutoff)) continue;

      // Snapshot the lists since we mutate via the service.
      for (final p in List<JobPhoto>.from(job.photos)) {
        await JobLogService.instance.removePhoto(job.id, p.id);
        deleted++;
      }
      for (final v in List<JobVoiceNote>.from(job.voiceNotes)) {
        await JobLogService.instance.removeVoiceNote(job.id, v.id);
        deleted++;
      }
    }
    return deleted;
  }
}

/// Format a byte count as a human-readable string. Public so the UI and
/// tests both share the same formatter.
String formatBytes(int bytes) {
  if (bytes < 0) return '0 B';
  const kib = 1024;
  if (bytes < kib) return '$bytes B';
  if (bytes < kib * kib) {
    return '${(bytes / kib).toStringAsFixed(1)} KB';
  }
  if (bytes < kib * kib * kib) {
    return '${(bytes / (kib * kib)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (kib * kib * kib)).toStringAsFixed(2)} GB';
}

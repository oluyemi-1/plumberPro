import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/job_log_data.dart';
import 'diagnostics_service.dart';

/// Singleton manager for the user's job log. Persists every job (and the
/// active timer state) via shared_preferences as a single JSON blob.
class JobLogService extends ChangeNotifier {
  JobLogService._();
  static final JobLogService instance = JobLogService._();

  static const _kJobs = 'job_log_jobs_v1';
  static const _kHourlyRate = 'job_log_default_rate_v1';
  static const _kBizName = 'job_log_business_name_v1';
  static const _kBizContact = 'job_log_business_contact_v1';
  static const _kVatRate = 'job_log_vat_rate_v1';

  final List<Job> _jobs = [];
  double _defaultHourlyRate = 50.0;
  String _businessName = '';
  String _businessContact = '';
  double _vatRate = 0.20; // 20% UK standard, only applied if user opts in
  bool _loaded = false;

  List<Job> get jobs => List.unmodifiable(_jobs);
  double get defaultHourlyRate => _defaultHourlyRate;
  String get businessName => _businessName;
  String get businessContact => _businessContact;
  double get vatRate => _vatRate;
  bool get loaded => _loaded;

  /// Currently running job — at most one entry across all jobs is running
  /// at a time; the service enforces this.
  Job? get runningJob {
    for (final j in _jobs) {
      if (j.hasRunningTimer) return j;
    }
    return null;
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _jobs.addAll(decodeJobs(prefs.getString(_kJobs)));
    _defaultHourlyRate = prefs.getDouble(_kHourlyRate) ?? 50.0;
    _businessName = prefs.getString(_kBizName) ?? '';
    _businessContact = prefs.getString(_kBizContact) ?? '';
    _vatRate = prefs.getDouble(_kVatRate) ?? 0.20;
    _loaded = true;
    // Sort: active first, then most-recent createdAt.
    _sort();
    notifyListeners();
  }

  void _sort() {
    _jobs.sort((a, b) {
      if (a.status != b.status) {
        return a.status == JobStatus.active ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  /// Re-read all state from disk after a restore.
  Future<void> reload() async {
    _jobs.clear();
    _loaded = false;
    await ensureLoaded();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kJobs, encodeJobs(_jobs));
  }

  Future<void> setDefaultHourlyRate(double v) async {
    _defaultHourlyRate = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kHourlyRate, v);
    notifyListeners();
  }

  Future<void> setBusinessProfile({
    required String name,
    required String contact,
    double? vatRate,
  }) async {
    _businessName = name.trim();
    _businessContact = contact.trim();
    if (vatRate != null) _vatRate = vatRate.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBizName, _businessName);
    await prefs.setString(_kBizContact, _businessContact);
    await prefs.setDouble(_kVatRate, _vatRate);
    notifyListeners();
  }

  Future<Job> createJob({
    required String customer,
    required String address,
    required String description,
    double? hourlyRateGbp,
    String customerId = '',
  }) async {
    final job = Job.create(
      customer: customer.trim(),
      customerId: customerId,
      address: address.trim(),
      description: description.trim(),
      hourlyRateGbp: hourlyRateGbp ?? _defaultHourlyRate,
    );
    _jobs.add(job);
    _sort();
    await _save();
    notifyListeners();
    return job;
  }

  Future<void> updateJob(Job updated) async {
    final i = _jobs.indexWhere((j) => j.id == updated.id);
    if (i == -1) return;
    _jobs[i] = updated;
    _sort();
    await _save();
    notifyListeners();
  }

  Future<void> deleteJob(String jobId) async {
    _jobs.removeWhere((j) => j.id == jobId);
    await _save();
    notifyListeners();
  }

  Job? findById(String id) {
    for (final j in _jobs) {
      if (j.id == id) return j;
    }
    return null;
  }

  /// Start a timer on the given job. If another job is currently being
  /// timed, that one is paused first.
  Future<void> startTimer(String jobId) async {
    // Stop any other running timers first.
    for (var i = 0; i < _jobs.length; i++) {
      if (_jobs[i].hasRunningTimer && _jobs[i].id != jobId) {
        _jobs[i] = _stopRunning(_jobs[i]);
      }
    }
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return;
    final j = _jobs[i];
    if (j.hasRunningTimer) return; // already running
    final now = DateTime.now();
    final entry = TimeEntry(
      id: 'te-${now.millisecondsSinceEpoch}',
      start: now,
    );
    _jobs[i] = j.copyWith(entries: [...j.entries, entry]);
    await _save();
    notifyListeners();
  }

  Future<void> stopTimer(String jobId) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return;
    _jobs[i] = _stopRunning(_jobs[i]);
    await _save();
    notifyListeners();
  }

  Job _stopRunning(Job j) {
    final now = DateTime.now();
    final updated = j.entries
        .map((e) => e.isRunning ? e.copyWith(end: now) : e)
        .toList();
    return j.copyWith(entries: updated);
  }

  Future<void> deleteEntry(String jobId, String entryId) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return;
    final j = _jobs[i];
    final entries =
        j.entries.where((e) => e.id != entryId).toList();
    _jobs[i] = j.copyWith(entries: entries);
    await _save();
    notifyListeners();
  }

  Future<void> addMaterial(String jobId, MaterialLine m) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return;
    final j = _jobs[i];
    _jobs[i] = j.copyWith(materials: [...j.materials, m]);
    await _save();
    notifyListeners();
  }

  Future<void> deleteMaterial(String jobId, String matId) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return;
    final j = _jobs[i];
    _jobs[i] = j.copyWith(
      materials: j.materials.where((m) => m.id != matId).toList(),
    );
    await _save();
    notifyListeners();
  }

  Future<void> updateNotes(String jobId, String notes) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return;
    _jobs[i] = _jobs[i].copyWith(notes: notes);
    await _save();
    notifyListeners();
  }

  /// Resolve the absolute path of a [JobPhoto] on disk.
  Future<String> photoPath(JobPhoto photo) async {
    final dir = await _photosDir();
    return '${dir.path}/${photo.fileName}';
  }

  Future<Directory> _photosDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/job_photos');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copies the source image bytes into the documents directory and adds a
  /// [JobPhoto] entry to the job. [sourcePath] is the temp path returned by
  /// `image_picker` (XFile.path).
  Future<JobPhoto?> addPhoto({
    required String jobId,
    required String sourcePath,
    String caption = '',
  }) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return null;
    final dir = await _photosDir();
    final id = 'p-${DateTime.now().millisecondsSinceEpoch}';
    final ext = sourcePath.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    final fileName = '$jobId-$id.$ext';
    final dest = File('${dir.path}/$fileName');
    try {
      final src = File(sourcePath);
      await src.copy(dest.path);
    } catch (e, st) {
      DiagnosticsService.instance.error(
        'JobLogService',
        'Could not copy photo from $sourcePath into $fileName.',
        '$e\n$st',
      );
      return null;
    }
    final photo = JobPhoto(
      id: id,
      fileName: fileName,
      caption: caption.trim(),
      takenAt: DateTime.now(),
    );
    final j = _jobs[i];
    _jobs[i] = j.copyWith(photos: [...j.photos, photo]);
    await _save();
    notifyListeners();
    return photo;
  }

  Future<void> removePhoto(String jobId, String photoId) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return;
    final j = _jobs[i];
    final photo = j.photos.where((p) => p.id == photoId).cast<JobPhoto?>().firstWhere((p) => true, orElse: () => null);
    _jobs[i] = j.copyWith(
      photos: j.photos.where((p) => p.id != photoId).toList(),
    );
    if (photo != null) {
      try {
        final dir = await _photosDir();
        final f = File('${dir.path}/${photo.fileName}');
        if (await f.exists()) await f.delete();
      } catch (e, st) {
        DiagnosticsService.instance.warning(
          'JobLogService',
          'Could not delete photo file ${photo.fileName} — orphan file left behind.',
          '$e\n$st',
        );
      }
    }
    await _save();
    notifyListeners();
  }

  /// Resolve the absolute path of a [JobVoiceNote] on disk.
  Future<String> voiceNotePath(JobVoiceNote note) async {
    final dir = await _voiceNotesDir();
    return '${dir.path}/${note.fileName}';
  }

  Future<Directory> _voiceNotesDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/job_voice_notes');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Move a freshly-recorded audio file (typically in the temp directory)
  /// into the documents folder and attach a [JobVoiceNote] to the job. Uses
  /// `rename` first (cheap, same-filesystem) and falls back to copy + delete.
  Future<JobVoiceNote?> addVoiceNote({
    required String jobId,
    required String sourcePath,
    required Duration duration,
    String caption = '',
  }) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return null;
    final dir = await _voiceNotesDir();
    final id = 'v-${DateTime.now().millisecondsSinceEpoch}';
    final ext =
        sourcePath.toLowerCase().endsWith('.aac') ? 'aac' : 'm4a';
    final fileName = '$jobId-$id.$ext';
    final dest = File('${dir.path}/$fileName');
    try {
      final src = File(sourcePath);
      try {
        await src.rename(dest.path);
      } catch (_) {
        await src.copy(dest.path);
        try {
          await src.delete();
        } catch (_) {/* harmless leftover in temp */}
      }
    } catch (e, st) {
      DiagnosticsService.instance.error(
        'JobLogService',
        'Could not save voice note from $sourcePath into $fileName.',
        '$e\n$st',
      );
      return null;
    }
    final note = JobVoiceNote(
      id: id,
      fileName: fileName,
      caption: caption.trim(),
      recordedAt: DateTime.now(),
      duration: duration,
    );
    final j = _jobs[i];
    _jobs[i] = j.copyWith(voiceNotes: [...j.voiceNotes, note]);
    await _save();
    notifyListeners();
    return note;
  }

  Future<void> removeVoiceNote(String jobId, String noteId) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return;
    final j = _jobs[i];
    final note = j.voiceNotes
        .where((n) => n.id == noteId)
        .cast<JobVoiceNote?>()
        .firstWhere((n) => true, orElse: () => null);
    _jobs[i] = j.copyWith(
      voiceNotes: j.voiceNotes.where((n) => n.id != noteId).toList(),
    );
    if (note != null) {
      try {
        final dir = await _voiceNotesDir();
        final f = File('${dir.path}/${note.fileName}');
        if (await f.exists()) await f.delete();
      } catch (e, st) {
        DiagnosticsService.instance.warning(
          'JobLogService',
          'Could not delete voice note ${note.fileName} — orphan file left behind.',
          '$e\n$st',
        );
      }
    }
    await _save();
    notifyListeners();
  }

  Future<void> updateVoiceNoteCaption(
      String jobId, String noteId, String caption) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return;
    final j = _jobs[i];
    final updated = j.voiceNotes
        .map((n) => n.id == noteId ? n.copyWith(caption: caption) : n)
        .toList();
    _jobs[i] = j.copyWith(voiceNotes: updated);
    await _save();
    notifyListeners();
  }

  Future<void> updatePhotoCaption(
      String jobId, String photoId, String caption) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return;
    final j = _jobs[i];
    final updated = j.photos
        .map((p) => p.id == photoId ? p.copyWith(caption: caption) : p)
        .toList();
    _jobs[i] = j.copyWith(photos: updated);
    await _save();
    notifyListeners();
  }

  Future<void> markComplete(String jobId) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return;
    var j = _jobs[i];
    if (j.hasRunningTimer) j = _stopRunning(j);
    _jobs[i] = j.copyWith(
      status: JobStatus.completed,
      completedAt: DateTime.now(),
    );
    _sort();
    await _save();
    notifyListeners();
  }

  Future<void> reopen(String jobId) async {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i == -1) return;
    _jobs[i] = _jobs[i].copyWith(
      status: JobStatus.active,
      clearCompleted: true,
    );
    _sort();
    await _save();
    notifyListeners();
  }
}

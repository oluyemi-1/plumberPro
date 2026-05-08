import 'dart:convert';
import 'dart:math' as math;

import 'schema_safe.dart';

/// A single contiguous time interval clocked against a job. If [end] is null
/// the entry is currently being timed (clock is running).
class TimeEntry {
  final String id;
  final DateTime start;
  final DateTime? end;

  const TimeEntry({
    required this.id,
    required this.start,
    this.end,
  });

  bool get isRunning => end == null;

  /// Duration so far. For a running entry, computed against [now].
  Duration durationAt(DateTime now) {
    final stop = end ?? now;
    final d = stop.difference(start);
    return d.isNegative ? Duration.zero : d;
  }

  TimeEntry copyWith({DateTime? end}) =>
      TimeEntry(id: id, start: start, end: end ?? this.end);

  Map<String, dynamic> toJson() => {
        'id': id,
        'start': start.toIso8601String(),
        'end': end?.toIso8601String(),
      };

  factory TimeEntry.fromJson(Map<String, dynamic> j) => TimeEntry(
        id: j['id'] as String,
        start: DateTime.parse(j['start'] as String),
        end: j['end'] == null ? null : DateTime.parse(j['end'] as String),
      );
}

/// A single line of materials used on the job.
class MaterialLine {
  final String id;
  final String description;
  final double quantity;
  final double unitPriceGbp;

  const MaterialLine({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPriceGbp,
  });

  double get totalGbp => quantity * unitPriceGbp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPriceGbp,
      };

  factory MaterialLine.fromJson(Map<String, dynamic> j) => MaterialLine(
        id: j['id'] as String,
        description: j['description'] as String,
        quantity: (j['quantity'] as num).toDouble(),
        unitPriceGbp: (j['unitPrice'] as num).toDouble(),
      );
}

/// A photo attached to a job. The actual JPEG is stored on disk under
/// `<documents>/job_photos/<fileName>`.
class JobPhoto {
  final String id;
  final String fileName; // basename only — we resolve to documents/job_photos
  final String caption;
  final DateTime takenAt;

  const JobPhoto({
    required this.id,
    required this.fileName,
    required this.caption,
    required this.takenAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'caption': caption,
        'takenAt': takenAt.toIso8601String(),
      };

  factory JobPhoto.fromJson(Map<String, dynamic> j) => JobPhoto(
        id: j['id'] as String,
        fileName: j['fileName'] as String,
        caption: j['caption'] as String? ?? '',
        takenAt: DateTime.parse(j['takenAt'] as String),
      );

  JobPhoto copyWith({String? caption}) => JobPhoto(
        id: id,
        fileName: fileName,
        caption: caption ?? this.caption,
        takenAt: takenAt,
      );
}

/// A short audio recording attached to a job. The actual M4A is stored on
/// disk under `<documents>/job_voice_notes/<fileName>` so it can be backed
/// up alongside photos.
class JobVoiceNote {
  final String id;
  final String fileName; // basename only
  final String caption;
  final DateTime recordedAt;
  final Duration duration;

  const JobVoiceNote({
    required this.id,
    required this.fileName,
    required this.caption,
    required this.recordedAt,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'caption': caption,
        'recordedAt': recordedAt.toIso8601String(),
        'durationMs': duration.inMilliseconds,
      };

  factory JobVoiceNote.fromJson(Map<String, dynamic> j) => JobVoiceNote(
        id: j['id'] as String,
        fileName: j['fileName'] as String,
        caption: j['caption'] as String? ?? '',
        recordedAt: DateTime.parse(j['recordedAt'] as String),
        duration:
            Duration(milliseconds: (j['durationMs'] as num?)?.toInt() ?? 0),
      );

  JobVoiceNote copyWith({String? caption}) => JobVoiceNote(
        id: id,
        fileName: fileName,
        caption: caption ?? this.caption,
        recordedAt: recordedAt,
        duration: duration,
      );
}

enum JobStatus { active, completed }

extension JobStatusX on JobStatus {
  String get label {
    switch (this) {
      case JobStatus.active:
        return 'Active';
      case JobStatus.completed:
        return 'Completed';
    }
  }
}

class Job {
  final String id;
  final String customer;
  final String customerId; // links to Customer.id; empty when free-text
  final String address;
  final String description;
  final JobStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double hourlyRateGbp;
  final List<TimeEntry> entries;
  final List<MaterialLine> materials;
  final List<JobPhoto> photos;
  final List<JobVoiceNote> voiceNotes;
  final String notes;

  const Job({
    required this.id,
    required this.customer,
    required this.customerId,
    required this.address,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.completedAt,
    required this.hourlyRateGbp,
    required this.entries,
    required this.materials,
    required this.photos,
    required this.voiceNotes,
    required this.notes,
  });

  factory Job.create({
    required String customer,
    required String address,
    required String description,
    required double hourlyRateGbp,
    String customerId = '',
  }) =>
      Job(
        id: _generateId(),
        customer: customer,
        customerId: customerId,
        address: address,
        description: description,
        status: JobStatus.active,
        createdAt: DateTime.now(),
        completedAt: null,
        hourlyRateGbp: hourlyRateGbp,
        entries: const [],
        materials: const [],
        photos: const [],
        voiceNotes: const [],
        notes: '',
      );

  bool get hasRunningTimer => entries.any((e) => e.isRunning);

  TimeEntry? get runningEntry =>
      entries.where((e) => e.isRunning).cast<TimeEntry?>().firstWhere(
            (e) => true,
            orElse: () => null,
          );

  Duration totalTime(DateTime now) {
    var total = Duration.zero;
    for (final e in entries) {
      total += e.durationAt(now);
    }
    return total;
  }

  double labourCostAt(DateTime now) {
    final hours = totalTime(now).inSeconds / 3600.0;
    return hours * hourlyRateGbp;
  }

  double get materialsCost =>
      materials.fold(0.0, (a, m) => a + m.totalGbp);

  double totalCostAt(DateTime now) =>
      labourCostAt(now) + materialsCost;

  Job copyWith({
    String? customer,
    String? customerId,
    String? address,
    String? description,
    JobStatus? status,
    DateTime? completedAt,
    bool clearCompleted = false,
    double? hourlyRateGbp,
    List<TimeEntry>? entries,
    List<MaterialLine>? materials,
    List<JobPhoto>? photos,
    List<JobVoiceNote>? voiceNotes,
    String? notes,
  }) =>
      Job(
        id: id,
        customer: customer ?? this.customer,
        customerId: customerId ?? this.customerId,
        address: address ?? this.address,
        description: description ?? this.description,
        status: status ?? this.status,
        createdAt: createdAt,
        completedAt: clearCompleted ? null : (completedAt ?? this.completedAt),
        hourlyRateGbp: hourlyRateGbp ?? this.hourlyRateGbp,
        entries: entries ?? this.entries,
        materials: materials ?? this.materials,
        photos: photos ?? this.photos,
        voiceNotes: voiceNotes ?? this.voiceNotes,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer,
        'customerId': customerId,
        'address': address,
        'description': description,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'hourlyRate': hourlyRateGbp,
        'entries': entries.map((e) => e.toJson()).toList(),
        'materials': materials.map((m) => m.toJson()).toList(),
        'photos': photos.map((p) => p.toJson()).toList(),
        'voiceNotes': voiceNotes.map((v) => v.toJson()).toList(),
        'notes': notes,
      };

  factory Job.fromJson(Map<String, dynamic> j) => Job(
        id: j['id'] as String,
        customer: j['customer'] as String? ?? '',
        customerId: j['customerId'] as String? ?? '',
        address: j['address'] as String? ?? '',
        description: j['description'] as String? ?? '',
        status: JobStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => JobStatus.active,
        ),
        createdAt: DateTime.parse(j['createdAt'] as String),
        completedAt: j['completedAt'] == null
            ? null
            : DateTime.parse(j['completedAt'] as String),
        hourlyRateGbp: (j['hourlyRate'] as num?)?.toDouble() ?? 0,
        entries: ((j['entries'] as List?) ?? const [])
            .map((e) => TimeEntry.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ))
            .toList(),
        materials: ((j['materials'] as List?) ?? const [])
            .map((e) => MaterialLine.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ))
            .toList(),
        photos: ((j['photos'] as List?) ?? const [])
            .map((e) => JobPhoto.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ))
            .toList(),
        voiceNotes: ((j['voiceNotes'] as List?) ?? const [])
            .map((e) => JobVoiceNote.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ))
            .toList(),
        notes: j['notes'] as String? ?? '',
      );
}

String _generateId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final r = math.Random().nextInt(1 << 32);
  return '$ts-${r.toRadixString(36)}';
}

/// Helper for serialising a list of jobs.
String encodeJobs(List<Job> jobs) =>
    jsonEncode(jobs.map((j) => j.toJson()).toList());

List<Job> decodeJobs(String? raw) =>
    SchemaSafe.decodeList<Job>(
      key: 'job_log_jobs_v1',
      raw: raw,
      fromJson: Job.fromJson,
    );

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String formatHours(Duration d) {
  final hours = d.inSeconds / 3600.0;
  return hours.toStringAsFixed(2);
}

String formatGbp(double value) {
  return '£${value.toStringAsFixed(2)}';
}

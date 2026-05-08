import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/job_log_data.dart';

void main() {
  group('TimeEntry', () {
    test('durationAt is the gap between start and end when stopped', () {
      final start = DateTime.utc(2026, 1, 1, 9, 0);
      final end = DateTime.utc(2026, 1, 1, 11, 30);
      final e = TimeEntry(id: 'te-1', start: start, end: end);
      expect(e.isRunning, false);
      expect(e.durationAt(DateTime.utc(2030, 1, 1)),
          const Duration(hours: 2, minutes: 30));
    });

    test('durationAt uses now when running', () {
      final start = DateTime.utc(2026, 1, 1, 9, 0);
      final e = TimeEntry(id: 'te-2', start: start);
      expect(e.isRunning, true);
      final dur = e.durationAt(DateTime.utc(2026, 1, 1, 10, 15));
      expect(dur, const Duration(hours: 1, minutes: 15));
    });

    test('durationAt clamps negative durations to zero', () {
      final start = DateTime.utc(2026, 1, 1, 11, 0);
      final e = TimeEntry(id: 'te-3', start: start);
      // now is *before* start (e.g. clock skew on restore).
      expect(e.durationAt(DateTime.utc(2026, 1, 1, 10, 0)), Duration.zero);
    });

    test('round-trip preserves running state', () {
      final running = TimeEntry(
        id: 'te-running',
        start: DateTime.utc(2026, 1, 1, 9, 0),
      );
      final back = TimeEntry.fromJson(running.toJson());
      expect(back.isRunning, true);
      expect(back.end, isNull);
      expect(back.start, running.start);

      final stopped = running.copyWith(end: DateTime.utc(2026, 1, 1, 10, 0));
      final back2 = TimeEntry.fromJson(stopped.toJson());
      expect(back2.isRunning, false);
      expect(back2.end, stopped.end);
    });
  });

  group('MaterialLine', () {
    test('totalGbp = quantity × unit price', () {
      const m = MaterialLine(
        id: 'm-1',
        description: '15mm copper, 2m',
        quantity: 3,
        unitPriceGbp: 4.50,
      );
      expect(m.totalGbp, closeTo(13.50, 1e-9));
    });

    test('round-trip preserves all fields', () {
      const m = MaterialLine(
        id: 'm-2',
        description: 'TRV',
        quantity: 2.5,
        unitPriceGbp: 12.99,
      );
      final back = MaterialLine.fromJson(m.toJson());
      expect(back.id, m.id);
      expect(back.description, m.description);
      expect(back.quantity, m.quantity);
      expect(back.unitPriceGbp, m.unitPriceGbp);
    });
  });

  group('JobVoiceNote', () {
    test('JSON round-trip preserves every field', () {
      final n = JobVoiceNote(
        id: 'v-1',
        fileName: 'job-1-v-1.m4a',
        caption: 'Combustion analyser readings',
        recordedAt: DateTime.utc(2026, 5, 6, 10, 30),
        duration: const Duration(seconds: 45),
      );
      final back = JobVoiceNote.fromJson(n.toJson());
      expect(back.id, n.id);
      expect(back.fileName, n.fileName);
      expect(back.caption, n.caption);
      expect(back.recordedAt, n.recordedAt);
      expect(back.duration, n.duration);
    });

    test('zero-duration note round-trips', () {
      final n = JobVoiceNote(
        id: 'v-2',
        fileName: 'x.m4a',
        caption: '',
        recordedAt: DateTime.utc(2026, 5, 6),
        duration: Duration.zero,
      );
      final back = JobVoiceNote.fromJson(n.toJson());
      expect(back.duration, Duration.zero);
    });

    test('copyWith only updates the caption', () {
      final n = JobVoiceNote(
        id: 'v-3',
        fileName: 'a.m4a',
        caption: 'old',
        recordedAt: DateTime.utc(2026, 5, 6),
        duration: const Duration(seconds: 12),
      );
      final updated = n.copyWith(caption: 'new');
      expect(updated.caption, 'new');
      expect(updated.fileName, n.fileName);
      expect(updated.duration, n.duration);
    });
  });

  group('Job math', () {
    Job buildJob({
      List<TimeEntry> entries = const [],
      List<MaterialLine> materials = const [],
      double rate = 50.0,
    }) =>
        Job(
          id: 'j-1',
          customer: 'Test',
          customerId: '',
          address: '',
          description: '',
          status: JobStatus.active,
          createdAt: DateTime.utc(2026, 1, 1),
          completedAt: null,
          hourlyRateGbp: rate,
          entries: entries,
          materials: materials,
          photos: const [],
          voiceNotes: const [],
          notes: '',
        );

    test('totalTime sums every entry', () {
      final j = buildJob(entries: [
        TimeEntry(
          id: 'a',
          start: DateTime.utc(2026, 1, 1, 9, 0),
          end: DateTime.utc(2026, 1, 1, 10, 30),
        ),
        TimeEntry(
          id: 'b',
          start: DateTime.utc(2026, 1, 1, 13, 0),
          end: DateTime.utc(2026, 1, 1, 14, 0),
        ),
      ]);
      expect(j.totalTime(DateTime.utc(2030, 1, 1)),
          const Duration(hours: 2, minutes: 30));
    });

    test('labourCostAt = hours × hourly rate', () {
      final j = buildJob(rate: 60, entries: [
        TimeEntry(
          id: 'a',
          start: DateTime.utc(2026, 1, 1, 9, 0),
          end: DateTime.utc(2026, 1, 1, 11, 0),
        ),
      ]);
      expect(j.labourCostAt(DateTime.utc(2030, 1, 1)), closeTo(120.0, 1e-9));
    });

    test('materialsCost sums every line', () {
      final j = buildJob(materials: const [
        MaterialLine(
            id: 'm1', description: 'A', quantity: 2, unitPriceGbp: 5),
        MaterialLine(
            id: 'm2', description: 'B', quantity: 1.5, unitPriceGbp: 8),
      ]);
      expect(j.materialsCost, closeTo(10 + 12, 1e-9));
    });

    test('totalCostAt = labour + materials', () {
      final j = buildJob(
        rate: 50,
        entries: [
          TimeEntry(
            id: 'a',
            start: DateTime.utc(2026, 1, 1, 9, 0),
            end: DateTime.utc(2026, 1, 1, 10, 0),
          ),
        ],
        materials: const [
          MaterialLine(
              id: 'm', description: 'Part', quantity: 1, unitPriceGbp: 25),
        ],
      );
      expect(j.totalCostAt(DateTime.utc(2030, 1, 1)), closeTo(75.0, 1e-9));
    });

    test('hasRunningTimer detects an entry with no end', () {
      final j = buildJob(entries: [
        TimeEntry(id: 'a', start: DateTime.utc(2026, 1, 1, 9, 0)),
      ]);
      expect(j.hasRunningTimer, true);
    });
  });

  group('Job JSON', () {
    test('round-trip preserves a fully-populated job', () {
      final j = Job(
        id: 'job-1',
        customer: 'Mrs Brown',
        customerId: 'c-42',
        address: '5 Main St',
        description: 'Annual boiler service',
        status: JobStatus.completed,
        createdAt: DateTime.utc(2026, 3, 1, 9, 0),
        completedAt: DateTime.utc(2026, 3, 1, 12, 0),
        hourlyRateGbp: 55,
        entries: [
          TimeEntry(
            id: 'e1',
            start: DateTime.utc(2026, 3, 1, 9, 0),
            end: DateTime.utc(2026, 3, 1, 11, 0),
          ),
        ],
        materials: const [
          MaterialLine(
              id: 'm1', description: 'Seals', quantity: 1, unitPriceGbp: 8),
        ],
        photos: [
          JobPhoto(
            id: 'p1',
            fileName: 'job-1-p1.jpg',
            caption: 'Combustion analyser',
            takenAt: DateTime.utc(2026, 3, 1, 10, 0),
          ),
        ],
        voiceNotes: [
          JobVoiceNote(
            id: 'v1',
            fileName: 'job-1-v1.m4a',
            caption: 'Pressure readings dictation',
            recordedAt: DateTime.utc(2026, 3, 1, 10, 30),
            duration: const Duration(seconds: 38),
          ),
        ],
        notes: 'CO/CO2 ratio: 0.0001',
      );
      final back = Job.fromJson(j.toJson());
      expect(back.id, j.id);
      expect(back.customer, j.customer);
      expect(back.customerId, j.customerId);
      expect(back.status, JobStatus.completed);
      expect(back.completedAt, j.completedAt);
      expect(back.hourlyRateGbp, j.hourlyRateGbp);
      expect(back.entries.length, 1);
      expect(back.entries.first.id, 'e1');
      expect(back.materials.length, 1);
      expect(back.materials.first.totalGbp, 8.0);
      expect(back.photos.length, 1);
      expect(back.photos.first.fileName, 'job-1-p1.jpg');
      expect(back.voiceNotes.length, 1);
      expect(back.voiceNotes.first.id, 'v1');
      expect(back.voiceNotes.first.duration,
          const Duration(seconds: 38));
      expect(back.notes, j.notes);
    });

    test('list encode/decode round-trip', () {
      final jobs = [
        Job.create(
            customer: 'A',
            address: '',
            description: '',
            hourlyRateGbp: 40),
        Job.create(
            customer: 'B',
            address: 'Addr',
            description: 'Desc',
            hourlyRateGbp: 60),
      ];
      final raw = encodeJobs(jobs);
      final back = decodeJobs(raw);
      expect(back.length, 2);
      expect(back[0].customer, 'A');
      expect(back[1].address, 'Addr');
    });

    test('decodeJobs is null/corrupt-safe', () {
      expect(decodeJobs(null), isEmpty);
      expect(decodeJobs(''), isEmpty);
      expect(decodeJobs('garbage'), isEmpty);
    });

    test('fromJson defaults missing status to active', () {
      final back = Job.fromJson({
        'id': 'jx',
        'customer': '',
        'address': '',
        'description': '',
        'createdAt': '2026-01-01T00:00:00Z',
        'hourlyRate': 40,
      });
      expect(back.status, JobStatus.active);
      expect(back.entries, isEmpty);
      expect(back.materials, isEmpty);
      expect(back.photos, isEmpty);
      // Legacy backups (pre-voice-notes) must decode cleanly.
      expect(back.voiceNotes, isEmpty);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/job_log_data.dart';
import 'package:plumbing_and_heating/services/storage_service.dart';

/// The full `StorageService.scan` walks the filesystem so it isn't
/// covered here — but the byte formatter is pure, exposed publicly, and
/// gets eyeballed everywhere on the Storage screen, so locking it in
/// matters more than the disk walk.
void main() {
  group('formatBytes', () {
    test('handles small byte counts in B', () {
      expect(formatBytes(0), '0 B');
      expect(formatBytes(1), '1 B');
      expect(formatBytes(512), '512 B');
      expect(formatBytes(1023), '1023 B');
    });

    test('switches to KB at 1024 bytes', () {
      expect(formatBytes(1024), '1.0 KB');
      expect(formatBytes(1536), '1.5 KB');
      expect(formatBytes(2048), '2.0 KB');
    });

    test('switches to MB at 1 MiB', () {
      expect(formatBytes(1024 * 1024), '1.0 MB');
      expect(formatBytes(1024 * 1024 * 5), '5.0 MB');
      // Realistic phone photo around 2.4 MB.
      expect(formatBytes(2_500_000), '2.4 MB');
    });

    test('switches to GB at 1 GiB and uses 2 decimals', () {
      expect(formatBytes(1024 * 1024 * 1024), '1.00 GB');
      expect(formatBytes(1024 * 1024 * 1024 * 3), '3.00 GB');
    });

    test('clamps negative inputs to 0 B (never displays a minus sign)', () {
      expect(formatBytes(-1), '0 B');
      expect(formatBytes(-9999), '0 B');
    });
  });

  group('JobStorage', () {
    test('totalBytes = photo + voice', () {
      const j = JobStorage(
        jobId: 'j-1',
        customerName: 'Smith',
        status: JobStatus.active,
        completedAt: null,
        photoBytes: 1024 * 1024,
        voiceNoteBytes: 256 * 1024,
        photoCount: 2,
        voiceNoteCount: 1,
      );
      expect(j.totalBytes, 1024 * 1024 + 256 * 1024);
      expect(j.fileCount, 3);
    });
  });

  group('StorageScan.empty', () {
    test('totalBytes / totalCount are zero', () {
      expect(StorageScan.empty.totalBytes, 0);
      expect(StorageScan.empty.totalCount, 0);
      expect(StorageScan.empty.byJob, isEmpty);
      expect(StorageScan.empty.orphanPhotoFiles, isEmpty);
      expect(StorageScan.empty.orphanVoiceFiles, isEmpty);
    });
  });
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/backup_service.dart';
import '../theme.dart';

/// Backup & restore — manual export of every piece of user data plus job
/// photos to a single zip the user can save to email / Drive / iCloud and
/// import on another device.
class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _exporting = false;
  bool _restoring = false;

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await BackupService.exportBackup();
      if (!mounted) return;
      if (!result.isComplete) {
        final parts = <String>[];
        if (result.photosMissing > 0) {
          parts.add(
              '${result.photosMissing} of ${result.photosExpected} photo${result.photosExpected == 1 ? '' : 's'}');
        }
        if (result.voiceNotesMissing > 0) {
          parts.add(
              '${result.voiceNotesMissing} of ${result.voiceNotesExpected} voice note${result.voiceNotesExpected == 1 ? '' : 's'}');
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Backup created, but ${parts.join(' and ')} could not be read. See Settings → Diagnostics for details.',
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _restore() async {
    if (_restoring) return;
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Pick a Plumber Pro backup zip',
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    final bytes = picked.bytes;
    if (bytes == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not read the chosen file.')),
      );
      return;
    }
    final summary = await BackupService.peekBackup(bytes);
    if (!mounted) return;
    if (summary == null) {
      messenger.showSnackBar(
        const SnackBar(
            content:
                Text('That zip does not look like a Plumber Pro backup.')),
      );
      return;
    }
    final ok = await _confirmDialog(summary);
    if (ok != true) return;
    setState(() => _restoring = true);
    try {
      final result = await BackupService.restoreFromBytes(bytes);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(result)),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<bool?> _confirmDialog(BackupSummary s) {
    final created = s.createdAt;
    final dateStr = created == null
        ? 'unknown date'
        : '${created.day}/${created.month}/${created.year} '
            '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore from this backup?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Backup created: $dateStr'),
            const SizedBox(height: 6),
            Text('Jobs: ${s.jobsCount}'),
            Text('Customers: ${s.customersCount}'),
            Text('Bookmarks: ${s.bookmarksCount}'),
            Text('Photos: ${s.photosCount}'),
            const SizedBox(height: 10),
            const Text(
              'This will overwrite your current data on this device. Make a backup first if you want to keep it.',
              style: TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & restore')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: AppColors.primary.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.cloud_upload,
                        color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Move your data to another device',
                        style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 6),
                  const Text(
                      'Export creates a single zip file containing all your jobs, customers, bookmarks, progress, SRS state, AI key, profile and every job photo. Save it somewhere you can reach from your other device — email it to yourself, drop it in Drive or iCloud, or AirDrop it directly.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Export backup',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  const Text(
                      'Bundles everything into a zip and opens the share sheet. The default filename includes today\'s date.'),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _exporting ? null : _export,
                    icon: _exporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.share),
                    label: Text(_exporting
                        ? 'Bundling…'
                        : 'Export & share backup'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Restore from backup',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  const Text(
                      'Pick a backup zip from your device. You will see a summary and confirm before anything is overwritten.'),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _restoring ? null : _restore,
                    icon: _restoring
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_download),
                    label: Text(_restoring
                        ? 'Restoring…'
                        : 'Restore from backup file'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            color: AppColors.cardBg,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.privacy_tip,
                        color: AppColors.muted, size: 18),
                    const SizedBox(width: 6),
                    Text('What is in the backup',
                        style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 4),
                  const Text(
                      '• Jobs, time entries, materials, notes, totals\n• Customers (name, address, phone, email, notes)\n• Job photos\n• Bookmarks, recently-opened, streak, role / goals / name\n• SRS schedule, quiz scores, checklist progress\n• Voice / TTS settings, hourly rate, business profile\n• Anthropic API key — yours, on your device only\n\nThe backup is unencrypted. Treat it like a password — anyone with the file has all of the above. For sensitive customer data, prefer keeping it on encrypted device storage.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            color: AppColors.gas.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.cloud_sync, color: AppColors.gas),
                    const SizedBox(width: 8),
                    Text('Real-time cloud sync (later)',
                        style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 4),
                  const Text(
                      'Manual backup is enough for "I got a new phone". For real-time multi-device sync (changes on phone appear on tablet within seconds, automatic cloud backup) you would add Firebase Auth + Firestore + Storage. The README explains the upgrade path.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


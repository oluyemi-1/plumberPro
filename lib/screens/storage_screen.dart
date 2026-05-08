import 'package:flutter/material.dart';

import '../data/job_log_data.dart';
import '../services/job_log_service.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import 'job_detail_screen.dart';

/// Disk-usage breakdown plus the "free up space" actions. Reachable from
/// Settings → Storage.
class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  StorageScan? _scan;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _busy = true);
    final s = await StorageService.scan();
    if (!mounted) return;
    setState(() {
      _scan = s;
      _busy = false;
    });
  }

  Future<void> _deleteOrphans() async {
    final s = _scan;
    if (s == null || (s.orphanPhotoFiles.isEmpty && s.orphanVoiceFiles.isEmpty)) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete orphaned files?'),
        content: Text(
          'Removes ${s.orphanPhotoFiles.length} photo${s.orphanPhotoFiles.length == 1 ? '' : 's'} and ${s.orphanVoiceFiles.length} voice note${s.orphanVoiceFiles.length == 1 ? '' : 's'} that no job references. Frees ${formatBytes(s.orphanBytes)}. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    final freed = await StorageService.deleteOrphans(s);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Freed ${formatBytes(freed)}.')),
    );
    await _refresh();
  }

  Future<void> _purgeOldMedia() async {
    final picked = await showModalBottomSheet<Duration?>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              dense: true,
              title: Text('Free up space'),
              subtitle: Text(
                  'Deletes photos AND voice notes from completed jobs older than the chosen age. Job records, time entries and totals are kept.'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Older than 6 months'),
              onTap: () =>
                  Navigator.pop(context, const Duration(days: 183)),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Older than 1 year'),
              onTap: () => Navigator.pop(context, const Duration(days: 365)),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Older than 2 years'),
              onTap: () =>
                  Navigator.pop(context, const Duration(days: 365 * 2)),
            ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final cutoff = DateTime.now().subtract(picked);
    final affected = JobLogService.instance.jobs.where((j) =>
        j.status == JobStatus.completed &&
        j.completedAt != null &&
        j.completedAt!.isBefore(cutoff) &&
        (j.photos.isNotEmpty || j.voiceNotes.isNotEmpty)).toList();
    if (affected.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No jobs match that age.')),
      );
      return;
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm media cleanup'),
        content: Text(
          'About to delete photos and voice notes from ${affected.length} completed job${affected.length == 1 ? '' : 's'}. Job details (time entries, materials, notes, totals) are kept. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete media'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    final deleted = await StorageService.purgeOldCompletedJobsMedia(picked);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Deleted $deleted file${deleted == 1 ? '' : 's'}.')),
    );
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final s = _scan ?? StorageScan.empty;
    final hasOrphans =
        s.orphanPhotoFiles.isNotEmpty || s.orphanVoiceFiles.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _busy ? null : _refresh,
          ),
        ],
      ),
      body: _busy && _scan == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
              children: [
                _TotalCard(scan: s),
                const SizedBox(height: 12),
                _StatGrid(scan: s),
                const SizedBox(height: 14),
                Text('Free up space',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                if (hasOrphans)
                  Card(
                    color: Colors.redAccent.withValues(alpha: 0.08),
                    child: ListTile(
                      leading: const Icon(Icons.cleaning_services,
                          color: Colors.redAccent),
                      title: Text(
                        'Delete ${s.orphanPhotoFiles.length + s.orphanVoiceFiles.length} orphaned file${(s.orphanPhotoFiles.length + s.orphanVoiceFiles.length) == 1 ? '' : 's'}',
                      ),
                      subtitle: Text(
                          'Files no job points to. Frees ${formatBytes(s.orphanBytes)}.'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _busy ? null : _deleteOrphans,
                    ),
                  ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.delete_sweep,
                        color: AppColors.accent),
                    title: const Text('Delete media on old completed jobs'),
                    subtitle: const Text(
                        'Photos + voice notes from jobs you finished long ago. The job record stays.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _busy ? null : _purgeOldMedia,
                  ),
                ),
                if (s.byJob.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text('Top jobs by storage',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  for (final j in s.byJob.take(10))
                    _JobStorageRow(jobStorage: j),
                  if (s.byJob.length > 10)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '+ ${s.byJob.length - 10} more job${s.byJob.length - 10 == 1 ? '' : 's'} not shown.',
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12),
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Storage figures cover photos and voice notes only. Job records, customers, quotes and reminders are tiny by comparison and are not deleted by these actions.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final StorageScan scan;
  const _TotalCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('STORAGE USED',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                )),
            const SizedBox(height: 4),
            Text(formatBytes(scan.totalBytes),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              '${scan.totalCount} file${scan.totalCount == 1 ? '' : 's'} across photos and voice notes',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final StorageScan scan;
  const _StatGrid({required this.scan});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: [
        _StatTile(
          icon: Icons.photo,
          color: AppColors.primary,
          label: 'Photos',
          value: formatBytes(scan.photoBytes),
          detail:
              '${scan.photoCount} file${scan.photoCount == 1 ? '' : 's'}',
        ),
        _StatTile(
          icon: Icons.mic,
          color: AppColors.accent,
          label: 'Voice notes',
          value: formatBytes(scan.voiceNoteBytes),
          detail:
              '${scan.voiceNoteCount} file${scan.voiceNoteCount == 1 ? '' : 's'}',
        ),
        _StatTile(
          icon: Icons.folder_special,
          color: const Color(0xFF6F4E7C),
          label: 'On-disk total',
          value: formatBytes(scan.totalBytes),
          detail: 'Photos + voice + orphans',
        ),
        _StatTile(
          icon: Icons.warning_amber,
          color: scan.orphanBytes > 0 ? Colors.redAccent : AppColors.muted,
          label: 'Orphans',
          value: formatBytes(scan.orphanBytes),
          detail:
              '${scan.orphanPhotoFiles.length + scan.orphanVoiceFiles.length} unreferenced file${(scan.orphanPhotoFiles.length + scan.orphanVoiceFiles.length) == 1 ? '' : 's'}',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String detail;
  const _StatTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ]),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              detail,
              style:
                  const TextStyle(color: AppColors.muted, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _JobStorageRow extends StatelessWidget {
  final JobStorage jobStorage;
  const _JobStorageRow({required this.jobStorage});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          jobStorage.status == JobStatus.completed
              ? Icons.check_circle
              : Icons.work,
          color: jobStorage.status == JobStatus.completed
              ? Colors.green
              : AppColors.primary,
        ),
        title: Text(
          jobStorage.customerName.isEmpty
              ? 'Untitled job'
              : jobStorage.customerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${jobStorage.photoCount} photo${jobStorage.photoCount == 1 ? '' : 's'} · ${jobStorage.voiceNoteCount} voice note${jobStorage.voiceNoteCount == 1 ? '' : 's'}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          formatBytes(jobStorage.totalBytes),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailScreen(jobId: jobStorage.jobId),
          ),
        ),
      ),
    );
  }
}

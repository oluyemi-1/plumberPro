import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/diagnostics_service.dart';
import '../theme.dart';

/// In-app log of background errors / warnings / info messages from the
/// services layer. Reachable from Settings.
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final Set<DiagSeverity> _filter = {
    DiagSeverity.info,
    DiagSeverity.warning,
    DiagSeverity.error,
  };

  @override
  void initState() {
    super.initState();
    DiagnosticsService.instance.ensureLoaded();
  }

  Color _color(DiagSeverity s) {
    switch (s) {
      case DiagSeverity.info:
        return AppColors.primary;
      case DiagSeverity.warning:
        return AppColors.accent;
      case DiagSeverity.error:
        return Colors.redAccent;
    }
  }

  IconData _icon(DiagSeverity s) {
    switch (s) {
      case DiagSeverity.info:
        return Icons.info_outline;
      case DiagSeverity.warning:
        return Icons.warning_amber;
      case DiagSeverity.error:
        return Icons.error_outline;
    }
  }

  String _formatWhen(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear the diagnostics log?'),
        content: const Text(
            'Removes every entry. This is fine — the log is local-only and only useful when something has just gone wrong.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DiagnosticsService.instance.clear();
    }
  }

  Future<void> _copyAll() async {
    final events = DiagnosticsService.instance.events;
    final text = events
        .map((e) =>
            '[${e.at.toIso8601String()}] ${e.severity.name.toUpperCase()} ${e.source}: ${e.message}${e.details == null ? '' : '\n  ${e.details}'}')
        .join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied ${events.length} entries to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(
            tooltip: 'Copy all',
            icon: const Icon(Icons.copy),
            onPressed: _copyAll,
          ),
          IconButton(
            tooltip: 'Clear log',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _confirmClear,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: DiagnosticsService.instance,
        builder: (context, _) {
          final all = DiagnosticsService.instance.events;
          final shown =
              all.where((e) => _filter.contains(e.severity)).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final s in DiagSeverity.values)
                      FilterChip(
                        label: Text(_label(s)),
                        selected: _filter.contains(s),
                        selectedColor: _color(s).withValues(alpha: 0.16),
                        onSelected: (sel) => setState(() {
                          if (sel) {
                            _filter.add(s);
                          } else {
                            _filter.remove(s);
                          }
                        }),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                        itemCount: shown.length,
                        itemBuilder: (_, i) {
                          final e = shown[i];
                          return _DiagRow(
                            event: e,
                            color: _color(e.severity),
                            icon: _icon(e.severity),
                            when: _formatWhen(e.at),
                          );
                        },
                      ),
              ),
              if (all.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Text(
                    'Showing ${shown.length} of ${all.length} (cap ${DiagnosticsService.maxEvents}).',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _label(DiagSeverity s) {
    final n = DiagnosticsService.instance.events
        .where((e) => e.severity == s)
        .length;
    return '${s.name[0].toUpperCase()}${s.name.substring(1)} ($n)';
  }
}

class _DiagRow extends StatelessWidget {
  final DiagEvent event;
  final Color color;
  final IconData icon;
  final String when;
  const _DiagRow({
    required this.event,
    required this.color,
    required this.icon,
    required this.when,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(event.source,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
                Text(when,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11)),
              ]),
              const SizedBox(height: 6),
              SelectableText(event.message),
              if (event.details != null && event.details!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectableText(
                    event.details!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 64, color: AppColors.muted),
            const SizedBox(height: 8),
            Text('No diagnostics yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Background services log here when something goes wrong (notification scheduling, photo IO, backup zip, etc.). An empty log usually means everything\'s fine.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

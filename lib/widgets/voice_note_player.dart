import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../data/job_log_data.dart';
import '../services/diagnostics_service.dart';
import '../services/job_log_service.dart';
import '../theme.dart';

/// Inline play/pause widget for a single saved voice note. Owns its own
/// `AudioPlayer`, releases it on dispose, and shows a thin progress
/// indicator under the row.
class VoiceNotePlayer extends StatefulWidget {
  final JobVoiceNote note;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onCaptionChanged;
  const VoiceNotePlayer({
    super.key,
    required this.note,
    this.onDelete,
    this.onCaptionChanged,
  });

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  final _player = AudioPlayer();
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<void>? _completeSub;

  Duration _position = Duration.zero;
  bool _playing = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _posSub = _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _stateSub = _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _playing = s == PlayerState.playing);
    });
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_playing) {
        await _player.pause();
      } else {
        final path =
            await JobLogService.instance.voiceNotePath(widget.note);
        await _player.play(DeviceFileSource(path));
      }
    } catch (e, st) {
      DiagnosticsService.instance.error(
        'VoiceNotePlayer',
        'Playback failed for ${widget.note.fileName}.',
        '$e\n$st',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not play that voice note.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editCaption() async {
    final ctrl = TextEditingController(text: widget.note.caption);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Caption'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration:
              const InputDecoration(hintText: 'Short label for this note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true) widget.onCaptionChanged?.call(ctrl.text);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatRecordedAt(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.note.duration;
    final progress = total.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(children: [
            IconButton(
              tooltip: _playing ? 'Pause' : 'Play',
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _playing ? Icons.pause_circle : Icons.play_circle,
                      color: AppColors.primary,
                      size: 32,
                    ),
              onPressed: _toggle,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.note.caption.isEmpty
                        ? 'Voice note'
                        : widget.note.caption,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_formatDuration(total)}  ·  ${_formatRecordedAt(widget.note.recordedAt)}',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit caption',
              icon: const Icon(Icons.edit, size: 18, color: AppColors.muted),
              onPressed: _editCaption,
            ),
            if (widget.onDelete != null)
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: AppColors.muted),
                onPressed: widget.onDelete,
              ),
          ]),
          if (_playing || _position > Duration.zero)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: AppColors.muted.withValues(alpha: 0.18),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

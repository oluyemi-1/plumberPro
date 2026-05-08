import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../services/diagnostics_service.dart';
import '../theme.dart';

/// Successful capture from [VoiceRecorderSheet]. The caller copies [path]
/// out of the temp dir (via `JobLogService.addVoiceNote`) — the temp file
/// is otherwise abandoned by the OS.
class VoiceRecordingResult {
  final String path;
  final Duration duration;
  final String caption;
  const VoiceRecordingResult({
    required this.path,
    required this.duration,
    required this.caption,
  });
}

/// Modal bottom-sheet that records a single voice note. Pops with a
/// [VoiceRecordingResult] when the user taps Save, or with `null` when
/// they cancel / deny mic permission. The recorder is stopped + cleaned
/// up automatically on dispose so a forgotten sheet doesn't leak.
class VoiceRecorderSheet extends StatefulWidget {
  const VoiceRecorderSheet({super.key});

  @override
  State<VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

class _VoiceRecorderSheetState extends State<VoiceRecorderSheet> {
  final _recorder = AudioRecorder();
  final _captionCtrl = TextEditingController();

  Timer? _ticker;
  DateTime? _startedAt;
  Duration _accumulated = Duration.zero;
  String? _path;
  bool _isPaused = false;
  bool _isStopped = false;
  bool _starting = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    // Best-effort cleanup. If the user just dismisses the sheet, abandon
    // any in-progress recording so we don't leave the mic engaged.
    _recorder.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  Duration get _elapsed {
    if (_startedAt == null || _isPaused || _isStopped) return _accumulated;
    return _accumulated + DateTime.now().difference(_startedAt!);
  }

  Future<void> _start() async {
    try {
      final ok = await _recorder.hasPermission();
      if (!ok) {
        setState(() {
          _starting = false;
          _error =
              'Microphone permission denied. Enable it in your phone\'s settings to record voice notes.';
        });
        return;
      }
      final tmpDir = await getTemporaryDirectory();
      final path =
          '${tmpDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );
      _path = path;
      _startedAt = DateTime.now();
      _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (mounted) setState(() {});
      });
      setState(() => _starting = false);
    } catch (e, st) {
      DiagnosticsService.instance.error(
        'VoiceRecorderSheet',
        'Could not start audio recording.',
        '$e\n$st',
      );
      if (mounted) {
        setState(() {
          _starting = false;
          _error = 'Could not start recording: $e';
        });
      }
    }
  }

  Future<void> _pause() async {
    if (_isPaused || _isStopped) return;
    try {
      await _recorder.pause();
      _accumulated += DateTime.now().difference(_startedAt!);
      _startedAt = null;
      setState(() => _isPaused = true);
    } catch (e, st) {
      DiagnosticsService.instance.warning(
        'VoiceRecorderSheet',
        'Pause failed.',
        '$e\n$st',
      );
    }
  }

  Future<void> _resume() async {
    if (!_isPaused || _isStopped) return;
    try {
      await _recorder.resume();
      _startedAt = DateTime.now();
      setState(() => _isPaused = false);
    } catch (e, st) {
      DiagnosticsService.instance.warning(
        'VoiceRecorderSheet',
        'Resume failed.',
        '$e\n$st',
      );
    }
  }

  Future<void> _stop() async {
    if (_isStopped) return;
    try {
      _ticker?.cancel();
      if (_startedAt != null && !_isPaused) {
        _accumulated += DateTime.now().difference(_startedAt!);
        _startedAt = null;
      }
      final path = await _recorder.stop();
      setState(() {
        _isStopped = true;
        _path = path ?? _path;
      });
    } catch (e, st) {
      DiagnosticsService.instance.error(
        'VoiceRecorderSheet',
        'Stop failed.',
        '$e\n$st',
      );
      if (mounted) {
        setState(() {
          _isStopped = true;
          _error = 'Could not finalise recording: $e';
        });
      }
    }
  }

  Future<void> _cancel() async {
    _ticker?.cancel();
    try {
      await _recorder.cancel();
    } catch (_) {/* ignore — file may not have been written yet */}
    // Wipe the temp file too — `cancel()` is supposed to do this but we
    // belt-and-braces it.
    final p = _path;
    if (p != null) {
      try {
        final f = File(p);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _save() async {
    if (!_isStopped) await _stop();
    if (!mounted) return;
    final p = _path;
    if (p == null || _elapsed == Duration.zero) {
      Navigator.pop(context);
      return;
    }
    Navigator.pop(
      context,
      VoiceRecordingResult(
        path: p,
        duration: _elapsed,
        caption: _captionCtrl.text.trim(),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DragHandle(),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.mic, color: AppColors.accent),
              const SizedBox(width: 8),
              Text('Voice note',
                  style: Theme.of(context).textTheme.titleLarge),
            ]),
            const SizedBox(height: 12),
            if (_starting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.redAccent)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ] else ...[
              _RecordingIndicator(
                isPaused: _isPaused,
                isStopped: _isStopped,
                elapsed: _formatDuration(_elapsed),
              ),
              const SizedBox(height: 18),
              if (!_isStopped)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _cancel,
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                    ),
                    if (!_isPaused)
                      OutlinedButton.icon(
                        onPressed: _pause,
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _resume,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Resume'),
                      ),
                    ElevatedButton.icon(
                      onPressed: _stop,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                    ),
                  ],
                )
              else ...[
                TextField(
                  controller: _captionCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Caption (optional)',
                    hintText: 'e.g. Combustion analyser readings',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _cancel,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Discard'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 36,
          height: 4,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.muted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

/// Pulsing red dot + elapsed timer. Goes amber when paused, grey when
/// stopped (so the user can still see how long they recorded).
class _RecordingIndicator extends StatefulWidget {
  final bool isPaused;
  final bool isStopped;
  final String elapsed;
  const _RecordingIndicator({
    required this.isPaused,
    required this.isStopped,
    required this.elapsed,
  });

  @override
  State<_RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<_RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    String label;
    if (widget.isStopped) {
      dotColor = AppColors.muted;
      label = 'STOPPED';
    } else if (widget.isPaused) {
      dotColor = Colors.orangeAccent;
      label = 'PAUSED';
    } else {
      dotColor = Colors.redAccent;
      label = 'RECORDING';
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dotColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final pulse = widget.isStopped || widget.isPaused
                  ? 1.0
                  : (0.5 + 0.5 * _ctrl.value);
              return Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: dotColor.withValues(alpha: pulse),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: dotColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          Text(
            widget.elapsed,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

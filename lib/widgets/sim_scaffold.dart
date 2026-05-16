import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../services/tts_service.dart';
import '../theme.dart';

/// A single narrated step within a simulation.
class SimStep {
  final String title;
  final String narration;
  const SimStep({required this.title, required this.narration});
}

/// Re-usable scaffold for any narrated animated simulation.
///
/// Provides: the canvas area, a step list, TTS controls, play / pause and the
/// narration caption bar. Each simulation screen supplies the diagram widget
/// plus the list of steps, and optionally updates some simulation state when
/// a step is activated via [onStepChanged].
class SimScaffold extends StatefulWidget {
  final String title;
  final String summary;
  final Widget Function(BuildContext, int stepIndex) diagramBuilder;
  final List<SimStep> steps;
  final List<Widget>? controls;
  final void Function(int stepIndex)? onStepChanged;
  final bool autoPlay;

  const SimScaffold({
    super.key,
    required this.title,
    required this.summary,
    required this.diagramBuilder,
    required this.steps,
    this.controls,
    this.onStepChanged,
    this.autoPlay = false,
  });

  @override
  State<SimScaffold> createState() => _SimScaffoldState();
}

class _SimScaffoldState extends State<SimScaffold> {
  int _step = 0;
  bool _autoAdvance = false;

  @override
  void initState() {
    super.initState();
    // Keep the screen on while the engineer steps through the simulation —
    // they are often watching the diagram or listening to TTS hands-free.
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStepChanged?.call(_step);
      if (widget.autoPlay) _speakCurrent();
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _speakCurrent() async {
    final step = widget.steps[_step];
    await TtsService.instance.speak('${step.title}. ${step.narration}');
    if (_autoAdvance && mounted && _step < widget.steps.length - 1) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted || !_autoAdvance) return;
      _goto(_step + 1);
      await _speakCurrent();
    }
  }

  void _goto(int i) {
    if (i < 0 || i >= widget.steps.length) return;
    setState(() => _step = i);
    widget.onStepChanged?.call(i);
  }

  @override
  Widget build(BuildContext context) {
    final tts = TtsService.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          AnimatedBuilder(
            animation: tts,
            builder: (_, __) => IconButton(
              tooltip: tts.enabled ? 'Mute narration' : 'Unmute narration',
              onPressed: () => tts.setEnabled(!tts.enabled),
              icon: Icon(tts.enabled ? Icons.volume_up : Icons.volume_off),
            ),
          ),
          PopupMenuButton<double>(
            tooltip: 'Narration speed',
            icon: const Icon(Icons.speed),
            onSelected: (v) => tts.setRate(v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 0.35, child: Text('Slow')),
              PopupMenuItem(value: 0.48, child: Text('Normal')),
              PopupMenuItem(value: 0.62, child: Text('Fast')),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 820;
          final diagram = Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: AspectRatio(
                aspectRatio: isWide ? 1.3 : 0.95,
                child: widget.diagramBuilder(context, _step),
              ),
            ),
          );
          final sidebar = _SidebarPanel(
            summary: widget.summary,
            steps: widget.steps,
            currentIndex: _step,
            autoAdvance: _autoAdvance,
            onAutoAdvance: (v) {
              setState(() => _autoAdvance = v);
              if (v) _speakCurrent();
            },
            onStep: _goto,
            onSpeak: _speakCurrent,
            onStop: () => TtsService.instance.stop(),
            controls: widget.controls,
          );
          if (isWide) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: diagram),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: sidebar),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                diagram,
                const SizedBox(height: 12),
                sidebar,
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _NarrationBar(
        stepIndex: _step,
        totalSteps: widget.steps.length,
        currentTitle: widget.steps[_step].title,
        onPrev: _step > 0 ? () => _goto(_step - 1) : null,
        onNext: _step < widget.steps.length - 1
            ? () {
                _goto(_step + 1);
                _speakCurrent();
              }
            : null,
        onPlay: _speakCurrent,
      ),
    );
  }
}

class _SidebarPanel extends StatelessWidget {
  final String summary;
  final List<SimStep> steps;
  final int currentIndex;
  final bool autoAdvance;
  final ValueChanged<bool> onAutoAdvance;
  final ValueChanged<int> onStep;
  final VoidCallback onSpeak;
  final VoidCallback onStop;
  final List<Widget>? controls;

  const _SidebarPanel({
    required this.summary,
    required this.steps,
    required this.currentIndex,
    required this.autoAdvance,
    required this.onAutoAdvance,
    required this.onStep,
    required this.onSpeak,
    required this.onStop,
    this.controls,
  });

  @override
  Widget build(BuildContext context) {
    final cur = steps[currentIndex];
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('About this simulation',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(summary, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 14),
            if (controls != null && controls!.isNotEmpty) ...[
              Text('Controls',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 8, children: controls!),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                Text('Steps (${currentIndex + 1}/${steps.length})',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Row(children: [
                  const Text('Auto', style: TextStyle(fontSize: 12)),
                  Switch.adaptive(
                    value: autoAdvance,
                    onChanged: onAutoAdvance,
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: steps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (_, i) {
                  final isCurrent = i == currentIndex;
                  return InkWell(
                    onTap: () => onStep(i),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.primary
                              : Colors.black12,
                          width: isCurrent ? 1.3 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: isCurrent
                                ? AppColors.primary
                                : Colors.black12,
                            child: Text('${i + 1}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: isCurrent
                                        ? Colors.white
                                        : Colors.black87)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(steps[i].title,
                                style: TextStyle(
                                    fontWeight: isCurrent
                                        ? FontWeight.w700
                                        : FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cur.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(cur.narration,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: onSpeak,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Speak'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: onStop,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NarrationBar extends StatelessWidget {
  final int stepIndex;
  final int totalSteps;
  final String currentTitle;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onPlay;

  const _NarrationBar({
    required this.stepIndex,
    required this.totalSteps,
    required this.currentTitle,
    required this.onPrev,
    required this.onNext,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryDark,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(
                color: Colors.white,
                onPressed: onPrev,
                icon: const Icon(Icons.skip_previous),
              ),
              IconButton(
                color: Colors.white,
                onPressed: onPlay,
                icon: const Icon(Icons.record_voice_over),
              ),
              IconButton(
                color: Colors.white,
                onPressed: onNext,
                icon: const Icon(Icons.skip_next),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Step ${stepIndex + 1} of $totalSteps',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                    Text(currentTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

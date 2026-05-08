import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/paint_helpers.dart';
import '../widgets/sim_scaffold.dart';

/// Domestic interior cross section. The user taps fittings to learn each
/// fluid category, or flips on Quiz me mode and is tested on it.
class FluidCategoriesSimScreen extends StatefulWidget {
  const FluidCategoriesSimScreen({super.key});

  @override
  State<FluidCategoriesSimScreen> createState() =>
      _FluidCategoriesSimScreenState();
}

class _Fitting {
  final String id;
  final String name;
  final int category; // 1..5
  final String device;
  final String tip;
  // Position as fractions of canvas (cx, cy, w, h)
  final double cx;
  final double cy;
  final double w;
  final double h;
  const _Fitting({
    required this.id,
    required this.name,
    required this.category,
    required this.device,
    required this.tip,
    required this.cx,
    required this.cy,
    required this.w,
    required this.h,
  });
}

const _fittings = <_Fitting>[
  _Fitting(
    id: 'kitchen',
    name: 'Kitchen drinking tap',
    category: 1,
    device: 'No device — wholesome rising main',
    tip: 'The only Cat 1 tap in the house. Keep flexible hoses off it.',
    cx: 0.16, cy: 0.55, w: 0.10, h: 0.10,
  ),
  _Fitting(
    id: 'kitchen_hot',
    name: 'Kitchen hot tap',
    category: 2,
    device: 'Single check valve',
    tip: 'Heated wholesome water — aesthetic change only.',
    cx: 0.27, cy: 0.55, w: 0.10, h: 0.10,
  ),
  _Fitting(
    id: 'basin',
    name: 'Wash basin tap',
    category: 3,
    device: 'AUK2 air gap above the rim',
    tip: 'Slight risk — body contact via hands and toiletries.',
    cx: 0.46, cy: 0.55, w: 0.10, h: 0.10,
  ),
  _Fitting(
    id: 'bath',
    name: 'Bath tap',
    category: 3,
    device: 'AUK3 air gap above the rim',
    tip: 'Body submerged — stronger AUK3 air gap is needed.',
    cx: 0.62, cy: 0.55, w: 0.12, h: 0.10,
  ),
  _Fitting(
    id: 'wc',
    name: 'WC cistern',
    category: 5,
    device: 'AG / AUK1 air gap inside cistern',
    tip: 'Pathogens — only an air gap is acceptable.',
    cx: 0.81, cy: 0.55, w: 0.12, h: 0.18,
  ),
  _Fitting(
    id: 'washer',
    name: 'Washing machine',
    category: 3,
    device: 'Integral SCV + AUK2 standpipe',
    tip: 'Domestic detergent — Category 3 in a home.',
    cx: 0.18, cy: 0.78, w: 0.12, h: 0.14,
  ),
  _Fitting(
    id: 'dishwasher',
    name: 'Dishwasher (commercial)',
    category: 4,
    device: 'Type AB break tank or RPZ',
    tip: 'Detergent + food residue — significant risk.',
    cx: 0.34, cy: 0.78, w: 0.12, h: 0.14,
  ),
  _Fitting(
    id: 'outside',
    name: 'Outside tap',
    category: 3,
    device: 'Double check valve in line',
    tip: 'A garden hose makes this Cat 3 minimum.',
    cx: 0.55, cy: 0.82, w: 0.08, h: 0.08,
  ),
  _Fitting(
    id: 'hose_union',
    name: 'Hose union (HA)',
    category: 4,
    device: 'HA fitting with verifiable DCV',
    tip: 'Hose pressed onto a chemical sprayer — Cat 4.',
    cx: 0.68, cy: 0.82, w: 0.08, h: 0.08,
  ),
  _Fitting(
    id: 'filling_loop',
    name: 'Heating filling loop',
    category: 3,
    device: 'Filling loop with built-in DCV',
    tip: 'Inhibitor dosed water — slight risk.',
    cx: 0.84, cy: 0.82, w: 0.10, h: 0.08,
  ),
];

class _FluidCategoriesSimScreenState extends State<FluidCategoriesSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  String? _selectedId;
  bool _quizMode = false;
  int _score = 0;
  int? _quizTargetCategory;
  String? _feedback;
  int _step = 0;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _setQuizMode(bool v) {
    setState(() {
      _quizMode = v;
      _feedback = null;
      _selectedId = null;
      if (v) {
        _newQuizTarget();
      } else {
        _quizTargetCategory = null;
      }
    });
  }

  void _newQuizTarget() {
    final pick = _fittings[_rng.nextInt(_fittings.length)];
    _quizTargetCategory = pick.category;
  }

  void _resetScore() {
    setState(() {
      _score = 0;
      _feedback = null;
      if (_quizMode) _newQuizTarget();
    });
  }

  void _onTapFitting(_Fitting f) {
    if (!_quizMode) {
      setState(() {
        _selectedId = f.id;
        _feedback = null;
      });
      return;
    }
    // Quiz mode: user must tap the fitting that matches the asked category
    if (_quizTargetCategory == null) return;
    final correct = f.category == _quizTargetCategory;
    setState(() {
      _selectedId = f.id;
      if (correct) {
        _score += 10;
        _feedback = 'Correct — ${f.name} is Category ${f.category}.';
        _newQuizTarget();
      } else {
        _score = math.max(0, _score - 5);
        _feedback =
            'Not this one — ${f.name} is Category ${f.category}.';
      }
    });
  }

  String? _quizPrompt() {
    if (!_quizMode || _quizTargetCategory == null) return null;
    return 'Tap any fitting that is Category $_quizTargetCategory.';
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedId == null
        ? null
        : _fittings.firstWhere((f) => f.id == _selectedId);

    return SimScaffold(
      title: 'Fluid categories',
      summary:
          'Walk through a domestic interior and tap each fitting to reveal its '
          'fluid category and required device. Switch on Quiz me to be tested.',
      onStepChanged: (i) => setState(() => _step = i),
      steps: const [
        SimStep(
          title: 'Walk through',
          narration:
              'Every domestic fitting falls into Category 1 to 5. Tap each one '
              'to see how it is classified and what protection it needs.',
        ),
        SimStep(
          title: 'Wholesome (Cat 1)',
          narration:
              'The kitchen drinking tap is Cat 1 — wholesome water from the '
              'rising main, with no further treatment.',
        ),
        SimStep(
          title: 'Cat 2 — temperature change',
          narration:
              'The kitchen hot tap is Cat 2 — wholesome water that has only '
              'been heated. A single check valve is enough.',
        ),
        SimStep(
          title: 'Cat 3 — slight risk',
          narration:
              'Wash basins, baths and the heating filling loop are Cat 3. '
              'Use AUK2 / AUK3 air gaps and double check valves.',
        ),
        SimStep(
          title: 'Cat 4 — significant risk',
          narration:
              'Commercial dishwashers and hose union taps with sprayers are '
              'Cat 4. RPZ or Type AB break tank.',
        ),
        SimStep(
          title: 'Cat 5 — serious risk',
          narration:
              'WC pans and agricultural / irrigation outlets are Cat 5. Only '
              'a physical air gap is acceptable.',
        ),
        SimStep(
          title: 'Quiz me',
          narration:
              'Flip on Quiz me. The panel asks for a fluid category and you '
              'tap any fitting that matches. Wrong answers deduct points.',
        ),
        SimStep(
          title: 'Field tips',
          narration:
              'When in doubt, escalate — a Cat 4 RPZ provides verifiable '
              'protection where a non testable DCV cannot be relied on.',
        ),
      ],
      controls: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Quiz me', style: TextStyle(fontSize: 12)),
          Switch.adaptive(
            value: _quizMode,
            onChanged: _setQuizMode,
          ),
        ]),
        OutlinedButton.icon(
          onPressed: _resetScore,
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset score'),
        ),
      ],
      diagramBuilder: (context, _) {
        return LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => CustomPaint(
                    painter: _InteriorPainter(
                      progress: _ctrl.value,
                      selectedId: _selectedId,
                      quizMode: _quizMode,
                      quizTargetCategory: _quizTargetCategory,
                    ),
                  ),
                ),
              ),
              // Tap hot spots
              for (final f in _fittings)
                Positioned(
                  left: (f.cx - f.w / 2) * w,
                  top: (f.cy - f.h / 2) * h,
                  width: f.w * w,
                  height: f.h * h,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onTapFitting(f),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedId == f.id
                                ? AppColors.accent
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
              // Score badge
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
              ),
              // Banner
              Positioned(
                left: 10,
                right: 90,
                top: 10,
                child: _Banner(
                  selected: selected,
                  quizPrompt: _quizPrompt(),
                  feedback: _feedback,
                  step: _step,
                ),
              ),
            ],
          );
        });
      },
    );
  }
}

class _Banner extends StatelessWidget {
  final _Fitting? selected;
  final String? quizPrompt;
  final String? feedback;
  final int step;
  const _Banner({
    required this.selected,
    required this.quizPrompt,
    required this.feedback,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String body;
    Color background;
    if (quizPrompt != null) {
      title = 'Quiz';
      body = feedback != null ? '$feedback\n\n$quizPrompt' : quizPrompt!;
      background = feedback != null && feedback!.startsWith('Correct')
          ? Colors.green.shade100
          : (feedback != null ? Colors.orange.shade100 : AppColors.cardBg);
    } else if (selected != null) {
      title = '${selected!.name} — Category ${selected!.category}';
      body = '${selected!.device}\n${selected!.tip}';
      background = _categoryColour(selected!.category);
    } else {
      title = 'Tap any fitting';
      body =
          'Tap a tap, basin, bath, WC, washer, dishwasher, outside tap or filling loop to see its fluid category.';
      background = AppColors.cardBg;
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Color _categoryColour(int c) {
    switch (c) {
      case 1:
        return Colors.green.shade100;
      case 2:
        return Colors.lightGreen.shade100;
      case 3:
        return Colors.yellow.shade100;
      case 4:
        return Colors.orange.shade100;
      case 5:
        return Colors.red.shade100;
      default:
        return AppColors.cardBg;
    }
  }
}

class _InteriorPainter extends CustomPainter {
  final double progress;
  final String? selectedId;
  final bool quizMode;
  final int? quizTargetCategory;
  _InteriorPainter({
    required this.progress,
    required this.selectedId,
    required this.quizMode,
    required this.quizTargetCategory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Walls / interior shading
    canvas.drawRect(Offset.zero & size,
        Paint()..color = const Color(0xFFF5EBD8));
    // floor
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.92, size.width, size.height * 0.08),
      Paint()..color = const Color(0xFF8C7A5E),
    );
    // skirting
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.9, size.width, 4),
      Paint()..color = const Color(0xFF6B5B43),
    );
    // Room divider line
    final divider = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.9),
      divider,
    );
    canvas.drawLine(
      Offset(size.width * 0.74, size.height * 0.4),
      Offset(size.width * 0.74, size.height * 0.9),
      divider,
    );
    // Room labels
    PipePainterHelpers.drawLabel(
        canvas, Offset(size.width * 0.05, size.height * 0.36), 'KITCHEN',
        fontSize: 10, background: Colors.white);
    PipePainterHelpers.drawLabel(
        canvas, Offset(size.width * 0.45, size.height * 0.36), 'BATHROOM',
        fontSize: 10, background: Colors.white);
    PipePainterHelpers.drawLabel(
        canvas, Offset(size.width * 0.78, size.height * 0.36), 'WC',
        fontSize: 10, background: Colors.white);

    // Rising main running across the top
    final mainY = size.height * 0.18;
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(size.width * 0.02, mainY),
      b: Offset(size.width * 0.98, mainY),
      color: AppColors.coldWater,
      width: 8,
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(size.width * 0.02, mainY - 22),
        'Rising main (Cat 1)',
        fontSize: 10);

    // Flow particles on the main
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: Offset(size.width * 0.02, mainY),
      b: Offset(size.width * 0.98, mainY),
      progress: progress,
      color: Colors.white,
      count: 8,
      radius: 2.4,
    );

    // Draw each fitting with a category coloured ring; highlight selected
    for (final f in _fittings) {
      final c = Offset(f.cx * size.width, f.cy * size.height);
      final w = f.w * size.width;
      final h = f.h * size.height;
      final isSel = selectedId == f.id;
      final isQuizTarget = quizMode &&
          quizTargetCategory != null &&
          f.category == quizTargetCategory;
      _drawFittingGlyph(canvas, f, c, w, h, isSel, isQuizTarget);

      // Drop pipe from the rising main down to the fitting
      final dropTop = Offset(c.dx, mainY);
      final dropBottom = Offset(c.dx, c.dy - h * 0.35);
      PipePainterHelpers.drawPipe(
        canvas,
        a: dropTop,
        b: dropBottom,
        color: isSel
            ? AppColors.coldWater
            : AppColors.coldWater.withValues(alpha: 0.45),
        width: 5,
      );

      // Category badge
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(c.dx - 24, c.dy + h * 0.5 + 6),
        'Cat ${f.category}',
        fontSize: 10,
        background: _categoryColour(f.category),
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(c.dx - (f.name.length * 3.2), c.dy - h * 0.5 - 18),
        f.name,
        fontSize: 9,
        background: Colors.white,
      );
    }
  }

  Color _categoryColour(int c) {
    switch (c) {
      case 1:
        return Colors.green.shade100;
      case 2:
        return Colors.lightGreen.shade100;
      case 3:
        return Colors.yellow.shade100;
      case 4:
        return Colors.orange.shade100;
      case 5:
        return Colors.red.shade100;
      default:
        return Colors.white;
    }
  }

  void _drawFittingGlyph(Canvas canvas, _Fitting f, Offset c,
      double w, double h, bool selected, bool isQuizTarget) {
    final body = Paint()..color = AppColors.pipeMetal;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rect = Rect.fromCenter(center: c, width: w * 0.85, height: h * 0.85);

    // Subtle highlight ring on selection
    if (selected) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(4), const Radius.circular(8)),
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    switch (f.id) {
      case 'kitchen':
      case 'kitchen_hot':
        // Tap on a sink
        final sink = Rect.fromLTWH(rect.left, c.dy, rect.width, rect.height * 0.4);
        canvas.drawRRect(
            RRect.fromRectAndRadius(sink, const Radius.circular(4)),
            Paint()..color = Colors.white);
        canvas.drawRRect(
            RRect.fromRectAndRadius(sink, const Radius.circular(4)), stroke);
        // tap
        canvas.drawLine(Offset(c.dx, c.dy - h * 0.3), Offset(c.dx, c.dy),
            Paint()..color = AppColors.copper..strokeWidth = 4);
        canvas.drawCircle(Offset(c.dx, c.dy - h * 0.3), 4,
            Paint()..color = AppColors.copper);
        break;
      case 'basin':
        final basin = Rect.fromLTWH(rect.left, c.dy, rect.width, rect.height * 0.5);
        canvas.drawArc(basin, 0, math.pi, false,
            Paint()..color = Colors.white..style = PaintingStyle.fill);
        canvas.drawArc(basin, 0, math.pi, false, stroke);
        canvas.drawLine(Offset(c.dx, c.dy - h * 0.3), Offset(c.dx, c.dy),
            Paint()..color = AppColors.copper..strokeWidth = 4);
        break;
      case 'bath':
        final tub = Rect.fromLTWH(rect.left, c.dy - rect.height * 0.1,
            rect.width, rect.height * 0.6);
        canvas.drawRRect(
            RRect.fromRectAndRadius(tub, const Radius.circular(8)),
            Paint()..color = Colors.white);
        canvas.drawRRect(
            RRect.fromRectAndRadius(tub, const Radius.circular(8)), stroke);
        canvas.drawRect(
            Rect.fromLTWH(tub.left + 4, tub.top + 4, tub.width - 8, 6),
            Paint()..color = AppColors.coldWater.withValues(alpha: 0.5));
        canvas.drawLine(Offset(c.dx, c.dy - h * 0.4), Offset(c.dx, tub.top),
            Paint()..color = AppColors.copper..strokeWidth = 4);
        break;
      case 'wc':
        final cistern = Rect.fromLTWH(
            c.dx - w * 0.32, c.dy - h * 0.35, w * 0.6, h * 0.36);
        canvas.drawRRect(
            RRect.fromRectAndRadius(cistern, const Radius.circular(3)),
            Paint()..color = Colors.white);
        canvas.drawRRect(
            RRect.fromRectAndRadius(cistern, const Radius.circular(3)), stroke);
        // water inside cistern
        canvas.drawRect(
            Rect.fromLTWH(cistern.left + 2,
                cistern.top + cistern.height * 0.45,
                cistern.width - 4,
                cistern.height * 0.5),
            Paint()..color = AppColors.coldWater.withValues(alpha: 0.5));
        // bowl
        final bowl = Rect.fromLTWH(
            c.dx - w * 0.28, c.dy + h * 0.05, w * 0.55, h * 0.3);
        canvas.drawArc(bowl, 0, math.pi, false,
            Paint()..color = Colors.white..style = PaintingStyle.fill);
        canvas.drawArc(bowl, 0, math.pi, false, stroke);
        break;
      case 'washer':
      case 'dishwasher':
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)), body);
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)), stroke);
        canvas.drawCircle(Offset(c.dx, c.dy + h * 0.05), w * 0.25,
            Paint()..color = Colors.white);
        canvas.drawCircle(
            Offset(c.dx, c.dy + h * 0.05), w * 0.25, stroke);
        if (f.id == 'dishwasher') {
          PipePainterHelpers.drawLabel(
              canvas, Offset(rect.left + 2, rect.top + 2), 'COMM',
              fontSize: 8, background: Colors.orange.shade100);
        }
        break;
      case 'outside':
      case 'hose_union':
        // Wall tap
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)),
            Paint()..color = AppColors.brass);
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)), stroke);
        // hose nozzle
        canvas.drawCircle(
            Offset(c.dx, c.dy + h * 0.45), 3,
            Paint()..color = AppColors.copper);
        canvas.drawLine(
          Offset(c.dx, c.dy + h * 0.4),
          Offset(c.dx, c.dy + h * 0.55),
          Paint()..color = AppColors.copper..strokeWidth = 3,
        );
        break;
      case 'filling_loop':
        // Filling loop: small horizontal flexi between two pipes
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)), body);
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)), stroke);
        // flexi
        final fl = Paint()
          ..color = AppColors.brass
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
            Offset(rect.left + 4, c.dy), Offset(rect.right - 4, c.dy), fl);
        PipePainterHelpers.drawLabel(
            canvas, Offset(rect.left + 2, rect.top + 2), 'FILL',
            fontSize: 8, background: Colors.white);
        break;
    }

    // Quiz mode hint: pulse a soft ring on every valid target so the user
    // has a visual cue beyond the prompt
    if (isQuizTarget) {
      final pulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(6), const Radius.circular(10)),
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.18 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InteriorPainter old) =>
      old.progress != progress ||
      old.selectedId != selectedId ||
      old.quizMode != quizMode ||
      old.quizTargetCategory != quizTargetCategory;
}

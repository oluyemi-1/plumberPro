import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum WcBlockSeverity { light, medium, severe }

class BlockedWcSimScreen extends StatefulWidget {
  const BlockedWcSimScreen({super.key});
  @override
  State<BlockedWcSimScreen> createState() => _BlockedWcSimScreenState();
}

class _BlockedWcSimScreenState extends State<BlockedWcSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  // ignore: unused_field
  int _step = 0;

  WcBlockSeverity _severity = WcBlockSeverity.medium;

  // Action counters / flags.
  int _plungeCount = 0;
  bool _plungeAnimating = false;
  double _plungePhase = 0.0;

  bool _augerUsed = false;
  bool _bucketPour = false;
  bool _panLifted = false;

  // Pan water level: 0 = empty bowl, 1 = overflowing.
  double _panLevel = 0.55;

  // Swirl phase used for the post-clear flush animation.
  double _swirl = 0.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _ctrl.addListener(_tick);
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      if (_plungeAnimating) {
        _plungePhase += 0.12;
        if (_plungePhase >= math.pi * 2 * 4) {
          _plungePhase = 0.0;
          _plungeAnimating = false;
        }
      }
      // Pan level slowly recedes when block is reduced.
      final cleared = _isCleared();
      double drain = 0.0;
      if (cleared) {
        drain = 0.014;
        _swirl += 0.18;
      } else {
        drain = _panLevel > 0.55 ? 0.003 : 0.0;
      }
      _panLevel = (_panLevel - drain).clamp(0.0, 1.0);
    });
  }

  /// How much "clearing pressure" each action provides.
  int get _appliedScore {
    int s = 0;
    s += _plungeCount; // each plunge cycle = 1
    if (_augerUsed) s += 3;
    if (_bucketPour) s += 1;
    if (_panLifted) s += 5;
    return s;
  }

  int get _requiredScore {
    switch (_severity) {
      case WcBlockSeverity.light:
        return 2;
      case WcBlockSeverity.medium:
        return 4;
      case WcBlockSeverity.severe:
        return 7;
    }
  }

  bool _isCleared() => _appliedScore >= _requiredScore;

  void _plunge() {
    setState(() {
      _plungeCount += 1;
      _plungeAnimating = true;
      _plungePhase = 0.0;
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_tick);
    _ctrl.dispose();
    super.dispose();
  }

  static const List<SimStep> _steps = [
    SimStep(
      title: 'Symptom',
      narration:
          'On flush the pan fills, sometimes to the brim, and drains very '
          'slowly or not at all. Watch the level — a true overflow risk '
          'means you stop flushing immediately.',
    ),
    SimStep(
      title: 'Stop flushing',
      narration:
          'Do not flush again. Each repeat flush adds 6 litres into a pan '
          'that already cannot empty. Let the level settle before any '
          'physical action.',
    ),
    SimStep(
      title: 'Identify the cause',
      narration:
          'Most blockages are paper, wet wipes or a foreign object such as '
          'a bottle top. A camera or a careful gloved feel into the trap '
          'tells you which it is.',
    ),
    SimStep(
      title: 'WC plunger choice',
      narration:
          'Use a flange plunger, not a sink cup. The flange folds out to '
          'seal the curved pan outlet. A sink plunger simply slips and '
          'cannot generate the pressure pulse needed.',
    ),
    SimStep(
      title: 'Plunge technique',
      narration:
          'Press the flange into the outlet, push down to expel air, then '
          'pull and push six to ten times. The work is done on the up-stroke '
          'as much as the down-stroke.',
    ),
    SimStep(
      title: 'Auger or drain snake',
      narration:
          'A WC closet auger has a sleeve that protects the porcelain and a '
          'cranked handle that drives a flexible cable around the trap. Use '
          'it for solid obstructions the plunger cannot move.',
    ),
    SimStep(
      title: 'Bucket of water from height',
      narration:
          'For partial paper blockages, a half-bucket of water tipped from '
          'about a metre will sometimes shift the slug where a 6 litre '
          'flush cannot.',
    ),
    SimStep(
      title: 'Lift the pan',
      narration:
          'Last resort: isolate, drain, unscrew the floor fixings and '
          'rock the pan free of the soil pan connector. You will need a '
          'new connector and silicone bedding on refit.',
    ),
    SimStep(
      title: 'Sanitise',
      narration:
          'After clearing, clean every splashed surface with a chlorine-'
          'based cleaner. Wipe tools, dispose of cloths, and wash hands '
          'thoroughly.',
    ),
    SimStep(
      title: 'Customer prevention advice',
      narration:
          'No wet wipes — even ones marked "flushable" do not break down '
          'fast enough. No sanitary products, no kitchen roll. Educate the '
          'customer; it prevents the next call-out.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Blocked WC — clearing technique',
      summary:
          'Identify a blocked toilet, choose the right plunger, work through '
          'plunging, augering and a height-pour, then escalate to lifting '
          'the pan. Severity determines how much effort is needed.',
      steps: _steps,
      onStepChanged: (i) => setState(() => _step = i),
      controls: [
        Wrap(
          spacing: 6,
          children: [
            for (final s in WcBlockSeverity.values)
              ChoiceChip(
                label: Text(_severityLabel(s)),
                selected: _severity == s,
                onSelected: (_) => setState(() {
                  _severity = s;
                  _plungeCount = 0;
                  _augerUsed = false;
                  _bucketPour = false;
                  _panLifted = false;
                  _panLevel = s == WcBlockSeverity.severe ? 0.85 : 0.6;
                }),
              ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _plunge,
          icon: const Icon(Icons.compress),
          label: const Text('Plunge'),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _augerUsed = true),
          icon: const Icon(Icons.cable),
          label: const Text('Use auger'),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _bucketPour = true;
            _panLevel = (_panLevel + 0.1).clamp(0.0, 1.0);
          }),
          icon: const Icon(Icons.water),
          label: const Text('Bucket pour'),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _panLifted = true),
          icon: const Icon(Icons.construction),
          label: const Text('Lift pan'),
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _WcPainter(
            step: i,
            t: _ctrl.value,
            panLevel: _panLevel,
            severity: _severity,
            plungeAnim: _plungeAnimating ? math.sin(_plungePhase) : 0.0,
            augerUsed: _augerUsed,
            cleared: _isCleared(),
            swirl: _swirl,
            score: _appliedScore,
            required: _requiredScore,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  String _severityLabel(WcBlockSeverity s) {
    switch (s) {
      case WcBlockSeverity.light:
        return 'Light';
      case WcBlockSeverity.medium:
        return 'Medium';
      case WcBlockSeverity.severe:
        return 'Severe';
    }
  }
}

class _WcPainter extends CustomPainter {
  final int step;
  final double t;
  final double panLevel;
  final WcBlockSeverity severity;
  final double plungeAnim;
  final bool augerUsed;
  final bool cleared;
  final double swirl;
  final int score;
  final int required;

  _WcPainter({
    required this.step,
    required this.t,
    required this.panLevel,
    required this.severity,
    required this.plungeAnim,
    required this.augerUsed,
    required this.cleared,
    required this.swirl,
    required this.score,
    required this.required,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.cardBg,
    );

    // Cistern (top).
    final cisternRect = Rect.fromLTWH(w * 0.18, h * 0.06, w * 0.32, h * 0.20);
    PipePainterHelpers.drawTank(
      canvas,
      rect: cisternRect,
      level: 0.85,
      waterColor: AppColors.coldWater,
      open: false,
      label: 'Cistern (6 L flush)',
    );
    // Flush handle.
    final handleRect = Rect.fromLTWH(
        cisternRect.right - 18, cisternRect.top + 24, 16, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, const Radius.circular(2)),
      Paint()..color = AppColors.brass,
    );

    // Pan body — side cross-section.
    final panLeft = w * 0.18;
    final panTop = h * 0.34;
    final panBowlRect = Rect.fromLTWH(panLeft, panTop, w * 0.32, h * 0.30);

    _drawPan(canvas, panBowlRect);

    // Trap weir.
    _drawTrap(canvas, panBowlRect);

    // Water in bowl.
    _drawBowlWater(canvas, panBowlRect);

    // Blockage in trap (paper / wipes) — fades as cleared.
    if (!cleared) {
      _drawBlockage(canvas, panBowlRect);
    }

    // Pan outlet to soil pipe, then soil stack.
    final outletStart = Offset(panBowlRect.right - 6, panBowlRect.bottom - 24);
    final outletEnd = Offset(w * 0.78, panBowlRect.bottom - 24);
    PipePainterHelpers.drawPipe(
      canvas,
      a: outletStart,
      b: outletEnd,
      color: AppColors.waste,
      width: 18,
    );
    // Soil stack.
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(outletEnd.dx, h * 0.06),
      b: Offset(outletEnd.dx, h * 0.94),
      color: AppColors.waste,
      width: 24,
    );
    PipePainterHelpers.drawJoint(canvas, outletEnd);

    // Plunger glyph during plunging.
    if (plungeAnim != 0.0 || score > 0) {
      final dy = plungeAnim * 16;
      _drawWcPlunger(canvas, Offset(panBowlRect.center.dx, panBowlRect.top - 60 + dy));
    }

    // Auger glyph if used.
    if (augerUsed && !cleared) {
      _drawAuger(canvas, panBowlRect);
    }

    // Swirl drain effect when cleared.
    if (cleared) {
      _drawSwirl(canvas, panBowlRect);
    }

    // Severity badge.
    _drawSeverityBadge(canvas, w, h);

    // Labels.
    PipePainterHelpers.drawLabel(canvas,
        Offset(cisternRect.left, cisternRect.top - 18), 'Cistern');
    PipePainterHelpers.drawLabel(canvas,
        Offset(panBowlRect.left, panBowlRect.top + 4), 'WC pan (cross-section)');
    PipePainterHelpers.drawLabel(
        canvas, Offset(panBowlRect.left + 30, panBowlRect.bottom + 4),
        'Trap weir');
    PipePainterHelpers.drawLabel(canvas,
        Offset(outletStart.dx - 30, outletStart.dy - 22), 'Pan outlet');
    PipePainterHelpers.drawLabel(
        canvas, Offset(outletEnd.dx + 14, h * 0.10), '110 mm soil stack');
    PipePainterHelpers.drawLabel(
        canvas, Offset(handleRect.left - 30, handleRect.top - 18), 'Flush handle');
    PipePainterHelpers.drawLabel(
        canvas, Offset(panBowlRect.left + 4, panBowlRect.bottom + 22),
        'Pan connector');
  }

  void _drawPan(Canvas c, Rect r) {
    final body = Paint()..color = const Color(0xFFF1F4F7);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final path = Path()
      ..moveTo(r.left, r.top)
      ..quadraticBezierTo(r.left, r.bottom, r.left + r.width * 0.55, r.bottom)
      ..lineTo(r.right - 4, r.bottom - 22)
      ..lineTo(r.right - 4, r.top + 8)
      ..lineTo(r.right - 14, r.top)
      ..close();
    c.drawPath(path, body);
    c.drawPath(path, stroke);
    // Rim.
    c.drawLine(
      Offset(r.left - 4, r.top),
      Offset(r.right + 4, r.top),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 3,
    );
  }

  void _drawTrap(Canvas c, Rect r) {
    // Internal "weir" curve drawn as an arc inside the bowl.
    final path = Path()
      ..moveTo(r.left + r.width * 0.55, r.bottom)
      ..cubicTo(
        r.left + r.width * 0.4, r.bottom - 30,
        r.left + r.width * 0.7, r.bottom - 50,
        r.right - 4, r.bottom - 22,
      );
    c.drawPath(
      path,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  void _drawBowlWater(Canvas c, Rect r) {
    final innerTop = r.top + (1.0 - panLevel) * (r.height - 8);
    final water = Path()
      ..moveTo(r.left + 3, innerTop)
      ..quadraticBezierTo(r.left + 3, r.bottom - 2,
          r.left + r.width * 0.55, r.bottom - 2)
      ..lineTo(r.right - 6, r.bottom - 22)
      ..lineTo(r.right - 6, innerTop)
      ..close();
    c.drawPath(
      water,
      Paint()..color = AppColors.coldWater.withValues(alpha: 0.55),
    );
    // Surface ripple.
    c.drawLine(
      Offset(r.left + 3, innerTop),
      Offset(r.right - 6, innerTop),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 1.4,
    );
  }

  void _drawBlockage(Canvas c, Rect r) {
    // Paper/wipes wadded at the trap weir.
    final cx = r.left + r.width * 0.62;
    final cy = r.bottom - 18;
    final size = severity == WcBlockSeverity.severe
        ? 14.0
        : severity == WcBlockSeverity.medium
            ? 10.0
            : 7.0;
    final reduced = (1.0 - (score / required).clamp(0.0, 1.0));
    final s = size * reduced;
    if (s < 1) return;
    final paint = Paint()..color = const Color(0xFFCFB78A);
    c.drawCircle(Offset(cx, cy), s, paint);
    c.drawCircle(Offset(cx + 6, cy - 4), s * 0.7, paint);
    c.drawCircle(Offset(cx - 6, cy - 2), s * 0.6, paint);
    // Stroke
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    c.drawCircle(Offset(cx, cy), s, stroke);
  }

  void _drawWcPlunger(Canvas c, Offset tip) {
    // Flange plunger — bell with a flange protruding from base.
    final cup = Paint()..color = AppColors.accent;
    final stroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    // Bell.
    final bellRect = Rect.fromCenter(center: tip, width: 32, height: 30);
    c.drawArc(bellRect, math.pi, math.pi, true, cup);
    c.drawArc(bellRect, math.pi, math.pi, true, stroke);
    // Flange.
    final flangeRect =
        Rect.fromCenter(center: tip.translate(0, 14), width: 22, height: 12);
    c.drawArc(flangeRect, math.pi, math.pi, true, cup);
    c.drawArc(flangeRect, math.pi, math.pi, true, stroke);
    // Stick.
    final stick = Rect.fromLTWH(tip.dx - 3, tip.dy - 80, 6, 60);
    c.drawRRect(RRect.fromRectAndRadius(stick, const Radius.circular(2)),
        Paint()..color = const Color(0xFF5D4037));
  }

  void _drawAuger(Canvas c, Rect r) {
    // Cranked handle off the right of the bowl + cable spiral into trap.
    final handleStart = Offset(r.right + 10, r.top - 10);
    final handleEnd = Offset(r.right + 30, r.top - 30);
    final paint = Paint()
      ..color = AppColors.brass
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    c.drawLine(handleStart, handleEnd, paint);
    c.drawLine(handleEnd, Offset(handleEnd.dx + 18, handleEnd.dy + 6), paint);
    // Sleeve into the bowl.
    c.drawLine(
      handleStart,
      Offset(r.left + r.width * 0.5, r.bottom - 14),
      Paint()
        ..color = AppColors.pipeMetal
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    // Spring-tip glyph.
    final tip = Offset(r.left + r.width * 0.5, r.bottom - 14);
    for (int i = 0; i < 6; i++) {
      c.drawCircle(
        Offset(tip.dx + math.cos(i * 1.0 + t * 6) * 3,
            tip.dy + i * 2.0),
        2.2,
        Paint()..color = AppColors.pipeMetal,
      );
    }
  }

  void _drawSwirl(Canvas c, Rect r) {
    final cx = r.left + r.width * 0.6;
    final cy = r.bottom - 16;
    final paint = Paint()
      ..color = AppColors.coldWater.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      final radius = 4.0 + i * 4 + (swirl * 2 % 6);
      c.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        swirl + i,
        math.pi * 1.5,
        false,
        paint,
      );
    }
  }

  void _drawSeverityBadge(Canvas c, double w, double h) {
    final colour = severity == WcBlockSeverity.severe
        ? AppColors.accent
        : severity == WcBlockSeverity.medium
            ? AppColors.gas
            : Colors.green;
    final label =
        'Severity: ${severity.name}   $score / $required';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = Rect.fromLTWH(w - tp.width - 28, 12, tp.width + 16, 24);
    c.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = colour.withValues(alpha: 0.92),
    );
    tp.paint(c, Offset(rect.left + 8, rect.top + 4));
  }

  @override
  bool shouldRepaint(_WcPainter o) => true;
}

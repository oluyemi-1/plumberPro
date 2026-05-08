import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class BlockedSinkSimScreen extends StatefulWidget {
  const BlockedSinkSimScreen({super.key});
  @override
  State<BlockedSinkSimScreen> createState() => _BlockedSinkSimScreenState();
}

class _BlockedSinkSimScreenState extends State<BlockedSinkSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  // ignore: unused_field
  int _step = 0;

  // Fix-state flags.
  bool _hotSoap = false;
  bool _overflowBlocked = false;
  bool _plunging = false;
  bool _trapUnscrewed = false;
  bool _trapEmptied = false;
  bool _trapRefitted = false;
  bool _flushTested = false;

  // Plunger animation (independent of main controller).
  double _plungerPhase = 0.0;

  // Basin water level: 1 = full, 0 = empty.
  double _basinLevel = 0.85;

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
      // Plunger sinusoidal motion when active.
      if (_plunging) {
        _plungerPhase += 0.08;
      }

      // Basin drainage rate depends on how cleared the system is.
      double drainRate = 0.0;
      final cleared = _isCleared();
      if (cleared) {
        drainRate = 0.010; // healthy drain
      } else if (_isPartiallyCleared()) {
        drainRate = 0.0035;
      } else {
        // Total block; very tiny seepage.
        drainRate = 0.0006;
      }

      // Plunger with overflow blocked actually shifts water into trap quickly.
      if (_plunging && _overflowBlocked) {
        drainRate += 0.004;
      }

      _basinLevel = (_basinLevel - drainRate).clamp(0.0, 1.0);
    });
  }

  bool _isPartiallyCleared() {
    return _hotSoap || (_plunging && _overflowBlocked) || _trapUnscrewed;
  }

  bool _isCleared() {
    return _trapEmptied && _trapRefitted;
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
          'The basin drains slowly, or not at all. Greyish water sits above '
          'the strainer. Confirm there is no overflow flooding before you '
          'start work.',
    ),
    SimStep(
      title: 'First check',
      narration:
          'Look at the strainer and the overflow rim. Hair, food and soap '
          'scum collect just below the plug. Often a quick lift of the '
          'strainer and a probe with gloves clears the symptom.',
    ),
    SimStep(
      title: 'Hot water and washing-up liquid',
      narration:
          'Run a kettle of hot, not boiling, water with a squirt of detergent. '
          'It softens grease that has set on the trap walls. Wait two minutes '
          'and check whether drainage improves.',
    ),
    SimStep(
      title: 'Plunger technique',
      narration:
          'Cover the strainer with a cup plunger and seal the overflow with '
          'a wet cloth first. Without that seal the air just bypasses through '
          'the overflow and the plunger does no useful work.',
    ),
    SimStep(
      title: 'Disconnect the trap',
      narration:
          'Place a bucket under the U-bend. Hand-tighten only — these are '
          'plastic compression nuts and a spanner will crack them. Loosen '
          'both nuts so the trap drops cleanly into the bucket.',
    ),
    SimStep(
      title: 'Inspect and clean the trap',
      narration:
          'A standard sink trap holds a 75 millimetre water seal. Clear out '
          'any debris, rinse the trap, and check the rubber washers are '
          'present and seated the correct way round.',
    ),
    SimStep(
      title: 'Drain rod the branch',
      narration:
          'If the trap was clean, the blockage is downstream. Feed a 9 mm '
          'flexible rod into the branch towards the soil stack and rotate '
          'clockwise so the joints do not unscrew.',
    ),
    SimStep(
      title: 'Refit and seal check',
      narration:
          'Refit the trap, run the tap for thirty seconds, and watch every '
          'compression nut for weeping. A small drip now becomes a cupboard '
          'full of swollen chipboard in a fortnight.',
    ),
    SimStep(
      title: 'Caustic unblocker',
      narration:
          'Only use caustic chemical unblockers as a last resort, with '
          'goggles and gloves. Never use them after a plunger — splash-back '
          'is severe. Flush thoroughly afterwards.',
    ),
    SimStep(
      title: 'Customer advice',
      narration:
          'Leave a strainer fitted at all times, never tip cooking fat down '
          'the sink, and run hot water for ten seconds after each washing-up '
          'session to keep the trap sweet.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Blocked sink — diagnose and clear',
      summary:
          'Work systematically through a partial sink blockage: visual check, '
          'hot soapy water, plunger with overflow sealed, trap strip, and '
          'drain rodding. Track each fix with the on-diagram checklist.',
      steps: _steps,
      onStepChanged: (i) => setState(() => _step = i),
      controls: [
        ElevatedButton.icon(
          onPressed: () => setState(() => _hotSoap = true),
          icon: const Icon(Icons.local_fire_department),
          label: const Text('Run hot water + soap'),
        ),
        ElevatedButton.icon(
          onPressed: () => setState(() => _plunging = !_plunging),
          icon: const Icon(Icons.south),
          label: Text(_plunging ? 'Stop plunger' : 'Plunger'),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Block overflow', style: TextStyle(fontSize: 12)),
            Switch.adaptive(
              value: _overflowBlocked,
              onChanged: (v) => setState(() => _overflowBlocked = v),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _trapUnscrewed = true),
          icon: const Icon(Icons.build),
          label: const Text('Unscrew trap'),
        ),
        OutlinedButton.icon(
          onPressed: _trapUnscrewed
              ? () => setState(() => _trapEmptied = true)
              : null,
          icon: const Icon(Icons.delete_sweep),
          label: const Text('Empty trap'),
        ),
        OutlinedButton.icon(
          onPressed: _trapEmptied
              ? () => setState(() => _trapRefitted = true)
              : null,
          icon: const Icon(Icons.settings_backup_restore),
          label: const Text('Refit trap'),
        ),
        ElevatedButton.icon(
          onPressed: () => setState(() {
            _flushTested = true;
            _basinLevel = 0.85;
          }),
          icon: const Icon(Icons.water_drop),
          label: const Text('Test flush'),
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _SinkPainter(
            step: i,
            t: _ctrl.value,
            basinLevel: _basinLevel,
            plunging: _plunging,
            plungerPhase: _plungerPhase,
            overflowBlocked: _overflowBlocked,
            hotSoap: _hotSoap,
            trapUnscrewed: _trapUnscrewed,
            trapEmptied: _trapEmptied,
            trapRefitted: _trapRefitted,
            flushTested: _flushTested,
            cleared: _isCleared(),
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SinkPainter extends CustomPainter {
  final int step;
  final double t;
  final double basinLevel;
  final bool plunging;
  final double plungerPhase;
  final bool overflowBlocked;
  final bool hotSoap;
  final bool trapUnscrewed;
  final bool trapEmptied;
  final bool trapRefitted;
  final bool flushTested;
  final bool cleared;

  _SinkPainter({
    required this.step,
    required this.t,
    required this.basinLevel,
    required this.plunging,
    required this.plungerPhase,
    required this.overflowBlocked,
    required this.hotSoap,
    required this.trapUnscrewed,
    required this.trapEmptied,
    required this.trapRefitted,
    required this.flushTested,
    required this.cleared,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.cardBg,
    );

    // Geometry.
    final basinRect = Rect.fromLTWH(w * 0.12, h * 0.20, w * 0.45, h * 0.22);
    final tapBaseX = basinRect.center.dx;
    final tapBaseY = basinRect.top - 6;

    _drawTap(canvas, Offset(tapBaseX, tapBaseY));
    _drawBasin(canvas, basinRect);
    _drawWaterInBasin(canvas, basinRect);
    _drawStrainer(canvas, basinRect);
    _drawOverflow(canvas, basinRect);

    // Trap below basin.
    final strainerX = basinRect.center.dx;
    final strainerY = basinRect.bottom;
    final trapTopY = strainerY + h * 0.04;
    final trapBottomY = strainerY + h * 0.20;

    if (!trapUnscrewed || trapRefitted) {
      _drawUBend(canvas, strainerX, strainerY, trapTopY, trapBottomY);
    } else {
      // Trap dropped — show two open stubs.
      _drawOpenStubs(canvas, strainerX, strainerY, trapTopY);
      _drawDroppedTrap(canvas, strainerX, trapBottomY + 30);
    }

    // Branch into stack.
    final branchStart = Offset(strainerX + 36, trapTopY + 18);
    final branchEnd = Offset(w * 0.85, trapTopY + 18);
    PipePainterHelpers.drawPipe(
      canvas,
      a: branchStart,
      b: branchEnd,
      color: AppColors.waste,
      width: 14,
    );

    // Soil stack.
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(branchEnd.dx, h * 0.05),
      b: Offset(branchEnd.dx, h * 0.95),
      color: AppColors.waste,
      width: 22,
    );
    PipePainterHelpers.drawJoint(canvas, branchEnd);

    // Bucket if trap is being worked on.
    if (trapUnscrewed) {
      _drawBucket(canvas, Offset(strainerX, trapBottomY + 60));
    }

    // Plunger glyph above strainer when active.
    if (plunging) {
      final dy = math.sin(plungerPhase) * 12;
      _drawPlunger(canvas, Offset(strainerX, basinRect.top - 30 + dy));
    }

    // Hot soap shimmer indicator.
    if (hotSoap && step >= 2) {
      _drawSteam(canvas, basinRect);
    }

    // Flow particles in branch when cleared & flushed.
    if ((cleared || flushTested) && !trapUnscrewed) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: branchStart,
        b: branchEnd,
        progress: t,
        color: AppColors.coldWater.withValues(alpha: 0.7),
        count: 7,
        radius: 3.2,
      );
    }

    // Labels.
    PipePainterHelpers.drawLabel(canvas, Offset(tapBaseX - 14, tapBaseY - 56),
        'Mixer tap');
    PipePainterHelpers.drawLabel(
        canvas, Offset(basinRect.left + 8, basinRect.top + 8), 'Sink basin');
    PipePainterHelpers.drawLabel(
        canvas, Offset(basinRect.left + 8, basinRect.bottom - 22),
        'Strainer waste');
    PipePainterHelpers.drawLabel(canvas, Offset(strainerX - 24, trapBottomY + 8),
        'U-bend trap (75 mm seal)');
    PipePainterHelpers.drawLabel(canvas,
        Offset(branchStart.dx + 20, branchStart.dy - 22), 'Branch to stack');
    PipePainterHelpers.drawLabel(
        canvas, Offset(branchEnd.dx + 14, h * 0.10), 'Soil stack');
    PipePainterHelpers.drawLabel(
        canvas,
        Offset(basinRect.right - 60, basinRect.top + 26),
        overflowBlocked ? 'Overflow sealed' : 'Overflow open',
        background: overflowBlocked
            ? AppColors.accent.withValues(alpha: 0.85)
            : Colors.white,
        textColor: overflowBlocked ? Colors.white : AppColors.text);

    _drawChecklist(canvas, size);
  }

  void _drawTap(Canvas c, Offset base) {
    final body = Paint()..color = AppColors.brass;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final spoutRect = Rect.fromLTWH(base.dx - 3, base.dy - 50, 6, 50);
    c.drawRRect(
        RRect.fromRectAndRadius(spoutRect, const Radius.circular(2)), body);
    c.drawRRect(
        RRect.fromRectAndRadius(spoutRect, const Radius.circular(2)), stroke);
    final headRect = Rect.fromLTWH(base.dx - 18, base.dy - 60, 36, 14);
    c.drawRRect(
        RRect.fromRectAndRadius(headRect, const Radius.circular(4)), body);
    c.drawRRect(
        RRect.fromRectAndRadius(headRect, const Radius.circular(4)), stroke);
    // Spout tip.
    c.drawCircle(Offset(base.dx, base.dy - 1), 5, body);
    c.drawCircle(Offset(base.dx, base.dy - 1), 5, stroke);
  }

  void _drawBasin(Canvas c, Rect r) {
    final body = Paint()..color = const Color(0xFFEDF2F6);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final path = Path()
      ..moveTo(r.left, r.top)
      ..lineTo(r.left + 14, r.bottom)
      ..lineTo(r.right - 14, r.bottom)
      ..lineTo(r.right, r.top);
    c.drawPath(path, body);
    c.drawPath(path, stroke);
    // Top rim.
    c.drawLine(Offset(r.left - 6, r.top), Offset(r.right + 6, r.top),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 3);
  }

  void _drawWaterInBasin(Canvas c, Rect r) {
    if (basinLevel <= 0.01) return;
    final innerTop =
        r.top + (1.0 - basinLevel) * (r.height - 4);
    final path = Path()
      ..moveTo(r.left + 2, innerTop)
      ..lineTo(r.left + 14, r.bottom - 2)
      ..lineTo(r.right - 14, r.bottom - 2)
      ..lineTo(r.right - 2, innerTop)
      ..close();
    final greyish = hotSoap
        ? AppColors.coldWater.withValues(alpha: 0.55)
        : const Color(0xFF8DA0A8).withValues(alpha: 0.7);
    c.drawPath(path, Paint()..color = greyish);
    // Surface ripple.
    final ripple = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rPath = Path()..moveTo(r.left + 2, innerTop);
    for (double x = r.left + 2; x < r.right - 2; x += 6) {
      rPath.relativeLineTo(3, math.sin((x + t * 60) * 0.3) * 1.4);
      rPath.relativeLineTo(3, -math.sin((x + t * 60) * 0.3) * 1.4);
    }
    c.drawPath(rPath, ripple);
  }

  void _drawStrainer(Canvas c, Rect r) {
    final cx = r.center.dx;
    final cy = r.bottom - 6;
    final outer = Paint()..color = AppColors.pipeMetal;
    c.drawCircle(Offset(cx, cy), 10, outer);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    c.drawCircle(Offset(cx, cy), 10, stroke);
    // Slits.
    for (int i = -2; i <= 2; i++) {
      c.drawLine(
        Offset(cx + i * 3.0, cy - 5),
        Offset(cx + i * 3.0, cy + 5),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.1,
      );
    }
  }

  void _drawOverflow(Canvas c, Rect r) {
    final ovRect = Rect.fromLTWH(r.right - 22, r.top + 14, 14, 6);
    c.drawRRect(
      RRect.fromRectAndRadius(ovRect, const Radius.circular(2)),
      Paint()
        ..color = overflowBlocked ? AppColors.accent : Colors.black87,
    );
  }

  void _drawUBend(Canvas c, double x, double topY, double midY, double botY) {
    // Vertical down from strainer.
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(x, topY),
      b: Offset(x, midY),
      color: AppColors.waste,
      width: 14,
    );
    // U-bend bottom curve.
    final rect = Rect.fromLTWH(x - 22, midY, 80, botY - midY);
    final paintOuter = Paint()
      ..color = AppColors.waste.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    final paintInner = Paint()
      ..color = AppColors.waste
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(rect.left + 22, rect.top)
      ..cubicTo(rect.left, rect.bottom, rect.left + 60, rect.bottom,
          rect.left + 36, rect.top);
    c.drawPath(path, paintOuter);
    c.drawPath(path, paintInner);

    // Compression nuts at top of each leg.
    PipePainterHelpers.drawJoint(c, Offset(x, midY - 2));
    PipePainterHelpers.drawJoint(c, Offset(x + 36, midY - 2));

    // Seal water inside U-bend.
    final sealPath = Path()
      ..moveTo(rect.left + 22, rect.top + 6)
      ..cubicTo(rect.left + 8, rect.bottom - 4, rect.left + 50, rect.bottom - 4,
          rect.left + 36, rect.top + 6);
    c.drawPath(
      sealPath,
      Paint()
        ..color = (cleared
                ? AppColors.coldWater
                : const Color(0xFF7A8B92))
            .withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // Gunk if not cleared.
    if (!trapEmptied) {
      final gunk = Paint()..color = const Color(0xFF3B2A1F);
      c.drawCircle(Offset(rect.left + 18, rect.bottom - 8), 5, gunk);
      c.drawCircle(Offset(rect.left + 28, rect.bottom - 4), 6, gunk);
      c.drawCircle(Offset(rect.left + 36, rect.bottom - 7), 4.5, gunk);
      // Hair strands.
      final hair = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      for (int i = 0; i < 5; i++) {
        c.drawLine(
          Offset(rect.left + 22 + i * 3, rect.bottom - 6),
          Offset(rect.left + 22 + i * 3 + 6, rect.bottom + 2),
          hair,
        );
      }
    }
  }

  void _drawOpenStubs(Canvas c, double x, double topY, double midY) {
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(x, topY),
      b: Offset(x, midY),
      color: AppColors.waste,
      width: 14,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(x + 36, midY),
      b: Offset(x + 36, midY + 18),
      color: AppColors.waste,
      width: 14,
    );
  }

  void _drawDroppedTrap(Canvas c, double x, double y) {
    final rect = Rect.fromLTWH(x - 30, y - 18, 80, 28);
    final paintOuter = Paint()
      ..color = AppColors.waste.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    final paintInner = Paint()
      ..color = AppColors.waste
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(rect.left, rect.top)
      ..cubicTo(rect.left, rect.bottom, rect.right, rect.bottom, rect.right,
          rect.top);
    c.drawPath(path, paintOuter);
    c.drawPath(path, paintInner);
  }

  void _drawBucket(Canvas c, Offset top) {
    final rect = Rect.fromLTWH(top.dx - 36, top.dy, 72, 50);
    final body = Paint()..color = const Color(0xFF455A64);
    final stroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.left + 8, rect.bottom)
      ..lineTo(rect.right - 8, rect.bottom)
      ..lineTo(rect.right, rect.top)
      ..close();
    c.drawPath(path, body);
    c.drawPath(path, stroke);
    // Handle arc.
    c.drawArc(
      Rect.fromCenter(center: top, width: 60, height: 26),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (trapEmptied) {
      // Dirty water inside.
      c.drawRect(
        Rect.fromLTRB(rect.left + 6, rect.top + 12, rect.right - 6, rect.bottom - 4),
        Paint()..color = const Color(0xFF3B2A1F).withValues(alpha: 0.7),
      );
    }
  }

  void _drawPlunger(Canvas c, Offset tip) {
    // Cup.
    final cup = Paint()..color = AppColors.accent;
    final stroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final cupRect = Rect.fromCenter(center: tip, width: 36, height: 18);
    c.drawArc(cupRect, 0, math.pi, true, cup);
    c.drawArc(cupRect, 0, math.pi, true, stroke);
    // Stick.
    final stick = Rect.fromLTWH(tip.dx - 3, tip.dy - 70, 6, 60);
    c.drawRRect(RRect.fromRectAndRadius(stick, const Radius.circular(2)),
        Paint()..color = const Color(0xFF6D4C41));
  }

  void _drawSteam(Canvas c, Rect basin) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.6);
    for (int i = 0; i < 4; i++) {
      final dx = basin.left + 30 + i * 32 + math.sin(t * math.pi * 2 + i) * 6;
      final dy = basin.top - 30 - (t * 30) % 30;
      c.drawCircle(Offset(dx, dy), 8, p);
    }
  }

  void _drawChecklist(Canvas c, Size size) {
    final items = <_ChecklistItem>[
      _ChecklistItem('Hot water + soap', hotSoap),
      _ChecklistItem('Overflow sealed', overflowBlocked),
      _ChecklistItem('Plunger applied', plunging || hotSoap && plunging),
      _ChecklistItem('Trap unscrewed', trapUnscrewed),
      _ChecklistItem('Trap emptied', trapEmptied),
      _ChecklistItem('Trap refitted', trapRefitted),
      _ChecklistItem('Test flush', flushTested),
    ];
    final boxRect = Rect.fromLTWH(size.width - 180, 12, 168, items.length * 18.0 + 14);
    c.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(8)),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    for (int i = 0; i < items.length; i++) {
      final y = boxRect.top + 8 + i * 18.0;
      final colour = items[i].done ? Colors.green.shade700 : Colors.black38;
      c.drawCircle(Offset(boxRect.left + 12, y + 6), 5, Paint()..color = colour);
      final tp = TextPainter(
        text: TextSpan(
          text: items[i].label,
          style: TextStyle(
            fontSize: 11,
            color: items[i].done ? AppColors.text : AppColors.muted,
            fontWeight: items[i].done ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, Offset(boxRect.left + 22, y));
    }
  }

  @override
  bool shouldRepaint(_SinkPainter o) => true;
}

class _ChecklistItem {
  final String label;
  final bool done;
  const _ChecklistItem(this.label, this.done);
}

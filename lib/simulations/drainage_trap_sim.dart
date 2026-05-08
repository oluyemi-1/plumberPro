import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum TrapType { pTrap, sTrap }

class DrainageTrapSimScreen extends StatefulWidget {
  const DrainageTrapSimScreen({super.key});
  @override
  State<DrainageTrapSimScreen> createState() => _DrainageTrapSimScreenState();
}

class _DrainageTrapSimScreenState extends State<DrainageTrapSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _step = 0;
  TrapType _trapType = TrapType.pTrap;
  bool _discharging = false;
  double _discharge = 0.0; // 0..1 progress of discharge animation

  static const List<SimStep> _steps = [
    SimStep(
      title: 'What a trap does',
      narration:
          'Every sanitary appliance sits above a trap. The bend holds a body '
          'of water, called the seal, which physically separates the habitable '
          'room from foul air in the drain.',
    ),
    SimStep(
      title: 'P-trap versus S-trap',
      narration:
          'A P-trap exits horizontally through a wall into a branch. An S-trap '
          'exits vertically through the floor; it is more prone to self-siphonage '
          'because the leaving leg sits directly under the seal.',
    ),
    SimStep(
      title: 'Healthy discharge',
      narration:
          'A short, measured discharge passes through the trap, fills the outlet '
          'momentarily, then air re-enters from the vent and the seal is '
          'restored at its design depth.',
    ),
    SimStep(
      title: 'Self-siphonage',
      narration:
          'If the leaving leg runs full for too long it becomes its own siphon, '
          'pulling the seal water out behind the slug. The trap is left '
          'partially or fully empty.',
    ),
    SimStep(
      title: 'Induced siphonage',
      narration:
          'When an upstream appliance, typically a WC, discharges past this '
          'branch it lowers the pressure in the stack. That negative pressure '
          'sucks the seal out of the smaller trap.',
    ),
    SimStep(
      title: 'Compression at base of stack',
      narration:
          'At the foot of the stack, falling water compresses air in the drain. '
          'That pressure wave can push up through lower branches and blow the '
          'seal back into the room.',
    ),
    SimStep(
      title: 'Evaporation and capillary loss',
      narration:
          'On a rarely used trap, water evaporates over weeks. A rag, hair or '
          'string laid across the weir can also wick the seal away by capillary '
          'action between visits.',
    ),
    SimStep(
      title: 'Solutions',
      narration:
          'Use deep-seal or anti-vacuum traps, fit an air admittance valve or '
          'extend the vent. Correct branch gradient and length are prescribed '
          'in the building regulations to prevent seal loss.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _ctrl.addListener(() {
      if (_discharging) {
        setState(() {
          _discharge += 0.012;
          if (_discharge >= 1.0) {
            _discharge = 1.0;
            _discharging = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _triggerDischarge() {
    setState(() {
      _discharge = 0.0;
      _discharging = true;
    });
  }

  // Seal level depending on step and discharge progress.
  double get _sealLevel {
    if (_step == 3 && _discharge > 0.4) {
      // self-siphon pulls seal
      return (1.0 - (_discharge - 0.4) * 1.6).clamp(0.0, 1.0);
    }
    if (_step == 4 && _discharge > 0.2) {
      // induced siphon
      return (1.0 - (_discharge - 0.2) * 1.3).clamp(0.0, 1.0);
    }
    if (_step == 5 && _discharge > 0.3) {
      // compression pushes seal up/out
      return (1.0 - (_discharge - 0.3) * 1.1).clamp(0.0, 1.0);
    }
    if (_step == 6) {
      // evaporation based on controller time
      return (1.0 - _ctrl.value * 0.6).clamp(0.0, 1.0);
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Drainage traps and seal loss',
      summary:
          'Understand how the water seal in a trap is protected, how it can be '
          'lost through siphonage, compression or evaporation, and how venting '
          'prevents those failures.',
      steps: _steps,
      onStepChanged: (i) {
        setState(() {
          _step = i;
          _discharge = 0.0;
          _discharging = false;
        });
      },
      controls: [
        ChoiceChip(
          label: const Text('P-trap'),
          selected: _trapType == TrapType.pTrap,
          onSelected: (_) => setState(() => _trapType = TrapType.pTrap),
        ),
        ChoiceChip(
          label: const Text('S-trap'),
          selected: _trapType == TrapType.sTrap,
          onSelected: (_) => setState(() => _trapType = TrapType.sTrap),
        ),
        ElevatedButton.icon(
          onPressed: _discharging ? null : _triggerDischarge,
          icon: const Icon(Icons.water_drop),
          label: const Text('Trigger discharge'),
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _DrainagePainter(
            step: i,
            t: _ctrl.value,
            trap: _trapType,
            discharge: _discharge,
            sealLevel: _sealLevel,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _DrainagePainter extends CustomPainter {
  final int step;
  final double t;
  final TrapType trap;
  final double discharge;
  final double sealLevel;

  _DrainagePainter({
    required this.step,
    required this.t,
    required this.trap,
    required this.discharge,
    required this.sealLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF9FBFD),
    );

    final w = size.width;
    final h = size.height;

    // --- Basin at top-left ---
    final basinRect = Rect.fromLTWH(w * 0.05, h * 0.08, w * 0.28, h * 0.12);
    _drawBasin(canvas, basinRect);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(basinRect.left, basinRect.top - 18),
      'Basin',
    );

    // Waste from basin down
    final wasteTop = Offset(basinRect.center.dx, basinRect.bottom);
    final trapTopY = h * 0.42;
    final trapTop = Offset(wasteTop.dx, trapTopY);

    PipePainterHelpers.drawPipe(
      canvas,
      a: wasteTop,
      b: trapTop,
      color: AppColors.waste,
      width: 12,
    );

    // --- Trap (P or S) ---
    final trapCenter = Offset(trapTop.dx + 26, trapTopY + 36);
    _drawTrap(canvas, trapTop, trapCenter, trap);

    // --- Branch to stack ---
    final branchStartY = trapTopY + 20;
    double branchStartX;
    if (trap == TrapType.pTrap) {
      branchStartX = trapCenter.dx + 34;
    } else {
      branchStartX = trapCenter.dx + 14;
    }
    final branchStart = Offset(branchStartX, branchStartY);
    final stackX = w * 0.70;
    final stackTop = Offset(stackX, h * 0.04);
    final stackBottom = Offset(stackX, h * 0.92);
    final branchEnd = Offset(stackX, branchStartY);

    if (trap == TrapType.pTrap) {
      PipePainterHelpers.drawPipe(
        canvas,
        a: branchStart,
        b: branchEnd,
        color: AppColors.waste,
        width: 12,
      );
    } else {
      // S-trap: drops then bends across
      final sDropY = branchStartY + 40;
      PipePainterHelpers.drawPipe(
        canvas,
        a: branchStart,
        b: Offset(branchStart.dx, sDropY),
        color: AppColors.waste,
        width: 12,
      );
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(branchStart.dx, sDropY),
        b: Offset(stackX, sDropY),
        color: AppColors.waste,
        width: 12,
      );
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(stackX, sDropY),
        b: branchEnd,
        color: AppColors.waste,
        width: 12,
      );
    }

    // --- Soil stack ---
    PipePainterHelpers.drawPipe(
      canvas,
      a: stackTop,
      b: stackBottom,
      color: AppColors.waste,
      width: 16,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(stackX + 14, stackTop.dy + 6),
      'Vent open\nto atmosphere',
      fontSize: 9,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(stackX - 60, stackBottom.dy - 16),
      'To drain',
      fontSize: 9,
    );

    // --- Upstream WC branch higher up ---
    final wcBranchY = h * 0.26;
    final wcP = Offset(stackX - w * 0.22, wcBranchY);
    _drawWC(canvas, wcP);
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(wcP.dx + 26, wcP.dy + 8),
      b: Offset(stackX, wcP.dy + 8),
      color: AppColors.waste,
      width: 14,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(wcP.dx - 6, wcP.dy - 18),
      'WC (upstream)',
      fontSize: 9,
    );

    // --- Foul air arrows from drain ---
    _drawFoulAirArrows(canvas, Offset(stackX, h * 0.80));

    // --- Discharge water animation ---
    if (discharge > 0.0 && discharge < 1.0) {
      // water falling from basin to trap
      final fall = discharge.clamp(0.0, 1.0);
      final yFallTop = basinRect.bottom + 2;
      final yFallBot = yFallTop + (trapTopY - yFallTop) * fall;
      final waterPaint = Paint()..color = AppColors.coldWater;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(wasteTop.dx - 4, yFallTop, 8, yFallBot - yFallTop),
          const Radius.circular(2),
        ),
        waterPaint,
      );
    }

    // Upstream WC discharge for induced siphon
    if (step == 4 && discharge > 0.0 && discharge < 1.0) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(wcP.dx + 26, wcP.dy + 8),
        b: Offset(stackX, wcP.dy + 8),
        progress: t,
        color: AppColors.coldWater,
        count: 6,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(stackX, wcP.dy + 14),
        b: Offset(stackX, h * 0.85),
        progress: t,
        color: AppColors.coldWater,
        count: 10,
      );
    }

    // Compression at base of stack
    if (step == 5 && discharge > 0.0) {
      final base = Offset(stackX, h * 0.85);
      final wavePaint = Paint()
        ..color = AppColors.waste.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (int i = 0; i < 3; i++) {
        canvas.drawCircle(
          base,
          10.0 + (t * 30) + i * 10,
          wavePaint,
        );
      }
      // upward arrows in stack
      final up = Paint()
        ..color = AppColors.accent
        ..strokeWidth = 2;
      for (int i = 0; i < 4; i++) {
        final y = h * 0.82 - i * 30 - t * 20;
        canvas.drawLine(Offset(stackX, y), Offset(stackX, y - 10), up);
        canvas.drawLine(Offset(stackX, y - 10), Offset(stackX - 4, y - 6), up);
        canvas.drawLine(Offset(stackX, y - 10), Offset(stackX + 4, y - 6), up);
      }
    }

    // Capillary / rag glyph on step 6
    if (step == 6) {
      final ragStart = trapCenter + const Offset(-10, 0);
      final ragEnd = trapCenter + const Offset(30, 24);
      final ragPaint = Paint()
        ..color = const Color(0xFF9E7E5C)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(ragStart, ragEnd, ragPaint);
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(ragEnd.dx + 4, ragEnd.dy - 8),
        'Rag / capillary',
        fontSize: 9,
      );
    }

    // Solutions glyphs on step 7
    if (step == 7) {
      // AAV on top of stack
      final aav = Offset(stackX, stackTop.dy + 10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: aav, width: 22, height: 14),
          const Radius.circular(3),
        ),
        Paint()..color = AppColors.brass,
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(aav.dx + 14, aav.dy - 4),
        'AAV',
        fontSize: 9,
      );
    }

    PipePainterHelpers.drawLabel(
      canvas,
      Offset(trapCenter.dx - 44, trapCenter.dy + 36),
      trap == TrapType.pTrap ? 'P-trap' : 'S-trap',
      fontSize: 10,
    );
  }

  void _drawBasin(Canvas canvas, Rect rect) {
    final body = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    // Basin shape: trapezoid
    final path = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right - 14, rect.bottom)
      ..lineTo(rect.left + 14, rect.bottom)
      ..close();
    canvas.drawPath(path, body);
    canvas.drawPath(path, stroke);
    // Water in basin during early discharge
    if (discharge > 0.0 && discharge < 0.3) {
      final lvl = (1 - discharge / 0.3);
      final waterPath = Path()
        ..moveTo(rect.left + 2, rect.top + 2 + (rect.height - 6) * (1 - lvl))
        ..lineTo(rect.right - 2, rect.top + 2 + (rect.height - 6) * (1 - lvl))
        ..lineTo(rect.right - 14, rect.bottom - 2)
        ..lineTo(rect.left + 14, rect.bottom - 2)
        ..close();
      canvas.drawPath(
        waterPath,
        Paint()..color = AppColors.coldWater.withValues(alpha: 0.6),
      );
    }
    // Tap
    canvas.drawRect(
      Rect.fromLTWH(rect.left + 8, rect.top - 14, 4, 14),
      Paint()..color = AppColors.brass,
    );
  }

  void _drawWC(Canvas canvas, Offset p) {
    final rect = Rect.fromLTWH(p.dx, p.dy - 8, 26, 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // cistern
    canvas.drawRect(
      Rect.fromLTWH(p.dx + 2, p.dy - 22, 22, 12),
      Paint()..color = const Color(0xFFE6EBF1),
    );
  }

  void _drawTrap(Canvas canvas, Offset inletTop, Offset center, TrapType type) {
    final pipeColor = AppColors.waste;
    // Trap body: U-shape
    final bendRect =
        Rect.fromCenter(center: center, width: 60, height: 44);
    final bodyPaint = Paint()
      ..color = pipeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final outerPaint = Paint()
      ..color = pipeColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(inletTop.dx, inletTop.dy)
      ..lineTo(inletTop.dx, bendRect.top + 10)
      ..arcToPoint(
        Offset(inletTop.dx + 52, bendRect.top + 10),
        radius: Radius.circular(bendRect.width / 2 + 2),
        clockwise: false,
        largeArc: true,
      );
    canvas.drawPath(path, outerPaint);
    canvas.drawPath(path, bodyPaint);

    // Outlet leg
    Offset outletA;
    Offset outletB;
    if (type == TrapType.pTrap) {
      outletA = Offset(inletTop.dx + 52, bendRect.top + 10);
      outletB = Offset(inletTop.dx + 120, bendRect.top + 10);
    } else {
      outletA = Offset(inletTop.dx + 52, bendRect.top + 10);
      outletB = Offset(inletTop.dx + 52, bendRect.bottom + 20);
    }
    PipePainterHelpers.drawPipe(
      canvas,
      a: outletA,
      b: outletB,
      color: pipeColor,
      width: 12,
    );

    // Water seal (blue fill in the U)
    final seal = sealLevel.clamp(0.0, 1.0);
    if (seal > 0.01) {
      final sealPaint = Paint()..color = AppColors.coldWater;
      // Draw an arc shape that fills the bottom of the U proportional to seal.
      final fillRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + 2),
        width: 46,
        height: 32 * seal + 4,
      );
      canvas.save();
      canvas.clipPath(
        Path()
          ..addRRect(RRect.fromRectAndRadius(
              fillRect, Radius.circular(fillRect.height / 2))),
      );
      canvas.drawRect(
        Rect.fromLTRB(fillRect.left, fillRect.top, fillRect.right,
            fillRect.bottom),
        sealPaint,
      );
      canvas.restore();
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(center.dx - 22, center.dy + 22),
        'Seal',
        fontSize: 9,
      );
    } else {
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(center.dx - 28, center.dy + 22),
        'Seal lost',
        fontSize: 9,
        textColor: AppColors.accent,
      );
    }
  }

  void _drawFoulAirArrows(Canvas canvas, Offset from) {
    final p = Paint()
      ..color = AppColors.waste
      ..strokeWidth = 1.5;
    for (int i = 0; i < 3; i++) {
      final y = from.dy - i * 14 - t * 6;
      canvas.drawLine(
        Offset(from.dx + 20, y),
        Offset(from.dx + 50, y),
        p,
      );
      canvas.drawLine(
        Offset(from.dx + 50, y),
        Offset(from.dx + 44, y - 3),
        p,
      );
      canvas.drawLine(
        Offset(from.dx + 50, y),
        Offset(from.dx + 44, y + 3),
        p,
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(from.dx + 26, from.dy + 8),
      'Foul air',
      fontSize: 9,
    );
  }

  @override
  bool shouldRepaint(_DrainagePainter o) =>
      o.step != step ||
      o.t != t ||
      o.trap != trap ||
      o.discharge != discharge ||
      o.sealLevel != sealLevel;
}

import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class ColdWaterSimScreen extends StatefulWidget {
  const ColdWaterSimScreen({super.key});

  @override
  State<ColdWaterSimScreen> createState() => _ColdWaterSimScreenState();
}

class _ColdWaterSimScreenState extends State<ColdWaterSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _indirect = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _steps = <SimStep>[
    SimStep(
      title: 'System overview',
      narration:
          'This is a typical domestic cold water installation in the UK. Water arrives from the main in the street, is metered at the boundary, and rises through the property to feed sanitary appliances and appliances that need potable water.',
    ),
    SimStep(
      title: 'Service pipe from the main',
      narration:
          'A blue MDPE service pipe runs from the communication pipe under the pavement, passes the boundary stop valve, and enters the property at least 750 millimetres below ground to stay frost-free. It then rises through the floor as the rising main.',
    ),
    SimStep(
      title: 'Internal stop valve and drain-off',
      narration:
          'Just inside the property you fit an internal stop valve so the householder can isolate the whole system. Directly above it goes a drain-off cock, used to empty the rising main when servicing.',
    ),
    SimStep(
      title: 'Direct vs indirect distribution',
      narration:
          'Use the toggle to switch modes. In a direct system every cold tap is fed straight off the rising main. In an indirect system only the kitchen tap is direct and the rest of the house is fed from a cold water storage cistern in the loft.',
    ),
    SimStep(
      title: 'Kitchen drinking water',
      narration:
          'Whichever system you fit, the kitchen sink cold tap must always be on a direct wholesome supply from the rising main. That guarantees drinking water is fresh and not stored.',
    ),
    SimStep(
      title: 'Upstairs feeds',
      narration:
          'Branches leave the rising main to feed the bath, wash basin and WC cistern. In an indirect system those branches instead come from the loft cistern under gravity pressure.',
    ),
    SimStep(
      title: 'Backflow protection at the outside tap',
      narration:
          'An outside tap is a fluid category 3 risk, so it needs a double check valve fitted inline on the rising main before it leaves the building. This prevents contaminated garden water being siphoned back into the main.',
    ),
    SimStep(
      title: 'Isolating and draining',
      narration:
          'To work on the system, close the internal stop valve, open the lowest tap or the drain-off cock, and let the main empty. Always open a high tap too to break the vacuum and let air in.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Cold Water Supply',
      summary:
          'Walk through how cold water travels from the main in the street to every draw-off point in a house, including isolation, drainage and backflow protection.',
      steps: _steps,
      controls: [
        ToggleButtons(
          isSelected: [!_indirect, _indirect],
          borderRadius: BorderRadius.circular(8),
          onPressed: (i) => setState(() => _indirect = i == 1),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text('Direct'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text('Indirect'),
            ),
          ],
        ),
      ],
      onStepChanged: (_) {},
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _ColdWaterPainter(
            step: i,
            t: _ctrl.value,
            indirect: _indirect,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ColdWaterPainter extends CustomPainter {
  final int step;
  final double t;
  final bool indirect;

  _ColdWaterPainter({
    required this.step,
    required this.t,
    required this.indirect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background — sky then ground.
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEAF3FB), Color(0xFFF5F8FC)],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.78));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.78), sky);
    final ground = Paint()..color = const Color(0xFFDCCBAE);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.78, w, h * 0.22), ground);

    // House outline.
    final houseRect = Rect.fromLTWH(w * 0.22, h * 0.12, w * 0.72, h * 0.66);
    final housePaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawRect(houseRect, housePaint);
    final houseStroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRect(houseRect, houseStroke);
    // Floors
    final floor1Y = h * 0.45;
    canvas.drawLine(
      Offset(houseRect.left, floor1Y),
      Offset(houseRect.right, floor1Y),
      Paint()
        ..color = Colors.black26
        ..strokeWidth = 1,
    );
    // Roof
    final roof = Path()
      ..moveTo(houseRect.left - 4, houseRect.top)
      ..lineTo(w * 0.58, h * 0.04)
      ..lineTo(houseRect.right + 4, houseRect.top)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFF9E4B3A));
    canvas.drawPath(roof, houseStroke);

    // --- Key coordinates for the pipework ---
    final boundaryValve = Offset(w * 0.1, h * 0.88);
    final mainLeft = Offset(0, h * 0.92);
    final mainRight = Offset(w, h * 0.92);
    final entryBelow = Offset(w * 0.28, h * 0.88);
    final entryUp = Offset(w * 0.28, h * 0.72);
    final stopValve = Offset(w * 0.28, h * 0.70);
    final drainOff = Offset(w * 0.28, h * 0.66);
    final riseTop = Offset(w * 0.28, h * 0.18);
    final branchKitchen = Offset(w * 0.28, h * 0.62);
    final kitchenTap = Offset(w * 0.52, h * 0.62);
    final branchOutside = Offset(w * 0.28, h * 0.56);
    final outsideTap = Offset(w * 0.08, h * 0.56);
    final dcv = Offset(w * 0.18, h * 0.56);
    final branchWc = Offset(w * 0.28, h * 0.40);
    final wcCistern = Offset(w * 0.48, h * 0.40);
    final branchBath = Offset(w * 0.28, h * 0.34);
    final bathTap = Offset(w * 0.68, h * 0.34);
    final basinTap = Offset(w * 0.84, h * 0.40);
    final loftTank = Rect.fromLTWH(w * 0.58, h * 0.15, w * 0.22, h * 0.12);
    final tankOut = Offset(loftTank.left + 6, loftTank.bottom);

    final cold = AppColors.coldWater;

    // --- Main under the street ---
    PipePainterHelpers.drawPipe(
      canvas,
      a: mainLeft,
      b: mainRight,
      color: cold,
      width: 14,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: mainLeft,
      b: mainRight,
      progress: t,
      color: Colors.white,
      count: 10,
      radius: 2.6,
    );
    PipePainterHelpers.drawLabel(canvas, Offset(w * 0.6, h * 0.94), 'Water main');

    // Service pipe from main up to boundary then across into the house.
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(boundaryValve.dx, mainLeft.dy),
      b: boundaryValve,
      color: cold,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: boundaryValve,
      b: entryBelow,
      color: cold,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: entryBelow,
      b: entryUp,
      color: cold,
    );
    PipePainterHelpers.drawValve(canvas, boundaryValve, open: true, size: 12);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boundaryValve.dx - 40, boundaryValve.dy + 18),
      'Boundary stop valve',
    );

    // Internal stop valve + drain off.
    PipePainterHelpers.drawPipe(
      canvas,
      a: entryUp,
      b: riseTop,
      color: cold,
    );
    PipePainterHelpers.drawValve(canvas, stopValve, open: true, size: 11);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(stopValve.dx + 18, stopValve.dy - 6),
      'Internal stop valve',
    );
    // Drain off — small tee downwards from stop valve area.
    canvas.drawLine(
      drainOff,
      Offset(drainOff.dx - 16, drainOff.dy + 6),
      Paint()
        ..color = cold
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(drainOff.dx - 80, drainOff.dy - 14),
      'Drain-off cock',
    );

    // Flow particles in service pipe (always live).
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: Offset(boundaryValve.dx, mainLeft.dy - 2),
      b: boundaryValve,
      progress: t,
      color: Colors.white,
      count: 3,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: boundaryValve,
      b: entryBelow,
      progress: t,
      color: Colors.white,
      count: 6,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: entryBelow,
      b: entryUp,
      progress: t,
      color: Colors.white,
      count: 4,
    );

    // Rising main continuation up above stop valve.
    PipePainterHelpers.drawJoint(canvas, branchBath);
    PipePainterHelpers.drawJoint(canvas, branchWc);
    PipePainterHelpers.drawJoint(canvas, branchKitchen);
    PipePainterHelpers.drawJoint(canvas, branchOutside);

    // Particles up the rising main always move (in direct mode feeds taps;
    // in indirect mode water still rises to the loft cistern).
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: stopValve,
      b: riseTop,
      progress: t,
      color: Colors.white,
      count: 10,
    );

    // Kitchen branch — always direct.
    PipePainterHelpers.drawPipe(
      canvas,
      a: branchKitchen,
      b: kitchenTap,
      color: cold,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: branchKitchen,
      b: kitchenTap,
      progress: t,
      color: Colors.white,
      count: 5,
    );
    _drawTap(canvas, kitchenTap);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(kitchenTap.dx + 8, kitchenTap.dy - 6),
      'Kitchen sink (drinking)',
    );

    // Outside tap branch with DCV.
    PipePainterHelpers.drawPipe(
      canvas,
      a: branchOutside,
      b: outsideTap,
      color: cold,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: branchOutside,
      b: outsideTap,
      progress: -t,
      color: Colors.white,
      count: 4,
    );
    _drawDoubleCheckValve(canvas, dcv, highlighted: step == 6);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(dcv.dx - 30, dcv.dy - 22),
      'Double check valve',
    );
    _drawTap(canvas, outsideTap, left: true);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(outsideTap.dx - 22, outsideTap.dy + 12),
      'Outside tap',
    );

    // Indirect mode: rising main continues up through loft then a cistern
    // feeds WC, bath, basin. Direct mode: tees feed all of them directly.
    if (indirect) {
      // Draw tank
      PipePainterHelpers.drawTank(
        canvas,
        rect: loftTank,
        level: 0.55,
        label: 'Cold water storage cistern',
      );
      // Rising pipe continues past branches up to tank inlet.
      PipePainterHelpers.drawPipe(
        canvas,
        a: riseTop,
        b: Offset(riseTop.dx, loftTank.top + 6),
        color: cold,
      );
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(riseTop.dx, loftTank.top + 6),
        b: Offset(loftTank.left, loftTank.top + 6),
        color: cold,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(riseTop.dx, loftTank.top + 6),
        b: Offset(loftTank.left, loftTank.top + 6),
        progress: t,
        color: Colors.white,
        count: 5,
      );
      // Ball valve at tank inlet.
      PipePainterHelpers.drawJoint(canvas, Offset(loftTank.left + 10, loftTank.top + 10));

      // Gravity feeds — tank down-pipe then branch to WC, bath, basin.
      final down1 = tankOut;
      final down2 = Offset(tankOut.dx, h * 0.34);
      PipePainterHelpers.drawPipe(canvas, a: down1, b: down2, color: cold);
      PipePainterHelpers.drawPipe(
        canvas,
        a: down2,
        b: Offset(branchBath.dx, h * 0.34),
        color: cold,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: down1,
        b: down2,
        progress: t,
        color: Colors.white,
        count: 5,
      );
    }

    // Branches to WC, bath, basin. In indirect mode their water comes from the
    // cistern-fed down pipe meeting the rise line, so we still draw the same
    // horizontal feeds; the particle direction hints at the source.
    PipePainterHelpers.drawPipe(canvas, a: branchWc, b: wcCistern, color: cold);
    _drawWcCistern(canvas, wcCistern);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(wcCistern.dx + 22, wcCistern.dy - 6),
      'WC cistern',
    );

    PipePainterHelpers.drawPipe(canvas, a: branchBath, b: bathTap, color: cold);
    PipePainterHelpers.drawPipe(
      canvas,
      a: bathTap,
      b: Offset(bathTap.dx, bathTap.dy + 26),
      color: cold,
      width: 10,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(bathTap.dx - 12, bathTap.dy + 30),
      'Bath cold',
    );

    PipePainterHelpers.drawPipe(canvas, a: branchBath, b: Offset(basinTap.dx, branchBath.dy),
        color: cold);
    PipePainterHelpers.drawPipe(
        canvas, a: Offset(basinTap.dx, branchBath.dy), b: basinTap, color: cold);
    _drawTap(canvas, basinTap);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(basinTap.dx - 8, basinTap.dy + 12),
      'Basin cold',
    );

    // Flow particles for upstairs feeds — direction depends on mode.
    final upstairsActive = step == 5 || step == 4 || step == 3 || step == 0 || step == 2;
    if (upstairsActive || indirect) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: indirect ? wcCistern : branchWc,
        b: indirect ? branchWc : wcCistern,
        progress: t,
        color: Colors.white,
        count: 4,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: indirect ? bathTap : branchBath,
        b: indirect ? branchBath : bathTap,
        progress: t,
        color: Colors.white,
        count: 5,
      );
    }

    // Step-based highlights.
    _stepHighlight(canvas, size);

    // Title label in corner.
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, 10),
      indirect ? 'INDIRECT SYSTEM' : 'DIRECT SYSTEM',
      background: AppColors.primary,
      textColor: Colors.white,
      fontSize: 11,
    );
  }

  void _stepHighlight(Canvas canvas, Size size) {
    Paint glow(Color c) => Paint()
      ..color = c.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    switch (step) {
      case 1:
        canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.9), 40,
            glow(AppColors.primary));
        break;
      case 2:
        canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.68), 40,
            glow(AppColors.primary));
        break;
      case 4:
        canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.62), 40,
            glow(AppColors.accent));
        break;
      case 6:
        canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.56), 36,
            glow(AppColors.accent));
        break;
      case 7:
        canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.66), 40,
            glow(AppColors.gas));
        break;
    }
  }

  void _drawTap(Canvas canvas, Offset p, {bool left = false}) {
    final body = Paint()..color = AppColors.brass;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rect = Rect.fromCenter(center: p, width: 18, height: 10);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)), body);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)), stroke);
    final spout = left
        ? Offset(p.dx - 10, p.dy + 8)
        : Offset(p.dx + 10, p.dy + 8);
    canvas.drawLine(p, spout, Paint()..color = AppColors.brass..strokeWidth = 4);
  }

  void _drawDoubleCheckValve(Canvas canvas, Offset p, {bool highlighted = false}) {
    final rect = Rect.fromCenter(center: p, width: 28, height: 14);
    final body = Paint()..color = AppColors.brass;
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)), body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Two back-to-back arrows.
    final arrow = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(p.dx - 10, p.dy - 4)
      ..lineTo(p.dx - 4, p.dy)
      ..lineTo(p.dx - 10, p.dy + 4)
      ..close()
      ..moveTo(p.dx + 2, p.dy - 4)
      ..lineTo(p.dx + 8, p.dy)
      ..lineTo(p.dx + 2, p.dy + 4)
      ..close();
    canvas.drawPath(path, arrow);
    if (highlighted) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(4), const Radius.circular(6)),
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }
  }

  void _drawWcCistern(Canvas canvas, Offset p) {
    final rect = Rect.fromCenter(center: p, width: 36, height: 22);
    final body = Paint()..color = Colors.white;
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)), body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // water inside
    canvas.drawRect(
      Rect.fromLTWH(rect.left + 2, rect.top + 9, rect.width - 4, rect.height - 11),
      Paint()..color = AppColors.coldWater.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant _ColdWaterPainter old) => true;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class MainsEntrySimScreen extends StatefulWidget {
  const MainsEntrySimScreen({super.key});

  @override
  State<MainsEntrySimScreen> createState() => _MainsEntrySimScreenState();
}

class _MainsEntrySimScreenState extends State<MainsEntrySimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _boundaryOpen = true;
  bool _internalOpen = true;
  bool _arctic = false;
  bool _externalMeter = true;

  static const List<SimStep> _steps = [
    SimStep(
      title: 'Roles and ownership',
      narration:
          'The water authority owns the pipework up to and including the boundary stop valve. '
          'Everything downstream of that valve, including the service pipe inside the property, is the householder\'s responsibility.',
    ),
    SimStep(
      title: 'Ferrule and communication pipe',
      narration:
          'A ferrule (saddle clamp) is fitted to the public main and the communication pipe rises from it. '
          'All work in the public footway is undertaken by the water company, never by the plumber.',
    ),
    SimStep(
      title: 'Boundary stop valve',
      narration:
          'The boundary stop is usually a long-spindle valve sitting in a small chamber under a footway lid. '
          'Closing this valve isolates the entire property from the public main.',
    ),
    SimStep(
      title: 'MDPE service pipe',
      narration:
          'From the boundary stop, a blue MDPE service pipe (typically 25 mm) runs into the property. '
          'It is jointed using fusion or compression fittings and must be at least 750 mm below ground.',
    ),
    SimStep(
      title: 'Frost protection',
      narration:
          'The 750 mm minimum cover keeps the service pipe below the frost line. '
          'Where it passes through walls or solid floors it is run inside an insulated sleeve to prevent freezing and abrasion.',
    ),
    SimStep(
      title: 'Transition into copper',
      narration:
          'Inside the building the MDPE is converted to copper at the rising main using a recognised transition fitting. '
          'This protects the plastic from heat and provides a rigid base for the first valve.',
    ),
    SimStep(
      title: 'Internal stop valve',
      narration:
          'The internal stop valve is the householder\'s primary means of isolation and must remain accessible at all times. '
          'It is fitted as the very first component on the rising main inside the dwelling.',
    ),
    SimStep(
      title: 'Drain-off cock',
      narration:
          'A drain-off cock is installed directly above the internal stop valve. '
          'After closing the stop valve the drain-off allows the rising main to be emptied for repairs or winter shutdown.',
    ),
    SimStep(
      title: 'Water meter',
      narration:
          'Meters can be fitted externally in the boundary chamber or internally just after the stop valve. '
          'Pre-meter pipework is normally MDPE and post-meter pipework is copper.',
    ),
    SimStep(
      title: 'Common faults',
      narration:
          'Typical mains-entry faults include buried leaks on the service pipe, frost burst from shallow runs, '
          'leaking ferrules at the public main, and seized boundary stop valves that no longer turn.',
    ),
  ];

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

  void _onStep(int i) {
    setState(() {
      // Step 7 demo: stop valve closed scenario
      if (i == 6) {
        _internalOpen = false;
      } else if (i == 9) {
        _boundaryOpen = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Cold Water Mains Entry',
      summary:
          'Cross-section showing how cold water enters a dwelling: from the public water main through the ferrule, '
          'communication pipe, boundary stop valve, MDPE service pipe and into the rising main with internal stop, '
          'drain-off cock and meter.',
      steps: _steps,
      onStepChanged: _onStep,
      controls: [
        FilterChip(
          label: Text('Boundary stop ${_boundaryOpen ? 'OPEN' : 'CLOSED'}'),
          selected: _boundaryOpen,
          onSelected: (v) => setState(() => _boundaryOpen = v),
        ),
        FilterChip(
          label: Text('Internal stop ${_internalOpen ? 'OPEN' : 'CLOSED'}'),
          selected: _internalOpen,
          onSelected: (v) => setState(() => _internalOpen = v),
        ),
        FilterChip(
          label: const Text('Arctic conditions'),
          selected: _arctic,
          onSelected: (v) => setState(() => _arctic = v),
        ),
        ChoiceChip(
          label: const Text('Meter: external'),
          selected: _externalMeter,
          onSelected: (_) => setState(() => _externalMeter = true),
        ),
        ChoiceChip(
          label: const Text('Meter: internal'),
          selected: !_externalMeter,
          onSelected: (_) => setState(() => _externalMeter = false),
        ),
      ],
      diagramBuilder: (ctx, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return CustomPaint(
              painter: _MainsEntryPainter(
                step: stepIndex,
                t: _ctrl.value,
                boundaryOpen: _boundaryOpen,
                internalOpen: _internalOpen,
                arctic: _arctic,
                externalMeter: _externalMeter,
              ),
              child: const SizedBox.expand(),
            );
          },
        );
      },
    );
  }
}

class _MainsEntryPainter extends CustomPainter {
  final int step;
  final double t;
  final bool boundaryOpen;
  final bool internalOpen;
  final bool arctic;
  final bool externalMeter;

  _MainsEntryPainter({
    required this.step,
    required this.t,
    required this.boundaryOpen,
    required this.internalOpen,
    required this.arctic,
    required this.externalMeter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ==== Backdrop: sky/wall above, ground line, soil below ====
    // Sky / outdoor background (left side) and indoor wall (right side)
    final groundY = h * 0.42;
    final frostDepth = h * 0.22; // ~750 mm visualised
    final skyRect = Rect.fromLTWH(0, 0, w * 0.62, groundY);
    canvas.drawRect(
      skyRect,
      Paint()..color = const Color(0xFFCFE4F1),
    );
    // Indoor wall background
    final wallRect = Rect.fromLTWH(w * 0.62, 0, w * 0.38, groundY);
    canvas.drawRect(
      wallRect,
      Paint()..color = const Color(0xFFF1ECDF),
    );
    // Wall line of the dwelling
    canvas.drawLine(
      Offset(w * 0.62, 0),
      Offset(w * 0.62, h),
      Paint()
        ..color = Colors.brown.shade700
        ..strokeWidth = 3,
    );

    // Road and pavement at ground level
    final roadRect = Rect.fromLTWH(0, groundY - 6, w * 0.18, 6);
    canvas.drawRect(roadRect, Paint()..color = const Color(0xFF555A60));
    final paveRect = Rect.fromLTWH(w * 0.18, groundY - 6, w * 0.44, 6);
    canvas.drawRect(paveRect, Paint()..color = const Color(0xFFB7BBC0));
    // Indoor floor finish
    final floorRect = Rect.fromLTWH(w * 0.62, groundY - 6, w * 0.38, 6);
    canvas.drawRect(floorRect, Paint()..color = const Color(0xFF8A6A4A));

    // Soil
    final soilRect = Rect.fromLTWH(0, groundY, w * 0.62, h - groundY);
    canvas.drawRect(
      soilRect,
      Paint()..color = const Color(0xFF7A5A3A),
    );
    // Sub-soil banding
    canvas.drawRect(
      Rect.fromLTWH(0, groundY + frostDepth, w * 0.62, h - groundY - frostDepth),
      Paint()..color = const Color(0xFF5E4226),
    );
    // Indoor sub-floor cavity
    canvas.drawRect(
      Rect.fromLTWH(w * 0.62, groundY, w * 0.38, h - groundY),
      Paint()..color = const Color(0xFF3E2A1A),
    );

    // Frost line dashed marker
    final frostY = groundY + frostDepth;
    _drawDashed(
      canvas,
      Offset(0, frostY),
      Offset(w * 0.62, frostY),
      Colors.white.withValues(alpha: 0.7),
      strokeWidth: 1.5,
      dash: 6,
      gap: 4,
    );

    // Arctic frost speckles in the upper soil band
    if (arctic) {
      final rng = math.Random(7);
      final speck = Paint()..color = const Color(0xFFCDE9FF).withValues(alpha: 0.85);
      for (int i = 0; i < 90; i++) {
        final x = rng.nextDouble() * (w * 0.62);
        final y = groundY + rng.nextDouble() * frostDepth;
        canvas.drawCircle(Offset(x, y), 1.4 + rng.nextDouble() * 1.4, speck);
      }
    }

    // ==== Define key path points ====
    // 1) Public main (large blue cylinder under road)
    final mainCenter = Offset(w * 0.07, groundY + h * 0.30);
    final mainRect = Rect.fromCenter(
      center: mainCenter,
      width: w * 0.10,
      height: 36,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mainRect, const Radius.circular(10)),
      Paint()..color = AppColors.coldWater.withValues(alpha: 0.4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mainRect, const Radius.circular(10)),
      Paint()
        ..color = AppColors.coldWater
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Ferrule (saddle clamp) on top of main
    final ferrule = Offset(mainCenter.dx, mainRect.top);
    final saddleRect = Rect.fromCenter(
      center: Offset(ferrule.dx, ferrule.dy + 2),
      width: 22,
      height: 10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(saddleRect, const Radius.circular(3)),
      Paint()..color = AppColors.brass,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(saddleRect, const Radius.circular(3)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // 2) Communication pipe: rises then crosses pavement to boundary box
    // Rise to just below frost line
    final commRiseTop = Offset(ferrule.dx, frostY + 4);
    // Boundary chamber x position
    final boundaryX = w * 0.30;
    final boundaryY = frostY + 4;
    final boundaryStop = Offset(boundaryX, boundaryY);

    // Service pipe horizontal run from boundary stop to building entry
    final entryX = w * 0.62;
    final serviceHorizY = frostY + 4;
    final buildingEntry = Offset(entryX, serviceHorizY);

    // Inside building: rise up through floor, then continue up
    final indoorFloorY = groundY - 6;
    final indoorRiseStart = Offset(entryX + 18, indoorFloorY);
    final transitionPt = Offset(entryX + 18, indoorFloorY - 22);
    final internalStopPt = Offset(entryX + 18, indoorFloorY - 60);
    final drainOffPt = Offset(entryX + 18, indoorFloorY - 95);
    final risingTop = Offset(entryX + 18, 18);

    // Internal meter position (just after stop valve)
    final internalMeterPt = Offset(entryX + 18, indoorFloorY - 130);

    // ==== Draw soil-buried pipe (communication + service) ====
    // Communication pipe: ferrule -> commRiseTop -> kink to boundary
    PipePainterHelpers.drawPipe(
      canvas,
      a: ferrule,
      b: commRiseTop,
      color: AppColors.coldWater,
      width: 10,
    );
    // Across to boundary chamber (horizontal, just below frost line)
    PipePainterHelpers.drawPipe(
      canvas,
      a: commRiseTop,
      b: Offset(boundaryX, frostY + 4),
      color: AppColors.coldWater,
      width: 10,
    );

    // Boundary chamber + footway lid
    final chamberRect = Rect.fromLTWH(
      boundaryX - 18,
      groundY - 6,
      36,
      boundaryY - groundY + 14,
    );
    canvas.drawRect(
      chamberRect,
      Paint()..color = const Color(0xFF2B2B2B).withValues(alpha: 0.85),
    );
    canvas.drawRect(
      chamberRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Footway lid
    final lidRect = Rect.fromLTWH(boundaryX - 22, groundY - 10, 44, 6);
    canvas.drawRect(
      lidRect,
      Paint()..color = const Color(0xFF3D3D3D),
    );
    canvas.drawRect(
      lidRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Boundary stop valve (long-spindle drawn as a tall stem)
    canvas.drawLine(
      Offset(boundaryX, groundY - 4),
      Offset(boundaryX, boundaryY - 4),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2,
    );
    PipePainterHelpers.drawValve(canvas, boundaryStop, open: boundaryOpen, size: 12);

    // External meter, sits in chamber after boundary stop
    if (externalMeter) {
      final meterRect = Rect.fromCenter(
        center: Offset(boundaryX + 14, boundaryY + 10),
        width: 18,
        height: 12,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(meterRect, const Radius.circular(2)),
        Paint()..color = AppColors.brass,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(meterRect, const Radius.circular(2)),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      // dial
      canvas.drawCircle(
        Offset(boundaryX + 14, boundaryY + 10),
        3.5,
        Paint()..color = Colors.white,
      );
    }

    // 3) MDPE service pipe (boundary stop -> building entry)
    final serviceShallow = arctic && (frostY < groundY + frostDepth - 1);
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(boundaryX + (externalMeter ? 26 : 4), serviceHorizY),
      b: buildingEntry,
      color: AppColors.coldWater,
      width: 12,
      highlighted: serviceShallow,
    );

    // Building entry duct + sleeve through wall
    final ductRect = Rect.fromLTWH(entryX - 6, serviceHorizY - 12, 24, 24);
    canvas.drawRect(
      ductRect,
      Paint()..color = Colors.grey.shade700,
    );
    canvas.drawRect(
      ductRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Sleeve through wall (insulated)
    final sleeveRect = Rect.fromLTWH(entryX - 2, serviceHorizY - 8, 24, 16);
    canvas.drawRect(
      sleeveRect,
      Paint()..color = const Color(0xFFE8DC9A),
    );
    canvas.drawRect(
      sleeveRect,
      Paint()
        ..color = Colors.brown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Service pipe enters the floor cavity, runs to indoor riser base
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(entryX + 18, serviceHorizY),
      b: indoorRiseStart,
      color: AppColors.coldWater,
      width: 12,
    );
    // Horizontal under-floor portion in the building
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(entryX, serviceHorizY),
      b: Offset(entryX + 18, serviceHorizY),
      color: AppColors.coldWater,
      width: 12,
    );

    // ==== Inside the dwelling (copper rising main) ====
    PipePainterHelpers.drawPipe(
      canvas,
      a: indoorRiseStart,
      b: transitionPt,
      color: AppColors.coldWater,
      width: 10,
    );

    // Transition fitting (MDPE-to-copper)
    final transRect = Rect.fromCenter(center: transitionPt, width: 20, height: 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(transRect, const Radius.circular(3)),
      Paint()..color = AppColors.brass,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(transRect, const Radius.circular(3)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Copper rising from transition up to internal stop
    PipePainterHelpers.drawPipe(
      canvas,
      a: transitionPt,
      b: internalStopPt,
      color: AppColors.copper,
      width: 10,
    );
    PipePainterHelpers.drawValve(canvas, internalStopPt, open: internalOpen, size: 12);

    // Drain-off cock directly above the stop valve
    PipePainterHelpers.drawPipe(
      canvas,
      a: internalStopPt,
      b: drainOffPt,
      color: AppColors.copper,
      width: 10,
    );
    // Drain-off cock visual (small spigot to the side)
    PipePainterHelpers.drawJoint(canvas, drainOffPt, color: AppColors.brass);
    canvas.drawLine(
      drainOffPt,
      Offset(drainOffPt.dx + 16, drainOffPt.dy + 6),
      Paint()
        ..color = AppColors.brass
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    // small handle
    canvas.drawCircle(
      Offset(drainOffPt.dx + 18, drainOffPt.dy + 7),
      3,
      Paint()..color = Colors.red.shade700,
    );

    // Internal meter (after drain-off if internal selection)
    if (!externalMeter) {
      // pipe up to meter
      PipePainterHelpers.drawPipe(
        canvas,
        a: drainOffPt,
        b: internalMeterPt,
        color: AppColors.copper,
        width: 10,
      );
      final meterRect = Rect.fromCenter(
        center: internalMeterPt,
        width: 22,
        height: 14,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(meterRect, const Radius.circular(3)),
        Paint()..color = AppColors.brass,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(meterRect, const Radius.circular(3)),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.drawCircle(
        internalMeterPt,
        4,
        Paint()..color = Colors.white,
      );
      // Continue up to top
      PipePainterHelpers.drawPipe(
        canvas,
        a: internalMeterPt,
        b: risingTop,
        color: AppColors.copper,
        width: 10,
      );
    } else {
      // continue up to top from drain-off
      PipePainterHelpers.drawPipe(
        canvas,
        a: drainOffPt,
        b: risingTop,
        color: AppColors.copper,
        width: 10,
      );
    }

    // Joints
    PipePainterHelpers.drawJoint(canvas, ferrule, color: AppColors.brass);
    PipePainterHelpers.drawJoint(canvas, commRiseTop);
    PipePainterHelpers.drawJoint(canvas, Offset(boundaryX, frostY + 4));
    PipePainterHelpers.drawJoint(canvas, indoorRiseStart);

    // ==== Flow particles (only upstream of closed valves) ====
    final flowColor = AppColors.coldWater.withValues(alpha: 0.95);

    // Public main bulk flow (always flowing)
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: Offset(mainRect.left + 6, mainCenter.dy),
      b: Offset(mainRect.right - 6, mainCenter.dy),
      progress: t,
      color: flowColor,
      count: 5,
      radius: 3,
    );

    // Comm pipe ferrule -> rise top: always flowing (upstream of boundary)
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: ferrule,
      b: commRiseTop,
      progress: t,
      color: flowColor,
      count: 4,
    );
    // commRiseTop -> boundary stop
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: commRiseTop,
      b: Offset(boundaryX, frostY + 4),
      progress: t,
      color: flowColor,
      count: 5,
    );

    // Service pipe (downstream of boundary stop)
    if (boundaryOpen) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(boundaryX + (externalMeter ? 26 : 4), serviceHorizY),
        b: buildingEntry,
        progress: t,
        color: flowColor,
        count: 7,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(entryX + 18, serviceHorizY),
        b: indoorRiseStart,
        progress: t,
        color: flowColor,
        count: 3,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: indoorRiseStart,
        b: transitionPt,
        progress: t,
        color: flowColor,
        count: 3,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: transitionPt,
        b: internalStopPt,
        progress: t,
        color: flowColor,
        count: 3,
      );
    } else {
      // water draining away downstream of closed boundary stop
      _drawDrainingDrops(canvas, buildingEntry, t);
    }

    // Past internal stop valve
    if (boundaryOpen && internalOpen) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: internalStopPt,
        b: drainOffPt,
        progress: t,
        color: flowColor,
        count: 3,
      );
      if (!externalMeter) {
        PipePainterHelpers.drawFlowParticles(
          canvas,
          a: drainOffPt,
          b: internalMeterPt,
          progress: t,
          color: flowColor,
          count: 2,
        );
        PipePainterHelpers.drawFlowParticles(
          canvas,
          a: internalMeterPt,
          b: risingTop,
          progress: t,
          color: flowColor,
          count: 4,
        );
      } else {
        PipePainterHelpers.drawFlowParticles(
          canvas,
          a: drainOffPt,
          b: risingTop,
          progress: t,
          color: flowColor,
          count: 5,
        );
      }
    } else if (boundaryOpen && !internalOpen) {
      _drawDrainingDrops(canvas, drainOffPt, t);
    }

    // ==== Labels (at least 12) ====
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(mainRect.left - 4, mainRect.bottom + 8),
      'Public main (4 bar)',
      background: AppColors.coldWater.withValues(alpha: 0.18),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ferrule.dx - 30, ferrule.dy - 28),
      'Ferrule',
      background: AppColors.brass.withValues(alpha: 0.4),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ferrule.dx + 18, ferrule.dy + 32),
      'Communication pipe',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boundaryX - 60, groundY - 28),
      'Footway box & lid',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boundaryX + 16, boundaryY - 20),
      'Boundary stop valve',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset((boundaryX + entryX) / 2 - 50, serviceHorizY + 12),
      'MDPE service pipe (25 mm)',
      background: AppColors.coldWater.withValues(alpha: 0.18),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(4, frostY - 16),
      'Frost depth 750 mm min',
      background: arctic ? const Color(0xFFCDE9FF) : Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(entryX - 50, serviceHorizY + 24),
      'Building entry duct',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(entryX + 4, serviceHorizY - 26),
      'Sleeve through wall',
      background: const Color(0xFFE8DC9A),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(transitionPt.dx + 18, transitionPt.dy - 6),
      'MDPE-to-copper transition',
      background: AppColors.brass.withValues(alpha: 0.4),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(internalStopPt.dx + 18, internalStopPt.dy - 6),
      'Internal stop valve',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(drainOffPt.dx + 24, drainOffPt.dy - 6),
      'Drain-off cock',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(risingTop.dx + 14, risingTop.dy + 4),
      'Rising main (copper)',
      background: AppColors.copper.withValues(alpha: 0.25),
    );
    if (externalMeter) {
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(boundaryX + 30, boundaryY + 18),
        'Water meter (external)',
      );
    } else {
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(internalMeterPt.dx + 18, internalMeterPt.dy - 6),
        'Water meter (internal)',
      );
    }

    // Arctic warning if shallow
    if (arctic) {
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(w * 0.30, 10),
        'ARCTIC: check service pipe cover ≥ 750 mm',
        background: const Color(0xFFFFE5E5),
        textColor: Colors.red.shade900,
      );
    }

    // Step heading at top-left
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(10, 10),
      'Step ${step + 1}',
      background: AppColors.primary.withValues(alpha: 0.15),
    );

    // Ground level label
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.40, groundY - 22),
      'Ground level',
      background: Colors.white.withValues(alpha: 0.9),
    );
  }

  void _drawDrainingDrops(Canvas canvas, Offset from, double t) {
    final paint = Paint()..color = AppColors.coldWater.withValues(alpha: 0.7);
    for (int i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1.0;
      final dy = phase * 24;
      canvas.drawCircle(Offset(from.dx + (i - 1) * 3, from.dy + 8 + dy), 2.2, paint);
    }
  }

  void _drawDashed(
    Canvas canvas,
    Offset a,
    Offset b,
    Color color, {
    double strokeWidth = 1,
    double dash = 5,
    double gap = 3,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    final total = (b - a).distance;
    final dir = (b - a) / total;
    double drawn = 0;
    while (drawn < total) {
      final start = a + dir * drawn;
      final end = a + dir * math.min(drawn + dash, total);
      canvas.drawLine(start, end, paint);
      drawn += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_MainsEntryPainter o) => true;
}

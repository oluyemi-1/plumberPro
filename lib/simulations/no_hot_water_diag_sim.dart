import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum NoHotWaterScenario {
  diverterStuck,
  failedTurbine,
  scaledPhe,
  lowPressure,
}

class NoHotWaterDiagSimScreen extends StatefulWidget {
  const NoHotWaterDiagSimScreen({super.key});
  @override
  State<NoHotWaterDiagSimScreen> createState() => _NoHotWaterDiagSimScreenState();
}

class _NoHotWaterDiagSimScreenState extends State<NoHotWaterDiagSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _tapOpen = false;
  bool _fixed = false;
  NoHotWaterScenario _scenario = NoHotWaterScenario.diverterStuck;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _burnerFiring {
    if (!_tapOpen) return false;
    if (_fixed) return true;
    switch (_scenario) {
      case NoHotWaterScenario.diverterStuck:
        return true; // burner fires but heating loop instead of DHW
      case NoHotWaterScenario.failedTurbine:
        return false;
      case NoHotWaterScenario.scaledPhe:
        return true;
      case NoHotWaterScenario.lowPressure:
        return false;
    }
  }

  Color get _outletColor {
    if (!_tapOpen) return AppColors.coldWater;
    if (_fixed) return AppColors.hotWater;
    switch (_scenario) {
      case NoHotWaterScenario.diverterStuck:
      case NoHotWaterScenario.failedTurbine:
      case NoHotWaterScenario.lowPressure:
        return AppColors.coldWater;
      case NoHotWaterScenario.scaledPhe:
        return Color.lerp(AppColors.coldWater, AppColors.hotWater, 0.5)!;
    }
  }

  String get _scenarioLabel {
    switch (_scenario) {
      case NoHotWaterScenario.diverterStuck:
        return 'Diverter stuck on heating';
      case NoHotWaterScenario.failedTurbine:
        return 'Failed flow turbine';
      case NoHotWaterScenario.scaledPhe:
        return 'Scaled plate exchanger';
      case NoHotWaterScenario.lowPressure:
        return 'Low DHW pressure';
    }
  }

  List<SimStep> get _steps => [
        SimStep(
          title: '1. Symptom',
          narration:
              'Customer reports the kitchen tap runs lukewarm or cold although radiators heat up normally. With a combi this almost always points to the DHW side rather than the gas valve or PCB.',
        ),
        const SimStep(
          title: '2. Open the hot tap fully',
          narration:
              'Open the hot tap fully and listen. You should hear the fan ramp and the burner ignite within about five seconds. No fire on demand narrows the fault to flow detection or pressure.',
        ),
        const SimStep(
          title: '3. Check inlet flow rate',
          narration:
              'Use a measuring jug or flow cup at the kitchen tap. A healthy combi needs at least 2.5 litres per minute to fire and 6+ for proper hot delivery; anything less is a pressure or strainer issue.',
        ),
        const SimStep(
          title: '4. Listen and feel',
          narration:
              'Feel the diverter for a clunk on demand and check whether the plate heat exchanger warms within seconds. A silent diverter or stone-cold PHE while the burner roars is diagnostic.',
        ),
        SimStep(
          title: '5. Decode fault: $_scenarioLabel',
          narration: _scenarioNarration(),
        ),
        SimStep(
          title: '6. Fix procedure',
          narration: _fixNarration(),
        ),
        const SimStep(
          title: '7. Refit, fill, vent, test',
          narration:
              'Re-pressurise to 1.2 bar cold, vent the PHE through the hot tap, and run for ten minutes confirming a stable 55 to 60 degree outlet at 6 to 10 litres per minute.',
        ),
        const SimStep(
          title: '8. Notifiable: record on Benchmark',
          narration:
              'Update the Benchmark commissioning checklist, log the fault code or reading, and leave the customer the gas safety record. Component swaps on a sealed system are notifiable to building control if it is a heat exchanger.',
        ),
      ];

  String _scenarioNarration() {
    switch (_scenario) {
      case NoHotWaterScenario.diverterStuck:
        return 'The diverter is parked in the heating position so primary water never crosses the PHE. Burner fires but DHW comes out cold. Replace the cartridge and seals.';
      case NoHotWaterScenario.failedTurbine:
        return 'The Hall-effect flow turbine no longer signals demand to the PCB so the burner never fires. Spin the impeller by hand off the body and check for shaft stiction.';
      case NoHotWaterScenario.scaledPhe:
        return 'Limescale has bottlenecked the secondary side of the plate heat exchanger. Burner fires but heat transfer is poor, giving lukewarm output and short-cycling.';
      case NoHotWaterScenario.lowPressure:
        return 'Cold mains is delivering below the DHW firing minimum. The PCB never sees demand. Check the strainer, flexi feeds, and consider an accumulator on a low-pressure main.';
    }
  }

  String _fixNarration() {
    switch (_scenario) {
      case NoHotWaterScenario.diverterStuck:
        return 'Isolate, drain the boiler, swap the diverter cartridge or full body to manufacturer torque, and re-fill cold. Many cartridges are a five minute swap once isolated.';
      case NoHotWaterScenario.failedTurbine:
        return 'Drain the cold side, unclip the flow turbine from the inlet group, fit the new sensor with a new o-ring, re-pressurise, and confirm the PCB sees demand on a flow above 2.5 l/min.';
      case NoHotWaterScenario.scaledPhe:
        return 'Power down, isolate, and either flush the PHE in-situ with a citric or sulphamic descaler kit or remove and replace it. Fit a scale-reducing device on the cold inlet.';
      case NoHotWaterScenario.lowPressure:
        return 'Confirm there is no partly closed isolator, flush the strainer, then if mains is genuinely weak fit an accumulator vessel and pump combination sized to the boiler.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Diagnose: no DHW from a combi',
      summary:
          'Walk through structured fault-finding for a combi where central heating works but the hot tap runs cold or lukewarm. Toggle the scenarios to see how the same symptom hides four different root causes.',
      steps: _steps,
      onStepChanged: (i) => setState(() {
        if (i == 5) _fixed = true;
        if (i == 0) _fixed = false;
      }),
      controls: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Open hot tap '),
            Switch.adaptive(
              value: _tapOpen,
              onChanged: (v) => setState(() => _tapOpen = v),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          children: NoHotWaterScenario.values.map((s) {
            return ChoiceChip(
              label: Text(_labelFor(s)),
              selected: _scenario == s,
              onSelected: (_) => setState(() {
                _scenario = s;
                _fixed = false;
              }),
            );
          }).toList(),
        ),
        ElevatedButton.icon(
          onPressed: () => setState(() => _fixed = true),
          icon: const Icon(Icons.build),
          label: Text(_fixLabelFor(_scenario)),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _fixed = false),
          icon: const Icon(Icons.refresh),
          label: const Text('Reset fault'),
        ),
      ],
      diagramBuilder: (ctx, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _NoHotWaterPainter(
              step: stepIndex,
              t: _ctrl.value,
              tapOpen: _tapOpen,
              fixed: _fixed,
              scenario: _scenario,
              burnerOn: _burnerFiring,
              outletColor: _outletColor,
            ),
          ),
        );
      },
    );
  }

  String _labelFor(NoHotWaterScenario s) {
    switch (s) {
      case NoHotWaterScenario.diverterStuck:
        return 'Diverter stuck';
      case NoHotWaterScenario.failedTurbine:
        return 'Flow turbine';
      case NoHotWaterScenario.scaledPhe:
        return 'Scaled PHE';
      case NoHotWaterScenario.lowPressure:
        return 'Low pressure';
    }
  }

  String _fixLabelFor(NoHotWaterScenario s) {
    switch (s) {
      case NoHotWaterScenario.diverterStuck:
        return 'Replace diverter';
      case NoHotWaterScenario.failedTurbine:
        return 'Replace turbine';
      case NoHotWaterScenario.scaledPhe:
        return 'Descale PHE';
      case NoHotWaterScenario.lowPressure:
        return 'Fit accumulator';
    }
  }
}

class _NoHotWaterPainter extends CustomPainter {
  final int step;
  final double t;
  final bool tapOpen;
  final bool fixed;
  final NoHotWaterScenario scenario;
  final bool burnerOn;
  final Color outletColor;

  _NoHotWaterPainter({
    required this.step,
    required this.t,
    required this.tapOpen,
    required this.fixed,
    required this.scenario,
    required this.burnerOn,
    required this.outletColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Boiler casing
    final casing = Rect.fromLTWH(w * 0.08, h * 0.08, w * 0.62, h * 0.78);
    canvas.drawRRect(
      RRect.fromRectAndRadius(casing, const Radius.circular(14)),
      Paint()..color = const Color(0xFFE8EDF2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(casing, const Radius.circular(14)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Cold mains entry
    final coldIn = Offset(w * 0.12, h * 0.92);
    final coldUp = Offset(w * 0.12, h * 0.62);
    PipePainterHelpers.drawPipe(
      canvas,
      a: coldIn,
      b: coldUp,
      color: AppColors.coldWater,
      width: 11,
    );

    // Flow turbine
    final turbine = Offset(w * 0.18, h * 0.62);
    PipePainterHelpers.drawPipe(
      canvas,
      a: coldUp,
      b: turbine,
      color: AppColors.coldWater,
      width: 11,
    );
    _drawTurbine(canvas, turbine);
    PipePainterHelpers.drawLabel(
        canvas, Offset(turbine.dx - 18, turbine.dy + 16), 'Flow turbine');

    // From turbine to PHE
    final pheIn = Offset(w * 0.30, h * 0.62);
    PipePainterHelpers.drawPipe(
      canvas,
      a: turbine,
      b: pheIn,
      color: AppColors.coldWater,
      width: 11,
    );

    // Plate heat exchanger
    final pheRect = Rect.fromLTWH(w * 0.30, h * 0.46, w * 0.10, h * 0.22);
    final pheWarm = burnerOn &&
        scenario != NoHotWaterScenario.diverterStuck &&
        scenario != NoHotWaterScenario.failedTurbine &&
        scenario != NoHotWaterScenario.lowPressure;
    canvas.drawRRect(
      RRect.fromRectAndRadius(pheRect, const Radius.circular(4)),
      Paint()
        ..color = pheWarm
            ? AppColors.hotWater.withValues(alpha: 0.45)
            : AppColors.coldWater.withValues(alpha: 0.4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pheRect, const Radius.circular(4)),
      Paint()
        ..color = AppColors.pipeMetal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // plate fins
    for (int i = 1; i < 8; i++) {
      final x = pheRect.left + (pheRect.width / 8) * i;
      canvas.drawLine(
        Offset(x, pheRect.top + 2),
        Offset(x, pheRect.bottom - 2),
        Paint()
          ..color = Colors.black26
          ..strokeWidth = 1,
      );
    }
    PipePainterHelpers.drawLabel(
        canvas, Offset(pheRect.left - 10, pheRect.top - 18), 'Plate heat exchanger');

    if (scenario == NoHotWaterScenario.scaledPhe && !fixed) {
      // limescale dots
      final rng = math.Random(11);
      for (int i = 0; i < 24; i++) {
        canvas.drawCircle(
          Offset(
            pheRect.left + rng.nextDouble() * pheRect.width,
            pheRect.top + rng.nextDouble() * pheRect.height,
          ),
          1.6,
          Paint()..color = const Color(0xFFEAD7A1),
        );
      }
    }

    // Diverter valve
    final diverter = Offset(w * 0.45, h * 0.40);
    _drawDiverter(canvas, diverter);
    PipePainterHelpers.drawLabel(
        canvas, Offset(diverter.dx - 18, diverter.dy - 28), 'Diverter');

    // From PHE up to diverter
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(pheRect.center.dx, pheRect.top),
      b: Offset(pheRect.center.dx, h * 0.40),
      color: pheWarm ? AppColors.hotWater : AppColors.coldWater,
      width: 9,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(pheRect.center.dx, h * 0.40),
      b: diverter,
      color: pheWarm ? AppColors.hotWater : AppColors.coldWater,
      width: 9,
    );

    // Primary heat exchanger and burner
    final primaryRect = Rect.fromLTWH(w * 0.50, h * 0.20, w * 0.18, h * 0.22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(primaryRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFCFD6DD),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(primaryRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // fins on primary HX
    for (int i = 1; i < 6; i++) {
      final y = primaryRect.top + (primaryRect.height / 6) * i;
      canvas.drawLine(Offset(primaryRect.left + 4, y),
          Offset(primaryRect.right - 4, y), Paint()..color = Colors.black26);
    }
    PipePainterHelpers.drawLabel(
        canvas,
        Offset(primaryRect.left, primaryRect.top - 18),
        'Primary HX');

    // Burner under HX
    final burnerY = primaryRect.bottom + 6;
    final burnerRect = Rect.fromLTRB(primaryRect.left + 6, burnerY,
        primaryRect.right - 6, burnerY + 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(burnerRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF333333),
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(burnerRect.left, burnerRect.bottom + 4), 'Burner');

    // Flame icon
    if (burnerOn) {
      final flameSize = 12 + (math.sin(t * 2 * math.pi) * 4);
      _drawFlame(canvas, Offset(burnerRect.center.dx, burnerRect.top - 4),
          flameSize.toDouble());
    }

    // Diverter to primary HX (heating loop)
    PipePainterHelpers.drawPipe(
      canvas,
      a: diverter,
      b: Offset(primaryRect.left, h * 0.40),
      color: AppColors.hotWater,
      width: 9,
    );

    // Hot draw-off out of PHE secondary to tap
    final outletStart = Offset(pheRect.right, h * 0.50);
    final outletElbow = Offset(w * 0.78, h * 0.50);
    final tap = Offset(w * 0.92, h * 0.50);
    PipePainterHelpers.drawPipe(
      canvas,
      a: outletStart,
      b: outletElbow,
      color: outletColor,
      width: 11,
    );
    PipePainterHelpers.drawJoint(canvas, outletElbow);
    PipePainterHelpers.drawPipe(
      canvas,
      a: outletElbow,
      b: tap,
      color: outletColor,
      width: 11,
    );
    // Tap glyph
    canvas.drawCircle(tap, 7, Paint()..color = AppColors.brass);
    canvas.drawLine(
      Offset(tap.dx, tap.dy + 4),
      Offset(tap.dx, tap.dy + 18),
      Paint()
        ..color = AppColors.brass
        ..strokeWidth = 5,
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(tap.dx - 22, tap.dy + 22), 'Kitchen tap');

    // Particles when tap open and water flowing
    if (tapOpen) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: coldIn,
        b: coldUp,
        progress: t,
        color: Colors.white.withValues(alpha: 0.8),
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: outletStart,
        b: tap,
        progress: t,
        color: Colors.white.withValues(alpha: 0.85),
      );
    }

    // Fault highlight
    if (!fixed) {
      Offset? faultPos;
      String faultText = '';
      switch (scenario) {
        case NoHotWaterScenario.diverterStuck:
          faultPos = diverter;
          faultText = 'STUCK';
          break;
        case NoHotWaterScenario.failedTurbine:
          faultPos = turbine;
          faultText = 'NO SIGNAL';
          break;
        case NoHotWaterScenario.scaledPhe:
          faultPos = pheRect.center;
          faultText = 'SCALED';
          break;
        case NoHotWaterScenario.lowPressure:
          faultPos = coldIn;
          faultText = 'LOW PSI';
          break;
      }
      canvas.drawCircle(
        faultPos,
        20,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(faultPos.dx + 18, faultPos.dy - 10),
        faultText,
        background: AppColors.accent,
        textColor: Colors.white,
      );
    }

    // Title
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(casing.left + 6, casing.top + 4),
      'Combi boiler — DHW path',
      background: AppColors.primary,
      textColor: Colors.white,
    );
  }

  void _drawTurbine(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 10, Paint()..color = AppColors.pipeMetal);
    canvas.drawCircle(
        c,
        10,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    final spin = scenario == NoHotWaterScenario.failedTurbine ? 0.0 : t * 2 * math.pi;
    for (int i = 0; i < 4; i++) {
      final angle = spin + i * math.pi / 2;
      final p1 = c + Offset(math.cos(angle) * 8, math.sin(angle) * 8);
      canvas.drawLine(c, p1,
          Paint()..color = Colors.black87..strokeWidth = 1.6);
    }
  }

  void _drawDiverter(Canvas canvas, Offset c) {
    final r = 14.0;
    canvas.drawCircle(c, r, Paint()..color = AppColors.brass);
    canvas.drawCircle(c, r,
        Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 1.4);
    // arrow showing position
    double angle;
    if (scenario == NoHotWaterScenario.diverterStuck && !fixed) {
      angle = 0; // pointing right (heating)
    } else {
      // toggle between positions if tap open
      angle = tapOpen ? math.pi / 2 : 0;
    }
    final arrowEnd = c + Offset(math.cos(angle) * r, math.sin(angle) * r);
    canvas.drawLine(c, arrowEnd,
        Paint()..color = Colors.black87..strokeWidth = 2.4);
  }

  void _drawFlame(Canvas canvas, Offset base, double size) {
    final path = Path()
      ..moveTo(base.dx - size * 0.4, base.dy)
      ..quadraticBezierTo(base.dx - size * 0.6, base.dy - size * 0.6,
          base.dx, base.dy - size * 1.2)
      ..quadraticBezierTo(base.dx + size * 0.6, base.dy - size * 0.6,
          base.dx + size * 0.4, base.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.accent);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // inner blue
    final inner = Path()
      ..moveTo(base.dx - size * 0.18, base.dy - size * 0.05)
      ..quadraticBezierTo(base.dx - size * 0.25, base.dy - size * 0.4,
          base.dx, base.dy - size * 0.7)
      ..quadraticBezierTo(base.dx + size * 0.25, base.dy - size * 0.4,
          base.dx + size * 0.18, base.dy - size * 0.05)
      ..close();
    canvas.drawPath(inner, Paint()..color = AppColors.coldWater);
  }

  @override
  bool shouldRepaint(_NoHotWaterPainter o) => true;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum WcScenario {
  floatValve,
  flushDiaphragm,
}

class RunningWcSimScreen extends StatefulWidget {
  const RunningWcSimScreen({super.key});
  @override
  State<RunningWcSimScreen> createState() => _RunningWcSimScreenState();
}

class _RunningWcSimScreenState extends State<RunningWcSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  WcScenario _scenario = WcScenario.floatValve;
  bool _lidLifted = false;
  bool _dyeAdded = false;
  bool _floatAdjusted = false;
  bool _diaphragmReplaced = false;
  bool _cycleTested = false;
  double _waterLevel = 0.85; // 0..1 of cistern height; overflow at 0.9

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

  bool get _fixed {
    switch (_scenario) {
      case WcScenario.floatValve:
        return _floatAdjusted;
      case WcScenario.flushDiaphragm:
        return _diaphragmReplaced;
    }
  }

  bool get _overflowing =>
      _scenario == WcScenario.floatValve && !_fixed && _waterLevel >= 0.88;

  bool get _drippingIntoPan => _scenario == WcScenario.flushDiaphragm && !_fixed;

  List<SimStep> get _steps => const [
        SimStep(
          title: '1. Symptom — running water',
          narration:
              'Customer reports the toilet hisses constantly or water is dribbling down the outside overflow. The clue is whether you can see the cistern level rising or it sits stable but the pan keeps refilling.',
        ),
        SimStep(
          title: '2. Lift the lid carefully',
          narration:
              'Cisterns are heavy and brittle, lift straight up and place flat. Note the water level relative to the maker line stamped inside, normally about 25 mm below the overflow.',
        ),
        SimStep(
          title: '3. Above the line: float valve fault',
          narration:
              'If the level is at or above the overflow line, the float valve is failing to shut off. Either the washer is worn, the diaphragm is split, or the float arm is set too high.',
        ),
        SimStep(
          title: '4. Level correct but trickling',
          narration:
              'If the level is correct yet water still trickles into the pan, the flush valve diaphragm or seal at the centre of the cistern is leaking past. This often makes no sound at all.',
        ),
        SimStep(
          title: '5. Dye test for confirmation',
          narration:
              'Drop a few drops of food dye into the cistern and do not flush. If colour appears in the pan within ten minutes, the flush valve is leaking by. Standard diagnostic in a service call.',
        ),
        SimStep(
          title: '6. Float valve repair',
          narration:
              'Isolate the supply, dismantle the cap, replace the washer or full diaphragm cartridge, and re-set the shut-off level. On older Portsmouth valves a gentle bend of the arm lowers the level.',
        ),
        SimStep(
          title: '7. Flush valve repair',
          narration:
              'Pop out the centre flush valve cartridge, swap the rubber diaphragm and lower seal, and refit. On a syphon, replace the syphon diaphragm — same principle but a larger flat washer.',
        ),
        SimStep(
          title: '8. Set level and cycle test',
          narration:
              'Set shut-off 25 mm below the overflow, flush two or three times to confirm a clean cut-off and a dry pan after settling. Leave the customer with a working toilet and no future drips.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Diagnose: running WC cistern',
      summary:
          'Step through the two main running-water faults found in a domestic WC: a float valve that will not shut off, and a flush valve diaphragm that leaks silently into the pan.',
      steps: _steps,
      onStepChanged: (_) => setState(() {}),
      controls: [
        Wrap(spacing: 6, children: [
          ChoiceChip(
            label: const Text('Float valve fails'),
            selected: _scenario == WcScenario.floatValve,
            onSelected: (_) => setState(() {
              _scenario = WcScenario.floatValve;
              _floatAdjusted = false;
            }),
          ),
          ChoiceChip(
            label: const Text('Flush valve leaks'),
            selected: _scenario == WcScenario.flushDiaphragm,
            onSelected: (_) => setState(() {
              _scenario = WcScenario.flushDiaphragm;
              _diaphragmReplaced = false;
            }),
          ),
        ]),
        OutlinedButton.icon(
          onPressed: () => setState(() => _lidLifted = !_lidLifted),
          icon: Icon(_lidLifted ? Icons.visibility : Icons.visibility_off),
          label: Text(_lidLifted ? 'Lid off' : 'Lift lid'),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _dyeAdded = true),
          icon: const Icon(Icons.water_drop),
          label: const Text('Add dye'),
        ),
        ElevatedButton.icon(
          onPressed: _scenario == WcScenario.floatValve
              ? () => setState(() {
                    _floatAdjusted = true;
                    _waterLevel = 0.7;
                  })
              : null,
          icon: const Icon(Icons.tune),
          label: const Text('Adjust float'),
        ),
        ElevatedButton.icon(
          onPressed: _scenario == WcScenario.flushDiaphragm
              ? () => setState(() => _diaphragmReplaced = true)
              : null,
          icon: const Icon(Icons.build),
          label: const Text('Replace flush diaphragm'),
        ),
        OutlinedButton.icon(
          onPressed: _fixed ? () => setState(() => _cycleTested = true) : null,
          icon: const Icon(Icons.refresh),
          label: const Text('Cycle test'),
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Level '),
          SizedBox(
            width: 140,
            child: Slider(
              value: _waterLevel,
              min: 0,
              max: 1,
              onChanged: (v) => setState(() => _waterLevel = v),
            ),
          ),
        ]),
      ],
      diagramBuilder: (ctx, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _RunningWcPainter(
              step: stepIndex,
              t: _ctrl.value,
              scenario: _scenario,
              lidLifted: _lidLifted,
              dyeAdded: _dyeAdded,
              fixed: _fixed,
              waterLevel: _waterLevel,
              overflowing: _overflowing,
              drippingIntoPan: _drippingIntoPan,
              cycleTested: _cycleTested,
            ),
          ),
        );
      },
    );
  }
}

class _RunningWcPainter extends CustomPainter {
  final int step;
  final double t;
  final WcScenario scenario;
  final bool lidLifted;
  final bool dyeAdded;
  final bool fixed;
  final double waterLevel;
  final bool overflowing;
  final bool drippingIntoPan;
  final bool cycleTested;

  _RunningWcPainter({
    required this.step,
    required this.t,
    required this.scenario,
    required this.lidLifted,
    required this.dyeAdded,
    required this.fixed,
    required this.waterLevel,
    required this.overflowing,
    required this.drippingIntoPan,
    required this.cycleTested,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wall background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFEFF3F8),
    );

    // Cistern body (sectional)
    final cistern = Rect.fromLTWH(w * 0.12, h * 0.10, w * 0.55, h * 0.45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cistern, const Radius.circular(6)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cistern, const Radius.circular(6)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Water inside
    final overflowY = cistern.top + cistern.height * 0.10;
    final cisternWaterTop =
        cistern.bottom - cistern.height * waterLevel.clamp(0.0, 1.0);
    final waterRect = Rect.fromLTRB(cistern.left + 2, cisternWaterTop,
        cistern.right - 2, cistern.bottom - 2);
    final waterColor = dyeAdded
        ? const Color(0xFF2EBF6E).withValues(alpha: 0.7)
        : AppColors.coldWater.withValues(alpha: 0.65);
    canvas.drawRect(waterRect, Paint()..color = waterColor);
    // Ripple
    final ripplePath = Path()..moveTo(waterRect.left, waterRect.top);
    for (double x = waterRect.left; x < waterRect.right; x += 8) {
      ripplePath.relativeLineTo(4, -1.5 - math.sin(t * 2 * math.pi + x) * 0.8);
      ripplePath.relativeLineTo(4, 1.5 + math.sin(t * 2 * math.pi + x) * 0.8);
    }
    canvas.drawPath(
      ripplePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Overflow line marker
    canvas.drawLine(
      Offset(cistern.left, overflowY),
      Offset(cistern.right, overflowY),
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.6)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
    PipePainterHelpers.drawLabel(
        canvas,
        Offset(cistern.right + 4, overflowY - 6),
        'Overflow line');

    // Cold mains entry to side-entry float valve
    final coldEntry = Offset(cistern.left, cistern.top + cistern.height * 0.5);
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(cistern.left - 30, coldEntry.dy),
      b: coldEntry,
      color: AppColors.coldWater,
      width: 9,
    );
    PipePainterHelpers.drawLabel(
        canvas,
        Offset(cistern.left - 60, coldEntry.dy - 18),
        'Cold mains in');

    // Float valve mechanism
    final floatBody = Offset(cistern.left + 18, coldEntry.dy);
    canvas.drawRect(
      Rect.fromCenter(center: floatBody, width: 14, height: 18),
      Paint()..color = AppColors.brass,
    );
    PipePainterHelpers.drawLabel(
        canvas,
        Offset(floatBody.dx + 12, floatBody.dy - 26),
        'Float valve');

    // Float arm
    double armAngle =
        (scenario == WcScenario.floatValve && !fixed) ? -0.3 : -0.15;
    final armEnd = floatBody +
        Offset(math.cos(armAngle) * 70, math.sin(armAngle) * 70);
    canvas.drawLine(floatBody, armEnd,
        Paint()..color = AppColors.pipeMetal..strokeWidth = 3);
    // Float ball
    canvas.drawCircle(armEnd, 12, Paint()..color = const Color(0xFFFFCB3D));
    canvas.drawCircle(
        armEnd, 12, Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 1);
    PipePainterHelpers.drawLabel(
        canvas, Offset(armEnd.dx - 10, armEnd.dy + 14), 'Float');

    // Centre flush valve / syphon
    final flushBase = Offset(cistern.center.dx, cistern.bottom - 4);
    final flushTop = Offset(cistern.center.dx, cistern.top + 18);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(flushBase.dx, (flushBase.dy + flushTop.dy) / 2),
          width: 22, height: (flushBase.dy - flushTop.dy)),
      Paint()..color = AppColors.pipeMetal,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(flushBase.dx, (flushBase.dy + flushTop.dy) / 2),
          width: 22, height: (flushBase.dy - flushTop.dy)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Diaphragm seal
    final diaphragm = Rect.fromCenter(
        center: Offset(flushBase.dx, flushBase.dy - 8), width: 30, height: 6);
    canvas.drawRect(
      diaphragm,
      Paint()
        ..color = (scenario == WcScenario.flushDiaphragm && !fixed)
            ? AppColors.accent.withValues(alpha: 0.6)
            : const Color(0xFF333333),
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(flushBase.dx + 16, flushBase.dy - 14), 'Flush diaphragm');
    PipePainterHelpers.drawLabel(
        canvas, Offset(flushBase.dx - 50, flushTop.dy - 4), 'Flush valve / syphon');

    // Overflow standpipe
    final overflowPipeX = cistern.right - 18;
    canvas.drawRect(
      Rect.fromLTWH(overflowPipeX - 4, overflowY, 8, cistern.bottom - overflowY),
      Paint()..color = AppColors.pipeMetal,
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(overflowPipeX - 30, cistern.bottom + 4), 'Overflow standpipe');

    // Lid
    if (!lidLifted) {
      canvas.drawRect(
        Rect.fromLTRB(cistern.left - 4, cistern.top - 8, cistern.right + 4, cistern.top),
        Paint()..color = const Color(0xFFCFD6DD),
      );
      canvas.drawRect(
        Rect.fromLTRB(cistern.left - 4, cistern.top - 8, cistern.right + 4, cistern.top),
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    // Flush handle
    canvas.drawRect(
      Rect.fromLTWH(cistern.left + 8, cistern.top - 4, 28, 6),
      Paint()..color = AppColors.brass,
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(cistern.left, cistern.top - 24), 'Flush handle');

    // Pan
    final panTop = h * 0.62;
    final panRect = Rect.fromLTWH(w * 0.30, panTop, w * 0.36, h * 0.30);
    final panPath = Path()
      ..moveTo(panRect.left, panRect.top)
      ..lineTo(panRect.right, panRect.top)
      ..quadraticBezierTo(
          panRect.right + 10, panRect.top + panRect.height * 0.6,
          panRect.right - 18, panRect.bottom)
      ..lineTo(panRect.left + 18, panRect.bottom)
      ..quadraticBezierTo(panRect.left - 10, panRect.top + panRect.height * 0.6,
          panRect.left, panRect.top)
      ..close();
    canvas.drawPath(panPath, Paint()..color = Colors.white);
    canvas.drawPath(
      panPath,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Pan water
    final panWaterRect = Rect.fromLTRB(panRect.left + 14, panRect.top + 18,
        panRect.right - 14, panRect.top + 36);
    canvas.drawOval(
      panWaterRect,
      Paint()
        ..color = (drippingIntoPan && dyeAdded)
            ? const Color(0xFF2EBF6E).withValues(alpha: 0.65)
            : AppColors.coldWater.withValues(alpha: 0.55),
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(panRect.left, panRect.bottom + 4), 'WC pan');

    // Flush pipe from cistern to pan
    final flushPipeTop = Offset(cistern.center.dx, cistern.bottom);
    final flushPipeBot = Offset(cistern.center.dx, panRect.top);
    PipePainterHelpers.drawPipe(
      canvas,
      a: flushPipeTop,
      b: flushPipeBot,
      color: AppColors.pipeMetal,
      width: 14,
    );

    // Drip from flush valve into pan
    if (drippingIntoPan) {
      for (int i = 0; i < 3; i++) {
        final dy = ((t + i / 3) % 1.0) * (panRect.top - flushPipeTop.dy);
        canvas.drawCircle(
          Offset(flushPipeTop.dx, flushPipeTop.dy + dy + 4),
          2.6,
          Paint()
            ..color = dyeAdded
                ? const Color(0xFF2EBF6E)
                : AppColors.coldWater,
        );
      }
    }

    // Overflow water
    if (overflowing) {
      for (int i = 0; i < 4; i++) {
        final dy = ((t + i / 4) % 1.0) * (h - cistern.bottom);
        canvas.drawCircle(
          Offset(overflowPipeX, cistern.bottom + dy),
          2.4,
          Paint()..color = AppColors.coldWater,
        );
      }
    }

    // Animated incoming particles when float valve open
    if (scenario == WcScenario.floatValve && !fixed) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(cistern.left - 30, coldEntry.dy),
        b: coldEntry,
        progress: t,
        color: Colors.white.withValues(alpha: 0.85),
      );
    }

    // Cycle tested badge
    if (cycleTested && fixed) {
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(w * 0.70, h * 0.06),
        'CYCLE OK',
        background: Colors.green.shade600,
        textColor: Colors.white,
      );
    }

    // Title
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(8, 8),
      'WC cistern — sectional',
      background: AppColors.primary,
      textColor: Colors.white,
    );
  }

  @override
  bool shouldRepaint(_RunningWcPainter o) => true;
}

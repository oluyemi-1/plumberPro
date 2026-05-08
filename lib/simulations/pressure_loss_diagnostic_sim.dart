import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum _PressureScenario {
  hiddenLeak,
  failedExpansion,
  prvPassing,
  dilution,
}

extension on _PressureScenario {
  String get label {
    switch (this) {
      case _PressureScenario.hiddenLeak:
        return 'Hidden leak';
      case _PressureScenario.failedExpansion:
        return 'Failed expansion vessel';
      case _PressureScenario.prvPassing:
        return 'PRV passing';
      case _PressureScenario.dilution:
        return 'Recently topped up';
    }
  }
}

class PressureLossDiagnosticSimScreen extends StatefulWidget {
  const PressureLossDiagnosticSimScreen({super.key});

  @override
  State<PressureLossDiagnosticSimScreen> createState() =>
      _PressureLossDiagnosticSimScreenState();
}

class _PressureLossDiagnosticSimScreenState
    extends State<PressureLossDiagnosticSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _step = 0;
  _PressureScenario _scenario = _PressureScenario.hiddenLeak;
  double _hours = 0.0;
  bool _externalInspected = false;
  bool _internalInspected = false;
  bool _expansionTested = false;
  bool _fixApplied = false;
  String _hint = 'Pick a fault, slide time and inspect.';

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

  // Computes simulated pressure (bar) at a given time (0..72h) given the
  // current scenario.
  double _pressureAt(double hours) {
    if (_fixApplied) return 1.2;
    switch (_scenario) {
      case _PressureScenario.hiddenLeak:
        return (1.3 - hours * 0.012).clamp(0.0, 3.5);
      case _PressureScenario.failedExpansion:
        // Cycles between cold low (0.6) and hot high (2.6) as the system
        // heats up and cools down with no air cushion.
        final cycle = math.sin(hours * 0.4) * 1.0;
        return (1.2 + cycle).clamp(0.0, 3.5);
      case _PressureScenario.prvPassing:
        // Pressure drifts down smoothly because water leaves via PRV.
        return (1.4 - hours * 0.018).clamp(0.0, 3.5);
      case _PressureScenario.dilution:
        // Saw-tooth: customer keeps topping up to 1.5 then it falls.
        final cyc = (hours % 18) / 18;
        return (1.5 - cyc * 0.9).clamp(0.0, 3.5);
    }
  }

  List<SimStep> get _steps {
    switch (_scenario) {
      case _PressureScenario.hiddenLeak:
        return const [
          SimStep(
            title: 'Symptom',
            narration:
                'Customer reports the pressure drops from 1.2 bar to under 0.5 bar over a couple of weeks and they have topped it up three times this month.',
          ),
          SimStep(
            title: 'Question the customer',
            narration:
                'Ask when it last held pressure, whether any work has been done recently and whether anyone has heard dripping or seen water marks on ceilings or floors.',
          ),
          SimStep(
            title: 'Inspect external',
            narration:
                'Check the PRV outside discharge pipe and the tundish if fitted. No drips here, so the leak is internal rather than venting through the safety valve.',
          ),
          SimStep(
            title: 'Inspect internal',
            narration:
                'Run paper towel under every joint and pull each radiator forward. A small damp patch shows up behind the lounge radiator at the TRV tail nut.',
          ),
          SimStep(
            title: 'Test expansion vessel',
            narration:
                'For thoroughness, drop the system pressure and press the Schrader valve on the expansion vessel. Air comes out cleanly so the diaphragm is intact.',
          ),
          SimStep(
            title: 'Confirm fault',
            narration:
                'Diagnosis is a slow weep at the radiator tail. Tightening alone is not always enough; inspect the olive and re-make the joint with fresh PTFE or jointing compound.',
          ),
          SimStep(
            title: 'Repair',
            narration:
                'Isolate the radiator, drain locally, cut back and re-make the compression joint with a new olive. Refit and pressure test before refilling.',
          ),
          SimStep(
            title: 'Test and document',
            narration:
                'Re-pressurise to 1.2 bar cold, run hot to about 2 bar and recheck after 24 to 48 hours. Pressure now holds and the customer is advised to monitor weekly.',
          ),
        ];
      case _PressureScenario.failedExpansion:
        return const [
          SimStep(
            title: 'Symptom',
            narration:
                'Pressure swings dramatically: under 1 bar cold, jumps to nearly 3 bar when hot, sometimes triggering the PRV. The customer hears the boiler discharging.',
          ),
          SimStep(
            title: 'Question the customer',
            narration:
                'Ask whether the boiler is more than five years old and whether anyone has serviced or recharged the expansion vessel recently. Both clues point to a tired vessel.',
          ),
          SimStep(
            title: 'Inspect external',
            narration:
                'Check the PRV outside discharge pipe. There may be evidence of past discharge, like staining or limescale, even when not actively dripping.',
          ),
          SimStep(
            title: 'Inspect internal',
            narration:
                'Joints and radiators look dry. With no visible leaks but cycling pressure, suspect the air cushion in the expansion vessel has been lost.',
          ),
          SimStep(
            title: 'Test expansion vessel',
            narration:
                'Turn off the boiler, drop system pressure to zero, then depress the Schrader valve on the vessel. Water comes out instead of air, confirming a ruptured diaphragm.',
          ),
          SimStep(
            title: 'Confirm fault',
            narration:
                'Failed expansion vessel diaphragm. Without an air cushion, the small expansion of heated water has nowhere to go and the PRV opens at 3 bar.',
          ),
          SimStep(
            title: 'Repair',
            narration:
                'Either re-charge the vessel with a foot pump to 1 bar with the system depressurised, or replace the vessel. Many techs add an external vessel where access is poor.',
          ),
          SimStep(
            title: 'Test and document',
            narration:
                'Refill to 1.0 to 1.2 bar cold, run system to full temperature and confirm pressure rises only to about 2 bar then settles. Note service interval for next visit.',
          ),
        ];
      case _PressureScenario.prvPassing:
        return const [
          SimStep(
            title: 'Symptom',
            narration:
                'Pressure falls smoothly from 1.4 bar over 24 hours and the customer mentions a constant trickle from the outside discharge pipe by the boiler.',
          ),
          SimStep(
            title: 'Question the customer',
            narration:
                'Ask whether anyone has overfilled the system above 2.5 bar or whether the discharge pipe has been wet for a while. PRVs often start passing after over-pressure events.',
          ),
          SimStep(
            title: 'Inspect external',
            narration:
                'Outside discharge pipe is wet with a clear, slow drip even with the system off. The tundish, if fitted, shows water flowing through it.',
          ),
          SimStep(
            title: 'Inspect internal',
            narration:
                'Internal joints and radiators are dry. The leak path is via the safety valve so internal inspection rules out other causes.',
          ),
          SimStep(
            title: 'Test expansion vessel',
            narration:
                'Pressure drop the system and check the Schrader. Air comes out, so the vessel is healthy. With expansion vessel ruled out, the PRV seat is the culprit.',
          ),
          SimStep(
            title: 'Confirm fault',
            narration:
                'PRV passing because debris has lodged on the seat or the seat is worn. Lifting the test cap usually does not reseat it permanently once it has started.',
          ),
          SimStep(
            title: 'Repair',
            narration:
                'Isolate, depressurise and replace the PRV cartridge or the whole valve. Confirm the discharge pipe runs to a safe outside termination per Part G.',
          ),
          SimStep(
            title: 'Test and document',
            narration:
                'Refill to 1.2 bar cold, run hot, confirm gauge rises to about 2 bar but the discharge stays dry. Advise customer to call back if water reappears.',
          ),
        ];
      case _PressureScenario.dilution:
        return const [
          SimStep(
            title: 'Symptom',
            narration:
                'Customer admits topping up the system every few days for months. Inhibitor levels are now diluted, masking what is actually a steady leak.',
          ),
          SimStep(
            title: 'Question the customer',
            narration:
                'Ask exactly how often they top up and to how high. Frequent top-ups always mean water is leaving the system somewhere; refilling does not solve the underlying fault.',
          ),
          SimStep(
            title: 'Inspect external',
            narration:
                'PRV discharge is dry. So the loss is internal. Check carefully for damp patches or staining anywhere a leak could be hidden, including under floors.',
          ),
          SimStep(
            title: 'Inspect internal',
            narration:
                'Walk every radiator, every visible joint and the boiler internal connections. A weeping pump union or a pinhole on a radiator behind furniture is common.',
          ),
          SimStep(
            title: 'Test expansion vessel',
            narration:
                'Frequent re-pressurising can hide a tired expansion vessel. Verify Schrader holds air, and check the inhibitor concentration with a test strip; it will be very low.',
          ),
          SimStep(
            title: 'Confirm fault',
            narration:
                'A small persistent leak combined with dilution. Inhibitor must be re-dosed once the leak is found and fixed, to protect the system from corrosion.',
          ),
          SimStep(
            title: 'Repair',
            narration:
                'Repair the leak source and dose fresh inhibitor to the correct concentration. Advise the customer not to top up repeatedly without investigation.',
          ),
          SimStep(
            title: 'Test and document',
            narration:
                'Re-pressurise to 1.2 bar, hold at temperature and confirm no further loss over 24 to 48 hours. Record inhibitor brand and date on the job record.',
          ),
        ];
    }
  }

  void _doExternalInspect() {
    setState(() {
      _externalInspected = true;
      _hint = _scenario == _PressureScenario.prvPassing
          ? 'PRV discharge is dripping outside.'
          : 'External discharge dry. Look elsewhere.';
    });
  }

  void _doInternalInspect() {
    setState(() {
      _internalInspected = true;
      switch (_scenario) {
        case _PressureScenario.hiddenLeak:
          _hint = 'Damp behind lounge radiator TRV tail.';
          break;
        case _PressureScenario.dilution:
          _hint = 'Pinhole weep on a hidden joint.';
          break;
        case _PressureScenario.failedExpansion:
          _hint = 'No internal leaks visible.';
          break;
        case _PressureScenario.prvPassing:
          _hint = 'No internal leaks visible.';
          break;
      }
    });
  }

  void _doExpansionTest() {
    setState(() {
      _expansionTested = true;
      _hint = _scenario == _PressureScenario.failedExpansion
          ? 'Schrader emits water — diaphragm failed.'
          : 'Schrader emits air — vessel healthy.';
    });
  }

  void _applyFix() {
    setState(() {
      _fixApplied = true;
      _hint = 'Repair complete. Pressure stable at 1.2 bar.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Pressure Loss Diagnostic',
      summary:
          'Sealed system pressure keeps dropping. Step through four causes, '
          'inspect, test the expansion vessel and apply the fix.',
      onStepChanged: (i) => setState(() => _step = i),
      controls: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final s in _PressureScenario.values)
              ChoiceChip(
                label: Text(s.label),
                selected: _scenario == s,
                onSelected: (_) => setState(() {
                  _scenario = s;
                  _externalInspected = false;
                  _internalInspected = false;
                  _expansionTested = false;
                  _fixApplied = false;
                  _hint = 'Scenario: ${s.label}';
                }),
              ),
          ],
        ),
        OutlinedButton(
          onPressed: _doExternalInspect,
          child: const Text('Inspect external'),
        ),
        OutlinedButton(
          onPressed: _doInternalInspect,
          child: const Text('Inspect internal'),
        ),
        OutlinedButton(
          onPressed: _doExpansionTest,
          child: const Text('Test expansion'),
        ),
        ElevatedButton(
          onPressed: _applyFix,
          child: const Text('Apply fix'),
        ),
        SizedBox(
          width: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time elapsed: ${_hours.toStringAsFixed(0)} h',
                style: const TextStyle(fontSize: 12),
              ),
              Slider(
                value: _hours,
                min: 0,
                max: 72,
                divisions: 72,
                label: '${_hours.toStringAsFixed(0)} h',
                onChanged: (v) => setState(() => _hours = v),
              ),
            ],
          ),
        ),
      ],
      steps: _steps,
      diagramBuilder: (context, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return CustomPaint(
              painter: _PressurePainter(
                step: _step,
                t: _ctrl.value,
                scenario: _scenario,
                hours: _hours,
                pressureNow: _pressureAt(_hours),
                pressureSeries: List.generate(
                  29,
                  (i) => _pressureAt(i * (_hours.clamp(1, 72) / 28)),
                ),
                externalInspected: _externalInspected,
                internalInspected: _internalInspected,
                expansionTested: _expansionTested,
                fixApplied: _fixApplied,
                hint: _hint,
              ),
            );
          },
        );
      },
    );
  }
}

class _PressurePainter extends CustomPainter {
  final int step;
  final double t;
  final _PressureScenario scenario;
  final double hours;
  final double pressureNow;
  final List<double> pressureSeries;
  final bool externalInspected;
  final bool internalInspected;
  final bool expansionTested;
  final bool fixApplied;
  final String hint;

  _PressurePainter({
    required this.step,
    required this.t,
    required this.scenario,
    required this.hours,
    required this.pressureNow,
    required this.pressureSeries,
    required this.externalInspected,
    required this.internalInspected,
    required this.expansionTested,
    required this.fixApplied,
    required this.hint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF1F4F8);
    canvas.drawRect(Offset.zero & size, bg);

    _drawTrendGraph(canvas, size);
    _drawBoilerAndExpansion(canvas, size);
    _drawFillingLoop(canvas, size);
    _drawRadiators(canvas, size);
    _drawPipework(canvas, size);
    _drawPrvDischarge(canvas, size);
    _drawGauge(canvas, size);
    _drawDripsIfVisible(canvas, size);
    _drawHintBox(canvas, size);
  }

  void _drawTrendGraph(Canvas canvas, Size size) {
    final box = Rect.fromLTWH(
      size.width * 0.34,
      size.height * 0.04,
      size.width * 0.32,
      size.height * 0.18,
    );
    final body = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rr = RRect.fromRectAndRadius(box, const Radius.circular(6));
    canvas.drawRRect(rr, body);
    canvas.drawRRect(rr, stroke);

    PipePainterHelpers.drawLabel(
      canvas,
      Offset(box.left, box.top - 16),
      '7-day pressure trend',
    );

    // Axes
    final axis = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(box.left + 6, box.top + 6),
      Offset(box.left + 6, box.bottom - 6),
      axis,
    );
    canvas.drawLine(
      Offset(box.left + 6, box.bottom - 6),
      Offset(box.right - 6, box.bottom - 6),
      axis,
    );

    // Reference lines at 1 bar and 2 bar (3 bar = top)
    for (final bar in [1.0, 2.0]) {
      final y = box.bottom - 6 - (box.height - 12) * (bar / 3.0);
      canvas.drawLine(
        Offset(box.left + 6, y),
        Offset(box.right - 6, y),
        Paint()
          ..color = Colors.black12
          ..strokeWidth = 0.8,
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(box.right - 22, y - 6),
        '${bar.toStringAsFixed(0)}b',
        fontSize: 9,
      );
    }

    // Plot
    if (pressureSeries.length >= 2) {
      final path = Path();
      for (int i = 0; i < pressureSeries.length; i++) {
        final x = box.left +
            6 +
            (box.width - 12) * (i / (pressureSeries.length - 1));
        final y = box.bottom -
            6 -
            (box.height - 12) * (pressureSeries[i] / 3.0).clamp(0.0, 1.0);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawBoilerAndExpansion(Canvas canvas, Size size) {
    // Boiler
    final bRect = Rect.fromLTWH(
      size.width * 0.06,
      size.height * 0.28,
      size.width * 0.18,
      size.height * 0.28,
    );
    final body = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bRect, const Radius.circular(8)),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bRect, const Radius.circular(8)),
      stroke,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(bRect.left, bRect.top - 16),
      'Boiler',
    );

    // Expansion vessel cross-section inside the boiler enclosure top-right
    final vRect = Rect.fromLTWH(
      bRect.right - size.width * 0.07,
      bRect.top + 6,
      size.width * 0.06,
      bRect.height * 0.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(vRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFCAD2DA),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(vRect, const Radius.circular(4)),
      stroke,
    );

    // Diaphragm — bulged up if failed
    final failed =
        scenario == _PressureScenario.failedExpansion && !fixApplied;
    final diaphY = failed
        ? vRect.top + vRect.height * 0.18
        : vRect.top + vRect.height * 0.5;
    final diaphragm = Path()
      ..moveTo(vRect.left + 2, diaphY)
      ..quadraticBezierTo(
        vRect.center.dx,
        failed ? diaphY - 14 : diaphY - 6,
        vRect.right - 2,
        diaphY,
      );
    canvas.drawPath(
      diaphragm,
      Paint()
        ..color = failed ? AppColors.accent : AppColors.coldWater
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Water below diaphragm
    canvas.drawRect(
      Rect.fromLTRB(vRect.left + 2, diaphY, vRect.right - 2, vRect.bottom - 2),
      Paint()..color = AppColors.coldWater.withValues(alpha: 0.6),
    );
    // Air above
    canvas.drawRect(
      Rect.fromLTRB(vRect.left + 2, vRect.top + 2, vRect.right - 2, diaphY),
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );

    // Schrader on top
    canvas.drawCircle(
      Offset(vRect.center.dx, vRect.top - 4),
      4,
      Paint()..color = AppColors.brass,
    );
    canvas.drawCircle(
      Offset(vRect.center.dx, vRect.top - 4),
      4,
      stroke,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(vRect.right + 4, vRect.top - 6),
      'Schrader',
      fontSize: 9,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(vRect.right + 4, vRect.center.dy),
      'Diaphragm',
      fontSize: 9,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(vRect.left - 6, vRect.bottom + 4),
      'Expansion vessel',
      fontSize: 9,
    );
  }

  void _drawFillingLoop(Canvas canvas, Size size) {
    final p1 = Offset(size.width * 0.06, size.height * 0.62);
    final p2 = Offset(size.width * 0.18, size.height * 0.62);
    PipePainterHelpers.drawPipe(
      canvas,
      a: p1,
      b: p2,
      color: AppColors.copper,
      width: 6,
    );
    // braided loop hump
    final hump = Path()
      ..moveTo(p1.dx + 16, p1.dy)
      ..quadraticBezierTo(
        (p1.dx + p2.dx) / 2,
        p1.dy - 14,
        p2.dx - 16,
        p2.dy,
      );
    canvas.drawPath(
      hump,
      Paint()
        ..color = AppColors.pipeMetal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    PipePainterHelpers.drawValve(canvas, p1.translate(8, 0), open: false);
    PipePainterHelpers.drawValve(canvas, p2.translate(-8, 0), open: false);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(p1.dx, p1.dy + 14),
      'Filling loop',
      fontSize: 10,
    );
  }

  void _drawRadiators(Canvas canvas, Size size) {
    final y = size.height * 0.74;
    final h = size.height * 0.14;
    final w = size.width * 0.16;
    final positions = [0.30, 0.55, 0.78];
    final names = ['Lounge', 'Kitchen', 'Bedroom'];
    for (int i = 0; i < 3; i++) {
      final left = size.width * positions[i] - w / 2;
      final rect = Rect.fromLTWH(left, y, w, h);
      PipePainterHelpers.drawRadiator(canvas, rect: rect, warmth: 0.7);
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(rect.left, rect.top - 16),
        names[i],
        fontSize: 10,
      );
    }
  }

  void _drawPipework(Canvas canvas, Size size) {
    final flowY = size.height * 0.7;
    final returnY = size.height * 0.92;
    final boilerOut = Offset(size.width * 0.24, flowY);
    final boilerIn = Offset(size.width * 0.24, returnY);
    final endR = Offset(size.width * 0.94, flowY);
    final endRBack = Offset(size.width * 0.94, returnY);

    PipePainterHelpers.drawPipe(
      canvas,
      a: boilerOut,
      b: endR,
      color: AppColors.hotWater,
      width: 7,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: endRBack,
      b: boilerIn,
      color: AppColors.coldWater,
      width: 7,
    );

    // Tee drops to each radiator
    for (final px in [0.30, 0.55, 0.78]) {
      final x = size.width * px;
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(x, flowY),
        b: Offset(x, flowY + 24),
        color: AppColors.hotWater,
        width: 5,
      );
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(x, returnY),
        b: Offset(x, returnY - 24),
        color: AppColors.coldWater,
        width: 5,
      );
      PipePainterHelpers.drawJoint(canvas, Offset(x, flowY));
      PipePainterHelpers.drawJoint(canvas, Offset(x, returnY));
    }

    if (!fixApplied) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: boilerOut,
        b: endR,
        progress: t,
        color: Colors.white,
        count: 8,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: endRBack,
        b: boilerIn,
        progress: t,
        color: Colors.white,
        count: 8,
      );
    } else {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: boilerOut,
        b: endR,
        progress: t,
        color: Colors.white,
        count: 6,
      );
    }

    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boilerOut.dx + 6, flowY - 16),
      'Flow',
      background: AppColors.hotWater,
      textColor: Colors.white,
      fontSize: 9,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boilerIn.dx + 6, returnY + 4),
      'Return',
      background: AppColors.coldWater,
      textColor: Colors.white,
      fontSize: 9,
    );
  }

  void _drawPrvDischarge(Canvas canvas, Size size) {
    final start = Offset(size.width * 0.22, size.height * 0.30);
    final exit = Offset(size.width * 0.04, size.height * 0.30);
    final down = Offset(size.width * 0.04, size.height * 0.55);
    PipePainterHelpers.drawPipe(
      canvas,
      a: start,
      b: exit,
      color: AppColors.copper,
      width: 5,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: exit,
      b: down,
      color: AppColors.copper,
      width: 5,
    );

    // Tundish
    final tRect =
        Rect.fromCenter(center: Offset(exit.dx, exit.dy + 14), width: 14, height: 12);
    canvas.drawRect(
      tRect,
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      tRect,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    PipePainterHelpers.drawLabel(
      canvas,
      Offset(start.dx - 2, start.dy - 16),
      'PRV (3 bar)',
      fontSize: 9,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tRect.right + 4, tRect.top),
      'Tundish',
      fontSize: 9,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(down.dx + 6, down.dy + 2),
      'Outside termination',
      fontSize: 9,
    );

    // Brick wall hint at termination
    canvas.drawRect(
      Rect.fromLTWH(0, down.dy, size.width * 0.04, 16),
      Paint()..color = const Color(0xFFD7B58E),
    );
  }

  void _drawGauge(Canvas canvas, Size size) {
    final centre = Offset(size.width * 0.74, size.height * 0.18);
    final r = 32.0;
    final body = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(centre, r, body);
    canvas.drawCircle(centre, r, stroke);

    // Coloured arc — green 1..2 bar, red 0..1 and 2..3.
    void arc(double startBar, double endBar, Color colour) {
      final startA = math.pi * 0.85 + (math.pi * 1.3) * (startBar / 3.0);
      final sweep = (math.pi * 1.3) * ((endBar - startBar) / 3.0);
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: r - 4),
        startA,
        sweep,
        false,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }

    arc(0, 1, AppColors.accent);
    arc(1, 2, const Color(0xFF1B6E3A));
    arc(2, 3, AppColors.accent);

    for (int i = 0; i <= 6; i++) {
      final ang = math.pi * 0.85 + (math.pi * 1.3) * (i / 6);
      final inner = centre + Offset(math.cos(ang), math.sin(ang)) * (r - 8);
      final outer = centre + Offset(math.cos(ang), math.sin(ang)) * (r - 1);
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.1,
      );
    }
    final needleAng =
        math.pi * 0.85 + (math.pi * 1.3) * (pressureNow / 3.0).clamp(0.0, 1.0);
    final tip = centre +
        Offset(math.cos(needleAng), math.sin(needleAng)) * (r - 6);
    canvas.drawLine(
      centre,
      tip,
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(centre, 3, Paint()..color = Colors.black);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(centre.dx - 22, centre.dy + r + 4),
      '${pressureNow.toStringAsFixed(2)} bar',
      fontSize: 10,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(centre.dx - 30, centre.dy - r - 18),
      'System gauge',
      fontSize: 10,
    );
  }

  void _drawDripsIfVisible(Canvas canvas, Size size) {
    if (fixApplied) return;
    Offset? dripPoint;
    String? dripLabel;
    switch (scenario) {
      case _PressureScenario.prvPassing:
        if (externalInspected || step >= 2) {
          dripPoint = Offset(size.width * 0.04, size.height * 0.6);
          dripLabel = 'PRV drip';
        }
        break;
      case _PressureScenario.hiddenLeak:
        if (internalInspected || step >= 3) {
          dripPoint = Offset(size.width * 0.30, size.height * 0.86);
          dripLabel = 'TRV tail weep';
        }
        break;
      case _PressureScenario.failedExpansion:
        if (expansionTested || step >= 4) {
          dripPoint = Offset(size.width * 0.22, size.height * 0.36);
          dripLabel = 'Schrader water';
        }
        break;
      case _PressureScenario.dilution:
        if (internalInspected || step >= 3) {
          dripPoint = Offset(size.width * 0.55, size.height * 0.86);
          dripLabel = 'Hidden weep';
        }
        break;
    }
    if (dripPoint != null) {
      // Animated falling drop
      final yOff = (t * 14) % 14;
      canvas.drawCircle(
        dripPoint.translate(0, yOff),
        3,
        Paint()..color = AppColors.coldWater,
      );
      canvas.drawCircle(
        dripPoint.translate(0, yOff + 6),
        2,
        Paint()..color = AppColors.coldWater.withValues(alpha: 0.6),
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(dripPoint.dx + 6, dripPoint.dy - 4),
        dripLabel!,
        background: AppColors.accent,
        textColor: Colors.white,
        fontSize: 9,
      );
    }
  }

  void _drawHintBox(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: hint,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: size.width * 0.6);
    final box = Rect.fromLTWH(
      size.width * 0.36,
      size.height * 0.94,
      tp.width + 14,
      tp.height + 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(8)),
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(8)),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    tp.paint(canvas, Offset(box.left + 7, box.top + 4));
  }

  @override
  bool shouldRepaint(_PressurePainter o) => true;
}

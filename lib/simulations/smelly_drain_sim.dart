import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum SmellScenario {
  driedTrap,
  aavFailed,
  missingVent,
  crackedJoint,
}

class SmellyDrainSimScreen extends StatefulWidget {
  const SmellyDrainSimScreen({super.key});
  @override
  State<SmellyDrainSimScreen> createState() => _SmellyDrainSimScreenState();
}

class _SmellyDrainSimScreenState extends State<SmellyDrainSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  SmellScenario _scenario = SmellScenario.driedTrap;
  bool _trapToppedUp = false;
  bool _aavReplaced = false;
  bool _smokeTest = false;
  bool _jointRepaired = false;
  bool _runTaps = false;

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
      case SmellScenario.driedTrap:
        return _trapToppedUp;
      case SmellScenario.aavFailed:
        return _aavReplaced;
      case SmellScenario.missingVent:
        return _runTaps && _trapToppedUp; // mitigated by re-establishing seal
      case SmellScenario.crackedJoint:
        return _jointRepaired;
    }
  }

  String get _scenarioLabel {
    switch (_scenario) {
      case SmellScenario.driedTrap:
        return 'Dried-out trap';
      case SmellScenario.aavFailed:
        return 'AAV stuck open';
      case SmellScenario.missingVent:
        return 'Missing vent';
      case SmellScenario.crackedJoint:
        return 'Cracked joint';
    }
  }

  List<SimStep> get _steps => [
        const SimStep(
          title: '1. Symptom — bad smell',
          narration:
              'Customer reports a sewage or rotten-egg smell, often blames the drains. Your job is to localise foul air ingress; the actual drain is usually fine and the seal in the building is the issue.',
        ),
        const SimStep(
          title: '2. Check every visible trap',
          narration:
              'Walk every basin, sink, shower and floor gully. Pour a litre into any rarely used trap to re-form the seal. This single action solves a high proportion of smell calls.',
        ),
        const SimStep(
          title: '3. Smoke or peppermint test',
          narration:
              'For stubborn smells, introduce smoke or peppermint oil into the system above all traps and walk the building. The smell will appear at the breach point first.',
        ),
        const SimStep(
          title: '4. AAV diagnosis',
          narration:
              'Listen at any air admittance valve when an upstream appliance discharges. A working AAV opens silently and reseats; a failed one hisses, smells, or is visibly stuck.',
        ),
        const SimStep(
          title: '5. Vent stack check',
          narration:
              'On the roof, check the soil vent terminal for birds nests, frost cap loss or capping by a previous trade. A blocked vent draws traps dry by siphonage on big flushes.',
        ),
        SimStep(
          title: '6. Repair: $_scenarioLabel',
          narration: _fixNarration(),
        ),
        const SimStep(
          title: '7. Run all appliances',
          narration:
              'After repairs, run every appliance in turn and confirm seals re-form. A peppermint or smoke retest is the gold standard before signing the job off.',
        ),
        const SimStep(
          title: '8. Customer education',
          narration:
              'Advise the customer to run little-used taps weekly, especially in holiday lets and second bathrooms. Trap evaporation is the single most common smell cause and it is free to prevent.',
        ),
      ];

  String _fixNarration() {
    switch (_scenario) {
      case SmellScenario.driedTrap:
        return 'Pour a litre of water through the dried trap to re-seal it. Recommend a bi-weekly run of any appliance that goes unused, especially en-suites.';
      case SmellScenario.aavFailed:
        return 'Unscrew the AAV from its boss and fit a new BS EN 12380 unit the right way up. Most have a captive seal — never use jointing compound.';
      case SmellScenario.missingVent:
        return 'Where the soil stack ends inside the loft or has been blanked, fit a properly sized vent or a code compliant AAV. Otherwise traps will siphon dry on every big flush.';
      case SmellScenario.crackedJoint:
        return 'Tighten or remake the joint. On compression, pull apart, fit a new seal and re-tighten by hand plus a quarter turn. On solvent weld, cut out and re-make to the manufacturer cure time.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Diagnose: smelly drain',
      summary:
          'Foul air rarely comes from the drains themselves — it comes from a broken seal inside the building. Step through the four typical causes and the diagnostic actions that prove each one.',
      steps: _steps,
      onStepChanged: (_) => setState(() {}),
      controls: [
        Wrap(spacing: 6, children: [
          for (final s in SmellScenario.values)
            ChoiceChip(
              label: Text(_chipLabel(s)),
              selected: _scenario == s,
              onSelected: (_) => setState(() {
                _scenario = s;
                _trapToppedUp = false;
                _aavReplaced = false;
                _jointRepaired = false;
              }),
            ),
        ]),
        ElevatedButton.icon(
          onPressed: () => setState(() => _trapToppedUp = true),
          icon: const Icon(Icons.water_drop),
          label: const Text('Top up trap'),
        ),
        ElevatedButton.icon(
          onPressed: () => setState(() => _aavReplaced = true),
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Replace AAV'),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _smokeTest = !_smokeTest),
          icon: const Icon(Icons.cloud),
          label: Text(_smokeTest ? 'Stop smoke' : 'Smoke test'),
        ),
        ElevatedButton.icon(
          onPressed: () => setState(() => _jointRepaired = true),
          icon: const Icon(Icons.build),
          label: const Text('Repair joint'),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _runTaps = !_runTaps),
          icon: const Icon(Icons.opacity),
          label: Text(_runTaps ? 'Stop taps' : 'Run taps'),
        ),
      ],
      diagramBuilder: (ctx, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _SmellyDrainPainter(
              step: stepIndex,
              t: _ctrl.value,
              scenario: _scenario,
              trapToppedUp: _trapToppedUp,
              aavReplaced: _aavReplaced,
              smokeTest: _smokeTest,
              jointRepaired: _jointRepaired,
              runTaps: _runTaps,
              fixed: _fixed,
            ),
          ),
        );
      },
    );
  }

  String _chipLabel(SmellScenario s) {
    switch (s) {
      case SmellScenario.driedTrap:
        return 'Dried trap';
      case SmellScenario.aavFailed:
        return 'AAV failed';
      case SmellScenario.missingVent:
        return 'Missing vent';
      case SmellScenario.crackedJoint:
        return 'Cracked joint';
    }
  }
}

class _SmellyDrainPainter extends CustomPainter {
  final int step;
  final double t;
  final SmellScenario scenario;
  final bool trapToppedUp;
  final bool aavReplaced;
  final bool smokeTest;
  final bool jointRepaired;
  final bool runTaps;
  final bool fixed;

  _SmellyDrainPainter({
    required this.step,
    required this.t,
    required this.scenario,
    required this.trapToppedUp,
    required this.aavReplaced,
    required this.smokeTest,
    required this.jointRepaired,
    required this.runTaps,
    required this.fixed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wall background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFF1F4F8),
    );
    // Ceiling line
    canvas.drawLine(Offset(0, h * 0.05), Offset(w, h * 0.05),
        Paint()..color = Colors.black26..strokeWidth = 1);

    // Soil vent stack
    final stackX = w * 0.78;
    final stackTop = Offset(stackX, h * 0.04);
    final stackBottom = Offset(stackX, h * 0.92);
    PipePainterHelpers.drawPipe(
      canvas,
      a: stackTop,
      b: stackBottom,
      color: AppColors.waste,
      width: 18,
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(stackX + 16, h * 0.40), 'Soil stack');

    // Vent terminal (or missing in scenario missingVent)
    if (scenario != SmellScenario.missingVent) {
      canvas.drawCircle(stackTop, 10,
          Paint()..color = AppColors.pipeMetal);
      canvas.drawCircle(
          stackTop,
          10,
          Paint()
            ..color = Colors.black54
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
      PipePainterHelpers.drawLabel(
          canvas, Offset(stackTop.dx + 14, stackTop.dy - 4), 'Vent terminal');
    } else {
      // Capped/missing
      canvas.drawRect(
        Rect.fromCenter(center: stackTop, width: 22, height: 6),
        Paint()..color = AppColors.accent,
      );
      PipePainterHelpers.drawLabel(
          canvas, Offset(stackTop.dx + 14, stackTop.dy - 4), 'Vent capped');
    }

    // Basin with P-trap
    final basinRect = Rect.fromLTWH(w * 0.08, h * 0.30, w * 0.18, h * 0.10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(basinRect, const Radius.circular(8)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(basinRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(basinRect.left, basinRect.top - 18), 'Basin');

    // P-trap below basin
    final trap1Top = Offset(basinRect.center.dx, basinRect.bottom);
    final trapBend = Offset(basinRect.center.dx, basinRect.bottom + 32);
    final trapOut = Offset(basinRect.center.dx + 36, basinRect.bottom + 22);
    PipePainterHelpers.drawPipe(
      canvas, a: trap1Top, b: trapBend, color: AppColors.waste, width: 10);
    PipePainterHelpers.drawPipe(
      canvas, a: trapBend, b: Offset(trap1Top.dx + 36, trapBend.dy),
      color: AppColors.waste, width: 10);
    PipePainterHelpers.drawPipe(
      canvas, a: Offset(trap1Top.dx + 36, trapBend.dy), b: trapOut,
      color: AppColors.waste, width: 10);
    // seal in trap
    final basinSealOk = scenario != SmellScenario.driedTrap || trapToppedUp;
    _drawTrapSeal(canvas, trap1Top, trapBend, basinSealOk);
    PipePainterHelpers.drawLabel(
        canvas, Offset(trap1Top.dx - 14, trapBend.dy + 12), 'P-trap');

    // Branch from basin trap to soil stack
    final branch1End = Offset(stackX, trapOut.dy);
    PipePainterHelpers.drawPipe(
      canvas, a: trapOut, b: branch1End, color: AppColors.waste, width: 12);
    PipePainterHelpers.drawJoint(canvas, branch1End);

    // Seldom-used pan / WC
    final panRect = Rect.fromLTWH(w * 0.08, h * 0.62, w * 0.14, h * 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(panRect, const Radius.circular(10)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(panRect, const Radius.circular(10)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(panRect.left, panRect.top - 18), 'Seldom-used WC');

    // Branch from pan to stack
    final panOut = Offset(panRect.right, panRect.center.dy);
    final panBranchEnd = Offset(stackX, panOut.dy);
    PipePainterHelpers.drawPipe(
      canvas, a: panOut, b: panBranchEnd, color: AppColors.waste, width: 14);

    // Floor gully / shower trap
    final gullyCenter = Offset(w * 0.45, h * 0.78);
    canvas.drawCircle(gullyCenter, 14,
        Paint()..color = AppColors.pipeMetal);
    canvas.drawCircle(
        gullyCenter,
        14,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    canvas.drawCircle(gullyCenter, 8,
        Paint()..color = const Color(0xFF333333));
    PipePainterHelpers.drawLabel(
        canvas, Offset(gullyCenter.dx - 18, gullyCenter.dy + 18), 'Floor gully');
    PipePainterHelpers.drawPipe(
      canvas,
      a: gullyCenter,
      b: Offset(stackX, gullyCenter.dy),
      color: AppColors.waste,
      width: 12,
    );

    // AAV on stub
    final aavStub = Offset(w * 0.30, h * 0.20);
    final stubBranch = Offset(w * 0.30, h * 0.45);
    PipePainterHelpers.drawPipe(
      canvas, a: aavStub, b: stubBranch, color: AppColors.waste, width: 12);
    PipePainterHelpers.drawPipe(
      canvas, a: stubBranch, b: Offset(stackX, stubBranch.dy),
      color: AppColors.waste, width: 12);
    _drawAAV(canvas, aavStub,
        stuckOpen: scenario == SmellScenario.aavFailed && !aavReplaced);
    PipePainterHelpers.drawLabel(
        canvas, Offset(aavStub.dx - 8, aavStub.dy - 30), 'AAV');

    // Cracked joint marker (between basin trap branch and stack)
    final crackPos = branch1End - const Offset(20, 0);
    if (scenario == SmellScenario.crackedJoint && !jointRepaired) {
      // visible drip
      for (int i = 0; i < 3; i++) {
        final dy = ((t + i / 3) % 1.0) * 24;
        canvas.drawCircle(
            Offset(crackPos.dx, crackPos.dy + dy + 4),
            2.4,
            Paint()..color = AppColors.waste.withValues(alpha: 0.8));
      }
      canvas.drawCircle(
        crackPos,
        18,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      PipePainterHelpers.drawLabel(
        canvas, Offset(crackPos.dx - 30, crackPos.dy - 24), 'Cracked joint',
        background: AppColors.accent, textColor: Colors.white,
      );
    }

    // Stink lines from active fault location
    if (!fixed) {
      Offset stinkOrigin;
      switch (scenario) {
        case SmellScenario.driedTrap:
          stinkOrigin = Offset(trap1Top.dx + 18, trapBend.dy);
          break;
        case SmellScenario.aavFailed:
          stinkOrigin = aavStub;
          break;
        case SmellScenario.missingVent:
          stinkOrigin =
              Offset(panRect.center.dx, panRect.top + panRect.height * 0.4);
          break;
        case SmellScenario.crackedJoint:
          stinkOrigin = crackPos;
          break;
      }
      _drawStinkLines(canvas, stinkOrigin);
    }

    // Smoke test smoke from stack top when smokeTest
    if (smokeTest) {
      for (int i = 0; i < 6; i++) {
        final dy = ((t + i / 6) % 1.0) * 60;
        canvas.drawCircle(
          Offset(stackTop.dx + math.sin(t * 4 + i) * 6, stackTop.dy - dy),
          5 + dy * 0.1,
          Paint()..color = Colors.grey.withValues(alpha: 0.4),
        );
      }
    }

    // Run taps -> water through basin trap
    if (runTaps) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: trap1Top,
        b: trapBend,
        progress: t,
        color: AppColors.coldWater,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(trap1Top.dx + 36, trapBend.dy),
        b: trapOut,
        progress: t,
        color: AppColors.coldWater,
      );
    }

    // Title label
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(8, 8),
      'Drainage layout',
      background: AppColors.primary,
      textColor: Colors.white,
    );
  }

  void _drawTrapSeal(Canvas canvas, Offset top, Offset bend, bool sealOk) {
    final left = top.dx - 4;
    final right = top.dx + 4;
    final sealTop = bend.dy - (sealOk ? 14 : 4);
    final sealBot = bend.dy + 4;
    canvas.drawRect(
      Rect.fromLTRB(left, sealTop, right, sealBot),
      Paint()
        ..color = sealOk
            ? AppColors.coldWater.withValues(alpha: 0.7)
            : AppColors.coldWater.withValues(alpha: 0.2),
    );
  }

  void _drawAAV(Canvas canvas, Offset c, {required bool stuckOpen}) {
    final r = 14.0;
    canvas.drawCircle(c, r, Paint()..color = AppColors.pipeMetal);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    // diaphragm cutaway
    final dY = stuckOpen ? -4.0 : 0.0;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(c.dx, c.dy + dY), width: 18, height: 3),
      Paint()
        ..color = stuckOpen ? AppColors.accent : const Color(0xFF333333),
    );
  }

  void _drawStinkLines(Canvas canvas, Offset origin) {
    final paint = Paint()
      ..color = AppColors.gas.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      final phase = (t * 2 * math.pi) + i;
      final path = Path();
      final startY = origin.dy - i * 6;
      path.moveTo(origin.dx + math.sin(phase) * 4, startY);
      for (int s = 1; s <= 6; s++) {
        path.lineTo(
          origin.dx + math.sin(phase + s * 0.6) * 8,
          startY - s * 6,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SmellyDrainPainter o) => true;
}

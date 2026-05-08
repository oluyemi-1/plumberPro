import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum _ColdRadScenario {
  airTop,
  sludgeBottom,
  trvStuck,
  wholeHouseCold,
  wrongWayAround,
  closedLockshield,
}

extension on _ColdRadScenario {
  String get label {
    switch (this) {
      case _ColdRadScenario.airTop:
        return 'Air at top';
      case _ColdRadScenario.sludgeBottom:
        return 'Sludge at bottom';
      case _ColdRadScenario.trvStuck:
        return 'TRV stuck';
      case _ColdRadScenario.wholeHouseCold:
        return 'Whole house cold';
      case _ColdRadScenario.wrongWayAround:
        return 'Wrong way around';
      case _ColdRadScenario.closedLockshield:
        return 'Closed lockshield';
    }
  }
}

class ColdRadiatorDiagnosticSimScreen extends StatefulWidget {
  const ColdRadiatorDiagnosticSimScreen({super.key});

  @override
  State<ColdRadiatorDiagnosticSimScreen> createState() =>
      _ColdRadiatorDiagnosticSimScreenState();
}

class _ColdRadiatorDiagnosticSimScreenState
    extends State<ColdRadiatorDiagnosticSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _step = 0;
  _ColdRadScenario _scenario = _ColdRadScenario.airTop;
  int? _tappedZone; // 0..3 TL, TR, BL, BR
  bool _fixApplied = false;
  String _hint = 'Pick a scenario, then tap a radiator zone to feel it.';

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

  List<SimStep> get _steps {
    switch (_scenario) {
      case _ColdRadScenario.airTop:
        return const [
          SimStep(
            title: 'Customer complaint',
            narration:
                'Customer says the lounge radiator is warm at the bottom but cold across the top. Ask when it last worked, whether anyone has bled radiators recently, and check if the rest of the house is fine.',
          ),
          SimStep(
            title: 'Initial visual check',
            narration:
                'System gauge reads about 1.2 bar cold which is healthy. Programmer is calling for heat and the room stat is set above room temperature, so the heating circuit should be active.',
          ),
          SimStep(
            title: 'Tap-to-feel diagnostic',
            narration:
                'Carefully feel each quadrant. Top-left and top-right are stone cold while bottom-left and bottom-right are hot. That cold band across the top is the classic signature of trapped air.',
          ),
          SimStep(
            title: 'Reading the pattern',
            narration:
                'Hot bottom and cold top means flow is reaching the radiator but air has collected at the highest point and stopped circulation through the upper waterways.',
          ),
          SimStep(
            title: 'Confirmation test',
            narration:
                'With a bleed key on the top right air vent, slowly crack it open. A hiss of air confirms the diagnosis before any water arrives.',
          ),
          SimStep(
            title: 'Fix procedure',
            narration:
                'Hold a cloth under the bleed point and let air escape until a steady bead of water appears, then close. Top up the system back to 1.0 to 1.5 bar cold using the filling loop.',
          ),
          SimStep(
            title: 'Verification',
            narration:
                'Run the heating for ten minutes. Top zones now warm evenly and the radiator reaches design temperature across the full surface. Document the pressure top-up on the job sheet.',
          ),
        ];
      case _ColdRadScenario.sludgeBottom:
        return const [
          SimStep(
            title: 'Customer complaint',
            narration:
                'Customer reports the radiator never feels properly hot and takes forever to warm the room. Ask whether an inhibitor has been dosed in recent years and how old the system is.',
          ),
          SimStep(
            title: 'Initial visual check',
            narration:
                'Gauge sits at 1.2 bar, the boiler is firing and other radiators are working normally. No leaks visible at valves or on the floor.',
          ),
          SimStep(
            title: 'Tap-to-feel diagnostic',
            narration:
                'Top of the radiator is hot but the bottom is cold, particularly at the centre and TRV end. Cold bottom with a hot top is the signature of magnetite sludge sitting in the waterways.',
          ),
          SimStep(
            title: 'Reading the pattern',
            narration:
                'Iron oxide debris settles at the lowest point of the radiator. It blocks the lower channels so flow short-circuits across the top only and the lower mass never warms.',
          ),
          SimStep(
            title: 'Confirmation test',
            narration:
                'A magnet held to the bottom of the radiator clings firmly, confirming ferrous sludge. A test strip on a sample shows inhibitor levels well below the manufacturer minimum.',
          ),
          SimStep(
            title: 'Fix procedure',
            narration:
                'Isolate both valves, drain the radiator, then power flush or hose flush outside until water runs clear. Refit, dose fresh inhibitor and consider fitting a magnetic system filter.',
          ),
          SimStep(
            title: 'Verification',
            narration:
                'Re-pressurise to 1.2 bar and run the system. Bottom of the radiator now warms within a few minutes and inhibitor strip reads in the green band.',
          ),
        ];
      case _ColdRadScenario.trvStuck:
        return const [
          SimStep(
            title: 'Customer complaint',
            narration:
                'One radiator stays completely cold even on full demand, while every other radiator in the house is hot. Ask if the TRV head has been turned recently or knocked.',
          ),
          SimStep(
            title: 'Initial visual check',
            narration:
                'Gauge healthy at 1.2 bar, boiler running, other radiators warming. The TRV head is set on five but the body feels cold to the touch.',
          ),
          SimStep(
            title: 'Tap-to-feel diagnostic',
            narration:
                'All four zones are stone cold even after twenty minutes of system run time. With other radiators hot, a single completely cold radiator points to a valve fault.',
          ),
          SimStep(
            title: 'Reading the pattern',
            narration:
                'Uniform cold means no flow at all. The lockshield is open, so the TRV pin is the prime suspect. Sticking pins are common in summer when valves sit unused.',
          ),
          SimStep(
            title: 'Confirmation test',
            narration:
                'Unscrew the TRV head and inspect the brass pin underneath. The pin is stuck down, holding the valve closed. Tap gently with the back of a screwdriver, it should spring up.',
          ),
          SimStep(
            title: 'Fix procedure',
            narration:
                'Free the pin with gentle pliers and a drop of releasing oil. If it will not free, isolate the lockshield, drain the radiator and replace the TRV head and body cartridge.',
          ),
          SimStep(
            title: 'Verification',
            narration:
                'Refit the head. Within minutes the radiator warms uniformly. Cycle the head from one to five and confirm the pin moves freely each time.',
          ),
        ];
      case _ColdRadScenario.wholeHouseCold:
        return const [
          SimStep(
            title: 'Customer complaint',
            narration:
                'No heating anywhere, hot water may also be off depending on the boiler. Ask when it last worked and whether any error codes are visible on the boiler display.',
          ),
          SimStep(
            title: 'Initial visual check',
            narration:
                'System pressure gauge reads only 0.3 bar, well below the minimum. The boiler shows a low pressure lockout fault and will not fire.',
          ),
          SimStep(
            title: 'Tap-to-feel diagnostic',
            narration:
                'Every radiator is cold including the towel rail. With no flow and a locked out boiler, the diagnostic is system-wide rather than radiator specific.',
          ),
          SimStep(
            title: 'Reading the pattern',
            narration:
                'A whole house cold pattern combined with low gauge pressure points to either water loss from a leak or a recently drained system that was not re-pressurised.',
          ),
          SimStep(
            title: 'Confirmation test',
            narration:
                'Walk the system looking for damp patches, then check the PRV outside discharge for drips. Note whether the loss is rapid or has been gradual over weeks.',
          ),
          SimStep(
            title: 'Fix procedure',
            narration:
                'Open the filling loop and slowly bring pressure to 1.2 bar cold. Watch the gauge for ten minutes to confirm it holds. Reset the boiler lockout per the manufacturer instructions.',
          ),
          SimStep(
            title: 'Verification',
            narration:
                'Boiler fires, all radiators begin to warm. Advise the customer to call back if the gauge drops again as that would indicate an ongoing leak requiring further work.',
          ),
        ];
      case _ColdRadScenario.wrongWayAround:
        return const [
          SimStep(
            title: 'Customer complaint',
            narration:
                'Newly fitted radiator never quite reaches the design temperature and feels lukewarm. Ask who installed it and whether the valves were swapped.',
          ),
          SimStep(
            title: 'Initial visual check',
            narration:
                'Gauge healthy at 1.2 bar, system running. The TRV is fitted on the right, lockshield on the left, opposite to the original installation marks on the wall.',
          ),
          SimStep(
            title: 'Tap-to-feel diagnostic',
            narration:
                'The radiator is warm but uneven, with the lockshield end hotter than the TRV end. The flow is entering the wrong side of the radiator and short-circuiting.',
          ),
          SimStep(
            title: 'Reading the pattern',
            narration:
                'Some modern TRVs are bidirectional but many still need to be on the flow side. Reverse fitting reduces output by up to thirty percent and never reaches design.',
          ),
          SimStep(
            title: 'Confirmation test',
            narration:
                'Check the arrow on the TRV body. The arrow points away from the radiator, confirming the valve is fitted backwards relative to the system flow direction.',
          ),
          SimStep(
            title: 'Fix procedure',
            narration:
                'Isolate, drain the radiator, swap the TRV and lockshield positions or refit a bidirectional TRV the right way around. Refill, vent and balance the lockshield.',
          ),
          SimStep(
            title: 'Verification',
            narration:
                'Radiator now warms evenly across both ends and reaches full output. Re-balance against neighbouring radiators using the lockshield and a clip-on thermometer.',
          ),
        ];
      case _ColdRadScenario.closedLockshield:
        return const [
          SimStep(
            title: 'Customer complaint',
            narration:
                'Single radiator stays cold but the homeowner insists both valves look fully open. Ask whether anyone has been balancing the system or working under floors recently.',
          ),
          SimStep(
            title: 'Initial visual check',
            narration:
                'Gauge healthy, boiler running, other radiators hot. The TRV head is set to five and the lockshield cap is in place looking correct.',
          ),
          SimStep(
            title: 'Tap-to-feel diagnostic',
            narration:
                'All four zones cold. With a working TRV and a hot system, suspect the lockshield is closed even though the cap and decorative cover suggest otherwise.',
          ),
          SimStep(
            title: 'Reading the pattern',
            narration:
                'Cold radiator with no flow despite a known good TRV is the signature of a closed lockshield. The decorative cap can mask a fully wound down spindle underneath.',
          ),
          SimStep(
            title: 'Confirmation test',
            narration:
                'Lift the lockshield cap and try to turn the spindle anticlockwise. If it moves several turns before stopping, it was closed; count the turns so you can re-balance it later.',
          ),
          SimStep(
            title: 'Fix procedure',
            narration:
                'Open the lockshield fully, then close it back to the recorded balance setting, typically a quarter to one turn open for the radiator nearest the boiler.',
          ),
          SimStep(
            title: 'Verification',
            narration:
                'Radiator warms evenly within a few minutes. Re-balance with a clip-on thermometer aiming for an eleven Kelvin drop between flow and return.',
          ),
        ];
    }
  }

  void _onAction(String name) {
    bool correct = false;
    switch (name) {
      case 'Bleed top':
        correct = _scenario == _ColdRadScenario.airTop;
        break;
      case 'Open lockshield':
        correct = _scenario == _ColdRadScenario.closedLockshield;
        break;
      case 'Re-pressurise to 1 bar':
        correct = _scenario == _ColdRadScenario.wholeHouseCold;
        break;
      case 'Replace TRV head':
        correct = _scenario == _ColdRadScenario.trvStuck;
        break;
      case 'Power flush radiator':
        correct = _scenario == _ColdRadScenario.sludgeBottom;
        break;
      case 'Swap valves':
        correct = _scenario == _ColdRadScenario.wrongWayAround;
        break;
    }
    setState(() {
      if (correct) {
        _fixApplied = true;
        _hint = '$name applied — radiator warming evenly.';
      } else {
        _fixApplied = false;
        _hint = 'No effect — try a different action for this fault.';
      }
    });
  }

  // Returns the warmth (0..1) for each of the four zones based on scenario,
  // step progression, and whether the fix has been applied.
  List<double> _zoneWarmth() {
    final progressed = _step >= 2;
    if (_fixApplied) return const [0.95, 0.95, 0.9, 0.9];
    switch (_scenario) {
      case _ColdRadScenario.airTop:
        return progressed
            ? const [0.05, 0.05, 0.85, 0.85]
            : const [0.2, 0.2, 0.5, 0.5];
      case _ColdRadScenario.sludgeBottom:
        return progressed
            ? const [0.85, 0.85, 0.05, 0.1]
            : const [0.5, 0.5, 0.2, 0.2];
      case _ColdRadScenario.trvStuck:
        return const [0.05, 0.05, 0.05, 0.05];
      case _ColdRadScenario.wholeHouseCold:
        return const [0.0, 0.0, 0.0, 0.0];
      case _ColdRadScenario.wrongWayAround:
        return progressed
            ? const [0.4, 0.65, 0.45, 0.7]
            : const [0.3, 0.3, 0.3, 0.3];
      case _ColdRadScenario.closedLockshield:
        return const [0.05, 0.05, 0.05, 0.05];
    }
  }

  double _gaugeBar() {
    if (_scenario == _ColdRadScenario.wholeHouseCold && !_fixApplied) {
      return 0.3;
    }
    return 1.2;
  }

  String _boilerStatus() {
    if (_scenario == _ColdRadScenario.wholeHouseCold && !_fixApplied) {
      return 'LOCKED OUT';
    }
    return 'RUNNING';
  }

  bool _flowActive() {
    if (_scenario == _ColdRadScenario.wholeHouseCold && !_fixApplied) {
      return false;
    }
    if (_scenario == _ColdRadScenario.trvStuck && !_fixApplied) return false;
    if (_scenario == _ColdRadScenario.closedLockshield && !_fixApplied) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Cold Radiator Diagnostic',
      summary:
          'Walk through six classic cold radiator faults. Pick a scenario, '
          'tap zones to feel temperatures, then apply the correct fix.',
      onStepChanged: (i) => setState(() => _step = i),
      controls: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final s in _ColdRadScenario.values)
              ChoiceChip(
                label: Text(s.label),
                selected: _scenario == s,
                onSelected: (_) => setState(() {
                  _scenario = s;
                  _fixApplied = false;
                  _tappedZone = null;
                  _hint = 'Scenario: ${s.label}';
                }),
              ),
          ],
        ),
        OutlinedButton(
          onPressed: () => _onAction('Bleed top'),
          child: const Text('Bleed top'),
        ),
        OutlinedButton(
          onPressed: () => _onAction('Open lockshield'),
          child: const Text('Open lockshield'),
        ),
        OutlinedButton(
          onPressed: () => _onAction('Re-pressurise to 1 bar'),
          child: const Text('Re-pressurise'),
        ),
        OutlinedButton(
          onPressed: () => _onAction('Replace TRV head'),
          child: const Text('Replace TRV head'),
        ),
        OutlinedButton(
          onPressed: () => _onAction('Power flush radiator'),
          child: const Text('Power flush'),
        ),
        OutlinedButton(
          onPressed: () => _onAction('Swap valves'),
          child: const Text('Swap valves'),
        ),
      ],
      steps: _steps,
      diagramBuilder: (context, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return LayoutBuilder(
              builder: (ctx, c) {
                final size = Size(c.maxWidth, c.maxHeight);
                return GestureDetector(
                  onTapDown: (d) {
                    final p = d.localPosition;
                    final z = _hitZone(p, size);
                    if (z != null) {
                      setState(() {
                        _tappedZone = z;
                        _hint = _zoneFeelText(z);
                      });
                    }
                  },
                  child: CustomPaint(
                    size: size,
                    painter: _ColdRadPainter(
                      step: _step,
                      t: _ctrl.value,
                      scenario: _scenario,
                      zoneWarmth: _zoneWarmth(),
                      tappedZone: _tappedZone,
                      gaugeBar: _gaugeBar(),
                      boilerStatus: _boilerStatus(),
                      flowActive: _flowActive(),
                      hint: _hint,
                      fixed: _fixApplied,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Rect _radiatorRect(Size size) {
    final w = size.width * 0.5;
    final h = size.height * 0.36;
    final left = (size.width - w) / 2;
    final top = size.height * 0.28;
    return Rect.fromLTWH(left, top, w, h);
  }

  int? _hitZone(Offset p, Size size) {
    final r = _radiatorRect(size);
    if (!r.contains(p)) return null;
    final left = p.dx < r.center.dx;
    final top = p.dy < r.center.dy;
    if (top && left) return 0;
    if (top && !left) return 1;
    if (!top && left) return 2;
    return 3;
  }

  String _zoneFeelText(int z) {
    final w = _zoneWarmth()[z];
    final names = ['Top-left', 'Top-right', 'Bottom-left', 'Bottom-right'];
    String temp;
    if (w < 0.15) {
      temp = 'cold';
    } else if (w < 0.45) {
      temp = 'lukewarm';
    } else if (w < 0.75) {
      temp = 'warm';
    } else {
      temp = 'hot';
    }
    return '${names[z]} feels $temp';
  }
}

class _ColdRadPainter extends CustomPainter {
  final int step;
  final double t;
  final _ColdRadScenario scenario;
  final List<double> zoneWarmth;
  final int? tappedZone;
  final double gaugeBar;
  final String boilerStatus;
  final bool flowActive;
  final String hint;
  final bool fixed;

  _ColdRadPainter({
    required this.step,
    required this.t,
    required this.scenario,
    required this.zoneWarmth,
    required this.tappedZone,
    required this.gaugeBar,
    required this.boilerStatus,
    required this.flowActive,
    required this.hint,
    required this.fixed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background wall
    final bg = Paint()..color = const Color(0xFFF1F4F8);
    canvas.drawRect(Offset.zero & size, bg);

    // Skirting board line
    final skirt = Paint()..color = const Color(0xFFD7DCE2);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.82, size.width, size.height * 0.04),
      skirt,
    );

    _drawBoiler(canvas, size);
    _drawRadiatorWithZones(canvas, size);
    _drawValvesAndPipes(canvas, size);
    _drawBleedScrew(canvas, size);
    _drawThermometer(canvas, size);
    _drawGauge(canvas, size);
    _drawHintBox(canvas, size);
  }

  void _drawBoiler(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(
      size.width * 0.04,
      size.height * 0.06,
      size.width * 0.16,
      size.height * 0.18,
    );
    final body = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(8));
    canvas.drawRRect(rr, body);
    canvas.drawRRect(rr, stroke);
    // display
    final disp = Rect.fromLTWH(
      r.left + 8,
      r.top + 10,
      r.width - 16,
      r.height * 0.35,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(disp, const Radius.circular(4)),
      Paint()..color = const Color(0xFF0E2230),
    );
    final isLocked = boilerStatus == 'LOCKED OUT';
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(disp.left + 4, disp.top + 6),
      boilerStatus,
      background: isLocked ? AppColors.accent : const Color(0xFF1B6E3A),
      textColor: Colors.white,
      fontSize: 10,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(r.left, r.bottom + 4),
      'Boiler',
    );
  }

  void _drawRadiatorWithZones(Canvas canvas, Size size) {
    final rect = _radiatorRect(size);
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final tl = Rect.fromLTRB(rect.left, rect.top, cx, cy);
    final tr = Rect.fromLTRB(cx, rect.top, rect.right, cy);
    final bl = Rect.fromLTRB(rect.left, cy, cx, rect.bottom);
    final br = Rect.fromLTRB(cx, cy, rect.right, rect.bottom);

    PipePainterHelpers.drawRadiator(canvas, rect: tl, warmth: zoneWarmth[0]);
    PipePainterHelpers.drawRadiator(canvas, rect: tr, warmth: zoneWarmth[1]);
    PipePainterHelpers.drawRadiator(canvas, rect: bl, warmth: zoneWarmth[2]);
    PipePainterHelpers.drawRadiator(canvas, rect: br, warmth: zoneWarmth[3]);

    // Quadrant divider
    final divP = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;
    canvas.drawLine(Offset(cx, rect.top), Offset(cx, rect.bottom), divP);
    canvas.drawLine(Offset(rect.left, cy), Offset(rect.right, cy), divP);

    // Zone labels
    final labels = ['TL', 'TR', 'BL', 'BR'];
    final centres = [tl.center, tr.center, bl.center, br.center];
    for (int i = 0; i < 4; i++) {
      final selected = tappedZone == i;
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(centres[i].dx - 10, centres[i].dy - 8),
        labels[i],
        background: selected ? AppColors.accent : Colors.white,
        textColor: selected ? Colors.white : AppColors.text,
        fontSize: 10,
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(rect.left, rect.top - 18),
      'Radiator (4 thermal zones)',
    );
  }

  Rect _radiatorRect(Size size) {
    final w = size.width * 0.5;
    final h = size.height * 0.36;
    final left = (size.width - w) / 2;
    final top = size.height * 0.28;
    return Rect.fromLTWH(left, top, w, h);
  }

  void _drawValvesAndPipes(Canvas canvas, Size size) {
    final rect = _radiatorRect(size);
    final flowSide = scenario == _ColdRadScenario.wrongWayAround
        ? rect.bottomRight + const Offset(-6, 8)
        : rect.bottomLeft + const Offset(6, 8);
    final returnSide = scenario == _ColdRadScenario.wrongWayAround
        ? rect.bottomLeft + const Offset(6, 8)
        : rect.bottomRight + const Offset(-6, 8);

    final floorY = size.height * 0.84;
    final flowDown = Offset(flowSide.dx, floorY);
    final returnDown = Offset(returnSide.dx, floorY);
    final boilerOut = Offset(size.width * 0.18, floorY);

    PipePainterHelpers.drawPipe(
      canvas,
      a: boilerOut,
      b: flowDown,
      color: AppColors.hotWater,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: flowDown,
      b: flowSide,
      color: AppColors.hotWater,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: returnSide,
      b: returnDown,
      color: AppColors.coldWater,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: returnDown,
      b: Offset(size.width * 0.95, floorY),
      color: AppColors.coldWater,
      width: 8,
    );

    // Flow particles
    if (flowActive) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: boilerOut,
        b: flowDown,
        progress: t,
        color: Colors.white,
        count: 5,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: returnSide,
        b: returnDown,
        progress: t,
        color: Colors.white,
        count: 4,
      );
    }

    // TRV head (bottom-left of radiator)
    final trvPos = scenario == _ColdRadScenario.wrongWayAround
        ? Offset(rect.right + 4, rect.bottom + 8)
        : Offset(rect.left - 4, rect.bottom + 8);
    final lockPos = scenario == _ColdRadScenario.wrongWayAround
        ? Offset(rect.left - 4, rect.bottom + 8)
        : Offset(rect.right + 4, rect.bottom + 8);

    _drawTrvHead(canvas, trvPos);
    _drawLockshield(canvas, lockPos);

    PipePainterHelpers.drawLabel(
      canvas,
      trvPos.translate(-26, 24),
      'TRV head',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      lockPos.translate(-30, 24),
      'Lockshield',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boilerOut.dx + 20, floorY - 22),
      'Flow (red)',
      background: AppColors.hotWater,
      textColor: Colors.white,
      fontSize: 10,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(size.width * 0.7, floorY + 4),
      'Return (blue)',
      background: AppColors.coldWater,
      textColor: Colors.white,
      fontSize: 10,
    );
  }

  void _drawTrvHead(Canvas canvas, Offset p) {
    final stuck = scenario == _ColdRadScenario.trvStuck && !fixed;
    final body = Paint()..color = stuck ? Colors.grey.shade400 : Colors.white;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rect = Rect.fromCenter(center: p, width: 22, height: 26);
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(5));
    canvas.drawRRect(rr, body);
    canvas.drawRRect(rr, stroke);
    final dial = Paint()..color = AppColors.accent;
    canvas.drawCircle(p.translate(0, -3), 4, dial);
  }

  void _drawLockshield(Canvas canvas, Offset p) {
    final closed = scenario == _ColdRadScenario.closedLockshield && !fixed;
    final body = Paint()..color = closed ? Colors.grey.shade400 : Colors.white;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rect = Rect.fromCenter(center: p, width: 18, height: 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      stroke,
    );
    final cap = Paint()..color = AppColors.brass;
    canvas.drawCircle(p, 5, cap);
  }

  void _drawBleedScrew(Canvas canvas, Size size) {
    final rect = _radiatorRect(size);
    final p = Offset(rect.right - 10, rect.top - 4);
    final body = Paint()..color = AppColors.brass;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(p, 5, body);
    canvas.drawCircle(p, 5, stroke);
    canvas.drawLine(
      p.translate(-3, 0),
      p.translate(3, 0),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.5,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(p.dx + 8, p.dy - 10),
      'Bleed screw',
      fontSize: 10,
    );
    // Air bubble animation if scenario is air
    if (scenario == _ColdRadScenario.airTop && !fixed) {
      final bubbleY = rect.top + 10 - (t * 12);
      canvas.drawCircle(
        Offset(rect.right - 18, bubbleY),
        3,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }
  }

  void _drawThermometer(Canvas canvas, Size size) {
    final base = Offset(size.width * 0.86, size.height * 0.32);
    final body = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final rect = Rect.fromCenter(center: base, width: 12, height: 36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      stroke,
    );
    canvas.drawCircle(
      Offset(base.dx, base.dy + 22),
      8,
      Paint()..color = AppColors.hotWater,
    );
    canvas.drawCircle(
      Offset(base.dx, base.dy + 22),
      8,
      stroke,
    );
    final fill = Paint()..color = AppColors.hotWater;
    canvas.drawRect(
      Rect.fromLTRB(
        base.dx - 3,
        base.dy + 6,
        base.dx + 3,
        base.dy + 22,
      ),
      fill,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(base.dx - 30, base.dy - 30),
      'Thermometer',
      fontSize: 10,
    );
  }

  void _drawGauge(Canvas canvas, Size size) {
    final centre = Offset(size.width * 0.12, size.height * 0.78);
    final r = 30.0;
    final body = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawCircle(centre, r, body);
    canvas.drawCircle(centre, r, stroke);

    // Tick marks 0..3 bar
    for (int i = 0; i <= 6; i++) {
      final ang = math.pi * 0.85 + (math.pi * 1.3) * (i / 6);
      final inner = centre + Offset(math.cos(ang), math.sin(ang)) * (r - 6);
      final outer = centre + Offset(math.cos(ang), math.sin(ang)) * (r - 1);
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.2,
      );
    }
    // Needle
    final frac = (gaugeBar / 3.0).clamp(0.0, 1.0);
    final needleAng = math.pi * 0.85 + (math.pi * 1.3) * frac;
    final tip = centre +
        Offset(math.cos(needleAng), math.sin(needleAng)) * (r - 6);
    canvas.drawLine(
      centre,
      tip,
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(centre, 3, Paint()..color = Colors.black);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(centre.dx - 28, centre.dy + r + 4),
      '${gaugeBar.toStringAsFixed(1)} bar',
      fontSize: 10,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(centre.dx - 28, centre.dy - r - 18),
      'Pressure gauge',
      fontSize: 10,
    );
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
    )..layout(maxWidth: size.width * 0.7);
    final box = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.92,
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
  bool shouldRepaint(_ColdRadPainter o) => true;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum FaultCode { f1Pressure, f7Fan, f22DryFire, eaIgnition, a04Condensate, f28FailedIgn }

extension FaultCodeMeta on FaultCode {
  String get code {
    switch (this) {
      case FaultCode.f1Pressure:
        return 'F1 / F75';
      case FaultCode.f7Fan:
        return 'F7';
      case FaultCode.f22DryFire:
        return 'F22 / E118';
      case FaultCode.eaIgnition:
        return 'EA / E1';
      case FaultCode.a04Condensate:
        return 'A04 / F19';
      case FaultCode.f28FailedIgn:
        return 'F28';
    }
  }

  String get title {
    switch (this) {
      case FaultCode.f1Pressure:
        return 'Low water pressure';
      case FaultCode.f7Fan:
        return 'Fan speed fault';
      case FaultCode.f22DryFire:
        return 'Loss of pressure / dry fire';
      case FaultCode.eaIgnition:
        return 'No flame detected';
      case FaultCode.a04Condensate:
        return 'Frozen / blocked condensate';
      case FaultCode.f28FailedIgn:
        return 'Failed ignition (3 attempts)';
    }
  }
}

class BoilerFaultCodesSimScreen extends StatefulWidget {
  const BoilerFaultCodesSimScreen({super.key});
  @override
  State<BoilerFaultCodesSimScreen> createState() =>
      _BoilerFaultCodesSimScreenState();
}

class _BoilerFaultCodesSimScreenState extends State<BoilerFaultCodesSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _step = 0;
  FaultCode _active = FaultCode.f1Pressure;
  bool _acknowledged = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<SimStep> _stepsFor(FaultCode f) {
    switch (f) {
      case FaultCode.f1Pressure:
        return const [
          SimStep(
              title: 'Symptom — F1 displayed',
              narration:
                  'Customer reports no heating or hot water. The boiler shows F1 / F75 and the radiators are cold. The display is locked out and the heating circuit will not fire.'),
          SimStep(
              title: 'Read the display and Benchmark log',
              narration:
                  'Note the exact code on the LCD and check the service log. F1 normally points to system pressure below the 0.5 bar low-pressure switch threshold.'),
          SimStep(
              title: 'Likely causes',
              narration:
                  'Slow leak on a radiator valve, weeping PRV, failed expansion vessel pre-charge, or recent bleeding without topping up the system pressure.'),
          SimStep(
              title: 'Diagnostic action — gauge check',
              narration:
                  'The pressure gauge needle sits in the red zone at about 0.3 bar. Check around radiator valves and the discharge pipe for any visible leaks.'),
          SimStep(
              title: 'Fix — repressurise via filling loop',
              narration:
                  'Open both filling-loop valves slowly and watch the gauge climb to 1.0 to 1.5 bar cold. Close both valves and check for leaks at the loop hose.'),
          SimStep(
              title: 'Acknowledge & verify',
              narration:
                  'Press reset on the boiler. The code clears, the pump primes, and the burner fires. Re-check pressure after the system reaches 70°C flow temperature.'),
        ];
      case FaultCode.f7Fan:
        return const [
          SimStep(
              title: 'Symptom — F7 fan fault',
              narration:
                  'The boiler attempts ignition then locks out. Customer hears a brief hum but no firing. The display shows F7 referencing the combustion fan.'),
          SimStep(
              title: 'Confirm fan stall on display',
              narration:
                  'Service mode reports fan target around 4500 rpm but actual reading is below 1000 rpm. The fan is stalled or running erratically.'),
          SimStep(
              title: 'Likely causes',
              narration:
                  'Seized bearing, debris in the impeller, broken fan loom, blocked flue, or a failed PCB fan driver stage. Check the simplest items first.'),
          SimStep(
              title: 'Diagnostic action — fan test',
              narration:
                  'Isolate, drop the fan and rotate by hand. A gritty or noisy spin confirms a bearing fault. Inspect the loom plug and the flue for blockage.'),
          SimStep(
              title: 'Fix — replace the fan assembly',
              narration:
                  'Fit the manufacturer fan kit, torque the screws, and reconnect the plug. Always replace gaskets and check the venturi seating to avoid CO leaks.'),
          SimStep(
              title: 'Acknowledge & verify combustion',
              narration:
                  'Reset and run a flue gas analysis. Fan should ramp smoothly to target rpm and CO2 should sit within the manufacturer band, typically 8.7 to 9.2 percent.'),
        ];
      case FaultCode.f22DryFire:
        return const [
          SimStep(
              title: 'Symptom — F22 / E118',
              narration:
                  'The boiler will not fire and the display warns of dry-fire risk. This indicates loss of system pressure to a level the boiler refuses to ignite at.'),
          SimStep(
              title: 'Read the gauge and history',
              narration:
                  'Pressure reads 0.0 bar. The fault history shows multiple low-pressure events, suggesting a leak rather than a single bleed event.'),
          SimStep(
              title: 'Likely causes',
              narration:
                  'Hidden leak under floor, failed automatic air vent, perforated heat exchanger, or PRV passing water to the discharge pipe.'),
          SimStep(
              title: 'Diagnostic action — leak hunt',
              narration:
                  'Check the external PRV tundish for drips and test by isolating zones. A pressure-drop test over an hour with the boiler off will localise the leak.'),
          SimStep(
              title: 'Fix — repair leak and refill',
              narration:
                  'Repair the offending fitting, refill to 1.2 bar, vent radiators top down, and check that the expansion vessel pre-charge is at 1.0 bar with system drained.'),
          SimStep(
              title: 'Acknowledge & verify',
              narration:
                  'Reset the boiler. The lockout clears. Run for a full heating cycle and confirm pressure stays between 1.0 and 2.0 bar throughout.'),
        ];
      case FaultCode.eaIgnition:
        return const [
          SimStep(
              title: 'Symptom — EA flame loss',
              narration:
                  'You can hear the gas valve click and the spark fire, but no flame is established. The boiler shows EA or E1 ignition fault.'),
          SimStep(
              title: 'Read the lockout history',
              narration:
                  'The display log shows three failed sparks then lockout. The flame current reading sits at zero microamps, confirming no flame signal.'),
          SimStep(
              title: 'Likely causes',
              narration:
                  'No gas at the appliance, dirty flame rectification electrode, cracked HT lead, low gas working pressure, or a faulty gas valve.'),
          SimStep(
              title: 'Diagnostic action — electrode inspection',
              narration:
                  'Drop the burner cover. Inspect the spark gap which should be 3 to 4 mm. Check the electrode tip is clean, undamaged and not earthing on the burner.'),
          SimStep(
              title: 'Fix — clean electrode and check gas pressure',
              narration:
                  'Lightly clean the rod with abrasive cloth, refit, and verify the working pressure is around 19 to 21 mbar at the inlet test point.'),
          SimStep(
              title: 'Acknowledge & verify flame',
              narration:
                  'Reset. The boiler re-attempts ignition, the flame establishes, and flame current rises to 3 to 6 microamps which is healthy.'),
        ];
      case FaultCode.a04Condensate:
        return const [
          SimStep(
              title: 'Symptom — A04 condensate',
              narration:
                  'The boiler locks out in cold weather. Customer says it stopped overnight after a frost. Display indicates a condensate trap or pipe blockage.'),
          SimStep(
              title: 'Read code and outside conditions',
              narration:
                  'Note A04 or F19. Step outside and check the condensate pipe for ice or a frosted external section, especially if it is 21.5 mm.'),
          SimStep(
              title: 'Likely causes',
              narration:
                  'Frozen external condensate pipe, blocked siphon trap, pipe with insufficient fall, or termination iced over by drain splashback.'),
          SimStep(
              title: 'Diagnostic action — trap and pipe',
              narration:
                  'Tap along the pipe to find the iced section. Listen at the trap for gurgle. The condensate trap should not gurgle or feel solidly blocked.'),
          SimStep(
              title: 'Fix — thaw and clear',
              narration:
                  'Apply warm cloths or pour warm — never boiling — water along the pipe. Remove and flush the internal trap. Dry-fit and refill to the correct level.'),
          SimStep(
              title: 'Acknowledge & insulate',
              narration:
                  'Reset. The lockout clears and the boiler fires. Lag the external pipe with weatherproof foam and consider increasing it to 32 mm.'),
        ];
      case FaultCode.f28FailedIgn:
        return const [
          SimStep(
              title: 'Symptom — F28 repeating',
              narration:
                  'The boiler shows F28 after three failed ignition attempts. The screen shows three crosses where ticks should be. Customer hears repeated clicking.'),
          SimStep(
              title: 'Read the attempt counter',
              narration:
                  'Service mode shows attempts 1, 2 and 3 all failed. This is a hard lockout requiring manual reset before another attempt.'),
          SimStep(
              title: 'Likely causes',
              narration:
                  'Closed gas isolation valve, air locked in the gas supply, failed gas valve coil, faulty PCB ignition driver or polarity reversed at the supply.'),
          SimStep(
              title: 'Diagnostic action — gas and polarity',
              narration:
                  'Check the gas isolation valve is fully open, test for live and neutral polarity at the boiler, and verify the earth continuity at the case stud.'),
          SimStep(
              title: 'Fix — purge gas and test',
              narration:
                  'Purge any air through a hob burner, confirm 19 to 21 mbar working pressure, and replace the gas valve only if proved faulty by manufacturer steps.'),
          SimStep(
              title: 'Acknowledge & verify',
              narration:
                  'Reset. The first ignition attempt succeeds and the display shows three ticks. Run an FGA and complete the Benchmark service record.'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _stepsFor(_active);
    return SimScaffold(
      key: ValueKey(_active),
      title: 'Boiler fault codes diagnoser',
      summary:
          'Pick a fault code chip to load its symptoms, causes and fix. Each chip swaps the step list. Tap Acknowledge & reset on the fix step to clear the boiler.',
      diagramBuilder: (ctx, idx) {
        _step = idx;
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _BoilerFaultPainter(
              step: idx,
              t: _ctrl.value,
              fault: _active,
              acknowledged: _acknowledged && idx >= steps.length - 1,
            ),
          ),
        );
      },
      steps: steps,
      onStepChanged: (i) {
        setState(() => _step = i);
      },
      controls: [
        for (final f in FaultCode.values)
          ChoiceChip(
            label: Text(f.code, style: const TextStyle(fontSize: 11)),
            selected: _active == f,
            onSelected: (_) => setState(() {
              _active = f;
              _acknowledged = false;
              _step = 0;
            }),
          ),
        ElevatedButton.icon(
          icon: const Icon(Icons.restart_alt, size: 18),
          label: const Text('Acknowledge & reset'),
          onPressed: _step >= steps.length - 2
              ? () => setState(() => _acknowledged = true)
              : null,
        ),
      ],
    );
  }
}

class _BoilerFaultPainter extends CustomPainter {
  final int step;
  final double t;
  final FaultCode fault;
  final bool acknowledged;
  _BoilerFaultPainter(
      {required this.step,
      required this.t,
      required this.fault,
      required this.acknowledged});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Wall
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFEFE7D6));
    // Boiler casing
    final boilerRect = Rect.fromLTWH(w * 0.18, h * 0.10, w * 0.64, h * 0.62);
    canvas.drawRRect(
        RRect.fromRectAndRadius(boilerRect, const Radius.circular(14)),
        Paint()..color = const Color(0xFFE9EEF3));
    canvas.drawRRect(
        RRect.fromRectAndRadius(boilerRect, const Radius.circular(14)),
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);

    // LCD display
    final lcdRect = Rect.fromLTWH(
        boilerRect.left + boilerRect.width * 0.28,
        boilerRect.top + 18,
        boilerRect.width * 0.44,
        46);
    canvas.drawRRect(
        RRect.fromRectAndRadius(lcdRect, const Radius.circular(6)),
        Paint()..color = acknowledged ? const Color(0xFF18324A) : const Color(0xFF0B1F33));
    final showCode = acknowledged ? 'OK' : fault.code;
    final codeColor = acknowledged ? Colors.greenAccent : Colors.redAccent;
    final tp = TextPainter(
      text: TextSpan(
          text: showCode,
          style: TextStyle(
              color: codeColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas,
        Offset(lcdRect.center.dx - tp.width / 2,
            lcdRect.center.dy - tp.height / 2));
    PipePainterHelpers.drawLabel(canvas,
        Offset(lcdRect.left, lcdRect.top - 16), 'LCD display');

    // Pressure gauge (left)
    final gaugeC = Offset(boilerRect.left + 50, boilerRect.top + 110);
    _drawPressureGauge(canvas, gaugeC, fault == FaultCode.f1Pressure ? 0.3 : (fault == FaultCode.f22DryFire ? 0.0 : 1.2));
    PipePainterHelpers.drawLabel(
        canvas, Offset(gaugeC.dx - 36, gaugeC.dy + 38), 'Pressure gauge');

    // Fan (top right of internals)
    final fanC = Offset(boilerRect.right - 60, boilerRect.top + 110);
    _drawFan(canvas, fanC, fault == FaultCode.f7Fan);
    PipePainterHelpers.drawLabel(
        canvas, Offset(fanC.dx - 18, fanC.dy + 36), 'Fan');

    // PCB
    final pcbRect = Rect.fromLTWH(
        boilerRect.left + 30, boilerRect.bottom - 90, 90, 50);
    canvas.drawRRect(
        RRect.fromRectAndRadius(pcbRect, const Radius.circular(4)),
        Paint()..color = const Color(0xFF1F6B3A));
    for (int i = 0; i < 6; i++) {
      canvas.drawCircle(Offset(pcbRect.left + 10 + i * 12, pcbRect.center.dy),
          2.5, Paint()..color = Colors.amber);
    }
    PipePainterHelpers.drawLabel(
        canvas, Offset(pcbRect.left, pcbRect.bottom + 4), 'PCB');

    // Burner & electrode
    final burnerRect = Rect.fromLTWH(
        boilerRect.center.dx - 50, boilerRect.bottom - 80, 100, 28);
    canvas.drawRRect(
        RRect.fromRectAndRadius(burnerRect, const Radius.circular(4)),
        Paint()..color = AppColors.pipeMetal);
    // electrode tip
    final elec = Offset(burnerRect.left + 14, burnerRect.top - 8);
    canvas.drawLine(
        elec,
        Offset(elec.dx, burnerRect.top + 4),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 2);
    if (fault == FaultCode.eaIgnition || fault == FaultCode.f28FailedIgn) {
      // no spark / red dot
      canvas.drawCircle(Offset(elec.dx, burnerRect.top + 2), 3,
          Paint()..color = Colors.redAccent);
    } else if (!acknowledged) {
      // healthy spark
      final spark = Paint()..color = Colors.yellowAccent.withValues(alpha: 0.5 + 0.4 * math.sin(t * math.pi * 4));
      canvas.drawCircle(Offset(elec.dx, burnerRect.top + 2), 4, spark);
    }
    // Flame
    if (acknowledged) {
      final flameP = Paint()..color = Colors.deepOrange.withValues(alpha: 0.8);
      final path = Path()
        ..moveTo(burnerRect.left + 10, burnerRect.top)
        ..relativeQuadraticBezierTo(20, -20, 40, 0)
        ..relativeQuadraticBezierTo(20, -20, 40, 0)
        ..lineTo(burnerRect.right - 10, burnerRect.top)
        ..close();
      canvas.drawPath(path, flameP);
    }
    PipePainterHelpers.drawLabel(canvas,
        Offset(burnerRect.left, burnerRect.bottom + 4), 'Burner');
    PipePainterHelpers.drawLabel(
        canvas, Offset(elec.dx + 8, elec.dy - 6), 'Electrode');

    // Condensate trap (bottom right)
    final trapC = Offset(boilerRect.right - 70, boilerRect.bottom - 30);
    _drawTrap(canvas, trapC, frozen: fault == FaultCode.a04Condensate);
    PipePainterHelpers.drawLabel(
        canvas, Offset(trapC.dx - 24, trapC.dy + 26), 'Condensate trap');

    // Status banner
    String banner;
    Color bannerColor;
    if (acknowledged) {
      banner = 'RUNNING';
      bannerColor = Colors.green.shade600;
    } else if (step >= 4) {
      banner = 'WAITING';
      bannerColor = Colors.amber.shade700;
    } else {
      banner = 'LOCKED OUT';
      bannerColor = Colors.red.shade600;
    }
    final bannerRect = Rect.fromLTWH(
        boilerRect.left, boilerRect.bottom + 14, boilerRect.width, 32);
    canvas.drawRRect(
        RRect.fromRectAndRadius(bannerRect, const Radius.circular(6)),
        Paint()..color = bannerColor);
    final bp = TextPainter(
        text: TextSpan(
            text: '$banner — ${fault.title}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr)
      ..layout();
    bp.paint(
        canvas,
        Offset(bannerRect.center.dx - bp.width / 2,
            bannerRect.center.dy - bp.height / 2));

    // Pulsing indicator near the suspected component
    if (!acknowledged) {
      Offset target;
      switch (fault) {
        case FaultCode.f1Pressure:
        case FaultCode.f22DryFire:
          target = gaugeC;
          break;
        case FaultCode.f7Fan:
          target = fanC;
          break;
        case FaultCode.eaIgnition:
        case FaultCode.f28FailedIgn:
          target = elec;
          break;
        case FaultCode.a04Condensate:
          target = trapC;
          break;
      }
      final pulse = 18 + 6 * math.sin(t * math.pi * 2);
      canvas.drawCircle(
          target,
          pulse,
          Paint()
            ..color = Colors.redAccent
                .withValues(alpha: 0.45 - 0.25 * math.sin(t * math.pi * 2))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2);
      PipePainterHelpers.drawLabel(
          canvas, Offset(target.dx - 30, target.dy - 36), 'Suspect',
          background: Colors.redAccent, textColor: Colors.white);
    }

    // F28 attempt indicators
    if (fault == FaultCode.f28FailedIgn) {
      for (int i = 0; i < 3; i++) {
        final p = Offset(lcdRect.left + 10 + i * 16, lcdRect.bottom + 10);
        canvas.drawLine(
            Offset(p.dx - 4, p.dy - 4),
            Offset(p.dx + 4, p.dy + 4),
            Paint()
              ..color = Colors.redAccent
              ..strokeWidth = 2);
        canvas.drawLine(
            Offset(p.dx + 4, p.dy - 4),
            Offset(p.dx - 4, p.dy + 4),
            Paint()
              ..color = Colors.redAccent
              ..strokeWidth = 2);
      }
      PipePainterHelpers.drawLabel(
          canvas, Offset(lcdRect.left + 60, lcdRect.bottom + 4),
          '3 failed ignitions');
    }

    // Title labels
    PipePainterHelpers.drawLabel(
        canvas, Offset(boilerRect.left + 10, boilerRect.top + 6),
        'Wall-mounted boiler');
    PipePainterHelpers.drawLabel(
        canvas, Offset(8, h - 24), 'Diagnoser canvas — tap a chip to load fault');
  }

  void _drawPressureGauge(Canvas canvas, Offset c, double bar) {
    canvas.drawCircle(c, 28, Paint()..color = Colors.white);
    canvas.drawCircle(
        c,
        28,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    // red zone arc 0..0.5 bar
    final arcRect = Rect.fromCircle(center: c, radius: 22);
    canvas.drawArc(
        arcRect,
        math.pi * 0.75,
        math.pi * 0.25,
        false,
        Paint()
          ..color = Colors.redAccent
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke);
    canvas.drawArc(
        arcRect,
        math.pi * 1.0,
        math.pi * 0.5,
        false,
        Paint()
          ..color = Colors.green
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke);
    // needle: 0 at 135°, 4 bar at 45° (sweep = 270° total)
    final ang = math.pi * 0.75 + (bar / 4.0) * math.pi * 1.5;
    final tip = Offset(c.dx + math.cos(ang) * 22, c.dy + math.sin(ang) * 22);
    canvas.drawLine(
        c,
        tip,
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2);
    canvas.drawCircle(c, 3, Paint()..color = Colors.black);
    final tp = TextPainter(
        text: TextSpan(
            text: '${bar.toStringAsFixed(1)} bar',
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy + 10));
  }

  void _drawFan(Canvas canvas, Offset c, bool faulty) {
    canvas.drawCircle(c, 26, Paint()..color = const Color(0xFF2C3640));
    canvas.drawCircle(
        c,
        26,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    final wobble = faulty ? math.sin(t * math.pi * 8) * 0.3 : 0.0;
    final spinSpeed = faulty ? 0.5 : 4.0;
    final base = t * math.pi * 2 * spinSpeed + wobble;
    for (int i = 0; i < 5; i++) {
      final a = base + i * (math.pi * 2 / 5);
      final p1 = Offset(c.dx + math.cos(a) * 6, c.dy + math.sin(a) * 6);
      final p2 = Offset(c.dx + math.cos(a) * 22, c.dy + math.sin(a) * 22);
      canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = Colors.white70
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round);
    }
    canvas.drawCircle(c, 5, Paint()..color = Colors.white);
    if (faulty) {
      PipePainterHelpers.drawLabel(canvas, Offset(c.dx - 14, c.dy - 44),
          'Stalled', background: Colors.red, textColor: Colors.white);
    }
  }

  void _drawTrap(Canvas canvas, Offset c, {required bool frozen}) {
    final rect = Rect.fromCenter(center: c, width: 36, height: 30);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..color = frozen ? const Color(0xFFB7E6F4) : AppColors.waste);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    // U-shape
    final p = Path()
      ..moveTo(rect.left + 8, rect.top - 14)
      ..lineTo(rect.left + 8, rect.top + 4)
      ..quadraticBezierTo(rect.center.dx, rect.bottom + 6,
          rect.right - 8, rect.top + 4)
      ..lineTo(rect.right - 8, rect.top - 14);
    canvas.drawPath(
        p,
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round);
    if (frozen) {
      PipePainterHelpers.drawLabel(canvas, Offset(c.dx - 14, c.dy - 30),
          'ICED', background: Colors.lightBlue, textColor: Colors.white);
    }
  }

  @override
  bool shouldRepaint(_BoilerFaultPainter o) => true;
}

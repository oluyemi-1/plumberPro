import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

/// Practical simulation of an electric boiler firing cycle:
///   - call for heat
///   - pump prove
///   - element staging (1 → 2 → 3 stages)
///   - thermostat satisfaction
///   - cooldown and pump run-on
///   - overheat lockout
///
/// The point is to make visible what is normally hidden inside the
/// enclosure — that there is no flame, no flue, just elements, a
/// contactor and the pump, and that the safety chain depends on the
/// pump being proven before any stage is allowed to close.
class ElectricBoilerSimScreen extends StatefulWidget {
  const ElectricBoilerSimScreen({super.key});

  @override
  State<ElectricBoilerSimScreen> createState() =>
      _ElectricBoilerSimScreenState();
}

class _ElectricBoilerSimScreenState extends State<ElectricBoilerSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _stage = 0; // 0..3 elements firing
  bool _pumpRunning = false;
  bool _flowProved = false;
  bool _overheat = false;
  double _temp = 20; // °C

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
      title: 'Idle — no heat demand',
      narration:
          'The boiler is sealed and pressurised. The display reads standby. The pump is off, no element is energised, and the contactor is open. System water sits at room temperature.',
    ),
    SimStep(
      title: 'Thermostat calls for heat',
      narration:
          'The room thermostat closes its switched-live. The PCB sees the call but does not yet allow any element to fire. First it must energise the pump.',
    ),
    SimStep(
      title: 'Pump runs, flow switch must prove',
      narration:
          'The pump starts. Water flows through the boiler body, past the elements, out to the radiators and back. A small paddle or hall-effect flow switch closes when flow is sensed. Without that proof the contactor is held open.',
    ),
    SimStep(
      title: 'Stage one energises',
      narration:
          'With flow proved, the PCB closes the contactor for the first element. One element is now drawing about thirteen amps from the supply. System temperature begins to climb gently.',
    ),
    SimStep(
      title: 'Stage two — load grows',
      narration:
          'If a single element cannot keep up with demand the PCB stages in a second element. Current draw roughly doubles. This is staging at work — finer output than a single-element boiler could ever provide.',
    ),
    SimStep(
      title: 'Stage three — full output',
      narration:
          'Demand is high — perhaps the cylinder is recovering or several rooms are calling. All three elements are firing. The contactor is loaded at the boiler\'s maximum rating. Flow temperature climbs quickly toward setpoint.',
    ),
    SimStep(
      title: 'Setpoint reached — stages drop out',
      narration:
          'As the flow sensor reads setpoint, the PCB drops stages back to keep temperature steady. Modulating boilers can taper smoothly; staged boilers step down two-three-one-zero as load falls.',
    ),
    SimStep(
      title: 'Thermostat satisfied — cooldown',
      narration:
          'The room thermostat opens. The contactor opens, all elements are off. The pump keeps running for a minute or two to carry residual heat out of the elements and prevent any local boil-and-knock noise.',
    ),
    SimStep(
      title: 'Overheat fault — what locks it out',
      narration:
          'If the pump fails or all TRVs close while a stage is firing, flow stops, heat builds locally and the overheat thermostat opens. The contactor drops out instantly and the display shows an overheat lockout. The pump may keep running to dissipate the trapped heat.',
    ),
    SimStep(
      title: 'What this all means on a service',
      narration:
          'Listen for clean contactor click, watch one full firing cycle, prove the pump runs whenever the boiler calls, confirm flow proof on the display, and verify the overheat thermostat resets only when temperature has dropped. That is what a real annual service of an electric boiler should include.',
    ),
  ];

  void _applyStep(int i) {
    setState(() {
      switch (i) {
        case 0:
          _stage = 0;
          _pumpRunning = false;
          _flowProved = false;
          _overheat = false;
          _temp = 20;
          break;
        case 1:
          _stage = 0;
          _pumpRunning = false;
          _flowProved = false;
          _temp = 20;
          break;
        case 2:
          _stage = 0;
          _pumpRunning = true;
          _flowProved = true;
          _temp = 22;
          break;
        case 3:
          _stage = 1;
          _pumpRunning = true;
          _flowProved = true;
          _temp = 35;
          break;
        case 4:
          _stage = 2;
          _pumpRunning = true;
          _flowProved = true;
          _temp = 50;
          break;
        case 5:
          _stage = 3;
          _pumpRunning = true;
          _flowProved = true;
          _temp = 65;
          break;
        case 6:
          _stage = 1;
          _pumpRunning = true;
          _flowProved = true;
          _temp = 70;
          break;
        case 7:
          _stage = 0;
          _pumpRunning = true;
          _flowProved = true;
          _temp = 55;
          break;
        case 8:
          _stage = 0;
          _pumpRunning = true; // pump may keep running to dissipate
          _flowProved = false;
          _overheat = true;
          _temp = 95;
          break;
        case 9:
          _stage = 1;
          _pumpRunning = true;
          _flowProved = true;
          _overheat = false;
          _temp = 60;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Electric Boiler Cycle',
      summary:
          'Watch how an electric boiler proves flow, stages elements in and out, satisfies the room thermostat, and what an overheat lockout actually looks like. No flame, no flue — just elements, contactor, pump.',
      steps: _steps,
      onStepChanged: _applyStep,
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _ElectricBoilerPainter(
            t: _ctrl.value,
            stage: _stage,
            pumpRunning: _pumpRunning,
            flowProved: _flowProved,
            overheat: _overheat,
            temp: _temp,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ElectricBoilerPainter extends CustomPainter {
  final double t;
  final int stage;
  final bool pumpRunning;
  final bool flowProved;
  final bool overheat;
  final double temp;

  _ElectricBoilerPainter({
    required this.t,
    required this.stage,
    required this.pumpRunning,
    required this.flowProved,
    required this.overheat,
    required this.temp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFF5F8FC),
    );

    // Boiler enclosure — left two thirds.
    final body = Rect.fromLTWH(w * 0.04, h * 0.06, w * 0.6, h * 0.86);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(14)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(14)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(body.left + 8, body.top + 6),
      'ELECTRIC BOILER',
      background: AppColors.primary,
      textColor: Colors.white,
    );

    // Display panel — bottom right of body.
    final display = Rect.fromLTWH(
      body.right - 110,
      body.bottom - 50,
      100,
      36,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(display, const Radius.circular(6)),
      Paint()..color = Colors.black87,
    );
    final displayText = overheat
        ? 'OVERHEAT'
        : (stage == 0 && !pumpRunning ? 'STBY' : '${temp.toInt()}°C');
    final tp = TextPainter(
      text: TextSpan(
        text: displayText,
        style: TextStyle(
          color: overheat ? Colors.redAccent : Colors.greenAccent,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(display.center.dx - tp.width / 2,
        display.center.dy - tp.height / 2));

    // Element bank — three bars stacked vertically.
    final bank = Rect.fromLTWH(
      body.left + body.width * 0.12,
      body.top + body.height * 0.22,
      body.width * 0.62,
      body.height * 0.36,
    );
    _drawElementBank(canvas, bank);

    // Contactor — top right of body.
    final contactor = Rect.fromLTWH(
      body.right - 70,
      body.top + 32,
      54,
      28,
    );
    final contactorOn = stage > 0 && !overheat;
    canvas.drawRRect(
      RRect.fromRectAndRadius(contactor, const Radius.circular(4)),
      Paint()
        ..color = contactorOn ? AppColors.primary : Colors.grey.shade400,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(contactor.left, contactor.top - 14),
      'Contactor',
    );
    // Show closed/open as bar above contactor.
    final cy = contactor.top - 4;
    canvas.drawLine(
      Offset(contactor.left + 6, cy),
      Offset(contactor.right - 6,
          contactorOn ? cy : cy - 10),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2,
    );

    // Pump — bottom left, partly outside boiler envelope to "show" flow.
    final pumpCenter = Offset(body.left + 38, body.bottom - 50);
    final pumpColor =
        pumpRunning ? AppColors.coldWater : Colors.grey.shade400;
    canvas.drawCircle(pumpCenter, 22, Paint()..color = pumpColor);
    canvas.drawCircle(
      pumpCenter,
      22,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // Spinning impeller indication.
    final spin = pumpRunning ? t * math.pi * 4 : 0.0;
    for (int blade = 0; blade < 3; blade++) {
      final a = spin + blade * math.pi * 2 / 3;
      canvas.drawLine(
        pumpCenter,
        Offset(pumpCenter.dx + math.cos(a) * 16,
            pumpCenter.dy + math.sin(a) * 16),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3,
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pumpCenter.dx - 26, pumpCenter.dy + 26),
      'Pump',
    );

    // Flow switch — indicator dot near pump.
    final fsCenter = Offset(pumpCenter.dx + 60, pumpCenter.dy);
    canvas.drawCircle(
      fsCenter,
      7,
      Paint()
        ..color =
            flowProved ? Colors.greenAccent.shade400 : Colors.grey.shade400,
    );
    canvas.drawCircle(
      fsCenter,
      7,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(fsCenter.dx - 24, fsCenter.dy - 22),
      'Flow proved',
    );

    // Mains supply line into the contactor from above.
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(contactor.center.dx, body.top),
      b: Offset(contactor.center.dx, contactor.top),
      color: stage > 0 && !overheat
          ? Colors.amber.shade700
          : Colors.grey.shade400,
      width: 5,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(contactor.center.dx - 30, body.top - 14),
      '230 V supply',
    );

    // Flow & return pipes — exiting right side of body.
    final flowY = body.top + body.height * 0.4;
    final returnY = body.top + body.height * 0.6;
    // Flow (hot) — leaves boiler hot.
    final flowColor = pumpRunning
        ? (stage > 0
            ? AppColors.hotWater
            : AppColors.coldWater)
        : Colors.grey.shade400;
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(body.right, flowY),
      b: Offset(w * 0.95, flowY),
      color: flowColor,
      width: 7,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.85, flowY - 18),
      'Flow',
    );
    // Return (cooler).
    final returnColor =
        pumpRunning ? AppColors.coldWater : Colors.grey.shade400;
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(body.right, returnY),
      b: Offset(w * 0.95, returnY),
      color: returnColor,
      width: 7,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.85, returnY + 8),
      'Return',
    );

    // Animated flow dots when pump running.
    if (pumpRunning) {
      for (var d = 0; d < 4; d++) {
        final p = (t + d / 4) % 1.0;
        final x = body.right + p * (w * 0.95 - body.right);
        canvas.drawCircle(
          Offset(x, flowY),
          3.5,
          Paint()..color = Colors.white,
        );
        final xr = w * 0.95 - p * (w * 0.95 - body.right);
        canvas.drawCircle(
          Offset(xr, returnY),
          3.5,
          Paint()..color = Colors.white,
        );
      }
    }
  }

  void _drawElementBank(Canvas canvas, Rect bank) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(bank, const Radius.circular(8)),
      Paint()..color = const Color(0xFFEFF3FA),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bank, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(bank.left + 4, bank.top + 4),
      'Elements',
    );
    final eh = (bank.height - 24) / 3;
    for (int i = 0; i < 3; i++) {
      final firing = i < stage && !overheat;
      final eRect = Rect.fromLTWH(
        bank.left + 22,
        bank.top + 22 + i * eh,
        bank.width - 36,
        eh - 6,
      );
      final base = firing
          ? Colors.red.shade400
          : (overheat && i < 3 ? Colors.red.shade200 : Colors.grey.shade300);
      canvas.drawRRect(
        RRect.fromRectAndRadius(eRect, const Radius.circular(4)),
        Paint()..color = base,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(eRect, const Radius.circular(4)),
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      // Heat shimmer when firing.
      if (firing) {
        final shimmerOpacity = (0.4 + 0.4 * math.sin(t * math.pi * 4 + i)).clamp(0.0, 1.0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(eRect, const Radius.circular(4)),
          Paint()
            ..color =
                Colors.orange.withValues(alpha: shimmerOpacity * 0.4),
        );
      }
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(eRect.left + 6, eRect.center.dy - 8),
        'Stage ${i + 1}',
        background: firing ? Colors.red.shade700 : Colors.grey.shade600,
        textColor: Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ElectricBoilerPainter old) =>
      old.t != t ||
      old.stage != stage ||
      old.pumpRunning != pumpRunning ||
      old.flowProved != flowProved ||
      old.overheat != overheat ||
      old.temp != temp;
}

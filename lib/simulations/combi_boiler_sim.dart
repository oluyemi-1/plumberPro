import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum _Demand { idle, heating, hotTap }

class CombiBoilerSimScreen extends StatefulWidget {
  const CombiBoilerSimScreen({super.key});

  @override
  State<CombiBoilerSimScreen> createState() => _CombiBoilerSimScreenState();
}

class _CombiBoilerSimScreenState extends State<CombiBoilerSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  _Demand _demand = _Demand.idle;

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
      title: 'Standby',
      narration:
          'With no demand the pump is off, the burner is off, and the diverter valve is parked in the central heating position. The boiler is pressurised and waiting for a signal.',
    ),
    SimStep(
      title: 'Heating call',
      narration:
          'When the room thermostat calls for heat the pump starts, the fan spins up, the gas valve opens, and the burner fires. Hot primary water circulates through the main heat exchanger and out to the radiators.',
    ),
    SimStep(
      title: 'Hot tap opened',
      narration:
          'Open a hot tap and the flow switch on the domestic side senses water moving. The control board overrides the heating circuit and energises the diverter valve, swinging it to the hot water position.',
    ),
    SimStep(
      title: 'DHW heating',
      narration:
          'Primary water now passes through the plate heat exchanger instead of the radiators. Cold mains water on the other side of the plates is heated instantaneously as it flows towards the tap.',
    ),
    SimStep(
      title: 'Both demands — DHW priority',
      narration:
          'Combi boilers always give hot water priority. Even if the heating is calling, opening a tap pauses the heating circuit so all the burner output goes into the plate exchanger until the tap is closed.',
    ),
    SimStep(
      title: 'Tap closed — run on',
      narration:
          'Close the tap and the diverter returns to the heating position. The pump often runs on for a short time to dissipate residual heat from the heat exchanger and protect it from kettling.',
    ),
    SimStep(
      title: 'Safety devices',
      narration:
          'The expansion vessel absorbs water volume as it heats, the pressure relief valve dumps at 3 bar if the vessel fails, and an overheat thermostat shuts the gas if the primary water exceeds safe temperatures.',
    ),
    SimStep(
      title: 'Common faults',
      narration:
          'Typical combi problems include a sticky diverter valve that sends heating water to the tap or vice versa, scale build-up narrowing the plate exchanger channels, and low system pressure locking the boiler out.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Combi Boiler Cycle',
      summary:
          'See how a combination boiler decides between central heating and instantaneous hot water, and what the diverter valve, plate heat exchanger and safety devices are actually doing.',
      steps: _steps,
      controls: [
        SegmentedButton<_Demand>(
          segments: const [
            ButtonSegment(value: _Demand.idle, label: Text('Idle')),
            ButtonSegment(value: _Demand.heating, label: Text('Heating')),
            ButtonSegment(value: _Demand.hotTap, label: Text('Hot tap')),
          ],
          selected: {_demand},
          onSelectionChanged: (s) => setState(() => _demand = s.first),
        ),
      ],
      onStepChanged: (i) {
        setState(() {
          // Auto set demand to match the narrated step.
          switch (i) {
            case 0:
              _demand = _Demand.idle;
              break;
            case 1:
              _demand = _Demand.heating;
              break;
            case 2:
            case 3:
            case 4:
              _demand = _Demand.hotTap;
              break;
            case 5:
              _demand = _Demand.heating;
              break;
            default:
              break;
          }
        });
      },
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _CombiPainter(step: i, t: _ctrl.value, demand: _demand),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _CombiPainter extends CustomPainter {
  final int step;
  final double t;
  final _Demand demand;

  _CombiPainter({required this.step, required this.t, required this.demand});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFF5F8FC),
    );

    // Boiler casing — left half.
    final boiler = Rect.fromLTWH(w * 0.04, h * 0.06, w * 0.48, h * 0.86);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boiler, const Radius.circular(12)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boiler, const Radius.circular(12)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boiler.left + 8, boiler.top + 6),
      'COMBI BOILER',
      background: AppColors.primary,
      textColor: Colors.white,
    );

    // Internal components ---------------------------------------------------
    // Heat exchanger (main) — top area.
    final hx = Rect.fromLTWH(
      boiler.left + boiler.width * 0.18,
      boiler.top + boiler.height * 0.14,
      boiler.width * 0.64,
      boiler.height * 0.24,
    );
    _drawHeatExchanger(canvas, hx);

    // Burner — beneath HX.
    final burner = Rect.fromLTWH(
      hx.left + 12,
      hx.bottom + 6,
      hx.width - 24,
      10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(burner, const Radius.circular(4)),
      Paint()..color = AppColors.muted,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(burner.right + 6, burner.top - 2),
      'Burner',
    );

    final firing = demand != _Demand.idle;
    if (firing) {
      _drawFlames(canvas, burner, t);
    }

    // Gas valve below burner.
    final gasValve = Offset(burner.center.dx, burner.bottom + 26);
    PipePainterHelpers.drawValve(canvas, gasValve, open: firing, size: 11);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gasValve.dx + 14, gasValve.dy - 6),
      'Gas valve',
      background: AppColors.gas,
      textColor: Colors.black87,
    );
    // Gas supply line.
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(gasValve.dx, boiler.bottom),
      b: gasValve,
      color: AppColors.gas,
      width: 10,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gasValve.dx - 44, boiler.bottom - 18),
      'Gas in',
      background: AppColors.gas,
    );

    // Diverter valve — centre of boiler.
    final diverterCentre = Offset(
      boiler.left + boiler.width * 0.32,
      boiler.top + boiler.height * 0.52,
    );
    _drawDiverter(canvas, diverterCentre, demand);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(diverterCentre.dx - 26, diverterCentre.dy + 22),
      'Diverter valve',
    );

    // Plate heat exchanger (DHW) — stack of plates.
    final phx = Rect.fromLTWH(
      boiler.left + boiler.width * 0.6,
      boiler.top + boiler.height * 0.46,
      boiler.width * 0.26,
      boiler.height * 0.2,
    );
    _drawPlateHx(canvas, phx, active: demand == _Demand.hotTap);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(phx.left - 4, phx.top - 18),
      'Plate heat exchanger',
    );

    // Pump — near bottom left of HX.
    final pump = Offset(boiler.left + boiler.width * 0.22,
        boiler.top + boiler.height * 0.68);
    _drawPump(canvas, pump, running: firing);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pump.dx + 16, pump.dy - 6),
      'Pump',
    );

    // Expansion vessel — bottom.
    final evRect = Rect.fromLTWH(
      boiler.left + 10,
      boiler.bottom - 90,
      36,
      60,
    );
    _drawExpansionVessel(canvas, evRect);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(evRect.right + 4, evRect.top + 4),
      'Expansion vessel',
    );

    // Pressure relief valve — little T off pump area.
    final prv = Offset(boiler.left + 20, pump.dy + 18);
    PipePainterHelpers.drawJoint(canvas, prv, color: AppColors.accent);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(prv.dx + 8, prv.dy + 6),
      'PRV',
    );

    // --- Internal primary circuit path ---
    // HX bottom left -> pump -> diverter -> either (heating flow out right)
    //                                           or (plate HX primary side)
    final hxOut = Offset(hx.left + 6, hx.bottom + 2);
    final pumpIn = Offset(pump.dx - 10, pump.dy);
    final pumpOut = Offset(pump.dx + 10, pump.dy);
    final divIn = Offset(diverterCentre.dx - 14, diverterCentre.dy);
    final divHeat = Offset(diverterCentre.dx, diverterCentre.dy - 14);
    final divDhw = Offset(diverterCentre.dx + 14, diverterCentre.dy);
    final heatingFlowOut = Offset(boiler.right - 4, boiler.top + boiler.height * 0.38);
    final heatingReturnIn = Offset(boiler.right - 4, boiler.top + boiler.height * 0.46);
    final hxInRight = Offset(hx.right - 6, hx.bottom + 2);
    final phxPrimTop = Offset(phx.left + 6, phx.top);
    final phxPrimBot = Offset(phx.left + 6, phx.bottom);

    // Primary loop — HX bottom -> down -> pump -> diverter.
    PipePainterHelpers.drawPipe(canvas, a: hxOut,
        b: Offset(hxOut.dx, pumpIn.dy), color: AppColors.hotWater);
    PipePainterHelpers.drawPipe(canvas, a: Offset(hxOut.dx, pumpIn.dy),
        b: pumpIn, color: AppColors.hotWater);
    PipePainterHelpers.drawPipe(canvas, a: pumpOut, b: divIn, color: AppColors.hotWater);

    // Heating branch out of diverter.
    PipePainterHelpers.drawPipe(canvas, a: divHeat,
        b: Offset(divHeat.dx, heatingFlowOut.dy), color: AppColors.hotWater);
    PipePainterHelpers.drawPipe(canvas, a: Offset(divHeat.dx, heatingFlowOut.dy),
        b: heatingFlowOut, color: AppColors.hotWater);
    // Return from radiators back into HX top-right.
    PipePainterHelpers.drawPipe(canvas, a: heatingReturnIn,
        b: Offset(hxInRight.dx, heatingReturnIn.dy), color: AppColors.hotWater.withValues(alpha: 0.65));
    PipePainterHelpers.drawPipe(canvas, a: Offset(hxInRight.dx, heatingReturnIn.dy),
        b: hxInRight, color: AppColors.hotWater.withValues(alpha: 0.65));

    // DHW branch out of diverter to PHX primary side then back to HX top.
    PipePainterHelpers.drawPipe(canvas, a: divDhw,
        b: Offset(phxPrimBot.dx, divDhw.dy), color: AppColors.hotWater);
    PipePainterHelpers.drawPipe(canvas, a: Offset(phxPrimBot.dx, divDhw.dy),
        b: phxPrimBot, color: AppColors.hotWater);
    PipePainterHelpers.drawPipe(canvas, a: phxPrimTop,
        b: Offset(phxPrimTop.dx, hx.bottom + 2), color: AppColors.hotWater);
    PipePainterHelpers.drawPipe(canvas, a: Offset(phxPrimTop.dx, hx.bottom + 2),
        b: Offset(hxInRight.dx - 2, hx.bottom + 2), color: AppColors.hotWater);

    // Flow particles — only along currently active loop.
    if (demand == _Demand.heating) {
      _flowAlong(canvas, [
        hxOut,
        Offset(hxOut.dx, pumpIn.dy),
        pumpIn,
        pumpOut,
        divIn,
        divHeat,
        Offset(divHeat.dx, heatingFlowOut.dy),
        heatingFlowOut,
      ], Colors.white, t);
    } else if (demand == _Demand.hotTap) {
      _flowAlong(canvas, [
        hxOut,
        Offset(hxOut.dx, pumpIn.dy),
        pumpIn,
        pumpOut,
        divIn,
        divDhw,
        Offset(phxPrimBot.dx, divDhw.dy),
        phxPrimBot,
        phxPrimTop,
        Offset(phxPrimTop.dx, hx.bottom + 2),
        Offset(hxInRight.dx - 2, hx.bottom + 2),
        hxInRight,
      ], Colors.white, t);
    }

    // Radiator block on the right (heating side external).
    final radRect = Rect.fromLTWH(w * 0.6, h * 0.16, w * 0.32, h * 0.2);
    final warmth = demand == _Demand.heating ? 0.9 : 0.05;
    PipePainterHelpers.drawRadiator(canvas, rect: radRect, warmth: warmth);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(radRect.left, radRect.top - 18),
      'Radiator circuit',
    );
    // Flow to/from radiator from the boiler outlets.
    PipePainterHelpers.drawPipe(
      canvas,
      a: heatingFlowOut,
      b: Offset(radRect.left, radRect.top + 10),
      color: AppColors.hotWater,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: heatingReturnIn,
      b: Offset(radRect.left, radRect.bottom - 10),
      color: AppColors.hotWater.withValues(alpha: 0.65),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(heatingFlowOut.dx - 38, heatingFlowOut.dy - 16),
      'Flow',
      background: AppColors.hotWater,
      textColor: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(heatingReturnIn.dx - 42, heatingReturnIn.dy + 4),
      'Return',
    );
    if (demand == _Demand.heating) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: heatingFlowOut,
        b: Offset(radRect.left, radRect.top + 10),
        progress: t,
        color: Colors.white,
        count: 5,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(radRect.left, radRect.bottom - 10),
        b: heatingReturnIn,
        progress: t,
        color: Colors.white,
        count: 5,
      );
    }

    // DHW side — cold mains bottom right, hot tap top right.
    final coldMainsIn = Offset(w * 0.97, h * 0.86);
    final coldMainsEntry = Offset(boiler.right - 4, h * 0.78);
    final hotTapOut = Offset(w * 0.97, h * 0.56);
    final hotTapExit = Offset(boiler.right - 4, h * 0.58);
    // Cold mains in.
    PipePainterHelpers.drawPipe(canvas, a: coldMainsIn,
        b: Offset(coldMainsEntry.dx + 40, coldMainsIn.dy), color: AppColors.coldWater);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(coldMainsEntry.dx + 40, coldMainsIn.dy),
        b: Offset(coldMainsEntry.dx + 40, phx.bottom + 6),
        color: AppColors.coldWater);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(coldMainsEntry.dx + 40, phx.bottom + 6),
        b: Offset(phx.right, phx.bottom - 6),
        color: AppColors.coldWater);
    // DHW out to tap.
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(phx.right, phx.top + 6),
        b: Offset(hotTapExit.dx + 40, phx.top + 6),
        color: AppColors.hotWater);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(hotTapExit.dx + 40, phx.top + 6),
        b: Offset(hotTapExit.dx + 40, hotTapOut.dy),
        color: AppColors.hotWater);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(hotTapExit.dx + 40, hotTapOut.dy),
        b: hotTapOut,
        color: AppColors.hotWater);
    // Sink/tap icon.
    _drawTap(canvas, hotTapOut);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(hotTapOut.dx - 46, hotTapOut.dy - 20),
      'Hot tap',
      background: AppColors.hotWater,
      textColor: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(coldMainsIn.dx - 68, coldMainsIn.dy + 6),
      'Cold mains',
      background: AppColors.coldWater,
      textColor: Colors.white,
    );

    if (demand == _Demand.hotTap) {
      _flowAlong(canvas, [
        coldMainsIn,
        Offset(coldMainsEntry.dx + 40, coldMainsIn.dy),
        Offset(coldMainsEntry.dx + 40, phx.bottom + 6),
        Offset(phx.right, phx.bottom - 6),
      ], Colors.white, t);
      _flowAlong(canvas, [
        Offset(phx.right, phx.top + 6),
        Offset(hotTapExit.dx + 40, phx.top + 6),
        Offset(hotTapExit.dx + 40, hotTapOut.dy),
        hotTapOut,
      ], Colors.white, t);
    }

    // Step-specific callouts.
    _stepHighlight(canvas, size, diverterCentre, phx, evRect);

    // Demand badge.
    final demandLabel = switch (demand) {
      _Demand.idle => 'IDLE',
      _Demand.heating => 'HEATING',
      _Demand.hotTap => 'HOT TAP',
    };
    final demandColor = switch (demand) {
      _Demand.idle => AppColors.muted,
      _Demand.heating => AppColors.hotWater,
      _Demand.hotTap => AppColors.accent,
    };
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w - 88, 10),
      'DEMAND: $demandLabel',
      background: demandColor,
      textColor: Colors.white,
    );
  }

  void _flowAlong(Canvas canvas, List<Offset> pts, Color c, double progress) {
    for (int i = 0; i < pts.length - 1; i++) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: pts[i],
        b: pts[i + 1],
        progress: (progress + i * 0.08) % 1.0,
        color: c,
        count: 4,
        radius: 3,
      );
    }
  }

  void _drawHeatExchanger(Canvas canvas, Rect r) {
    final body = Paint()..color = const Color(0xFFE4E8EE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(8)),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Fins.
    final fin = Paint()
      ..color = AppColors.copper
      ..strokeWidth = 2;
    for (double y = r.top + 8; y < r.bottom - 4; y += 6) {
      canvas.drawLine(
        Offset(r.left + 6, y),
        Offset(r.right - 6, y),
        fin,
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(r.left + 4, r.top - 18),
      'Main heat exchanger',
    );
  }

  void _drawPlateHx(Canvas canvas, Rect r, {required bool active}) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()..color = const Color(0xFFD5DAE1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    final plates = 6;
    for (int i = 0; i < plates; i++) {
      final y = r.top + 4 + i * ((r.height - 8) / (plates - 1));
      final c = i.isEven
          ? (active ? AppColors.hotWater : AppColors.muted)
          : (active ? AppColors.coldWater : AppColors.muted.withValues(alpha: 0.5));
      canvas.drawLine(
        Offset(r.left + 3, y),
        Offset(r.right - 3, y),
        Paint()
          ..color = c
          ..strokeWidth = 2.2,
      );
    }
  }

  void _drawPump(Canvas canvas, Offset c, {required bool running}) {
    final body = Paint()..color = AppColors.primary;
    canvas.drawCircle(c, 14, body);
    canvas.drawCircle(
      c,
      14,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Impeller — three blades rotating.
    final angle = running ? t * math.pi * 2 * 3 : 0.0;
    final blade = Paint()..color = Colors.white;
    for (int i = 0; i < 3; i++) {
      final a = angle + i * (math.pi * 2 / 3);
      final p1 = c + Offset(math.cos(a), math.sin(a)) * 10;
      final p2 = c + Offset(math.cos(a + math.pi), math.sin(a + math.pi)) * 3;
      canvas.drawLine(p1, p2, blade..strokeWidth = 3);
    }
  }

  void _drawDiverter(Canvas canvas, Offset c, _Demand d) {
    // Body — square with inlet (left), heating up, dhw right.
    final rect = Rect.fromCenter(center: c, width: 28, height: 28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      Paint()..color = AppColors.brass,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Arrow showing active path.
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final inLeft = Offset(c.dx - 10, c.dy);
    final up = Offset(c.dx, c.dy - 10);
    final right = Offset(c.dx + 10, c.dy);
    if (d == _Demand.hotTap) {
      canvas.drawLine(inLeft, right, p);
    } else {
      canvas.drawLine(inLeft, up, p);
    }
  }

  void _drawExpansionVessel(Canvas canvas, Rect r) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(8)),
      Paint()..color = AppColors.accent,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Diaphragm line.
    canvas.drawLine(
      Offset(r.left + 3, r.center.dy),
      Offset(r.right - 3, r.center.dy),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.2,
    );
  }

  void _drawFlames(Canvas canvas, Rect burner, double t) {
    final rnd = math.Random(2);
    for (double x = burner.left + 6; x < burner.right - 6; x += 10) {
      final h = 14 + math.sin((t * math.pi * 2) + x) * 4 + rnd.nextDouble() * 3;
      final flame = Path()
        ..moveTo(x - 4, burner.top)
        ..quadraticBezierTo(x, burner.top - h * 0.6, x, burner.top - h)
        ..quadraticBezierTo(x, burner.top - h * 0.6, x + 4, burner.top)
        ..close();
      canvas.drawPath(
        flame,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [AppColors.gas, AppColors.accent.withValues(alpha: 0.4)],
          ).createShader(Rect.fromLTWH(x - 4, burner.top - h, 8, h)),
      );
    }
  }

  void _drawTap(Canvas canvas, Offset p) {
    final body = Paint()..color = AppColors.brass;
    final rect = Rect.fromCenter(center: p, width: 18, height: 12);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)), body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      p,
      Offset(p.dx + 10, p.dy + 10),
      Paint()
        ..color = AppColors.brass
        ..strokeWidth = 4,
    );
    // Water droplet when active.
    if (demand == _Demand.hotTap) {
      canvas.drawCircle(
        Offset(p.dx + 10, p.dy + 16 + (t * 8) % 10),
        3,
        Paint()..color = AppColors.hotWater,
      );
    }
  }

  void _stepHighlight(
      Canvas canvas, Size size, Offset diverter, Rect phx, Rect ev) {
    Paint g(Color c) => Paint()
      ..color = c.withValues(alpha: 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    switch (step) {
      case 2:
      case 5:
        canvas.drawCircle(diverter, 30, g(AppColors.accent));
        break;
      case 3:
        canvas.drawRect(phx.inflate(10), g(AppColors.hotWater));
        break;
      case 4:
        canvas.drawRect(phx.inflate(10), g(AppColors.accent));
        break;
      case 6:
        canvas.drawRect(ev.inflate(12), g(AppColors.accent));
        break;
      case 7:
        canvas.drawRect(phx.inflate(10), g(AppColors.gas));
        canvas.drawCircle(diverter, 30, g(AppColors.gas));
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CombiPainter old) => true;
}

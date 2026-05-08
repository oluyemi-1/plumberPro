import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum _DhwMode { heatingOnly, dhwCall, legionella, idle }

class DhwPrioritySimScreen extends StatefulWidget {
  const DhwPrioritySimScreen({super.key});
  @override
  State<DhwPrioritySimScreen> createState() => _DhwPrioritySimScreenState();
}

class _DhwPrioritySimScreenState extends State<DhwPrioritySimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  _DhwMode _mode = _DhwMode.heatingOnly;
  double _dhwSetpoint = 50; // 40..55
  bool _allowInterrupt = false;

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

  String _modeLabel(_DhwMode m) {
    switch (m) {
      case _DhwMode.heatingOnly:
        return 'Heating only';
      case _DhwMode.dhwCall:
        return 'DHW call';
      case _DhwMode.legionella:
        return 'DHW + Legionella';
      case _DhwMode.idle:
        return 'Idle';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'DHW priority on a heat pump',
      summary:
          'Walk through how a heat pump shares its output between space heating and domestic hot water using a priority diverter valve. Switch mode, raise the DHW set point and toggle blended operation to see the effect on radiators and cylinder.',
      onStepChanged: (_) => setState(() {}),
      controls: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final m in _DhwMode.values)
              ChoiceChip(
                label: Text(_modeLabel(m)),
                selected: _mode == m,
                onSelected: (_) => setState(() => _mode = m),
              ),
          ],
        ),
        SizedBox(
          width: 240,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DHW set point: ${_dhwSetpoint.toStringAsFixed(0)} C',
                  style: const TextStyle(fontSize: 12)),
              Slider(
                value: _dhwSetpoint,
                min: 40,
                max: 55,
                divisions: 15,
                label: '${_dhwSetpoint.toStringAsFixed(0)} C',
                onChanged: (v) => setState(() => _dhwSetpoint = v),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Allow heating to interrupt DHW',
                style: TextStyle(fontSize: 12)),
            Switch.adaptive(
              value: _allowInterrupt,
              onChanged: (v) => setState(() => _allowInterrupt = v),
            ),
          ],
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _DhwPriorityPainter(
            step: i,
            t: _ctrl.value,
            mode: _mode,
            setpoint: _dhwSetpoint,
            allowInterrupt: _allowInterrupt,
          ),
          size: Size.infinite,
        ),
      ),
      steps: const [
        SimStep(
          title: 'Why DHW priority?',
          narration:
              'Heat pumps deliver modest power continuously, so reheating a cylinder takes longer than a combi boiler. Priority logic dedicates the full output to DHW to keep recovery times sensible.',
        ),
        SimStep(
          title: 'The diverter valve',
          narration:
              'A motorised three-port valve sits on the heat pump flow. In heating it routes water to the radiators; in DHW it routes the entire flow through the cylinder coil instead.',
        ),
        SimStep(
          title: 'Heating mode',
          narration:
              'With no DHW call, the diverter is parked towards heating. Full bore flow at 45 C reaches the radiators and the cylinder coil is bypassed entirely.',
        ),
        SimStep(
          title: 'Switching to DHW',
          narration:
              'When the cylinder thermostat asks for heat, the diverter rotates and the heat pump set point lifts to 50 C. Particles are now redirected through the coil.',
        ),
        SimStep(
          title: 'Recovery time',
          narration:
              'Recovery depends on cylinder volume, coil surface area and flow temperature. A typical 200 L cylinder takes 90 to 150 minutes to recover from cold on a 6 kW heat pump.',
        ),
        SimStep(
          title: 'Stratification and coil sizing',
          narration:
              'Heat pump cylinders use an oversized coil, often 3 to 4 square metres, to keep return temperatures low. Stratification means the top draws hot first while the bottom slowly catches up.',
        ),
        SimStep(
          title: 'Legionella cycle',
          narration:
              'Once a week the set point lifts to 60 C to pasteurise the cylinder. Heat pumps often need an immersion booster because the refrigerant cannot reach 60 C efficiently.',
        ),
        SimStep(
          title: 'Effect on space heating',
          narration:
              'During a long DHW recovery the radiators cool noticeably. Allowing heating to interrupt DHW blends the modes but extends overall recovery time.',
        ),
        SimStep(
          title: 'Common faults',
          narration:
              'A stuck diverter, a scaled coil, or low primary flow all stall DHW recovery. Symptoms include long run times, low cylinder top temperature and ErrP1 or low delta T faults.',
        ),
      ],
    );
  }
}

class _DhwPriorityPainter extends CustomPainter {
  final int step;
  final double t;
  final _DhwMode mode;
  final double setpoint;
  final bool allowInterrupt;

  _DhwPriorityPainter({
    required this.step,
    required this.t,
    required this.mode,
    required this.setpoint,
    required this.allowInterrupt,
  });

  // valve position 0 = heating, 1 = DHW
  double get _valveTarget {
    switch (mode) {
      case _DhwMode.heatingOnly:
        return 0;
      case _DhwMode.dhwCall:
        return allowInterrupt ? 0.6 : 1.0;
      case _DhwMode.legionella:
        return 1.0;
      case _DhwMode.idle:
        return 0.5;
    }
  }

  // Step 3 shows heating, step 4 highlights switching, step 7 highlights leg.
  double get _valvePos {
    final stepBias = step == 2
        ? 0.0
        : step == 3
            ? 1.0
            : step == 6
                ? 1.0
                : _valveTarget;
    return stepBias;
  }

  bool get _hpRunning => mode != _DhwMode.idle;
  bool get _dhwActive => _valvePos > 0.4;
  bool get _heatingActive {
    if (mode == _DhwMode.idle) return false;
    if (allowInterrupt) return true;
    return _valvePos < 0.6;
  }

  String get _modeText {
    switch (mode) {
      case _DhwMode.heatingOnly:
        return 'HEATING';
      case _DhwMode.dhwCall:
        return 'DHW PRIORITY';
      case _DhwMode.legionella:
        return 'LEGIONELLA';
      case _DhwMode.idle:
        return 'IDLE';
    }
  }

  double get _flowTemp {
    if (mode == _DhwMode.legionella) return 60;
    if (_dhwActive) return setpoint.clamp(40, 55);
    return 45;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.cardBg;
    canvas.drawRect(Offset.zero & size, bg);

    final w = size.width;
    final h = size.height;

    // Heat pump (left)
    final hpRect = Rect.fromLTWH(w * 0.04, h * 0.32, w * 0.16, h * 0.30);
    _drawHeatPump(canvas, hpRect);
    PipePainterHelpers.drawLabel(
        canvas, Offset(hpRect.left, hpRect.top - 18), 'Heat pump 6 kW');

    final hpFlow = Offset(hpRect.right, hpRect.top + hpRect.height * 0.30);
    final hpReturn = Offset(hpRect.right, hpRect.top + hpRect.height * 0.78);

    // System pump
    final pumpPos = Offset(hpFlow.dx + w * 0.06, hpFlow.dy);
    _drawPump(canvas, pumpPos, on: _hpRunning, label: 'Primary pump');

    // Diverter valve location
    final divCenter = Offset(w * 0.36, hpFlow.dy);

    // Cylinder (middle, vertical)
    final cylRect = Rect.fromLTWH(w * 0.46, h * 0.16, w * 0.13, h * 0.62);
    _drawCylinder(canvas, cylRect);

    // Cylinder coil ports
    final coilIn = Offset(cylRect.left, cylRect.top + cylRect.height * 0.30);
    final coilOut = Offset(cylRect.left, cylRect.top + cylRect.height * 0.78);

    // Heating circuit / radiators (right)
    final radX = w * 0.78;
    final radW = w * 0.18;
    final radH = h * 0.13;
    final radGap = h * 0.06;
    final radTopY = h * 0.16;

    final radRects = <Rect>[
      Rect.fromLTWH(radX, radTopY, radW, radH),
      Rect.fromLTWH(radX, radTopY + radH + radGap, radW, radH),
      Rect.fromLTWH(radX, radTopY + 2 * (radH + radGap), radW, radH),
    ];

    // Compute radiator warmth: cools when heating not active
    double radWarmth;
    if (mode == _DhwMode.idle) {
      radWarmth = 0.2;
    } else if (_heatingActive && !_dhwActive) {
      radWarmth = 1.0;
    } else if (_heatingActive && _dhwActive && allowInterrupt) {
      radWarmth = 0.55;
    } else {
      // strict DHW priority: rads decay
      radWarmth = 0.25 + 0.1 * math.sin(t * math.pi * 2);
    }

    for (int i = 0; i < radRects.length; i++) {
      PipePainterHelpers.drawRadiator(
        canvas,
        rect: radRects[i],
        warmth: radWarmth.clamp(0.0, 1.0),
      );
      PipePainterHelpers.drawLabel(
          canvas, Offset(radRects[i].left, radRects[i].top - 18), 'Rad ${i + 1}');
    }

    // Pipework: HP flow -> pump -> diverter
    PipePainterHelpers.drawPipe(canvas,
        a: hpFlow, b: pumpPos, color: AppColors.hotWater, width: 11);
    PipePainterHelpers.drawPipe(canvas,
        a: pumpPos, b: divCenter, color: AppColors.hotWater, width: 11);

    // Two outlets from diverter:
    // Heating port: divCenter -> right and up to manifold
    final manTop = Offset(w * 0.74, radTopY + radH * 0.5);
    final manBot = Offset(w * 0.74, radTopY + 2 * (radH + radGap) + radH * 0.5);
    final heatTeeJoin = Offset(divCenter.dx, manTop.dy - radH);
    PipePainterHelpers.drawPipe(canvas,
        a: divCenter,
        b: Offset(divCenter.dx, heatTeeJoin.dy),
        color: AppColors.hotWater,
        width: 11);
    // along top to manifold
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(divCenter.dx, heatTeeJoin.dy),
        b: Offset(manTop.dx, heatTeeJoin.dy),
        color: AppColors.hotWater,
        width: 11);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(manTop.dx, heatTeeJoin.dy),
        b: manTop,
        color: AppColors.hotWater,
        width: 11);
    PipePainterHelpers.drawPipe(canvas,
        a: manTop, b: manBot, color: AppColors.hotWater, width: 11);
    for (final r in radRects) {
      final entry = Offset(r.left, r.top + r.height * 0.5);
      PipePainterHelpers.drawPipe(canvas,
          a: Offset(manTop.dx, entry.dy),
          b: entry,
          color: AppColors.hotWater,
          width: 8);
    }
    final retMan = Offset(w * 0.70, manTop.dy);
    final retManBot = Offset(w * 0.70, manBot.dy);
    PipePainterHelpers.drawPipe(canvas,
        a: retMan, b: retManBot, color: AppColors.coldWater, width: 10);
    for (final r in radRects) {
      final exit = Offset(r.left, r.top + r.height * 0.85);
      PipePainterHelpers.drawPipe(canvas,
          a: exit, b: Offset(retMan.dx, exit.dy), color: AppColors.coldWater, width: 8);
    }

    // DHW port from diverter to cylinder coil in
    PipePainterHelpers.drawPipe(canvas,
        a: divCenter,
        b: Offset(coilIn.dx, divCenter.dy),
        color: AppColors.hotWater,
        width: 11);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(coilIn.dx, divCenter.dy), b: coilIn, color: AppColors.hotWater, width: 11);

    // Coil out -> back to HP return
    PipePainterHelpers.drawPipe(canvas,
        a: coilOut,
        b: Offset(coilOut.dx, hpReturn.dy + h * 0.04),
        color: AppColors.coldWater,
        width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(coilOut.dx, hpReturn.dy + h * 0.04),
        b: Offset(hpReturn.dx + w * 0.04, hpReturn.dy + h * 0.04),
        color: AppColors.coldWater,
        width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(hpReturn.dx + w * 0.04, hpReturn.dy + h * 0.04),
        b: hpReturn,
        color: AppColors.coldWater,
        width: 10);

    // Heating return ties into same line below cylinder
    PipePainterHelpers.drawPipe(canvas,
        a: retManBot,
        b: Offset(retManBot.dx, hpReturn.dy + h * 0.04),
        color: AppColors.coldWater,
        width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(retManBot.dx, hpReturn.dy + h * 0.04),
        b: Offset(coilOut.dx, hpReturn.dy + h * 0.04),
        color: AppColors.coldWater,
        width: 10);

    // Draw cylinder coil shape (zigzag inside cylinder)
    _drawCoil(canvas, cylRect, coilIn, coilOut);

    // Diverter valve glyph + actuator
    _drawDiverter(canvas, divCenter, _valvePos);

    // Flow particles (only on active routes)
    if (_hpRunning) {
      final p = t % 1.0;
      PipePainterHelpers.drawFlowParticles(canvas,
          a: hpFlow, b: divCenter, progress: p, color: Colors.white, count: 6);

      if (_heatingActive) {
        final ph = (t * (allowInterrupt && _dhwActive ? 0.5 : 1.0)) % 1.0;
        PipePainterHelpers.drawFlowParticles(canvas,
            a: divCenter,
            b: Offset(divCenter.dx, heatTeeJoin.dy),
            progress: ph,
            color: Colors.white,
            count: 4);
        PipePainterHelpers.drawFlowParticles(canvas,
            a: Offset(divCenter.dx, heatTeeJoin.dy),
            b: manTop,
            progress: ph,
            color: Colors.white,
            count: 6);
        PipePainterHelpers.drawFlowParticles(canvas,
            a: manTop, b: manBot, progress: ph, color: Colors.white, count: 6);
        for (final r in radRects) {
          final entry = Offset(r.left, r.top + r.height * 0.5);
          PipePainterHelpers.drawFlowParticles(canvas,
              a: Offset(manTop.dx, entry.dy),
              b: entry,
              progress: ph,
              color: Colors.white,
              count: 3);
        }
        PipePainterHelpers.drawFlowParticles(canvas,
            a: retMan, b: retManBot, progress: 1 - ph, color: Colors.white, count: 5);
      }

      if (_dhwActive) {
        final pd = (t * (allowInterrupt ? 0.7 : 1.0)) % 1.0;
        PipePainterHelpers.drawFlowParticles(canvas,
            a: divCenter, b: coilIn, progress: pd, color: Colors.white, count: 6);
        PipePainterHelpers.drawFlowParticles(canvas,
            a: coilOut,
            b: Offset(coilOut.dx, hpReturn.dy + h * 0.04),
            progress: 1 - pd,
            color: Colors.white,
            count: 4);
      }
    }

    // Joints
    PipePainterHelpers.drawJoint(canvas, divCenter, color: AppColors.brass);
    PipePainterHelpers.drawJoint(canvas, manTop);
    PipePainterHelpers.drawJoint(canvas, manBot);
    PipePainterHelpers.drawJoint(canvas, retMan);
    PipePainterHelpers.drawJoint(canvas, retManBot);

    // Controls box top-left
    _drawControls(canvas, Offset(w * 0.04, h * 0.04), w * 0.32);

    // Temperature labels
    PipePainterHelpers.drawLabel(canvas, Offset(hpFlow.dx + 6, hpFlow.dy - 22),
        'Flow ${_flowTemp.toStringAsFixed(0)} C',
        textColor: AppColors.hotWater);
    PipePainterHelpers.drawLabel(canvas,
        Offset(hpReturn.dx + 6, hpReturn.dy + 6), 'Return 40 C',
        textColor: AppColors.coldWater);
    PipePainterHelpers.drawLabel(
        canvas, Offset(divCenter.dx - 32, divCenter.dy - 30), 'Diverter');
    PipePainterHelpers.drawLabel(canvas, Offset(coilIn.dx - 80, coilIn.dy - 8),
        'Coil in', textColor: AppColors.hotWater);
    PipePainterHelpers.drawLabel(canvas, Offset(coilOut.dx - 80, coilOut.dy - 8),
        'Coil out', textColor: AppColors.coldWater);
  }

  // ---------- Components ----------

  void _drawHeatPump(Canvas canvas, Rect rect) {
    final body = Paint()..color = const Color(0xFFD7DDE5);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(r, body);
    canvas.drawRRect(r, stroke);
    final cx = rect.center.dx;
    final cy = rect.top + rect.height * 0.35;
    canvas.drawCircle(
        Offset(cx, cy), rect.width * 0.18, Paint()..color = Colors.black87);
    final blade = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final fanSpeed = _hpRunning ? t : 0.0;
    for (int i = 0; i < 3; i++) {
      final a = (fanSpeed * 2 * math.pi) + i * 2 * math.pi / 3;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + math.cos(a) * rect.width * 0.16,
            cy + math.sin(a) * rect.width * 0.16),
        blade,
      );
    }
    final block = Rect.fromLTWH(rect.left + 6, rect.top + rect.height * 0.6,
        rect.width - 12, rect.height * 0.3);
    canvas.drawRect(block, Paint()..color = const Color(0xFF8893A1));
  }

  void _drawCylinder(Canvas canvas, Rect rect) {
    final body = Paint()..color = const Color(0xFFEDEFF3);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(r, body);

    // Stratification: hot at top, gradient down. Hotter when DHW active.
    final hotFrac = _dhwActive ? 0.85 : (mode == _DhwMode.heatingOnly ? 0.5 : 0.6);
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.hotWater.withValues(alpha: 0.7),
        AppColors.hotWater.withValues(alpha: 0.35),
        AppColors.coldWater.withValues(alpha: 0.45),
      ],
      stops: [0.0, hotFrac, 1.0],
    ).createShader(rect.deflate(4));
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(8)),
        Paint()..shader = shader);
    canvas.drawRRect(r, stroke);

    // Top draw-off and cold inlet
    final topStub = Paint()..color = AppColors.pipeMetal;
    canvas.drawRect(
        Rect.fromLTWH(rect.left + rect.width * 0.4, rect.top - 10,
            rect.width * 0.18, 10),
        topStub);
    canvas.drawRect(
        Rect.fromLTWH(rect.left + rect.width * 0.4, rect.bottom,
            rect.width * 0.18, 10),
        topStub);
    PipePainterHelpers.drawLabel(
        canvas, Offset(rect.left + 4, rect.top - 18), 'Cylinder 200 L');
    PipePainterHelpers.drawLabel(
        canvas,
        Offset(rect.left + rect.width * 0.46, rect.top - 30),
        'DHW out',
        textColor: AppColors.hotWater);
    PipePainterHelpers.drawLabel(canvas,
        Offset(rect.left + rect.width * 0.46, rect.bottom + 14),
        'Cold in',
        textColor: AppColors.coldWater);

    // Immersion (visible in legionella)
    if (mode == _DhwMode.legionella) {
      final imm = Rect.fromLTWH(
          rect.left - 10, rect.top + rect.height * 0.45, 12, rect.height * 0.18);
      canvas.drawRect(imm, Paint()..color = AppColors.accent);
      canvas.drawRect(
          imm,
          Paint()
            ..color = Colors.black54
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
      PipePainterHelpers.drawLabel(
          canvas,
          Offset(rect.left - 80, rect.top + rect.height * 0.46),
          'Immersion ON',
          textColor: AppColors.accent);
      // glow
      canvas.drawRect(
        imm.inflate(4),
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Top temp readout
    PipePainterHelpers.drawLabel(
        canvas,
        Offset(rect.left + 4, rect.top + 6),
        'Top ${(mode == _DhwMode.legionella ? 60 : (_dhwActive ? setpoint : 48)).toStringAsFixed(0)} C',
        textColor: Colors.white,
        background: AppColors.hotWater);
    PipePainterHelpers.drawLabel(canvas,
        Offset(rect.left + 4, rect.bottom - 22), 'Bot 25 C',
        textColor: Colors.white, background: AppColors.coldWater);
  }

  void _drawCoil(Canvas canvas, Rect cylRect, Offset inP, Offset outP) {
    final paint = Paint()
      ..color = AppColors.copper
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final coilLeft = cylRect.left + cylRect.width * 0.18;
    final coilRight = cylRect.right - cylRect.width * 0.18;
    final path = Path()..moveTo(inP.dx, inP.dy);
    path.lineTo(coilLeft, inP.dy);
    final loops = 6;
    final dy = (outP.dy - inP.dy) / loops;
    for (int i = 0; i < loops; i++) {
      final y = inP.dy + dy * i;
      path.lineTo(coilRight, y);
      path.lineTo(coilRight, y + dy * 0.5);
      path.lineTo(coilLeft, y + dy * 0.5);
      path.lineTo(coilLeft, y + dy);
    }
    path.lineTo(outP.dx, outP.dy);
    canvas.drawPath(path, paint);
  }

  void _drawDiverter(Canvas canvas, Offset c, double pos) {
    // body
    canvas.drawCircle(c, 18, Paint()..color = AppColors.brass);
    canvas.drawCircle(
        c,
        18,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    // actuator on top
    canvas.drawRect(
        Rect.fromCenter(center: Offset(c.dx, c.dy - 24), width: 22, height: 14),
        Paint()..color = AppColors.primary);
    // pointer: 0 = right (heating up), 1 = right (DHW down through cyl)
    // In our layout heating goes up, DHW continues right toward cylinder.
    // pos 0 -> point up; pos 1 -> point right
    final angle = math.pi * 1.5 + pos * math.pi * 0.5; // 270 -> 360 deg
    final tip = Offset(c.dx + math.cos(angle) * 14, c.dy + math.sin(angle) * 14);
    final pp = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c, tip, pp);
    // small rotating ring to show actuator energised
    if (mode == _DhwMode.dhwCall || mode == _DhwMode.legionella) {
      final ring = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final rectArc = Rect.fromCircle(center: c, radius: 22);
      canvas.drawArc(rectArc, t * 2 * math.pi, math.pi * 0.6, false, ring);
    }
  }

  void _drawPump(Canvas canvas, Offset p, {required bool on, String? label}) {
    final bg = Paint()..color = on ? AppColors.primary : Colors.grey.shade400;
    canvas.drawCircle(p, 14, bg);
    canvas.drawCircle(
        p,
        14,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    final ang = on ? (t * 2 * math.pi) : 0.0;
    final arrow = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(p.dx + math.cos(ang) * 8, p.dy + math.sin(ang) * 8),
      Offset(p.dx + math.cos(ang + math.pi) * 8,
          p.dy + math.sin(ang + math.pi) * 8),
      arrow,
    );
    if (label != null) {
      PipePainterHelpers.drawLabel(canvas, Offset(p.dx - 30, p.dy + 18), label,
          fontSize: 10);
    }
  }

  void _drawControls(Canvas canvas, Offset p, double width) {
    final rect = Rect.fromLTWH(p.dx, p.dy, width, 56);
    final bg = Paint()..color = AppColors.primaryDark;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(r, bg);

    final modeColor = mode == _DhwMode.legionella
        ? AppColors.accent
        : mode == _DhwMode.dhwCall
            ? AppColors.hotWater
            : mode == _DhwMode.idle
                ? Colors.grey.shade500
                : AppColors.coldWater;

    // status pill
    final pill = Rect.fromLTWH(rect.left + 8, rect.top + 8, 100, 18);
    canvas.drawRRect(
        RRect.fromRectAndRadius(pill, const Radius.circular(9)),
        Paint()..color = modeColor);
    PipePainterHelpers.drawLabel(canvas, Offset(pill.left + 6, pill.top + 2),
        _modeText,
        background: modeColor, textColor: Colors.white, fontSize: 10);

    PipePainterHelpers.drawLabel(
        canvas,
        Offset(rect.left + 8, rect.top + 30),
        'Set ${setpoint.toStringAsFixed(0)} C  -  HP flow ${_flowTemp.toStringAsFixed(0)} C',
        background: AppColors.primaryDark,
        textColor: Colors.white,
        fontSize: 11);

    // Blink dot when running
    final dot = Paint()
      ..color = _hpRunning
          ? AppColors.accent.withValues(alpha: 0.6 + 0.4 * math.sin(t * 6))
          : Colors.grey.shade600;
    canvas.drawCircle(Offset(rect.right - 14, rect.top + 14), 6, dot);
  }

  @override
  bool shouldRepaint(covariant _DhwPriorityPainter old) => true;
}

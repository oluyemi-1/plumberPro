import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class WeatherCompTutorSimScreen extends StatefulWidget {
  const WeatherCompTutorSimScreen({super.key});
  @override
  State<WeatherCompTutorSimScreen> createState() =>
      _WeatherCompTutorSimScreenState();
}

class _WeatherCompTutorSimScreenState extends State<WeatherCompTutorSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  double _slope = 1.4;
  double _offset = 0.0;
  double _oatOverride = 0.0;
  bool _autoOat = true;
  double _roomTemp = 18.0;

  static const double _designOat = -2.0;
  static const double _baseFlow = 20.0;
  static const double _refOat = 20.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _ctrl.addListener(_tickRoom);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_tickRoom);
    _ctrl.dispose();
    super.dispose();
  }

  double _currentOat() {
    if (!_autoOat) return _oatOverride;
    final phase = _ctrl.value * 2 * math.pi;
    return 6.5 + math.sin(phase) * 11.5;
  }

  double _flowFromCurve(double oat) {
    final f = _baseFlow + _slope * (_refOat - oat) + _offset;
    return f.clamp(20.0, 75.0);
  }

  double _equilibriumRoom(double flow, double oat) {
    final heatIn = (flow - 20.0) * 0.92;
    return oat + heatIn;
  }

  void _tickRoom() {
    final oat = _currentOat();
    final flow = _flowFromCurve(oat);
    final eq = _equilibriumRoom(flow, oat);
    setState(() {
      _roomTemp += (eq - _roomTemp) * 0.02;
      _roomTemp = _roomTemp.clamp(-5.0, 35.0);
    });
  }

  String _verdict() {
    final designFlow = _flowFromCurve(_designOat);
    final designRoom = _equilibriumRoom(designFlow, _designOat);
    if (designRoom > 22.5) return 'OVER-HEATING';
    if (designRoom < 19.5) return 'UNDER-HEATING';
    return 'GOOD';
  }

  Color _verdictColor() {
    switch (_verdict()) {
      case 'GOOD':
        return Colors.greenAccent;
      case 'OVER-HEATING':
        return Colors.orangeAccent;
      default:
        return Colors.lightBlueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final oat = _currentOat();
    final flow = _flowFromCurve(oat);

    return SimScaffold(
      title: 'Weather Compensation Tutor',
      summary:
          'Drag the heating curve slope and offset to match the building heat-loss. '
          'Watch the live operating point, the radiators and the simulated indoor '
          'temperature respond.',
      onStepChanged: (_) => setState(() {}),
      controls: [
        _StatRow(
            oat: oat,
            flow: flow,
            room: _roomTemp,
            verdict: _verdict(),
            verdictColor: _verdictColor()),
        const SizedBox(height: 8),
        _LabelledSlider(
          label: 'Curve slope',
          value: _slope,
          min: 0.5,
          max: 3.0,
          divisions: 25,
          format: (v) => v.toStringAsFixed(2),
          onChanged: (v) => setState(() => _slope = v),
        ),
        _LabelledSlider(
          label: 'Parallel offset (K)',
          value: _offset,
          min: -5,
          max: 5,
          divisions: 20,
          format: (v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(1)}',
          onChanged: (v) => setState(() => _offset = v),
        ),
        Row(
          children: [
            const Text('Auto outside temp',
                style: TextStyle(color: AppColors.text)),
            const Spacer(),
            Switch(
              value: _autoOat,
              onChanged: (v) => setState(() => _autoOat = v),
            ),
          ],
        ),
        if (!_autoOat)
          _LabelledSlider(
            label: 'Outside temp override (°C)',
            value: _oatOverride,
            min: -15,
            max: 20,
            divisions: 35,
            format: (v) => v.toStringAsFixed(1),
            onChanged: (v) => setState(() => _oatOverride = v),
          ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _WeatherCompPainter(
            step: i,
            t: _ctrl.value,
            slope: _slope,
            offset: _offset,
            oat: oat,
            flow: flow,
            room: _roomTemp,
            verdict: _verdict(),
            verdictColor: _verdictColor(),
          ),
          size: Size.infinite,
        ),
      ),
      steps: const [
        SimStep(
          title: 'Why weather compensation',
          narration:
              'Heat loss is roughly linear with outside temperature, so the flow '
              'temperature should be too. Compensating saves fuel and improves '
              'comfort versus running a fixed high flow temperature.',
        ),
        SimStep(
          title: 'The heating curve explained',
          narration:
              'A heating curve maps outside air temperature to flow temperature. '
              'Slope sets how quickly flow rises as it gets colder; offset shifts '
              'the whole curve up or down in parallel.',
        ),
        SimStep(
          title: 'Reading the live operating point',
          narration:
              'The dot moving along the curve is the controller live: it picks '
              'today\'s flow temperature from the curve. Watch it slide as the '
              'simulated outside temperature changes.',
        ),
        SimStep(
          title: 'Setting the design point',
          narration:
              'At your local design OAT (here -2 °C) the flow temperature must '
              'deliver full heat-loss. If radiators are sized for 50 °C mean, the '
              'curve should hit roughly 55 °C flow at design.',
        ),
        SimStep(
          title: 'Steeper vs shallower curves',
          narration:
              'Older, leakier homes need a steeper slope; well-insulated homes '
              'use shallow curves. Too steep and you overheat at mid temperatures; '
              'too shallow and you never warm up on the coldest days.',
        ),
        SimStep(
          title: 'The parallel offset',
          narration:
              'If the whole house feels a bit cool or warm, nudge the offset '
              'rather than the slope. Offset is your everyday comfort trim; slope '
              'is set once for the building fabric.',
        ),
        SimStep(
          title: 'Tuning by feel',
          narration:
              'Adjust in small steps over a week of varied weather. Change one '
              'thing at a time, leave it 24 hours, and judge comfort across mild '
              'and cold spells before tweaking again.',
        ),
        SimStep(
          title: 'Combining with room influence',
          narration:
              'A room sensor can bias the curve based on the actual lounge '
              'temperature. This protects against solar gain and occupancy '
              'changes the OAT alone cannot see.',
        ),
        SimStep(
          title: 'Efficiency benefits',
          narration:
              'Lower flow temperatures keep a condensing boiler in condensing '
              'mode and lift a heat pump\'s SCOP. Every degree of flow saved is '
              'real money on the bill.',
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final double oat;
  final double flow;
  final double room;
  final String verdict;
  final Color verdictColor;
  const _StatRow({
    required this.oat,
    required this.flow,
    required this.room,
    required this.verdict,
    required this.verdictColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.muted.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _stat('OAT', '${oat.toStringAsFixed(1)} °C', AppColors.coldWater),
              _stat('Flow', '${flow.toStringAsFixed(1)} °C', AppColors.hotWater),
              _stat('Room', '${room.toStringAsFixed(1)} °C', AppColors.accent),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: verdictColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: verdictColor),
            ),
            child: Center(
              child: Text(
                verdict,
                style: TextStyle(
                  color: verdictColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color c) => Expanded(
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            Text(value,
                style: TextStyle(
                    color: c, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      );
}

class _LabelledSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final ValueChanged<double> onChanged;
  const _LabelledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(color: AppColors.text, fontSize: 12)),
              Text(format(value),
                  style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Slider(
          min: min,
          max: max,
          divisions: divisions,
          value: value.clamp(min, max),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _WeatherCompPainter extends CustomPainter {
  final int step;
  final double t;
  final double slope;
  final double offset;
  final double oat;
  final double flow;
  final double room;
  final String verdict;
  final Color verdictColor;

  _WeatherCompPainter({
    required this.step,
    required this.t,
    required this.slope,
    required this.offset,
    required this.oat,
    required this.flow,
    required this.room,
    required this.verdict,
    required this.verdictColor,
  });

  static const double _refOat = 20.0;
  static const double _baseFlow = 20.0;

  double _flowAt(double o) =>
      (_baseFlow + slope * (_refOat - o) + offset).clamp(20.0, 75.0);

  @override
  void paint(Canvas c, Size s) {
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.surface,
          AppColors.surface.withValues(alpha: 0.85),
        ],
      ).createShader(Offset.zero & s);
    c.drawRect(Offset.zero & s, bg);

    final houseRect = Rect.fromLTWH(20, 30, s.width * 0.5 - 30, s.height - 60);
    final graphRect = Rect.fromLTWH(
        s.width * 0.5 + 10, 30, s.width * 0.5 - 30, s.height - 60);

    _drawHouse(c, houseRect);
    _drawOutdoorScene(c, houseRect);
    _drawCurveGraph(c, graphRect);
    _drawStepHint(c, s);
  }

  void _drawHouse(Canvas c, Rect r) {
    final ground = Paint()..color = AppColors.pipeMetal.withValues(alpha: 0.3);
    c.drawRect(Rect.fromLTWH(r.left, r.bottom - 14, r.width, 14), ground);

    final wall = Paint()
      ..color = AppColors.cardBg
      ..style = PaintingStyle.fill;
    final wallStroke = Paint()
      ..color = AppColors.muted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final hRect = Rect.fromLTWH(
        r.left + 20, r.top + 50, r.width - 40, r.height - 70);
    c.drawRect(hRect, wall);
    c.drawRect(hRect, wallStroke);

    final roof = Path()
      ..moveTo(hRect.left - 6, hRect.top)
      ..lineTo(hRect.left + hRect.width / 2, hRect.top - 40)
      ..lineTo(hRect.right + 6, hRect.top)
      ..close();
    c.drawPath(roof, Paint()..color = AppColors.brass.withValues(alpha: 0.7));
    c.drawPath(roof, wallStroke);

    PipePainterHelpers.drawLabel(
        c, Offset(hRect.left + 8, hRect.top - 50), 'House cross-section');

    // Three radiators
    final radWidth = hRect.width / 3 - 16;
    final radY = hRect.bottom - 60;
    final flowIntensity = ((flow - 20) / 50).clamp(0.0, 1.0);
    for (int i = 0; i < 3; i++) {
      final rx = hRect.left + 12 + i * (radWidth + 16);
      PipePainterHelpers.drawRadiator(
        c,
        rect: Rect.fromLTWH(rx, radY, radWidth, 36),
        warmth: flowIntensity,
      );
      PipePainterHelpers.drawLabel(
          c, Offset(rx, radY - 14), 'Rad ${i + 1}');
    }

    final flowY = radY + 42;
    final retY = flowY + 10;
    PipePainterHelpers.drawPipe(c,
        a: Offset(hRect.left + 8, flowY),
        b: Offset(hRect.right - 8, flowY),
        color: AppColors.hotWater,
        width: 7);
    PipePainterHelpers.drawPipe(c,
        a: Offset(hRect.left + 8, retY),
        b: Offset(hRect.right - 8, retY),
        color: AppColors.coldWater,
        width: 7);

    final particleColor = Color.lerp(
        AppColors.hotWater.withValues(alpha: 0.4),
        AppColors.hotWater,
        flowIntensity)!;
    PipePainterHelpers.drawFlowParticles(c,
        a: Offset(hRect.left + 8, flowY),
        b: Offset(hRect.right - 8, flowY),
        progress: t,
        color: particleColor,
        count: 6);
    PipePainterHelpers.drawFlowParticles(c,
        a: Offset(hRect.right - 8, retY),
        b: Offset(hRect.left + 8, retY),
        progress: t,
        color: AppColors.coldWater.withValues(alpha: 0.7),
        count: 6);

    PipePainterHelpers.drawLabel(
        c, Offset(hRect.left + 8, flowY - 16), 'Flow pipe');
    PipePainterHelpers.drawLabel(
        c, Offset(hRect.left + 8, retY + 6), 'Return pipe');

    _drawThermometer(c, Offset(hRect.right - 26, hRect.top + 24),
        value: room, min: -5, max: 35, label: 'Room');

    final boxRect = Rect.fromLTWH(hRect.left + 8, hRect.top + 8, 110, 70);
    c.drawRRect(
        RRect.fromRectAndRadius(boxRect, const Radius.circular(6)),
        Paint()..color = AppColors.primaryDark);
    c.drawRRect(
        RRect.fromRectAndRadius(boxRect, const Radius.circular(6)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.accent
          ..strokeWidth = 1.5);
    void tp(String text, double dy, Color col, [double sz = 11]) {
      final p = TextPainter(
          text: TextSpan(
              text: text,
              style: TextStyle(
                  color: col, fontSize: sz, fontWeight: FontWeight.w600)),
          textDirection: TextDirection.ltr)
        ..layout();
      p.paint(c, Offset(boxRect.left + 6, boxRect.top + dy));
    }

    tp('Controller', 4, AppColors.accent, 10);
    tp('OAT  ${oat.toStringAsFixed(1)}°', 18, AppColors.coldWater);
    tp('Flow ${flow.toStringAsFixed(1)}°', 32, AppColors.hotWater);
    tp('Room ${room.toStringAsFixed(1)}°', 46, AppColors.text);
    PipePainterHelpers.drawLabel(
        c, Offset(boxRect.left, boxRect.bottom + 2), 'Control box');
  }

  void _drawOutdoorScene(Canvas c, Rect houseRect) {
    final unitRect = Rect.fromLTWH(
        houseRect.left + 4, houseRect.bottom - 64, 60, 50);
    c.drawRRect(
        RRect.fromRectAndRadius(unitRect, const Radius.circular(4)),
        Paint()..color = AppColors.pipeMetal);
    c.drawRRect(
        RRect.fromRectAndRadius(unitRect, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.muted
          ..strokeWidth = 1.2);
    final fc = unitRect.center;
    c.drawCircle(fc, 16, Paint()..color = AppColors.surface);
    final fanA = t * 2 * math.pi * 4;
    for (int b = 0; b < 3; b++) {
      final a = fanA + b * 2 * math.pi / 3;
      final p = Path()
        ..moveTo(fc.dx, fc.dy)
        ..lineTo(fc.dx + math.cos(a) * 14, fc.dy + math.sin(a) * 14)
        ..lineTo(fc.dx + math.cos(a + 0.4) * 12,
            fc.dy + math.sin(a + 0.4) * 12)
        ..close();
      c.drawPath(p, Paint()..color = AppColors.muted);
    }
    PipePainterHelpers.drawLabel(
        c, Offset(unitRect.left - 4, unitRect.bottom + 2), 'Outdoor unit');

    _drawThermometer(c, Offset(houseRect.left + 80, houseRect.bottom - 70),
        value: oat, min: -15, max: 25, label: 'OAT');
  }

  void _drawThermometer(Canvas c, Offset pos,
      {required double value,
      required double min,
      required double max,
      required String label}) {
    final r = Rect.fromLTWH(pos.dx, pos.dy, 12, 50);
    c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(6)),
        Paint()..color = AppColors.surface);
    c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(6)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.muted
          ..strokeWidth = 1);
    final norm = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final fill = Rect.fromLTWH(
        r.left + 2,
        r.bottom - 4 - (r.height - 6) * norm,
        8,
        (r.height - 6) * norm);
    final col = value > 12
        ? AppColors.hotWater
        : (value < 0 ? AppColors.coldWater : AppColors.accent);
    c.drawRect(fill, Paint()..color = col);
    c.drawCircle(Offset(r.center.dx, r.bottom + 2), 6, Paint()..color = col);
    PipePainterHelpers.drawLabel(c, Offset(pos.dx - 4, pos.dy - 14), label);
  }

  void _drawCurveGraph(Canvas c, Rect r) {
    c.drawRect(
        r,
        Paint()
          ..style = PaintingStyle.fill
          ..color = AppColors.cardBg.withValues(alpha: 0.6));
    c.drawRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.muted
          ..strokeWidth = 1.2);

    final axis = Paint()
      ..color = AppColors.muted.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    for (double x = -15; x <= 20; x += 5) {
      final dx = _xToPx(x, r);
      c.drawLine(Offset(dx, r.top), Offset(dx, r.bottom), axis);
    }
    for (double y = 20; y <= 70; y += 10) {
      final dy = _yToPx(y, r);
      c.drawLine(Offset(r.left, dy), Offset(r.right, dy), axis);
    }

    PipePainterHelpers.drawLabel(
        c, Offset(r.left + 6, r.top - 18), 'Heating curve');
    PipePainterHelpers.drawLabel(
        c, Offset(r.right - 50, r.bottom + 4), 'OAT °C');
    PipePainterHelpers.drawLabel(
        c, Offset(r.left - 4, r.top - 18), 'Flow °C');

    for (final x in [-15, -5, 5, 15]) {
      final tp = TextPainter(
          text: TextSpan(
              text: '$x',
              style:
                  const TextStyle(color: AppColors.muted, fontSize: 9)),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(c, Offset(_xToPx(x.toDouble(), r) - 6, r.bottom + 2));
    }
    for (final y in [30, 50, 70]) {
      final tp = TextPainter(
          text: TextSpan(
              text: '$y',
              style:
                  const TextStyle(color: AppColors.muted, fontSize: 9)),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(c, Offset(r.left - 18, _yToPx(y.toDouble(), r) - 6));
    }

    final curvePaint = Paint()
      ..color = AppColors.hotWater
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final p = Path();
    bool first = true;
    for (double x = -15; x <= 20; x += 0.5) {
      final fx = _xToPx(x, r);
      final fy = _yToPx(_flowAt(x), r);
      if (first) {
        p.moveTo(fx, fy);
        first = false;
      } else {
        p.lineTo(fx, fy);
      }
    }
    c.drawPath(p, curvePaint);

    final designX = _xToPx(-2, r);
    c.drawLine(
        Offset(designX, r.top),
        Offset(designX, r.bottom),
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.6)
          ..strokeWidth = 1.2);
    PipePainterHelpers.drawLabel(
        c, Offset(designX + 2, r.top + 4), 'Design -2°C');

    final dotX = _xToPx(oat, r);
    final dotY = _yToPx(flow, r);
    c.drawCircle(Offset(dotX, dotY), 8,
        Paint()..color = verdictColor.withValues(alpha: 0.4));
    c.drawCircle(Offset(dotX, dotY), 5, Paint()..color = verdictColor);
    PipePainterHelpers.drawLabel(
        c,
        Offset(dotX + 8, dotY - 14),
        'Op. point ${oat.toStringAsFixed(0)}/${flow.toStringAsFixed(0)}');

    final slopeTp = TextPainter(
        text: TextSpan(
            text:
                'slope ${slope.toStringAsFixed(2)}   offset ${offset >= 0 ? '+' : ''}${offset.toStringAsFixed(1)}K',
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout();
    slopeTp.paint(c, Offset(r.left + 6, r.bottom - 16));
  }

  double _xToPx(double oat, Rect r) => r.left + (oat + 15) / 35 * r.width;
  double _yToPx(double f, Rect r) => r.bottom - (f - 20) / 50 * r.height;

  void _drawStepHint(Canvas c, Size s) {
    final hints = [
      'Compensation matches flow temp to heat-loss',
      'Slope = steepness, Offset = parallel shift',
      'Live dot = today\'s operating point',
      'Hit room target at design OAT',
      'Steeper for leaky homes, shallow for insulated',
      'Offset for everyday comfort trim',
      'Tune slowly, one knob at a time',
      'Room sensor refines OAT control',
      'Lower flow = better SCOP / condensing',
    ];
    final txt = hints[step.clamp(0, hints.length - 1)];
    final tp = TextPainter(
        text: TextSpan(
            text: txt,
            style: TextStyle(
                color: AppColors.accent.withValues(alpha: 0.85),
                fontSize: 11,
                fontStyle: FontStyle.italic)),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(c, Offset(20, s.height - 18));
  }

  @override
  bool shouldRepaint(_WeatherCompPainter o) => true;
}

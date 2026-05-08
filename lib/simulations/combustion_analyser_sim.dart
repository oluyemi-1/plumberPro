import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum _BurnMode { healthy, lean, rich, faulty }

class CombustionAnalyserSimScreen extends StatefulWidget {
  const CombustionAnalyserSimScreen({super.key});

  @override
  State<CombustionAnalyserSimScreen> createState() =>
      _CombustionAnalyserSimScreenState();
}

class _CombustionAnalyserSimScreenState
    extends State<CombustionAnalyserSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  _BurnMode _mode = _BurnMode.healthy;

  // Rolling chart history (CO2 + O2)
  final List<double> _co2Hist = [];
  final List<double> _o2Hist = [];
  int _lastSampleTick = -1;

  static const _samplesMax = 60;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _ctrl.addListener(_sampleTick);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_sampleTick);
    _ctrl.dispose();
    super.dispose();
  }

  void _sampleTick() {
    final tick = (_ctrl.value * 60).floor();
    if (tick == _lastSampleTick) return;
    _lastSampleTick = tick;
    final r = _readings();
    _co2Hist.add(r.co2);
    _o2Hist.add(r.o2);
    if (_co2Hist.length > _samplesMax) _co2Hist.removeAt(0);
    if (_o2Hist.length > _samplesMax) _o2Hist.removeAt(0);
    if (mounted) setState(() {});
  }

  void _resetChart() {
    setState(() {
      _co2Hist.clear();
      _o2Hist.clear();
    });
  }

  _Readings _readings() {
    final wobble = math.sin(_ctrl.value * math.pi * 4);
    switch (_mode) {
      case _BurnMode.healthy:
        return _Readings(
          co2: 9.0 + wobble * 0.05,
          o2: 4.5 - wobble * 0.05,
          coPpm: 30 + wobble * 4,
          coOverCo2: 0.0033 + wobble * 0.0002,
          flueT: 75 + wobble * 1.0,
          ambientT: 21 + wobble * 0.2,
          efficiency: 96.5 + wobble * 0.2,
          status: _Status.green,
        );
      case _BurnMode.lean:
        return _Readings(
          co2: 6.0 + wobble * 0.05,
          o2: 9.5 - wobble * 0.08,
          coPpm: 18 + wobble * 3,
          coOverCo2: 0.0030 + wobble * 0.0002,
          flueT: 90 + wobble * 1.5,
          ambientT: 21 + wobble * 0.2,
          efficiency: 88.0 + wobble * 0.5,
          status: _Status.amber,
        );
      case _BurnMode.rich:
        return _Readings(
          co2: 11.0 + wobble * 0.1,
          o2: 1.6 - wobble * 0.05,
          coPpm: 460 + wobble * 30,
          coOverCo2: 0.0235 + wobble * 0.0006,
          flueT: 110 + wobble * 2.0,
          ambientT: 21 + wobble * 0.2,
          efficiency: 86.0 + wobble * 0.5,
          status: _Status.red,
        );
      case _BurnMode.faulty:
        final chaos = math.sin(_ctrl.value * math.pi * 9) * 1.5;
        return _Readings(
          co2: 7.5 + chaos,
          o2: 6.5 - chaos * 0.6,
          coPpm: 850 + chaos * 200,
          coOverCo2: 0.045 + chaos * 0.005,
          flueT: 140 + chaos * 8,
          ambientT: 22 + chaos * 0.3,
          efficiency: 70 + chaos,
          status: _Status.red,
        );
    }
  }

  static const List<SimStep> _steps = [
    SimStep(
      title: '1. What the analyser tells you',
      narration:
          'A flue gas analyser measures CO2, O2, CO and temperatures, then derives the CO/CO2 ratio and combustion efficiency. It is the only objective check on burner health.',
    ),
    SimStep(
      title: '2. Setting up — calibration',
      narration:
          'Power on and zero in clean air for at least 60 seconds, fit a fresh particle filter, and confirm the calibration date sticker is current. Open the test point and insert the probe.',
    ),
    SimStep(
      title: '3. Stable burn before reading',
      narration:
          'Run the appliance at full rate for 3 to 5 minutes so the flue gas stabilises. Take readings only when the digits are no longer climbing.',
    ),
    SimStep(
      title: '4. Acceptable CO/CO2 ratio',
      narration:
          'Standard limit is 0.004 and the action limit is 0.008. Above 0.02 the appliance is immediately dangerous and must be turned off and reported.',
    ),
    SimStep(
      title: '5. Lean burn',
      narration:
          'Low CO2 with high O2 indicates excess air. Causes include over-aerated burner, oversized flue, too small a gas rate, or air leaking into the flue.',
    ),
    SimStep(
      title: '6. Rich burn',
      narration:
          'High CO2 with low O2 and rising CO indicates incomplete combustion. Causes include a blocked flue, dirty heat exchanger, oversized injectors, or a starved air supply.',
    ),
    SimStep(
      title: '7. Recording results on FGA report',
      narration:
          'Document mode, gas rate, all six readings, ratio and efficiency on the FGA report. The customer keeps a copy and so does the engineer file.',
    ),
    SimStep(
      title: '8. When to leave the appliance off',
      narration:
          'A CO/CO2 ratio above 0.02, persistent CO above 400 ppm, or evidence of flame failure equals immediately dangerous. Turn off, label, warn the customer and report.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      ChoiceChip(
        label: const Text('Healthy'),
        selected: _mode == _BurnMode.healthy,
        onSelected: (_) => setState(() => _mode = _BurnMode.healthy),
      ),
      ChoiceChip(
        label: const Text('Lean (excess air)'),
        selected: _mode == _BurnMode.lean,
        onSelected: (_) => setState(() => _mode = _BurnMode.lean),
      ),
      ChoiceChip(
        label: const Text('Rich (incomplete)'),
        selected: _mode == _BurnMode.rich,
        onSelected: (_) => setState(() => _mode = _BurnMode.rich),
      ),
      ChoiceChip(
        label: const Text('Faulty appliance'),
        selected: _mode == _BurnMode.faulty,
        onSelected: (_) => setState(() => _mode = _BurnMode.faulty),
      ),
      OutlinedButton.icon(
        onPressed: _resetChart,
        icon: const Icon(Icons.restart_alt),
        label: const Text('Restart test'),
      ),
    ];

    return SimScaffold(
      title: 'Flue gas analyser (FGA)',
      summary:
          'A digital combustion analyser drawn alongside the appliance flue test point. Switch between four scenarios to see how CO2, O2, CO and CO/CO2 ratio change with burner condition.',
      steps: _steps,
      controls: controls,
      diagramBuilder: (context, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final r = _readings();
            return CustomPaint(
              painter: _AnalyserPainter(
                t: _ctrl.value,
                step: stepIndex,
                readings: r,
                co2Hist: List<double>.from(_co2Hist),
                o2Hist: List<double>.from(_o2Hist),
              ),
              child: const SizedBox.expand(),
            );
          },
        );
      },
    );
  }
}

enum _Status { green, amber, red }

class _Readings {
  final double co2;
  final double o2;
  final double coPpm;
  final double coOverCo2;
  final double flueT;
  final double ambientT;
  final double efficiency;
  final _Status status;
  const _Readings({
    required this.co2,
    required this.o2,
    required this.coPpm,
    required this.coOverCo2,
    required this.flueT,
    required this.ambientT,
    required this.efficiency,
    required this.status,
  });
}

class _AnalyserPainter extends CustomPainter {
  final double t;
  final int step;
  final _Readings readings;
  final List<double> co2Hist;
  final List<double> o2Hist;
  _AnalyserPainter({
    required this.t,
    required this.step,
    required this.readings,
    required this.co2Hist,
    required this.o2Hist,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.cardBg,
    );

    final w = size.width;
    final h = size.height;

    // Boiler casing on the left
    final boiler = Rect.fromLTWH(w * 0.05, h * 0.18, w * 0.34, h * 0.66);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boiler, const Radius.circular(10)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boiler, const Radius.circular(10)),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boiler.left, boiler.bottom + 6),
      'Boiler',
    );

    // Flue stub from boiler top
    final flueRect = Rect.fromLTWH(
      boiler.center.dx - 18,
      boiler.top - 30,
      36,
      34,
    );
    canvas.drawRect(flueRect, Paint()..color = AppColors.pipeMetal);
    canvas.drawRect(
      flueRect,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Test point hole
    final tpCentre = Offset(flueRect.right - 4, flueRect.center.dy);
    canvas.drawCircle(tpCentre, 6, Paint()..color = Colors.black87);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(flueRect.left - 6, flueRect.top - 16),
      'Flue test point',
    );

    // Burner inside boiler with small flames
    final burnerRect = Rect.fromLTWH(
      boiler.left + 16,
      boiler.center.dy + 30,
      boiler.width - 32,
      14,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(burnerRect, const Radius.circular(3)),
      Paint()..color = Colors.black87,
    );
    for (int i = 0; i < 5; i++) {
      final jx = burnerRect.left + 10 + i * (burnerRect.width - 20) / 4;
      _drawFlame(canvas, Offset(jx, burnerRect.top - 2), t + i * 0.15);
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(burnerRect.left, burnerRect.top - 18),
      'Burner',
    );

    // Heat exchanger above burner (label component)
    final heRect = Rect.fromLTWH(
      boiler.left + 14,
      boiler.top + 30,
      boiler.width - 28,
      40,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(heRect, const Radius.circular(6)),
      Paint()..color = AppColors.pipeMetal.withValues(alpha: 0.6),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(heRect.left, heRect.top - 14),
      'Heat exchanger',
    );

    // Analyser device on the right
    final dev = Rect.fromLTWH(w * 0.55, h * 0.20, w * 0.40, h * 0.62);
    canvas.drawRRect(
      RRect.fromRectAndRadius(dev, const Radius.circular(14)),
      Paint()..color = const Color(0xFF243140),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(dev, const Radius.circular(14)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(dev.left, dev.bottom + 6),
      'Combustion analyser',
    );

    // Display screen
    final screen = Rect.fromLTWH(
      dev.left + 12,
      dev.top + 14,
      dev.width - 24,
      dev.height * 0.55,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, const Radius.circular(6)),
      Paint()..color = const Color(0xFF0E2230),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, const Radius.circular(6)),
      Paint()
        ..color = Colors.greenAccent.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Digital readouts
    _drawReadout(canvas, screen, 0, 0, 'CO2',
        '${readings.co2.toStringAsFixed(1)} %');
    _drawReadout(canvas, screen, 0, 1, 'O2',
        '${readings.o2.toStringAsFixed(1)} %');
    _drawReadout(canvas, screen, 0, 2, 'CO',
        '${readings.coPpm.toStringAsFixed(0)} ppm');
    _drawReadout(canvas, screen, 1, 0, 'CO/CO2',
        readings.coOverCo2.toStringAsFixed(4));
    _drawReadout(canvas, screen, 1, 1, 'Flue T',
        '${readings.flueT.toStringAsFixed(0)} C');
    _drawReadout(canvas, screen, 1, 2, 'Amb T',
        '${readings.ambientT.toStringAsFixed(0)} C');
    _drawReadout(canvas, screen, 2, 0, 'Eff',
        '${readings.efficiency.toStringAsFixed(1)} %');
    _drawReadout(canvas, screen, 2, 1, 'Mode',
        switch (readings.status) {
          _Status.green => 'OK',
          _Status.amber => 'CHK',
          _Status.red => 'RISK',
        });
    _drawReadout(canvas, screen, 2, 2, 'Test',
        '${(t * 60).toStringAsFixed(0)} s');

    // Indicator lights row
    final lightsY = screen.bottom + 18;
    _drawIndicator(canvas, Offset(dev.left + 30, lightsY), Colors.greenAccent,
        readings.status == _Status.green);
    _drawIndicator(canvas, Offset(dev.left + 60, lightsY), Colors.amberAccent,
        readings.status == _Status.amber);
    _drawIndicator(canvas, Offset(dev.left + 90, lightsY), Colors.redAccent,
        readings.status == _Status.red);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(dev.left + 110, lightsY - 6),
      'Status lights',
      background: Colors.white,
    );

    // Rolling chart
    final chart = Rect.fromLTWH(
      dev.left + 12,
      lightsY + 18,
      dev.width - 24,
      dev.bottom - lightsY - 28,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(chart, const Radius.circular(4)),
      Paint()..color = const Color(0xFF0E2230),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(chart, const Radius.circular(4)),
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    _drawSeries(canvas, chart, co2Hist, 0, 14, AppColors.accent);
    _drawSeries(canvas, chart, o2Hist, 0, 14, AppColors.coldWater);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(chart.left + 4, chart.top - 14),
      'Rolling CO2 (orange) / O2 (blue)',
      background: Colors.white,
    );

    // Probe from device into the flue test point
    final probeStart = Offset(dev.left + 4, dev.center.dy);
    final probeMid = Offset((dev.left + flueRect.right) / 2, dev.center.dy);
    final probeEnd = tpCentre;
    final probePaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final probePath = Path()
      ..moveTo(probeStart.dx, probeStart.dy)
      ..quadraticBezierTo(probeMid.dx, probeMid.dy + 30, probeEnd.dx, probeEnd.dy);
    canvas.drawPath(probePath, probePaint);
    canvas.drawCircle(probeStart, 5, Paint()..color = Colors.black87);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(probeMid.dx - 30, probeMid.dy + 36),
      'Probe in flue',
    );

    // Title strip
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(8, 12),
      'Flue gas analysis — live readings',
      background: AppColors.primary,
      textColor: Colors.white,
      fontSize: 12,
    );
  }

  void _drawReadout(
      Canvas canvas, Rect screen, int row, int col, String label, String value) {
    final cellW = screen.width / 3;
    final cellH = screen.height / 3;
    final x = screen.left + col * cellW + 6;
    final y = screen.top + row * cellH + 6;

    final lp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    lp.paint(canvas, Offset(x, y));

    final vp = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: Colors.greenAccent.shade100,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    vp.paint(canvas, Offset(x, y + 12));
  }

  void _drawIndicator(Canvas canvas, Offset c, Color color, bool on) {
    canvas.drawCircle(c, 9, Paint()..color = Colors.black);
    canvas.drawCircle(
      c,
      8,
      Paint()..color = on ? color : color.withValues(alpha: 0.18),
    );
    if (on) {
      canvas.drawCircle(
        c,
        12,
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  void _drawSeries(Canvas canvas, Rect r, List<double> data, double lo, double hi,
      Color color) {
    if (data.length < 2) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final v = ((data[i] - lo) / (hi - lo)).clamp(0.0, 1.0);
      final x = r.left + (i / (data.length - 1)) * r.width;
      final y = r.bottom - v * r.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawFlame(Canvas canvas, Offset base, double time) {
    final flicker = 1 + math.sin(time * math.pi * 8) * 0.3;
    final hh = 16 * flicker;
    final path = Path()
      ..moveTo(base.dx - 4, base.dy)
      ..quadraticBezierTo(base.dx - 6, base.dy - hh * 0.6, base.dx, base.dy - hh)
      ..quadraticBezierTo(base.dx + 6, base.dy - hh * 0.6, base.dx + 4, base.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = AppColors.gas.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _AnalyserPainter old) =>
      old.t != t ||
      old.step != step ||
      old.readings.co2 != readings.co2 ||
      old.co2Hist.length != co2Hist.length;
}

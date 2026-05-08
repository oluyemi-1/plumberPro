import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class KettlingDescaleSimScreen extends StatefulWidget {
  const KettlingDescaleSimScreen({super.key});
  @override
  State<KettlingDescaleSimScreen> createState() =>
      _KettlingDescaleSimScreenState();
}

class _KettlingDescaleSimScreenState extends State<KettlingDescaleSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _scale = 60.0; // %
  bool _descaling = false;
  double _descaleProgress = 0.0; // 0..1
  bool _inhibitor = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _ctrl.addListener(() {
      if (_descaling) {
        setState(() {
          _descaleProgress = (_descaleProgress + 0.005).clamp(0.0, 1.0);
          _scale = (60.0 * (1 - _descaleProgress)).clamp(0.0, 100.0);
          if (_descaleProgress >= 1.0) _descaling = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _steps = <SimStep>[
    SimStep(
        title: 'Symptom — kettling and rumble',
        narration:
            'Customer reports a whistling, rumbling kettle-like noise from the boiler, slow heat-up and rising gas bills. The noise gets worse near the end of a heat cycle.'),
    SimStep(
        title: 'Cause — limescale on the heat exchanger',
        narration:
            'Calcium carbonate plates out on the hottest surfaces inside the primary heat exchanger. The water above scale flashes to steam locally and creates the noise.'),
    SimStep(
        title: 'Hard water risk areas',
        narration:
            'Anywhere with mains water above roughly 200 ppm CaCO₃ is high risk. Your local water authority publishes hardness data — confirm before quoting.'),
    SimStep(
        title: 'Diagnose — analyser, ΔT and ear',
        narration:
            'Run the FGA, measure flow vs return ΔT (should be 11 to 20 K), and listen at the boiler. A loud rumble with a small ΔT often means scale or sludge.'),
    SimStep(
        title: 'Mild scale — chemical descale',
        narration:
            'Add proprietary scale remover via the filling loop, run the system at 60°C for the recommended period, then drain, flush and refill with clean water.'),
    SimStep(
        title: 'Heavy scale — power flush',
        narration:
            'Connect a high-flow pump that reverses direction and dose with cleaner. The high velocity dislodges scale and sludge from the heat exchanger and rads.'),
    SimStep(
        title: 'Re-balance and re-inhibit',
        narration:
            'After flushing, balance lockshields for even ΔT across rads, refill, vent, and dose with the correct concentration of corrosion inhibitor.'),
    SimStep(
        title: 'Prevent recurrence',
        narration:
            'Fit an in-line scale reducer or magnetic descaler on the cold mains feed, and a system filter on the heating return to catch debris before the boiler.'),
    SimStep(
        title: 'When to replace',
        narration:
            'Pinholing, repeated kettling after flush, or HX hot spots on a thermal image suggest the heat exchanger is past life and should be renewed.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Kettling and descale diagnoser',
      summary:
          'Tune the scale slider to see noise and efficiency change in real time. Run descale to clean the heat exchanger. Toggle inhibitor for ongoing protection.',
      diagramBuilder: (_, idx) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _KettlingPainter(
              step: idx,
              t: _ctrl.value,
              scale: _scale,
              descaling: _descaling,
              descaleProgress: _descaleProgress,
              inhibitor: _inhibitor,
            ),
          ),
        );
      },
      steps: _steps,
      onStepChanged: (_) => setState(() {}),
      controls: [
        SizedBox(
          width: 240,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Scale level: ${_scale.round()}%',
                  style: const TextStyle(fontSize: 12)),
              Slider(
                value: _scale,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${_scale.round()}%',
                onChanged: _descaling
                    ? null
                    : (v) => setState(() => _scale = v),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.cleaning_services, size: 18),
          label: Text(_descaling ? 'Descaling...' : 'Run descale'),
          onPressed: _descaling
              ? null
              : () => setState(() {
                    _descaling = true;
                    _descaleProgress = 0.0;
                  }),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Inhibitor', style: TextStyle(fontSize: 12)),
            Switch.adaptive(
              value: _inhibitor,
              onChanged: (v) => setState(() => _inhibitor = v),
            ),
          ],
        ),
      ],
    );
  }
}

class _KettlingPainter extends CustomPainter {
  final int step;
  final double t;
  final double scale; // 0..100
  final bool descaling;
  final double descaleProgress; // 0..1
  final bool inhibitor;

  _KettlingPainter({
    required this.step,
    required this.t,
    required this.scale,
    required this.descaling,
    required this.descaleProgress,
    required this.inhibitor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFEFE7D6));

    // Heat exchanger sectional view in centre
    final hxRect = Rect.fromLTWH(w * 0.10, h * 0.20, w * 0.55, h * 0.55);
    canvas.drawRRect(
        RRect.fromRectAndRadius(hxRect, const Radius.circular(10)),
        Paint()..color = const Color(0xFFE9EEF3));
    canvas.drawRRect(
        RRect.fromRectAndRadius(hxRect, const Radius.circular(10)),
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    PipePainterHelpers.drawLabel(canvas,
        Offset(hxRect.left + 8, hxRect.top - 16), 'Primary heat exchanger (section)');

    // Coil passages — horizontal runs
    final passages = 5;
    final spacing = (hxRect.height - 40) / passages;
    final scaleFrac = (scale / 100.0).clamp(0.0, 1.0);
    for (int i = 0; i < passages; i++) {
      final y = hxRect.top + 30 + i * spacing;
      final inner = Rect.fromLTWH(hxRect.left + 16, y, hxRect.width - 32, 18);
      // pipe wall
      canvas.drawRRect(
          RRect.fromRectAndRadius(inner, const Radius.circular(8)),
          Paint()..color = AppColors.copper);
      // bore (water)
      final bore = Rect.fromLTWH(inner.left + 3, inner.top + 3,
          inner.width - 6, inner.height - 6);
      canvas.drawRRect(
          RRect.fromRectAndRadius(bore, const Radius.circular(6)),
          Paint()..color = AppColors.hotWater.withValues(alpha: 0.55));
      // scale layer thickness depends on scaleFrac
      final scaleLayer = 5.0 * scaleFrac;
      if (scaleLayer > 0.4) {
        final upper = Rect.fromLTWH(bore.left, bore.top, bore.width, scaleLayer);
        final lower = Rect.fromLTWH(bore.left,
            bore.bottom - scaleLayer, bore.width, scaleLayer);
        final scalePaint = Paint()
          ..color = const Color(0xFFE6D6A8).withValues(alpha: 0.95);
        canvas.drawRect(upper, scalePaint);
        canvas.drawRect(lower, scalePaint);
        // gritty texture
        final dotP = Paint()..color = const Color(0xFFB29A60);
        for (int k = 0; k < 14; k++) {
          final px = bore.left + (k * 17 + i * 7) % bore.width;
          canvas.drawCircle(Offset(px, upper.bottom - 1), 1.0, dotP);
          canvas.drawCircle(Offset(px, lower.top + 1), 1.0, dotP);
        }
      }
      // bubbles forming on hot scaled surface (kettling) — only if hot and scaled
      if (scaleFrac > 0.3 && !descaling) {
        for (int b = 0; b < 4; b++) {
          final phase = ((t + b * 0.25 + i * 0.13) % 1.0);
          final bx = bore.left + ((b * 47 + i * 31) % bore.width);
          final by = bore.top + bore.height * 0.5 - phase * 10;
          canvas.drawCircle(Offset(bx, by), 1.6 + phase * 1.3,
              Paint()..color = Colors.white.withValues(alpha: 0.9 - phase * 0.7));
        }
      }
      // flow particles — speed reduces with scale
      final particleCount = (6 - (scaleFrac * 4)).round().clamp(2, 6);
      PipePainterHelpers.drawFlowParticles(canvas,
          a: Offset(bore.left, bore.center.dy),
          b: Offset(bore.right, bore.center.dy),
          progress: (t * (1.4 - scaleFrac)) % 1.0,
          color: Colors.yellowAccent,
          count: particleCount,
          radius: 2.0);
      // descale fluid effect: a green tinted layer that erodes the scale visually
      if (descaling) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(bore, const Radius.circular(6)),
            Paint()..color = Colors.greenAccent.withValues(alpha: 0.25));
      }
    }
    PipePainterHelpers.drawLabel(canvas,
        Offset(hxRect.left + 16, hxRect.top + 6), 'Coil passages');
    PipePainterHelpers.drawLabel(canvas,
        Offset(hxRect.right - 110, hxRect.top + 6),
        'Scale: ${scale.round()}%',
        background: scaleFrac > 0.5 ? Colors.redAccent : Colors.green,
        textColor: Colors.white);

    // Inlet / outlet labels
    PipePainterHelpers.drawLabel(canvas,
        Offset(hxRect.left - 4, hxRect.bottom - 4), 'Return 60°C');
    PipePainterHelpers.drawLabel(canvas,
        Offset(hxRect.right - 60, hxRect.bottom - 4), 'Flow 80°C');

    // Side panel with meters
    final panelRect =
        Rect.fromLTWH(w * 0.68, h * 0.20, w * 0.28, h * 0.55);
    canvas.drawRRect(
        RRect.fromRectAndRadius(panelRect, const Radius.circular(10)),
        Paint()..color = AppColors.cardBg);
    canvas.drawRRect(
        RRect.fromRectAndRadius(panelRect, const Radius.circular(10)),
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    PipePainterHelpers.drawLabel(canvas,
        Offset(panelRect.left + 8, panelRect.top - 16), 'Boiler readouts');

    // Noise meter
    final noiseTop = panelRect.top + 14;
    PipePainterHelpers.drawLabel(canvas,
        Offset(panelRect.left + 8, noiseTop), 'Noise meter');
    final bars = 10;
    final activeBars = (scaleFrac * bars).round();
    for (int b = 0; b < bars; b++) {
      final x = panelRect.left + 10 + b * 14;
      final isActive = b < activeBars;
      final h2 = isActive ? 8.0 + b * 1.6 : 4.0;
      final color = b < 4
          ? Colors.green
          : (b < 7 ? Colors.amber : Colors.redAccent);
      canvas.drawRect(
          Rect.fromLTWH(x, noiseTop + 32 - h2, 10, h2),
          Paint()
            ..color = isActive
                ? color
                : color.withValues(alpha: 0.2));
    }

    // Wavy rumble line
    final rumbleY = noiseTop + 56;
    final amp = 4 + scaleFrac * 12;
    final freq = 2 + scaleFrac * 5;
    final path = Path()..moveTo(panelRect.left + 8, rumbleY);
    for (double x = panelRect.left + 8; x < panelRect.right - 8; x += 2) {
      final y = rumbleY + math.sin((x / 8) * freq + t * math.pi * 4) * amp;
      path.lineTo(x, y);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.redAccent.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    PipePainterHelpers.drawLabel(canvas,
        Offset(panelRect.left + 8, rumbleY + amp + 4), 'Rumble waveform');

    // Efficiency
    final effY = panelRect.top + 130;
    final eff = (95 - scaleFrac * 30).round();
    PipePainterHelpers.drawLabel(canvas,
        Offset(panelRect.left + 8, effY), 'Efficiency: $eff%',
        background: eff > 85 ? Colors.green : Colors.amber.shade700,
        textColor: Colors.white);

    // Flow temp gauge (simple bar)
    final flowY = effY + 30;
    final flowTemp = (80 - scaleFrac * 12).round();
    PipePainterHelpers.drawLabel(canvas,
        Offset(panelRect.left + 8, flowY), 'Flow temp: $flowTemp°C');
    final fbar = Rect.fromLTWH(panelRect.left + 8, flowY + 20,
        panelRect.width - 20, 12);
    canvas.drawRRect(
        RRect.fromRectAndRadius(fbar, const Radius.circular(6)),
        Paint()..color = Colors.black12);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(fbar.left, fbar.top,
                fbar.width * (flowTemp / 90.0).clamp(0.0, 1.0),
                fbar.height),
            const Radius.circular(6)),
        Paint()..color = AppColors.hotWater);

    // Inhibitor status
    final inhY = flowY + 44;
    PipePainterHelpers.drawLabel(canvas,
        Offset(panelRect.left + 8, inhY),
        inhibitor ? 'Inhibitor: dosed' : 'Inhibitor: missing',
        background: inhibitor ? Colors.green : Colors.redAccent,
        textColor: Colors.white);

    // Descale progress bar at bottom
    if (descaling || descaleProgress > 0.0) {
      final dRect = Rect.fromLTWH(20, h - 36, w - 40, 14);
      canvas.drawRRect(
          RRect.fromRectAndRadius(dRect, const Radius.circular(7)),
          Paint()..color = Colors.black12);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(dRect.left, dRect.top,
                  dRect.width * descaleProgress, dRect.height),
              const Radius.circular(7)),
          Paint()..color = Colors.greenAccent.shade700);
      PipePainterHelpers.drawLabel(canvas, Offset(20, h - 54),
          'Descale progress: ${(descaleProgress * 100).round()}%');
    }

    // Title labels along boiler frame
    PipePainterHelpers.drawLabel(canvas,
        Offset(8, 8), 'Heat exchanger sectional diagnostic');
    PipePainterHelpers.drawLabel(canvas, Offset(8, h - 14),
        '60–80°C operating range — kettling rises with scale %');
    PipePainterHelpers.drawLabel(canvas,
        Offset(hxRect.center.dx - 30, hxRect.bottom + 6),
        'Bubbles = local boiling');
  }

  @override
  bool shouldRepaint(_KettlingPainter o) => true;
}

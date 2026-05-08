import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class RainwaterDrainageSimScreen extends StatefulWidget {
  const RainwaterDrainageSimScreen({super.key});
  @override
  State<RainwaterDrainageSimScreen> createState() =>
      _RainwaterDrainageSimScreenState();
}

class _RainwaterDrainageSimScreenState extends State<RainwaterDrainageSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _rainIntensity = 60;
  bool _blockage = false;

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

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Roof Rainwater Drainage',
      summary:
          'Follow rain from roof slope to gutter, downpipe, gully and the underground surface water drain. Adjust intensity or trigger a leaf blockage to see the system fail.',
      controls: [
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rain intensity: ${_rainIntensity.round()}%',
                  style: const TextStyle(fontSize: 12)),
              Slider(
                value: _rainIntensity,
                min: 0,
                max: 100,
                onChanged: (v) => setState(() => _rainIntensity = v),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          icon: Icon(_blockage ? Icons.cleaning_services : Icons.eco),
          onPressed: () => setState(() => _blockage = !_blockage),
          label: Text(_blockage ? 'Clear blockage' : 'Trigger leaf blockage'),
        ),
      ],
      diagramBuilder: (context, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _RainwaterDrainagePainter(
              step: stepIndex,
              t: _ctrl.value,
              rain: _rainIntensity / 100,
              blocked: _blockage,
            ),
            size: Size.infinite,
          ),
        );
      },
      steps: const [
        SimStep(
          title: 'Why drain a roof',
          narration:
              'Roof drainage protects the walls and foundations from saturation. Without it, run-off causes damp penetration, frost damage and ground heave around the building.',
        ),
        SimStep(
          title: 'Rainfall design intensity',
          narration:
              'British practice uses a design rainfall of around 75 millimetres per hour for a one-in-two-year storm. The figure feeds gutter and downpipe sizing calculations.',
        ),
        SimStep(
          title: 'Gutter sizing',
          narration:
              'Gutter capacity must handle the effective roof area in flow. A larger pitched roof means a deeper section or more outlets to keep the gutter from overtopping.',
        ),
        SimStep(
          title: 'Gutter fall',
          narration:
              'Gutters are laid with a gentle fall, typically one in six hundred, towards the outlet. Too flat and water stagnates; too steep and the gutter looks crooked.',
        ),
        SimStep(
          title: 'Bracket spacing',
          narration:
              'Plastic gutter brackets sit at one metre maximum centres, closer near outlets and joints. Brackets carry both the weight of water and any snow load in winter.',
        ),
        SimStep(
          title: 'Downpipe sizing',
          narration:
              'A 68 millimetre round downpipe handles roughly forty square metres of roof. Larger roofs need either bigger downpipes or multiple outlets along the gutter run.',
        ),
        SimStep(
          title: 'Discharge methods',
          narration:
              'The downpipe finishes at a back-inlet gully, hopper or soakaway. Each connection needs a removable grating or trap so debris does not enter the underground drain.',
        ),
        SimStep(
          title: 'Separation from foul',
          narration:
              'Surface water must run in its own drain, never combined with foul on a separate system. Mixing the two overloads treatment plants and breaches building regulations.',
        ),
        SimStep(
          title: 'Maintenance',
          narration:
              'Annual checks remove leaves, moss and broken brackets. Swan-neck offsets are common blockage points where the pipe steps out from the eave to the wall.',
        ),
        SimStep(
          title: 'Diagnostics',
          narration:
              'Water spilling over the front of the gutter usually means an undersized section or a blocked outlet. Trace from the discharge upward to find the restriction.',
        ),
      ],
    );
  }
}

class _RainwaterDrainagePainter extends CustomPainter {
  final int step;
  final double t;
  final double rain;
  final bool blocked;
  _RainwaterDrainagePainter({
    required this.step,
    required this.t,
    required this.rain,
    required this.blocked,
  });

  static const Color soil = Color(0xFF6B4226);
  static const Color grass = Color(0xFF4F8B3B);
  static const Color sky = Color(0xFFCFE3F2);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky / ground
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.7),
      Paint()..color = sky.withValues(alpha: 0.5),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.7, w, h * 0.06),
      Paint()..color = grass,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.76, w, h * 0.24),
      Paint()..color = soil.withValues(alpha: 0.7),
    );

    // House body
    final wallLeft = w * 0.18;
    final wallRight = w * 0.55;
    final wallTop = h * 0.42;
    final wallBottom = h * 0.7;
    canvas.drawRect(
      Rect.fromLTRB(wallLeft, wallTop, wallRight, wallBottom),
      Paint()..color = const Color(0xFFE8D9B0),
    );
    canvas.drawRect(
      Rect.fromLTRB(wallLeft, wallTop, wallRight, wallBottom),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Pitched roof
    final ridge = Offset((wallLeft + wallRight) / 2, h * 0.18);
    final eaveLeft = Offset(wallLeft - 14, wallTop);
    final eaveRight = Offset(wallRight + 14, wallTop);
    final roof = Path()
      ..moveTo(eaveLeft.dx, eaveLeft.dy)
      ..lineTo(ridge.dx, ridge.dy)
      ..lineTo(eaveRight.dx, eaveRight.dy)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFF7A2A1A));
    canvas.drawPath(
        roof,
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    // tiles texture
    for (double y = h * 0.2; y < wallTop; y += 8) {
      final dx = (y - h * 0.18) * (wallLeft - 14 - ridge.dx) /
          (wallTop - h * 0.18);
      final dx2 = (y - h * 0.18) * (wallRight + 14 - ridge.dx) /
          (wallTop - h * 0.18);
      canvas.drawLine(
        Offset(ridge.dx + dx, y),
        Offset(ridge.dx + dx2, y),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..strokeWidth = 0.8,
      );
    }

    // Fascia
    canvas.drawRect(
      Rect.fromLTWH(eaveLeft.dx - 4, wallTop - 2, eaveRight.dx - eaveLeft.dx + 8, 6),
      Paint()..color = const Color(0xFFEFEFEF),
    );

    // Gutter (half round) — slight fall to the right outlet
    final gutterLeft = Offset(eaveLeft.dx - 6, wallTop + 8);
    final gutterRight = Offset(eaveRight.dx + 6, wallTop + 14);
    final gutterRect = Rect.fromPoints(
      Offset(gutterLeft.dx, gutterLeft.dy - 6),
      Offset(gutterRight.dx, gutterRight.dy + 8),
    );
    final gutterPaint = Paint()..color = const Color(0xFF333A40);
    canvas.drawRRect(
      RRect.fromRectAndRadius(gutterRect, const Radius.circular(7)),
      gutterPaint,
    );
    // water inside gutter
    final fillLevel = blocked ? 0.95 : (0.2 + rain * 0.4);
    final innerRect = Rect.fromLTRB(
      gutterRect.left + 3,
      gutterRect.top + 3,
      gutterRect.right - 3,
      gutterRect.bottom - 3,
    );
    final waterRect = Rect.fromLTRB(
      innerRect.left,
      innerRect.bottom - innerRect.height * fillLevel,
      innerRect.right,
      innerRect.bottom,
    );
    canvas.drawRect(
      waterRect,
      Paint()..color = AppColors.coldWater.withValues(alpha: 0.75),
    );

    // Brackets
    for (double x = gutterLeft.dx + 12; x < gutterRight.dx; x += 38) {
      canvas.drawLine(
        Offset(x, gutterRect.top),
        Offset(x, wallTop - 4),
        Paint()
          ..color = Colors.black54
          ..strokeWidth = 2.2,
      );
    }

    // Stop ends
    canvas.drawCircle(
      Offset(gutterRect.left + 2, gutterRect.center.dy),
      5,
      Paint()..color = Colors.black87,
    );
    canvas.drawCircle(
      Offset(gutterRect.right - 2, gutterRect.center.dy),
      5,
      Paint()..color = Colors.black87,
    );

    // Running outlet at right side, swan neck
    final outlet = Offset(gutterRect.right - 12, gutterRect.bottom);
    final swanA = Offset(outlet.dx, outlet.dy + 6);
    final swanB = Offset(outlet.dx + 14, outlet.dy + 18);
    final downTop = Offset(swanB.dx, swanB.dy + 4);
    final downBottom = Offset(downTop.dx, h * 0.68);

    // Hopper head (small)
    canvas.drawRect(
      Rect.fromCenter(center: outlet, width: 22, height: 12),
      Paint()..color = const Color(0xFF333A40),
    );

    PipePainterHelpers.drawPipe(
      canvas,
      a: swanA,
      b: swanB,
      color: const Color(0xFF333A40),
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: downTop,
      b: downBottom,
      color: const Color(0xFF333A40),
      width: 10,
    );

    // Pipe clips
    for (double y = downTop.dy + 18; y < downBottom.dy; y += 38) {
      canvas.drawRect(
        Rect.fromLTWH(downTop.dx - 8, y, 16, 4),
        Paint()..color = Colors.black87,
      );
    }

    // Shoe
    final shoe = Offset(downBottom.dx + 6, downBottom.dy + 4);
    final shoePath = Path()
      ..moveTo(downBottom.dx - 6, downBottom.dy)
      ..lineTo(downBottom.dx + 6, downBottom.dy)
      ..lineTo(shoe.dx + 6, shoe.dy)
      ..lineTo(shoe.dx, shoe.dy + 6)
      ..close();
    canvas.drawPath(shoePath, Paint()..color = const Color(0xFF222A30));

    // Back-inlet gully at ground level
    final gullyTop = Offset(shoe.dx + 4, h * 0.7);
    final gullyRect = Rect.fromLTWH(gullyTop.dx - 14, gullyTop.dy - 4, 38, 18);
    canvas.drawRect(gullyRect, Paint()..color = Colors.grey.shade700);
    // grating
    for (int i = 0; i < 5; i++) {
      final gx = gullyRect.left + 4 + i * 6.0;
      canvas.drawLine(
        Offset(gx, gullyRect.top + 2),
        Offset(gx, gullyRect.top + 8),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1.5,
      );
    }

    // Underground surface water drain
    final drainStart = Offset(gullyRect.center.dx, h * 0.82);
    final drainEnd = Offset(w * 0.95, h * 0.86);
    PipePainterHelpers.drawPipe(
      canvas,
      a: drainStart,
      b: drainEnd,
      color: AppColors.coldWater,
      width: 16,
    );
    // dashed alternative foul drain (separate)
    final foulPaint = Paint()
      ..color = AppColors.waste
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final dashStart = Offset(w * 0.05, h * 0.93);
    final dashEnd = Offset(w * 0.95, h * 0.93);
    double dx = dashStart.dx;
    while (dx < dashEnd.dx) {
      canvas.drawLine(Offset(dx, dashStart.dy),
          Offset(math.min(dx + 12, dashEnd.dx), dashStart.dy), foulPaint);
      dx += 18;
    }
    PipePainterHelpers.drawLabel(
        canvas, Offset(w * 0.1, h * 0.95), 'Foul drain (separate)');

    // Rain droplets falling on roof
    if (rain > 0.05) {
      final rng = math.Random(7);
      final drops = (rain * 28).round();
      for (int i = 0; i < drops; i++) {
        final x = 30 + rng.nextDouble() * (w - 80);
        final phase = (t + i * 0.08) % 1.0;
        final y = (rng.nextDouble() * 0.4 + phase) * h * 0.55;
        canvas.drawLine(
          Offset(x, y),
          Offset(x - 2, y + 6),
          Paint()
            ..color = AppColors.coldWater.withValues(alpha: 0.7)
            ..strokeWidth = 1.3,
        );
      }

      // Roof runoff -- particles flowing on slope to gutter
      final leftSlope = (t + 0.0) % 1.0;
      final rightSlope = (t + 0.3) % 1.0;
      _drawSlopeFlow(canvas, ridge, eaveLeft, leftSlope, rain);
      _drawSlopeFlow(canvas, ridge, eaveRight, rightSlope, rain);

      // Gutter flow towards the outlet (right side)
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(gutterRect.left + 8, gutterRect.center.dy),
        b: Offset(gutterRect.right - 14, gutterRect.center.dy),
        progress: t,
        color: Colors.white,
        count: 8,
        radius: 2.4,
      );
      // Downpipe flow
      if (!blocked) {
        PipePainterHelpers.drawFlowParticles(
          canvas,
          a: downTop,
          b: downBottom,
          color: Colors.white,
          progress: t,
          count: 7,
          radius: 2.5,
        );
        // Underground drain flow
        PipePainterHelpers.drawFlowParticles(
          canvas,
          a: drainStart,
          b: drainEnd,
          color: Colors.white,
          progress: t,
          count: 9,
          radius: 2.8,
        );
      } else {
        // Overflow over front of gutter cascading down the wall
        final ovX = gutterRect.left + 30;
        for (int i = 0; i < 8; i++) {
          final ph = (t + i * 0.12) % 1.0;
          final y = gutterRect.bottom + ph * (wallBottom - gutterRect.bottom);
          canvas.drawCircle(
            Offset(ovX + math.sin(ph * 6) * 2, y),
            2.6,
            Paint()..color = AppColors.coldWater,
          );
        }
        PipePainterHelpers.drawLabel(
          canvas,
          Offset(ovX - 30, wallTop + 22),
          'OVERFLOWING',
          background: AppColors.accent,
          textColor: Colors.white,
        );
      }
    }

    // Gutter cross-section callout
    final cx = w * 0.7;
    final cy = h * 0.18;
    final co = Rect.fromLTWH(cx, cy, 110, 70);
    canvas.drawRRect(
      RRect.fromRectAndRadius(co, const Radius.circular(8)),
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(co, const Radius.circular(8)),
      Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final crossPath = Path()
      ..moveTo(co.left + 14, co.top + 16)
      ..lineTo(co.left + 14, co.top + 50)
      ..arcToPoint(
        Offset(co.right - 14, co.top + 50),
        radius: const Radius.circular(35),
        clockwise: false,
      )
      ..lineTo(co.right - 14, co.top + 16);
    canvas.drawPath(
        crossPath,
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    final waterClip = Rect.fromLTRB(
      co.left + 16,
      co.top + 50 - 28 * fillLevel,
      co.right - 16,
      co.top + 60,
    );
    canvas.drawRect(
      waterClip,
      Paint()..color = AppColors.coldWater.withValues(alpha: 0.6),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(co.left + 6, co.top - 18),
      'Gutter cross section',
    );

    // Labels
    PipePainterHelpers.drawLabel(canvas, Offset(ridge.dx - 22, ridge.dy - 18),
        'Pitched roof');
    PipePainterHelpers.drawLabel(canvas, Offset(eaveLeft.dx - 4, wallTop - 24),
        'Eaves & fascia');
    PipePainterHelpers.drawLabel(
        canvas, Offset(gutterRect.left - 4, gutterRect.bottom + 6),
        'Gutter (half-round)');
    PipePainterHelpers.drawLabel(
        canvas, Offset(outlet.dx - 30, outlet.dy + 22), 'Hopper / outlet');
    PipePainterHelpers.drawLabel(
        canvas, Offset(swanB.dx + 6, swanB.dy - 4), 'Swan-neck offset');
    PipePainterHelpers.drawLabel(
        canvas, Offset(downTop.dx + 16, (downTop.dy + downBottom.dy) / 2),
        'Downpipe (RWP)');
    PipePainterHelpers.drawLabel(
        canvas, Offset(downTop.dx - 80, downTop.dy + 60), 'Pipe clip');
    PipePainterHelpers.drawLabel(
        canvas, Offset(gullyRect.right + 4, gullyRect.top - 10),
        'Back-inlet gully + grating');
    PipePainterHelpers.drawLabel(
        canvas, Offset(drainEnd.dx - 140, drainEnd.dy + 6),
        'Surface water drain');
    PipePainterHelpers.drawLabel(canvas,
        Offset(gutterRect.right - 50, gutterRect.top - 18), 'Stop end');

    // Step highlight box
    final highlights = <int, Rect>{
      2: gutterRect,
      3: gutterRect,
      4: Rect.fromLTRB(gutterRect.left, wallTop - 8, gutterRect.right,
          gutterRect.bottom + 4),
      5: Rect.fromLTRB(downTop.dx - 18, downTop.dy, downTop.dx + 18,
          downBottom.dy),
      6: gullyRect.inflate(6),
      7: Rect.fromLTRB(drainStart.dx - 20, drainStart.dy - 14, drainEnd.dx,
          dashStart.dy + 14),
      9: gutterRect.inflate(8),
    };
    final h2 = highlights[step];
    if (h2 != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(h2.inflate(4), const Radius.circular(8)),
        Paint()
          ..color = AppColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }
  }

  void _drawSlopeFlow(Canvas canvas, Offset ridge, Offset eave, double phase,
      double rainStrength) {
    final n = (rainStrength * 6).round();
    for (int i = 0; i < n; i++) {
      final t2 = (phase + i / n) % 1.0;
      final p = Offset.lerp(ridge, eave, t2)!;
      canvas.drawCircle(
        p,
        2.4,
        Paint()..color = AppColors.coldWater.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RainwaterDrainagePainter o) => true;
}

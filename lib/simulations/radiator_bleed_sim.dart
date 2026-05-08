import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class RadiatorBleedSimScreen extends StatefulWidget {
  const RadiatorBleedSimScreen({super.key});
  @override
  State<RadiatorBleedSimScreen> createState() =>
      _RadiatorBleedSimScreenState();
}

class _RadiatorBleedSimScreenState extends State<RadiatorBleedSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _step = 0;
  bool _bleedOpen = false;
  // Air pocket proportion of radiator height. 1 = lots of trapped air.
  double _airLevel = 0.35;
  bool _waterDripping = false;

  static const List<SimStep> _steps = [
    SimStep(
      title: 'Why bleed',
      narration:
          'Air collects at the top of a radiator because it is lighter than '
          'water. That trapped pocket insulates the upper fins, leaving the top '
          'cold while the bottom is hot.',
    ),
    SimStep(
      title: 'Safety first',
      narration:
          'Switch the heating off and allow the system to cool. Bleeding a hot '
          'radiator can scald you, and circulating pump pressure makes the air '
          'harder to release cleanly.',
    ),
    SimStep(
      title: 'Prepare your kit',
      narration:
          'Collect a bleed key, a clean cloth and a small tray. Note the system '
          'pressure on the boiler gauge so you know what to re-pressurise back '
          'to once bleeding is finished.',
    ),
    SimStep(
      title: 'Open one turn',
      narration:
          'Fit the key to the bleed nipple and turn one quarter to half a turn '
          'anti-clockwise. You should hear a steady hiss as the trapped air is '
          'pushed out by the higher pressure water behind it.',
    ),
    SimStep(
      title: 'Watch for water',
      narration:
          'The hiss will end and a thin stream of water will follow. As soon as '
          'water runs steady, close the screw firmly but do not over-tighten, '
          'to avoid damaging the soft brass seat.',
    ),
    SimStep(
      title: 'Re-pressurise',
      narration:
          'Every radiator bled has lost a little water, so the system pressure '
          'will drop. Top up slowly using the filling loop until the gauge '
          'reads about one bar with the system cold.',
    ),
    SimStep(
      title: 'Work outwards',
      narration:
          'Repeat at every radiator, moving away from the boiler. Check each '
          'one for even heat top to bottom, then record the final cold '
          'pressure on the service sheet.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _ctrl.addListener(_tick);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_tick);
    _ctrl.dispose();
    super.dispose();
  }

  void _tick() {
    if (_bleedOpen && _step >= 3) {
      setState(() {
        if (_airLevel > 0.0) {
          _airLevel = (_airLevel - 0.003).clamp(0.0, 1.0);
          if (_airLevel <= 0.0) {
            _waterDripping = true;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Bleed a radiator',
      summary:
          'Step-by-step bleeding procedure. Watch the air pocket shrink as the '
          'bleed screw is opened, then close it the moment a clean water bead '
          'appears.',
      steps: _steps,
      onStepChanged: (i) {
        setState(() {
          _step = i;
          if (i == 0) {
            _airLevel = 0.35;
            _waterDripping = false;
            _bleedOpen = false;
          }
          if (i == 5) {
            // re-pressurise: show filling animation, no bleed needed
            _bleedOpen = false;
          }
        });
      },
      controls: [
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _bleedOpen = !_bleedOpen;
              if (!_bleedOpen) _waterDripping = false;
            });
          },
          icon: Icon(_bleedOpen ? Icons.lock_open : Icons.lock),
          label: Text(_bleedOpen ? 'Close bleed' : 'Open bleed'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _airLevel = 0.35;
              _waterDripping = false;
              _bleedOpen = false;
            });
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _BleedPainter(
            step: i,
            t: _ctrl.value,
            bleedOpen: _bleedOpen,
            airLevel: _airLevel,
            waterDripping: _waterDripping,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BleedPainter extends CustomPainter {
  final int step;
  final double t;
  final bool bleedOpen;
  final double airLevel;
  final bool waterDripping;

  _BleedPainter({
    required this.step,
    required this.t,
    required this.bleedOpen,
    required this.airLevel,
    required this.waterDripping,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF9FBFD),
    );

    final w = size.width;
    final h = size.height;

    // Radiator rect (close-up) centred
    final radRect = Rect.fromLTWH(w * 0.18, h * 0.20, w * 0.58, h * 0.42);
    // Warmth depends on air level - bottom warm, top cold if air present
    final warmth = step < 1 ? 0.3 : 0.8;
    PipePainterHelpers.drawRadiator(canvas, rect: radRect, warmth: warmth);

    // If air pocket present, overdraw the top cold stripe
    if (airLevel > 0.01) {
      final coldH = radRect.height * airLevel;
      final coldRect = Rect.fromLTWH(
        radRect.left + 1,
        radRect.top + 1,
        radRect.width - 2,
        coldH,
      );
      canvas.drawRect(
        coldRect,
        Paint()..color = const Color(0xFFBFC9D1).withValues(alpha: 0.85),
      );
      // Air bubble label
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(radRect.center.dx - 24, radRect.top + coldH / 2 - 6),
        'Trapped air',
        fontSize: 10,
        background: Colors.white,
      );
    }

    // Water body (lower part) shown as a subtle overlay line
    final waterTopY = radRect.top + radRect.height * airLevel;
    canvas.drawLine(
      Offset(radRect.left + 4, waterTopY),
      Offset(radRect.right - 4, waterTopY),
      Paint()
        ..color = AppColors.coldWater.withValues(alpha: 0.8)
        ..strokeWidth = 2,
    );

    // Bleed screw top-right
    final bleedP = Offset(radRect.right - 8, radRect.top - 4);
    _drawBleedScrew(canvas, bleedP, open: bleedOpen);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(bleedP.dx - 26, bleedP.dy - 24),
      'Bleed screw',
      fontSize: 9,
    );

    // Hand/key glyph
    if (step >= 3) {
      _drawKey(canvas, Offset(bleedP.dx + 30, bleedP.dy - 4), bleedOpen);
    }

    // Flow and return valves bottom
    final flowV = Offset(radRect.left + 14, radRect.bottom + 18);
    final retV = Offset(radRect.right - 14, radRect.bottom + 18);
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(flowV.dx, radRect.bottom),
      b: Offset(flowV.dx, flowV.dy + 40),
      color: AppColors.hotWater,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(retV.dx, radRect.bottom),
      b: Offset(retV.dx, retV.dy + 40),
      color: AppColors.coldWater,
      width: 10,
    );
    PipePainterHelpers.drawValve(canvas, flowV, open: step != 1);
    PipePainterHelpers.drawValve(canvas, retV, open: step != 1);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(flowV.dx - 12, flowV.dy + 40),
      'Flow',
      fontSize: 9,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(retV.dx - 20, retV.dy + 40),
      'Lockshield',
      fontSize: 9,
    );

    // Tray below bleed screw
    final trayRect = Rect.fromLTWH(bleedP.dx - 28, bleedP.dy + 110, 60, 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(trayRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFDCDFE3),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(trayRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(trayRect.left, trayRect.bottom + 4),
      'Tray',
      fontSize: 9,
    );

    // Air escaping: small circles above bleed screw while bleeding and air left
    if (bleedOpen && airLevel > 0.01) {
      final bubblePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final outline = Paint()
        ..color = Colors.black38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      for (int i = 0; i < 4; i++) {
        final frac = ((t + i * 0.25) % 1.0);
        final y = bleedP.dy - 6 - frac * 40;
        final x = bleedP.dx + 2 + math.sin(frac * 6) * 3;
        final r = 3.0 + frac * 2;
        canvas.drawCircle(Offset(x, y), r, bubblePaint);
        canvas.drawCircle(Offset(x, y), r, outline);
      }
      // Hiss label
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(bleedP.dx + 6, bleedP.dy - 54),
        'hiss',
        fontSize: 9,
        textColor: AppColors.muted,
      );
    }

    // Water drip when air gone and bleed still open
    if (bleedOpen && airLevel <= 0.01) {
      final dripPaint = Paint()..color = AppColors.coldWater;
      for (int i = 0; i < 3; i++) {
        final frac = ((t + i * 0.33) % 1.0);
        final y = bleedP.dy + 6 + frac * 90;
        final x = bleedP.dx;
        canvas.drawCircle(Offset(x, y), 2.5, dripPaint);
      }
      // Ripple in tray
      canvas.drawLine(
        Offset(trayRect.left + 10, trayRect.top + 4),
        Offset(trayRect.right - 10, trayRect.top + 4),
        Paint()
          ..color = AppColors.coldWater.withValues(alpha: 0.6)
          ..strokeWidth = 2,
      );
    }

    // Pressure gauge in top-left for step 2 & 5
    if (step == 2 || step == 5) {
      final gaugeC = Offset(w * 0.08, h * 0.10);
      canvas.drawCircle(gaugeC, 22, Paint()..color = Colors.white);
      canvas.drawCircle(
        gaugeC,
        22,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      final angle = step == 5 ? -0.4 + t * 0.5 : -0.9;
      canvas.drawLine(
        gaugeC,
        Offset(gaugeC.dx + 18 * math.cos(angle),
            gaugeC.dy + 18 * math.sin(angle)),
        Paint()
          ..color = AppColors.accent
          ..strokeWidth = 2.2,
      );
      canvas.drawCircle(gaugeC, 3, Paint()..color = Colors.black);
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(gaugeC.dx - 24, gaugeC.dy + 26),
        step == 5 ? 'Filling to 1 bar' : 'Check pressure',
        fontSize: 9,
      );
    }

    // Filling loop animation step 5
    if (step == 5) {
      final fA = Offset(w * 0.08, h * 0.22);
      final fB = Offset(w * 0.22, h * 0.22);
      PipePainterHelpers.drawPipe(
        canvas,
        a: fA,
        b: fB,
        color: AppColors.coldWater,
        width: 6,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: fA,
        b: fB,
        progress: t,
        color: Colors.white,
        count: 4,
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(fA.dx - 4, fA.dy - 14),
        'Fill loop',
        fontSize: 9,
      );
    }

    // Step 6: multi-radiator schematic along the bottom
    if (step == 6) {
      final yy = h * 0.92;
      for (int i = 0; i < 4; i++) {
        final rx = w * 0.15 + i * (w * 0.18);
        final rr = Rect.fromLTWH(rx, yy - 14, w * 0.12, 12);
        PipePainterHelpers.drawRadiator(
          canvas,
          rect: rr,
          warmth: 1.0 - i * 0.15,
        );
      }
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(w * 0.15, yy - 32),
        'Work outwards from boiler',
        fontSize: 10,
      );
    }

    // Title label
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(radRect.left, radRect.top - 22),
      'Radiator (close-up)',
    );
  }

  void _drawBleedScrew(Canvas canvas, Offset p, {required bool open}) {
    final c = Paint()..color = AppColors.brass;
    final rim = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(p, 8, c);
    canvas.drawCircle(p, 8, rim);
    // Slot
    final slotPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2;
    final a = open ? 0.8 : 0.0;
    canvas.drawLine(
      Offset(p.dx - 5 * math.cos(a), p.dy - 5 * math.sin(a)),
      Offset(p.dx + 5 * math.cos(a), p.dy + 5 * math.sin(a)),
      slotPaint,
    );
  }

  void _drawKey(Canvas canvas, Offset p, bool turning) {
    // Stylised bleed key glyph (square socket with T handle)
    final shaft = Paint()..color = AppColors.pipeMetal;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final angle = turning ? math.sin(t * 6.28) * 0.3 : 0.0;
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(angle);
    final shaftRect = Rect.fromLTWH(-4, 0, 8, 40);
    canvas.drawRect(shaftRect, shaft);
    canvas.drawRect(shaftRect, stroke);
    final tRect = Rect.fromLTWH(-16, 30, 32, 10);
    canvas.drawRect(tRect, shaft);
    canvas.drawRect(tRect, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BleedPainter o) =>
      o.step != step ||
      o.t != t ||
      o.bleedOpen != bleedOpen ||
      o.airLevel != airLevel ||
      o.waterDripping != waterDripping;
}

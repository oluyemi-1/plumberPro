import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum TapType { compression, ceramic }

class DrippingTapSimScreen extends StatefulWidget {
  const DrippingTapSimScreen({super.key});
  @override
  State<DrippingTapSimScreen> createState() => _DrippingTapSimScreenState();
}

class _DrippingTapSimScreenState extends State<DrippingTapSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  // ignore: unused_field
  int _step = 0;

  TapType _type = TapType.compression;

  // Stage flags.
  bool _isolated = false;
  bool _stripped = false;
  bool _sealReplaced = false;
  bool _reassembled = false;
  bool _tested = false;

  // Spanner rotation phase.
  double _spannerPhase = 0.0;

  // Drip rate (slider). 0 = no drips, 1 = fast.
  double _dripRate = 0.7;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _ctrl.addListener(_tick);
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      if (_stripped && !_reassembled) _spannerPhase += 0.06;
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_tick);
    _ctrl.dispose();
    super.dispose();
  }

  bool get _fixed => _tested && _reassembled && _sealReplaced;

  // Compression steps.
  static const List<SimStep> _stepsCompression = [
    SimStep(
      title: 'Identify type',
      narration:
          'A multi-turn handle that rises and falls is a compression tap. '
          'Inside, a brass spindle drives a rubber washer onto a brass seat. '
          'A worn or hardened washer is the usual cause of drips.',
    ),
    SimStep(
      title: 'Isolate',
      narration:
          'Use the service valve on the tail beneath the basin. A quarter '
          'turn with a flat screwdriver closes it. Avoid shutting the main '
          'stop tap if you can isolate locally.',
    ),
    SimStep(
      title: 'Open the tap to drain',
      narration:
          'Open the tap fully so any pressurised water in the rising main '
          'leg between the service valve and the tap relieves before you '
          'split the body open.',
    ),
    SimStep(
      title: 'Unscrew cover and headgear',
      narration:
          'Lift or unscrew the cosmetic cover. Hold the tap body with a '
          'second spanner while you crack the headgear nut, otherwise you '
          'twist the tap and break the basin seal.',
    ),
    SimStep(
      title: 'Inspect washer',
      narration:
          'Lift the headgear and look at the washer at the bottom of the '
          'spindle. A failed washer is split, hardened, or has lost its '
          'shape. Inspect the seat for pitting at the same time.',
    ),
    SimStep(
      title: 'Replace washer',
      narration:
          'Fit a new washer of the correct size — typically half-inch for '
          'a basin tap, three-quarter for a bath. If the seat is pitted, '
          're-cut it with a reseating tool or fit a seat insert.',
    ),
    SimStep(
      title: 'Reassemble',
      narration:
          'Reassemble in reverse order. Snug only — do not crank the '
          'headgear nut. Over-tightening crushes the new washer and gives '
          'you the same drip in a fortnight.',
    ),
    SimStep(
      title: 'Restore and test',
      narration:
          'Open the service valve slowly so you do not water-hammer the '
          'system. Run hot and cold for thirty seconds and watch the spout '
          'for a returning drip.',
    ),
  ];

  // Ceramic steps.
  static const List<SimStep> _stepsCeramic = [
    SimStep(
      title: 'Identify type',
      narration:
          'A quarter-turn lever or knob, on / off in 90 degrees, is a '
          'ceramic disc cartridge. Two polished discs slide against each '
          'other; when scored, they leak.',
    ),
    SimStep(
      title: 'Isolate at the service valve',
      narration:
          'As with any tap repair, close the local service valve. Mains '
          'pressure of around 1.5 bar will spray everywhere if you forget.',
    ),
    SimStep(
      title: 'Pop indice cap and remove handle',
      narration:
          'Lever off the small red or blue indice cap with a fine flat '
          'blade. Beneath is a grub or Phillips screw. Remove it and lift '
          'the handle straight off.',
    ),
    SimStep(
      title: 'Unscrew cartridge retaining nut',
      narration:
          'A large brass collar holds the cartridge. Use the correct size '
          'spanner — never grips, which round the brass. Lift the cartridge '
          'out vertically.',
    ),
    SimStep(
      title: 'Replace cartridge',
      narration:
          'Fit the matching cartridge — note the orientation tab. Hot is '
          'almost always anticlockwise to open, cold clockwise; reversing '
          'these on installation is a common fault.',
    ),
    SimStep(
      title: 'Refit hand-tight',
      narration:
          'The cartridge sits on a rubber seat. Hand-tight only on a '
          'ceramic, then a quarter turn with a spanner. Excess torque '
          'cracks the cartridge body.',
    ),
    SimStep(
      title: 'Restore and test',
      narration:
          'Reopen the service valve. Cycle the handle a few times to bed '
          'the new disc, then check the spout and base for any seep.',
    ),
  ];

  List<SimStep> get _steps =>
      _type == TapType.compression ? _stepsCompression : _stepsCeramic;

  // Effective drip rate after fix progress.
  double get _effectiveDripRate {
    if (_fixed) return 0.0;
    if (_isolated) return 0.0; // water off
    double r = _dripRate;
    if (_sealReplaced) r *= 0.2;
    if (_stripped && !_sealReplaced) r *= 0.5;
    return r.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Repair a dripping tap',
      summary:
          'Choose the tap type, isolate, strip, replace the washer or '
          'cartridge, reassemble and test. Watch the drip rate fall to '
          'zero as each fix step completes.',
      steps: _steps,
      onStepChanged: (i) => setState(() => _step = i),
      controls: [
        Wrap(
          spacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Compression (washer)'),
              selected: _type == TapType.compression,
              onSelected: (_) => setState(() {
                _type = TapType.compression;
                _resetFix();
              }),
            ),
            ChoiceChip(
              label: const Text('Quarter-turn (ceramic)'),
              selected: _type == TapType.ceramic,
              onSelected: (_) => setState(() {
                _type = TapType.ceramic;
                _resetFix();
              }),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => setState(() => _isolated = true),
          icon: const Icon(Icons.do_not_disturb_on),
          label: const Text('Isolate supply'),
        ),
        OutlinedButton.icon(
          onPressed: _isolated
              ? () => setState(() => _stripped = true)
              : null,
          icon: const Icon(Icons.handyman),
          label: const Text('Strip down'),
        ),
        OutlinedButton.icon(
          onPressed: _stripped
              ? () => setState(() => _sealReplaced = true)
              : null,
          icon: const Icon(Icons.swap_horiz),
          label: Text(_type == TapType.compression
              ? 'Replace washer'
              : 'Replace cartridge'),
        ),
        OutlinedButton.icon(
          onPressed: _sealReplaced
              ? () => setState(() => _reassembled = true)
              : null,
          icon: const Icon(Icons.build_circle),
          label: const Text('Reassemble'),
        ),
        ElevatedButton.icon(
          onPressed: _reassembled
              ? () => setState(() {
                  _tested = true;
                  _isolated = false;
                })
              : null,
          icon: const Icon(Icons.check_circle),
          label: const Text('Test'),
        ),
        SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Drip rate', style: TextStyle(fontSize: 12)),
              Slider(
                value: _dripRate,
                onChanged: (v) => setState(() => _dripRate = v),
              ),
            ],
          ),
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _TapPainter(
            step: i,
            t: _ctrl.value,
            type: _type,
            isolated: _isolated,
            stripped: _stripped,
            sealReplaced: _sealReplaced,
            reassembled: _reassembled,
            tested: _tested,
            spannerPhase: _spannerPhase,
            dripRate: _effectiveDripRate,
            fixed: _fixed,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  void _resetFix() {
    _isolated = false;
    _stripped = false;
    _sealReplaced = false;
    _reassembled = false;
    _tested = false;
  }
}

class _TapPainter extends CustomPainter {
  final int step;
  final double t;
  final TapType type;
  final bool isolated;
  final bool stripped;
  final bool sealReplaced;
  final bool reassembled;
  final bool tested;
  final double spannerPhase;
  final double dripRate;
  final bool fixed;

  _TapPainter({
    required this.step,
    required this.t,
    required this.type,
    required this.isolated,
    required this.stripped,
    required this.sealReplaced,
    required this.reassembled,
    required this.tested,
    required this.spannerPhase,
    required this.dripRate,
    required this.fixed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.cardBg,
    );

    // Left side: basin with drips.
    final basinRect = Rect.fromLTWH(w * 0.06, h * 0.40, w * 0.36, h * 0.18);
    _drawBasin(canvas, basinRect);

    // Spout above basin.
    final spoutBase = Offset(basinRect.center.dx, basinRect.top - 10);
    _drawSpout(canvas, spoutBase);

    // Drip animation.
    _drawDrips(canvas, spoutBase, basinRect);

    // Right side: exploded sectional view.
    final centreX = w * 0.72;
    final centreY = h * 0.45;
    if (type == TapType.compression) {
      _drawCompressionExploded(canvas, Offset(centreX, centreY));
    } else {
      _drawCeramicExploded(canvas, Offset(centreX, centreY));
    }

    // Service valve below basin.
    final svPos = Offset(basinRect.center.dx, basinRect.bottom + 36);
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(svPos.dx, basinRect.bottom),
      b: Offset(svPos.dx, svPos.dy + 24),
      color: AppColors.coldWater,
      width: 10,
    );
    PipePainterHelpers.drawValve(canvas, svPos, open: !isolated, size: 12);

    // Spanner glyph if stripping.
    if (stripped && !reassembled) {
      _drawSpanner(canvas, Offset(centreX - 80, centreY - 20));
    }

    // Status banner.
    _drawStatusBanner(canvas, w);

    // Labels.
    PipePainterHelpers.drawLabel(canvas,
        Offset(basinRect.left + 8, basinRect.top + 6), 'Basin');
    PipePainterHelpers.drawLabel(
        canvas, Offset(spoutBase.dx - 24, spoutBase.dy - 60), 'Spout');
    PipePainterHelpers.drawLabel(canvas, Offset(svPos.dx + 18, svPos.dy - 6),
        isolated ? 'Service valve (closed)' : 'Service valve (open)');
    PipePainterHelpers.drawLabel(
        canvas, Offset(centreX - 60, centreY - 130),
        type == TapType.compression
            ? 'Compression tap — exploded view'
            : 'Ceramic disc tap — exploded view');
    PipePainterHelpers.drawLabel(
        canvas, Offset(8, h - 22),
        'Mains pressure typical 1.5 bar — isolate before disassembly.');
  }

  void _drawBasin(Canvas c, Rect r) {
    final body = Paint()..color = const Color(0xFFEDF2F6);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..moveTo(r.left, r.top)
      ..lineTo(r.left + 12, r.bottom)
      ..lineTo(r.right - 12, r.bottom)
      ..lineTo(r.right, r.top);
    c.drawPath(path, body);
    c.drawPath(path, stroke);
    // Plug hole.
    c.drawCircle(
      Offset(r.center.dx, r.bottom - 4),
      4,
      Paint()..color = Colors.black87,
    );
  }

  void _drawSpout(Canvas c, Offset base) {
    final body = Paint()..color = AppColors.brass;
    final stroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    // Vertical riser.
    final riser = Rect.fromLTWH(base.dx - 4, base.dy - 60, 8, 60);
    c.drawRRect(
        RRect.fromRectAndRadius(riser, const Radius.circular(2)), body);
    c.drawRRect(
        RRect.fromRectAndRadius(riser, const Radius.circular(2)), stroke);
    // Horizontal head.
    final head = Rect.fromLTWH(base.dx - 22, base.dy - 70, 44, 10);
    c.drawRRect(
        RRect.fromRectAndRadius(head, const Radius.circular(3)), body);
    c.drawRRect(
        RRect.fromRectAndRadius(head, const Radius.circular(3)), stroke);
    // Tip.
    c.drawCircle(base, 5, body);
    c.drawCircle(base, 5, stroke);
  }

  void _drawDrips(Canvas c, Offset spout, Rect basin) {
    if (dripRate <= 0.001) return;
    // Number of visible drips depends on rate.
    final n = (dripRate * 5).clamp(1, 6).toInt();
    for (int i = 0; i < n; i++) {
      final phase = ((t + i / n) * (0.4 + dripRate)) % 1.0;
      final y = spout.dy + 6 + phase * (basin.bottom - spout.dy - 8);
      final paint = Paint()
        ..color = AppColors.coldWater.withValues(alpha: 0.85);
      // Teardrop.
      final path = Path()
        ..moveTo(spout.dx, y)
        ..quadraticBezierTo(spout.dx - 4, y + 5, spout.dx, y + 8)
        ..quadraticBezierTo(spout.dx + 4, y + 5, spout.dx, y);
      c.drawPath(path, paint);
    }
    // Surface splash where drips land.
    if (dripRate > 0.05) {
      final ripple = Paint()
        ..color = AppColors.coldWater.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      c.drawCircle(Offset(spout.dx, basin.bottom - 4),
          6 + (t * 6) % 6, ripple);
    }
  }

  void _drawCompressionExploded(Canvas c, Offset centre) {
    final ex = stripped && !reassembled ? 18.0 : 0.0;
    final cx = centre.dx;
    var y = centre.dy - 80;

    // Capstan top handle.
    _drawHandle(c, Offset(cx, y));
    y += 22 + ex;

    // Headgear nut.
    _drawHexNut(c, Offset(cx, y));
    y += 16 + ex;

    // Spindle (long brass rod).
    final spindleRect = Rect.fromCenter(
        center: Offset(cx, y + 10), width: 8, height: 36);
    c.drawRRect(
      RRect.fromRectAndRadius(spindleRect, const Radius.circular(2)),
      Paint()..color = AppColors.brass,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(spindleRect, const Radius.circular(2)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    y += 36 + ex;

    // Washer (the failure point).
    final washerColour = sealReplaced ? Colors.black87 : const Color(0xFF8A2A1A);
    _drawWasher(c, Offset(cx, y), washerColour);
    y += 12 + ex;

    // Tap body (lower).
    final bodyRect =
        Rect.fromCenter(center: Offset(cx, y + 18), width: 60, height: 40);
    c.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      Paint()..color = AppColors.copper,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Seat inside body.
    c.drawCircle(
      Offset(cx, y + 12),
      6,
      Paint()..color = Colors.black87,
    );

    // Labels.
    PipePainterHelpers.drawLabel(c, Offset(cx + 24, centre.dy - 86), 'Capstan');
    PipePainterHelpers.drawLabel(
        c, Offset(cx + 24, centre.dy - 60 - ex), 'Headgear nut');
    PipePainterHelpers.drawLabel(
        c, Offset(cx + 24, centre.dy - 30 - ex), 'Spindle');
    PipePainterHelpers.drawLabel(
        c, Offset(cx + 24, centre.dy + 4 - ex),
        sealReplaced ? '1/2" washer (new)' : '1/2" washer (worn)');
    PipePainterHelpers.drawLabel(
        c, Offset(cx + 24, centre.dy + 28), 'Brass seat');
    PipePainterHelpers.drawLabel(
        c, Offset(cx - 70, centre.dy + 50), 'Tap body');
  }

  void _drawCeramicExploded(Canvas c, Offset centre) {
    final ex = stripped && !reassembled ? 18.0 : 0.0;
    final cx = centre.dx;
    var y = centre.dy - 80;

    // Indice cap.
    c.drawCircle(
      Offset(cx, y),
      8,
      Paint()..color = AppColors.coldWater,
    );
    c.drawCircle(
      Offset(cx, y),
      8,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    y += 16 + ex;

    // Lever handle.
    final leverRect = Rect.fromCenter(
        center: Offset(cx, y), width: 50, height: 12);
    c.drawRRect(
      RRect.fromRectAndRadius(leverRect, const Radius.circular(4)),
      Paint()..color = AppColors.brass,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(leverRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    y += 18 + ex;

    // Retaining nut (hex collar).
    _drawHexNut(c, Offset(cx, y), w: 36);
    y += 18 + ex;

    // Cartridge body.
    final cartridgeColour =
        sealReplaced ? AppColors.coldWater : const Color(0xFF8A2A1A);
    final cartridgeRect = Rect.fromCenter(
        center: Offset(cx, y + 12), width: 28, height: 42);
    c.drawRRect(
      RRect.fromRectAndRadius(cartridgeRect, const Radius.circular(4)),
      Paint()..color = cartridgeColour.withValues(alpha: 0.9),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(cartridgeRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Disc lines.
    c.drawLine(
      Offset(cartridgeRect.left + 4, cartridgeRect.bottom - 12),
      Offset(cartridgeRect.right - 4, cartridgeRect.bottom - 12),
      Paint()
        ..color = Colors.white70
        ..strokeWidth = 1,
    );
    c.drawLine(
      Offset(cartridgeRect.left + 4, cartridgeRect.bottom - 6),
      Offset(cartridgeRect.right - 4, cartridgeRect.bottom - 6),
      Paint()
        ..color = Colors.white70
        ..strokeWidth = 1,
    );
    y += 44 + ex;

    // Tap body.
    final bodyRect =
        Rect.fromCenter(center: Offset(cx, y + 18), width: 60, height: 40);
    c.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      Paint()..color = AppColors.copper,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Labels.
    PipePainterHelpers.drawLabel(c, Offset(cx + 16, centre.dy - 86), 'Indice cap');
    PipePainterHelpers.drawLabel(
        c, Offset(cx + 30, centre.dy - 64 - ex), 'Lever handle');
    PipePainterHelpers.drawLabel(
        c, Offset(cx + 28, centre.dy - 44 - 2 * ex), 'Retaining nut');
    PipePainterHelpers.drawLabel(
        c, Offset(cx + 22, centre.dy - 10 - 2 * ex),
        sealReplaced ? 'Ceramic cartridge (new)' : 'Ceramic cartridge (worn)');
    PipePainterHelpers.drawLabel(
        c, Offset(cx - 70, centre.dy + 50), 'Tap body');
  }

  void _drawHandle(Canvas c, Offset p) {
    final body = Paint()..color = AppColors.brass;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final r = Rect.fromCenter(center: p, width: 30, height: 8);
    c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), body);
    c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), stroke);
    c.drawCircle(p, 5, body);
    c.drawCircle(p, 5, stroke);
  }

  void _drawHexNut(Canvas c, Offset p, {double w = 28}) {
    final body = Paint()..color = AppColors.pipeMetal;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      final x = p.dx + math.cos(a) * (w / 2);
      final y = p.dy + math.sin(a) * 7;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    c.drawPath(path, body);
    c.drawPath(path, stroke);
  }

  void _drawWasher(Canvas c, Offset p, Color colour) {
    final r = Rect.fromCenter(center: p, width: 16, height: 6);
    c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(3)),
      Paint()..color = colour,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(3)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawSpanner(Canvas c, Offset pivot) {
    c.save();
    c.translate(pivot.dx, pivot.dy);
    c.rotate(math.sin(spannerPhase) * 0.6);
    final body = Paint()..color = AppColors.pipeMetal;
    final stroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final shaft = Rect.fromLTWH(0, -4, 60, 8);
    c.drawRRect(
        RRect.fromRectAndRadius(shaft, const Radius.circular(2)), body);
    c.drawRRect(
        RRect.fromRectAndRadius(shaft, const Radius.circular(2)), stroke);
    // Jaw.
    final jaw = Path()
      ..moveTo(60, -10)
      ..lineTo(78, -10)
      ..lineTo(78, -2)
      ..lineTo(70, -2)
      ..lineTo(70, 2)
      ..lineTo(78, 2)
      ..lineTo(78, 10)
      ..lineTo(60, 10)
      ..close();
    c.drawPath(jaw, body);
    c.drawPath(jaw, stroke);
    c.restore();
  }

  void _drawStatusBanner(Canvas c, double w) {
    final colour = fixed
        ? Colors.green.shade700
        : (dripRate > 0.5
            ? AppColors.accent
            : (dripRate > 0.05 ? AppColors.gas : Colors.green));
    final label = fixed
        ? 'Repair complete — no drip'
        : (isolated ? 'Supply isolated' : 'Drip rate: ${(dripRate * 100).round()}%');
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = Rect.fromLTWH(w - tp.width - 28, 12, tp.width + 16, 24);
    c.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = colour.withValues(alpha: 0.92),
    );
    tp.paint(c, Offset(rect.left + 8, rect.top + 4));
  }

  @override
  bool shouldRepaint(_TapPainter o) => true;
}

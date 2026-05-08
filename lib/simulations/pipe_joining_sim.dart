import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum _JoinTechnique { compression, pushFit, solder }

class PipeJoiningSimScreen extends StatefulWidget {
  const PipeJoiningSimScreen({super.key});
  @override
  State<PipeJoiningSimScreen> createState() => _PipeJoiningSimScreenState();
}

class _PipeJoiningSimScreenState extends State<PipeJoiningSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  _JoinTechnique _technique = _JoinTechnique.compression;

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

  // --- Content per technique ---------------------------------------------

  String get _summary {
    switch (_technique) {
      case _JoinTechnique.compression:
        return 'A compression joint seals a copper pipe by squeezing a brass olive between a nut and fitting body. It needs no heat, so it is ideal for repairs near timber or under sinks. Work carefully and never over-tighten or the olive will distort.';
      case _JoinTechnique.pushFit:
        return 'Push fit relies on a stainless grab ring to hold the pipe and an O-ring to seal it. Fast, clean, and demountable with a collet, it is perfect for plastic or copper work where a flame is not practical.';
      case _JoinTechnique.solder:
        return 'A soldered capillary joint uses flux and a fine solder wire drawn into the gap by capillary action when the fitting reaches melting temperature. Done well it produces a permanent, neat, full-bore joint that will outlast the building.';
    }
  }

  List<SimStep> get _steps {
    switch (_technique) {
      case _JoinTechnique.compression:
        return const [
          SimStep(
            title: '1. Cut and deburr',
            narration:
                'Cut the copper pipe square using a rotary pipe slice. Ream the inside with a deburring tool so the olive can seat cleanly and flow is not restricted.',
          ),
          SimStep(
            title: '2. Slide nut and olive',
            narration:
                'Slip the back-nut onto the pipe first, then the brass olive. Make sure the olive is the right way round for the fitting you are using.',
          ),
          SimStep(
            title: '3. Insert into body',
            narration:
                'Push the pipe fully home into the fitting body so it bottoms out on the shoulder. A short insertion will leak no matter how hard you tighten.',
          ),
          SimStep(
            title: '4. Hand tighten',
            narration:
                'Bring the nut up to the body by hand. You should be able to feel the olive touch the seat without any grit or side-play.',
          ),
          SimStep(
            title: '5. Spanner one turn',
            narration:
                'Hold the body with one spanner and turn the nut roughly one full turn with a second spanner. This deforms the olive just enough to make a watertight metal-to-metal seal.',
          ),
          SimStep(
            title: '6. Pressure test',
            narration:
                'Refill, vent, and check the joint for weeps. A dry cloth wiped around the nut will pick up even a trace of water so you can nip it up a fraction more if needed.',
          ),
        ];
      case _JoinTechnique.pushFit:
        return const [
          SimStep(
            title: '1. Cut and deburr',
            narration:
                'Cut the pipe dead square and remove any burr inside and out. Sharp edges will cut the O-ring and you will chase that leak forever.',
          ),
          SimStep(
            title: '2. Fit insert sleeve',
            narration:
                'Push a pipe insert into the end. It keeps the bore round so the grab ring and O-ring find the wall of the pipe evenly.',
          ),
          SimStep(
            title: '3. Mark insertion depth',
            narration:
                'Measure the socket depth and mark the pipe with a pencil. The mark tells you at a glance that the pipe is pushed all the way home.',
          ),
          SimStep(
            title: '4. Push firmly home',
            narration:
                'Push the pipe into the fitting with a steady twist. You will feel two clicks: the stainless grab ring biting and the O-ring passing its lead-in.',
          ),
          SimStep(
            title: '5. Pull back to latch',
            narration:
                'Give the pipe a firm tug. The grab ring teeth dig in harder under load, so if the pipe does not come out you know it is latched.',
          ),
          SimStep(
            title: '6. Demount if needed',
            narration:
                'To remove, press the collet squarely against the body and pull the pipe out. Always fit a new insert and check the O-ring before re-using the fitting.',
          ),
        ];
      case _JoinTechnique.solder:
        return const [
          SimStep(
            title: '1. Clean until bright',
            narration:
                'Cut and deburr, then polish the pipe end and fitting socket with wire wool until they shine. Solder will not wet a dirty or oxidised surface.',
          ),
          SimStep(
            title: '2. Apply flux',
            narration:
                'Brush a thin, even film of flux onto the pipe and inside the socket. Flux strips oxide as the joint heats and pulls the solder into the gap.',
          ),
          SimStep(
            title: '3. Assemble and support',
            narration:
                'Push the pipe fully into the socket and support it so it cannot move. Any movement while the solder freezes will crack the joint.',
          ),
          SimStep(
            title: '4. Heat evenly',
            narration:
                'Play the flame around the fitting, not the pipe, until the flux just begins to bubble and turn clear. Even heat gives an even capillary pull.',
          ),
          SimStep(
            title: '5. Touch solder in',
            narration:
                'Take the flame off the joint and touch the solder wire to the rim. Capillary action sucks the solder right around the socket in a thin silver ring.',
          ),
          SimStep(
            title: '6. Wipe while warm',
            narration:
                'Wipe the joint with a damp cloth to remove flux and leave a clean finish. Do not move the fitting until it has lost its shine or the joint will fail.',
          ),
        ];
    }
  }

  void _setTechnique(_JoinTechnique t) {
    if (t == _technique) return;
    setState(() {
      _technique = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_technique) {
      _JoinTechnique.compression => 'Compression',
      _JoinTechnique.pushFit => 'Push fit',
      _JoinTechnique.solder => 'Solder capillary',
    };

    final controls = <Widget>[
      SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Compression'),
              selected: _technique == _JoinTechnique.compression,
              onSelected: (_) => _setTechnique(_JoinTechnique.compression),
            ),
            ChoiceChip(
              label: const Text('Push fit'),
              selected: _technique == _JoinTechnique.pushFit,
              onSelected: (_) => _setTechnique(_JoinTechnique.pushFit),
            ),
            ChoiceChip(
              label: const Text('Solder capillary'),
              selected: _technique == _JoinTechnique.solder,
              onSelected: (_) => _setTechnique(_JoinTechnique.solder),
            ),
          ],
        ),
      ),
    ];

    return SimScaffold(
      key: ValueKey(_technique),
      title: 'Joining copper pipe: $title',
      summary: _summary,
      steps: _steps,
      controls: controls,
      diagramBuilder: (context, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _JoinPainter(
              technique: _technique,
              step: stepIndex,
              t: _ctrl.value,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _JoinPainter extends CustomPainter {
  final _JoinTechnique technique;
  final int step;
  final double t;
  _JoinPainter({required this.technique, required this.step, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bg = Paint()..color = AppColors.cardBg;
    canvas.drawRect(Offset.zero & size, bg);

    // Cross-section baseline
    final cy = size.height * 0.55;
    _drawBench(canvas, size, cy);

    switch (technique) {
      case _JoinTechnique.compression:
        _paintCompression(canvas, size, cy);
        break;
      case _JoinTechnique.pushFit:
        _paintPushFit(canvas, size, cy);
        break;
      case _JoinTechnique.solder:
        _paintSolder(canvas, size, cy);
        break;
    }

    // Title strip
    final titleText = switch (technique) {
      _JoinTechnique.compression => 'Compression joint — cross section',
      _JoinTechnique.pushFit => 'Push fit joint — cross section',
      _JoinTechnique.solder => 'Capillary soldered joint — cross section',
    };
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(size.width * 0.03, size.height * 0.04),
      titleText,
      background: AppColors.primary,
      textColor: Colors.white,
      fontSize: 12,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(size.width * 0.03, size.height * 0.92),
      'Step ${step + 1}',
      background: AppColors.accent,
      textColor: Colors.white,
      fontSize: 11,
    );
  }

  void _drawBench(Canvas canvas, Size size, double cy) {
    final p = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final dashW = 6.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, cy + size.height * 0.28),
        Offset(x + dashW, cy + size.height * 0.28),
        p,
      );
      x += dashW * 2;
    }
  }

  // ---------------- Compression -----------------------------------------

  void _paintCompression(Canvas canvas, Size size, double cy) {
    final w = size.width;
    // Pipe entry from left
    final pipeLeftA = Offset(w * 0.04, cy);
    // Nut position slides along pipe depending on step
    double nutX;
    double oliveX;
    double pipeInsertFrac; // how far pipe is inside body
    switch (step) {
      case 0:
        nutX = w * 0.18;
        oliveX = w * 0.22;
        pipeInsertFrac = 0.0;
        break;
      case 1:
        nutX = w * 0.28;
        oliveX = w * 0.33;
        pipeInsertFrac = 0.0;
        break;
      case 2:
        nutX = w * 0.33;
        oliveX = w * 0.38;
        pipeInsertFrac = 0.5;
        break;
      case 3:
        nutX = w * 0.41;
        oliveX = w * 0.44;
        pipeInsertFrac = 1.0;
        break;
      case 4:
        nutX = w * 0.44;
        oliveX = w * 0.46;
        pipeInsertFrac = 1.0;
        break;
      default:
        nutX = w * 0.45;
        oliveX = w * 0.47;
        pipeInsertFrac = 1.0;
    }

    // Fitting body (fixed, right side)
    final bodyLeft = w * 0.48;
    final bodyRight = w * 0.82;
    final bodyRect = Rect.fromLTRB(bodyLeft, cy - 28, bodyRight, cy + 28);
    final bodyPaint = Paint()..color = AppColors.brass.withValues(alpha: 0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)),
      bodyPaint,
    );
    final bodyStroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)),
      bodyStroke,
    );
    // Hex flats suggestion
    for (int i = 0; i < 5; i++) {
      final xx = bodyLeft + 8 + i * 14.0;
      canvas.drawLine(
        Offset(xx, bodyRect.top + 4),
        Offset(xx, bodyRect.top + 12),
        bodyStroke,
      );
    }

    // Pipe from entry to insertion point
    final insertDepth = (bodyLeft + 40) - pipeLeftA.dx;
    final pipeEndX = pipeLeftA.dx + insertDepth * (0.55 + 0.45 * pipeInsertFrac);
    PipePainterHelpers.drawPipe(
      canvas,
      a: pipeLeftA,
      b: Offset(pipeEndX, cy),
      color: AppColors.copper,
      width: 22,
    );
    // Pipe coming out the other side of body
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(bodyRight - 2, cy),
      b: Offset(w * 0.97, cy),
      color: AppColors.copper,
      width: 22,
    );

    // Olive (brass ring)
    final olivePaint = Paint()..color = AppColors.brass;
    final oliveStroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final oliveRect = Rect.fromCenter(
      center: Offset(oliveX, cy),
      width: 16,
      height: 34,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(oliveRect, const Radius.circular(3)),
      olivePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(oliveRect, const Radius.circular(3)),
      oliveStroke,
    );

    // Back-nut
    final nutRect = Rect.fromCenter(
      center: Offset(nutX, cy),
      width: 28,
      height: 46,
    );
    final nutPaint = Paint()..color = AppColors.brass.withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(nutRect, const Radius.circular(4)),
      nutPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(nutRect, const Radius.circular(4)),
      oliveStroke,
    );
    // Hex suggestion on nut
    for (int i = 0; i < 3; i++) {
      final yy = nutRect.top + 6 + i * 12.0;
      canvas.drawLine(
        Offset(nutRect.left + 4, yy),
        Offset(nutRect.right - 4, yy),
        oliveStroke,
      );
    }

    // Spanner illustration (step 4 - index 4)
    if (step == 4) {
      final wobble = math.sin(t * math.pi * 4) * 2;
      _drawSpanner(canvas, Offset(nutX, cy - 56 + wobble), horizontal: true);
      _drawSpanner(canvas, Offset(bodyLeft + 30, cy + 56 - wobble),
          horizontal: true);
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(nutX - 30, cy - 82),
        'One turn',
        background: AppColors.accent,
        textColor: Colors.white,
      );
    }
    if (step == 0) {
      // Show reamer / cut icon
      _drawCutter(canvas, Offset(pipeLeftA.dx + 70, cy), t);
    }

    // Labels
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pipeLeftA.dx - 4, cy + 48),
      'Copper pipe',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(nutRect.left - 6, cy + 58),
      'Back-nut',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(oliveRect.left - 8, cy - 70),
      'Brass olive',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(bodyLeft + 8, cy - 70),
      'Fitting body',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(bodyRight - 30, cy + 48),
      'Outlet',
    );
  }

  void _drawSpanner(Canvas canvas, Offset p, {required bool horizontal}) {
    final paint = Paint()..color = AppColors.pipeMetal;
    final stroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rect = horizontal
        ? Rect.fromCenter(center: p, width: 90, height: 14)
        : Rect.fromCenter(center: p, width: 14, height: 90);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      stroke,
    );
    // jaws
    final jaw = Path();
    if (horizontal) {
      jaw.moveTo(rect.right, rect.top);
      jaw.lineTo(rect.right + 14, rect.top - 6);
      jaw.lineTo(rect.right + 14, rect.bottom + 6);
      jaw.lineTo(rect.right, rect.bottom);
      jaw.close();
    }
    canvas.drawPath(jaw, paint);
    canvas.drawPath(jaw, stroke);
  }

  void _drawCutter(Canvas canvas, Offset p, double time) {
    final paint = Paint()..color = Colors.redAccent;
    canvas.drawCircle(p, 18, paint);
    canvas.drawCircle(p, 18, Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2);
    final ang = time * math.pi * 2;
    canvas.drawLine(
      p,
      Offset(p.dx + math.cos(ang) * 14, p.dy + math.sin(ang) * 14),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(p.dx - 12, p.dy - 36),
      'Pipe slice',
    );
  }

  // ---------------- Push fit --------------------------------------------

  void _paintPushFit(Canvas canvas, Size size, double cy) {
    final w = size.width;
    final bodyLeft = w * 0.42;
    final bodyRight = w * 0.82;
    final bodyRect = Rect.fromLTRB(bodyLeft, cy - 32, bodyRight, cy + 32);
    final bodyPaint = Paint()..color = AppColors.pipeMetal;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(12)),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(12)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Collet at entry
    final colletOffset = (step == 5) ? -10.0 : 0.0;
    final colletLeft = bodyLeft - 10 + colletOffset;
    final colletRect =
        Rect.fromLTRB(colletLeft, cy - 20, colletLeft + 16, cy + 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(colletRect, const Radius.circular(4)),
      Paint()..color = Colors.black87,
    );

    // O-ring and grab ring inside body
    final oRingX = bodyLeft + 40;
    final grabRingX = bodyLeft + 22;
    // Grab ring teeth
    final grabPaint = Paint()..color = const Color(0xFFC0C6CC);
    final grabStroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = -3; i <= 3; i++) {
      final path = Path()
        ..moveTo(grabRingX, cy + i * 5.0)
        ..lineTo(grabRingX + 8, cy + i * 5.0 + 2)
        ..lineTo(grabRingX, cy + i * 5.0 + 4);
      canvas.drawPath(path, grabPaint);
      canvas.drawPath(path, grabStroke);
    }
    // O-ring
    canvas.drawCircle(Offset(oRingX, cy - 14),
        4, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(oRingX, cy + 14),
        4, Paint()..color = Colors.black);

    // Pipe insertion progression
    double pipeEndX;
    switch (step) {
      case 0:
        pipeEndX = w * 0.25;
        break;
      case 1:
        pipeEndX = w * 0.30;
        break;
      case 2:
        pipeEndX = w * 0.36;
        break;
      case 3:
        pipeEndX = bodyLeft + 55;
        break;
      case 4:
        pipeEndX = bodyLeft + 50;
        break;
      default:
        pipeEndX = bodyLeft + 15;
    }

    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(w * 0.04, cy),
      b: Offset(pipeEndX, cy),
      color: AppColors.copper,
      width: 22,
    );

    // Insert sleeve (shown once fitted)
    if (step >= 1) {
      final sleeveRect = Rect.fromCenter(
        center: Offset(pipeEndX - 10, cy),
        width: 22,
        height: 14,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(sleeveRect, const Radius.circular(3)),
        Paint()..color = Colors.white,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(sleeveRect, const Radius.circular(3)),
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(sleeveRect.left - 20, cy - 36),
        'Insert',
      );
    }

    // Depth mark on pipe (step 2 onward)
    if (step >= 2) {
      canvas.drawLine(
        Offset(bodyLeft - 2, cy - 14),
        Offset(bodyLeft - 2, cy + 14),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2,
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(bodyLeft - 20, cy + 40),
        'Depth mark',
      );
    }

    // Outlet pipe
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(bodyRight - 2, cy),
      b: Offset(w * 0.97, cy),
      color: AppColors.copper,
      width: 22,
    );

    // Labels
    PipePainterHelpers.drawLabel(canvas, Offset(w * 0.04, cy + 48),
        'Copper pipe');
    PipePainterHelpers.drawLabel(canvas, Offset(colletLeft - 6, cy + 56),
        'Demount collet');
    PipePainterHelpers.drawLabel(canvas, Offset(grabRingX - 6, cy - 62),
        'Grab ring teeth');
    PipePainterHelpers.drawLabel(canvas, Offset(oRingX - 4, cy + 56),
        'O-ring seal');
    PipePainterHelpers.drawLabel(canvas, Offset(bodyLeft + 80, cy - 62),
        'Push fit body');
  }

  // ---------------- Solder ----------------------------------------------

  void _paintSolder(Canvas canvas, Size size, double cy) {
    final w = size.width;
    // Fitting socket (copper colored fitting)
    final bodyLeft = w * 0.42;
    final bodyRight = w * 0.78;
    final bodyRect = Rect.fromLTRB(bodyLeft, cy - 30, bodyRight, cy + 30);
    final bodyPaint = Paint()..color = AppColors.copper.withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Pipe in
    final inEnd =
        step >= 2 ? bodyLeft + 40.0 : bodyLeft - 10.0;
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(w * 0.04, cy),
      b: Offset(inEnd, cy),
      color: AppColors.copper,
      width: 22,
    );
    // Pipe out
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(bodyRight - 2, cy),
      b: Offset(w * 0.97, cy),
      color: AppColors.copper,
      width: 22,
    );

    // Bright polished band (step 0)
    if (step == 0) {
      final band = Paint()..color = Colors.white.withValues(alpha: 0.6);
      canvas.drawRect(
          Rect.fromLTWH(bodyLeft - 40, cy - 12, 36, 24), band);
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(bodyLeft - 48, cy - 50),
        'Wire wool clean',
      );
    }

    // Flux brush (step 1)
    if (step == 1) {
      _drawFluxBrush(canvas, Offset(bodyLeft - 20, cy - 50), t);
      // Blue flux smear
      final flux = Paint()..color = Colors.lightBlueAccent.withValues(alpha: 0.6);
      canvas.drawRect(
          Rect.fromLTWH(bodyLeft - 36, cy - 12, 32, 24), flux);
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(bodyLeft - 38, cy + 48),
        'Flux applied',
      );
    }

    // Torch and flame (steps 3-5 inclusive index 3..5)
    if (step >= 3) {
      _drawTorchFlame(canvas, Offset(bodyLeft + (bodyRight - bodyLeft) / 2, cy + 90),
          t, active: step <= 4);
    }

    // Solder wire (step 4 onwards, feeding)
    if (step == 4) {
      _drawSolderWire(canvas, Offset(bodyLeft + 6, cy - 70), t);
      // Drip at joint
      final drip = step == 4;
      if (drip) {
        final dy = (t * 30) % 30;
        canvas.drawCircle(
          Offset(bodyLeft + 6, cy - 40 + dy),
          3,
          Paint()..color = Colors.grey.shade300,
        );
      }
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(bodyLeft - 18, cy - 96),
        'Solder wire',
      );
    }

    // Capillary silver ring (steps 4-5)
    if (step >= 4) {
      final ring = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawLine(
        Offset(bodyLeft + 1, cy - 22),
        Offset(bodyLeft + 1, cy + 22),
        ring,
      );
    }

    // Damp cloth (step 5)
    if (step == 5) {
      final cloth = Paint()..color = Colors.lightBlue.shade200;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(bodyLeft + 20, cy - 60),
            width: 36,
            height: 22,
          ),
          const Radius.circular(4),
        ),
        cloth,
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(bodyLeft - 4, cy - 84),
        'Damp cloth',
      );
    }

    // Labels
    PipePainterHelpers.drawLabel(canvas, Offset(w * 0.04, cy + 48),
        'Copper pipe');
    PipePainterHelpers.drawLabel(canvas, Offset(bodyLeft + 40, cy - 56),
        'Capillary fitting socket');
    PipePainterHelpers.drawLabel(canvas, Offset(bodyRight + 10, cy + 48),
        'Outlet');
  }

  void _drawFluxBrush(Canvas canvas, Offset p, double time) {
    final handle = Paint()..color = const Color(0xFF8C5A2B);
    final head = Paint()..color = Colors.grey.shade400;
    final wobble = math.sin(time * math.pi * 4) * 3;
    final r = Rect.fromCenter(
      center: Offset(p.dx, p.dy + wobble),
      width: 8,
      height: 50,
    );
    canvas.drawRect(r, handle);
    canvas.drawRect(
      Rect.fromLTWH(r.left - 4, r.bottom, r.width + 8, 10),
      head,
    );
  }

  void _drawSolderWire(Canvas canvas, Offset p, double time) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final jitter = math.sin(time * math.pi * 6) * 2;
    canvas.drawLine(
      Offset(p.dx + jitter, p.dy),
      Offset(p.dx + jitter, p.dy + 60),
      paint,
    );
  }

  void _drawTorchFlame(Canvas canvas, Offset p, double time, {required bool active}) {
    // Torch body
    final torchRect = Rect.fromCenter(center: p, width: 40, height: 80);
    canvas.drawRRect(
      RRect.fromRectAndRadius(torchRect, const Radius.circular(6)),
      Paint()..color = Colors.black87,
    );
    // Nozzle
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(p.dx, p.dy - 45),
        width: 10,
        height: 20,
      ),
      Paint()..color = Colors.grey.shade700,
    );
    if (active) {
      // Flame with flicker
      final flicker = 1.0 + math.sin(time * math.pi * 10) * 0.15;
      final flame = Path()
        ..moveTo(p.dx - 12, p.dy - 55)
        ..quadraticBezierTo(
          p.dx - 16 * flicker,
          p.dy - 80 * flicker,
          p.dx,
          p.dy - 110 * flicker,
        )
        ..quadraticBezierTo(
          p.dx + 16 * flicker,
          p.dy - 80 * flicker,
          p.dx + 12,
          p.dy - 55,
        )
        ..close();
      canvas.drawPath(
        flame,
        Paint()..color = AppColors.gas.withValues(alpha: 0.85),
      );
      final inner = Path()
        ..moveTo(p.dx - 6, p.dy - 60)
        ..quadraticBezierTo(
          p.dx - 8 * flicker,
          p.dy - 80 * flicker,
          p.dx,
          p.dy - 95 * flicker,
        )
        ..quadraticBezierTo(
          p.dx + 8 * flicker,
          p.dy - 80 * flicker,
          p.dx + 6,
          p.dy - 60,
        )
        ..close();
      canvas.drawPath(
        inner,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(p.dx - 16, p.dy + 44),
      'Blow torch',
    );
  }

  @override
  bool shouldRepaint(covariant _JoinPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.step != step ||
      oldDelegate.technique != technique;
}

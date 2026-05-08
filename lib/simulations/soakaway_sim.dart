import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum _Soil { sand, loam, clay }

enum _PitType { rubble, crate }

class SoakawaySimScreen extends StatefulWidget {
  const SoakawaySimScreen({super.key});
  @override
  State<SoakawaySimScreen> createState() => _SoakawaySimScreenState();
}

class _SoakawaySimScreenState extends State<SoakawaySimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  _Soil _soil = _Soil.loam;
  _PitType _type = _PitType.crate;
  bool _testRunning = false;
  double _pitLevel = 0.0;
  DateTime? _testStart;

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
    final dt = 1 / 60;
    final infiltration = switch (_soil) {
      _Soil.sand => 0.20,
      _Soil.loam => 0.07,
      _Soil.clay => 0.012,
    };
    double inflow = 0;
    if (_testRunning) {
      final elapsed = DateTime.now().difference(_testStart!).inMilliseconds /
          1000.0;
      if (elapsed < 6) {
        inflow = 0.16 * dt;
      } else {
        // discharge ended
        _testRunning = false;
      }
    }
    final outflow = infiltration * dt * _pitLevel;
    final next = (_pitLevel + inflow - outflow).clamp(0.0, 1.0);
    if ((next - _pitLevel).abs() > 0.0005) {
      setState(() => _pitLevel = next);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_tick);
    _ctrl.dispose();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _testRunning = true;
      _testStart = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Surface Water Soakaway',
      summary:
          'A cross-section of a soakaway taking roof run-off into the ground. Switch soil type and pit construction to see how percolation rate, BRE 365 testing and overflow strategy change.',
      controls: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Soil: '),
          ChoiceChip(
            label: const Text('Sand'),
            selected: _soil == _Soil.sand,
            onSelected: (_) => setState(() => _soil = _Soil.sand),
          ),
          const SizedBox(width: 4),
          ChoiceChip(
            label: const Text('Loam'),
            selected: _soil == _Soil.loam,
            onSelected: (_) => setState(() => _soil = _Soil.loam),
          ),
          const SizedBox(width: 4),
          ChoiceChip(
            label: const Text('Clay'),
            selected: _soil == _Soil.clay,
            onSelected: (_) => setState(() => _soil = _Soil.clay),
          ),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Type: '),
          ChoiceChip(
            label: const Text('Rubble'),
            selected: _type == _PitType.rubble,
            onSelected: (_) => setState(() => _type = _PitType.rubble),
          ),
          const SizedBox(width: 4),
          ChoiceChip(
            label: const Text('Crate'),
            selected: _type == _PitType.crate,
            onSelected: (_) => setState(() => _type = _PitType.crate),
          ),
        ]),
        ElevatedButton.icon(
          onPressed: _testRunning ? null : _startTest,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start test discharge'),
        ),
      ],
      diagramBuilder: (context, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _SoakawayPainter(
              step: stepIndex,
              t: _ctrl.value,
              soil: _soil,
              type: _type,
              level: _pitLevel,
              testing: _testRunning,
            ),
            size: Size.infinite,
          ),
        );
      },
      steps: const [
        SimStep(
          title: 'Purpose',
          narration:
              'A soakaway disperses roof and yard run-off into the ground rather than the public sewer. It reduces sewer load and replicates the natural soakage of an undeveloped site.',
        ),
        SimStep(
          title: 'Site investigation',
          narration:
              'Before designing, dig a trial pit to confirm soil layers and the seasonal water table. The soakaway must sit at least five metres from buildings and outside any boundary.',
        ),
        SimStep(
          title: 'BRE 365 percolation test',
          narration:
              'BRE digest 365 specifies three sequential percolation tests in a soaked pit. The slowest of the three runs is taken as the design rate to give a conservative result.',
        ),
        SimStep(
          title: 'Sizing',
          narration:
              'Soakaway volume equals design rainfall times catchment area divided by the soil infiltration rate. A higher rate means a smaller pit; clay sites grow large quickly.',
        ),
        SimStep(
          title: 'Construction',
          narration:
              'A traditional soakaway is filled with washed rubble, while modern sites use plastic crates that hold a much higher void ratio. Both are wrapped in geotextile membrane.',
        ),
        SimStep(
          title: 'Inlet pipe and inspection',
          narration:
              'A surface water drain enters via an inspection chamber with a rodding eye. That access lets you clear a blocked inlet without digging up the whole soakaway pit.',
        ),
        SimStep(
          title: 'Overflow strategy',
          narration:
              'Where soil is clay or the water table is high, an overflow runs to a watercourse with environmental consent. Plan that route at the start, never as an afterthought.',
        ),
        SimStep(
          title: 'Don\'t do this',
          narration:
              'Never place a soakaway within five metres of a foundation or boundary. Avoid contaminated land and remember soakaways are for surface water only, never foul effluent.',
        ),
        SimStep(
          title: 'Maintenance',
          narration:
              'Fit a silt trap upstream to catch grit before it clogs the gravel. Periodic jetting of the inlet and a check after very wet winters keep the system working long term.',
        ),
      ],
    );
  }
}

class _SoakawayPainter extends CustomPainter {
  final int step;
  final double t;
  final _Soil soil;
  final _PitType type;
  final double level;
  final bool testing;
  _SoakawayPainter({
    required this.step,
    required this.t,
    required this.soil,
    required this.type,
    required this.level,
    required this.testing,
  });

  static const Color grass = Color(0xFF4F8B3B);
  static const Color topsoil = Color(0xFF6B4226);
  static const Color subsoil = Color(0xFF8B5A2B);
  static const Color parent = Color(0xFFA17554);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky band (small)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.12),
      Paint()..color = const Color(0xFFCFE3F2).withValues(alpha: 0.5),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.12, w, h * 0.04),
      Paint()..color = grass,
    );

    // Soil layers
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.16, w, h * 0.18),
      Paint()..color = topsoil,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.34, w, h * 0.28),
      Paint()..color = subsoil,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.62, w, h * 0.38),
      Paint()..color = parent,
    );
    PipePainterHelpers.drawLabel(canvas, Offset(8, h * 0.18), 'Topsoil');
    PipePainterHelpers.drawLabel(
        canvas, Offset(8, h * 0.36), 'Subsoil  k = ${_kSubsoil()}');
    PipePainterHelpers.drawLabel(
        canvas, Offset(8, h * 0.64), 'Parent material');

    // Back-inlet gully (top left)
    final gully = Rect.fromLTWH(w * 0.18, h * 0.115, 30, 18);
    canvas.drawRect(gully, Paint()..color = Colors.grey.shade700);
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(gully.left + 4 + i * 6, gully.top + 2),
        Offset(gully.left + 4 + i * 6, gully.top + 8),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1.4,
      );
    }
    PipePainterHelpers.drawLabel(
        canvas, Offset(gully.left - 8, gully.top - 18), 'Back-inlet gully');

    // Inspection chamber + rodding eye
    final icRect = Rect.fromLTWH(w * 0.32, h * 0.12, 22, h * 0.18);
    canvas.drawRect(icRect, Paint()..color = const Color(0xFFB8BEC7));
    canvas.drawRect(
      icRect,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawRect(
      Rect.fromLTWH(icRect.left + 3, icRect.top - 4, icRect.width - 6, 4),
      Paint()..color = Colors.black87,
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(icRect.right + 4, icRect.top - 4),
        'Inspection chamber + rodding eye');

    // Pipe from gully to inspection chamber and onto soakaway pit
    final pipeA = Offset(gully.right, gully.center.dy);
    final pipeB = Offset(icRect.left, h * 0.18);
    PipePainterHelpers.drawPipe(
      canvas,
      a: pipeA,
      b: pipeB,
      color: AppColors.coldWater,
      width: 10,
    );

    final pipeC = Offset(icRect.right, h * 0.26);
    final pitRect = Rect.fromLTWH(w * 0.5, h * 0.36, w * 0.34, h * 0.32);
    final pipeD = Offset(pitRect.left + 14, pitRect.top + 14);
    PipePainterHelpers.drawPipe(
      canvas,
      a: pipeC,
      b: Offset(pipeD.dx, pipeC.dy),
      color: AppColors.coldWater,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(pipeD.dx, pipeC.dy),
      b: pipeD,
      color: AppColors.coldWater,
      width: 10,
    );

    // Geotextile (slightly larger rounded rect)
    final geoRect = pitRect.inflate(8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(geoRect, const Radius.circular(6)),
      Paint()
        ..color = const Color(0xFFEFD9A4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Free-draining gravel surround between geo and pit
    canvas.drawRRect(
      RRect.fromRectAndRadius(geoRect, const Radius.circular(6)),
      Paint()..color = const Color(0xFFD2B48C).withValues(alpha: 0.85),
    );

    // Pit (rubble or crate)
    if (type == _PitType.rubble) {
      canvas.drawRect(pitRect, Paint()..color = const Color(0xFFB0B6BE));
      final rng = math.Random(3);
      for (int i = 0; i < 80; i++) {
        final p = Offset(
          pitRect.left + rng.nextDouble() * pitRect.width,
          pitRect.top + rng.nextDouble() * pitRect.height,
        );
        canvas.drawCircle(
          p,
          rng.nextDouble() * 4 + 3,
          Paint()..color = Color.lerp(Colors.grey.shade700,
              Colors.grey.shade400, rng.nextDouble())!,
        );
      }
    } else {
      // Crate grid
      canvas.drawRect(pitRect, Paint()..color = const Color(0xFF1F2A33));
      final cellW = pitRect.width / 6;
      final cellH = pitRect.height / 4;
      final stroke = Paint()
        ..color = const Color(0xFF7A8593)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      for (int i = 0; i <= 6; i++) {
        canvas.drawLine(
          Offset(pitRect.left + i * cellW, pitRect.top),
          Offset(pitRect.left + i * cellW, pitRect.bottom),
          stroke,
        );
      }
      for (int j = 0; j <= 4; j++) {
        canvas.drawLine(
          Offset(pitRect.left, pitRect.top + j * cellH),
          Offset(pitRect.right, pitRect.top + j * cellH),
          stroke,
        );
      }
    }

    // Water in pit
    final waterTop = pitRect.bottom - pitRect.height * level;
    canvas.drawRect(
      Rect.fromLTRB(
          pitRect.left + 2, waterTop, pitRect.right - 2, pitRect.bottom - 2),
      Paint()..color = AppColors.coldWater.withValues(alpha: 0.55),
    );

    // Outward percolation arrows decaying with time
    final arrowPaint = Paint()
      ..color = AppColors.coldWater.withValues(alpha: 0.85)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final arrowDirs = <Offset>[
      const Offset(1, 0.4),
      const Offset(1, -0.2),
      const Offset(-1, 0.4),
      const Offset(-1, -0.2),
      const Offset(0, 1),
      const Offset(0.6, 1),
      const Offset(-0.6, 1),
    ];
    final intensity = (level * (soil == _Soil.clay ? 0.3 : 1.0)).clamp(0.0, 1.0);
    for (int i = 0; i < arrowDirs.length; i++) {
      final dir = arrowDirs[i];
      final start = pitRect.center +
          Offset(dir.dx * pitRect.width * 0.5, dir.dy * pitRect.height * 0.5);
      final phase = (t + i * 0.15) % 1.0;
      final reach = 14 + 14 * intensity;
      final end = start + Offset(dir.dx * reach * phase, dir.dy * reach * phase);
      canvas.drawLine(
          start, end, arrowPaint..color = AppColors.coldWater
            .withValues(alpha: (0.85 * (1 - phase)) * intensity));
      // arrow head
      final hd = (end - start);
      final ang = math.atan2(hd.dy, hd.dx);
      final tip1 = end + Offset(math.cos(ang + math.pi - 0.4) * 4,
          math.sin(ang + math.pi - 0.4) * 4);
      final tip2 = end + Offset(math.cos(ang + math.pi + 0.4) * 4,
          math.sin(ang + math.pi + 0.4) * 4);
      canvas.drawLine(end, tip1, arrowPaint);
      canvas.drawLine(end, tip2, arrowPaint);
    }

    // Inflow particles when testing
    if (testing) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: pipeA,
        b: pipeB,
        progress: t,
        color: Colors.white,
        count: 5,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(pipeD.dx, pipeC.dy),
        b: pipeD,
        progress: t,
        color: Colors.white,
        count: 4,
      );
    }

    // Overflow path (dotted) to a watercourse if clay
    final ofStart = Offset(pitRect.right, pitRect.top + 12);
    final ofEnd = Offset(w * 0.97, h * 0.95);
    final dotPaint = Paint()
      ..color = soil == _Soil.clay
          ? AppColors.coldWater
          : Colors.black38
      ..strokeWidth = 2.2;
    final segs = 26;
    for (int i = 0; i < segs; i += 2) {
      final a = Offset.lerp(ofStart, ofEnd, i / segs)!;
      final b = Offset.lerp(ofStart, ofEnd, (i + 1) / segs)!;
      canvas.drawLine(a, b, dotPaint);
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ofEnd.dx - 110, ofEnd.dy - 18),
      'Overflow to watercourse',
      background: soil == _Soil.clay ? AppColors.accent : Colors.white,
      textColor: soil == _Soil.clay ? Colors.white : AppColors.text,
    );

    // BRE 365 test inset (top right)
    final inset = Rect.fromLTWH(w * 0.62, 8, w * 0.34, h * 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inset, const Radius.circular(8)),
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(inset, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(inset.left + 6, inset.top - 16), 'BRE 365 inset');
    // 3 small pits
    for (int i = 0; i < 3; i++) {
      final pr = Rect.fromLTWH(
          inset.left + 14 + i * (inset.width / 3.6), inset.top + 22,
          inset.width / 5, inset.height - 36);
      canvas.drawRect(pr, Paint()..color = const Color(0xFFC8B79A));
      final fill = (math.sin((t + i * 0.33) * math.pi * 2) * 0.5 + 0.5);
      final fillH = pr.height * (1 - fill * 0.7);
      canvas.drawRect(
        Rect.fromLTRB(pr.left + 2, pr.top + fillH, pr.right - 2, pr.bottom - 2),
        Paint()..color = AppColors.coldWater.withValues(alpha: 0.7),
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(pr.left, pr.bottom + 2),
        'Test ${i + 1}',
        fontSize: 9,
      );
    }

    // 5 m clearance reminder line
    final clearY = h * 0.96;
    canvas.drawLine(
      Offset(w * 0.05, clearY),
      Offset(w * 0.45, clearY),
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.7)
        ..strokeWidth = 1.5,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.05, clearY - 16),
      '>= 5 m from buildings/boundary',
    );

    // Labels
    PipePainterHelpers.drawLabel(canvas,
        Offset(pitRect.left, pitRect.top - 16),
        type == _PitType.rubble ? 'Rubble pit' : 'Crate pit');
    PipePainterHelpers.drawLabel(
        canvas, Offset(geoRect.right - 70, geoRect.bottom + 4),
        'Geotextile + gravel');
    PipePainterHelpers.drawLabel(
        canvas, Offset(pipeD.dx + 6, pipeD.dy - 12), 'Inlet pipe');

    // Soil indicator
    final soilLabel = switch (soil) {
      _Soil.sand => 'Sand: fast (k ~ 1e-4 m/s)',
      _Soil.loam => 'Loam: moderate (k ~ 1e-5)',
      _Soil.clay => 'Clay: very slow (k ~ 1e-7)',
    };
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.5, h * 0.04),
      soilLabel,
      background: AppColors.primary,
      textColor: Colors.white,
    );

    // Step highlights
    final boxes = <int, Rect>{
      1: Rect.fromLTRB(w * 0.04, h * 0.92, w * 0.46, h * 0.99),
      2: inset.inflate(4),
      3: pitRect.inflate(10),
      4: pitRect.inflate(2),
      5: Rect.fromLTRB(icRect.left - 4, icRect.top - 8,
          pipeD.dx + 10, pipeD.dy + 14),
      6: Rect.fromLTRB(ofStart.dx - 4, ofStart.dy - 6, ofEnd.dx + 4,
          ofEnd.dy + 4),
      7: Rect.fromLTRB(w * 0.04, h * 0.92, w * 0.46, h * 0.99),
    };
    final hb = boxes[step];
    if (hb != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(hb, const Radius.circular(8)),
        Paint()
          ..color = AppColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }
  }

  String _kSubsoil() {
    return switch (soil) {
      _Soil.sand => '1e-4 m/s',
      _Soil.loam => '1e-5 m/s',
      _Soil.clay => '1e-7 m/s',
    };
  }

  @override
  bool shouldRepaint(covariant _SoakawayPainter o) => true;
}

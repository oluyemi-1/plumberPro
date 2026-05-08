import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum _ScMode { timer, thermostat }

class SecondaryCirculationSimScreen extends StatefulWidget {
  const SecondaryCirculationSimScreen({super.key});
  @override
  State<SecondaryCirculationSimScreen> createState() =>
      _SecondaryCirculationSimScreenState();
}

class _SecondaryCirculationSimScreenState
    extends State<SecondaryCirculationSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _pumpRunning = true;
  _ScMode _mode = _ScMode.timer;

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
      title: 'Why a secondary loop',
      narration:
          'Long pipe runs to remote outlets create dead-legs, wasting water and time waiting for hot. A secondary circulation loop keeps a steady flow of hot water near every tap so it arrives within a few seconds.',
    ),
    SimStep(
      title: 'Components',
      narration:
          'The loop needs a small bronze circulator pump, a non-return valve to prevent reverse flow, and a controller. The controller can be a simple timeclock or a thermostat that watches return temperature.',
    ),
    SimStep(
      title: 'Pump operation cycles',
      narration:
          'A typical timer runs 30 minutes on and 30 off during the day. Thermostatic control instead starts the pump only when return temperature drops below around 55 degrees Celsius, saving energy.',
    ),
    SimStep(
      title: 'Effect on Legionella',
      narration:
          'Return temperature into the cylinder must stay above 50 degrees Celsius to suppress Legionella growth. Run a periodic pasteurisation cycle to 60 degrees on the cylinder if any tepid points are suspected.',
    ),
    SimStep(
      title: 'Pipe sizing and insulation',
      narration:
          'Use generous sizing on the flow and a smaller return, all fully insulated to maintain temperature. Poor insulation drops return temperature, makes the pump run longer, and wastes energy.',
    ),
    SimStep(
      title: 'Balancing',
      narration:
          'A balancing valve or fixed orifice on the return prevents the pump short-circuiting through close-by branches. Without it, distant outlets stay cool while the nearest ones run hot.',
    ),
    SimStep(
      title: 'Energy cost vs comfort',
      narration:
          'A continuously running pump can cost noticeable energy in standing losses. Trade comfort for efficiency with timeclocks, thermostats, demand sensors or BMS occupancy signals.',
    ),
    SimStep(
      title: 'Common faults',
      narration:
          'Air locks at the highest point stop circulation, a sticking non-return valve causes reverse flow when the pump is off, and scaled pump impellers reduce flow. Check temperature drop across the pump as a diagnostic.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Secondary hot water circulation',
      summary:
          'See how a secondary return loop keeps hot water close to every outlet, with a circulator pump, non-return valve and controller, plus the effect on Legionella, energy and comfort.',
      steps: _steps,
      onStepChanged: (_) => setState(() {}),
      controls: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pump running'),
            Switch.adaptive(
              value: _pumpRunning,
              onChanged: (v) => setState(() => _pumpRunning = v),
            ),
          ],
        ),
        ChoiceChip(
          label: const Text('Timer mode'),
          selected: _mode == _ScMode.timer,
          onSelected: (_) => setState(() => _mode = _ScMode.timer),
        ),
        ChoiceChip(
          label: const Text('Thermostat mode'),
          selected: _mode == _ScMode.thermostat,
          onSelected: (_) => setState(() => _mode = _ScMode.thermostat),
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _SecCircPainter(
            step: i,
            t: _ctrl.value,
            pump: _pumpRunning,
            mode: _mode,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SecCircPainter extends CustomPainter {
  final int step;
  final double t;
  final bool pump;
  final _ScMode mode;
  _SecCircPainter({
    required this.step,
    required this.t,
    required this.pump,
    required this.mode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEFF4F8),
    );

    // ----- Cylinder on the left -----
    final cylRect = Rect.fromLTWH(w * 0.06, h * 0.35, w * 0.16, h * 0.5);
    final body = Paint()..color = const Color(0xFFD8DDE3);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cylRect, const Radius.circular(14)),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cylRect, const Radius.circular(14)),
      stroke,
    );
    canvas.drawRect(
      cylRect.deflate(4),
      Paint()..color = AppColors.hotWater.withValues(alpha: 0.45),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cylRect.left, cylRect.top - 18),
      'Hot water cylinder',
    );

    // Hot top draw-off rises and runs across
    final hotTop = Offset(cylRect.center.dx, cylRect.top - 4);
    final riserTop = Offset(cylRect.center.dx, h * 0.18);
    final acrossRight = Offset(w * 0.92, h * 0.18);
    PipePainterHelpers.drawPipe(
      canvas,
      a: hotTop,
      b: riserTop,
      color: AppColors.hotWater,
      width: 12,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: riserTop,
      b: acrossRight,
      color: AppColors.hotWater,
      width: 12,
    );

    // Three outlet drops
    final outlets = <_OutletDef>[
      _OutletDef(Offset(w * 0.45, h * 0.18), 'Kitchen', h * 0.36),
      _OutletDef(Offset(w * 0.65, h * 0.18), 'Basin', h * 0.36),
      _OutletDef(Offset(w * 0.85, h * 0.18), 'Shower', h * 0.36),
    ];

    // Cooling factor for distant outlets when pump off
    for (int i = 0; i < outlets.length; i++) {
      final o = outlets[i];
      // distance factor 0..1 (0 nearest)
      final df = i / (outlets.length - 1);
      // when pump on, all hot; when pump off, distal taps cool over time
      final hotness = pump ? 1.0 : (1.0 - 0.7 * df);
      final color = Color.lerp(
        AppColors.coldWater,
        AppColors.hotWater,
        hotness,
      )!;
      PipePainterHelpers.drawPipe(
        canvas,
        a: o.top,
        b: Offset(o.top.dx, o.bottomY),
        color: color,
        width: 10,
      );
      // Outlet symbol (tap)
      _drawTap(canvas, Offset(o.top.dx, o.bottomY));
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(o.top.dx - 18, o.bottomY + 18),
        o.name,
      );
      PipePainterHelpers.drawJoint(canvas, o.top);
    }

    // Secondary return runs from last outlet back near cylinder, mid-cylinder
    final lastOutlet = outlets.last.top;
    final returnRiseTop = Offset(lastOutlet.dx, h * 0.06);
    final returnLeft = Offset(w * 0.32, h * 0.06);
    final pumpP = Offset(w * 0.32, h * 0.55);
    final cylMidIn = Offset(cylRect.right + 4, cylRect.center.dy);

    PipePainterHelpers.drawPipe(
      canvas,
      a: lastOutlet,
      b: returnRiseTop,
      color: AppColors.hotWater.withValues(alpha: 0.7),
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: returnRiseTop,
      b: returnLeft,
      color: AppColors.hotWater.withValues(alpha: 0.7),
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: returnLeft,
      b: pumpP,
      color: AppColors.hotWater.withValues(alpha: 0.7),
      width: 8,
    );
    // pump to cylinder
    final nrvP = Offset((pumpP.dx + cylMidIn.dx) / 2, cylMidIn.dy);
    PipePainterHelpers.drawPipe(
      canvas,
      a: pumpP,
      b: Offset(pumpP.dx, cylMidIn.dy),
      color: AppColors.hotWater.withValues(alpha: 0.7),
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(pumpP.dx, cylMidIn.dy),
      b: cylMidIn,
      color: AppColors.hotWater.withValues(alpha: 0.7),
      width: 8,
    );

    // Pump body
    _drawPump(canvas, pumpP, pump, t);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pumpP.dx - 36, pumpP.dy + 22),
      'Circulator pump',
    );

    // Non-return valve
    _drawNRV(canvas, nrvP);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(nrvP.dx - 36, nrvP.dy + 14),
      'Non-return valve',
    );

    // Controller box
    final ctrlP = Offset(w * 0.18, h * 0.6);
    _drawController(canvas, ctrlP, mode);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ctrlP.dx - 30, ctrlP.dy + 26),
      mode == _ScMode.timer ? 'Timeclock' : 'Thermostat',
    );

    // Cold mains entry to cylinder bottom
    final coldIn = Offset(w * 0.04, cylRect.bottom - 12);
    final coldElbow = Offset(cylRect.left - 4, cylRect.bottom - 12);
    PipePainterHelpers.drawPipe(
      canvas,
      a: coldIn,
      b: coldElbow,
      color: AppColors.coldWater,
      width: 8,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(coldIn.dx - 4, coldIn.dy + 12),
      'Cold mains',
    );

    // Animate flow only when pump running
    if (pump) {
      // Riser and across
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: hotTop,
        b: riserTop,
        progress: t,
        color: Colors.white,
        count: 4,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: riserTop,
        b: acrossRight,
        progress: t,
        color: Colors.white,
        count: 7,
      );
      // Return path
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: lastOutlet,
        b: returnRiseTop,
        progress: t,
        color: Colors.white,
        count: 3,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: returnRiseTop,
        b: returnLeft,
        progress: t,
        color: Colors.white,
        count: 5,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: returnLeft,
        b: pumpP,
        progress: t,
        color: Colors.white,
        count: 4,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: pumpP,
        b: cylMidIn,
        progress: t,
        color: Colors.white,
        count: 4,
      );
    }

    // Step badge
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, 12),
      'Step ${step + 1}',
      background: AppColors.primary.withValues(alpha: 0.15),
    );

    // Status badge
    final running = pump ? 'Pump: ON (${mode == _ScMode.timer ? "timer" : "stat"})' : 'Pump: OFF';
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w - 130, 12),
      running,
      background: pump
          ? Colors.green.withValues(alpha: 0.2)
          : Colors.grey.withValues(alpha: 0.2),
    );
  }

  void _drawTap(Canvas canvas, Offset p) {
    final body = Rect.fromLTWH(p.dx - 8, p.dy, 16, 10);
    canvas.drawRect(body, Paint()..color = AppColors.brass);
    canvas.drawRect(
      body,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(p.dx, p.dy - 4),
      3.5,
      Paint()..color = AppColors.brass,
    );
  }

  void _drawPump(Canvas canvas, Offset p, bool running, double t) {
    final r = 14.0;
    canvas.drawCircle(p, r, Paint()..color = const Color(0xFF2A4F73));
    canvas.drawCircle(
      p,
      r,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // impeller blades
    final angle = running ? t * 6.2831853 : 0.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      final a = angle + i * 2.094;
      final dx = (r - 3) * (a.remainder(6.2831853) < 3.14 ? 1 : -1);
      final p1 = PipePainterHelpers.rotate(
        Offset(p.dx + r - 3, p.dy),
        p,
        angle + i * 2.094,
      );
      final p2 = PipePainterHelpers.rotate(
        Offset(p.dx - r + 3, p.dy),
        p,
        angle + i * 2.094,
      );
      canvas.drawLine(p1, p2, paint);
      // suppress unused
      // ignore: unused_local_variable
      final _ = dx;
    }
  }

  void _drawNRV(Canvas canvas, Offset p) {
    final r = Rect.fromCenter(center: p, width: 22, height: 14);
    canvas.drawRect(r, Paint()..color = AppColors.brass);
    canvas.drawRect(
      r,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    final path = Path()
      ..moveTo(p.dx - 5, p.dy - 4)
      ..lineTo(p.dx + 5, p.dy)
      ..lineTo(p.dx - 5, p.dy + 4)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  void _drawController(Canvas canvas, Offset p, _ScMode mode) {
    final r = Rect.fromCenter(center: p, width: 56, height: 36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(6)),
      Paint()..color = const Color(0xFF233646),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(6)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    // small indicator
    final ind = Rect.fromCenter(center: p, width: 38, height: 18);
    canvas.drawRect(
      ind,
      Paint()..color = AppColors.gas.withValues(alpha: 0.85),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: mode == _ScMode.timer ? '06-22' : '55C',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(ind.center.dx - tp.width / 2, ind.center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_SecCircPainter o) =>
      o.step != step || o.t != t || o.pump != pump || o.mode != mode;
}

class _OutletDef {
  final Offset top;
  final String name;
  final double bottomY;
  _OutletDef(this.top, this.name, this.bottomY);
}

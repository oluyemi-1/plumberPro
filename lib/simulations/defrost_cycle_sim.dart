import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum DefrostMode { mild, coldHumid, subZero }

enum DefrostPhase { heating, defrost, recovery }

class DefrostCycleSimScreen extends StatefulWidget {
  const DefrostCycleSimScreen({super.key});
  @override
  State<DefrostCycleSimScreen> createState() => _DefrostCycleSimScreenState();
}

class _DefrostCycleSimScreenState extends State<DefrostCycleSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  DefrostMode _mode = DefrostMode.coldHumid;
  double _compressor = 0.7;
  DefrostPhase _phase = DefrostPhase.heating;
  double _frost = 0.0;
  double _flowTemp = 45.0;
  double _phaseTimer = 0.0;
  bool _forceDefrostRequested = false;

  double _lastTick = 0.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _ctrl.addListener(_advance);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_advance);
    _ctrl.dispose();
    super.dispose();
  }

  double _frostRate() {
    switch (_mode) {
      case DefrostMode.mild:
        return 0.012 * _compressor;
      case DefrostMode.coldHumid:
        return 0.06 * _compressor;
      case DefrostMode.subZero:
        return 0.025 * _compressor;
    }
  }

  double _defrostThreshold() {
    switch (_mode) {
      case DefrostMode.mild:
        return 0.85;
      case DefrostMode.coldHumid:
        return 0.7;
      case DefrostMode.subZero:
        return 0.78;
    }
  }

  double _defrostDuration() {
    switch (_mode) {
      case DefrostMode.mild:
        return 2.0;
      case DefrostMode.coldHumid:
        return 3.0;
      case DefrostMode.subZero:
        return 4.5;
    }
  }

  void _advance() {
    final now = _ctrl.value;
    double dt = now - _lastTick;
    if (dt < 0) dt += 1.0;
    _lastTick = now;
    final ticks = dt * _ctrl.duration!.inSeconds;

    setState(() {
      _phaseTimer += ticks;
      switch (_phase) {
        case DefrostPhase.heating:
          _frost += _frostRate() * ticks;
          if (_frost > 1.0) _frost = 1.0;
          _flowTemp += (45.0 - _flowTemp) * 0.1 * ticks;
          if (_forceDefrostRequested || _frost >= _defrostThreshold()) {
            _phase = DefrostPhase.defrost;
            _phaseTimer = 0;
            _forceDefrostRequested = false;
          }
          break;
        case DefrostPhase.defrost:
          _frost -= (1.0 / _defrostDuration()) * ticks;
          if (_frost < 0) _frost = 0;
          _flowTemp -= 4 * ticks;
          if (_flowTemp < 18) _flowTemp = 18;
          if (_phaseTimer >= _defrostDuration() && _frost < 0.05) {
            _phase = DefrostPhase.recovery;
            _phaseTimer = 0;
          }
          break;
        case DefrostPhase.recovery:
          _flowTemp += (45.0 - _flowTemp) * 0.18 * ticks;
          _frost += _frostRate() * 0.4 * ticks;
          if (_phaseTimer >= 2.5) {
            _phase = DefrostPhase.heating;
            _phaseTimer = 0;
          }
          break;
      }
    });
  }

  String _modeLabel(DefrostMode m) {
    switch (m) {
      case DefrostMode.mild:
        return 'Mild +5°C, low RH';
      case DefrostMode.coldHumid:
        return 'Cold humid 0°C, 90% RH';
      case DefrostMode.subZero:
        return 'Sub-zero -5°C';
    }
  }

  String _phaseLabel() {
    switch (_phase) {
      case DefrostPhase.heating:
        return 'HEATING';
      case DefrostPhase.defrost:
        return 'DEFROST';
      case DefrostPhase.recovery:
        return 'RECOVERY';
    }
  }

  Color _phaseColor() {
    switch (_phase) {
      case DefrostPhase.heating:
        return AppColors.hotWater;
      case DefrostPhase.defrost:
        return AppColors.coldWater;
      case DefrostPhase.recovery:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Defrost Cycle',
      summary:
          'An air-source heat pump must shed frost from its evaporator. '
          'Watch the 4-way valve flip, the indoor flow dip, and the condensate '
          'shed during a reverse-cycle defrost.',
      onStepChanged: (_) => setState(() {}),
      controls: [
        _StatusBanner(
            label: _phaseLabel(),
            color: _phaseColor(),
            frost: _frost,
            flow: _flowTemp),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: DefrostMode.values
              .map((m) => ChoiceChip(
                    label: Text(_modeLabel(m),
                        style: const TextStyle(fontSize: 11)),
                    selected: _mode == m,
                    onSelected: (_) => setState(() => _mode = m),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.ac_unit, size: 18),
                label: const Text('Force defrost'),
                onPressed: _phase == DefrostPhase.heating
                    ? () => setState(() => _forceDefrostRequested = true)
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Compressor speed',
                  style: TextStyle(color: AppColors.text, fontSize: 12)),
              Text('${(_compressor * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Slider(
          min: 0.2,
          max: 1.0,
          value: _compressor,
          onChanged: (v) => setState(() => _compressor = v),
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _DefrostPainter(
            step: i,
            t: _ctrl.value,
            mode: _mode,
            phase: _phase,
            frost: _frost,
            flow: _flowTemp,
            compressor: _compressor,
          ),
          size: Size.infinite,
        ),
      ),
      steps: const [
        SimStep(
          title: 'Why defrost is needed',
          narration:
              'Below about +7 °C with humid air the evaporator drops below '
              'dew-point and frost forms. Frost insulates the coil, blocks '
              'airflow and starves the refrigerant of heat.',
        ),
        SimStep(
          title: 'Frost formation',
          narration:
              'Water vapour deposits as ice on the cold fins. The colder and '
              'wetter the air, the faster the build-up. Watch the white frost '
              'thicken on the evaporator as the cycle runs.',
        ),
        SimStep(
          title: 'Defrost trigger',
          narration:
              'Triggers vary: coil temperature falling below a threshold, time '
              'in heating mode, or a demand-based algorithm comparing expected '
              'and actual capacity.',
        ),
        SimStep(
          title: 'Reverse-cycle defrost',
          narration:
              'The 4-way reversing valve flips the refrigerant flow. The '
              'outdoor coil becomes the condenser, hot gas melts the frost, and '
              'the indoor coil becomes the evaporator briefly.',
        ),
        SimStep(
          title: 'Indoor effect',
          narration:
              'Flow temperature drops sharply because the indoor side is now '
              'absorbing heat. A buffer cylinder smooths this dip, protecting '
              'comfort and preventing nuisance low-temperature alarms.',
        ),
        SimStep(
          title: 'Condensate management',
          narration:
              'Melt-water runs from the coil into a base tray and out through '
              'a drain. The tray often contains a trace heater to stop ice '
              'plugging the drain in cold weather.',
        ),
        SimStep(
          title: 'Frost protection of the drain',
          narration:
              'Outside, the condensate pipe must be insulated and ideally '
              'discharged below ground or into a soakaway. A frozen drain '
              'backs up into the unit and can cause repeat fault lock-outs.',
        ),
        SimStep(
          title: 'Recovery and SCOP impact',
          narration:
              'After defrost the system spends 5-10 minutes rebuilding flow '
              'temperature. Frequent defrosts hurt SCOP, so good airflow and '
              'siting matter as much as the controller settings.',
        ),
        SimStep(
          title: 'Common faults',
          narration:
              'A stuck reversing valve halts defrost mid-cycle. A blocked '
              'condensate drain causes ice-up. A failing temperature sensor '
              'can leave the unit defrosting forever or never at all.',
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String label;
  final Color color;
  final double frost;
  final double flow;
  const _StatusBanner({
    required this.label,
    required this.color,
    required this.frost,
    required this.flow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _bar('Frost', frost, AppColors.coldWater)),
              const SizedBox(width: 8),
              Expanded(
                child: _bar('Flow',
                    ((flow - 15) / 35).clamp(0.0, 1.0), AppColors.hotWater,
                    valueText: '${flow.toStringAsFixed(1)}°C'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(String label, double v, Color c, {String? valueText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            Text(valueText ?? '${(v * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    color: c, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: v,
            minHeight: 6,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation(c),
          ),
        ),
      ],
    );
  }
}

class _DefrostPainter extends CustomPainter {
  final int step;
  final double t;
  final DefrostMode mode;
  final DefrostPhase phase;
  final double frost;
  final double flow;
  final double compressor;

  _DefrostPainter({
    required this.step,
    required this.t,
    required this.mode,
    required this.phase,
    required this.frost,
    required this.flow,
    required this.compressor,
  });

  bool get _reversed => phase == DefrostPhase.defrost;

  @override
  void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..color = AppColors.surface);

    final outdoorRect =
        Rect.fromLTWH(20, 30, s.width * 0.55 - 30, s.height - 60);
    final indoorRect = Rect.fromLTWH(
        s.width * 0.55 + 10, 30, s.width * 0.45 - 30, s.height - 60);

    _drawOutdoor(c, outdoorRect);
    _drawIndoor(c, indoorRect);
    _drawConnections(c, outdoorRect, indoorRect);
    _drawStepHint(c, s);
  }

  void _drawOutdoor(Canvas c, Rect r) {
    c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(8)),
        Paint()..color = AppColors.cardBg);
    c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(8)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.muted
          ..strokeWidth = 1.5);
    PipePainterHelpers.drawLabel(
        c, Offset(r.left + 4, r.top - 14), 'Outdoor unit');

    final fanCenter = Offset(r.right - 50, r.top + 60);
    c.drawCircle(fanCenter, 30, Paint()..color = AppColors.surface);
    c.drawCircle(
        fanCenter,
        30,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.muted
          ..strokeWidth = 1.2);
    final fanA = t * 2 * math.pi * (4 + 4 * compressor);
    for (int b = 0; b < 4; b++) {
      final a = fanA + b * math.pi / 2;
      final p = Path()
        ..moveTo(fanCenter.dx, fanCenter.dy)
        ..lineTo(fanCenter.dx + math.cos(a) * 26,
            fanCenter.dy + math.sin(a) * 26)
        ..lineTo(fanCenter.dx + math.cos(a + 0.5) * 22,
            fanCenter.dy + math.sin(a + 0.5) * 22)
        ..close();
      c.drawPath(p, Paint()..color = AppColors.muted);
    }
    c.drawCircle(fanCenter, 4, Paint()..color = AppColors.brass);
    PipePainterHelpers.drawLabel(
        c, Offset(fanCenter.dx - 10, fanCenter.dy + 34), 'Fan');

    final coilRect = Rect.fromLTWH(r.left + 16, r.top + 24, 90, 90);
    final coilColor = _reversed ? AppColors.hotWater : AppColors.coldWater;
    c.drawRRect(
        RRect.fromRectAndRadius(coilRect, const Radius.circular(4)),
        Paint()..color = coilColor.withValues(alpha: 0.25));
    c.drawRRect(
        RRect.fromRectAndRadius(coilRect, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = coilColor
          ..strokeWidth = 1.5);
    for (double y = coilRect.top + 4; y < coilRect.bottom - 4; y += 5) {
      c.drawLine(
          Offset(coilRect.left + 2, y),
          Offset(coilRect.right - 2, y),
          Paint()
            ..color = coilColor.withValues(alpha: 0.5)
            ..strokeWidth = 1);
    }
    PipePainterHelpers.drawLabel(
        c,
        Offset(coilRect.left, coilRect.top - 12),
        _reversed ? 'Evap (now condenser)' : 'Evaporator coil');

    if (frost > 0.02) {
      final fLayer = Paint()
        ..color = Colors.white.withValues(alpha: 0.55 + 0.4 * frost);
      final fThick = 2 + frost * 14;
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(coilRect.left - fThick / 2,
                  coilRect.top - fThick / 2, coilRect.width + fThick, fThick),
              const Radius.circular(2)),
          fLayer);
      final rng = math.Random(42);
      for (int i = 0; i < (frost * 30).round(); i++) {
        final fx = coilRect.left + rng.nextDouble() * coilRect.width;
        final fy = coilRect.top + rng.nextDouble() * 6;
        c.drawCircle(Offset(fx, fy), 1.4 + rng.nextDouble() * 1.5,
            Paint()..color = Colors.white.withValues(alpha: 0.9));
      }
      PipePainterHelpers.drawLabel(
          c,
          Offset(coilRect.right + 4, coilRect.top + 4),
          'Frost ${(frost * 100).toStringAsFixed(0)}%');
    }

    final valveCenter = Offset(r.left + 60, r.bottom - 90);
    final vRect = Rect.fromCenter(center: valveCenter, width: 50, height: 36);
    c.drawRRect(
        RRect.fromRectAndRadius(vRect, const Radius.circular(4)),
        Paint()..color = AppColors.brass.withValues(alpha: 0.7));
    c.drawRRect(
        RRect.fromRectAndRadius(vRect, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.muted
          ..strokeWidth = 1.4);
    final arrowPaint = Paint()
      ..color = _reversed ? AppColors.coldWater : AppColors.hotWater
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    if (_reversed) {
      _arrow(c, Offset(vRect.left + 4, vRect.top + 8),
          Offset(vRect.right - 4, vRect.top + 8), arrowPaint);
      _arrow(c, Offset(vRect.right - 4, vRect.bottom - 8),
          Offset(vRect.left + 4, vRect.bottom - 8), arrowPaint);
    } else {
      _arrow(c, Offset(vRect.left + 4, vRect.top + 8),
          Offset(vRect.right - 4, vRect.bottom - 8), arrowPaint);
      _arrow(c, Offset(vRect.right - 4, vRect.top + 8),
          Offset(vRect.left + 4, vRect.bottom - 8), arrowPaint);
    }
    PipePainterHelpers.drawLabel(
        c, Offset(vRect.left - 8, vRect.bottom + 4), '4-way valve');

    final compCenter = Offset(r.left + 130, r.bottom - 70);
    c.drawCircle(compCenter, 18, Paint()..color = AppColors.pipeMetal);
    c.drawCircle(
        compCenter,
        18,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.muted
          ..strokeWidth = 1.4);
    final cpA = t * 2 * math.pi * (3 + 6 * compressor);
    c.drawLine(
        compCenter,
        Offset(compCenter.dx + math.cos(cpA) * 14,
            compCenter.dy + math.sin(cpA) * 14),
        Paint()
          ..color = AppColors.accent
          ..strokeWidth = 2);
    PipePainterHelpers.drawLabel(
        c, Offset(compCenter.dx - 24, compCenter.dy + 22), 'Compressor');

    final tray =
        Rect.fromLTWH(r.left + 10, r.bottom - 26, r.width - 60, 12);
    c.drawRRect(
        RRect.fromRectAndRadius(tray, const Radius.circular(3)),
        Paint()..color = AppColors.pipeMetal);
    c.drawRRect(
        RRect.fromRectAndRadius(tray, const Radius.circular(3)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.muted
          ..strokeWidth = 1);
    PipePainterHelpers.drawLabel(
        c, Offset(tray.left, tray.top - 12), 'Condensate tray');

    if (_reversed || phase == DefrostPhase.recovery) {
      final lvl = phase == DefrostPhase.defrost ? 0.7 : 0.3;
      c.drawRect(
          Rect.fromLTWH(tray.left + 2, tray.bottom - 4 - lvl * 6,
              tray.width - 4, 4 + lvl * 4),
          Paint()..color = AppColors.coldWater.withValues(alpha: 0.7));
    }

    final drainStart = Offset(tray.right - 14, tray.bottom);
    final drainEnd = Offset(drainStart.dx, r.bottom + 4);
    PipePainterHelpers.drawPipe(c,
        a: drainStart, b: drainEnd, color: AppColors.pipeMetal, width: 6);
    PipePainterHelpers.drawLabel(
        c, Offset(drainEnd.dx - 12, drainEnd.dy - 4), 'Drain');

    if (_reversed || phase == DefrostPhase.recovery) {
      final dripCount = phase == DefrostPhase.defrost ? 4 : 1;
      for (int i = 0; i < dripCount; i++) {
        final phase01 = (t + i * 0.25) % 1.0;
        final dy = drainEnd.dy + 6 + phase01 * 16;
        c.drawCircle(Offset(drainEnd.dx, dy), 2.4 - phase01 * 1.0,
            Paint()
              ..color = AppColors.coldWater.withValues(alpha: 1 - phase01));
      }
    }
  }

  void _drawIndoor(Canvas c, Rect r) {
    c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(8)),
        Paint()..color = AppColors.cardBg);
    c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(8)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.muted
          ..strokeWidth = 1.5);
    PipePainterHelpers.drawLabel(
        c, Offset(r.left + 4, r.top - 14), 'Indoor side');

    final bufRect =
        Rect.fromLTWH(r.left + 20, r.top + 30, 80, r.height - 100);
    final tNorm = ((flow - 18) / 30).clamp(0.0, 1.0);
    PipePainterHelpers.drawTank(c,
        rect: bufRect,
        level: 0.92,
        waterColor:
            Color.lerp(AppColors.coldWater, AppColors.hotWater, tNorm)!,
        label: 'Buffer cylinder');

    final tp = TextPainter(
        text: TextSpan(
            text: '${flow.toStringAsFixed(1)} °C',
            style: TextStyle(
                color: Color.lerp(
                    AppColors.coldWater, AppColors.hotWater, tNorm)!,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(c,
        Offset(bufRect.center.dx - tp.width / 2, bufRect.center.dy - 6));

    final heRect = Rect.fromLTWH(r.right - 70, r.top + 50, 50, 80);
    c.drawRRect(
        RRect.fromRectAndRadius(heRect, const Radius.circular(4)),
        Paint()
          ..color = (_reversed ? AppColors.coldWater : AppColors.hotWater)
              .withValues(alpha: 0.25));
    c.drawRRect(
        RRect.fromRectAndRadius(heRect, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = _reversed ? AppColors.coldWater : AppColors.hotWater
          ..strokeWidth = 1.5);
    for (double y = heRect.top + 6; y < heRect.bottom - 6; y += 6) {
      c.drawLine(
          Offset(heRect.left + 2, y),
          Offset(heRect.right - 2, y),
          Paint()
            ..color =
                (_reversed ? AppColors.coldWater : AppColors.hotWater)
                    .withValues(alpha: 0.6)
            ..strokeWidth = 1);
    }
    PipePainterHelpers.drawLabel(
        c,
        Offset(heRect.left - 10, heRect.bottom + 4),
        _reversed ? 'Indoor coil (evap)' : 'Indoor heat-ex');

    final flowPipeY = bufRect.top + 20;
    final retPipeY = bufRect.bottom - 20;
    PipePainterHelpers.drawPipe(c,
        a: Offset(bufRect.right, flowPipeY),
        b: Offset(heRect.left, flowPipeY),
        color: _reversed ? AppColors.coldWater : AppColors.hotWater,
        width: 6);
    PipePainterHelpers.drawPipe(c,
        a: Offset(bufRect.right, retPipeY),
        b: Offset(heRect.left, retPipeY),
        color: AppColors.coldWater,
        width: 6);

    if (phase != DefrostPhase.defrost || compressor > 0.2) {
      PipePainterHelpers.drawFlowParticles(c,
          a: Offset(bufRect.right, flowPipeY),
          b: Offset(heRect.left, flowPipeY),
          progress: t,
          color: _reversed
              ? AppColors.coldWater
              : AppColors.hotWater.withValues(alpha: 0.4 + 0.6 * tNorm),
          count: 4);
      PipePainterHelpers.drawFlowParticles(c,
          a: Offset(heRect.left, retPipeY),
          b: Offset(bufRect.right, retPipeY),
          progress: t,
          color: AppColors.coldWater.withValues(alpha: 0.7),
          count: 4);
    }

    if (_reversed) {
      PipePainterHelpers.drawLabel(
          c, Offset(bufRect.left, bufRect.bottom + 8), 'Flow dipping!');
    }
  }

  void _drawConnections(Canvas c, Rect outdoor, Rect indoor) {
    final outA = Offset(outdoor.right - 4, outdoor.top + 130);
    final outB = Offset(outdoor.right - 4, outdoor.top + 160);
    final inA = Offset(indoor.right - 40, indoor.top + 50);
    final inB = Offset(indoor.right - 40, indoor.top + 130);

    final hotCol = _reversed ? AppColors.coldWater : AppColors.hotWater;
    final colCol = _reversed ? AppColors.hotWater : AppColors.coldWater;

    PipePainterHelpers.drawPipe(c,
        a: outA,
        b: Offset(indoor.left - 4, outA.dy),
        color: hotCol,
        width: 5);
    PipePainterHelpers.drawPipe(c,
        a: Offset(indoor.left - 4, outA.dy),
        b: inA,
        color: hotCol,
        width: 5);

    PipePainterHelpers.drawPipe(c,
        a: outB,
        b: Offset(indoor.left - 4, outB.dy),
        color: colCol,
        width: 5);
    PipePainterHelpers.drawPipe(c,
        a: Offset(indoor.left - 4, outB.dy),
        b: inB,
        color: colCol,
        width: 5);

    if (_reversed) {
      PipePainterHelpers.drawFlowParticles(c,
          a: inA,
          b: Offset(indoor.left - 4, outA.dy),
          progress: t,
          color: AppColors.hotWater,
          count: 4);
      PipePainterHelpers.drawFlowParticles(c,
          a: Offset(indoor.left - 4, outA.dy),
          b: outA,
          progress: t,
          color: AppColors.hotWater,
          count: 4);
      PipePainterHelpers.drawFlowParticles(c,
          a: outB,
          b: Offset(indoor.left - 4, outB.dy),
          progress: t,
          color: AppColors.coldWater,
          count: 4);
      PipePainterHelpers.drawFlowParticles(c,
          a: Offset(indoor.left - 4, outB.dy),
          b: inB,
          progress: t,
          color: AppColors.coldWater,
          count: 4);
    } else {
      PipePainterHelpers.drawFlowParticles(c,
          a: outA,
          b: Offset(indoor.left - 4, outA.dy),
          progress: t,
          color: AppColors.hotWater,
          count: 4);
      PipePainterHelpers.drawFlowParticles(c,
          a: Offset(indoor.left - 4, outA.dy),
          b: inA,
          progress: t,
          color: AppColors.hotWater,
          count: 4);
      PipePainterHelpers.drawFlowParticles(c,
          a: inB,
          b: Offset(indoor.left - 4, outB.dy),
          progress: t,
          color: AppColors.coldWater,
          count: 4);
      PipePainterHelpers.drawFlowParticles(c,
          a: Offset(indoor.left - 4, outB.dy),
          b: outB,
          progress: t,
          color: AppColors.coldWater,
          count: 4);
    }

    PipePainterHelpers.drawLabel(
        c,
        Offset((outA.dx + indoor.left) / 2 - 24, outA.dy - 12),
        'Hot gas line');
    PipePainterHelpers.drawLabel(
        c,
        Offset((outB.dx + indoor.left) / 2 - 30, outB.dy + 6),
        'Liquid/suction line');
  }

  void _arrow(Canvas c, Offset a, Offset b, Paint p) {
    c.drawLine(a, b, p);
    final ang = math.atan2(b.dy - a.dy, b.dx - a.dx);
    final h1 = Offset(
        b.dx - math.cos(ang - 0.5) * 6, b.dy - math.sin(ang - 0.5) * 6);
    final h2 = Offset(
        b.dx - math.cos(ang + 0.5) * 6, b.dy - math.sin(ang + 0.5) * 6);
    c.drawLine(b, h1, p);
    c.drawLine(b, h2, p);
  }

  void _drawStepHint(Canvas c, Size s) {
    final hints = [
      'Frost insulates the coil and cuts capacity',
      'Vapour condenses and freezes on cold fins',
      'Trigger: coil temp, time, or demand',
      '4-way valve flips refrigerant direction',
      'Indoor flow dips - buffer absorbs the shock',
      'Tray catches melt-water, drain disposes',
      'Insulate condensate, prevent freeze-up',
      'Recovery rebuilds flow temp; SCOP cost',
      'Stuck valve / blocked drain = fault',
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
  bool shouldRepaint(_DefrostPainter o) => true;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum _SepLayout { volumiser, llh, buffer }

class HydraulicSeparationSimScreen extends StatefulWidget {
  const HydraulicSeparationSimScreen({super.key});
  @override
  State<HydraulicSeparationSimScreen> createState() =>
      _HydraulicSeparationSimScreenState();
}

class _HydraulicSeparationSimScreenState
    extends State<HydraulicSeparationSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  _SepLayout _layout = _SepLayout.llh;
  bool _heatingDemand = true;
  double _pumpDuty = 0.7; // 0..1

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

  List<SimStep> _stepsForLayout(_SepLayout l) {
    switch (l) {
      case _SepLayout.volumiser:
        return const [
          SimStep(
            title: 'Why a volumiser?',
            narration:
                'Modern heat pumps need a minimum water volume to defrost cleanly and avoid short cycling. A volumiser is a small in-line vessel, around 20 to 50 litres, that adds that buffer without full hydraulic separation.',
          ),
          SimStep(
            title: 'Single-pump arrangement',
            narration:
                'There is only one circulator. The heat pump pump moves water through the volumiser and out to every radiator. Primary and secondary flow rates must therefore match.',
          ),
          SimStep(
            title: 'Where it sits',
            narration:
                'The volumiser is normally fitted on the heat pump return. That keeps the hottest water flowing straight to the emitters and lets the vessel hold the cooler return mass.',
          ),
          SimStep(
            title: 'Sizing',
            narration:
                'Manufacturers specify a minimum litre-per-kilowatt figure, often 7 to 12 L per kW. Undersize the vessel and defrost cycles become noisy and inefficient.',
          ),
          SimStep(
            title: 'Commissioning',
            narration:
                'Balance every radiator at design flow and confirm the heat pump sees its specified delta T, typically 5 K at flow temperature 45 C. The volumiser does no balancing for you.',
          ),
          SimStep(
            title: 'Pros',
            narration:
                'Cheap, compact, no extra pump, low pressure loss. Ideal where the heating circuit is well sized and resistance is predictable.',
          ),
          SimStep(
            title: 'Cons',
            narration:
                'No hydraulic separation. If radiator TRVs close down, flow falls and the heat pump can trip on low delta T. Not suitable for high-resistance microbore systems.',
          ),
        ];
      case _SepLayout.llh:
        return const [
          SimStep(
            title: 'Why hydraulic separation matters',
            narration:
                'Heat pumps want a steady, generous flow at low delta T. Heating circuits with TRVs and zone valves vary wildly. A separator decouples the two so neither starves the other.',
          ),
          SimStep(
            title: 'The LLH principle',
            narration:
                'A low-loss header is a vertical pipe with two flow ports and two return ports. Primary and secondary pumps run independently and the header neutralises any difference in their flow rates.',
          ),
          SimStep(
            title: 'Sizing the body',
            narration:
                'Rule of thumb: the header diameter is at least three to four times the largest connecting pipe. That keeps internal velocity below 0.1 m/s so mixing is minimal.',
          ),
          SimStep(
            title: 'Connections',
            narration:
                'Keep both flow ports on the same side and both returns on the other. Reversing them mixes hot and cold and wrecks the secondary flow temperature.',
          ),
          SimStep(
            title: 'System delta T',
            narration:
                'If the secondary flow exceeds the primary, return water is drawn back up the header and dilutes the flow. Watch for an unexpected drop in radiator flow temperature on commissioning.',
          ),
          SimStep(
            title: 'Pros',
            narration:
                'Simple, cheap, very forgiving. Allows different pump curves on each side and air or dirt separation can be combined into the body.',
          ),
          SimStep(
            title: 'Cons',
            narration:
                'A small temperature drop across the header is unavoidable. The LLH gives almost no thermal storage, so a separate volumiser may still be needed for defrost.',
          ),
        ];
      case _SepLayout.buffer:
        return const [
          SimStep(
            title: 'Buffer tank role',
            narration:
                'A buffer is a larger insulated cylinder, typically 100 to 300 L. It provides both hydraulic separation and real thermal storage for defrosts and short cycling.',
          ),
          SimStep(
            title: '2-port versus 4-port',
            narration:
                'A 2-port buffer sits in series and forces all flow through the tank. A 4-port buffer is a parallel separator, much like an LLH with extra volume.',
          ),
          SimStep(
            title: 'Stratification',
            narration:
                'In a 4-port buffer hot water enters high and cold returns low. Done well, the tank stratifies and the secondary always draws the hottest layer.',
          ),
          SimStep(
            title: 'Sizing',
            narration:
                'Aim for at least 20 L per kW of heat pump output for defrost. Oversize and standing losses dominate; undersize and you lose the storage benefit.',
          ),
          SimStep(
            title: 'Stored heat in use',
            narration:
                'When the heat pump stops, the secondary loop can keep running off stored energy. Watch the buffer cool gradually as the tank discharges.',
          ),
          SimStep(
            title: 'Pros',
            narration:
                'Real thermal mass for defrost, smoother cycling, can support multiple zones at different temperatures. Absorbs renewable PV diversion when wired correctly.',
          ),
          SimStep(
            title: 'Cons',
            narration:
                'Standing losses, footprint, cost, and a 4-port version still mixes if pumps are mismatched. Always insulate every fitting, not just the cylinder body.',
          ),
        ];
    }
  }

  String _layoutTitle(_SepLayout l) {
    switch (l) {
      case _SepLayout.volumiser:
        return 'Volumiser';
      case _SepLayout.llh:
        return 'Low-loss header';
      case _SepLayout.buffer:
        return 'Buffer tank';
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _stepsForLayout(_layout);

    return SimScaffold(
      title: 'Hydraulic separation',
      summary:
          'Compare three ways to separate a heat pump primary from a heating secondary: an in-line volumiser, a low-loss header, or a buffer tank. Switch layout, toggle demand and adjust pump duty to see the effect on flow and temperatures.',
      onStepChanged: (_) => setState(() {}),
      controls: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final l in _SepLayout.values)
              ChoiceChip(
                label: Text(_layoutTitle(l)),
                selected: _layout == l,
                onSelected: (_) => setState(() {
                  _layout = l;
                }),
              ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Heating demand', style: TextStyle(fontSize: 12)),
            Switch.adaptive(
              value: _heatingDemand,
              onChanged: (v) => setState(() => _heatingDemand = v),
            ),
          ],
        ),
        SizedBox(
          width: 220,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pump duty: ${(_pumpDuty * 100).round()} %',
                  style: const TextStyle(fontSize: 12)),
              Slider(
                value: _pumpDuty,
                min: 0.1,
                max: 1.0,
                onChanged: (v) => setState(() => _pumpDuty = v),
              ),
            ],
          ),
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _HydraulicSeparationPainter(
            step: i,
            t: _ctrl.value,
            layout: _layout,
            heatingDemand: _heatingDemand,
            pumpDuty: _pumpDuty,
          ),
          size: Size.infinite,
        ),
      ),
      steps: steps.isNotEmpty
          ? steps
          : [const SimStep(title: '...', narration: '...')],
      // ignore: unused_local_variable
    );
  }
}

class _HydraulicSeparationPainter extends CustomPainter {
  final int step;
  final double t;
  final _SepLayout layout;
  final bool heatingDemand;
  final double pumpDuty;

  _HydraulicSeparationPainter({
    required this.step,
    required this.t,
    required this.layout,
    required this.heatingDemand,
    required this.pumpDuty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bg = Paint()..color = AppColors.cardBg;
    canvas.drawRect(Offset.zero & size, bg);

    final w = size.width;
    final h = size.height;

    // Heat pump (left)
    final hpRect = Rect.fromLTWH(w * 0.04, h * 0.30, w * 0.16, h * 0.32);
    _drawHeatPump(canvas, hpRect);
    PipePainterHelpers.drawLabel(
        canvas, Offset(hpRect.left, hpRect.top - 18), 'Heat pump (8 kW)');

    // Three radiators (right)
    final radX = w * 0.78;
    final radW = w * 0.18;
    final radH = h * 0.13;
    final radGap = h * 0.07;
    final radTopY = h * 0.18;
    final radRects = <Rect>[
      Rect.fromLTWH(radX, radTopY, radW, radH),
      Rect.fromLTWH(radX, radTopY + radH + radGap, radW, radH),
      Rect.fromLTWH(radX, radTopY + 2 * (radH + radGap), radW, radH),
    ];

    // Decide warmth based on layout/demand
    double secondaryWarmth = heatingDemand ? 1.0 : 0.0;
    double bufferStored = 1.0;
    if (layout == _SepLayout.buffer && !heatingDemand) {
      // tank stays warm, radiators idle
      secondaryWarmth = 0.0;
    } else if (layout == _SepLayout.buffer && heatingDemand) {
      bufferStored = 0.85 - 0.2 * (1 - pumpDuty);
    }

    for (int i = 0; i < radRects.length; i++) {
      PipePainterHelpers.drawRadiator(
        canvas,
        rect: radRects[i],
        warmth: secondaryWarmth * (0.85 + 0.05 * i),
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(radRects[i].left, radRects[i].top - 18),
        'Rad ${i + 1}',
      );
    }

    // Primary HP flow / return points
    final hpFlowOut = Offset(hpRect.right, hpRect.top + hpRect.height * 0.30);
    final hpReturnIn =
        Offset(hpRect.right, hpRect.top + hpRect.height * 0.75);

    // Mid layout area
    final midX = w * 0.42;
    final midTop = h * 0.18;
    final midBottom = h * 0.78;

    switch (layout) {
      case _SepLayout.volumiser:
        _paintVolumiser(canvas, size, hpFlowOut, hpReturnIn, midX, midTop,
            midBottom, radRects);
        break;
      case _SepLayout.llh:
        _paintLLH(canvas, size, hpFlowOut, hpReturnIn, midX, midTop, midBottom,
            radRects);
        break;
      case _SepLayout.buffer:
        _paintBuffer(canvas, size, hpFlowOut, hpReturnIn, midX, midTop,
            midBottom, radRects, bufferStored);
        break;
    }

    // Header strip
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.04, h * 0.02),
      'Step ${step + 1} - ${_layoutHeader()}',
      background: AppColors.primaryDark,
      textColor: Colors.white,
    );
  }

  String _layoutHeader() {
    switch (layout) {
      case _SepLayout.volumiser:
        return 'Volumiser (in-line buffer, single pump)';
      case _SepLayout.llh:
        return 'Low-loss header (parallel separator)';
      case _SepLayout.buffer:
        return 'Buffer tank (storage + separation)';
    }
  }

  // ---------- Layouts ----------

  void _paintVolumiser(
    Canvas canvas,
    Size size,
    Offset hpFlow,
    Offset hpReturn,
    double midX,
    double midTop,
    double midBottom,
    List<Rect> radRects,
  ) {
    final w = size.width;
    final h = size.height;

    // Vertical small vessel on the return leg between HP and radiators
    final vesselRect = Rect.fromLTWH(midX - w * 0.04, h * 0.50, w * 0.08, h * 0.22);
    _drawVessel(canvas, vesselRect, fill: 0.85, label: 'Volumiser ~30 L');

    // Single pump at HP flow side
    final pumpPos = Offset(hpFlow.dx + w * 0.06, hpFlow.dy);
    _drawPump(canvas, pumpPos, on: heatingDemand, label: 'System pump');

    // Flow path: HP flow -> right -> down to radiator manifold -> radiators
    final manifoldTop = Offset(w * 0.74, h * 0.18 + h * 0.065);
    final manifoldBottom = Offset(w * 0.74, h * 0.18 + 2 * (h * 0.13 + h * 0.07) + h * 0.065);

    final flowColor = AppColors.hotWater;
    final retColor = AppColors.coldWater;

    // HP flow horizontal
    PipePainterHelpers.drawPipe(canvas,
        a: hpFlow, b: pumpPos, color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: pumpPos, b: Offset(manifoldTop.dx, pumpPos.dy), color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(manifoldTop.dx, pumpPos.dy), b: manifoldTop, color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: manifoldTop, b: manifoldBottom, color: flowColor, width: 10);

    // Branches into radiators
    for (final r in radRects) {
      final entry = Offset(r.left, r.top + r.height * 0.5);
      PipePainterHelpers.drawPipe(canvas,
          a: Offset(manifoldTop.dx, entry.dy),
          b: entry,
          color: flowColor,
          width: 8);
    }

    // Return manifold and return through volumiser back to HP
    final retMan = Offset(w * 0.70, manifoldTop.dy);
    final retManBottom = Offset(w * 0.70, manifoldBottom.dy);
    PipePainterHelpers.drawPipe(canvas,
        a: retMan, b: retManBottom, color: retColor, width: 10);
    for (final r in radRects) {
      final exit = Offset(r.left, r.top + r.height * 0.85);
      PipePainterHelpers.drawPipe(canvas,
          a: exit, b: Offset(retMan.dx, exit.dy), color: retColor, width: 8);
    }
    // Return path back through volumiser
    final volTop = Offset(vesselRect.center.dx, vesselRect.top);
    final volBottom = Offset(vesselRect.center.dx, vesselRect.bottom);
    PipePainterHelpers.drawPipe(canvas,
        a: retManBottom,
        b: Offset(volTop.dx, retManBottom.dy),
        color: retColor,
        width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(volTop.dx, retManBottom.dy),
        b: volTop,
        color: retColor,
        width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: volBottom, b: Offset(volBottom.dx, hpReturn.dy), color: retColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(volBottom.dx, hpReturn.dy), b: hpReturn, color: retColor, width: 10);

    // Particles only when heating demand
    if (heatingDemand) {
      final speed = pumpDuty;
      final p = (t * speed) % 1.0;
      PipePainterHelpers.drawFlowParticles(canvas,
          a: hpFlow, b: pumpPos, progress: p, color: Colors.white, count: 4);
      PipePainterHelpers.drawFlowParticles(canvas,
          a: manifoldTop, b: manifoldBottom, progress: p, color: Colors.white, count: 6);
      for (final r in radRects) {
        final entry = Offset(r.left, r.top + r.height * 0.5);
        PipePainterHelpers.drawFlowParticles(canvas,
            a: Offset(manifoldTop.dx, entry.dy),
            b: entry,
            progress: p,
            color: Colors.white,
            count: 3);
      }
      PipePainterHelpers.drawFlowParticles(canvas,
          a: retMan, b: retManBottom, progress: 1 - p, color: Colors.white, count: 6);
      PipePainterHelpers.drawFlowParticles(canvas,
          a: volBottom, b: hpReturn, progress: 1 - p, color: Colors.white, count: 4);
    }

    // Joints
    PipePainterHelpers.drawJoint(canvas, manifoldTop);
    PipePainterHelpers.drawJoint(canvas, manifoldBottom);
    PipePainterHelpers.drawJoint(canvas, retMan);
    PipePainterHelpers.drawJoint(canvas, retManBottom);

    // Labels: temperatures
    PipePainterHelpers.drawLabel(canvas, Offset(hpFlow.dx + 10, hpFlow.dy - 22),
        'Flow 45 C', textColor: AppColors.hotWater);
    PipePainterHelpers.drawLabel(canvas,
        Offset(hpReturn.dx + 10, hpReturn.dy + 6), 'Return 40 C',
        textColor: AppColors.coldWater);
    PipePainterHelpers.drawLabel(canvas, Offset(radRects.first.right - 60, radRects.first.bottom + 4),
        'Rad flow ~44 C',
        textColor: AppColors.hotWater);
  }

  void _paintLLH(
    Canvas canvas,
    Size size,
    Offset hpFlow,
    Offset hpReturn,
    double midX,
    double midTop,
    double midBottom,
    List<Rect> radRects,
  ) {
    final w = size.width;
    final h = size.height;

    // Header body
    final headerRect =
        Rect.fromLTWH(midX - w * 0.025, midTop, w * 0.05, midBottom - midTop);
    _drawHeader(canvas, headerRect);

    final flowColor = AppColors.hotWater;
    final retColor = AppColors.coldWater;

    // Primary connections (left side of header)
    final pHigh = Offset(headerRect.left, headerRect.top + headerRect.height * 0.18);
    final pLow = Offset(headerRect.left, headerRect.top + headerRect.height * 0.82);
    // Secondary connections (right side)
    final sHigh = Offset(headerRect.right, headerRect.top + headerRect.height * 0.18);
    final sLow = Offset(headerRect.right, headerRect.top + headerRect.height * 0.82);

    // Primary pump
    final primPump = Offset(hpFlow.dx + (pHigh.dx - hpFlow.dx) * 0.55, hpFlow.dy);
    _drawPump(canvas, primPump, on: true, label: 'Primary pump');

    PipePainterHelpers.drawPipe(canvas,
        a: hpFlow, b: primPump, color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: primPump, b: Offset(pHigh.dx, primPump.dy), color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(pHigh.dx, primPump.dy), b: pHigh, color: flowColor, width: 10);

    PipePainterHelpers.drawPipe(canvas,
        a: pLow, b: Offset(pLow.dx, hpReturn.dy), color: retColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(pLow.dx, hpReturn.dy), b: hpReturn, color: retColor, width: 10);

    // Secondary
    final secPump = Offset(sHigh.dx + w * 0.07, sHigh.dy);
    _drawPump(canvas, secPump, on: heatingDemand, label: 'Secondary pump');

    final manTop = Offset(w * 0.74, h * 0.18 + h * 0.065);
    final manBot = Offset(w * 0.74, h * 0.18 + 2 * (h * 0.13 + h * 0.07) + h * 0.065);
    PipePainterHelpers.drawPipe(canvas,
        a: sHigh, b: secPump, color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: secPump, b: Offset(manTop.dx, secPump.dy), color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(manTop.dx, secPump.dy), b: manTop, color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: manTop, b: manBot, color: flowColor, width: 10);
    for (final r in radRects) {
      final entry = Offset(r.left, r.top + r.height * 0.5);
      PipePainterHelpers.drawPipe(canvas,
          a: Offset(manTop.dx, entry.dy), b: entry, color: flowColor, width: 8);
    }
    final retMan = Offset(w * 0.70, manTop.dy);
    final retManBot = Offset(w * 0.70, manBot.dy);
    PipePainterHelpers.drawPipe(canvas,
        a: retMan, b: retManBot, color: retColor, width: 10);
    for (final r in radRects) {
      final exit = Offset(r.left, r.top + r.height * 0.85);
      PipePainterHelpers.drawPipe(canvas,
          a: exit, b: Offset(retMan.dx, exit.dy), color: retColor, width: 8);
    }
    PipePainterHelpers.drawPipe(canvas,
        a: retManBot, b: Offset(retManBot.dx, sLow.dy), color: retColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(retManBot.dx, sLow.dy), b: sLow, color: retColor, width: 10);

    // Particles
    final p = t % 1.0;
    PipePainterHelpers.drawFlowParticles(canvas,
        a: hpFlow, b: pHigh, progress: p, color: Colors.white, count: 5);
    PipePainterHelpers.drawFlowParticles(canvas,
        a: pLow, b: hpReturn, progress: 1 - p, color: Colors.white, count: 5);
    if (heatingDemand) {
      final ps = (t * pumpDuty) % 1.0;
      PipePainterHelpers.drawFlowParticles(canvas,
          a: sHigh, b: manTop, progress: ps, color: Colors.white, count: 6);
      PipePainterHelpers.drawFlowParticles(canvas,
          a: manTop, b: manBot, progress: ps, color: Colors.white, count: 6);
      for (final r in radRects) {
        final entry = Offset(r.left, r.top + r.height * 0.5);
        PipePainterHelpers.drawFlowParticles(canvas,
            a: Offset(manTop.dx, entry.dy),
            b: entry,
            progress: ps,
            color: Colors.white,
            count: 3);
      }
      PipePainterHelpers.drawFlowParticles(canvas,
          a: retMan, b: sLow, progress: 1 - ps, color: Colors.white, count: 6);
    }

    // Subtle vertical mixing inside header
    final mix = Paint()
      ..color = AppColors.hotWater.withValues(alpha: 0.18)
      ..strokeWidth = 2.0;
    for (int i = 0; i < 5; i++) {
      final yy = headerRect.top + 8 + i * (headerRect.height - 16) / 4;
      final wob = math.sin((t * 2 * math.pi) + i) * 4;
      canvas.drawLine(
          Offset(headerRect.left + 6, yy + wob),
          Offset(headerRect.right - 6, yy + wob),
          mix);
    }

    // Labels
    PipePainterHelpers.drawLabel(canvas, Offset(headerRect.left - 4, headerRect.top - 16), 'LLH body');
    PipePainterHelpers.drawLabel(canvas, Offset(hpFlow.dx + 10, hpFlow.dy - 22),
        'Flow 45 C', textColor: AppColors.hotWater);
    PipePainterHelpers.drawLabel(canvas,
        Offset(hpReturn.dx + 10, hpReturn.dy + 6), 'Return 40 C',
        textColor: AppColors.coldWater);
    PipePainterHelpers.drawLabel(canvas, Offset(sHigh.dx + 4, sHigh.dy - 22),
        'Sec flow 44 C', textColor: AppColors.hotWater);
    PipePainterHelpers.drawLabel(canvas, Offset(sLow.dx + 4, sLow.dy + 6),
        'Sec ret 39 C', textColor: AppColors.coldWater);

    PipePainterHelpers.drawJoint(canvas, pHigh);
    PipePainterHelpers.drawJoint(canvas, pLow);
    PipePainterHelpers.drawJoint(canvas, sHigh);
    PipePainterHelpers.drawJoint(canvas, sLow);
  }

  void _paintBuffer(
    Canvas canvas,
    Size size,
    Offset hpFlow,
    Offset hpReturn,
    double midX,
    double midTop,
    double midBottom,
    List<Rect> radRects,
    double storedLevel,
  ) {
    final w = size.width;
    final h = size.height;

    // Larger tank
    final tankRect =
        Rect.fromLTWH(midX - w * 0.06, midTop, w * 0.12, midBottom - midTop);
    PipePainterHelpers.drawTank(
      canvas,
      rect: tankRect,
      level: storedLevel,
      waterColor: heatingDemand ? AppColors.hotWater : AppColors.hotWater,
      open: false,
      label: '4-port buffer 200 L',
    );

    // Stratification gradient overlay
    final strat = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.hotWater.withValues(alpha: 0.55),
          AppColors.coldWater.withValues(alpha: 0.35),
        ],
      ).createShader(tankRect);
    canvas.drawRect(tankRect.deflate(4), strat);

    final flowColor = AppColors.hotWater;
    final retColor = AppColors.coldWater;

    // Primary pair (left side)
    final pHigh = Offset(tankRect.left, tankRect.top + tankRect.height * 0.18);
    final pLow = Offset(tankRect.left, tankRect.top + tankRect.height * 0.82);
    final sHigh = Offset(tankRect.right, tankRect.top + tankRect.height * 0.22);
    final sLow = Offset(tankRect.right, tankRect.top + tankRect.height * 0.85);

    final primPump = Offset(hpFlow.dx + (pHigh.dx - hpFlow.dx) * 0.55, hpFlow.dy);
    _drawPump(canvas, primPump, on: true, label: 'Primary');

    PipePainterHelpers.drawPipe(canvas,
        a: hpFlow, b: primPump, color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: primPump, b: Offset(pHigh.dx, primPump.dy), color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(pHigh.dx, primPump.dy), b: pHigh, color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: pLow, b: Offset(pLow.dx, hpReturn.dy), color: retColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(pLow.dx, hpReturn.dy), b: hpReturn, color: retColor, width: 10);

    // Secondary
    final secPump = Offset(sHigh.dx + w * 0.05, sHigh.dy);
    _drawPump(canvas, secPump, on: heatingDemand, label: 'Secondary');

    final manTop = Offset(w * 0.74, h * 0.18 + h * 0.065);
    final manBot = Offset(w * 0.74, h * 0.18 + 2 * (h * 0.13 + h * 0.07) + h * 0.065);
    PipePainterHelpers.drawPipe(canvas,
        a: sHigh, b: secPump, color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: secPump, b: Offset(manTop.dx, secPump.dy), color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(manTop.dx, secPump.dy), b: manTop, color: flowColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: manTop, b: manBot, color: flowColor, width: 10);
    for (final r in radRects) {
      final entry = Offset(r.left, r.top + r.height * 0.5);
      PipePainterHelpers.drawPipe(canvas,
          a: Offset(manTop.dx, entry.dy), b: entry, color: flowColor, width: 8);
    }
    final retMan = Offset(w * 0.70, manTop.dy);
    final retManBot = Offset(w * 0.70, manBot.dy);
    PipePainterHelpers.drawPipe(canvas,
        a: retMan, b: retManBot, color: retColor, width: 10);
    for (final r in radRects) {
      final exit = Offset(r.left, r.top + r.height * 0.85);
      PipePainterHelpers.drawPipe(canvas,
          a: exit, b: Offset(retMan.dx, exit.dy), color: retColor, width: 8);
    }
    PipePainterHelpers.drawPipe(canvas,
        a: retManBot, b: Offset(retManBot.dx, sLow.dy), color: retColor, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(retManBot.dx, sLow.dy), b: sLow, color: retColor, width: 10);

    // Particles
    final pPrim = t % 1.0;
    PipePainterHelpers.drawFlowParticles(canvas,
        a: hpFlow, b: pHigh, progress: pPrim, color: Colors.white, count: 5);
    PipePainterHelpers.drawFlowParticles(canvas,
        a: pLow, b: hpReturn, progress: 1 - pPrim, color: Colors.white, count: 5);
    if (heatingDemand) {
      final ps = (t * pumpDuty) % 1.0;
      PipePainterHelpers.drawFlowParticles(canvas,
          a: sHigh, b: manTop, progress: ps, color: Colors.white, count: 6);
      PipePainterHelpers.drawFlowParticles(canvas,
          a: manTop, b: manBot, progress: ps, color: Colors.white, count: 6);
      for (final r in radRects) {
        final entry = Offset(r.left, r.top + r.height * 0.5);
        PipePainterHelpers.drawFlowParticles(canvas,
            a: Offset(manTop.dx, entry.dy),
            b: entry,
            progress: ps,
            color: Colors.white,
            count: 3);
      }
      PipePainterHelpers.drawFlowParticles(canvas,
          a: retMan, b: sLow, progress: 1 - ps, color: Colors.white, count: 6);
    } else {
      // depleting indicator: small downward bubbles inside tank
      final dot = Paint()..color = Colors.white.withValues(alpha: 0.6);
      for (int i = 0; i < 4; i++) {
        final y = tankRect.top +
            8 +
            ((t * 80) + i * tankRect.height / 4) % (tankRect.height - 16);
        canvas.drawCircle(
            Offset(tankRect.center.dx + math.sin(t * 2 * math.pi + i) * 4, y),
            2.5,
            dot);
      }
    }

    PipePainterHelpers.drawLabel(canvas, Offset(hpFlow.dx + 10, hpFlow.dy - 22),
        'Flow 45 C', textColor: AppColors.hotWater);
    PipePainterHelpers.drawLabel(canvas,
        Offset(hpReturn.dx + 10, hpReturn.dy + 6), 'Return 40 C',
        textColor: AppColors.coldWater);
    PipePainterHelpers.drawLabel(canvas, Offset(sHigh.dx + 4, sHigh.dy - 22),
        'Sec flow 43 C', textColor: AppColors.hotWater);
    PipePainterHelpers.drawLabel(canvas, Offset(sLow.dx + 4, sLow.dy + 6),
        'Sec ret 38 C', textColor: AppColors.coldWater);

    PipePainterHelpers.drawJoint(canvas, pHigh);
    PipePainterHelpers.drawJoint(canvas, pLow);
    PipePainterHelpers.drawJoint(canvas, sHigh);
    PipePainterHelpers.drawJoint(canvas, sLow);
  }

  // ---------- Components ----------

  void _drawHeatPump(Canvas canvas, Rect rect) {
    final body = Paint()..color = const Color(0xFFD7DDE5);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(r, body);
    canvas.drawRRect(r, stroke);
    // Fan
    final cx = rect.center.dx;
    final cy = rect.top + rect.height * 0.35;
    canvas.drawCircle(
        Offset(cx, cy), rect.width * 0.18, Paint()..color = Colors.black87);
    final blade = Paint()..color = Colors.white;
    for (int i = 0; i < 3; i++) {
      final a = (t * 2 * math.pi) + i * 2 * math.pi / 3;
      final p1 = Offset(cx, cy);
      final p2 = Offset(cx + math.cos(a) * rect.width * 0.16,
          cy + math.sin(a) * rect.width * 0.16);
      canvas.drawLine(
          p1,
          p2,
          blade
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round);
    }
    // Compressor block
    final block = Rect.fromLTWH(rect.left + 6, rect.top + rect.height * 0.6,
        rect.width - 12, rect.height * 0.3);
    canvas.drawRect(block, Paint()..color = const Color(0xFF8893A1));
  }

  void _drawHeader(Canvas canvas, Rect rect) {
    final body = Paint()..color = const Color(0xFFCAD3DC);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(r, body);
    canvas.drawRRect(r, stroke);
    // top/bottom caps
    final cap = Paint()..color = AppColors.pipeMetal;
    canvas.drawRect(
        Rect.fromLTWH(rect.left - 3, rect.top - 5, rect.width + 6, 6), cap);
    canvas.drawRect(
        Rect.fromLTWH(rect.left - 3, rect.bottom - 1, rect.width + 6, 6), cap);
  }

  void _drawVessel(Canvas canvas, Rect rect,
      {double fill = 0.85, String? label}) {
    final body = Paint()..color = const Color(0xFFE1E6EC);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(r, body);
    final waterRect = Rect.fromLTWH(
      rect.left + 3,
      rect.bottom - rect.height * fill,
      rect.width - 6,
      rect.height * fill,
    );
    canvas.drawRect(
        waterRect, Paint()..color = AppColors.hotWater.withValues(alpha: 0.6));
    canvas.drawRRect(r, stroke);
    if (label != null) {
      PipePainterHelpers.drawLabel(
          canvas, Offset(rect.left - 4, rect.top - 18), label);
    }
  }

  void _drawPump(Canvas canvas, Offset p, {required bool on, String? label}) {
    final bg = Paint()..color = on ? AppColors.primary : Colors.grey.shade400;
    canvas.drawCircle(p, 14, bg);
    final ring = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(p, 14, ring);
    // rotating arrow
    final ang = on ? (t * 2 * math.pi) : 0.0;
    final arrow = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final p1 = Offset(p.dx + math.cos(ang) * 8, p.dy + math.sin(ang) * 8);
    final p2 = Offset(p.dx + math.cos(ang + math.pi) * 8,
        p.dy + math.sin(ang + math.pi) * 8);
    canvas.drawLine(p1, p2, arrow);
    if (label != null) {
      PipePainterHelpers.drawLabel(canvas, Offset(p.dx - 30, p.dy + 18), label,
          fontSize: 10);
    }
  }

  @override
  bool shouldRepaint(covariant _HydraulicSeparationPainter old) => true;
}

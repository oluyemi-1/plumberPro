import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/paint_helpers.dart';
import '../widgets/sim_scaffold.dart';

/// Cascade modulating-boiler array: four wall-hung condensing boilers feeding
/// common flow / return headers via a low-loss header. Demonstrates lead/lag
/// staging, even-wear lead rotation and BMS sequencing for commercial heating.
class CascadeBoilerSimScreen extends StatefulWidget {
  const CascadeBoilerSimScreen({super.key});

  @override
  State<CascadeBoilerSimScreen> createState() =>
      _CascadeBoilerSimScreenState();
}

enum _SeqStrategy { lastOnFirstOff, evenWear, allModulating }

class _CascadeBoilerSimScreenState extends State<CascadeBoilerSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  /// Demand expressed in percent — 100% = one boiler full output.
  double _demand = 220;
  bool _autoRotate = true;
  _SeqStrategy _seq = _SeqStrategy.evenWear;

  /// Hours run per boiler — used by even-wear strategy to pick the lead.
  final List<double> _hours = [4120, 4185, 4090, 4205];

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

  /// Lead boiler ID (0..3): even-wear picks the lowest-hours boiler, others
  /// return boiler 0 by default — manual rotation is exposed via the switch.
  int get _leadBoiler {
    if (_seq == _SeqStrategy.evenWear || _autoRotate) {
      var idx = 0;
      var minH = _hours[0];
      for (var i = 1; i < _hours.length; i++) {
        if (_hours[i] < minH) {
          minH = _hours[i];
          idx = i;
        }
      }
      return idx;
    }
    return 0;
  }

  /// Per-boiler modulation 0..1 based on demand and the chosen sequence.
  List<double> _computeModulation() {
    final mods = List<double>.filled(4, 0);
    final demandFraction = (_demand / 100.0).clamp(0.0, 4.0);
    final lead = _leadBoiler;

    if (_seq == _SeqStrategy.allModulating) {
      // Spread evenly across all four — best for condensing efficiency.
      final each = (demandFraction / 4.0).clamp(0.0, 1.0);
      for (var i = 0; i < 4; i++) {
        mods[i] = each;
      }
      return mods;
    }

    // last-on-first-off and even-wear both stage one at a time, starting at
    // the lead and rotating round.
    var remaining = demandFraction;
    for (var i = 0; i < 4; i++) {
      final id = (lead + i) % 4;
      if (remaining <= 0) {
        mods[id] = 0;
        continue;
      }
      if (remaining >= 1.0) {
        mods[id] = 1.0;
        remaining -= 1.0;
      } else {
        // Last firing boiler modulates to make up the part-load.
        mods[id] = remaining.clamp(0.3, 1.0);
        remaining = 0;
      }
    }
    return mods;
  }

  String get _seqLabel {
    switch (_seq) {
      case _SeqStrategy.lastOnFirstOff:
        return 'Last-on first-off';
      case _SeqStrategy.evenWear:
        return 'Even wear (rotate)';
      case _SeqStrategy.allModulating:
        return 'All modulating together';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      SizedBox(
        width: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Heating demand: ${_demand.toStringAsFixed(0)} %'),
            Slider(
              value: _demand,
              min: 0,
              max: 400,
              divisions: 40,
              label: '${_demand.toStringAsFixed(0)} %',
              onChanged: (v) => setState(() => _demand = v),
            ),
          ],
        ),
      ),
      Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('Auto rotate lead'),
        Switch.adaptive(
          value: _autoRotate,
          onChanged: (v) => setState(() => _autoRotate = v),
        ),
      ]),
      Wrap(
        spacing: 6,
        children: _SeqStrategy.values.map((s) {
          String label;
          switch (s) {
            case _SeqStrategy.lastOnFirstOff:
              label = 'Last-on first-off';
              break;
            case _SeqStrategy.evenWear:
              label = 'Even wear';
              break;
            case _SeqStrategy.allModulating:
              label = 'All modulating';
              break;
          }
          return ChoiceChip(
            label: Text(label),
            selected: _seq == s,
            onSelected: (_) => setState(() => _seq = s),
          );
        }).toList(),
      ),
    ];

    final steps = const <SimStep>[
      SimStep(
        title: '1. Cascade fundamentals',
        narration:
            'A cascade is several smaller modulating boilers connected to common headers and sized so the whole array equals the building peak load. Splitting the duty lets each boiler run lower and longer for far better seasonal efficiency.',
      ),
      SimStep(
        title: '2. Lead and lag',
        narration:
            'On a call for heat, the lead boiler fires first and modulates up. Once it is at full output and demand still climbs, the controller stages in the next boiler.',
      ),
      SimStep(
        title: '3. Modulating across the array',
        narration:
            'Some controllers prefer to bring all boilers on at low fire instead of one at a time. Running every unit at, say, thirty percent gives the lowest return temperatures and the highest condensing yield.',
      ),
      SimStep(
        title: '4. Lead rotation',
        narration:
            'Periodically the controller rotates the lead boiler so hours run are evenly spread. This doubles useful life and avoids one heat exchanger taking all the wear.',
      ),
      SimStep(
        title: '5. Common headers',
        narration:
            'Flow and return headers run the full length of the boiler bank with isolation valves on each branch. That lets a single unit be isolated for service without dropping the whole plant.',
      ),
      SimStep(
        title: '6. Low-loss header',
        narration:
            'A low-loss header decouples the boiler primary loop from the system secondary loop. Each side has its own pump and the LLH balances flow so neither loop fights the other.',
      ),
      SimStep(
        title: '7. BMS interface',
        narration:
            'Boilers report status, modulation and faults over OpenTherm or Modbus. The cascade controller orchestrates staging, weather compensation and outside-air resets from the BMS.',
      ),
      SimStep(
        title: '8. Sequencing strategies',
        narration:
            'Last-on first-off staging keeps cycling on the marginal boiler. Even-wear rotation balances hours across all units. All-modulating gives the best efficiency at part load.',
      ),
      SimStep(
        title: '9. Common faults',
        narration:
            'Watch for comms loss between BMS and a boiler, a frozen flow sensor causing nuisance lockouts, and a scaled heat exchanger on one unit driving its return temperature unusually high.',
      ),
    ];

    return SimScaffold(
      title: 'Cascade modulating boilers',
      summary:
          'Four wall-hung modulating condensing boilers staged from a cascade '
          'controller, feeding common flow and return headers and a low-loss '
          'header into the secondary heating circuit.',
      steps: steps,
      controls: controls,
      onStepChanged: (_) => setState(() {}),
      diagramBuilder: (ctx, i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return CustomPaint(
              painter: _CascadePainter(
                step: i,
                t: _ctrl.value,
                modulation: _computeModulation(),
                lead: _leadBoiler,
                hours: _hours,
                demandPct: _demand,
                seqLabel: _seqLabel,
                autoRotate: _autoRotate,
              ),
              size: Size.infinite,
            );
          },
        );
      },
    );
  }
}

class _CascadePainter extends CustomPainter {
  final int step;
  final double t;
  final List<double> modulation;
  final int lead;
  final List<double> hours;
  final double demandPct;
  final String seqLabel;
  final bool autoRotate;

  _CascadePainter({
    required this.step,
    required this.t,
    required this.modulation,
    required this.lead,
    required this.hours,
    required this.demandPct,
    required this.seqLabel,
    required this.autoRotate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.cardBg,
    );

    // Layout
    final headerLeft = w * 0.10;
    final headerRight = w * 0.62;
    final flowY = h * 0.18;
    final returnY = h * 0.82;
    final boilerCount = 4;
    final boilerY = h * 0.45;
    final boilerW = (headerRight - headerLeft) / boilerCount * 0.62;
    final boilerH = h * 0.26;

    // Boiler centre x positions
    final cx = List.generate(boilerCount, (i) {
      final span = (headerRight - headerLeft);
      return headerLeft + span * (i + 0.5) / boilerCount;
    });

    // Common flow header (top)
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(headerLeft, flowY),
      b: Offset(headerRight, flowY),
      color: AppColors.hotWater,
      width: 14,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(headerLeft, flowY - 28),
      'Common flow header',
      background: Colors.white,
    );

    // Common return header (bottom)
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(headerLeft, returnY),
      b: Offset(headerRight, returnY),
      color: AppColors.coldWater,
      width: 14,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(headerLeft, returnY + 14),
      'Common return header',
      background: Colors.white,
    );

    // Boilers
    for (int i = 0; i < boilerCount; i++) {
      final mod = modulation[i].clamp(0.0, 1.0);
      final firing = mod > 0.02;
      final rect = Rect.fromCenter(
        center: Offset(cx[i], boilerY + boilerH / 2),
        width: boilerW,
        height: boilerH,
      );
      _drawBoiler(canvas, rect, mod: mod, firing: firing, id: i + 1, isLead: i == lead);

      // Branch flow up to header
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(cx[i], rect.top),
        b: Offset(cx[i], flowY + 7),
        color: AppColors.hotWater,
        width: 9,
        highlighted: firing && step == 4,
      );
      // Branch return down from header
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(cx[i], rect.bottom),
        b: Offset(cx[i], returnY - 7),
        color: AppColors.coldWater,
        width: 9,
      );

      // Per-boiler isolation valves on flow and return
      PipePainterHelpers.drawValve(
        canvas,
        Offset(cx[i], rect.top - 14),
        open: firing,
        size: 9,
      );
      PipePainterHelpers.drawValve(
        canvas,
        Offset(cx[i], rect.bottom + 14),
        open: firing,
        size: 9,
      );

      // Animate flow particles only on firing boilers
      if (firing) {
        PipePainterHelpers.drawFlowParticles(
          canvas,
          a: Offset(cx[i], rect.top),
          b: Offset(cx[i], flowY + 7),
          progress: t,
          color: Colors.white,
          count: 3,
          radius: 2.6,
        );
        PipePainterHelpers.drawFlowParticles(
          canvas,
          a: Offset(cx[i], returnY - 7),
          b: Offset(cx[i], rect.bottom),
          progress: t,
          color: Colors.white,
          count: 3,
          radius: 2.6,
        );
      }
    }

    // Header flow particles only when at least one boiler fires
    final anyFiring = modulation.any((m) => m > 0.02);
    if (anyFiring) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(headerLeft, flowY),
        b: Offset(headerRight, flowY),
        progress: t,
        color: Colors.white,
        count: 8,
        radius: 3.0,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(headerRight, returnY),
        b: Offset(headerLeft, returnY),
        progress: t,
        color: Colors.white,
        count: 8,
        radius: 3.0,
      );
    }

    // Joints at header T branches
    for (final x in cx) {
      PipePainterHelpers.drawJoint(canvas, Offset(x, flowY));
      PipePainterHelpers.drawJoint(canvas, Offset(x, returnY));
    }

    // Low-loss header
    final llhX = headerRight + 30;
    final llhTop = flowY - 8;
    final llhBottom = returnY + 8;
    final llhRect = Rect.fromLTWH(llhX, llhTop, 36, llhBottom - llhTop);
    _drawLowLossHeader(canvas, llhRect);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(llhX - 8, llhTop - 18),
      'Low-loss header',
      background: Colors.white,
    );

    // Connection from header to LLH
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(headerRight, flowY),
      b: Offset(llhX, flowY),
      color: AppColors.hotWater,
      width: 12,
      highlighted: step == 5 && anyFiring,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(headerRight, returnY),
      b: Offset(llhX, returnY),
      color: AppColors.coldWater,
      width: 12,
    );

    // System pump on the secondary side
    final sysPumpX = llhX + 36 + 30;
    final sysPumpY = h * 0.35;
    _drawPump(canvas, Offset(sysPumpX, sysPumpY), spinning: anyFiring);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(sysPumpX - 24, sysPumpY - 36),
      'System pump',
      background: Colors.white,
    );

    // Secondary flow to radiators
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(llhX + 36, flowY + 4),
      b: Offset(sysPumpX - 14, sysPumpY),
      color: AppColors.hotWater,
      width: 10,
    );
    final radX = w * 0.92;
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(sysPumpX + 14, sysPumpY),
      b: Offset(radX, sysPumpY),
      color: AppColors.hotWater,
      width: 10,
      highlighted: step == 5 && anyFiring,
    );
    if (anyFiring) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(sysPumpX + 14, sysPumpY),
        b: Offset(radX, sysPumpY),
        progress: t,
        color: Colors.white,
        count: 5,
        radius: 2.5,
      );
    }

    // Three radiators stacked on right
    final radTop = h * 0.30;
    for (var i = 0; i < 3; i++) {
      final rTop = radTop + i * (h * 0.16);
      final rRect = Rect.fromLTWH(radX - 70, rTop, 70, h * 0.10);
      final warmth = anyFiring ? 0.85 : 0.05;
      PipePainterHelpers.drawRadiator(canvas, rect: rRect, warmth: warmth);
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(rRect.left, rRect.top - 16),
        'Rad ${i + 1}',
        background: Colors.white,
      );
    }

    // Return path from radiators back to LLH
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(radX, h * 0.78),
      b: Offset(llhX + 36, returnY - 4),
      color: AppColors.coldWater,
      width: 10,
    );

    // Cascade controller box (top right area, above LLH)
    _drawController(canvas, w, h);

    // Step-specific overlay labels
    _drawStepOverlay(canvas, w, h, cx, boilerY);
  }

  void _drawBoiler(
    Canvas canvas,
    Rect rect, {
    required double mod,
    required bool firing,
    required int id,
    required bool isLead,
  }) {
    // Casing
    final body = Paint()..color = const Color(0xFFF1F3F5);
    final stroke = Paint()
      ..color = isLead ? AppColors.accent : Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = isLead ? 2.6 : 1.4;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(r, body);
    canvas.drawRRect(r, stroke);

    // Heat exchanger band
    final hxBand = Rect.fromLTWH(
      rect.left + 6,
      rect.top + rect.height * 0.28,
      rect.width - 12,
      rect.height * 0.20,
    );
    canvas.drawRect(
      hxBand,
      Paint()..color = AppColors.copper.withValues(alpha: 0.6),
    );

    // Flame icon at burner
    final burnerCx = rect.center.dx;
    final burnerY = rect.top + rect.height * 0.62;
    if (firing) {
      _drawFlame(canvas, Offset(burnerCx, burnerY), size: 18 * (0.6 + mod * 0.4));
    } else {
      // dormant burner
      canvas.drawCircle(
        Offset(burnerCx, burnerY),
        4,
        Paint()..color = AppColors.muted,
      );
    }

    // Modulation bar (right side of casing)
    final barRect = Rect.fromLTWH(
      rect.right - 12,
      rect.top + 6,
      6,
      rect.height - 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(3)),
      Paint()..color = Colors.black12,
    );
    final fillH = (rect.height - 12) * mod;
    final fillRect = Rect.fromLTWH(
      barRect.left,
      barRect.bottom - fillH,
      barRect.width,
      fillH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, const Radius.circular(3)),
      Paint()
        ..color = (mod > 0.02 ? AppColors.gas : AppColors.muted),
    );

    // ID label (B1..B4)
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(rect.left + 4, rect.top + 4),
      'B$id${isLead ? '  LEAD' : ''}',
      background: isLead ? AppColors.accent.withValues(alpha: 0.18) : Colors.white,
      textColor: isLead ? AppColors.accent : AppColors.text,
    );

    // Modulation percent label
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(rect.left + 4, rect.bottom - 18),
      '${(mod * 100).toStringAsFixed(0)} %',
      background: Colors.white,
      fontSize: 10,
    );
  }

  void _drawFlame(Canvas canvas, Offset c, {double size = 16}) {
    final glow = Paint()
      ..color = AppColors.gas.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(c, size * 1.2, glow);

    final path = Path()
      ..moveTo(c.dx, c.dy + size * 0.6)
      ..quadraticBezierTo(c.dx - size * 0.9, c.dy, c.dx - size * 0.2, c.dy - size * 0.6)
      ..quadraticBezierTo(c.dx, c.dy - size * 0.2, c.dx + size * 0.2, c.dy - size * 0.7)
      ..quadraticBezierTo(c.dx + size * 0.9, c.dy, c.dx, c.dy + size * 0.6)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.gas);

    final core = Path()
      ..moveTo(c.dx, c.dy + size * 0.3)
      ..quadraticBezierTo(c.dx - size * 0.4, c.dy, c.dx, c.dy - size * 0.4)
      ..quadraticBezierTo(c.dx + size * 0.4, c.dy, c.dx, c.dy + size * 0.3)
      ..close();
    canvas.drawPath(core, Paint()..color = AppColors.accent.withValues(alpha: 0.8));
  }

  void _drawLowLossHeader(Canvas canvas, Rect rect) {
    final body = Paint()..color = AppColors.pipeMetal.withValues(alpha: 0.6);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(r, body);
    canvas.drawRRect(r, stroke);

    // Internal stratification gradient
    final grad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.hotWater.withValues(alpha: 0.55),
          AppColors.coldWater.withValues(alpha: 0.55),
        ],
      ).createShader(rect);
    canvas.drawRRect(r, grad);
  }

  void _drawPump(Canvas canvas, Offset c, {required bool spinning}) {
    canvas.drawCircle(
      c,
      14,
      Paint()..color = AppColors.brass.withValues(alpha: 0.6),
    );
    canvas.drawCircle(
      c,
      14,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final angle = spinning ? t * 2 * math.pi : 0.0;
    final p = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 3; i++) {
      final a = angle + i * (2 * math.pi / 3);
      canvas.drawLine(
        c,
        c + Offset(math.cos(a) * 10, math.sin(a) * 10),
        p,
      );
    }
  }

  void _drawController(Canvas canvas, double w, double h) {
    final rect = Rect.fromLTWH(w * 0.04, h * 0.02, w * 0.32, h * 0.13);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = AppColors.primary.withValues(alpha: 0.10),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(rect.left + 6, rect.top + 4),
      'Cascade controller',
      background: AppColors.primary.withValues(alpha: 0.15),
      textColor: AppColors.primaryDark,
    );

    final lines = <String>[
      'Demand: ${demandPct.toStringAsFixed(0)} %',
      'Lead: B${lead + 1}'
          '${autoRotate ? '  (auto)' : ''}',
      'Strategy: $seqLabel',
      'Hours: '
          'B1=${hours[0].toStringAsFixed(0)}  '
          'B2=${hours[1].toStringAsFixed(0)}  '
          'B3=${hours[2].toStringAsFixed(0)}  '
          'B4=${hours[3].toStringAsFixed(0)}',
    ];

    for (var i = 0; i < lines.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: lines[i],
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rect.width - 16);
      tp.paint(canvas, Offset(rect.left + 8, rect.top + 24 + i * 14.0));
    }
  }

  void _drawStepOverlay(
    Canvas canvas,
    double w,
    double h,
    List<double> cx,
    double boilerY,
  ) {
    String? hint;
    switch (step) {
      case 0:
        hint = 'Cascade = many small modulating boilers, sized to peak load.';
        break;
      case 1:
        hint = 'Lead boiler fires first, modulates to 100%, then lag stages in.';
        break;
      case 2:
        hint = 'All boilers at low fire = lowest return temp, best condensing.';
        break;
      case 3:
        hint = 'Lead rotates on hours run — keeps wear even across the bank.';
        break;
      case 4:
        hint = 'Branch isolation valves let any boiler be removed for service.';
        break;
      case 5:
        hint = 'Low-loss header decouples primary boiler loop from secondary.';
        break;
      case 6:
        hint = 'BMS / OpenTherm: status, modulation, faults, weather comp.';
        break;
      case 7:
        hint = 'Strategy: $seqLabel';
        break;
      case 8:
        hint = 'Faults: comms loss, frozen sensor, scaled HX on one boiler.';
        break;
      default:
        hint = null;
    }
    if (hint != null) {
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(w * 0.04, h * 0.92),
        hint,
        background: Colors.white,
        fontSize: 12,
      );
    }

    // Highlight a faulted boiler on step 9 (e.g. boiler 3 scaled HX)
    if (step == 8) {
      final faultIdx = 2;
      final c = Offset(cx[faultIdx], boilerY - 18);
      canvas.drawCircle(
        c,
        14,
        Paint()..color = AppColors.accent.withValues(alpha: 0.85),
      );
      final tp = TextPainter(
        text: const TextSpan(
          text: '!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(c.dx + 18, c.dy - 8),
        'Scaled HX — high return ΔT',
        background: AppColors.accent.withValues(alpha: 0.15),
        textColor: AppColors.accent,
      );
    }
  }

  @override
  bool shouldRepaint(_CascadePainter o) => true;
}

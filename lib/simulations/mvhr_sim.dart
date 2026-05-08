import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

/// Animated MVHR simulation showing extract from wet rooms, supply to
/// habitable rooms and a counter-flow heat exchanger.
class MvhrSimScreen extends StatefulWidget {
  const MvhrSimScreen({super.key});

  @override
  State<MvhrSimScreen> createState() => _MvhrSimScreenState();
}

class _MvhrSimScreenState extends State<MvhrSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _outsideTemp = 5; // degrees C

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _steps = <SimStep>[
    SimStep(
      title: 'Why ventilate',
      narration:
          'Modern airtight homes cannot rely on draughts to remove moisture, smells and CO2. Mechanical ventilation with heat recovery delivers a controlled fresh air change while keeping the heat in.',
    ),
    SimStep(
      title: 'Counter-flow heat exchanger',
      narration:
          'Inside the unit, the warm extract and cold supply pass each other on opposite sides of thin plates. Up to 90 percent of the heat in the outgoing air transfers to the incoming air without mixing.',
    ),
    SimStep(
      title: 'Wet rooms extract, habitable rooms supply',
      narration:
          'Stale air is drawn from the kitchen, bathroom, en-suite and utility. Fresh tempered air is delivered to the bedrooms and lounge, balancing the dwelling so it neither pressurises nor depressurises.',
    ),
    SimStep(
      title: 'Filters G4 and F7',
      narration:
          'A G4 panel filter sits on the extract to protect the heat exchanger. An F7 fine filter on the supply removes pollen and fine particles. Inspect every six months and change annually.',
    ),
    SimStep(
      title: 'Insulated ducting',
      narration:
          'Ducts in the loft are wrapped in 25 millimetres or more of vapour-sealed insulation. That keeps cold supply ducts above the dew point so condensation cannot drip into the ceiling.',
    ),
    SimStep(
      title: 'Commissioning',
      narration:
          'Air flow is measured at every terminal and trimmed with the damper until it is within plus or minus 10 percent of design. Total supply must roughly equal total extract for a balanced system.',
    ),
    SimStep(
      title: 'Common faults',
      narration:
          'A blocked filter, a frosted exchanger in cold weather and a blocked condensate pipe are the three most common faults. Each shows up as low flow at one or more terminals.',
    ),
  ];

  // Recovery efficiency declines as outside drops, but for show 90 -> 78
  double get _efficiency {
    final norm = ((_outsideTemp + 10) / 30).clamp(0.0, 1.0);
    return 78 + 12 * norm; // 78%..90%
  }

  // Supply temperature out of unit (heat recovered from 21 C indoor)
  double get _supplyTempC {
    final ext = 21.0;
    return _outsideTemp + (_efficiency / 100) * (ext - _outsideTemp);
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'MVHR mechanical ventilation',
      summary:
          'A central heat exchanger in the loft draws stale extract from wet rooms and supplies tempered fresh air to bedrooms and the lounge. Adjust outside temperature and watch supply temperature and recovery efficiency change.',
      steps: _steps,
      onStepChanged: (_) => setState(() {}),
      controls: [
        SizedBox(
          width: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Outside: ${_outsideTemp.toStringAsFixed(0)} °C'),
              Slider(
                value: _outsideTemp,
                min: -10,
                max: 20,
                divisions: 30,
                onChanged: (v) => setState(() => _outsideTemp = v),
              ),
              Text(
                'Recovery ≈ ${_efficiency.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text('Supply ≈ ${_supplyTempC.toStringAsFixed(0)} °C'),
            ],
          ),
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _MvhrPainter(
            step: i,
            t: _ctrl.value,
            outsideTemp: _outsideTemp,
            efficiency: _efficiency,
            supplyTemp: _supplyTempC,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _MvhrPainter extends CustomPainter {
  final int step;
  final double t;
  final double outsideTemp;
  final double efficiency;
  final double supplyTemp;

  _MvhrPainter({
    required this.step,
    required this.t,
    required this.outsideTemp,
    required this.efficiency,
    required this.supplyTemp,
  });

  // Duct colour conventions
  static const Color warmExtract = Color(0xFFE63946); // hot side
  static const Color coolSupply = Color(0xFFE69500); // tempered supply (warmed)
  static const Color outsideIntake = Color(0xFF2E9CCA); // cold intake
  static const Color cooledExtract = Color(0xFF6C757D); // cooled extract

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEFF4F8),
    );

    // House outline
    final houseRect = Rect.fromLTWH(w * 0.04, h * 0.30, w * 0.92, h * 0.62);
    canvas.drawRRect(
      RRect.fromRectAndRadius(houseRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFFAF8F2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(houseRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // Roof
    final roofPath = Path()
      ..moveTo(houseRect.left, houseRect.top)
      ..lineTo(houseRect.center.dx, houseRect.top - 60)
      ..lineTo(houseRect.right, houseRect.top)
      ..close();
    canvas.drawPath(
      roofPath,
      Paint()..color = const Color(0xFF8C5A3A),
    );
    canvas.drawPath(
      roofPath,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Floor divider mid-height: ground floor below, first floor above
    final floorY = houseRect.top + houseRect.height * 0.5;
    canvas.drawLine(
      Offset(houseRect.left, floorY),
      Offset(houseRect.right, floorY),
      Paint()
        ..color = Colors.black45
        ..strokeWidth = 1.4,
    );

    // Internal walls: ground (kitchen | utility | lounge), first (bath | en-suite | bed1 | bed2)
    final gWall1 = houseRect.left + houseRect.width * 0.22;
    final gWall2 = houseRect.left + houseRect.width * 0.42;
    final gWall3 = houseRect.left + houseRect.width * 0.62;
    final fWall1 = houseRect.left + houseRect.width * 0.26;
    final fWall2 = houseRect.left + houseRect.width * 0.50;
    final fWall3 = houseRect.left + houseRect.width * 0.72;
    final wallPaint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(gWall1, floorY), Offset(gWall1, houseRect.bottom),
        wallPaint);
    canvas.drawLine(Offset(gWall2, floorY), Offset(gWall2, houseRect.bottom),
        wallPaint);
    canvas.drawLine(Offset(gWall3, floorY), Offset(gWall3, houseRect.bottom),
        wallPaint);
    canvas.drawLine(Offset(fWall1, houseRect.top), Offset(fWall1, floorY),
        wallPaint);
    canvas.drawLine(Offset(fWall2, houseRect.top), Offset(fWall2, floorY),
        wallPaint);
    canvas.drawLine(Offset(fWall3, houseRect.top), Offset(fWall3, floorY),
        wallPaint);

    // Room labels
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(houseRect.left + 8, houseRect.bottom - 24),
      'Kitchen',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gWall1 + 4, houseRect.bottom - 24),
      'Bathroom',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gWall2 + 4, houseRect.bottom - 24),
      'Utility',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gWall3 + 4, houseRect.bottom - 24),
      'Lounge',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(houseRect.left + 8, floorY - 14),
      'Bedroom',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(fWall1 + 4, floorY - 14),
      'En-suite',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(fWall2 + 4, floorY - 14),
      'Bedroom 2',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(fWall3 + 4, floorY - 14),
      'Hallway',
    );

    // ----- Loft MVHR unit -----
    final unitRect = Rect.fromCenter(
      center: Offset(houseRect.center.dx, houseRect.top - 26),
      width: 90,
      height: 50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(unitRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFE6E9EE),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(unitRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(unitRect.left, unitRect.top - 18),
      'MVHR unit (loft)',
    );
    // Counter-flow heat exchanger glyph (tilted square)
    final hex = Path()
      ..moveTo(unitRect.center.dx, unitRect.top + 8)
      ..lineTo(unitRect.right - 12, unitRect.center.dy)
      ..lineTo(unitRect.center.dx, unitRect.bottom - 8)
      ..lineTo(unitRect.left + 12, unitRect.center.dy)
      ..close();
    canvas.drawPath(
      hex,
      Paint()..color = const Color(0xFFD0D6DD),
    );
    canvas.drawPath(
      hex,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    // Two crossed channels: extract red, supply orange
    canvas.drawLine(
      Offset(unitRect.center.dx, unitRect.top + 8),
      Offset(unitRect.center.dx, unitRect.bottom - 8),
      Paint()
        ..color = warmExtract.withValues(alpha: 0.5)
        ..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(unitRect.left + 12, unitRect.center.dy),
      Offset(unitRect.right - 12, unitRect.center.dy),
      Paint()
        ..color = coolSupply.withValues(alpha: 0.5)
        ..strokeWidth = 4,
    );
    // Filters at unit
    canvas.drawRect(
      Rect.fromLTWH(unitRect.left - 8, unitRect.top + 18, 6, 14),
      Paint()..color = AppColors.gas,
    );
    canvas.drawRect(
      Rect.fromLTWH(unitRect.right + 2, unitRect.top + 18, 6, 14),
      Paint()..color = AppColors.gas,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(unitRect.left - 30, unitRect.top + 36),
      'F7 supply',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(unitRect.right + 2, unitRect.top + 36),
      'G4 extract',
    );

    // Outside intake (left of unit, going up over roof to outside) and
    // exhaust (right side going outside)
    // Use external icons
    final intakeOut = Offset(houseRect.left - 30, unitRect.center.dy - 10);
    final exhaustOut = Offset(houseRect.right + 30, unitRect.center.dy + 10);

    // Intake duct: outside cold -> filter -> exchanger left -> exits as warmed supply
    final intakeA = intakeOut;
    final intakeB = Offset(unitRect.left - 10, intakeOut.dy);
    final intakeC = Offset(unitRect.left + 12, unitRect.center.dy);
    PipePainterHelpers.drawPipe(
      canvas, a: intakeA, b: intakeB, color: outsideIntake, width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: intakeB, b: intakeC, color: outsideIntake, width: 8,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(intakeA.dx - 18, intakeA.dy - 22),
      'Cold intake ${outsideTemp.toStringAsFixed(0)} °C',
      background: outsideIntake.withValues(alpha: 0.18),
    );

    // Cooled extract going outside (right side of exchanger)
    final coolExA = Offset(unitRect.right - 12, unitRect.center.dy);
    final coolExB = Offset(unitRect.right + 10, coolExA.dy + 10);
    final coolExC = exhaustOut;
    PipePainterHelpers.drawPipe(
      canvas, a: coolExA, b: coolExB, color: cooledExtract, width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: coolExB, b: coolExC, color: cooledExtract, width: 8,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(exhaustOut.dx - 18, exhaustOut.dy - 22),
      'Cooled exhaust',
      background: cooledExtract.withValues(alpha: 0.25),
    );

    // Warm extract risers from wet rooms up to top of unit (red)
    final wetTerms = <Offset>[
      Offset(houseRect.left + houseRect.width * 0.10,
          houseRect.bottom - 10), // kitchen
      Offset(gWall1 + 12, houseRect.bottom - 10), // bathroom
      Offset(gWall2 + 12, houseRect.bottom - 10), // utility
      Offset(fWall1 + 12, floorY - 4), // en-suite
    ];
    for (final term in wetTerms) {
      _drawTerminal(canvas, term, warmExtract);
      // Up to ceiling of that floor
      final ceilY = (term.dy < floorY) ? houseRect.top + 10 : floorY + 4;
      PipePainterHelpers.drawPipe(
        canvas,
        a: term,
        b: Offset(term.dx, ceilY),
        color: warmExtract,
        width: 6,
      );
      // Across to unit top
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(term.dx, ceilY),
        b: Offset(term.dx, unitRect.top + 8),
        color: warmExtract,
        width: 6,
      );
      // run horizontal at exchanger top into unit
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(term.dx, unitRect.top + 8),
        b: Offset(unitRect.center.dx, unitRect.top + 8),
        color: warmExtract,
        width: 6,
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(wetTerms[0].dx - 14, wetTerms[0].dy - 22),
      'Extract',
    );

    // Warmed supply ducts from unit bottom out to habitable rooms (orange)
    final supTerms = <Offset>[
      Offset(houseRect.left + houseRect.width * 0.13, floorY - 4), // bedroom
      Offset(fWall2 + 14, floorY - 4), // bedroom 2
      Offset(houseRect.left + houseRect.width * 0.85,
          houseRect.bottom - 10), // lounge
    ];
    for (final term in supTerms) {
      _drawTerminal(canvas, term, coolSupply);
      final ceilY = (term.dy < floorY) ? houseRect.top + 18 : floorY + 8;
      PipePainterHelpers.drawPipe(
        canvas,
        a: term,
        b: Offset(term.dx, ceilY),
        color: coolSupply,
        width: 6,
      );
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(term.dx, ceilY),
        b: Offset(term.dx, unitRect.bottom - 8),
        color: coolSupply,
        width: 6,
      );
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(term.dx, unitRect.bottom - 8),
        b: Offset(unitRect.center.dx, unitRect.bottom - 8),
        color: coolSupply,
        width: 6,
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(supTerms[0].dx - 14, supTerms[0].dy - 22),
      'Supply',
    );

    // ----- Animation particles along active routes -----
    // Cold intake -> exchanger
    PipePainterHelpers.drawFlowParticles(
      canvas, a: intakeA, b: intakeB, progress: t,
      color: Colors.white, count: 4,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas, a: intakeB, b: intakeC, progress: t,
      color: Colors.white, count: 2,
    );
    // Cooled exhaust outwards
    PipePainterHelpers.drawFlowParticles(
      canvas, a: coolExA, b: coolExB, progress: t,
      color: Colors.white, count: 2,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas, a: coolExB, b: coolExC, progress: t,
      color: Colors.white, count: 4,
    );

    // Wet room extract: terminal -> ceiling -> across to unit top
    for (final term in wetTerms) {
      final ceilY = (term.dy < floorY) ? houseRect.top + 10 : floorY + 4;
      PipePainterHelpers.drawFlowParticles(
        canvas, a: term, b: Offset(term.dx, ceilY),
        progress: t, color: Colors.white, count: 2,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas, a: Offset(term.dx, unitRect.top + 8),
        b: Offset(unitRect.center.dx, unitRect.top + 8),
        progress: t, color: Colors.white, count: 3,
      );
    }
    // Habitable supply: from unit bottom out to terminal
    for (final term in supTerms) {
      final ceilY = (term.dy < floorY) ? houseRect.top + 18 : floorY + 8;
      PipePainterHelpers.drawFlowParticles(
        canvas, a: Offset(term.dx, unitRect.bottom - 8),
        b: Offset(term.dx, ceilY),
        progress: t, color: Colors.white, count: 2,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas, a: Offset(term.dx, ceilY),
        b: term, progress: t,
        color: Colors.white, count: 2,
      );
    }

    // Joints
    PipePainterHelpers.drawJoint(canvas, intakeB);
    PipePainterHelpers.drawJoint(canvas, coolExB);

    // ----- Mini chart of port temperatures -----
    final chartRect = Rect.fromLTWH(w - 170, 12, 158, 78);
    canvas.drawRRect(
      RRect.fromRectAndRadius(chartRect, const Radius.circular(6)),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(chartRect, const Radius.circular(6)),
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke,
    );
    _drawChartLine(
      canvas,
      Offset(chartRect.left + 6, chartRect.top + 12),
      'Outside ${outsideTemp.toStringAsFixed(0)} °C',
      outsideIntake,
    );
    _drawChartLine(
      canvas,
      Offset(chartRect.left + 6, chartRect.top + 28),
      'Supply ${supplyTemp.toStringAsFixed(0)} °C',
      coolSupply,
    );
    _drawChartLine(
      canvas,
      Offset(chartRect.left + 6, chartRect.top + 44),
      'Extract 21 °C',
      warmExtract,
    );
    _drawChartLine(
      canvas,
      Offset(chartRect.left + 6, chartRect.top + 60),
      'Exhaust ${(supplyTemp - 4).toStringAsFixed(0)} °C',
      cooledExtract,
    );

    // Status badges
    PipePainterHelpers.drawLabel(
      canvas, Offset(12, h - 60),
      'Recovery ${efficiency.toStringAsFixed(0)}%',
      background: AppColors.accent.withValues(alpha: 0.2),
    );
    PipePainterHelpers.drawLabel(
      canvas, Offset(12, h - 40),
      'Supply ${supplyTemp.toStringAsFixed(0)} °C',
      background: coolSupply.withValues(alpha: 0.2),
    );
    PipePainterHelpers.drawLabel(
      canvas, Offset(12, h - 20),
      'Step ${step + 1}',
      background: AppColors.primary.withValues(alpha: 0.18),
    );
  }

  void _drawTerminal(Canvas canvas, Offset p, Color color) {
    canvas.drawCircle(p, 8, Paint()..color = color);
    canvas.drawCircle(
      p, 8,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(p, 3, Paint()..color = Colors.white);
  }

  void _drawChartLine(Canvas canvas, Offset p, String text, Color color) {
    canvas.drawCircle(
      Offset(p.dx + 4, p.dy + 6),
      4,
      Paint()..color = color,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(p.dx + 14, p.dy));
  }

  @override
  bool shouldRepaint(_MvhrPainter o) =>
      o.step != step ||
      o.t != t ||
      o.outsideTemp != outsideTemp ||
      o.efficiency != efficiency ||
      o.supplyTemp != supplyTemp;
}

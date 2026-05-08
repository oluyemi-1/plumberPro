import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum _FuelKind { lpg, oil }

class LpgOilSimScreen extends StatefulWidget {
  const LpgOilSimScreen({super.key});

  @override
  State<LpgOilSimScreen> createState() => _LpgOilSimScreenState();
}

class _LpgOilSimScreenState extends State<LpgOilSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  _FuelKind _kind = _FuelKind.oil;
  bool _fireValveTripped = false;
  bool _fireTestActive = false;
  double _flameProgress = 0; // 0..1 animates the flame appearing

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _ctrl.addListener(_onTick);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTick);
    _ctrl.dispose();
    super.dispose();
  }

  void _onTick() {
    if (_fireTestActive && !_fireValveTripped) {
      setState(() {
        _flameProgress += 0.02;
        if (_flameProgress >= 1.0) {
          _flameProgress = 1.0;
          _fireValveTripped = true;
        }
      });
    }
  }

  void _startFireTest() {
    setState(() {
      _fireTestActive = true;
      _fireValveTripped = false;
      _flameProgress = 0;
    });
  }

  void _resetSafety() {
    setState(() {
      _fireTestActive = false;
      _fireValveTripped = false;
      _flameProgress = 0;
    });
  }

  static const List<SimStep> _oilSteps = [
    SimStep(
      title: '1. Tank type — single-skin in bund or integrally bunded',
      narration:
          'A single-skin tank must sit inside a separate bund holding 110 percent of capacity. An integrally bunded tank combines both skins in one moulded unit and is the preferred specification.',
    ),
    SimStep(
      title: '2. Distance from building and boundary',
      narration:
          'Under OFTEC TI/133 the tank should be at least 1.8 m from the dwelling, 1.8 m from a boundary and 760 mm from a non-fire-rated eaves. Use a fire wall to reduce these.',
    ),
    SimStep(
      title: '3. Fire valve at the appliance',
      narration:
          'A remote-acting fire valve has its sensor within 150 mm of the burner. A fire melts the fusible head, the cable releases and a spring closes the valve at the line entry.',
    ),
    SimStep(
      title: '4. Filter and deaerator',
      narration:
          'The filter traps dirt and water; the deaerator removes air bubbles from a single-pipe system so the burner sees clean, gas-free fuel at every fire.',
    ),
    SimStep(
      title: '5. Tank inspection',
      narration:
          'Annual visual check: corrosion, weeping seams, brittle plastic, vent and gauge integrity, and the bund clear of rainwater. Note any defects on the OFTEC report.',
    ),
    SimStep(
      title: '6. Spill response',
      narration:
          'Bunds contain spills; absorbent granules and pads handle splashes. Notify the Environment Agency if oil reaches surface water or the ground beyond the bund.',
    ),
    SimStep(
      title: '7. OFTEC and competence',
      narration:
          'Oil work in England, Wales and Northern Ireland is notifiable; OFTEC registration provides the competent person scheme for self-certification.',
    ),
  ];

  static const List<SimStep> _lpgSteps = [
    SimStep(
      title: '1. Bulk tank principle',
      narration:
          'A bulk LPG tank stores liquid propane and offtakes vapour through a regulator. Pressure is dropped to 37 mbar at the appliance. The supplier owns the vessel.',
    ),
    SimStep(
      title: '2. Safety distances',
      narration:
          'A typical 1200 litre tank sits at least 3 m from a building and 1.5 m from a boundary. A fire wall can reduce these but never eliminate them.',
    ),
    SimStep(
      title: '3. Emergency control valve',
      narration:
          'An ECV is fitted where the supply enters the building so that the occupant can isolate gas in an emergency. Mark its position clearly and keep it accessible.',
    ),
    SimStep(
      title: '4. Bonding and earthing',
      narration:
          'The bulk tank is electrically bonded to earth and the metallic supply line is cross-bonded to the main earth terminal of the dwelling.',
    ),
    SimStep(
      title: '5. Flame failure devices',
      narration:
          'Every appliance has a flame failure device that closes the gas valve within seconds if the flame is lost, preventing unburnt gas escaping.',
    ),
    SimStep(
      title: '6. Ventilation — heavier than air',
      narration:
          'LPG vapour is heavier than air and pools in low spaces. Provide low-level as well as high-level ventilation, and avoid cellars, drains and lift pits.',
    ),
    SimStep(
      title: '7. Leak testing',
      narration:
          'Test all joints with leak detection fluid or an electronic detector at every visit. Never search with a flame and never re-use perished flexible hose.',
    ),
  ];

  List<SimStep> get _activeSteps =>
      _kind == _FuelKind.oil ? _oilSteps : _lpgSteps;

  String get _summary => _kind == _FuelKind.oil
      ? 'An oil-fired installation: integrally bunded tank, fire valve sensor at the burner, copper supply line, filter and deaerator. Press Fire test to see the safety chain operate.'
      : 'A bulk LPG installation: outdoor tank with regulator and pressure gauge, underground line into the dwelling, internal ECV, regulator at the appliance and bonded earthing.';

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      ChoiceChip(
        label: const Text('LPG bulk tank'),
        selected: _kind == _FuelKind.lpg,
        onSelected: (_) => setState(() {
          _kind = _FuelKind.lpg;
          _resetSafety();
        }),
      ),
      ChoiceChip(
        label: const Text('Oil installation'),
        selected: _kind == _FuelKind.oil,
        onSelected: (_) => setState(() {
          _kind = _FuelKind.oil;
          _resetSafety();
        }),
      ),
      ElevatedButton.icon(
        onPressed: _startFireTest,
        icon: const Icon(Icons.local_fire_department),
        label: const Text('Fire test'),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _fireTestActive ? AppColors.accent : AppColors.primary,
        ),
      ),
      OutlinedButton.icon(
        onPressed: _resetSafety,
        icon: const Icon(Icons.replay),
        label: const Text('Reset'),
      ),
    ];

    return SimScaffold(
      key: ValueKey(_kind),
      title: 'LPG and oil installations',
      summary: _summary,
      steps: _activeSteps,
      controls: controls,
      diagramBuilder: (context, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _LpgOilPainter(
              kind: _kind,
              t: _ctrl.value,
              fireTestActive: _fireTestActive,
              fireValveTripped: _fireValveTripped,
              flameProgress: _flameProgress,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _LpgOilPainter extends CustomPainter {
  final _FuelKind kind;
  final double t;
  final bool fireTestActive;
  final bool fireValveTripped;
  final double flameProgress;
  _LpgOilPainter({
    required this.kind,
    required this.t,
    required this.fireTestActive,
    required this.fireValveTripped,
    required this.flameProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.cardBg,
    );

    final w = size.width;
    final h = size.height;

    // Outdoor / indoor split
    final wallX = w * 0.55;
    final groundY = h * 0.85;

    // Outdoor area
    canvas.drawRect(
      Rect.fromLTWH(0, 0, wallX, h),
      Paint()..color = const Color(0xFFE7F2EC),
    );
    // Ground line
    canvas.drawLine(
      Offset(0, groundY),
      Offset(w, groundY),
      Paint()
        ..color = Colors.brown.shade400
        ..strokeWidth = 2,
    );
    // House wall
    canvas.drawRect(
      Rect.fromLTWH(wallX, 0, 14, h),
      Paint()..color = const Color(0xFFB6A37C),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(8, 14),
      'Outside',
      background: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(wallX + 22, 14),
      'Inside dwelling',
      background: Colors.white,
    );

    // Building dwelling outline (right of wall)
    final house = Rect.fromLTWH(wallX + 14, h * 0.18, w - wallX - 24, h * 0.62);
    canvas.drawRRect(
      RRect.fromRectAndRadius(house, const Radius.circular(8)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(house, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Appliance (boiler) inside the house
    final appliance = Rect.fromLTWH(
      house.left + 16,
      house.center.dy - 30,
      80,
      80,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(appliance, const Radius.circular(6)),
      Paint()..color = const Color(0xFFE7ECF2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(appliance, const Radius.circular(6)),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(appliance.left, appliance.bottom + 4),
      'Appliance',
    );

    if (kind == _FuelKind.oil) {
      _paintOil(canvas, size, wallX, groundY, house, appliance);
    } else {
      _paintLpg(canvas, size, wallX, groundY, house, appliance);
    }

    // Title strip
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(8, 36),
      kind == _FuelKind.oil ? 'Oil installation' : 'LPG bulk tank',
      background: AppColors.primary,
      textColor: Colors.white,
      fontSize: 12,
    );
  }

  void _paintOil(Canvas canvas, Size size, double wallX, double groundY,
      Rect house, Rect appliance) {
    // Integrally bunded tank
    final tank = Rect.fromLTWH(
      size.width * 0.06,
      groundY - 130,
      size.width * 0.30,
      120,
    );
    // Outer skin (bund)
    canvas.drawRRect(
      RRect.fromRectAndRadius(tank, const Radius.circular(10)),
      Paint()..color = const Color(0xFF7E8B98),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tank, const Radius.circular(10)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Inner tank
    final inner = tank.deflate(8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, const Radius.circular(6)),
      Paint()..color = const Color(0xFF98A4B0),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, const Radius.circular(6)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    // Oil fill level
    final oilLvl = inner.bottom - inner.height * 0.7;
    canvas.drawRect(
      Rect.fromLTRB(inner.left + 2, oilLvl, inner.right - 2, inner.bottom - 2),
      Paint()..color = const Color(0xFF6B3E10).withValues(alpha: 0.85),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tank.left, tank.top - 16),
      'Integrally bunded oil tank (110%)',
    );
    // Vent and fill on top
    canvas.drawRect(
      Rect.fromLTWH(tank.left + 14, tank.top - 14, 14, 14),
      Paint()..color = AppColors.pipeMetal,
    );
    canvas.drawRect(
      Rect.fromLTWH(tank.right - 28, tank.top - 14, 14, 14),
      Paint()..color = AppColors.pipeMetal,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tank.left + 14, tank.top - 30),
      'Fill / vent',
    );

    // Distance label
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tank.right + 6, tank.center.dy),
      '1.8 m to dwelling',
      background: AppColors.accent,
      textColor: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tank.left, groundY - 8),
      '1.8 m to boundary',
      background: AppColors.accent,
      textColor: Colors.white,
    );

    // Tank outlet -> isolation valve -> fire valve at line entry
    final tankOutlet = Offset(tank.right - 6, oilLvl + 24);
    final valve1 = Offset(tank.right + 24, tankOutlet.dy);
    final entry = Offset(wallX, tankOutlet.dy + 20);
    final lineEntryFireValve = Offset(wallX + 28, entry.dy);
    final filter = Offset(lineEntryFireValve.dx + 36, entry.dy);
    final deaerator = Offset(filter.dx + 36, entry.dy);
    final applInlet = Offset(appliance.left, appliance.center.dy + 16);

    final lineColor = const Color(0xFF8C5A2C);

    // Tank to outdoor isolation
    PipePainterHelpers.drawPipe(
      canvas,
      a: tankOutlet,
      b: valve1,
      color: lineColor,
      width: 8,
    );
    PipePainterHelpers.drawValve(canvas, valve1, open: true);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(valve1.dx - 14, valve1.dy + 16),
      'Tank iso valve',
    );

    // Outdoor to entry
    PipePainterHelpers.drawPipe(
      canvas,
      a: valve1,
      b: Offset(valve1.dx, entry.dy),
      color: lineColor,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(valve1.dx, entry.dy),
      b: entry,
      color: lineColor,
      width: 8,
    );
    PipePainterHelpers.drawJoint(canvas, entry);

    // Through wall
    PipePainterHelpers.drawPipe(
      canvas,
      a: entry,
      b: lineEntryFireValve,
      color: lineColor,
      width: 8,
    );
    PipePainterHelpers.drawValve(canvas, lineEntryFireValve, open: !fireValveTripped);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(lineEntryFireValve.dx - 12, lineEntryFireValve.dy - 28),
      'Fire valve',
      background: fireValveTripped ? Colors.red.shade100 : Colors.white,
    );

    // To filter
    PipePainterHelpers.drawPipe(
      canvas,
      a: lineEntryFireValve,
      b: filter,
      color: lineColor,
      width: 8,
    );
    canvas.drawCircle(filter, 8, Paint()..color = AppColors.brass);
    canvas.drawCircle(
      filter,
      8,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(filter.dx - 10, filter.dy + 14),
      'Filter',
    );

    // To deaerator
    PipePainterHelpers.drawPipe(
      canvas,
      a: filter,
      b: deaerator,
      color: lineColor,
      width: 8,
    );
    canvas.drawRect(
      Rect.fromCenter(center: deaerator, width: 18, height: 14),
      Paint()..color = AppColors.pipeMetal,
    );
    canvas.drawRect(
      Rect.fromCenter(center: deaerator, width: 18, height: 14),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(deaerator.dx - 18, deaerator.dy + 14),
      'Deaerator',
    );

    // To appliance
    PipePainterHelpers.drawPipe(
      canvas,
      a: deaerator,
      b: applInlet,
      color: lineColor,
      width: 8,
    );

    // Fire valve sensor at burner (within 150 mm) - shown as fusible bulb
    final sensor = Offset(appliance.left + 14, appliance.center.dy + 6);
    canvas.drawCircle(sensor, 5,
        Paint()..color = fireValveTripped ? Colors.grey : Colors.redAccent);
    canvas.drawCircle(
      sensor,
      5,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(sensor.dx + 8, sensor.dy - 14),
      'Fusible sensor (150 mm)',
    );

    // Cable from sensor back to fire valve
    final cablePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final cablePath = Path()
      ..moveTo(sensor.dx, sensor.dy)
      ..quadraticBezierTo(
        (sensor.dx + lineEntryFireValve.dx) / 2,
        sensor.dy - 30,
        lineEntryFireValve.dx,
        lineEntryFireValve.dy - 18,
      );
    canvas.drawPath(cablePath, cablePaint);

    // Animate oil particles when valve open
    if (!fireValveTripped) {
      _drawFuelParticles(
        canvas,
        [tankOutlet, valve1, Offset(valve1.dx, entry.dy), entry, lineEntryFireValve, filter, deaerator, applInlet],
        const Color(0xFF8C5A2C),
      );
    }

    // Fire test flame on appliance
    if (fireTestActive) {
      final flameC = Offset(appliance.center.dx, appliance.bottom + 14);
      _drawTestFire(canvas, flameC, flameProgress, t);
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(flameC.dx - 16, flameC.dy + 18),
        fireValveTripped ? 'Fire valve TRIPPED' : 'Fire test running',
        background: fireValveTripped ? Colors.red.shade200 : Colors.amber.shade200,
      );
    }
  }

  void _paintLpg(Canvas canvas, Size size, double wallX, double groundY,
      Rect house, Rect appliance) {
    // Bulk tank (horizontal cylinder)
    final tankCentre = Offset(size.width * 0.20, groundY - 60);
    final tankRect = Rect.fromCenter(center: tankCentre, width: 200, height: 80);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tankRect, const Radius.circular(40)),
      Paint()..color = const Color(0xFFC2D6C2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tankRect, const Radius.circular(40)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // End caps
    canvas.drawCircle(
      Offset(tankRect.left + 6, tankRect.center.dy),
      6,
      Paint()..color = Colors.black54,
    );
    canvas.drawCircle(
      Offset(tankRect.right - 6, tankRect.center.dy),
      6,
      Paint()..color = Colors.black54,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tankRect.left, tankRect.top - 16),
      'LPG bulk tank (1200 L)',
    );

    // Concrete plinth
    canvas.drawRect(
      Rect.fromLTWH(tankRect.left - 10, tankRect.bottom - 4, tankRect.width + 20, 12),
      Paint()..color = const Color(0xFFB6BCC4),
    );

    // Vapour offtake + regulator + pressure gauge on top
    final regulatorC = Offset(tankCentre.dx, tankRect.top - 12);
    canvas.drawCircle(regulatorC, 12, Paint()..color = AppColors.pipeMetal);
    canvas.drawCircle(
      regulatorC,
      12,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(regulatorC.dx - 18, regulatorC.dy - 26),
      'Regulator (37 mbar)',
    );

    // Pressure gauge
    final gauge = Offset(regulatorC.dx + 22, regulatorC.dy - 4);
    canvas.drawCircle(gauge, 8, Paint()..color = Colors.white);
    canvas.drawCircle(
      gauge,
      8,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final needle = Offset(
      gauge.dx + math.cos(-math.pi / 2 + 0.6) * 6,
      gauge.dy + math.sin(-math.pi / 2 + 0.6) * 6,
    );
    canvas.drawLine(
      gauge,
      needle,
      Paint()
        ..color = Colors.red
        ..strokeWidth = 1.5,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gauge.dx + 12, gauge.dy - 12),
      'Pressure gauge',
    );

    // Earth bonding clamp
    final earthP = Offset(tankRect.right + 6, tankRect.bottom - 4);
    canvas.drawRect(
      Rect.fromCenter(center: earthP, width: 10, height: 8),
      Paint()..color = Colors.black87,
    );
    final earthLineEnd = Offset(earthP.dx + 30, groundY + 4);
    canvas.drawLine(
      earthP,
      earthLineEnd,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.5,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(earthP.dx + 12, earthP.dy - 18),
      'Bonded earth',
    );

    // Distance labels
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tankRect.right + 6, tankRect.center.dy),
      '3 m to dwelling',
      background: AppColors.accent,
      textColor: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tankRect.left, groundY + 6),
      '1.5 m to boundary',
      background: AppColors.accent,
      textColor: Colors.white,
    );

    // Underground line from regulator to wall entry
    final undergroundY = groundY + 18;
    final lineColor = AppColors.gas;
    final pTop = regulatorC + const Offset(0, -2);
    final pDownToGround = Offset(regulatorC.dx, undergroundY);
    final pAlongGround = Offset(wallX - 4, undergroundY);
    final pIntoBuilding = Offset(wallX + 30, undergroundY - 30);
    final ecv = Offset(wallX + 50, undergroundY - 30);
    final regAtAppl = Offset(appliance.left - 14, appliance.center.dy + 16);
    final applInlet = Offset(appliance.left, appliance.center.dy + 16);

    PipePainterHelpers.drawPipe(canvas, a: pTop, b: pDownToGround, color: lineColor, width: 8);
    // Underground (dashed look)
    PipePainterHelpers.drawPipe(canvas, a: pDownToGround, b: pAlongGround, color: lineColor, width: 8);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pDownToGround.dx + 8, pDownToGround.dy + 6),
      'Underground line',
    );

    // Up into building
    PipePainterHelpers.drawPipe(canvas, a: pAlongGround, b: pIntoBuilding, color: lineColor, width: 8);
    PipePainterHelpers.drawJoint(canvas, pIntoBuilding);

    // ECV inside
    PipePainterHelpers.drawPipe(canvas, a: pIntoBuilding, b: ecv, color: lineColor, width: 8);
    PipePainterHelpers.drawValve(canvas, ecv, open: !fireValveTripped);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ecv.dx - 8, ecv.dy - 24),
      'ECV',
    );

    // To appliance regulator
    PipePainterHelpers.drawPipe(canvas, a: ecv, b: Offset(regAtAppl.dx, ecv.dy), color: lineColor, width: 8);
    PipePainterHelpers.drawPipe(canvas, a: Offset(regAtAppl.dx, ecv.dy), b: regAtAppl, color: lineColor, width: 8);
    canvas.drawCircle(regAtAppl, 9, Paint()..color = AppColors.pipeMetal);
    canvas.drawCircle(
      regAtAppl,
      9,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(regAtAppl.dx - 26, regAtAppl.dy + 14),
      'Appliance regulator',
    );
    PipePainterHelpers.drawPipe(canvas, a: regAtAppl, b: applInlet, color: lineColor, width: 8);

    // Animate LPG flow (green particles)
    if (!fireValveTripped) {
      _drawFuelParticles(
        canvas,
        [pTop, pDownToGround, pAlongGround, pIntoBuilding, ecv, Offset(regAtAppl.dx, ecv.dy), regAtAppl, applInlet],
        const Color(0xFF35A35A),
      );
    }

    // Fire test flame
    if (fireTestActive) {
      final flameC = Offset(appliance.center.dx, appliance.bottom + 14);
      _drawTestFire(canvas, flameC, flameProgress, t);
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(flameC.dx - 16, flameC.dy + 18),
        fireValveTripped ? 'ECV closed by FFD' : 'Fire test running',
        background: fireValveTripped ? Colors.red.shade200 : Colors.amber.shade200,
      );
    }

    // Drain warning label
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tankRect.right + 6, groundY + 30),
      '3 m clear of drains / ignition',
    );
  }

  void _drawFuelParticles(Canvas canvas, List<Offset> path, Color color) {
    if (path.length < 2) return;
    // Compute total length
    double total = 0;
    final segLens = <double>[];
    for (int i = 0; i < path.length - 1; i++) {
      final l = (path[i + 1] - path[i]).distance;
      segLens.add(l);
      total += l;
    }
    if (total <= 0) return;

    const count = 14;
    final paint = Paint()..color = color;
    for (int i = 0; i < count; i++) {
      final pos = ((t + i / count) % 1.0) * total;
      double acc = 0;
      for (int s = 0; s < segLens.length; s++) {
        if (pos <= acc + segLens[s]) {
          final localT = (pos - acc) / segLens[s];
          final p = path[s] + (path[s + 1] - path[s]) * localT;
          canvas.drawCircle(p, 3.0, paint);
          break;
        }
        acc += segLens[s];
      }
    }
  }

  void _drawTestFire(Canvas canvas, Offset c, double progress, double time) {
    final scale = 0.4 + 0.6 * progress.clamp(0.0, 1.0);
    final flicker = 1 + math.sin(time * math.pi * 8) * 0.3;
    final hh = 36 * flicker * scale;
    final wd = 18 * scale;
    final path = Path()
      ..moveTo(c.dx - wd / 2, c.dy)
      ..quadraticBezierTo(c.dx - wd, c.dy - hh * 0.6, c.dx, c.dy - hh)
      ..quadraticBezierTo(c.dx + wd, c.dy - hh * 0.6, c.dx + wd / 2, c.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = AppColors.accent.withValues(alpha: 0.85),
    );
    final inner = Path()
      ..moveTo(c.dx - wd / 3, c.dy)
      ..quadraticBezierTo(c.dx - wd / 2, c.dy - hh * 0.5, c.dx, c.dy - hh * 0.8)
      ..quadraticBezierTo(c.dx + wd / 2, c.dy - hh * 0.5, c.dx + wd / 3, c.dy)
      ..close();
    canvas.drawPath(
      inner,
      Paint()..color = Colors.yellowAccent.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _LpgOilPainter old) =>
      old.t != t ||
      old.kind != kind ||
      old.fireTestActive != fireTestActive ||
      old.fireValveTripped != fireValveTripped ||
      old.flameProgress != flameProgress;
}

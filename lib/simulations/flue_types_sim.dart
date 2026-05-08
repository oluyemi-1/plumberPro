import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum _FlueKind { open, balanced, fan }

class FlueTypesSimScreen extends StatefulWidget {
  const FlueTypesSimScreen({super.key});

  @override
  State<FlueTypesSimScreen> createState() => _FlueTypesSimScreenState();
}

class _FlueTypesSimScreenState extends State<FlueTypesSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  _FlueKind _kind = _FlueKind.open;

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

  // Step lists per flue type --------------------------------------------------
  static const List<SimStep> _openSteps = [
    SimStep(
      title: '1. Class I open flue principle',
      narration:
          'An open-flued appliance draws combustion air from the room and discharges products vertically up a flue under natural draught. The room itself is part of the air supply.',
    ),
    SimStep(
      title: '2. Room ventilation',
      narration:
          'The room must have a permanent ventilator sized at roughly 5 cm2 per kW of input above 7 kW for natural gas. Blocking the vent will starve the flame and produce CO.',
    ),
    SimStep(
      title: '3. Draught diverter',
      narration:
          'A draught diverter sits above the appliance to relieve down-draught and stabilise the flue. It is the classic giveaway that an installation is open-flued.',
    ),
    SimStep(
      title: '4. Vertical flue route',
      narration:
          'The flue rises through the building to a terminal on the roof, fitted with a cowl to prevent rain ingress and bird entry. Horizontal offsets are limited.',
    ),
    SimStep(
      title: '5. Spillage and flue flow tests',
      narration:
          'A smoke match held below the diverter must be drawn upward. Spillage means products are entering the room and the appliance must be turned off.',
    ),
    SimStep(
      title: '6. Common faults',
      narration:
          'Blocked terminals, bird nests, dislodged liners and blocked room ventilators are the usual culprits behind down-draught and spillage.',
    ),
    SimStep(
      title: '7. Inspection',
      narration:
          'Inspect liner continuity, terminal condition, draught diverter clearance and that the room ventilator is open and unobstructed.',
    ),
  ];

  static const List<SimStep> _balancedSteps = [
    SimStep(
      title: '1. Room-sealed principle',
      narration:
          'A balanced flue takes air from outside and exhausts products through a single concentric terminal. No room air enters the combustion chamber.',
    ),
    SimStep(
      title: '2. Terminal location rules',
      narration:
          'Typical clearances are 300 mm below an opening window, 600 mm to a facing surface, 300 mm from an internal corner and 300 mm above ground level.',
    ),
    SimStep(
      title: '3. Class FL or B designation',
      narration:
          'Class FL covers manufacturer-specific concentric flues. Only the supplied components, lengths and seals may be used and equivalent length must be tracked.',
    ),
    SimStep(
      title: '4. Inspection',
      narration:
          'The terminal must be visible, free of obstruction and free of plume staining. The horizontal run inside the building should fall back to the appliance.',
    ),
    SimStep(
      title: '5. Spillage and flue flow tests',
      narration:
          'Room-sealed appliances rarely spill but the flue flow test still confirms a clear path. Check the manufacturer flow rate against the meter reading.',
    ),
    SimStep(
      title: '6. Common faults',
      narration:
          'Terminal blockage by leaves, a full condensate trap, perished gaskets and uphill horizontal runs are common defects.',
    ),
    SimStep(
      title: '7. Plume management',
      narration:
          'A condensing balanced flue produces a visible water plume in cold weather. A plume kit can redirect it to avoid nuisance to neighbours.',
    ),
  ];

  static const List<SimStep> _fanSteps = [
    SimStep(
      title: '1. Fan-assisted principle',
      narration:
          'A fan in the flue path overcomes resistance and allows longer or more complex routes. The boiler proves the fan before the gas valve is opened.',
    ),
    SimStep(
      title: '2. Pre-purge and air-pressure switch',
      narration:
          'The fan runs first to clear residual gases. An air-pressure switch or fan-speed feedback confirms a clear flue before ignition.',
    ),
    SimStep(
      title: '3. Equivalent length',
      narration:
          'Each bend, length of pipe and terminal counts toward the maximum permitted equivalent length set by the manufacturer. Exceeding this stops the boiler firing.',
    ),
    SimStep(
      title: '4. Terminal clearances',
      narration:
          'Fanned terminals follow the same Part J clearances: 300 mm below openings, 600 mm to facing walls, 75 mm from eaves. Stricter manufacturer figures apply if higher.',
    ),
    SimStep(
      title: '5. Spillage and flow tests',
      narration:
          'On a room-sealed fanned flue the analyser confirms flue integrity. Joints should be smoke-tested if there is any doubt about seal integrity.',
    ),
    SimStep(
      title: '6. Common faults',
      narration:
          'A noisy or stalling fan, blocked condensate trap, slipped flue support or a failed pressure switch will all lock the boiler out.',
    ),
    SimStep(
      title: '7. Service intervals',
      narration:
          'Annual service cleans the fan blades, checks the gasket seals and replaces the condensate trap washers as required by the manufacturer.',
    ),
  ];

  List<SimStep> get _activeSteps {
    switch (_kind) {
      case _FlueKind.open:
        return _openSteps;
      case _FlueKind.balanced:
        return _balancedSteps;
      case _FlueKind.fan:
        return _fanSteps;
    }
  }

  String get _summary => switch (_kind) {
        _FlueKind.open =>
          'A class I open-flued appliance with a draught diverter, room ventilator and a vertical flue rising to a roof terminal. Combustion air comes from the room.',
        _FlueKind.balanced =>
          'A room-sealed balanced flue with a single concentric terminal taking outside air through the outer annulus and discharging products through the inner pipe.',
        _FlueKind.fan =>
          'A fan-assisted room-sealed flue allowing longer horizontal runs. An air-pressure switch confirms a clear path before the boiler fires.',
      };

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      ChoiceChip(
        label: const Text('Open flue (class I)'),
        selected: _kind == _FlueKind.open,
        onSelected: (_) => setState(() => _kind = _FlueKind.open),
      ),
      ChoiceChip(
        label: const Text('Balanced flue (room-sealed)'),
        selected: _kind == _FlueKind.balanced,
        onSelected: (_) => setState(() => _kind = _FlueKind.balanced),
      ),
      ChoiceChip(
        label: const Text('Fan-assisted (room-sealed)'),
        selected: _kind == _FlueKind.fan,
        onSelected: (_) => setState(() => _kind = _FlueKind.fan),
      ),
    ];

    return SimScaffold(
      key: ValueKey(_kind),
      title: 'Flue types and terminal rules',
      summary: _summary,
      steps: _activeSteps,
      controls: controls,
      diagramBuilder: (context, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _FluePainter(
              kind: _kind,
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

class _FluePainter extends CustomPainter {
  final _FlueKind kind;
  final int step;
  final double t;
  _FluePainter({required this.kind, required this.step, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.cardBg;
    canvas.drawRect(Offset.zero & size, bg);

    final w = size.width;
    final h = size.height;

    // External wall and ground line
    final wallX = w * 0.62;
    final groundY = h * 0.92;
    // Draw outdoor area
    final outdoor = Paint()..color = const Color(0xFFE7F2EC);
    canvas.drawRect(Rect.fromLTWH(wallX, 0, w - wallX, h), outdoor);
    // Wall
    canvas.drawRect(
      Rect.fromLTWH(wallX - 14, 0, 14, h),
      Paint()..color = const Color(0xFFB6A37C),
    );
    canvas.drawLine(
      Offset(0, groundY),
      Offset(w, groundY),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 1.5,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(wallX + 6, 14),
      'Outside',
      background: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(8, 14),
      'Inside dwelling',
      background: Colors.white,
    );

    // Appliance casing
    final casing = Rect.fromLTWH(w * 0.18, h * 0.42, w * 0.28, h * 0.34);
    canvas.drawRRect(
      RRect.fromRectAndRadius(casing, const Radius.circular(10)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(casing, const Radius.circular(10)),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(casing.left, casing.bottom + 6),
      'Appliance',
    );

    // Burner inside
    final burnerRect = Rect.fromLTWH(
      casing.left + 12,
      casing.center.dy + 24,
      casing.width - 24,
      14,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(burnerRect, const Radius.circular(3)),
      Paint()..color = Colors.black87,
    );
    for (int i = 0; i < 5; i++) {
      final jx = burnerRect.left + 10 + i * (burnerRect.width - 20) / 4;
      _drawSmallFlame(canvas, Offset(jx, burnerRect.top - 2), t + i * 0.15);
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(burnerRect.left, burnerRect.top - 18),
      'Burner',
    );

    switch (kind) {
      case _FlueKind.open:
        _drawOpen(canvas, size, casing, wallX, groundY);
        break;
      case _FlueKind.balanced:
        _drawBalanced(canvas, size, casing, wallX, groundY);
        break;
      case _FlueKind.fan:
        _drawFan(canvas, size, casing, wallX, groundY);
        break;
    }

    // Title
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(8, 36),
      switch (kind) {
        _FlueKind.open => 'Class I open flue',
        _FlueKind.balanced => 'Balanced (room-sealed) flue',
        _FlueKind.fan => 'Fan-assisted flue',
      },
      background: AppColors.primary,
      textColor: Colors.white,
      fontSize: 12,
    );
  }

  void _drawOpen(Canvas canvas, Size size, Rect casing, double wallX, double groundY) {
    final w = size.width;
    // Draught diverter just above the appliance
    final diverterRect = Rect.fromLTWH(
      casing.center.dx - 26,
      casing.top - 28,
      52,
      24,
    );
    final dPath = Path()
      ..moveTo(diverterRect.left, diverterRect.bottom)
      ..lineTo(diverterRect.left + 8, diverterRect.top)
      ..lineTo(diverterRect.right - 8, diverterRect.top)
      ..lineTo(diverterRect.right, diverterRect.bottom)
      ..close();
    canvas.drawPath(dPath, Paint()..color = AppColors.pipeMetal);
    canvas.drawPath(
      dPath,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(diverterRect.right + 6, diverterRect.top),
      'Draught diverter',
    );

    // Vertical flue from diverter up to roof terminal
    final flueX = casing.center.dx;
    final flueTopY = 30.0;
    final flueRect = Rect.fromLTWH(flueX - 14, flueTopY, 28, diverterRect.top - flueTopY);
    canvas.drawRect(flueRect, Paint()..color = AppColors.pipeMetal);
    canvas.drawRect(
      flueRect,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Cowl
    final cowlPath = Path()
      ..moveTo(flueRect.left - 8, flueRect.top)
      ..lineTo(flueRect.right + 8, flueRect.top)
      ..lineTo(flueRect.right + 4, flueRect.top - 12)
      ..lineTo(flueRect.left - 4, flueRect.top - 12)
      ..close();
    canvas.drawPath(cowlPath, Paint()..color = AppColors.copper);
    canvas.drawPath(
      cowlPath,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(flueRect.right + 6, flueRect.top + 4),
      'Roof terminal + cowl',
    );

    // Combustion gases rising
    for (int i = 0; i < 9; i++) {
      final p = ((t + i / 9) % 1.0);
      final y = diverterRect.top - p * (diverterRect.top - flueRect.top - 6);
      canvas.drawCircle(
        Offset(flueX + math.sin(p * 6) * 4, y),
        4 - p * 1.5,
        Paint()..color = Colors.orange.withValues(alpha: (1 - p) * 0.85),
      );
    }

    // Room ventilator on opposite wall
    final ventRect = Rect.fromLTWH(8, casing.center.dy - 14, 22, 28);
    canvas.drawRect(
      ventRect,
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      ventRect,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    for (int i = 0; i < 4; i++) {
      final y = ventRect.top + 4 + i * 6;
      canvas.drawLine(
        Offset(ventRect.left + 2, y),
        Offset(ventRect.right - 2, y),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.2,
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ventRect.right + 4, ventRect.top - 14),
      'Room ventilator (5 cm² / kW)',
    );

    // Inflowing air particles from vent toward burner
    for (int i = 0; i < 6; i++) {
      final p = ((t + i / 6) % 1.0);
      final x = ventRect.right + p * (casing.left - ventRect.right - 4);
      final y = casing.center.dy + math.sin(p * 5) * 6;
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = AppColors.coldWater.withValues(alpha: (1 - p) * 0.9),
      );
    }

    // Label - room air taken from the dwelling (only on open)
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.04, casing.bottom - 36),
      'Room air taken from the dwelling',
      background: AppColors.accent,
      textColor: Colors.white,
    );

    // Clearances
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(flueRect.right + 6, flueRect.top + 24),
      '600 mm above ridge',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(diverterRect.left - 6, diverterRect.bottom - 36),
      'Spillage zone',
    );
  }

  void _drawBalanced(Canvas canvas, Size size, Rect casing, double wallX, double groundY) {
    // Flue takes a horizontal run out through the wall
    final flueY = casing.top + 20;
    // Inside leg
    final aIn = Offset(casing.right, flueY);
    final aThroughWall = Offset(wallX - 8, flueY);
    final aOuter = Offset(wallX + 26, flueY);
    canvas.drawRect(
      Rect.fromLTRB(aIn.dx, flueY - 12, aThroughWall.dx, flueY + 12),
      Paint()..color = AppColors.pipeMetal,
    );
    canvas.drawRect(
      Rect.fromLTRB(aIn.dx, flueY - 12, aThroughWall.dx, flueY + 12),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Concentric terminal (outer + inner)
    // Outer ring
    final terminal = Rect.fromCenter(
      center: Offset(aOuter.dx, flueY),
      width: 56,
      height: 38,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(terminal, const Radius.circular(6)),
      Paint()..color = AppColors.coldWater.withValues(alpha: 0.4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(terminal, const Radius.circular(6)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Inner exhaust pipe
    final innerRect = Rect.fromCenter(
      center: Offset(aOuter.dx, flueY),
      width: 30,
      height: 18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(4)),
      Paint()..color = AppColors.pipeMetal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(terminal.right + 6, terminal.top - 4),
      'Concentric terminal',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(terminal.right + 6, terminal.top + 16),
      'Outer = air intake',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(terminal.right + 6, terminal.top + 34),
      'Inner = exhaust',
    );

    // Animated flue gas going outward (orange) inside the inner pipe
    for (int i = 0; i < 8; i++) {
      final p = ((t + i / 8) % 1.0);
      final x = aIn.dx + p * (aOuter.dx + 10 - aIn.dx);
      canvas.drawCircle(
        Offset(x, flueY - 4),
        3,
        Paint()..color = Colors.orange.withValues(alpha: (1 - p) * 0.95),
      );
    }
    // Animated air intake (blue) from outside in
    for (int i = 0; i < 8; i++) {
      final p = ((t + i / 8) % 1.0);
      final x = aOuter.dx + 18 - p * (aOuter.dx + 18 - aIn.dx);
      canvas.drawCircle(
        Offset(x, flueY + 6),
        3,
        Paint()..color = AppColors.coldWater.withValues(alpha: (1 - p) * 0.9),
      );
    }

    // Pipe up from appliance to flue route
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(casing.center.dx, casing.top),
      b: Offset(casing.center.dx, flueY),
      color: AppColors.pipeMetal,
      width: 18,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(casing.center.dx, flueY),
      b: aIn,
      color: AppColors.pipeMetal,
      width: 18,
    );

    // Window above terminal (clearance reference)
    final windowRect = Rect.fromLTWH(wallX + 60, flueY - 110, 70, 50);
    canvas.drawRect(
      windowRect,
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      windowRect,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      Offset(windowRect.center.dx, windowRect.top),
      Offset(windowRect.center.dx, windowRect.bottom),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 1,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(windowRect.left, windowRect.top - 14),
      'Opening window',
    );

    // Clearance arrows / labels
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(terminal.right + 6, terminal.bottom + 12),
      '300 mm below opening',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(terminal.left - 30, terminal.bottom + 30),
      '300 mm above ground',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(terminal.left, terminal.top - 22),
      '600 mm to facing wall',
    );
  }

  void _drawFan(Canvas canvas, Size size, Rect casing, double wallX, double groundY) {
    // Similar concentric terminal but with a longer route and fan symbol
    final flueY = casing.top + 20;
    final aIn = Offset(casing.right, flueY);
    final aOuter = Offset(wallX + 26, flueY);
    // Long horizontal pipe (mid-section showing the fan)
    canvas.drawRect(
      Rect.fromLTRB(aIn.dx, flueY - 12, wallX - 8, flueY + 12),
      Paint()..color = AppColors.pipeMetal,
    );
    canvas.drawRect(
      Rect.fromLTRB(aIn.dx, flueY - 12, wallX - 8, flueY + 12),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Fan symbol within the pipe near the appliance
    final fanCentre = Offset(aIn.dx + 32, flueY);
    canvas.drawCircle(fanCentre, 14, Paint()..color = const Color(0xFFD3DAE2));
    canvas.drawCircle(
      fanCentre,
      14,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final spinAngle = t * math.pi * 8;
    for (int i = 0; i < 4; i++) {
      final a = spinAngle + i * math.pi / 2;
      final p1 = fanCentre;
      final p2 = Offset(fanCentre.dx + math.cos(a) * 12, fanCentre.dy + math.sin(a) * 12);
      final p3 = Offset(
        fanCentre.dx + math.cos(a + 0.4) * 8,
        fanCentre.dy + math.sin(a + 0.4) * 8,
      );
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = Colors.black87);
    }
    canvas.drawCircle(fanCentre, 3, Paint()..color = AppColors.accent);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(fanCentre.dx - 18, fanCentre.dy + 18),
      'Flue fan',
    );

    // Concentric terminal
    final terminal = Rect.fromCenter(
      center: Offset(aOuter.dx, flueY),
      width: 56,
      height: 38,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(terminal, const Radius.circular(6)),
      Paint()..color = AppColors.coldWater.withValues(alpha: 0.4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(terminal, const Radius.circular(6)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final innerRect = Rect.fromCenter(
      center: Offset(aOuter.dx, flueY),
      width: 30,
      height: 18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(4)),
      Paint()..color = AppColors.pipeMetal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(terminal.right + 6, terminal.top - 4),
      'Concentric terminal',
    );

    // Animated flue gas (faster due to fan)
    for (int i = 0; i < 10; i++) {
      final p = ((t * 1.6 + i / 10) % 1.0);
      final x = aIn.dx + p * (aOuter.dx + 10 - aIn.dx);
      canvas.drawCircle(
        Offset(x, flueY - 4),
        3,
        Paint()..color = Colors.orange.withValues(alpha: (1 - p) * 0.95),
      );
    }
    // Air in
    for (int i = 0; i < 10; i++) {
      final p = ((t * 1.6 + i / 10) % 1.0);
      final x = aOuter.dx + 18 - p * (aOuter.dx + 18 - aIn.dx);
      canvas.drawCircle(
        Offset(x, flueY + 6),
        3,
        Paint()..color = AppColors.coldWater.withValues(alpha: (1 - p) * 0.9),
      );
    }

    // Pipe up from appliance
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(casing.center.dx, casing.top),
      b: Offset(casing.center.dx, flueY),
      color: AppColors.pipeMetal,
      width: 18,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(casing.center.dx, flueY),
      b: aIn,
      color: AppColors.pipeMetal,
      width: 18,
    );

    // Air-pressure switch indication
    final apsRect = Rect.fromLTWH(casing.center.dx + 30, casing.top - 24, 36, 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(apsRect, const Radius.circular(3)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(apsRect, const Radius.circular(3)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(apsRect.left - 6, apsRect.top - 14),
      'Air-pressure switch',
    );

    // Clearance labels
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(terminal.right + 6, terminal.bottom + 12),
      '300 mm below opening',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(terminal.left - 30, terminal.bottom + 30),
      '300 mm above ground',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(terminal.left - 30, terminal.top - 22),
      'Longer horizontal run permitted',
    );
  }

  void _drawSmallFlame(Canvas canvas, Offset base, double time) {
    final flicker = 1 + math.sin(time * math.pi * 8) * 0.3;
    final hh = 16 * flicker;
    final path = Path()
      ..moveTo(base.dx - 4, base.dy)
      ..quadraticBezierTo(base.dx - 6, base.dy - hh * 0.6, base.dx, base.dy - hh)
      ..quadraticBezierTo(base.dx + 6, base.dy - hh * 0.6, base.dx + 4, base.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = AppColors.gas.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _FluePainter old) =>
      old.t != t || old.step != step || old.kind != kind;
}

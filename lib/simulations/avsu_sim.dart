import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/paint_helpers.dart';
import '../widgets/sim_scaffold.dart';

/// Animated training simulation for an Area Valve Service Unit (AVSU)
/// installation as required by HTM 02-01. Three AVSUs serve a ward with
/// oxygen, four bar medical air and medical vacuum, and the user can
/// open or close each valve, simulate an emergency shutdown, and reset.
class AvsuSimScreen extends StatefulWidget {
  const AvsuSimScreen({super.key});

  @override
  State<AvsuSimScreen> createState() => _AvsuSimScreenState();
}

class _AvsuSimScreenState extends State<AvsuSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  bool _o2Open = true;
  bool _airOpen = true;
  bool _vacOn = true;
  bool _emergency = false;

  static const Color _oxygenColour = Color(0xFF3CB371);
  static const Color _vacuumColour = Color(0xFFE6B800);

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

  void _emergencyShutdown() {
    setState(() {
      _o2Open = false;
      _airOpen = false;
      _vacOn = false;
      _emergency = true;
    });
  }

  void _reset() {
    setState(() {
      _o2Open = true;
      _airOpen = true;
      _vacOn = true;
      _emergency = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'AVSU and emergency isolation',
      summary:
          'Three Area Valve Service Units feed a clinical zone with oxygen, four bar medical air and medical vacuum. Practise routine isolation and emergency shutdown under HTM 02-01.',
      onStepChanged: (_) => setState(() {}),
      controls: [
        _switchTile(
          label: 'Oxygen open',
          value: _o2Open,
          colour: _oxygenColour,
          onChanged: _emergency
              ? null
              : (v) => setState(() => _o2Open = v),
        ),
        _switchTile(
          label: 'Medical air open',
          value: _airOpen,
          colour: AppColors.coldWater,
          onChanged: _emergency
              ? null
              : (v) => setState(() => _airOpen = v),
        ),
        _switchTile(
          label: 'Vacuum on',
          value: _vacOn,
          colour: _vacuumColour,
          onChanged: _emergency
              ? null
              : (v) => setState(() => _vacOn = v),
        ),
        SizedBox(
          width: 230,
          child: ElevatedButton.icon(
            onPressed: _emergency ? null : _emergencyShutdown,
            icon: const Icon(Icons.local_fire_department),
            label: const Text('Emergency shutdown'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(
          width: 230,
          child: OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset to normal'),
          ),
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _AvsuPainter(
            step: i,
            t: _ctrl.value,
            o2Open: _o2Open,
            airOpen: _airOpen,
            vacOn: _vacOn,
            emergency: _emergency,
            oxygenColour: _oxygenColour,
            airColour: AppColors.coldWater,
            vacuumColour: _vacuumColour,
          ),
          size: Size.infinite,
        ),
      ),
      steps: const [
        SimStep(
          title: 'Purpose of the AVSU',
          narration:
              'Each AVSU is a single point of isolation for one clinical zone. In an emergency, closing the cabinet valve takes that ward off supply within seconds without disturbing the rest of the hospital.',
        ),
        SimStep(
          title: 'Components inside the cabinet',
          narration:
              'Inside each AVSU are a full bore lever ball valve, a pressure gauge upstream and downstream, an alarm contact wired to the area panel, and a locking mechanism that requires a key or break glass tag.',
        ),
        SimStep(
          title: 'Authorised Person procedure',
          narration:
              'Routine operation of an AVSU is only carried out under a permit to work issued by the AP-MGPS. The clinical lead, the duty manager and any contractor are all named on the permit before the key is released.',
        ),
        SimStep(
          title: 'Permit to work and patient safety',
          narration:
              'Before the valve is closed, the clinical team prepares alternative supply for any ventilated patients using cylinders and ensures monitoring is in place. The valve is never operated until clinical staff have agreed.',
        ),
        SimStep(
          title: 'Closing the valve',
          narration:
              'When the ball valve is closed, the downstream gauge in the cabinet falls to zero and the area alarm panel raises an audible and visual low pressure alarm. The flow into the ward stops on the diagram.',
        ),
        SimStep(
          title: 'Emergency shutdown',
          narration:
              'In a fire or major leak, all AVSUs serving the affected zone are closed in coordination with the fire service and clinical staff. Cylinder backup keeps essential ventilators running while the cause is found.',
        ),
        SimStep(
          title: 'Reinstatement after work',
          narration:
              'Reinstatement requires the system to be purged with the correct gas, leak tested at working pressure, identity tested at every terminal and signed off by the AP-MGPS before the area returns to clinical use.',
        ),
        SimStep(
          title: 'Common faults',
          narration:
              'Typical AVSU faults include a leaking valve gland that drops downstream pressure slowly, a sticking lock that delays emergency operation, and a failed alarm contact that fails to signal a closed valve at the panel.',
        ),
      ],
    );
  }

  Widget _switchTile({
    required String label,
    required bool value,
    required Color colour,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      width: 230,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colour.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: colour, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _AvsuPainter extends CustomPainter {
  final int step;
  final double t;
  final bool o2Open;
  final bool airOpen;
  final bool vacOn;
  final bool emergency;
  final Color oxygenColour;
  final Color airColour;
  final Color vacuumColour;

  _AvsuPainter({
    required this.step,
    required this.t,
    required this.o2Open,
    required this.airOpen,
    required this.vacOn,
    required this.emergency,
    required this.oxygenColour,
    required this.airColour,
    required this.vacuumColour,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background: corridor and ward
    final bg = Paint()..color = const Color(0xFFF1F4F8);
    canvas.drawRect(Offset.zero & size, bg);

    // Corridor wall
    final corridorTop = h * 0.12;
    final wallY = h * 0.55;
    final wardTop = wallY;
    final wardBottom = h * 0.93;

    // Ward area (lighter)
    final wardPaint = Paint()..color = const Color(0xFFE9F5EC);
    canvas.drawRect(
      Rect.fromLTRB(w * 0.06, wardTop, w * 0.94, wardBottom),
      wardPaint,
    );

    // Wall line
    final wallPaint = Paint()
      ..color = const Color(0xFF9AA4AE)
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(w * 0.04, wallY),
      Offset(w * 0.96, wallY),
      wallPaint,
    );

    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.07, wardTop + 8),
      'Ward 4B clinical zone',
    );

    // Top distribution line
    final riserY = corridorTop + 14;
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.04, corridorTop - 16),
      'Plant room riser  -  HTM 02-01',
    );

    // Three AVSU positions
    final centresX = [w * 0.22, w * 0.50, w * 0.78];
    final gases = [
      _GasInfo(
        name: 'Oxygen',
        formula: 'O2',
        colour: oxygenColour,
        on: o2Open,
        pressure: '4.1 bar',
        nominal: 4.1,
      ),
      _GasInfo(
        name: 'Medical air 4 bar',
        formula: 'Air',
        colour: airColour,
        on: airOpen,
        pressure: '4.1 bar',
        nominal: 4.1,
      ),
      _GasInfo(
        name: 'Vacuum',
        formula: 'Vac',
        colour: vacuumColour,
        on: vacOn,
        pressure: '-40 kPa',
        nominal: -0.4,
      ),
    ];

    // Alarm panel above corridor
    final panelRect = Rect.fromLTWH(w * 0.34, 8, w * 0.32, corridorTop - 22);
    final panelBg = Paint()
      ..color = emergency
          ? AppColors.accent.withValues(alpha: 0.85)
          : const Color(0xFF1B2A36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(panelRect, const Radius.circular(8)),
      panelBg,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(panelRect.left + 8, panelRect.top + 4),
      emergency ? 'AREA ALARM  -  EMERGENCY' : 'Area alarm panel',
      background: emergency ? Colors.white : Colors.white,
      textColor: emergency ? AppColors.accent : AppColors.primaryDark,
    );

    // Three alarm LEDs on the panel
    for (int i = 0; i < gases.length; i++) {
      final lx = panelRect.left + 16 + i * (panelRect.width / 3.2);
      final ly = panelRect.top + panelRect.height - 12;
      final fault = !gases[i].on || emergency;
      final ledColour = fault
          ? (emergency
              ? Colors.redAccent
              : Colors.orangeAccent)
          : Colors.greenAccent;
      canvas.drawCircle(
        Offset(lx, ly),
        4.5 + (fault ? 1.0 + 0.6 * (0.5 + 0.5 * (t * 6.28).abs()) : 0),
        Paint()..color = ledColour,
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(lx + 8, ly - 8),
        gases[i].formula,
        background: Colors.white,
        fontSize: 9,
      );
    }

    // Distribution riser pipes from left to right
    for (int i = 0; i < gases.length; i++) {
      final yOff = riserY + i * 10;
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(w * 0.04, yOff),
        b: Offset(w * 0.96, yOff),
        color: gases[i].colour,
        width: 8,
      );
    }

    // Per-AVSU cabinet drawing
    for (int i = 0; i < gases.length; i++) {
      _drawAvsuCabinet(canvas, w, h, centresX[i], wallY, gases[i]);
      _drawDropAndBranch(
          canvas, w, h, centresX[i], riserY + i * 10, wallY, gases[i]);
    }

    // Branch lines into ward (terminals)
    for (int i = 0; i < gases.length; i++) {
      final x = centresX[i];
      final yStart = wallY + 6;
      final yEnd = wardBottom - 30;
      final colour = gases[i].colour;
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(x, yStart),
        b: Offset(x, yEnd),
        color: colour,
        width: 7,
      );
      // Terminal unit at end
      _drawTerminalUnit(canvas, Offset(x, yEnd + 10), gases[i]);
      // Particles only when valve open and not in emergency
      if (gases[i].on && !emergency) {
        PipePainterHelpers.drawFlowParticles(
          canvas,
          a: Offset(x, yStart),
          b: Offset(x, yEnd),
          progress: t,
          color: Colors.white.withValues(alpha: 0.85),
          count: 5,
          radius: 2.6,
        );
      } else {
        // Strike-through to show isolation
        final cross = Paint()
          ..color = AppColors.accent.withValues(alpha: 0.7)
          ..strokeWidth = 2.5;
        canvas.drawLine(
          Offset(x - 12, (yStart + yEnd) / 2 - 12),
          Offset(x + 12, (yStart + yEnd) / 2 + 12),
          cross,
        );
        canvas.drawLine(
          Offset(x - 12, (yStart + yEnd) / 2 + 12),
          Offset(x + 12, (yStart + yEnd) / 2 - 12),
          cross,
        );
      }
    }

    // Step caption banner
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.06, h - 18),
      'Step ${step + 1} of 8  -  AVSU operation under HTM 02-01',
      background: AppColors.cardBg,
      fontSize: 11,
    );
  }

  void _drawAvsuCabinet(
      Canvas canvas, double w, double h, double cx, double wallY, _GasInfo g) {
    final cabRect = Rect.fromCenter(
      center: Offset(cx, wallY - 60),
      width: w * 0.18,
      height: 90,
    );
    final cabBody = Paint()..color = Colors.white;
    final cabStroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cabRect, const Radius.circular(6)),
      cabBody,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cabRect, const Radius.circular(6)),
      cabStroke,
    );

    // Header band in gas colour
    final headerRect = Rect.fromLTWH(
      cabRect.left,
      cabRect.top,
      cabRect.width,
      18,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        headerRect,
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      ),
      Paint()..color = g.colour.withValues(alpha: 0.85),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cabRect.left + 6, cabRect.top + 2),
      '${g.name}  AVSU',
      background: Colors.white,
      fontSize: 9,
    );

    // Pressure gauge
    final gaugeC = Offset(cabRect.left + 22, cabRect.top + 50);
    canvas.drawCircle(gaugeC, 11,
        Paint()..color = const Color(0xFFEDEDED));
    canvas.drawCircle(gaugeC, 11,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    // Needle
    final nominal = g.on && !emergency ? 1.0 : 0.0;
    final isVacuum = g.name == 'Vacuum';
    final theta = isVacuum
        ? (-2.4 + 1.8 * nominal)
        : (-2.4 + 1.8 * nominal);
    final needleEnd = Offset(
      gaugeC.dx + 9 * _cos(theta),
      gaugeC.dy + 9 * _sin(theta),
    );
    canvas.drawLine(
      gaugeC,
      needleEnd,
      Paint()
        ..color = nominal == 0 ? AppColors.accent : AppColors.primary
        ..strokeWidth = 2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gaugeC.dx - 12, gaugeC.dy + 14),
      g.pressure,
      fontSize: 9,
    );

    // Lockable valve (key icon)
    final valveC = Offset(cabRect.right - 30, cabRect.top + 50);
    PipePainterHelpers.drawValve(canvas, valveC,
        open: g.on && !emergency, size: 10);
    // Key icon above
    final keyP = Paint()..color = Colors.amber.shade700;
    canvas.drawCircle(Offset(valveC.dx, valveC.dy - 22), 4, keyP);
    canvas.drawRect(
      Rect.fromLTWH(valveC.dx - 1.5, valveC.dy - 22, 3, 8),
      keyP,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(valveC.dx - 14, valveC.dy + 14),
      'Lock',
      fontSize: 9,
    );

    // Status LEDs
    final normalLed = Offset(cabRect.left + 8, cabRect.top + 24);
    final faultLed = Offset(cabRect.left + 8, cabRect.top + 36);
    final isFault = !g.on || emergency;
    canvas.drawCircle(
      normalLed,
      3.2,
      Paint()
        ..color = isFault
            ? Colors.green.withValues(alpha: 0.25)
            : Colors.greenAccent,
    );
    canvas.drawCircle(
      faultLed,
      3.2,
      Paint()
        ..color = isFault
            ? (emergency ? Colors.redAccent : Colors.orangeAccent)
            : Colors.red.withValues(alpha: 0.25),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(normalLed.dx + 8, normalLed.dy - 4),
      'NORMAL',
      fontSize: 8,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(faultLed.dx + 8, faultLed.dy - 4),
      'FAULT',
      fontSize: 8,
    );

    // Pipeline ID label
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cabRect.left, cabRect.bottom + 4),
      'ID: ${g.formula}/${(_pipelineId(g.name))}',
      fontSize: 9,
    );
  }

  void _drawDropAndBranch(Canvas canvas, double w, double h, double cx,
      double riserY, double wallY, _GasInfo g) {
    // Vertical drop from riser into the AVSU cabinet
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(cx, riserY),
      b: Offset(cx, wallY - 60),
      color: g.colour,
      width: 7,
    );
    PipePainterHelpers.drawJoint(canvas, Offset(cx, riserY));
  }

  void _drawTerminalUnit(Canvas canvas, Offset p, _GasInfo g) {
    final r = Rect.fromCenter(center: p, width: 26, height: 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawCircle(p, 4, Paint()..color = g.colour);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(p.dx - 18, p.dy + 12),
      'BS 5682 ${g.formula}',
      fontSize: 9,
    );
  }

  String _pipelineId(String gasName) {
    switch (gasName) {
      case 'Oxygen':
        return '01';
      case 'Medical air 4 bar':
        return '04';
      case 'Vacuum':
        return '07';
      default:
        return '00';
    }
  }

  // Avoid extra dart:math import; reuse trig from helpers? Inline simple impl.
  double _cos(double r) =>
      _polyCos(((r % 6.28318530718) + 6.28318530718) % 6.28318530718);
  double _sin(double r) => _cos(r - 1.5707963267948966);

  double _polyCos(double x) {
    // High accuracy not needed for needle; use Taylor up to x^6 around 0
    // after reducing into [-pi, pi].
    double v = x;
    if (v > 3.14159265358979) v -= 6.28318530718;
    final v2 = v * v;
    return 1 - v2 / 2 + (v2 * v2) / 24 - (v2 * v2 * v2) / 720;
  }

  @override
  bool shouldRepaint(_AvsuPainter old) => true;
}

class _GasInfo {
  final String name;
  final String formula;
  final Color colour;
  final bool on;
  final String pressure;
  final double nominal;
  const _GasInfo({
    required this.name,
    required this.formula,
    required this.colour,
    required this.on,
    required this.pressure,
    required this.nominal,
  });
}

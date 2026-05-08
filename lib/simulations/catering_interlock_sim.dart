import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/paint_helpers.dart';
import '../widgets/sim_scaffold.dart';

/// Animated walkthrough of a BS 6173 commercial catering gas interlock.
///
/// The user can toggle the extract fan, make-up air and pressure-proving
/// switch and attempt to arm the gas solenoid. The painter only animates
/// gas particles when every interlock condition is satisfied.
class CateringInterlockSimScreen extends StatefulWidget {
  const CateringInterlockSimScreen({super.key});

  @override
  State<CateringInterlockSimScreen> createState() =>
      _CateringInterlockSimScreenState();
}

class _CateringInterlockSimScreenState extends State<CateringInterlockSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Interlock input state
  bool _extractOn = false;
  bool _makeupAir = false;
  bool _ppsmade = false;

  // Latched conditions
  bool _solenoidOpen = false;
  bool _epoLatched = false;
  bool _gpssOk = true;
  String? _statusMessage;

  bool get _conditionsMet =>
      _extractOn && _makeupAir && _ppsmade && _gpssOk && !_epoLatched;

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

  void _activateGas() {
    if (_epoLatched) {
      setState(() => _statusMessage =
          'EPO is latched. Reset the interlock before re-arming.');
      return;
    }
    if (!_extractOn) {
      setState(() =>
          _statusMessage = 'Extract fan must be running before gas can flow.');
      return;
    }
    if (!_makeupAir) {
      setState(() => _statusMessage =
          'Make-up air not detected. Combustion air supply required.');
      return;
    }
    if (!_ppsmade) {
      setState(() => _statusMessage =
          'Air pressure proving switch has not made. Check duct pressure.');
      return;
    }
    if (!_gpssOk) {
      setState(() => _statusMessage =
          'GPPS reports a downstream leak. Investigate before re-arming.');
      return;
    }
    setState(() {
      _solenoidOpen = true;
      _statusMessage = 'Solenoid open — gas flowing to appliances.';
    });
  }

  void _pressEpo() {
    setState(() {
      _epoLatched = true;
      _solenoidOpen = false;
      _statusMessage = 'EPO pressed — solenoid latched closed.';
    });
  }

  void _resetInterlock() {
    setState(() {
      _epoLatched = false;
      _solenoidOpen = false;
      _gpssOk = true;
      _statusMessage = 'Interlock reset. Re-arm by activating gas.';
    });
  }

  void _onStepChanged(int step) {
    // Step 8: simulate EPO press for narration consistency.
    if (step == 7 && !_epoLatched) {
      // Don't auto-press; just clear stale messages.
      setState(() => _statusMessage = null);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final gasFlowing = _solenoidOpen && _conditionsMet;
    return SimScaffold(
      title: 'Catering interlock — BS 6173',
      summary:
          'Commercial kitchens must interlock the gas supply with the extract '
          'system per BS 6173. Use the controls to satisfy or fail the '
          'interlock and watch how the controller, GPPS and solenoid respond.',
      onStepChanged: _onStepChanged,
      controls: [
        _Toggle(
          label: 'Extract fan running',
          value: _extractOn,
          onChanged: (v) => setState(() {
            _extractOn = v;
            if (!v) {
              _solenoidOpen = false;
              _statusMessage = 'Extract stopped — solenoid closed.';
            }
          }),
        ),
        _Toggle(
          label: 'Make-up air available',
          value: _makeupAir,
          onChanged: (v) => setState(() {
            _makeupAir = v;
            if (!v) {
              _solenoidOpen = false;
              _statusMessage = 'Make-up air lost — solenoid closed.';
            }
          }),
        ),
        _Toggle(
          label: 'Air pressure proving switch made',
          value: _ppsmade,
          onChanged: (v) => setState(() {
            _ppsmade = v;
            if (!v) {
              _solenoidOpen = false;
              _statusMessage = 'PPS dropped out — solenoid closed.';
            }
          }),
        ),
        _Action(
          label: 'Activate gas',
          icon: Icons.local_fire_department,
          enabled: !_solenoidOpen,
          onPressed: _activateGas,
        ),
        _Action(
          label: 'Press EPO',
          icon: Icons.dangerous_outlined,
          enabled: !_epoLatched,
          colour: AppColors.accent,
          onPressed: _pressEpo,
        ),
        _Action(
          label: 'Reset interlock',
          icon: Icons.replay,
          enabled: true,
          onPressed: _resetInterlock,
        ),
        if (_statusMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: (_solenoidOpen ? AppColors.primary : AppColors.accent)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (_solenoidOpen ? AppColors.primary : AppColors.accent)
                    .withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              _statusMessage!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _CateringInterlockPainter(
            step: i,
            t: _ctrl.value,
            extractOn: _extractOn,
            makeupAir: _makeupAir,
            ppsmade: _ppsmade,
            solenoidOpen: _solenoidOpen,
            epoLatched: _epoLatched,
            gpssOk: _gpssOk,
            gasFlowing: gasFlowing,
          ),
          size: Size.infinite,
        ),
      ),
      steps: const [
        SimStep(
          title: 'Why interlocks exist',
          narration:
              'Uncombusted gas accumulating in a commercial kitchen alongside '
              'naked flames creates a catastrophic explosion risk. BS 6173 '
              'and IGEM/UP/19 require that gas can only flow when extraction '
              'is proven to be moving air.',
        ),
        SimStep(
          title: 'Components of a BS 6173 interlock',
          narration:
              'The system comprises a gas solenoid, an air pressure proving '
              'switch in the duct, a make-up air sensor, an emergency stop, '
              'a gas pressure proving system and a controller that supervises '
              'all inputs.',
        ),
        SimStep(
          title: 'Air pressure proving switch',
          narration:
              'The PPS is a differential pressure switch sensing static '
              'pressure across the extract fan. Until it makes, the controller '
              'will not energise the solenoid coil.',
        ),
        SimStep(
          title: 'Make-up air',
          narration:
              'A kitchen running with extract but no replacement air will '
              'starve appliances of combustion oxygen and pull flue gases back '
              'down the flue. EN 1775 and BS 6173 require make-up to be '
              'proven.',
        ),
        SimStep(
          title: 'Gas pressure proving system',
          narration:
              'Before re-arming, the GPPS isolates the manifold, tests for a '
              'pressure decay, and only then permits the controller to open '
              'the solenoid. This catches downstream leaks before gas is '
              'delivered.',
        ),
        SimStep(
          title: 'The solenoid valve fails closed',
          narration:
              'A normally-closed solenoid only opens while continuously '
              'energised. Loss of any interlock signal removes the holding '
              'current and the valve drops shut within milliseconds.',
        ),
        SimStep(
          title: 'Sequence of operation',
          narration:
              'Extract fan starts, the PPS makes, make-up air is confirmed, '
              'the GPPS test passes and the controller drives the solenoid '
              'open. Gas now flows to the cooker, fryer and salamander.',
        ),
        SimStep(
          title: 'Emergency stop and recovery',
          narration:
              'Pressing the EPO mushroom button latches the solenoid closed '
              'irrespective of any other input. The system can only be '
              're-armed by a deliberate reset and a fresh GPPS cycle.',
        ),
        SimStep(
          title: 'Common faults',
          narration:
              'A sticking PPS gives spurious enables, a failed solenoid coil '
              'prevents arming, and GPPS sensor drift can cause repeated '
              'leak-test failures even with sound pipework. Always verify '
              'with a manometer.',
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value ? AppColors.primary : Colors.black12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(value: value, onChanged: onChanged),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final Color? colour;
  const _Action({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    this.colour,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: colour ?? AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _CateringInterlockPainter extends CustomPainter {
  final int step;
  final double t;
  final bool extractOn;
  final bool makeupAir;
  final bool ppsmade;
  final bool solenoidOpen;
  final bool epoLatched;
  final bool gpssOk;
  final bool gasFlowing;

  _CateringInterlockPainter({
    required this.step,
    required this.t,
    required this.extractOn,
    required this.makeupAir,
    required this.ppsmade,
    required this.solenoidOpen,
    required this.epoLatched,
    required this.gpssOk,
    required this.gasFlowing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background — kitchen floor + wall band.
    final bg = Paint()..color = const Color(0xFFF1F4F8);
    canvas.drawRect(Offset.zero & size, bg);
    final wall = Paint()..color = const Color(0xFFE5E9EE);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.6),
      wall,
    );
    // Floor line
    final floorY = size.height * 0.82;
    canvas.drawLine(
      Offset(0, floorY),
      Offset(size.width, floorY),
      Paint()
        ..color = Colors.black26
        ..strokeWidth = 1.4,
    );

    final w = size.width;
    final h = size.height;

    // === Canopy / extract hood ===
    final canopyRect = Rect.fromLTWH(w * 0.22, h * 0.06, w * 0.55, h * 0.16);
    final canopy = Paint()..color = const Color(0xFFB8BEC7);
    final canopyStroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(canopyRect, const Radius.circular(8)),
      canopy,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(canopyRect, const Radius.circular(8)),
      canopyStroke,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(canopyRect.left + 6, canopyRect.top + 6),
      'Extract canopy',
      fontSize: 10,
    );

    // Extract duct rising from canopy
    final ductTop = Offset(canopyRect.center.dx, h * 0.02);
    final ductBottom = Offset(canopyRect.center.dx, canopyRect.top);
    PipePainterHelpers.drawPipe(
      canvas,
      a: ductTop,
      b: ductBottom,
      color: AppColors.pipeMetal,
      width: 18,
    );
    // Extract fan symbol
    final fanCentre = Offset(canopyRect.center.dx, h * 0.05);
    _drawFan(canvas, fanCentre, t, running: extractOn);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(fanCentre.dx + 16, fanCentre.dy - 6),
      'Extract fan',
      fontSize: 10,
    );

    // Air particles in duct when extract is running
    if (extractOn) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: ductBottom,
        b: ductTop,
        progress: t,
        color: AppColors.coldWater,
        count: 5,
        radius: 2.6,
      );
    }

    // PPS on duct
    final ppsAt = Offset(canopyRect.center.dx + 26, canopyRect.top - h * 0.05);
    _drawPps(canvas, ppsAt, made: ppsmade);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ppsAt.dx + 14, ppsAt.dy - 8),
      'Air PPS',
      fontSize: 10,
    );

    // Make-up air supply (fresh-air grille on left wall)
    final mauRect =
        Rect.fromLTWH(w * 0.02, h * 0.16, w * 0.08, h * 0.06);
    final mauPaint = Paint()
      ..color = makeupAir
          ? AppColors.coldWater.withValues(alpha: 0.25)
          : Colors.black12;
    canvas.drawRRect(
      RRect.fromRectAndRadius(mauRect, const Radius.circular(4)),
      mauPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mauRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // grille slats
    for (int i = 1; i < 5; i++) {
      final y = mauRect.top + i * (mauRect.height / 5);
      canvas.drawLine(
        Offset(mauRect.left + 2, y),
        Offset(mauRect.right - 2, y),
        Paint()
          ..color = Colors.black45
          ..strokeWidth = 1,
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(mauRect.left, mauRect.bottom + 4),
      'Make-up air',
      fontSize: 10,
    );
    if (makeupAir) {
      // arrows showing air entering
      for (int i = 0; i < 3; i++) {
        final xs = mauRect.right + ((t * 40) + i * 18) % 60;
        final y = mauRect.center.dy + (i - 1) * 6;
        _drawArrow(canvas, Offset(xs, y), Offset(xs + 14, y),
            AppColors.coldWater);
      }
    }

    // === Gas inlet pipe ===
    final inletStart = Offset(w * 0.02, h * 0.6);
    final solenoidAt = Offset(w * 0.18, h * 0.6);
    final gpssAt = Offset(w * 0.28, h * 0.6);
    final manifoldStart = Offset(w * 0.36, h * 0.6);
    final manifoldEnd = Offset(w * 0.86, h * 0.6);

    PipePainterHelpers.drawPipe(
      canvas,
      a: inletStart,
      b: solenoidAt,
      color: AppColors.gas,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(inletStart.dx + 4, inletStart.dy - 22),
      'Gas inlet',
      fontSize: 10,
    );

    // Solenoid valve (uses drawValve, red=open / grey=closed)
    PipePainterHelpers.drawPipe(
      canvas,
      a: solenoidAt,
      b: gpssAt,
      color: AppColors.gas,
    );
    PipePainterHelpers.drawValve(canvas, solenoidAt, open: solenoidOpen);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(solenoidAt.dx - 26, solenoidAt.dy + 18),
      solenoidOpen ? 'Solenoid OPEN' : 'Solenoid CLOSED',
      fontSize: 10,
      background: solenoidOpen
          ? AppColors.primary.withValues(alpha: 0.15)
          : Colors.white,
    );

    // GPPS block — small box with sensor dot and vent
    _drawGpps(canvas, gpssAt, ok: gpssOk);
    PipePainterHelpers.drawPipe(
      canvas,
      a: gpssAt,
      b: manifoldStart,
      color: AppColors.gas,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gpssAt.dx - 12, gpssAt.dy + 32),
      'GPPS',
      fontSize: 10,
    );

    // Manifold
    PipePainterHelpers.drawPipe(
      canvas,
      a: manifoldStart,
      b: manifoldEnd,
      color: AppColors.gas,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(manifoldStart.dx + 4, manifoldStart.dy - 22),
      'Manifold',
      fontSize: 10,
    );

    // Three appliance drops + appliances
    final appliances = <_Appliance>[
      _Appliance(
        x: w * 0.46,
        label: 'Cooker',
        kind: _ApplianceKind.cooker,
      ),
      _Appliance(
        x: w * 0.62,
        label: 'Fryer',
        kind: _ApplianceKind.fryer,
      ),
      _Appliance(
        x: w * 0.78,
        label: 'Salamander',
        kind: _ApplianceKind.salamander,
      ),
    ];
    for (final a in appliances) {
      final dropTop = Offset(a.x, h * 0.6);
      final dropBottom = Offset(a.x, h * 0.74);
      PipePainterHelpers.drawPipe(
        canvas,
        a: dropTop,
        b: dropBottom,
        color: AppColors.gas,
        width: 10,
      );
      PipePainterHelpers.drawJoint(canvas, dropTop);
      _drawAppliance(canvas, dropBottom, a.kind, gasFlowing);
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(a.x - 22, h * 0.78 + 10),
        a.label,
        fontSize: 10,
      );

      // Animated gas particles only if interlock satisfied.
      if (gasFlowing) {
        PipePainterHelpers.drawFlowParticles(
          canvas,
          a: dropTop,
          b: dropBottom,
          progress: t,
          color: AppColors.gas,
          count: 4,
          radius: 2.6,
        );
      }
    }
    if (gasFlowing) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: manifoldStart,
        b: manifoldEnd,
        progress: t,
        color: AppColors.gas,
        count: 7,
        radius: 2.8,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: inletStart,
        b: solenoidAt,
        progress: t,
        color: AppColors.gas,
        count: 4,
        radius: 2.6,
      );
    }

    // Emergency stop button on right wall
    final epoCentre = Offset(w * 0.94, h * 0.34);
    _drawEpo(canvas, epoCentre, latched: epoLatched);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(epoCentre.dx - 30, epoCentre.dy + 22),
      'EPO',
      fontSize: 10,
    );

    // CO/CH4 detector on ceiling
    final detCentre = Offset(w * 0.12, h * 0.04);
    _drawDetector(canvas, detCentre);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(detCentre.dx + 12, detCentre.dy + 2),
      'CO / CH4 detector',
      fontSize: 10,
    );

    // Interlock controller box (top-right)
    final ctrlRect = Rect.fromLTWH(w * 0.78, h * 0.04, w * 0.18, h * 0.18);
    _drawController(
      canvas,
      ctrlRect,
      extractOk: extractOn && ppsmade,
      airOk: makeupAir,
      gasOk: solenoidOpen && gpssOk,
      enabled: gasFlowing && !epoLatched,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ctrlRect.left, ctrlRect.top - 14),
      'Interlock controller',
      fontSize: 10,
    );

    // Step focus highlights (subtle)
    _drawStepFocus(canvas, size);
  }

  void _drawStepFocus(Canvas canvas, Size size) {
    Rect? focus;
    switch (step) {
      case 2:
        focus = Rect.fromCircle(
          center: Offset(size.width * 0.495, size.height * 0.13),
          radius: 32,
        );
        break;
      case 3:
        focus = Rect.fromLTWH(
            size.width * 0.005, size.height * 0.14, size.width * 0.13, 60);
        break;
      case 4:
        focus = Rect.fromLTWH(
            size.width * 0.24, size.height * 0.55, 60, 80);
        break;
      case 5:
        focus = Rect.fromLTWH(
            size.width * 0.14, size.height * 0.55, 60, 80);
        break;
      case 7:
        focus = Rect.fromCircle(
          center: Offset(size.width * 0.94, size.height * 0.34),
          radius: 32,
        );
        break;
      default:
        focus = null;
    }
    if (focus != null) {
      final p = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(focus, const Radius.circular(8)),
        p,
      );
    }
  }

  void _drawFan(Canvas canvas, Offset c, double t, {required bool running}) {
    canvas.drawCircle(
      c,
      14,
      Paint()..color = const Color(0xFFD7DBE0),
    );
    canvas.drawCircle(
      c,
      14,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final angle = running ? t * 6.283 * 2 : 0.0;
    for (int i = 0; i < 4; i++) {
      final a = angle + i * 1.5708;
      final p1 = Offset(c.dx, c.dy);
      final p2 = PipePainterHelpers.rotate(
        Offset(c.dx + 12, c.dy),
        c,
        a,
      );
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = running ? AppColors.primary : Colors.black45
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawPps(Canvas canvas, Offset c, {required bool made}) {
    final r = Rect.fromCenter(center: c, width: 28, height: 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()..color = made ? const Color(0xFFC8E6C9) : const Color(0xFFFFCDD2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    canvas.drawCircle(
      c,
      4,
      Paint()..color = made ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
    );
  }

  void _drawGpps(Canvas canvas, Offset at, {required bool ok}) {
    final body = Rect.fromCenter(center: at, width: 22, height: 28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(4)),
      Paint()..color = const Color(0xFFEDEFF3),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      Offset(at.dx, at.dy - 6),
      3,
      Paint()..color = ok ? const Color(0xFF2E7D32) : AppColors.accent,
    );
    canvas.drawCircle(
      Offset(at.dx, at.dy + 6),
      3,
      Paint()..color = const Color(0xFF607D8B),
    );
  }

  void _drawAppliance(Canvas canvas, Offset at, _ApplianceKind kind, bool on) {
    final base = Rect.fromCenter(center: at.translate(0, 18), width: 50, height: 26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(base, const Radius.circular(4)),
      Paint()..color = const Color(0xFFB0BEC5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(base, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // burner top — flame if on
    final flameY = base.top - 4;
    if (on) {
      for (int i = -1; i <= 1; i++) {
        final cx = base.center.dx + i * 12.0;
        final flicker = (1 + ((t * 6.283 + i) % 1.0)) * 1.5;
        final path = Path()
          ..moveTo(cx - 4, flameY)
          ..quadraticBezierTo(cx - 2, flameY - 8 - flicker, cx, flameY - 12 - flicker)
          ..quadraticBezierTo(cx + 2, flameY - 8 - flicker, cx + 4, flameY)
          ..close();
        canvas.drawPath(
          path,
          Paint()..color = AppColors.accent.withValues(alpha: 0.85),
        );
        canvas.drawPath(
          path,
          Paint()..color = AppColors.gas.withValues(alpha: 0.6),
        );
      }
    } else {
      for (int i = -1; i <= 1; i++) {
        final cx = base.center.dx + i * 12.0;
        canvas.drawCircle(
          Offset(cx, flameY),
          2.6,
          Paint()..color = Colors.black45,
        );
      }
    }
    // kind hint glyph
    final glyph = switch (kind) {
      _ApplianceKind.cooker => '||',
      _ApplianceKind.fryer => '~',
      _ApplianceKind.salamander => '=',
    };
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(base.left + 4, base.top + 4),
      glyph,
      fontSize: 10,
      background: Colors.white,
    );
  }

  void _drawEpo(Canvas canvas, Offset c, {required bool latched}) {
    canvas.drawCircle(
      c,
      18,
      Paint()..color = Colors.black87,
    );
    canvas.drawCircle(
      c,
      14,
      Paint()
        ..color = latched
            ? AppColors.accent.withValues(alpha: 0.95)
            : AppColors.accent,
    );
    canvas.drawCircle(
      c,
      14,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    if (latched) {
      canvas.drawCircle(
        c,
        22,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  void _drawDetector(Canvas canvas, Offset c) {
    canvas.drawCircle(
      c,
      9,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      c,
      9,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      c,
      4,
      Paint()..color = const Color(0xFF2E7D32),
    );
  }

  void _drawController(
    Canvas canvas,
    Rect rect, {
    required bool extractOk,
    required bool airOk,
    required bool gasOk,
    required bool enabled,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFECEFF1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final lineH = rect.height / 5;
    void led(double y, String label, bool on) {
      final dotC = Offset(rect.left + 12, rect.top + y);
      canvas.drawCircle(
        dotC,
        4.5,
        Paint()
          ..color = on ? const Color(0xFF2E7D32) : AppColors.accent,
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(rect.left + 22, rect.top + y - 7),
        label,
        fontSize: 10,
        background: Colors.white,
      );
    }

    led(lineH * 0.6, 'VENT ON', extractOk);
    led(lineH * 1.6, 'EXTRACT OK', extractOk);
    led(lineH * 2.6, 'AIR OK', airOk);
    led(lineH * 3.6, 'GAS OK', gasOk);
    led(lineH * 4.6, 'ENABLED', enabled);
  }

  void _drawArrow(Canvas canvas, Offset a, Offset b, Color colour) {
    final p = Paint()
      ..color = colour
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(a, b, p);
    final dir = b - a;
    final len = dir.distance;
    if (len == 0) return;
    final n = Offset(-dir.dy / len, dir.dx / len);
    final tip1 = b - dir * 0.3 + n * 4;
    final tip2 = b - dir * 0.3 - n * 4;
    canvas.drawLine(b, tip1, p);
    canvas.drawLine(b, tip2, p);
  }

  @override
  bool shouldRepaint(_CateringInterlockPainter o) => true;
}

enum _ApplianceKind { cooker, fryer, salamander }

class _Appliance {
  final double x;
  final String label;
  final _ApplianceKind kind;
  const _Appliance({
    required this.x,
    required this.label,
    required this.kind,
  });
}

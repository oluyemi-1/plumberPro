import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/paint_helpers.dart';
import '../widgets/sim_scaffold.dart';

/// Animated tour of seven typical backflow installations on a single wall:
/// outside tap with DCV, bath with AUK3, basin with AUK2, WC with AG,
/// hose union HA, washing machine with SCV, and a commercial RPZ.
class BackflowProtectionSimScreen extends StatefulWidget {
  const BackflowProtectionSimScreen({super.key});

  @override
  State<BackflowProtectionSimScreen> createState() =>
      _BackflowProtectionSimScreenState();
}

class _Installation {
  final String id;
  final String title;
  final String category;
  final String device;
  final String explanation;
  final bool airGap;
  const _Installation({
    required this.id,
    required this.title,
    required this.category,
    required this.device,
    required this.explanation,
    required this.airGap,
  });
}

const _installations = <_Installation>[
  _Installation(
    id: 'outside_tap',
    title: 'Outside tap',
    category: 'Cat 3',
    device: 'Double check valve (DCV)',
    explanation:
        'A garden hose can sit in a puddle of fertiliser run off, so a DCV in the rising main protects to Category 3.',
    airGap: false,
  ),
  _Installation(
    id: 'bath_tap',
    title: 'Bath tap',
    category: 'Cat 3',
    device: 'AUK3 air gap',
    explanation:
        'A bath is a Category 3 risk because of body contact. The AUK3 vertical gap above the rim is the protection.',
    airGap: true,
  ),
  _Installation(
    id: 'basin_tap',
    title: 'Wash basin tap',
    category: 'Cat 3',
    device: 'AUK2 air gap',
    explanation:
        'A basin spout sits a fixed distance above the rim. That AUK2 gap is the only thing keeping the supply clean.',
    airGap: true,
  ),
  _Installation(
    id: 'wc',
    title: 'WC cistern',
    category: 'Cat 5',
    device: 'AG / AUK1 air gap inside cistern',
    explanation:
        'WC water is Category 5. The float valve outlet sits above the cistern overflow — an AG / AUK1 air gap.',
    airGap: true,
  ),
  _Installation(
    id: 'hose_union',
    title: 'Garden hose union',
    category: 'Cat 3',
    device: 'HA hose union with built-in DCV',
    explanation:
        'The HA hose union tap has a DCV integrated into the body so a hose can never siphon back.',
    airGap: false,
  ),
  _Installation(
    id: 'washer',
    title: 'Washing machine',
    category: 'Cat 3',
    device: 'Single check valve + AUK2 standpipe',
    explanation:
        'Domestic washers rely on the integral SCV in the appliance plus the AUK2 gap at the standpipe rim.',
    airGap: false,
  ),
  _Installation(
    id: 'rpz',
    title: 'Commercial line — RPZ',
    category: 'Cat 4',
    device: 'Reduced Pressure Zone valve',
    explanation:
        'For Category 4 commercial outlets, an RPZ provides a verifiable barrier with a visible tundish discharge.',
    airGap: false,
  ),
];

class _BackflowProtectionSimScreenState
    extends State<BackflowProtectionSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  String _selectedId = _installations.first.id;
  bool _withoutProtection = false;
  bool _backPressureEvent = false;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  _Installation get _selected =>
      _installations.firstWhere((i) => i.id == _selectedId);

  void _triggerBackPressure() {
    setState(() => _backPressureEvent = true);
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) setState(() => _backPressureEvent = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Backflow protection',
      summary:
          'Tour seven everyday installations and see how each is protected. '
          'Trigger a back-pressure event to see what fails when the device is missing.',
      onStepChanged: (i) => setState(() => _step = i),
      steps: const [
        SimStep(
          title: 'Why we worry',
          narration:
              'Backflow can pull contaminated water back into the wholesome supply. '
              'Every fitting must be protected to its fluid category.',
        ),
        SimStep(
          title: 'Fluid category at the outlet',
          narration:
              'Pick an installation to see whether it is Category 3, 4 or 5 '
              'and the level of protection that demands.',
        ),
        SimStep(
          title: 'The device fitted',
          narration:
              'Each outlet uses a specific device — air gap, single or double '
              'check, hose union or RPZ. Read the panel for this fitting.',
        ),
        SimStep(
          title: 'Failure mechanisms',
          narration:
              'Back-pressure pushes contaminated water uphill. Back-siphonage '
              'sucks it back when mains pressure drops. Both must be defeated.',
        ),
        SimStep(
          title: 'Trigger a back-flow event',
          narration:
              'Press the button to simulate negative pressure on the mains. '
              'Toggle Without protection to see what happens with no device fitted.',
        ),
        SimStep(
          title: 'With device fitted — protection holds',
          narration:
              'A working device blocks the reverse path. Watch the arrow stop '
              'at the device and the supply stays clean.',
        ),
        SimStep(
          title: 'Test or inspection',
          narration:
              'RPZ valves are tested annually by an approved tester. '
              'DCVs and air gaps are visually inspected at every service.',
        ),
        SimStep(
          title: 'Where this goes wrong',
          narration:
              'No DCV on a garden tap. A flexible spray below sink rim losing '
              'AUK2. A commercial dishwasher straight off the mains.',
        ),
      ],
      controls: [
        SizedBox(
          width: 320,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final i in _installations)
                ChoiceChip(
                  label: Text(i.title, style: const TextStyle(fontSize: 12)),
                  selected: _selectedId == i.id,
                  onSelected: (_) => setState(() {
                    _selectedId = i.id;
                    _backPressureEvent = false;
                  }),
                ),
            ],
          ),
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Without protection',
              style: TextStyle(fontSize: 12)),
          Switch.adaptive(
            value: _withoutProtection,
            onChanged: (v) => setState(() => _withoutProtection = v),
          ),
        ]),
        ElevatedButton.icon(
          onPressed: _triggerBackPressure,
          icon: const Icon(Icons.bolt),
          label: const Text('Trigger back-pressure'),
        ),
      ],
      diagramBuilder: (context, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => CustomPaint(
                  painter: _BackflowWallPainter(
                    progress: _ctrl.value,
                    selectedId: _selectedId,
                    withoutProtection: _withoutProtection,
                    backPressureEvent: _backPressureEvent,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: _ExplanationBanner(
                installation: _selected,
                step: _step,
                withoutProtection: _withoutProtection,
                backPressureEvent: _backPressureEvent,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExplanationBanner extends StatelessWidget {
  final _Installation installation;
  final int step;
  final bool withoutProtection;
  final bool backPressureEvent;
  const _ExplanationBanner({
    required this.installation,
    required this.step,
    required this.withoutProtection,
    required this.backPressureEvent,
  });

  @override
  Widget build(BuildContext context) {
    final danger = backPressureEvent && withoutProtection;
    final colour = danger
        ? AppColors.hotWater
        : (backPressureEvent ? AppColors.primary : AppColors.cardBg);
    final fg = (danger || backPressureEvent) ? Colors.white : AppColors.text;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            danger
                ? Icons.warning_amber_rounded
                : (backPressureEvent ? Icons.shield : Icons.info_outline),
            color: fg,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${installation.title} — ${installation.category}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: fg,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  withoutProtection
                      ? 'Device removed — only the bare connection remains.'
                      : installation.device,
                  style: TextStyle(color: fg, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  danger
                      ? 'Back-flow occurring — contaminated water has reached the supply.'
                      : (backPressureEvent
                          ? 'Back-pressure event — protection is holding.'
                          : installation.explanation),
                  style: TextStyle(color: fg, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackflowWallPainter extends CustomPainter {
  final double progress;
  final String selectedId;
  final bool withoutProtection;
  final bool backPressureEvent;
  _BackflowWallPainter({
    required this.progress,
    required this.selectedId,
    required this.withoutProtection,
    required this.backPressureEvent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Wall background
    final wall = Paint()..color = const Color(0xFFEFE6D6);
    canvas.drawRect(Offset.zero & size, wall);
    // floor
    final floor = Paint()..color = const Color(0xFF7A6E5A);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.86, size.width, size.height * 0.14),
      floor,
    );

    // Rising main runs along the top
    final mainY = size.height * 0.18;
    final mainStart = Offset(size.width * 0.04, mainY);
    final mainEnd = Offset(size.width * 0.96, mainY);
    PipePainterHelpers.drawPipe(
      canvas,
      a: mainStart,
      b: mainEnd,
      color: AppColors.coldWater,
      width: 12,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(size.width * 0.02, mainY - 22),
      'Rising main (Cat 1)',
    );

    // Layout: 7 outlet columns
    final n = _installations.length;
    final colW = size.width / n;
    for (int i = 0; i < n; i++) {
      final inst = _installations[i];
      final cx = colW * (i + 0.5);
      final isSel = inst.id == selectedId;
      _drawInstallation(canvas, size, inst, cx, mainY, isSel);
    }
  }

  void _drawInstallation(Canvas canvas, Size size, _Installation inst,
      double cx, double mainY, bool selected) {
    final dim = !selected;
    final dropTop = Offset(cx, mainY);
    final dropBottom = Offset(cx, size.height * 0.6);
    final pipeColor = dim
        ? AppColors.coldWater.withValues(alpha: 0.28)
        : AppColors.coldWater;

    PipePainterHelpers.drawPipe(
      canvas,
      a: dropTop,
      b: dropBottom,
      color: pipeColor,
      width: 8,
      highlighted: selected && backPressureEvent && !withoutProtection,
    );
    PipePainterHelpers.drawJoint(canvas, dropTop);

    // Flow particles (forward) when selected and not in back-pressure
    if (selected && !backPressureEvent) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: dropTop,
        b: dropBottom,
        progress: progress,
        color: Colors.white,
        count: 4,
        radius: 2.6,
      );
    }

    // Device marker midway (or at top of fitting)
    final deviceY = size.height * 0.42;
    final devicePos = Offset(cx, deviceY);
    if (!withoutProtection || !selected) {
      _drawDevice(canvas, devicePos, inst, dim);
    } else {
      // missing device — red cross
      _drawMissingDevice(canvas, devicePos);
    }

    // Backflow arrow
    if (selected && backPressureEvent) {
      _drawBackflowArrow(
        canvas,
        from: dropBottom,
        to: dropTop,
        blocked: !withoutProtection,
        deviceY: deviceY,
      );
    }

    // Fitting glyph at bottom
    _drawFitting(canvas, size, inst, cx, dropBottom, dim);

    // Title label
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cx - 38, size.height * 0.02),
      inst.title,
      fontSize: 10,
      background: selected ? Colors.yellow.shade100 : Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cx - 22, size.height * 0.08),
      inst.category,
      fontSize: 10,
      background: _categoryColour(inst.category),
    );
  }

  Color _categoryColour(String c) {
    if (c.contains('5')) return Colors.red.shade100;
    if (c.contains('4')) return Colors.orange.shade100;
    if (c.contains('3')) return Colors.yellow.shade100;
    if (c.contains('2')) return Colors.lightGreen.shade100;
    return Colors.green.shade100;
  }

  void _drawDevice(
      Canvas canvas, Offset p, _Installation inst, bool dim) {
    final col = dim ? Colors.grey.shade400 : AppColors.brass;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    if (inst.airGap) {
      // air gap — show a dashed gap symbol
      final dashPaint = Paint()
        ..color = dim ? Colors.grey.shade400 : Colors.black87
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      for (double y = p.dy - 10; y < p.dy + 10; y += 4) {
        canvas.drawLine(
            Offset(p.dx - 10, y), Offset(p.dx + 10, y), dashPaint);
      }
      PipePainterHelpers.drawLabel(canvas, Offset(p.dx + 14, p.dy - 8),
          'AIR GAP',
          fontSize: 9,
          background: dim ? Colors.white70 : Colors.lightBlue.shade100);
    } else if (inst.id == 'rpz') {
      // RPZ — a wider body with relief tundish
      final rect = Rect.fromCenter(center: p, width: 36, height: 18);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()..color = col);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)), stroke);
      // tundish
      final tundishTop = Offset(p.dx + 24, p.dy);
      final tundishBot = Offset(p.dx + 24, p.dy + 22);
      canvas.drawLine(tundishTop, tundishBot,
          Paint()..color = AppColors.muted..strokeWidth = 2);
      PipePainterHelpers.drawLabel(canvas, Offset(p.dx + 30, p.dy + 6),
          'RPZ',
          fontSize: 9,
          background:
              dim ? Colors.white70 : Colors.orange.shade100);
    } else {
      // DCV / SCV body
      final rect = Rect.fromCenter(center: p, width: 28, height: 16);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()..color = col);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)), stroke);
      final isDouble = inst.id == 'outside_tap' || inst.id == 'hose_union';
      // arrow chevrons
      final ar = Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawLine(
          Offset(p.dx - 8, p.dy - 4), Offset(p.dx - 4, p.dy), ar);
      canvas.drawLine(
          Offset(p.dx - 4, p.dy), Offset(p.dx - 8, p.dy + 4), ar);
      if (isDouble) {
        canvas.drawLine(
            Offset(p.dx + 4, p.dy - 4), Offset(p.dx + 8, p.dy), ar);
        canvas.drawLine(
            Offset(p.dx + 8, p.dy), Offset(p.dx + 4, p.dy + 4), ar);
      }
      PipePainterHelpers.drawLabel(
          canvas, Offset(p.dx + 14, p.dy + 6), isDouble ? 'DCV' : 'SCV',
          fontSize: 9,
          background:
              dim ? Colors.white70 : Colors.lightGreen.shade100);
    }
  }

  void _drawMissingDevice(Canvas canvas, Offset p) {
    final paint = Paint()
      ..color = AppColors.hotWater
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(p.dx - 10, p.dy - 10), Offset(p.dx + 10, p.dy + 10), paint);
    canvas.drawLine(
        Offset(p.dx + 10, p.dy - 10), Offset(p.dx - 10, p.dy + 10), paint);
    PipePainterHelpers.drawLabel(canvas, Offset(p.dx + 14, p.dy - 8),
        'NO DEVICE',
        fontSize: 9, background: Colors.red.shade100);
  }

  void _drawFitting(Canvas canvas, Size size, _Installation inst,
      double cx, Offset top, bool dim) {
    final fill = dim ? Colors.grey.shade300 : AppColors.pipeMetal;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final paint = Paint()..color = fill;

    switch (inst.id) {
      case 'outside_tap':
      case 'hose_union':
        // Tap body protruding from wall
        final body = Rect.fromCenter(
            center: Offset(cx, top.dy + 14), width: 24, height: 20);
        canvas.drawRRect(
            RRect.fromRectAndRadius(body, const Radius.circular(4)), paint);
        canvas.drawRRect(
            RRect.fromRectAndRadius(body, const Radius.circular(4)), stroke);
        // spout
        canvas.drawLine(Offset(cx, top.dy + 20), Offset(cx, top.dy + 40),
            Paint()..color = fill..strokeWidth = 6..strokeCap = StrokeCap.round);
        canvas.drawCircle(
            Offset(cx, top.dy + 8), 5, Paint()..color = AppColors.copper);
        break;
      case 'bath_tap':
        // bath tub
        final tub = Rect.fromLTWH(cx - 30, size.height * 0.7, 60, 26);
        canvas.drawRRect(
            RRect.fromRectAndRadius(tub, const Radius.circular(8)),
            Paint()..color = Colors.white);
        canvas.drawRRect(
            RRect.fromRectAndRadius(tub, const Radius.circular(8)), stroke);
        // water
        canvas.drawRect(
            Rect.fromLTWH(cx - 26, size.height * 0.71, 52, 8),
            Paint()..color = AppColors.coldWater.withValues(alpha: 0.5));
        // spout
        canvas.drawLine(
            Offset(cx, top.dy), Offset(cx, size.height * 0.68),
            Paint()..color = fill..strokeWidth = 5..strokeCap = StrokeCap.round);
        break;
      case 'basin_tap':
        // basin
        final basin = Rect.fromLTWH(cx - 24, size.height * 0.7, 48, 20);
        canvas.drawArc(basin, 0, 3.14, false,
            Paint()..color = Colors.white..style = PaintingStyle.fill);
        canvas.drawArc(basin, 0, 3.14, false, stroke);
        // spout
        canvas.drawLine(
            Offset(cx, top.dy), Offset(cx, size.height * 0.69),
            Paint()..color = fill..strokeWidth = 5..strokeCap = StrokeCap.round);
        break;
      case 'wc':
        // cistern + bowl
        final cistern = Rect.fromLTWH(cx - 18, size.height * 0.62, 36, 22);
        canvas.drawRRect(
            RRect.fromRectAndRadius(cistern, const Radius.circular(3)),
            Paint()..color = Colors.white);
        canvas.drawRRect(
            RRect.fromRectAndRadius(cistern, const Radius.circular(3)), stroke);
        // inner water
        canvas.drawRect(
            Rect.fromLTWH(cx - 15, size.height * 0.7, 30, 10),
            Paint()..color = AppColors.coldWater.withValues(alpha: 0.5));
        // float valve drop into cistern (the AUK1 air gap above water)
        canvas.drawLine(Offset(cx + 8, size.height * 0.64),
            Offset(cx + 8, size.height * 0.68),
            Paint()..color = AppColors.copper..strokeWidth = 3);
        // bowl
        final bowl = Rect.fromLTWH(cx - 14, size.height * 0.84, 28, 12);
        canvas.drawArc(bowl, 0, 3.14, false,
            Paint()..color = Colors.white..style = PaintingStyle.fill);
        canvas.drawArc(bowl, 0, 3.14, false, stroke);
        break;
      case 'washer':
        // appliance box
        final box = Rect.fromLTWH(cx - 22, size.height * 0.68, 44, 28);
        canvas.drawRRect(
            RRect.fromRectAndRadius(box, const Radius.circular(4)), paint);
        canvas.drawRRect(
            RRect.fromRectAndRadius(box, const Radius.circular(4)), stroke);
        // drum
        canvas.drawCircle(Offset(cx, size.height * 0.82), 9,
            Paint()..color = Colors.white);
        canvas.drawCircle(Offset(cx, size.height * 0.82), 9, stroke);
        break;
      case 'rpz':
        // commercial line — pipe drops to a process vessel
        final box = Rect.fromLTWH(cx - 22, size.height * 0.68, 44, 28);
        canvas.drawRRect(
            RRect.fromRectAndRadius(box, const Radius.circular(3)),
            Paint()..color = AppColors.brass);
        canvas.drawRRect(
            RRect.fromRectAndRadius(box, const Radius.circular(3)), stroke);
        PipePainterHelpers.drawLabel(canvas,
            Offset(cx - 18, size.height * 0.78), 'PROCESS',
            fontSize: 8, background: Colors.white);
        break;
    }
  }

  void _drawBackflowArrow(Canvas canvas,
      {required Offset from,
      required Offset to,
      required bool blocked,
      required double deviceY}) {
    final col = blocked ? AppColors.primary : AppColors.hotWater;
    final paint = Paint()
      ..color = col
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final headPaint = Paint()..color = col;
    final endY = blocked ? deviceY + 14 : to.dy + 4;
    final start = Offset(from.dx + 6, from.dy);
    final end = Offset(from.dx + 6, endY);
    canvas.drawLine(start, end, paint);
    // arrow head
    final head = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - 5, end.dy + 8)
      ..lineTo(end.dx + 5, end.dy + 8)
      ..close();
    canvas.drawPath(head, headPaint);
    if (blocked) {
      // a "stop" bar across the device
      canvas.drawLine(
        Offset(from.dx - 10, deviceY + 2),
        Offset(from.dx + 18, deviceY + 2),
        Paint()
          ..color = AppColors.primary
          ..strokeWidth = 3,
      );
      PipePainterHelpers.drawLabel(canvas,
          Offset(from.dx + 12, deviceY + 14), 'BLOCKED',
          fontSize: 9, background: Colors.lightBlue.shade100);
    } else {
      PipePainterHelpers.drawLabel(canvas,
          Offset(from.dx + 12, from.dy - 22), 'BACKFLOW',
          fontSize: 9, background: Colors.red.shade100);
    }
  }

  @override
  bool shouldRepaint(covariant _BackflowWallPainter old) =>
      old.progress != progress ||
      old.selectedId != selectedId ||
      old.withoutProtection != withoutProtection ||
      old.backPressureEvent != backPressureEvent;
}

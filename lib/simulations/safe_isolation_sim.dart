import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/paint_helpers.dart';
import '../widgets/sim_scaffold.dart';

/// Interactive seven-step safe isolation procedure.
class SafeIsolationSimScreen extends StatefulWidget {
  const SafeIsolationSimScreen({super.key});

  @override
  State<SafeIsolationSimScreen> createState() => _SafeIsolationSimScreenState();
}

class _SafeIsolationSimScreenState extends State<SafeIsolationSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _breakerOff = false;
  bool _testerProven = false;
  bool _circuitDead = false;
  bool _testerProvenAgain = false;
  bool _lockOn = false;

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

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Safe isolation — interactive procedure',
      summary:
          'Walk through the seven recognised steps to prove a circuit dead before working on it. Each control mirrors the action you would take on site.',
      onStepChanged: (_) => setState(() {}),
      controls: [
        _ControlButton(
          label: _breakerOff ? 'Breaker OFF' : 'Switch breaker OFF',
          icon: Icons.power_settings_new,
          enabled: !_breakerOff,
          onPressed: () => setState(() => _breakerOff = true),
        ),
        _ControlButton(
          label: _testerProven ? 'Tester proven' : 'Prove tester (live source)',
          icon: Icons.electric_bolt,
          enabled: _breakerOff && !_testerProven,
          onPressed: () => setState(() => _testerProven = true),
        ),
        _ControlButton(
          label: _circuitDead ? 'Confirmed dead' : 'Test L–N, L–E, N–E',
          icon: Icons.verified,
          enabled: _testerProven && !_circuitDead,
          onPressed: () => setState(() => _circuitDead = true),
        ),
        _ControlButton(
          label: _testerProvenAgain ? 'Tester re-proven' : 'Re-prove tester',
          icon: Icons.replay,
          enabled: _circuitDead && !_testerProvenAgain,
          onPressed: () => setState(() => _testerProvenAgain = true),
        ),
        _ControlButton(
          label: _lockOn ? 'Locked off' : 'Lock off + tag',
          icon: Icons.lock,
          enabled: _testerProvenAgain && !_lockOn,
          onPressed: () => setState(() => _lockOn = true),
        ),
        _ControlButton(
          label: 'Reset procedure',
          icon: Icons.restart_alt,
          enabled: true,
          onPressed: () => setState(() {
            _breakerOff = false;
            _testerProven = false;
            _circuitDead = false;
            _testerProvenAgain = false;
            _lockOn = false;
          }),
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _SafeIsoPainter(
            step: i,
            t: _ctrl.value,
            breakerOff: _breakerOff,
            testerProven: _testerProven,
            circuitDead: _circuitDead,
            testerProvenAgain: _testerProvenAgain,
            lockOn: _lockOn,
          ),
          size: Size.infinite,
        ),
      ),
      steps: const [
        SimStep(
          title: 'Step 1 — Identify the supply',
          narration:
              'Locate the consumer unit and identify the correct circuit by labelling. Check with the customer or building owner that the circuit you have identified is the one you intend to isolate.',
        ),
        SimStep(
          title: 'Step 2 — Notify occupants',
          narration:
              'Tell anyone in the building that power will be off, and for how long. Make sure no critical equipment depends on the circuit you are about to switch off.',
        ),
        SimStep(
          title: 'Step 3 — Switch off',
          narration:
              'Operate the protective device — the MCB, RCBO or fused isolator — and confirm it has switched. Use the on-screen control to switch the breaker off in this simulation.',
        ),
        SimStep(
          title: 'Step 4 — Prove the tester on a known live source',
          narration:
              'Before you trust the tester, prove it on a voltage proving unit or another known live source. This confirms the tester itself is working before you rely on it.',
        ),
        SimStep(
          title: 'Step 5 — Test the circuit dead',
          narration:
              'At the point of isolation, test all combinations: line to neutral, line to earth, and neutral to earth. All three readings must show zero volts.',
        ),
        SimStep(
          title: 'Step 6 — Re-prove the tester',
          narration:
              'Return to the same known live source and prove the tester again. This confirms the tester has not failed during the test, which would have given a false dead reading.',
        ),
        SimStep(
          title: 'Step 7 — Lock off and tag',
          narration:
              'Fit a personal padlock to the breaker and attach a warning tag with your name, the date and the time. Only you remove the lock when work is complete.',
        ),
        SimStep(
          title: 'After the work',
          narration:
              'Once the work is complete, restore covers, remove your padlock and tag, switch the breaker back on, retest where required, and demonstrate operation to the customer. Issue a minor works certificate if applicable.',
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  const _ControlButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          backgroundColor: enabled ? AppColors.primary : Colors.grey.shade300,
          foregroundColor: enabled ? Colors.white : Colors.black54,
        ),
      ),
    );
  }
}

class _SafeIsoPainter extends CustomPainter {
  final int step;
  final double t;
  final bool breakerOff;
  final bool testerProven;
  final bool circuitDead;
  final bool testerProvenAgain;
  final bool lockOn;
  _SafeIsoPainter({
    required this.step,
    required this.t,
    required this.breakerOff,
    required this.testerProven,
    required this.circuitDead,
    required this.testerProvenAgain,
    required this.lockOn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background panels — wall behind consumer unit, immersion heater on right.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFEFF2F6),
    );

    // ── Consumer unit ──────────────────────────────────────────────────
    final cuRect = Rect.fromLTWH(w * 0.04, h * 0.12, w * 0.46, h * 0.55);
    final cuBody = Paint()..color = const Color(0xFFF7F7F2);
    final cuStroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cuRect, const Radius.circular(8)),
      cuBody,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cuRect, const Radius.circular(8)),
      cuStroke,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cuRect.left, cuRect.top - 22),
      'Consumer unit',
      fontSize: 13,
    );

    // Main switch
    final mainSw = Rect.fromLTWH(
      cuRect.left + 10,
      cuRect.top + 10,
      cuRect.width * 0.18,
      30,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mainSw, const Radius.circular(4)),
      Paint()..color = Colors.red.shade600,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(mainSw.left, mainSw.bottom + 4),
      'Main switch',
      fontSize: 10,
    );

    // Breakers row
    final breakerCount = 6;
    final breakerW = (cuRect.width - 20) / breakerCount;
    for (int i = 0; i < breakerCount; i++) {
      final isImmersion = i == 3;
      final r = Rect.fromLTWH(
        cuRect.left + 10 + i * breakerW,
        cuRect.top + 60,
        breakerW - 4,
        80,
      );
      // body
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)),
        Paint()..color = const Color(0xFFE6E6DC),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)),
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      // toggle
      final togglePos = (isImmersion && breakerOff) ? r.bottom - 16 : r.top + 8;
      canvas.drawRect(
        Rect.fromLTWH(r.left + (r.width - 8) / 2, togglePos, 8, 16),
        Paint()
          ..color = (isImmersion && breakerOff)
              ? Colors.green.shade700
              : Colors.red.shade400,
      );
      // padlock for immersion
      if (isImmersion && lockOn) {
        final lockCenter = Offset(r.center.dx, r.bottom + 18);
        canvas.drawCircle(
          lockCenter,
          10,
          Paint()..color = Colors.amber.shade700,
        );
        canvas.drawArc(
          Rect.fromCircle(center: Offset(lockCenter.dx, lockCenter.dy - 6), radius: 7),
          3.14,
          3.14,
          false,
          Paint()
            ..color = Colors.black87
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      }
      if (isImmersion) {
        PipePainterHelpers.drawLabel(
          canvas,
          Offset(r.left - 4, r.top - 22),
          'Immersion 16 A',
          fontSize: 9,
          background: AppColors.gas.withValues(alpha: 0.18),
        );
      }
    }

    // Status banner inside consumer unit
    final statusY = cuRect.bottom - 70;
    final statusColor = !breakerOff
        ? Colors.red
        : !testerProven
            ? Colors.orange
            : !circuitDead
                ? Colors.amber.shade800
                : !testerProvenAgain
                    ? Colors.lightGreen
                    : !lockOn
                        ? Colors.green.shade700
                        : Colors.green.shade900;
    final statusText = !breakerOff
        ? 'CIRCUIT LIVE — DO NOT TOUCH'
        : !testerProven
            ? 'BREAKER OFF — Prove tester first'
            : !circuitDead
                ? 'TEST L–N, L–E, N–E now'
                : !testerProvenAgain
                    ? 'Re-prove the tester'
                    : !lockOn
                        ? 'Lock off and tag'
                        : 'SAFE — proceed with the work';
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cuRect.left + 10, statusY, cuRect.width - 20, 40),
        const Radius.circular(6),
      ),
      Paint()..color = statusColor.withValues(alpha: 0.18),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cuRect.left + 16, statusY + 12),
      statusText,
      fontSize: 12,
      textColor: statusColor,
      background: Colors.white.withValues(alpha: 0.9),
    );

    // Tester device (right side, top)
    final testerRect = Rect.fromLTWH(w * 0.55, h * 0.10, w * 0.36, h * 0.30);
    canvas.drawRRect(
      RRect.fromRectAndRadius(testerRect, const Radius.circular(10)),
      Paint()..color = const Color(0xFFFFE066),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(testerRect, const Radius.circular(10)),
      cuStroke,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(testerRect.left, testerRect.top - 18),
      'Two-pole voltage indicator',
      fontSize: 12,
    );
    // Display
    final disp = Rect.fromLTWH(
      testerRect.left + 16,
      testerRect.top + 16,
      testerRect.width - 32,
      36,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(disp, const Radius.circular(4)),
      Paint()..color = Colors.black,
    );
    String dispText;
    Color dispColor;
    if (!breakerOff) {
      dispText = '230 V LIVE';
      dispColor = Colors.red;
    } else if (!testerProven) {
      dispText = 'Prove on live source';
      dispColor = Colors.orange;
    } else if (!circuitDead) {
      dispText = 'Test now';
      dispColor = Colors.amber;
    } else if (!testerProvenAgain) {
      dispText = '0.0 V — re-prove';
      dispColor = Colors.lightGreenAccent;
    } else {
      dispText = '0.0 V CONFIRMED';
      dispColor = Colors.greenAccent;
    }
    final tp = TextPainter(
      text: TextSpan(
        text: dispText,
        style: TextStyle(
          color: dispColor,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(disp.center.dx - tp.width / 2, disp.center.dy - tp.height / 2),
    );

    // Test leads
    final leadStart = Offset(testerRect.left + 30, testerRect.bottom - 8);
    final leadStart2 = Offset(testerRect.right - 30, testerRect.bottom - 8);
    final probeEnd = Offset(testerRect.left + 60, testerRect.bottom + 50);
    final probeEnd2 = Offset(testerRect.right - 60, testerRect.bottom + 50);
    final leadPaint = Paint()
      ..color = Colors.brown.shade600
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final leadPaint2 = Paint()
      ..color = Colors.blue.shade700
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(leadStart, probeEnd, leadPaint);
    canvas.drawLine(leadStart2, probeEnd2, leadPaint2);
    // Probe tips
    canvas.drawCircle(probeEnd, 4, Paint()..color = Colors.black87);
    canvas.drawCircle(probeEnd2, 4, Paint()..color = Colors.black87);

    // Live source proving unit (bottom right)
    final pvRect = Rect.fromLTWH(w * 0.62, h * 0.55, w * 0.28, h * 0.20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(pvRect, const Radius.circular(10)),
      Paint()..color = const Color(0xFFD9F2FF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pvRect, const Radius.circular(10)),
      cuStroke,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pvRect.left, pvRect.top - 18),
      'Voltage proving unit',
      fontSize: 12,
      background: AppColors.coldWater.withValues(alpha: 0.18),
    );
    // Indicator on proving unit
    final pvLight = Offset(pvRect.center.dx, pvRect.center.dy);
    final pvActive = (testerProven && !circuitDead) ||
        (testerProvenAgain && circuitDead);
    canvas.drawCircle(
      pvLight,
      14,
      Paint()
        ..color = pvActive
            ? Colors.greenAccent.shade400
            : Colors.grey.shade400,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pvRect.left + 6, pvRect.bottom - 24),
      pvActive ? 'PROVEN' : 'Press to prove',
      fontSize: 11,
    );

    // Step pointer arrow — animated when not yet done
    final hintColor = AppColors.accent;
    String hint;
    Offset hintPoint;
    if (!breakerOff) {
      hint = 'Switch off the breaker';
      final r3 = Rect.fromLTWH(
        cuRect.left + 10 + 3 * breakerW,
        cuRect.top + 60,
        breakerW - 4,
        80,
      );
      hintPoint = r3.center;
    } else if (!testerProven) {
      hint = 'Prove the tester here';
      hintPoint = pvLight;
    } else if (!circuitDead) {
      hint = 'Test the circuit dead';
      hintPoint = Offset(probeEnd.dx + 10, probeEnd.dy + 20);
    } else if (!testerProvenAgain) {
      hint = 'Re-prove the tester';
      hintPoint = pvLight;
    } else if (!lockOn) {
      hint = 'Apply your padlock';
      final r3 = Rect.fromLTWH(
        cuRect.left + 10 + 3 * breakerW,
        cuRect.top + 60,
        breakerW - 4,
        80,
      );
      hintPoint = Offset(r3.center.dx, r3.bottom + 18);
    } else {
      hint = 'You may safely begin work';
      hintPoint = Offset(w * 0.5, h * 0.92);
    }
    final pulse = (1 + math.cos(t * 6.28)) / 2; // 0..1
    canvas.drawCircle(
      hintPoint,
      18 + pulse * 8,
      Paint()
        ..color = hintColor.withValues(alpha: 0.30 - pulse * 0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(8, h - 24),
      hint,
      background: hintColor.withValues(alpha: 0.18),
      textColor: hintColor,
      fontSize: 13,
    );

    // Step counter top-right
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w - 80, 8),
      'Step ${step + 1} of 8',
      fontSize: 11,
      background: Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _SafeIsoPainter old) =>
      old.step != step ||
      old.t != t ||
      old.breakerOff != breakerOff ||
      old.testerProven != testerProven ||
      old.circuitDead != circuitDead ||
      old.testerProvenAgain != testerProvenAgain ||
      old.lockOn != lockOn;
}


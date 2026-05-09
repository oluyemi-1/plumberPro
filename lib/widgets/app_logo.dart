import 'package:flutter/material.dart';

import '../theme.dart';

/// Programmatic PipeSmart logo.
///
/// Draws a stylised tap + droplet inside a rounded square with a navy → deep
/// blue gradient. Scales to any size — used on the splash screen, the About
/// screen and anywhere we want to show the brand mark without an asset file.
class AppLogo extends StatelessWidget {
  final double size;
  final BorderRadius? borderRadius;
  const AppLogo({super.key, this.size = 96, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(size * 0.22),
        child: CustomPaint(
          painter: _LogoPainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Rounded background gradient.
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    // Soft radial highlight in the upper-left.
    final highlight = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(w * 0.35, h * 0.30),
        radius: w * 0.55,
      ));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), highlight);

    // Tap body (silver) — vertical pillar centred in the canvas.
    final tapBody = Paint()..color = const Color(0xFFD8DEE7);
    final tapShadow = Paint()..color = const Color(0xFF8A95A4);

    // Tap pillar
    final pillarRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.50),
      width: w * 0.18,
      height: h * 0.42,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillarRect, Radius.circular(w * 0.04)),
      tapBody,
    );
    // Pillar shadow on the right side
    final shadowRect = Rect.fromLTWH(
      pillarRect.right - w * 0.05,
      pillarRect.top,
      w * 0.05,
      pillarRect.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, Radius.circular(w * 0.04)),
      tapShadow..color = tapShadow.color.withValues(alpha: 0.35),
    );

    // Tap top — handle / wheel
    final handleRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.27),
      width: w * 0.36,
      height: h * 0.10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, Radius.circular(w * 0.04)),
      tapBody,
    );
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.27),
      w * 0.04,
      Paint()..color = const Color(0xFF6F7A8A),
    );

    // Tap spout — angled rectangle protruding to the left.
    final spoutPath = Path();
    final spoutWidth = w * 0.40;
    final spoutThickness = h * 0.08;
    final spoutY = h * 0.55;
    spoutPath.moveTo(w * 0.50, spoutY);
    spoutPath.lineTo(w * 0.50, spoutY + spoutThickness);
    spoutPath.lineTo(w * 0.50 - spoutWidth, spoutY + spoutThickness * 1.1);
    spoutPath.lineTo(w * 0.50 - spoutWidth, spoutY - spoutThickness * 0.1);
    spoutPath.close();
    canvas.drawPath(spoutPath, tapBody);

    // Spout end nozzle
    final nozzleRect = Rect.fromCenter(
      center: Offset(w * 0.10, spoutY + spoutThickness / 2),
      width: w * 0.08,
      height: spoutThickness * 1.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(nozzleRect, Radius.circular(w * 0.02)),
      tapBody,
    );

    // Big water droplet falling from the nozzle.
    final dropletCenter = Offset(w * 0.10, h * 0.78);
    final dropletPath = Path()
      ..moveTo(dropletCenter.dx, dropletCenter.dy - h * 0.10)
      ..cubicTo(
        dropletCenter.dx + w * 0.10,
        dropletCenter.dy - h * 0.04,
        dropletCenter.dx + w * 0.08,
        dropletCenter.dy + h * 0.06,
        dropletCenter.dx,
        dropletCenter.dy + h * 0.06,
      )
      ..cubicTo(
        dropletCenter.dx - w * 0.08,
        dropletCenter.dy + h * 0.06,
        dropletCenter.dx - w * 0.10,
        dropletCenter.dy - h * 0.04,
        dropletCenter.dx,
        dropletCenter.dy - h * 0.10,
      )
      ..close();
    canvas.drawPath(
      dropletPath,
      Paint()..color = AppColors.coldWater,
    );
    // Droplet highlight
    canvas.drawCircle(
      Offset(dropletCenter.dx - w * 0.025, dropletCenter.dy - h * 0.02),
      w * 0.020,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );

    // Small accent droplets to give a brand "spark".
    final spark = Paint()..color = AppColors.coldWater.withValues(alpha: 0.65);
    canvas.drawCircle(Offset(w * 0.12, h * 0.92), w * 0.018, spark);
    canvas.drawCircle(Offset(w * 0.04, h * 0.86), w * 0.012, spark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Convenience widget for screens that want to show the wordmark next to the
/// logo — used by the splash and About screens.
class AppLogoWordmark extends StatelessWidget {
  final double logoSize;
  final TextStyle? titleStyle;
  final bool inverse;
  const AppLogoWordmark({
    super.key,
    this.logoSize = 96,
    this.titleStyle,
    this.inverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = inverse ? Colors.white : AppColors.text;
    final secondary =
        inverse ? Colors.white.withValues(alpha: 0.75) : AppColors.muted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: logoSize),
        SizedBox(height: logoSize * 0.18),
        Text(
          'PipeSmart',
          style: titleStyle ??
              TextStyle(
                fontSize: logoSize * 0.32,
                fontWeight: FontWeight.w800,
                color: fg,
                letterSpacing: -0.3,
              ),
        ),
        SizedBox(height: logoSize * 0.04),
        Text(
          'Practical UK plumbing training',
          style: TextStyle(
            fontSize: logoSize * 0.13,
            color: secondary,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}


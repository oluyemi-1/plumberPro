import 'package:flutter/material.dart';

/// Centres a child in the available width and constrains it to a sensible
/// maximum so content doesn't stretch absurdly wide on tablets or desktop.
///
/// Use this anywhere a screen would otherwise show a single-column ListView
/// at full screen width. Reading widths above ~720 px are uncomfortable.
class MaxContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final Alignment alignment;

  const MaxContentWidth({
    super.key,
    required this.child,
    this.maxWidth = 760,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding == null
            ? child
            : Padding(padding: padding!, child: child),
      ),
    );
  }
}

/// Returns a responsive grid cross-axis count based on the available width:
///   < 560 px → 1 column
///   < 900 px → 2 columns
///   < 1300 px → 3 columns
///   ≥ 1300 px → 4 columns
int responsiveGridCount(double width) {
  if (width < 560) return 1;
  if (width < 900) return 2;
  if (width < 1300) return 3;
  return 4;
}

/// True for tablet-and-larger widths.
bool isWide(BuildContext context) =>
    MediaQuery.of(context).size.width >= 720;

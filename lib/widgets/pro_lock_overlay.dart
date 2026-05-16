import 'package:flutter/material.dart';

import '../screens/paywall_screen.dart';
import '../theme.dart';

/// Wraps a card-style item to indicate it requires PipeSmart Pro.
///
/// When [locked] is true, the underlying [child] is dimmed and a "Pro"
/// pill is overlaid in the top-right corner. Any tap on the wrapper
/// opens the paywall instead of bubbling to the child's own onTap.
class ProLockOverlay extends StatelessWidget {
  final Widget child;
  final bool locked;

  const ProLockOverlay({
    super.key,
    required this.child,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    return Stack(
      children: [
        IgnorePointer(
          ignoring: true,
          child: Opacity(opacity: 0.55, child: child),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => PaywallScreen.show(context),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: _ProPill(),
        ),
      ],
    );
  }
}

class _ProPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.lock_rounded, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

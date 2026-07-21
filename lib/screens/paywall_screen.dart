import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../services/iap_service.dart';
import '../services/redemption_service.dart';
import '../theme.dart';
import 'legal_screen.dart';

/// PipeSmart Pro upsell screen shown when a user taps a locked feature.
///
/// Native auto-renewing subscriptions ([IapService], via the App Store /
/// Play Store) are the primary channel on every platform.
///
/// On Android we additionally offer the redemption-code box and a bulk-licence
/// contact card for institutional / direct-sale licences. Both are hidden on
/// iOS: App Store Review Guideline 3.1.1 forbids unlocking paid digital content
/// through any mechanism other than In-App Purchase, and even a "contact us for
/// a plan" card counts as out-of-store purchase steering.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  static const _teamEmail = 'info@karitec.co.uk';

  static Future<void> show(BuildContext context) {
    // Make sure products are loaded when the paywall opens.
    IapService.instance.refreshProducts();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PaywallScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Non-IAP channels (code redemption, bulk-licence contact) are Android-only;
    // see the class doc for the App Store 3.1.1 rationale.
    final showNonIapChannels = !Platform.isIOS;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PipeSmart Pro'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Header(showRedeemHint: showNonIapChannels),
          const SizedBox(height: 18),
          _FeatureList(),
          const SizedBox(height: 20),
          _PlansSection(showRedeemHint: showNonIapChannels),
          if (showNonIapChannels) ...[
            const SizedBox(height: 14),
            _RedeemCodeCard(),
            const SizedBox(height: 14),
            _TeamLicenceCard(email: _teamEmail),
          ],
          const SizedBox(height: 18),
          _LegalFooter(),
        ],
      ),
    );
  }
}

/// Native subscription plans, driven by [IapService]. Shows store-localized
/// prices and the auto-renew disclosure Apple requires near the buy button.
class _PlansSection extends StatelessWidget {
  /// Whether to mention the activation-code fallback in the empty state.
  /// Android only — see [PaywallScreen] doc.
  final bool showRedeemHint;
  const _PlansSection({required this.showRedeemHint});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: IapService.instance,
      builder: (context, _) {
        final iap = IapService.instance;

        if (!iap.available) {
          // Store unreachable (e.g. simulator, or not signed in). Hide the
          // plans entirely rather than show a broken buy button. On Android the
          // redemption-code box below still provides a way in.
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Choose a plan',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Subscriptions are billed through your App Store / Google Play account.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                if (iap.loading && iap.products.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (iap.products.isEmpty)
                  // Never surface a raw StoreKit / Billing error to users —
                  // show a calm, neutral message. (On the iOS Simulator the
                  // store is unreachable, so this is what shows there.)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      showRedeemHint
                          ? 'Subscription plans load when you\'re signed in to '
                              'the App Store / Google Play. You can also redeem '
                              'an activation code below.'
                          : 'Subscription plans load when you\'re signed in to '
                              'the App Store.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
                  for (final product in iap.products)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PlanRow(product: product),
                    ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.restore_rounded, size: 18),
                  label: const Text('Restore purchases'),
                  onPressed: () async {
                    await iap.restore();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Checking your account for active subscriptions…'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 20),
                Text(
                  'Subscriptions renew automatically unless cancelled at least '
                  '24 hours before the end of the current period. Your account '
                  'is charged for renewal within 24 hours before the period '
                  'ends. Manage or cancel anytime in your App Store / Google '
                  'Play account settings.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlanRow extends StatelessWidget {
  final ProductDetails product;
  const _PlanRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final plan = IapService.instance.planForProduct(product.id);
    final label = plan?.label ?? product.title;
    final isYear = plan?.months == 12;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: isYear ? 0.8 : 0.3),
          width: isYear ? 2 : 1,
        ),
      ),
      onPressed: () => IapService.instance.buy(product),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (isYear) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'BEST VALUE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            product.price,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  /// Android only: mention the activation-code option in the intro copy.
  final bool showRedeemHint;
  const _Header({required this.showRedeemHint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 32),
              SizedBox(width: 10),
              Text(
                'Unlock the full toolkit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            showRedeemHint
                ? 'PipeSmart Pro unlocks every lesson, quiz, simulator, troubleshooter and job scenario. Subscribe below, or redeem an activation code from your college, employer or training provider.'
                : 'PipeSmart Pro unlocks every lesson, quiz, simulator, troubleshooter and job scenario. Subscribe below to get full access.',
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  static const _items = [
    ('All practical simulations', Icons.precision_manufacturing_rounded),
    ('Every lesson and theory module', Icons.menu_book_rounded),
    ('Full quiz library + practice mode', Icons.quiz_rounded),
    ('Every troubleshooter scenario', Icons.build_circle_rounded),
    ('All job scenarios with feedback', Icons.work_history_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
        child: Column(
          children: [
            for (final (label, icon) in _items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const Icon(Icons.check_rounded,
                        color: Colors.green, size: 20),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RedeemCodeCard extends StatefulWidget {
  @override
  State<_RedeemCodeCard> createState() => _RedeemCodeCardState();
}

class _RedeemCodeCardState extends State<_RedeemCodeCard> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _expiryLabel(DateTime when) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${when.day} ${months[when.month - 1]} ${when.year}';
  }

  Future<void> _redeem() async {
    final raw = _controller.text;
    if (raw.trim().isEmpty) return;
    setState(() => _busy = true);
    final result = await RedemptionService.instance.redeem(raw);
    if (!mounted) return;
    setState(() => _busy = false);
    final messenger = ScaffoldMessenger.of(context);
    switch (result.status) {
      case RedemptionService.resultOk:
        final msg = result.expiresAt == null
            ? 'Code accepted — PipeSmart Pro unlocked for life.'
            : 'Code accepted — Pro active until ${_expiryLabel(result.expiresAt!)}.';
        messenger.showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
        );
        Navigator.of(context).pop();
        return;
      case RedemptionService.resultMalformed:
        messenger.showSnackBar(const SnackBar(
            content: Text('Code format looks wrong. Check for typos.')));
        return;
      case RedemptionService.resultAlreadyRedeemed:
        messenger.showSnackBar(const SnackBar(
            content:
                Text('This code has already been redeemed on this device.')));
        return;
      default:
        messenger.showSnackBar(const SnackBar(
            content: Text('That code is not valid.')));
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.confirmation_number_rounded,
                    color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Have a redemption code?',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Codes provided by your college, training provider, or employer unlock the full Pro library on this device.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_busy,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'PSMART-XXXX-XXXX-XXXX-XXXX',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _redeem(),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: _busy ? null : _redeem,
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Redeem'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamLicenceCard extends StatelessWidget {
  final String email;
  const _TeamLicenceCard({required this.email});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.accent.withValues(alpha: 0.07),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.groups_rounded, color: AppColors.accent),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'For schools, training providers & organisations',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'We offer bulk licences for colleges, plumbing-and-heating training providers, and businesses kitting out their engineers. Get in touch and we will tailor a plan to your team size.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    email,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy email'),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: email));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copied to clipboard.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Functional links to the Terms of Use (EULA) and Privacy Policy, required on
/// the paywall by App Store Review Guideline 3.1.2(c) for auto-renewing
/// subscriptions. Both open the in-app [LegalScreen], which holds the full text.
class _LegalFooter extends StatelessWidget {
  void _openLegal(BuildContext context, int tab) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LegalScreen(initialTab: tab)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      fontSize: 12,
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            GestureDetector(
              onTap: () => _openLegal(context, 1),
              child: Text('Terms of Use (EULA)', style: linkStyle),
            ),
            Text('·', style: TextStyle(color: AppColors.muted, fontSize: 12)),
            GestureDetector(
              onTap: () => _openLegal(context, 0),
              child: Text('Privacy Policy', style: linkStyle),
            ),
          ],
        ),
      ],
    );
  }
}

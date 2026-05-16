import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/redemption_service.dart';
import '../theme.dart';

/// PipeSmart Pro upsell screen shown when a user taps a locked feature.
///
/// The "Unlock Pro" button is a stub until real in-app purchases land —
/// for now it shows a "Coming soon" message. Pro entitlement can be
/// flipped manually for testing via the dev toggle in Settings.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  static const _teamEmail = 'info@karitec.co.uk';

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PaywallScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          _Header(),
          const SizedBox(height: 18),
          _FeatureList(),
          const SizedBox(height: 20),
          _RedeemCodeCard(),
          const SizedBox(height: 14),
          _TeamLicenceCard(email: _teamEmail),
          const SizedBox(height: 18),
          _LegalFooter(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
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
          const Text(
            "PipeSmart Pro unlocks every lesson, quiz, simulator, troubleshooter and job scenario. It is currently available via institutional licence or activation code — individual subscriptions are coming in a future update.",
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
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

class _LegalFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'Terms of Use and Privacy Policy are available on the support website (karitec.co.uk).',
        style: TextStyle(
          fontSize: 11,
          color: AppColors.muted,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../data/user_role_data.dart';
import '../services/tts_service.dart';
import '../services/user_profile_service.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'legal_screen.dart';

/// Multi-page first-run experience that captures the user's role and goals
/// and routes them to the home screen with their primary hub featured.
class OnboardingScreen extends StatefulWidget {
  /// When [popOnFinish] is true, pops back to the previous route instead of
  /// replacing with the home screen. Used when re-entering from Settings.
  final bool popOnFinish;
  const OnboardingScreen({super.key, this.popOnFinish = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  final _nameCtrl = TextEditingController();
  int _page = 0;

  UserRole? _selectedRole;
  final Set<String> _selectedGoals = <String>{};

  @override
  void initState() {
    super.initState();
    final svc = UserProfileService.instance;
    _selectedRole = svc.role;
    _selectedGoals.addAll(svc.goals);
    _nameCtrl.text = svc.displayName;
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 3) {
      setState(() => _page += 1);
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) {
      setState(() => _page -= 1);
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    final svc = UserProfileService.instance;
    if (_selectedRole != null) {
      await svc.saveRole(_selectedRole!);
    }
    await svc.saveGoals(_selectedGoals);
    await svc.saveDisplayName(_nameCtrl.text);
    await svc.markOnboarded();
    if (!mounted) return;
    if (widget.popOnFinish) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _skip() async {
    final svc = UserProfileService.instance;
    await svc.markOnboarded();
    if (!mounted) return;
    if (widget.popOnFinish) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAdvance = switch (_page) {
      0 => true,
      1 => _selectedRole != null,
      2 => true,
      _ => true,
    };
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _StepIndicator(current: _page, total: 4),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _Welcome(nameCtrl: _nameCtrl),
                  _RolePicker(
                    selected: _selectedRole,
                    onSelect: (r) => setState(() => _selectedRole = r),
                  ),
                  _GoalsPicker(
                    selected: _selectedGoals,
                    onToggle: (g) {
                      setState(() {
                        if (_selectedGoals.contains(g)) {
                          _selectedGoals.remove(g);
                        } else {
                          _selectedGoals.add(g);
                        }
                      });
                    },
                  ),
                  _Done(role: _selectedRole),
                ],
              ),
            ),
            _Nav(
              page: _page,
              canAdvance: canAdvance,
              onBack: _back,
              onNext: _next,
              onSkip: _skip,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= current;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.black12,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  final int page;
  final bool canAdvance;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  const _Nav({
    required this.page,
    required this.canAdvance,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          if (page > 0)
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            )
          else
            TextButton(onPressed: onSkip, child: const Text('Skip')),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: canAdvance ? onNext : null,
            icon: Icon(page == 3 ? Icons.check : Icons.arrow_forward),
            label: Text(page == 3 ? 'Get started' : 'Next'),
          ),
        ],
      ),
    );
  }
}

// ─── Page 0 ─ Welcome ──────────────────────────────────────────────────

class _Welcome extends StatelessWidget {
  final TextEditingController nameCtrl;
  const _Welcome({required this.nameCtrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.plumbing,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(
            'Welcome to PipeSmart',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Practical training for UK plumbers — from apprentice through to specialist. Animated simulations, narrated lessons and field-ready calculators.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Text('What should we call you?',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Your name (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => TtsService.instance.speak(
              'Welcome to PipeSmart, your practical training companion. I will guide you through every simulation, lesson and calculator.',
            ),
            icon: const Icon(Icons.record_voice_over),
            label: const Text('Hear the welcome'),
          ),
          const Spacer(),
          Text(
            'On the next screens we will ask which kind of plumbing you do, and what you are working toward, so we can pin the most relevant tools to your home screen.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─── Page 1 ─ Role picker ─────────────────────────────────────────────

class _RolePicker extends StatelessWidget {
  final UserRole? selected;
  final ValueChanged<UserRole> onSelect;
  const _RolePicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'What kind of plumber are you?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Pick the option that fits best — you can change this later in settings.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: UserRole.values.map((r) {
                final info = userRoleInfo[r]!;
                final isSel = selected == r;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: InkWell(
                    onTap: () => onSelect(r),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSel
                            ? info.color.withValues(alpha: 0.10)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSel ? info.color : Colors.black12,
                          width: isSel ? 2 : 1,
                        ),
                      ),
                      child: Row(children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: info.color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(info.icon, color: info.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(info.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                              const SizedBox(height: 2),
                              Text(info.tagline,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall),
                            ],
                          ),
                        ),
                        if (isSel)
                          Icon(Icons.check_circle, color: info.color),
                      ]),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 2 ─ Goals picker ────────────────────────────────────────────

class _GoalsPicker extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const _GoalsPicker({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are you working toward?',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Pick any that apply. We will tailor your home screen and quiz suggestions to match.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: userGoals.map((g) {
                final isSel = selected.contains(g.id);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: InkWell(
                    onTap: () => onToggle(g.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel ? AppColors.primary : Colors.black12,
                          width: isSel ? 1.6 : 1,
                        ),
                      ),
                      child: Row(children: [
                        Icon(
                          isSel
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSel
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                              const SizedBox(height: 2),
                              Text(g.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 3 ─ Done ─────────────────────────────────────────────────────

class _Done extends StatelessWidget {
  final UserRole? role;
  const _Done({required this.role});

  @override
  Widget build(BuildContext context) {
    final info = role == null ? null : userRoleInfo[role];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: (info?.color ?? AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              info?.icon ?? Icons.check_circle,
              color: info?.color ?? AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 14),
          Text('You are all set',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          if (info != null)
            Text(
              'We will pin the ${info.label} content to your home screen and surface its tools first. You can still see every module — they will be in the All modules section below.',
              style: Theme.of(context).textTheme.bodyLarge,
            )
          else
            Text(
              'Your home screen will show every module. You can pick a track later from settings.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick tips',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                _Bullet(
                    text:
                        'Tap any speak button to hear lessons read aloud in British English.'),
                _Bullet(
                    text:
                        'Quizzes save your best score automatically — try practice mode first.'),
                _Bullet(
                    text:
                        'Job scenarios mimic real call-outs with a clock and a score.'),
                _Bullet(
                    text:
                        'Voice and language can be changed in Settings (the tune icon on the home AppBar).'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text('By tapping Get started you accept the ',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LegalScreen(initialTab: 1)),
                  ),
                  child: const Text('Terms',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline)),
                ),
                const Text(' and ',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LegalScreen(initialTab: 0)),
                  ),
                  child: const Text('Privacy policy',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline)),
                ),
                const Text('.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
              child: Text(text,
                  style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

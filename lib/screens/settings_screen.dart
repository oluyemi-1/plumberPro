import 'package:flutter/material.dart';

import '../services/ai_tutor_service.dart';
import '../services/diagnostics_service.dart';
import '../services/notifications_service.dart';
import '../services/theme_service.dart';
import '../services/tts_service.dart';
import '../services/user_profile_service.dart';
import '../theme.dart';
import 'backup_restore_screen.dart';
import 'diagnostics_screen.dart';
import 'legal_screen.dart';
import 'onboarding_screen.dart';
import 'storage_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _languages = <_LangOption>[
    _LangOption('English (United Kingdom)', 'en-GB'),
    _LangOption('English (Ireland)', 'en-IE'),
    _LangOption('English (Australia)', 'en-AU'),
    _LangOption('English (United States)', 'en-US'),
    _LangOption('English (India)', 'en-IN'),
  ];

  static const _sample =
      'Hello, this is your plumbing trainer. I will guide you through every simulation, step by step. Press play on any lesson to begin.';

  String _voiceFilter = 'British only';

  Future<void> _refresh() async {
    await TtsService.instance.refreshVoices();
  }

  Future<void> _testVoice() async {
    await TtsService.instance.speak(_sample);
  }

  List<TtsVoice> _filtered() {
    final all = TtsService.instance.voices;
    if (_voiceFilter == 'British only') {
      return all.where((v) => v.isUk).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }
    if (_voiceFilter == 'English only') {
      return all.where((v) => v.isEnglish).toList()
        ..sort((a, b) {
          if (a.isUk && !b.isUk) return -1;
          if (b.isUk && !a.isUk) return 1;
          return a.name.compareTo(b.name);
        });
    }
    return List<TtsVoice>.of(all)..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Widget build(BuildContext context) {
    final tts = TtsService.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            tooltip: 'Refresh voice list',
            onPressed: () async {
              await _refresh();
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: tts,
        builder: (_, __) {
          final voices = _filtered();
          final currentSelected = (tts.voiceName != null &&
                  tts.voiceLocale != null)
              ? TtsVoice(name: tts.voiceName!, locale: tts.voiceLocale!)
              : null;
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _ProfileCard(),
              const SizedBox(height: 12),
              const _AppearanceCard(),
              const SizedBox(height: 12),
              const _DailyReminderCard(),
              const SizedBox(height: 12),
              _AiTutorCard(),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Narration',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: tts.enabled,
                      onChanged: tts.setEnabled,
                      title: const Text('Enable spoken narration'),
                      subtitle: const Text(
                          'Turn off to silence all voice guidance across the app'),
                    ),
                    const Divider(),
                    _SliderRow(
                      label: 'Speech rate',
                      value: tts.rate,
                      min: 0.2,
                      max: 0.9,
                      divisions: 14,
                      formatter: (v) =>
                          v < 0.4 ? 'Slow' : (v < 0.6 ? 'Normal' : 'Fast'),
                      onChanged: tts.setRate,
                    ),
                    _SliderRow(
                      label: 'Pitch',
                      value: tts.pitch,
                      min: 0.6,
                      max: 1.6,
                      divisions: 20,
                      formatter: (v) => v.toStringAsFixed(2),
                      onChanged: tts.setPitch,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Voice and language',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Language',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _languages.map((l) {
                        final selected = tts.language == l.code;
                        return ChoiceChip(
                          label: Text(l.label),
                          selected: selected,
                          onSelected: (_) => tts.setLanguage(l.code),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          'Voice',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 6,
                          children: ['British only', 'English only', 'All']
                              .map((f) => ChoiceChip(
                                    label: Text(f),
                                    selected: _voiceFilter == f,
                                    onSelected: (_) =>
                                        setState(() => _voiceFilter = f),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (voices.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _voiceFilter == 'British only'
                              ? 'No British voice installed on this device. Tap a different filter, or install a UK voice from your system Text-to-speech settings.'
                              : 'No voices available. Tap refresh to scan again.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black12),
                        ),
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: voices.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final v = voices[i];
                            final selected = currentSelected == v;
                            return ListTile(
                              dense: true,
                              title: Text(v.name),
                              subtitle: Text(v.locale),
                              trailing: selected
                                  ? const Icon(Icons.check_circle,
                                      color: AppColors.primary)
                                  : null,
                              onTap: () async {
                                await TtsService.instance.setVoice(v);
                                await TtsService.instance.speak(_sample);
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _testVoice,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Test voice'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => TtsService.instance.stop(),
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: TtsService.instance.clearVoice,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Tips for the best voice',
                child: const Text(
                  'On Android, install a UK English voice from Settings, System, '
                  'Languages and input, Text to speech output, then tap the gear next '
                  'to your engine and choose Install voice data, English (United Kingdom). '
                  'Return to this screen and tap refresh.',
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cloud_sync,
                          color: AppColors.primary),
                      title: const Text('Backup & restore'),
                      subtitle: const Text(
                          'Move your data to another device — bookmarks, jobs, customers, photos and more'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BackupRestoreScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.sd_storage,
                          color: AppColors.primary),
                      title: const Text('Storage'),
                      subtitle: const Text(
                          'See how much space photos and voice notes use, and free space safely'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StorageScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    AnimatedBuilder(
                      animation: DiagnosticsService.instance,
                      builder: (context, _) {
                        final errors =
                            DiagnosticsService.instance.errorCount;
                        final total =
                            DiagnosticsService.instance.events.length;
                        return ListTile(
                          leading: Icon(
                            errors > 0
                                ? Icons.error_outline
                                : Icons.health_and_safety,
                            color: errors > 0
                                ? Colors.redAccent
                                : AppColors.primary,
                          ),
                          title: const Text('Diagnostics'),
                          subtitle: Text(
                            total == 0
                                ? 'Background error log — empty'
                                : errors > 0
                                    ? '$errors error${errors == 1 ? '' : 's'} · $total entries'
                                    : '$total entries · no errors',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DiagnosticsScreen()),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip,
                          color: AppColors.primary),
                      title: const Text('Privacy policy'),
                      subtitle: const Text(
                          'How your data is handled — short and plain English'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const LegalScreen(initialTab: 0)),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.gavel,
                          color: AppColors.primary),
                      title: const Text('Terms of use'),
                      subtitle: const Text(
                          'What this app is for, and what it is not'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const LegalScreen(initialTab: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LangOption {
  final String label;
  final String code;
  const _LangOption(this.label, this.code);
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, _) {
        final mode = ThemeService.instance.mode;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.palette,
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Appearance',
                      style: Theme.of(context).textTheme.titleLarge),
                ]),
                const SizedBox(height: 6),
                const Text(
                  'Pick a theme. System follows your phone\'s light or dark setting automatically.',
                ),
                const SizedBox(height: 10),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {mode},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) =>
                      ThemeService.instance.setMode(s.first),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AiTutorCard extends StatefulWidget {
  const _AiTutorCard();

  @override
  State<_AiTutorCard> createState() => _AiTutorCardState();
}

class _AiTutorCardState extends State<_AiTutorCard> {
  final _keyCtrl = TextEditingController();
  bool _obscure = true;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    AiTutorService.instance.ensureLoaded().then((_) {
      if (!mounted) return;
      _keyCtrl.text = AiTutorService.instance.apiKey ?? '';
      setState(() {});
    });
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AiTutorService.instance,
      builder: (context, _) {
        final svc = AiTutorService.instance;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.auto_awesome,
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('AI tutor (Anthropic)',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  Chip(
                    label: Text(svc.hasUserKey
                        ? 'Your key'
                        : svc.usingProxy
                            ? 'Server proxy'
                            : svc.usingBakedInKey
                                ? 'Build-in key'
                                : 'No key'),
                    backgroundColor: (svc.hasKey
                            ? Colors.green
                            : Colors.redAccent)
                        .withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color:
                          svc.hasKey ? Colors.green : Colors.redAccent,
                      fontWeight: FontWeight.w700,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ]),
                const SizedBox(height: 6),
                Text(
                  svc.usingProxy
                      ? 'AI calls route through PipeSmart\'s server, so no API key is required. You can still paste your own Anthropic key below to use your own quota and billing — that takes priority and goes direct to api.anthropic.com.'
                      : svc.usingBakedInKey
                          ? 'This build was compiled with a built-in demo key. Anyone with the APK can extract it — only ship this build to closed testing tracks. You can override with your own key below.'
                          : 'Paste your Anthropic API key to enable the in-app AI tutor. Stored locally on this device only — never sent anywhere except api.anthropic.com.',
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _keyCtrl,
                  obscureText: _obscure,
                  enabled: _editing || !svc.hasKey,
                  decoration: InputDecoration(
                    labelText: 'API key',
                    hintText: 'sk-ant-api03-…',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  if (svc.hasKey && !_editing)
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _editing = true),
                      icon: const Icon(Icons.edit),
                      label: const Text('Replace key'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await svc.setApiKey(_keyCtrl.text);
                        if (!mounted) return;
                        setState(() => _editing = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(svc.hasKey
                                ? 'API key saved.'
                                : 'API key cleared.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  const SizedBox(width: 8),
                  if (svc.hasKey)
                    TextButton.icon(
                      onPressed: () async {
                        await svc.setApiKey('');
                        _keyCtrl.clear();
                        setState(() => _editing = false);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Clear'),
                    ),
                ]),
                const SizedBox(height: 14),
                Text('Model',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: AiTutorService.availableModels.map((m) {
                    final selected = svc.model == m.id;
                    return ChoiceChip(
                      label: Text(m.label),
                      selected: selected,
                      onSelected: (_) => svc.setModel(m.id),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                Text(
                  AiTutorService.availableModels
                      .firstWhere(
                        (m) => m.id == svc.model,
                        orElse: () =>
                            AiTutorService.availableModels.first,
                      )
                      .description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.savings,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('Cost control',
                            style:
                                Theme.of(context).textTheme.titleSmall),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                        'The system prompt is sent with prompt caching enabled — after the first message of a chat, subsequent messages reuse the cached prompt and cost roughly 90% less. Cached replies so far: ${svc.cacheHits}.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UserProfileService.instance,
      builder: (context, _) {
        final profile = UserProfileService.instance;
        final info = profile.roleInfo;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        (info?.color ?? AppColors.primary)
                            .withValues(alpha: 0.15),
                    child: Icon(
                      info?.icon ?? Icons.person,
                      color: info?.color ?? AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName.isEmpty
                              ? 'Your profile'
                              : profile.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          info?.label ?? 'No track selected',
                          style: TextStyle(
                            color: info?.color ?? AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (profile.goals.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${profile.goals.length} goal${profile.goals.length == 1 ? '' : 's'} pinned',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const OnboardingScreen(popOnFinish: true),
                        ),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Update profile'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _DailyReminderCard extends StatelessWidget {
  const _DailyReminderCard();

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NotificationsService.instance,
      builder: (context, _) {
        final svc = NotificationsService.instance;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.notifications_active,
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Daily reminder',
                      style: Theme.of(context).textTheme.titleLarge),
                ]),
                const SizedBox(height: 6),
                const Text(
                  'Get a one-line nudge each morning to keep your study streak going. Personalised to your current streak.',
                ),
                if (!svc.supported) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Notifications are only supported on iOS and Android. On this platform the toggle is disabled.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: svc.enabled,
                    onChanged: (v) async {
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await svc.setEnabled(v);
                      if (v && !ok) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Notification permission denied. Enable it in your phone\'s settings to receive the daily reminder.'),
                          ),
                        );
                      }
                    },
                    title: const Text('Send a reminder every day'),
                    subtitle: Text(svc.enabled
                        ? 'Next firing: ${_formatTime(svc.time)}'
                        : 'Off'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: svc.enabled,
                    leading: const Icon(Icons.access_time),
                    title: const Text('Time of day'),
                    subtitle: Text(_formatTime(svc.time)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: !svc.enabled
                        ? null
                        : () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: svc.time,
                            );
                            if (picked != null) {
                              await svc.setTime(picked);
                            }
                          },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) formatter;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.formatter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(formatter(value),
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

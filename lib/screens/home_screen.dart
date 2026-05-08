import 'dart:async';

import 'package:flutter/material.dart';

import '../data/content_index.dart';
import '../data/daily_challenge.dart';
import '../data/user_role_data.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../services/user_profile_service.dart';
import '../theme.dart';
import '../widgets/responsive.dart';
import 'simulations_hub.dart';
import 'lessons_screen.dart';
import 'troubleshooter_screen.dart';
import 'calculators_screen.dart';
import 'glossary_screen.dart';
import 'quizzes_screen.dart';
import 'scenarios_screen.dart';
import 'checklists_screen.dart';
import 'customer_explainers_screen.dart';
import 'tools_encyclopedia_screen.dart';
import 'conversions_screen.dart';
import 'regulations_screen.dart';
import 'careers_screen.dart';
import 'commercial_gas_hub_screen.dart';
import 'commercial_hub_screen.dart';
import 'heat_pump_hub_screen.dart';
import 'lpg_oil_hub_screen.dart';
import 'medical_gases_hub_screen.dart';
import 'sprinklers_hub_screen.dart';
import 'synoptic_screen.dart';
import 'ai_tutor_screen.dart';
import 'bookmarks_screen.dart';
import 'calendar_screen.dart';
import 'customers_screen.dart';
import 'dashboard_screen.dart';
import 'expenses_screen.dart';
import 'inventory_screen.dart';
import 'job_detail_screen.dart';
import 'jobs_screen.dart';
import 'quotes_screen.dart';
import 'reminders_screen.dart';
import 'photo_diagnosis_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import '../data/job_log_data.dart';
import '../services/job_log_service.dart';

class _Module {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
  final String? hubHint; // matches UserRoleInfo.hubRouteHint
  const _Module({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
    this.hubHint,
  });
}

List<_Module> _allModules() => [
      _Module(
        title: 'AI plumbing tutor',
        subtitle:
            'Ask anything in UK plumbing language — your private AI mentor.',
        icon: Icons.auto_awesome,
        color: const Color(0xFF8E44AD),
        builder: (_) => const AiTutorScreen(),
      ),
      _Module(
        title: 'Photo fault diagnosis',
        subtitle:
            'Snap a fault code, fitting or leak — get a UK-style diagnosis.',
        icon: Icons.camera_alt,
        color: const Color(0xFFE63946),
        builder: (_) => const PhotoDiagnosisScreen(),
      ),
      _Module(
        title: 'Job log & timer',
        subtitle:
            'Log customer jobs, time on the clock, parts used and totals.',
        icon: Icons.work,
        color: const Color(0xFF1B4965),
        builder: (_) => const JobsScreen(),
      ),
      _Module(
        title: 'Quotes & estimates',
        subtitle:
            'Survey-time estimates, signed PDF acceptance, one-tap convert to job.',
        icon: Icons.note_add,
        color: const Color(0xFF8E44AD),
        builder: (_) => const QuotesScreen(),
      ),
      _Module(
        title: 'Income dashboard',
        subtitle:
            'Revenue, hours, profit, miles and top customers — week, month or year.',
        icon: Icons.bar_chart,
        color: const Color(0xFF1F7A8C),
        builder: (_) => const DashboardScreen(),
      ),
      _Module(
        title: 'Service reminders',
        subtitle:
            'Annual boiler services, gas safety renewals — phone-notified on the due date.',
        icon: Icons.event_available,
        color: const Color(0xFFC1121F),
        builder: (_) => const RemindersScreen(),
      ),
      _Module(
        title: 'Calendar',
        subtitle:
            'Month grid of reminders due, jobs completed, quote expiries — tap any day for details.',
        icon: Icons.calendar_month,
        color: const Color(0xFF457B9D),
        builder: (_) => const CalendarScreen(),
      ),
      _Module(
        title: 'Customers',
        subtitle:
            'Light customer database — quick-pick when starting a new job.',
        icon: Icons.people_alt,
        color: const Color(0xFF6F4E7C),
        builder: (_) => const CustomersScreen(),
      ),
      _Module(
        title: 'Expenses & mileage',
        subtitle:
            'Log fuel, parts, tools and business miles — month and year totals.',
        icon: Icons.receipt_long,
        color: const Color(0xFF2E8B57),
        builder: (_) => const ExpensesScreen(),
      ),
      _Module(
        title: 'Van inventory',
        subtitle:
            'Track parts in your van — low-stock alerts before the next job.',
        icon: Icons.inventory_2,
        color: const Color(0xFFB8860B),
        builder: (_) => const InventoryScreen(),
      ),
      _Module(
        title: 'Practical simulations',
        subtitle:
            'Animated, narrated step by step walk throughs of real systems',
        icon: Icons.play_circle_fill,
        color: AppColors.primary,
        builder: (_) => const SimulationsHubScreen(),
        hubHint: 'simulations',
      ),
      _Module(
        title: 'Heat pump installer',
        subtitle:
            'Heat-loss design, emitter sizing, MCS 020 sound, F-gas, commissioning',
        icon: Icons.heat_pump,
        color: const Color(0xFFE76F51),
        builder: (_) => const HeatPumpHubScreen(),
        hubHint: 'heat_pump',
      ),
      _Module(
        title: 'Commercial plumbing engineer',
        subtitle:
            'Booster sets, calorifiers, cascade boilers, L8 hygiene, BS 1710',
        icon: Icons.apartment,
        color: const Color(0xFF073B4C),
        builder: (_) => const CommercialHubScreen(),
        hubHint: 'commercial',
      ),
      _Module(
        title: 'Commercial gas engineer',
        subtitle:
            'IGEM/UP/1, UP/2, UP/16, BS 6644 ventilation, BS 6173 catering interlock',
        icon: Icons.local_fire_department,
        color: const Color(0xFFB8860B),
        builder: (_) => const CommercialGasHubScreen(),
        hubHint: 'commercial_gas',
      ),
      _Module(
        title: 'LPG & oil specialist',
        subtitle:
            'UKLPG, OFTEC, BS 5482, bunding, bulk-tank sizing for off-grid',
        icon: Icons.propane_tank,
        color: const Color(0xFF7B2CBF),
        builder: (_) => const LpgOilHubScreen(),
        hubHint: 'lpg_oil',
      ),
      _Module(
        title: 'Medical gas pipelines',
        subtitle: 'HTM 02-01, AVSU, AP-MGPS oversight, brazed-under-nitrogen',
        icon: Icons.local_hospital,
        color: const Color(0xFF0077B6),
        builder: (_) => const MedicalGasesHubScreen(),
        hubHint: 'medical',
      ),
      _Module(
        title: 'Fire sprinkler systems',
        subtitle: 'BS 9251, BS EN 12845, hazard categories, K-factor design',
        icon: Icons.fire_extinguisher,
        color: const Color(0xFFD62828),
        builder: (_) => const SprinklersHubScreen(),
        hubHint: 'sprinkler',
      ),
      _Module(
        title: 'Lessons and theory',
        subtitle: 'Listen to or read core plumbing knowledge',
        icon: Icons.menu_book,
        color: const Color(0xFF2A9D8F),
        builder: (_) => const LessonsScreen(),
        hubHint: 'lessons',
      ),
      _Module(
        title: 'Quizzes',
        subtitle:
            'Test your knowledge with practice and exam modes, scores saved',
        icon: Icons.quiz,
        color: const Color(0xFFE76F51),
        builder: (_) => const QuizzesScreen(),
      ),
      _Module(
        title: 'Job scenarios',
        subtitle:
            'Walk through a real call-out: customer brief, decisions, scoring',
        icon: Icons.work_history,
        color: const Color(0xFFD62828),
        builder: (_) => const ScenariosScreen(),
      ),
      _Module(
        title: 'Troubleshooter',
        subtitle: 'Diagnose common faults, guided with safety notes',
        icon: Icons.build_circle,
        color: AppColors.accent,
        builder: (_) => const TroubleshooterScreen(),
      ),
      _Module(
        title: 'Pre-job checklists',
        subtitle:
            'Field-ready tick lists for swaps, services, refits and tests',
        icon: Icons.checklist,
        color: const Color(0xFF457B9D),
        builder: (_) => const ChecklistsScreen(),
      ),
      _Module(
        title: 'Customer explainers',
        subtitle: 'Plain-English audio you can play in front of the homeowner',
        icon: Icons.campaign,
        color: const Color(0xFF6F4E7C),
        builder: (_) => const CustomerExplainersScreen(),
      ),
      _Module(
        title: 'Tool encyclopedia',
        subtitle: 'Every common plumbing tool, with use, errors and safety',
        icon: Icons.handyman,
        color: const Color(0xFFB87333),
        builder: (_) => const ToolsEncyclopediaScreen(),
      ),
      _Module(
        title: 'Calculators',
        subtitle:
            'Pipe sizing, radiator heat load, head pressure, flow rate, system volume',
        icon: Icons.calculate,
        color: const Color(0xFF1B998B),
        builder: (_) => const CalculatorsScreen(),
      ),
      _Module(
        title: 'Unit conversions',
        subtitle: 'Length, pressure, flow, power, volume, temperature, mass',
        icon: Icons.swap_horiz,
        color: const Color(0xFF118AB2),
        builder: (_) => const ConversionsScreen(),
      ),
      _Module(
        title: 'Regulations & standards',
        subtitle:
            'Building Regs, Water Regs, Gas Regs and the BS standards',
        icon: Icons.gavel,
        color: const Color(0xFF073B4C),
        builder: (_) => const RegulationsScreen(),
      ),
      _Module(
        title: 'Synoptic mock assessment',
        subtitle:
            'End-to-end timed exam, design, calculation and diagnosis combined',
        icon: Icons.fact_check,
        color: const Color(0xFFC1121F),
        builder: (_) => const SynopticScreen(),
      ),
      _Module(
        title: 'Career pathway',
        subtitle:
            'Stages, qualifications and the routes through the trade',
        icon: Icons.route,
        color: const Color(0xFF386641),
        builder: (_) => const CareersScreen(),
      ),
      _Module(
        title: 'Glossary',
        subtitle: 'Plumbing terms in plain English, tap to hear',
        icon: Icons.spellcheck,
        color: const Color(0xFF264653),
        builder: (_) => const GlossaryScreen(),
      ),
      _Module(
        title: 'Voice and settings',
        subtitle: 'Pick a British voice, change rate or pitch',
        icon: Icons.tune,
        color: const Color(0xFF8E44AD),
        builder: (_) => const SettingsScreen(),
      ),
    ];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final modules = _allModules();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plumber Pro'),
        actions: [
          const _RunningTimerChip(),
          IconButton(
            tooltip: 'Search everything',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Bookmarks',
            icon: const Icon(Icons.bookmark),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookmarksScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Your progress',
            icon: const Icon(Icons.insights),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ),
          AnimatedBuilder(
            animation: TtsService.instance,
            builder: (_, __) => IconButton(
              tooltip: 'Toggle narration',
              onPressed: () => TtsService.instance
                  .setEnabled(!TtsService.instance.enabled),
              icon: Icon(TtsService.instance.enabled
                  ? Icons.volume_up
                  : Icons.volume_off),
            ),
          ),
          IconButton(
            tooltip: 'Voice & settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: UserProfileService.instance,
        builder: (context, _) {
          final profile = UserProfileService.instance;
          final info = profile.roleInfo;
          final recommended = info == null
              ? <_Module>[]
              : modules
                  .where((m) => info.recommendedModules.contains(m.title))
                  .toList();
          // Other modules — those not in recommended.
          final others = modules
              .where((m) => !recommended.any((r) => r.title == m.title))
              .toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxis = responsiveGridCount(constraints.maxWidth);
              return MaxContentWidth(
                maxWidth: 1200,
                child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  _Greeting(
                    name: profile.displayName,
                    info: info,
                  ),
                  const SizedBox(height: 12),
                  if (info != null)
                    _TrackHero(
                      info: info,
                      onOpen: () {
                        final hub = modules.firstWhere(
                          (m) => m.hubHint == info.hubRouteHint,
                          orElse: () => modules.first,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: hub.builder),
                        );
                      },
                    )
                  else
                    _GenericHero(
                      onStart: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SimulationsHubScreen()),
                      ),
                    ),
                  const SizedBox(height: 14),
                  const _DailyChallengeCard(),
                  const _RecentStrip(),
                  if (recommended.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text('Recommended for you',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recommended.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxis,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 168,
                      ),
                      itemBuilder: (_, i) =>
                          _ModuleTile(module: recommended[i]),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    info == null ? 'All modules' : 'Everything else',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: others.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxis,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 168,
                    ),
                    itemBuilder: (_, i) => _ModuleTile(module: others[i]),
                  ),
                  const SizedBox(height: 24),
                  const _QuickTipsCard(),
                ],
              ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final String name;
  final UserRoleInfo? info;
  const _Greeting({required this.name, required this.info});

  @override
  Widget build(BuildContext context) {
    final greet = name.isEmpty ? 'Welcome back' : 'Welcome back, $name';
    return AnimatedBuilder(
      animation: ProgressService.instance,
      builder: (context, _) {
        final streak = ProgressService.instance.streak;
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greet,
                      style: Theme.of(context).textTheme.titleLarge),
                  if (info != null) ...[
                    const SizedBox(height: 2),
                    Text(info!.label,
                        style: TextStyle(color: info!.color, fontSize: 13)),
                  ],
                ],
              ),
            ),
            if (streak > 0) _StreakChip(streak: streak),
          ],
        );
      },
    );
  }
}

/// Small live chip that appears in the home AppBar when a job timer is
/// running. Shows the elapsed time and links straight to the job detail.
class _RunningTimerChip extends StatefulWidget {
  const _RunningTimerChip();

  @override
  State<_RunningTimerChip> createState() => _RunningTimerChipState();
}

class _RunningTimerChipState extends State<_RunningTimerChip> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    JobLogService.instance.ensureLoaded();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: JobLogService.instance,
      builder: (context, _) {
        final Job? running = JobLogService.instance.runningJob;
        if (running == null) return const SizedBox.shrink();
        final elapsed = running.totalTime(DateTime.now());
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => JobDetailScreen(jobId: running.id)),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.55)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fiber_manual_record,
                      color: AppColors.accent, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    formatDuration(elapsed),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StreakChip extends StatelessWidget {
  final int streak;
  const _StreakChip({required this.streak});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StatsScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.gas.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.gas.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department,
                color: AppColors.gas, size: 16),
            const SizedBox(width: 4),
            Text(
              '$streak day${streak == 1 ? '' : 's'}',
              style: const TextStyle(
                color: AppColors.gas,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard();

  @override
  Widget build(BuildContext context) {
    final challenge = todaysChallenge(buildContentIndex());
    if (challenge == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            ProgressService.instance.markVisited(challenge.id);
            Navigator.push(
              context,
              MaterialPageRoute(builder: challenge.builder),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  challenge.color.withValues(alpha: 0.95),
                  challenge.color.withValues(alpha: 0.65),
                ],
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(challenge.icon,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TODAY\'S CHALLENGE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          )),
                      const SizedBox(height: 2),
                      Text(challenge.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(challenge.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentStrip extends StatelessWidget {
  const _RecentStrip();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ProgressService.instance,
      builder: (context, _) {
        final ids = ProgressService.instance.recentIds;
        if (ids.isEmpty) return const SizedBox.shrink();
        final all = buildContentIndex();
        final byId = {for (final e in all) e.id: e};
        final entries = ids
            .map((id) => byId[id])
            .whereType<SearchEntry>()
            .take(8)
            .toList();
        if (entries.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pick up where you left off',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _RecentCard(entry: entries[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentCard extends StatelessWidget {
  final SearchEntry entry;
  const _RecentCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            ProgressService.instance.markVisited(entry.id);
            Navigator.push(
              context,
              MaterialPageRoute(builder: entry.builder),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: entry.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(entry.icon, color: entry.color, size: 18),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(entry.type,
                        style: TextStyle(
                            color: entry.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(entry.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(entry.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackHero extends StatelessWidget {
  final UserRoleInfo info;
  final VoidCallback onOpen;
  const _TrackHero({required this.info, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            info.color.withValues(alpha: 0.95),
            info.color.withValues(alpha: 0.65),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -16,
            child: Icon(info.icon,
                size: 160, color: Colors.white.withValues(alpha: 0.10)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR TRACK',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                info.tagline,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Open my hub'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: info.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenericHero extends StatelessWidget {
  final VoidCallback onStart;
  const _GenericHero({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.plumbing,
                size: 200, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learn by doing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Interactive narrated simulations of water, heating and drainage systems.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start a simulation'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final _Module module;
  const _ModuleTile({required this.module});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          ProgressService.instance
              .markVisited('hub:${module.hubHint ?? module.title}');
          Navigator.push(
            context,
            MaterialPageRoute(builder: module.builder),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(module.icon, color: module.color),
              ),
              const Spacer(),
              Text(module.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(
                module.subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTipsCard extends StatelessWidget {
  const _QuickTipsCard();

  static const _tips = [
    'Cold water mains pressure is usually 2 to 4 bar. Test before every installation.',
    'Store hot water at 60 degrees to suppress Legionella, blend to a safe temperature at the outlet.',
    'Sealed heating systems should read one to one and a half bar cold, rising about half a bar when hot.',
    'Always reseat a trap with hand pressure only, a wrench cracks the threads.',
    'Never run copper inside a wall without protection against corrosion from plaster.',
    'A dripping tundish means either high pressure or a failed safety valve, never block it.',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.lightbulb, color: AppColors.gas),
              const SizedBox(width: 8),
              Text('On-the-job tips',
                  style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 8),
            ..._tips.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(
                        child: Text(t,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      IconButton(
                        tooltip: 'Read aloud',
                        icon: const Icon(Icons.volume_up, size: 18),
                        onPressed: () => TtsService.instance.speak(t),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}


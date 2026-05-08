import 'package:flutter/material.dart';

import '../data/pas_2035_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class Pas2035Screen extends StatefulWidget {
  const Pas2035Screen({super.key});

  @override
  State<Pas2035Screen> createState() => _Pas2035ScreenState();
}

class _Pas2035ScreenState extends State<Pas2035Screen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('PAS 2035 retrofit pathway'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const <Tab>[
            Tab(icon: Icon(Icons.timeline), text: 'Pathway'),
            Tab(icon: Icon(Icons.groups_outlined), text: 'Roles'),
            Tab(icon: Icon(Icons.warning_amber_outlined), text: 'Risk paths'),
            Tab(icon: Icon(Icons.air_outlined), text: 'Ventilation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          _PathwayTab(),
          _RolesTab(),
          _RiskPathsTab(),
          _VentilationTab(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pathway tab
// ---------------------------------------------------------------------------

class _PathwayTab extends StatelessWidget {
  const _PathwayTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (BuildContext context, int index) {
        final PasStage stage = pasStages[index];
        return _StageCard(stage: stage);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: pasStages.length,
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.stage});

  final PasStage stage;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBg,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: Text(
                    '${stage.order}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stage.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              stage.description,
              style: const TextStyle(color: AppColors.text, height: 1.35),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Outputs',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...stage.outputs.map(
                    (String o) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(top: 6, right: 8),
                            child: Icon(
                              Icons.circle,
                              size: 6,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              o,
                              style: const TextStyle(color: AppColors.text),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: _SpeakButton(text: stage.speakable),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Roles tab
// ---------------------------------------------------------------------------

class _RolesTab extends StatelessWidget {
  const _RolesTab();

  static const List<IconData> _icons = <IconData>[
    Icons.engineering,
    Icons.fact_check_outlined,
    Icons.design_services_outlined,
    Icons.build_outlined,
    Icons.assignment_turned_in_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (BuildContext context, int index) {
        final RetrofitRole role = retrofitRoles[index];
        final IconData icon = _icons[index % _icons.length];
        return Card(
          color: AppColors.cardBg,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.accent.withValues(alpha: 0.18),
              foregroundColor: AppColors.primaryDark,
              child: Icon(icon),
            ),
            title: Text(
              role.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                role.summary,
                style: const TextStyle(color: AppColors.muted, height: 1.3),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _RoleDetailScreen(role: role, icon: icon),
                ),
              );
            },
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: retrofitRoles.length,
    );
  }
}

class _RoleDetailScreen extends StatelessWidget {
  const _RoleDetailScreen({required this.role, required this.icon});

  final RetrofitRole role;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(role.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            tooltip: 'Speak whole entry',
            icon: const Icon(Icons.volume_up),
            onPressed: () => TtsService.instance.speak(role.speakable),
          ),
          IconButton(
            tooltip: 'Stop',
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: () => TtsService.instance.stop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.accent.withValues(alpha: 0.18),
                foregroundColor: AppColors.primaryDark,
                child: Icon(icon, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  role.summary,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.text,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _DetailSection(
            title: 'Responsibilities',
            speakText: 'Responsibilities. ${role.responsibilities}',
            child: Text(
              role.responsibilities,
              style: const TextStyle(color: AppColors.text, height: 1.4),
            ),
          ),
          _DetailSection(
            title: 'Deliverables',
            speakText:
                'Deliverables. ${role.deliverables.join(". ")}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: role.deliverables
                  .map(
                    (String d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(top: 7, right: 8),
                            child: Icon(
                              Icons.circle,
                              size: 6,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              d,
                              style: const TextStyle(
                                color: AppColors.text,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          _DetailSection(
            title: 'Competence',
            speakText: 'Competence. ${role.competence}',
            child: Text(
              role.competence,
              style: const TextStyle(color: AppColors.text, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.speakText,
    required this.child,
  });

  final String title;
  final String speakText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              _SpeakButton(text: speakText, compact: true),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Risk paths tab
// ---------------------------------------------------------------------------

class _RiskPathsTab extends StatelessWidget {
  const _RiskPathsTab();

  Color _colorFor(String label) {
    switch (label) {
      case 'A':
        return AppColors.coldWater;
      case 'B':
        return AppColors.accent;
      case 'C':
      default:
        return AppColors.hotWater;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: riskPaths.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (BuildContext context, int index) {
        final RiskPath path = riskPaths[index];
        final Color accent = _colorFor(path.label);
        return Card(
          color: AppColors.cardBg,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        path.label,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Risk Path ${path.label}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  path.summary,
                  style: const TextStyle(
                    color: AppColors.text,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Requirements',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                ...path.requirements.map(
                  (String r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 6, right: 8),
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: accent,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            r,
                            style: const TextStyle(
                              color: AppColors.text,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _SpeakButton(text: path.speakable),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Ventilation tab
// ---------------------------------------------------------------------------

class _VentilationTab extends StatelessWidget {
  const _VentilationTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ventilationStrategies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (BuildContext context, int index) {
        final VentilationStrategy v = ventilationStrategies[index];
        return Card(
          color: AppColors.cardBg,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.coldWater.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        v.label,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Strategy ${v.label}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _LabelledRow(
                  icon: Icons.speed_outlined,
                  label: 'Airtightness',
                  value: v.airtightness,
                ),
                const SizedBox(height: 10),
                _LabelledRow(
                  icon: Icons.air,
                  label: 'Approach',
                  value: v.approach,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _SpeakButton(text: v.speakable),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LabelledRow extends StatelessWidget {
  const _LabelledRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.primaryDark),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared speak button
// ---------------------------------------------------------------------------

class _SpeakButton extends StatelessWidget {
  const _SpeakButton({required this.text, this.compact = false});

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        tooltip: 'Speak',
        icon: const Icon(Icons.volume_up, color: AppColors.primaryDark),
        onPressed: () => TtsService.instance.speak(text),
      );
    }
    return TextButton.icon(
      onPressed: () => TtsService.instance.speak(text),
      icon: const Icon(Icons.volume_up, size: 18),
      label: const Text('Speak'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

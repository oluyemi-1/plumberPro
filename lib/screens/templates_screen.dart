import 'package:flutter/material.dart';

import '../data/job_log_data.dart';
import '../data/job_template_data.dart';
import '../services/job_template_service.dart';
import '../theme.dart';
import 'edit_template_screen.dart';
import 'job_detail_screen.dart';
import 'new_job_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  @override
  void initState() {
    super.initState();
    JobTemplateService.instance.ensureLoaded();
  }

  Future<void> _useTemplate(JobTemplate t) async {
    final nav = Navigator.of(context);
    final job = await nav.push<Job?>(
      MaterialPageRoute(builder: (_) => NewJobScreen(prefillTemplate: t)),
    );
    if (job != null) {
      nav.push(
        MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: job.id)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job templates'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'restore') {
                final messenger = ScaffoldMessenger.of(context);
                await JobTemplateService.instance.restoreBuiltIns();
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Built-in templates restored.')),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'restore',
                child: Text('Restore built-in templates'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New template'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditTemplateScreen()),
        ),
      ),
      body: AnimatedBuilder(
        animation: JobTemplateService.instance,
        builder: (context, _) {
          final templates = JobTemplateService.instance.templates;
          if (templates.isEmpty) {
            return const _EmptyState();
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
            children: [
              const _IntroCard(),
              const SizedBox(height: 12),
              for (final t in templates) _TemplateCard(
                template: t,
                onUse: () => _useTemplate(t),
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditTemplateScreen(existing: t)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.layers, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('One-tap job creation',
                  style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 6),
            const Text(
                'Tap Use on any template to start a new job with the description, hourly rate, suggested materials and notes already filled in. You can still tweak everything before saving.'),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final JobTemplate template;
  final VoidCallback onUse;
  final VoidCallback onEdit;
  const _TemplateCard({
    required this.template,
    required this.onUse,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final t = template;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_iconFor(t.iconCode),
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(t.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                            ),
                            if (t.builtIn)
                              const _Tag(label: 'BUILT-IN'),
                          ]),
                          if (t.description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(t.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (t.suggestedMaterials.isNotEmpty)
                      _Pill(
                        label:
                            '${t.suggestedMaterials.length} part${t.suggestedMaterials.length == 1 ? '' : 's'}',
                        color: AppColors.coldWater,
                      ),
                    if (t.defaultHourlyRateGbp != null)
                      _Pill(
                        label:
                            '£${t.defaultHourlyRateGbp!.toStringAsFixed(0)}/h',
                        color: AppColors.accent,
                      ),
                    if (t.defaultNotes.isNotEmpty)
                      const _Pill(label: 'Notes prompt',
                          color: AppColors.muted),
                  ],
                ),
                const SizedBox(height: 10),
                Row(children: [
                  ElevatedButton.icon(
                    onPressed: onUse,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Use'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.muted.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 9,
            color: AppColors.muted,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.layers_outlined,
                size: 64, color: AppColors.muted),
            const SizedBox(height: 8),
            Text('No templates yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
                'Tap New template to add one, or use the menu in the AppBar to restore the built-in set.',
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Maps a template's iconCode string to a Material icon. Lets us serialise
/// the choice in JSON without storing a code-point.
IconData _iconFor(String code) {
  switch (code) {
    case 'flame':
      return Icons.local_fire_department;
    case 'tap':
      return Icons.water_drop;
    case 'drain':
      return Icons.plumbing;
    case 'radiator':
      return Icons.heat_pump;
    case 'flush':
      return Icons.sync;
    case 'bathroom':
      return Icons.bathtub;
    case 'cylinder':
      return Icons.propane_tank;
    case 'wrench':
      return Icons.build;
    case 'tools':
      return Icons.handyman;
    case 'electrical':
      return Icons.bolt;
    case 'leak':
      return Icons.water_damage;
    case 'inspection':
      return Icons.fact_check;
    default:
      return Icons.layers;
  }
}

/// Public list of icon options used by the edit screen.
const templateIconOptions = <(String, IconData)>[
  ('wrench', Icons.build),
  ('tools', Icons.handyman),
  ('flame', Icons.local_fire_department),
  ('tap', Icons.water_drop),
  ('drain', Icons.plumbing),
  ('radiator', Icons.heat_pump),
  ('flush', Icons.sync),
  ('bathroom', Icons.bathtub),
  ('cylinder', Icons.propane_tank),
  ('electrical', Icons.bolt),
  ('leak', Icons.water_damage),
  ('inspection', Icons.fact_check),
];

IconData iconForCode(String code) => _iconFor(code);

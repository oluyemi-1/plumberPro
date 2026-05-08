import 'package:flutter/material.dart';

import '../data/careers_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

/// Top-level careers reference screen with three tabs:
///   * Stages — vertical timeline of [CareerStage]s.
///   * Qualifications — searchable list with detail screens.
///   * Pathways — list of [CareerPath]s.
class CareersScreen extends StatefulWidget {
  const CareersScreen({super.key});

  @override
  State<CareersScreen> createState() => _CareersScreenState();
}

class _CareersScreenState extends State<CareersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _qualSearch = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      appBar: AppBar(
        title: const Text('Careers and qualifications'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Stages'),
            Tab(text: 'Qualifications'),
            Tab(text: 'Pathways'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Stop narration',
            icon: const Icon(Icons.stop_circle),
            onPressed: () => TtsService.instance.stop(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StagesTab(),
          _QualificationsTab(
            search: _qualSearch,
            onSearchChanged: (v) => setState(() => _qualSearch = v),
          ),
          _PathwaysTab(),
        ],
      ),
    );
  }
}

class _StagesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stages = careerStages;
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: stages.length,
      itemBuilder: (context, i) {
        final stage = stages[i];
        final isLast = i == stages.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  stage.stage,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Read aloud',
                                icon: const Icon(Icons.record_voice_over),
                                onPressed: () => TtsService.instance
                                    .speak(stage.speakable),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(stage.description,
                              style:
                                  Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: stage.skills
                                .map((s) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.08),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: Text(
                                        s,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QualificationsTab extends StatelessWidget {
  final String search;
  final ValueChanged<String> onSearchChanged;
  const _QualificationsTab({
    required this.search,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final query = search.trim().toLowerCase();
    final filtered = qualifications.where((q) {
      if (query.isEmpty) return true;
      return q.name.toLowerCase().contains(query) ||
          q.summary.toLowerCase().contains(query) ||
          q.level.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search qualifications',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('No qualifications match that search.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final q = filtered[i];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: _levelColor(q.level)
                              .withValues(alpha: 0.15),
                          child: Icon(Icons.school,
                              color: _levelColor(q.level)),
                        ),
                        title: Text(q.name,
                            style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _levelColor(q.level)
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(999),
                                ),
                                child: Text(
                                  q.level,
                                  style: TextStyle(
                                    color: _levelColor(q.level),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(q.summary),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  _QualificationDetailScreen(qual: q),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

Color _levelColor(String level) {
  switch (level) {
    case 'Foundation':
      return AppColors.coldWater;
    case 'Practising':
      return AppColors.primary;
    case 'Specialist':
      return AppColors.accent;
    default:
      return AppColors.muted;
  }
}

class _QualificationDetailScreen extends StatelessWidget {
  final Qualification qual;
  const _QualificationDetailScreen({required this.qual});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(qual.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Read aloud',
            icon: const Icon(Icons.record_voice_over),
            onPressed: () => TtsService.instance.speak(qual.speakable),
          ),
          IconButton(
            tooltip: 'Stop narration',
            icon: const Icon(Icons.stop_circle),
            onPressed: () => TtsService.instance.stop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: _levelColor(qual.level).withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.school,
                      size: 36, color: _levelColor(qual.level)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(qual.level,
                            style: TextStyle(
                              color: _levelColor(qual.level),
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 4),
                        Text(qual.summary,
                            style:
                                Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Requirements',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...qual.requirements.map(
                    (r) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(r,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About this qualification',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(qual.body,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.record_voice_over),
            label: const Text('Speak'),
            onPressed: () => TtsService.instance.speak(qual.speakable),
          ),
        ],
      ),
    );
  }
}

class _PathwaysTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: careerPaths.length,
      itemBuilder: (context, i) {
        final path = careerPaths[i];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => _CareerPathDetailScreen(path: path),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppColors.accent.withValues(alpha: 0.15),
                        child: const Icon(Icons.work,
                            color: AppColors.accent),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(path.title,
                            style:
                                Theme.of(context).textTheme.titleLarge),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.muted),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(path.summary,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CareerPathDetailScreen extends StatelessWidget {
  final CareerPath path;
  const _CareerPathDetailScreen({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(path.title),
        actions: [
          IconButton(
            tooltip: 'Read aloud',
            icon: const Icon(Icons.record_voice_over),
            onPressed: () => TtsService.instance.speak(path.speakable),
          ),
          IconButton(
            tooltip: 'Stop narration',
            icon: const Icon(Icons.stop_circle),
            onPressed: () => TtsService.instance.stop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: AppColors.accent.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(path.summary,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(path.narrative,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('A typical day',
                          style:
                              Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...path.dayInTheLife.map(
                    (d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.fiber_manual_record,
                              size: 10, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(d,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payments,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Typical earnings',
                          style:
                              Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...path.typicalEarnings.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right,
                              color: AppColors.muted),
                          Expanded(
                            child: Text(e,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.record_voice_over),
            label: const Text('Read pathway aloud'),
            onPressed: () => TtsService.instance.speak(path.speakable),
          ),
        ],
      ),
    );
  }
}

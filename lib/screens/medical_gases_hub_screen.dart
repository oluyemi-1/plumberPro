import 'package:flutter/material.dart';

import '../data/medical_gases_checklists_data.dart';
import '../data/medical_gases_lessons_data.dart';
import '../services/tts_service.dart';
import '../simulations/avsu_sim.dart';
import '../theme.dart';
import 'checklists_screen.dart';
import 'lessons_screen.dart';
import 'medical_gases_reference_screen.dart';

class MedicalGasesHubScreen extends StatelessWidget {
  const MedicalGasesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical gas pipelines')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _Hero(
            title: 'Medical gas pipelines',
            subtitle:
                'HTM 02-01 • BS EN ISO 7396 • AP-MGPS • brazed-under-nitrogen',
            colors: const [Color(0xFF0077B6), Color(0xFF023E8A)],
            icon: Icons.local_hospital,
            onIntro: () => TtsService.instance.speak(
              'Welcome to the medical gas pipeline pack. Tools cover the gas reference for oxygen, medical air, surgical air, vacuum, AGSS, nitrous oxide, entonox and CO2, plus a simulation of Area Valve Service Units. Healthcare engineering is one of the most controlled environments in plumbing — every joint matters.',
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader('References'),
          _Tile(
            icon: Icons.medical_information,
            color: const Color(0xFF0077B6),
            title: 'Medical gases reference (HTM 02-01)',
            subtitle:
                'Properties, working pressures, terminal units and hazards for each gas.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MedicalGasesReferenceScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader('Simulations'),
          _Tile(
            icon: Icons.health_and_safety,
            color: AppColors.accent,
            title: 'AVSU emergency isolation',
            subtitle:
                'Three-zone Area Valve Service Unit panel with alarm and emergency shutdown.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AvsuSimScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader('Knowledge'),
          ...medicalGasesLessonTopics.map((t) => _Tile(
                icon: Icons.menu_book,
                color: const Color(0xFF2A9D8F),
                title: t.title,
                subtitle: t.summary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonDetailScreen(topic: t),
                  ),
                ),
              )),
          const SizedBox(height: 14),
          _SectionHeader('On-site checklists'),
          ...medicalGasesChecklists.map((cl) => _Tile(
                icon: Icons.checklist,
                color: const Color(0xFF457B9D),
                title: cl.title,
                subtitle: cl.summary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChecklistDetailScreen(checklist: cl),
                  ),
                ),
              )),
          const SizedBox(height: 24),
          Card(
            color: AppColors.cardBg,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('AP-MGPS oversight required',
                        style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'Medical gas work in the UK is performed under permit from an Authorised Person (AP-MGPS). The Quality Test Certificate must be signed off before any pipeline is brought into clinical service. This module is study material — never substitute for the AP-MGPS procedures of the actual healthcare site.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> colors;
  final IconData icon;
  final VoidCallback onIntro;
  const _Hero({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.icon,
    required this.onIntro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onIntro,
            icon: const Icon(Icons.record_voice_over),
            label: const Text('Listen to introduction'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _Tile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ]),
          ),
        ),
      ),
    );
  }
}

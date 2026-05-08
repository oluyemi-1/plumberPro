import 'package:flutter/material.dart';

import '../data/sprinklers_checklists_data.dart';
import '../data/sprinklers_lessons_data.dart';
import '../services/tts_service.dart';
import '../simulations/sprinkler_activation_sim.dart';
import '../theme.dart';
import 'checklists_screen.dart';
import 'lessons_screen.dart';
import 'sprinkler_design_screen.dart';

class SprinklersHubScreen extends StatelessWidget {
  const SprinklersHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fire sprinkler systems')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _Hero(
            title: 'Fire sprinkler systems',
            subtitle: 'BS 9251 • BS EN 12845 • residential & domestic life-safety',
            colors: const [Color(0xFFD62828), Color(0xFF8B0000)],
            icon: Icons.fire_extinguisher,
            onIntro: () => TtsService.instance.speak(
              'Welcome to the fire sprinkler pack. Tools cover BS nine two five one design — head selection, hazard categories, supply types, hydraulic flow Q equals K times the square root of pressure — plus an animated simulation of a head activating over a fire. Sprinklers save lives, and demand is growing as more local authorities mandate them.',
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader('Design tools'),
          _Tile(
            icon: Icons.calculate,
            color: const Color(0xFFD62828),
            title: 'Sprinkler system design',
            subtitle:
                'Hazard category, K-factor, supply type → flow, tank size, pipe size.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SprinklerDesignScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader('Simulations'),
          _Tile(
            icon: Icons.water_drop,
            color: AppColors.coldWater,
            title: 'Sprinkler activation',
            subtitle:
                'Watch a glass-bulb head burst over a fire and spray water — only the affected head activates.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SprinklerActivationSimScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader('Knowledge'),
          ...sprinklersLessonTopics.map((t) => _Tile(
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
          ...sprinklersChecklists.map((cl) => _Tile(
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

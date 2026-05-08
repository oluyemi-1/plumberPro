import 'package:flutter/material.dart';

import '../data/lpg_oil_checklists_data.dart';
import '../data/lpg_oil_lessons_data.dart';
import '../services/tts_service.dart';
import '../simulations/lpg_oil_sim.dart';
import '../theme.dart';
import 'checklists_screen.dart';
import 'lessons_screen.dart';
import 'lpg_tank_sizing_screen.dart';
import 'oil_tank_sizing_screen.dart';

class LpgOilHubScreen extends StatelessWidget {
  const LpgOilHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LPG & oil specialist')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _Hero(
            title: 'LPG & oil specialist',
            subtitle:
                'UKLPG • OFTEC • BS 5482 • bunding • bulk tanks • oil burners',
            colors: const [Color(0xFF7B2CBF), Color(0xFF3A0CA3)],
            icon: Icons.propane_tank,
            onIntro: () => TtsService.instance.speak(
              'Welcome to the LPG and oil pack. Tools cover bulk LPG sizing, oil tank sizing with bund volume, lessons on regulator work, fire valves, OFTEC commissioning, and a sectional view of bulk LPG and oil installations. Off-grid heating is a substantial commercial market in the UK.',
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader('Design tools'),
          _Tile(
            icon: Icons.propane_tank,
            color: const Color(0xFF7B2CBF),
            title: 'LPG tank sizing',
            subtitle:
                'Annual demand, refill interval and vapourisation rate from connected load.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LpgTankSizingScreen()),
            ),
          ),
          _Tile(
            icon: Icons.opacity,
            color: AppColors.brass,
            title: 'Oil tank sizing',
            subtitle:
                'Tank capacity, bund volume (110 % rule) and OFTEC distances.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OilTankSizingScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader('Simulations'),
          _Tile(
            icon: Icons.propane_tank,
            color: AppColors.gas,
            title: 'LPG and oil installations (sectional)',
            subtitle:
                'Switch between LPG bulk tank and oil tank, fire-valve trip, animated fuel flow.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LpgOilSimScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader('Knowledge'),
          ...lpgOilLessonTopics.map((t) => _Tile(
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
          ...lpgOilChecklists.map((cl) => _Tile(
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
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
              backgroundColor: AppColors.accent,
            ),
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

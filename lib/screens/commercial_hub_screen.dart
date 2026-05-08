import 'package:flutter/material.dart';

import '../data/commercial_checklists_data.dart';
import '../data/commercial_lessons_data.dart';
import '../services/tts_service.dart';
import '../simulations/cascade_boiler_sim.dart';
import '../theme.dart';
import 'booster_set_screen.dart';
import 'bs1710_reference_screen.dart';
import 'calorifier_sizing_screen.dart';
import 'checklists_screen.dart';
import 'l8_risk_screen.dart';
import 'lessons_screen.dart';

/// One-stop hub for the commercial plumbing engineer module.
class CommercialHubScreen extends StatelessWidget {
  const CommercialHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commercial plumbing engineer')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _Hero(
            onIntro: () => TtsService.instance.speak(
              'Welcome to the commercial plumbing pack. The tools here cover booster set design, calorifier sizing, cascade boiler sequencing, water hygiene under L8, BS 1710 pipe identification and the commissioning paperwork expected on a non-domestic project. This is the same workflow used on offices, hotels, schools and apartment blocks.',
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'Design tools'),
          _Tile(
            icon: Icons.compress,
            color: AppColors.coldWater,
            title: 'Booster set sizing',
            subtitle:
                'Size a cold-water booster from peak demand, head and storey count.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BoosterSetScreen()),
            ),
          ),
          _Tile(
            icon: Icons.water_damage,
            color: AppColors.hotWater,
            title: 'Calorifier sizing',
            subtitle:
                'Peak-hour DHW for hotels, schools, gyms — coil area and recovery time.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CalorifierSizingScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'Simulations'),
          _Tile(
            icon: Icons.dynamic_form,
            color: AppColors.gas,
            title: 'Cascade boiler sequencing',
            subtitle:
                'Lead/lag rotation, modulating across an array, BMS interface.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CascadeBoilerSimScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'Knowledge'),
          ...commercialLessonTopics.map((t) => _Tile(
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
          _SectionHeader(text: 'Compliance & references'),
          _Tile(
            icon: Icons.water_drop,
            color: AppColors.accent,
            title: 'L8 water hygiene risk assessment',
            subtitle:
                'Six-category scored risk assessment, persistent across sessions, with a generated report.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const L8RiskScreen()),
            ),
          ),
          _Tile(
            icon: Icons.color_lens,
            color: AppColors.primary,
            title: 'BS 1710 pipe identification',
            subtitle:
                'Colour-coded reference for every common service in a commercial building.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const Bs1710ReferenceScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'On-site checklists'),
          ...commercialChecklists.map((cl) => _Tile(
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
                    Text('Why this matters',
                        style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'Commercial buildings work to higher pressures, larger flows and tighter tolerances than a typical domestic install. Booster sets, calorifiers, cascade boilers, vent stacks and BMS controls are the common ground. Add HSE ACoP L8 water hygiene and BS 1710 pipe identification — and you are ready for site work that pays substantially more than domestic.',
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
  final VoidCallback onIntro;
  const _Hero({required this.onIntro});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2A36), Color(0xFF073B4C)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.apartment, color: Colors.white, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Commercial plumbing engineer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Booster sets • calorifiers • cascade boilers • L8 hygiene • BS 1710',
                    style: TextStyle(color: Colors.white70),
                  ),
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
  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
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

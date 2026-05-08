import 'package:flutter/material.dart';

import '../data/commercial_gas_checklists_data.dart';
import '../data/commercial_gas_lessons_data.dart';
import '../services/tts_service.dart';
import '../simulations/catering_interlock_sim.dart';
import '../theme.dart';
import 'boiler_room_ventilation_screen.dart';
import 'checklists_screen.dart';
import 'gas_pipe_sizing_screen.dart';
import 'hazardous_areas_screen.dart';
import 'lessons_screen.dart';
import 'tightness_test_screen.dart';

/// One-stop hub for the commercial gas engineer module.
class CommercialGasHubScreen extends StatelessWidget {
  const CommercialGasHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commercial gas engineer')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _Hero(
            onIntro: () => TtsService.instance.speak(
              'Welcome to the commercial gas pack. The tools here cover IGEM UP one tightness testing, IGEM UP two pipe sizing, BS six six four four boiler-room ventilation, IGEM UP sixteen hazardous area classification, and the BS six one seven three catering interlock. This is the workflow expected on a commercial gas engineer ACS portfolio.',
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'Design tools'),
          _Tile(
            icon: Icons.straighten,
            color: AppColors.gas,
            title: 'Commercial gas pipe sizing',
            subtitle:
                'IGEM/UP/2 simplified — diameter from length, demand and pressure drop.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GasPipeSizingScreen()),
            ),
          ),
          _Tile(
            icon: Icons.speed,
            color: AppColors.accent,
            title: 'Tightness test (IGEM/UP/1)',
            subtitle:
                'Procedure selector, allowable drop, leak rate, PASS / FAIL banner.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TightnessTestScreen()),
            ),
          ),
          _Tile(
            icon: Icons.air,
            color: AppColors.coldWater,
            title: 'Boiler room ventilation (BS 6644)',
            subtitle:
                'Low-level / high-level free area for open or balanced flue plant.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const BoilerRoomVentilationScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'Compliance & references'),
          _Tile(
            icon: Icons.warning_amber,
            color: const Color(0xFFD62828),
            title: 'Hazardous areas (IGEM/UP/16)',
            subtitle:
                'Zone 0/1/2 reference plus a catalogue of typical locations.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HazardousAreasScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'Simulations'),
          _Tile(
            icon: Icons.restaurant,
            color: AppColors.gas,
            title: 'Catering interlock (BS 6173)',
            subtitle:
                'Extract → pressure-proving → gas-pressure-proving → solenoid sequence.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CateringInterlockSimScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'Knowledge'),
          ...commercialGasLessonTopics.map((t) => _Tile(
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
          _SectionHeader(text: 'On-site checklists'),
          ...commercialGasChecklists.map((cl) => _Tile(
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
                    Text('ACS commercial gas',
                        style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'Commercial gas requires the ACS qualifications COCNGI1 (core), ICPN1 (installation pipework), CIGA1 (indirect-fired) and CDGA1 (direct-fired), plus TPCP1 for testing and purging. The standards here align with IGEM/UP/1, /2, /4, /10 and /16 plus BS 6644, BS 6173 and BS EN 1775. Use these tools as a study companion — final assessments must always be the relevant manufacturer / ACS document.',
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
          colors: [Color(0xFFB8860B), Color(0xFF8B4513)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.local_fire_department,
                color: Colors.white, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Commercial gas engineer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'IGEM/UP/1 • UP/2 • UP/16 • BS 6644 • BS 6173',
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

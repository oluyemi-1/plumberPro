import 'package:flutter/material.dart';

import '../data/heat_pump_checklists_data.dart';
import '../data/heat_pump_data.dart';
import '../data/heat_pump_lessons_data.dart';
import '../services/tts_service.dart';
import '../simulations/defrost_cycle_sim.dart';
import '../simulations/dhw_priority_sim.dart';
import '../simulations/heat_pump_sim.dart';
import '../simulations/hybrid_system_sim.dart';
import '../simulations/hydraulic_separation_sim.dart';
import '../simulations/weather_comp_tutor_sim.dart';
import '../theme.dart';
import 'checklists_screen.dart';
import 'emitter_sizing_screen.dart';
import 'g99_process_screen.dart';
import 'gshp_design_screen.dart';
import 'heat_loss_calculator_screen.dart';
import 'hp_cylinder_sizing_screen.dart';
import 'hp_fault_codes_screen.dart';
import 'lessons_screen.dart';
import 'mcs_sound_screen.dart';
import 'pas_2035_screen.dart';

/// One-stop hub for the heat pump installer training pack.
class HeatPumpHubScreen extends StatelessWidget {
  const HeatPumpHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heat pump installer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _Hero(
            onIntro: () => TtsService.instance.speak(
              'Welcome to the heat pump installer pack. The tools here let you complete a heat loss design, size the emitters, run an MCS twenty sound assessment, work through the F-gas refrigerant content and tick off the MCS commissioning checklists. This is the same workflow used on a real installation.',
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'Design tools'),
          _Tile(
            icon: Icons.thermostat,
            color: AppColors.primary,
            title: 'Heat loss calculator',
            subtitle:
                'Room-by-room fabric and ventilation losses, with HP capacity recommendation.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const HeatLossCalculatorScreen()),
            ),
          ),
          _Tile(
            icon: Icons.straighten,
            color: AppColors.accent,
            title: 'Emitter sizing helper',
            subtitle:
                'De-rate any radiator at the heat pump flow temperature, or find the rating you need.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmitterSizingScreen()),
            ),
          ),
          _Tile(
            icon: Icons.graphic_eq,
            color: AppColors.coldWater,
            title: 'MCS 020 sound assessment',
            subtitle:
                'Predict Lp at the neighbour from Lw, distance and reflection conditions.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const McsSoundScreen()),
            ),
          ),
          _Tile(
            icon: Icons.terrain,
            color: const Color(0xFF6B4226),
            title: 'GSHP collector design',
            subtitle:
                'Slinky vs vertical borehole sizing by soil type and HP capacity.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GshpDesignScreen()),
            ),
          ),
          _Tile(
            icon: Icons.water_drop,
            color: AppColors.hotWater,
            title: 'HP cylinder sizing',
            subtitle:
                'Coil area, recovery time and daily DHW energy from peak demand.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const HpCylinderSizingScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'Knowledge'),
          ...heatPumpLessonTopics.map((t) => _Tile(
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
          _RefrigerantsTile(),
          _Tile(
            icon: Icons.heat_pump,
            color: AppColors.accent,
            title: 'Refrigerant cycle simulation',
            subtitle:
                'Animated evaporator → compressor → condenser → expansion valve loop.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HeatPumpSimScreen()),
            ),
          ),
          _Tile(
            icon: Icons.architecture,
            color: const Color(0xFF386641),
            title: 'PAS 2035 retrofit pathway',
            subtitle:
                'Roles, stages, ventilation strategies and risk paths for the retrofit standard.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Pas2035Screen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'System operation deep dives'),
          _Tile(
            icon: Icons.merge_type,
            color: AppColors.primary,
            title: 'Hydraulic separation',
            subtitle:
                'Volumiser, low-loss header and buffer tank — when to use each.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const HydraulicSeparationSimScreen()),
            ),
          ),
          _Tile(
            icon: Icons.shower,
            color: AppColors.hotWater,
            title: 'DHW priority and Legionella',
            subtitle:
                'Diverter switching, recovery time, set-point lift and immersion overlay.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DhwPrioritySimScreen()),
            ),
          ),
          _Tile(
            icon: Icons.timeline,
            color: AppColors.accent,
            title: 'Weather compensation tutor',
            subtitle:
                'Drag the heating curve, watch room temp respond to outside temp.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const WeatherCompTutorSimScreen()),
            ),
          ),
          _Tile(
            icon: Icons.ac_unit,
            color: AppColors.coldWater,
            title: 'Defrost cycle',
            subtitle:
                'Frost build-up, 4-way valve reverse, recovery — under cold humid conditions.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DefrostCycleSimScreen()),
            ),
          ),
          _Tile(
            icon: Icons.compare_arrows,
            color: AppColors.gas,
            title: 'Hybrid system (HP + boiler)',
            subtitle:
                'Bivalent point, parallel vs alternate strategy, cost-optimised control.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HybridSystemSimScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'Compliance & fault-finding'),
          _Tile(
            icon: Icons.electrical_services,
            color: const Color(0xFF118AB2),
            title: 'G98 / G99 DNO process',
            subtitle:
                'Decision tree, application stages and witness testing for grid connection.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const G99ProcessScreen()),
            ),
          ),
          _Tile(
            icon: Icons.error_outline,
            color: AppColors.accent,
            title: 'Brand fault-code library',
            subtitle:
                'Vaillant, Daikin, Mitsubishi, Samsung and Grant — codes, causes and fixes.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HpFaultCodesScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(text: 'On-site checklists'),
          ...heatPumpChecklists.map((cl) => _Tile(
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
                    Text('Why this is here',
                        style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'Heat pumps are the fastest-growing UK plumbing skill and the BUS grant pays £7,500 toward an air-source install. This pack gives you the design tools, the safety knowledge and the commissioning rigour expected by MCS, so you can work toward MIS 3005 design competence.',
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
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.heat_pump, color: Colors.white, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Heat pump installer pack',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Design • emitter sizing • sound • F-gas • commissioning',
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

class _RefrigerantsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ExpansionTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.gas.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.science, color: AppColors.gas),
          ),
          title: const Text('Refrigerants — quick reference'),
          subtitle: const Text(
              'GWP, safety class, charge limits and field notes for the refrigerants you will meet.'),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          children: refrigerants.map((r) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(r.name,
                          style:
                              Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      _Tag(text: r.safetyClass),
                      const SizedBox(width: 6),
                      _Tag(text: 'GWP ${r.gwp}'),
                    ]),
                    const SizedBox(height: 4),
                    Text('Charge: ${r.charge}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(r.note,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: () => TtsService.instance.speak(
                        '${r.name}. Safety class ${r.safetyClass}. Global warming potential ${r.gwp}. Typical charge ${r.charge}. ${r.note}',
                      ),
                      icon: const Icon(Icons.volume_up, size: 18),
                      label: const Text('Speak'),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary)),
    );
  }
}

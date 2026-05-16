import 'package:flutter/material.dart';

import '../theme.dart';
import '../services/pro_entitlement.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../widgets/pro_lock_overlay.dart';
import '../simulations/cold_water_sim.dart';
import '../simulations/mains_entry_sim.dart';
import '../simulations/hot_water_vented_sim.dart';
import '../simulations/unvented_cylinder_sim.dart';
import '../simulations/secondary_circulation_sim.dart';
import '../simulations/solar_thermal_sim.dart';
import '../simulations/combi_boiler_sim.dart';
import '../simulations/boiler_cycle_sim.dart';
import '../simulations/electric_boiler_sim.dart';
import '../simulations/central_heating_sim.dart';
import '../simulations/y_plan_heating_sim.dart';
import '../simulations/underfloor_heating_sim.dart';
import '../simulations/weather_compensation_sim.dart';
import '../simulations/radiator_bleed_sim.dart';
import '../simulations/drainage_trap_sim.dart';
import '../simulations/rainwater_drainage_sim.dart';
import '../simulations/rainwater_harvesting_sim.dart';
import '../simulations/soakaway_sim.dart';
import '../simulations/pipe_joining_sim.dart';
import '../simulations/pipe_bending_sim.dart';
import '../simulations/pressure_test_sim.dart';
import '../simulations/water_hammer_sim.dart';
import '../simulations/boiler_fault_codes_sim.dart';
import '../simulations/frozen_condensate_sim.dart';
import '../simulations/kettling_descale_sim.dart';
import '../simulations/cold_radiator_diagnostic_sim.dart';
import '../simulations/pressure_loss_diagnostic_sim.dart';
import '../simulations/blocked_sink_sim.dart';
import '../simulations/blocked_wc_sim.dart';
import '../simulations/dripping_tap_sim.dart';
import '../simulations/no_hot_water_diag_sim.dart';
import '../simulations/running_wc_sim.dart';
import '../simulations/smelly_drain_sim.dart';
import '../simulations/hidden_leak_sim.dart';
import '../simulations/safe_isolation_sim.dart';
import '../simulations/heat_pump_sim.dart';
import '../simulations/solar_pv_sim.dart';
import '../simulations/mvhr_sim.dart';
import '../simulations/flue_types_sim.dart';
import '../simulations/combustion_analyser_sim.dart';
import '../simulations/lpg_oil_sim.dart';
import '../simulations/backflow_protection_sim.dart';
import '../simulations/fluid_categories_sim.dart';

class _SimEntry {
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color accent;
  final WidgetBuilder builder;

  const _SimEntry({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.accent,
    required this.builder,
  });
}

class SimulationsHubScreen extends StatefulWidget {
  const SimulationsHubScreen({super.key});

  @override
  State<SimulationsHubScreen> createState() => _SimulationsHubScreenState();
}

class _SimulationsHubScreenState extends State<SimulationsHubScreen> {
  String _category = 'All';

  static final List<_SimEntry> _all = [
    _SimEntry(
      title: 'Mains entry',
      subtitle:
          'From the public main, through the boundary stop and into the rising main.',
      category: 'Cold water',
      icon: Icons.fork_left,
      accent: AppColors.coldWater,
      builder: (_) => const MainsEntrySimScreen(),
    ),
    _SimEntry(
      title: 'Cold water system',
      subtitle:
          'Direct vs indirect distribution, stop valves, drain offs, backflow.',
      category: 'Cold water',
      icon: Icons.water_drop,
      accent: AppColors.coldWater,
      builder: (_) => const ColdWaterSimScreen(),
    ),
    _SimEntry(
      title: 'Vented hot water cylinder',
      subtitle:
          'Gravity feed, primary coil, stratification, vent pipe and immersion.',
      category: 'Hot water',
      icon: Icons.local_fire_department,
      accent: AppColors.hotWater,
      builder: (_) => const HotWaterVentedSimScreen(),
    ),
    _SimEntry(
      title: 'Unvented cylinder',
      subtitle:
          'PRV, expansion vessel, T&P relief, tundish — every safety device explained.',
      category: 'Hot water',
      icon: Icons.shield,
      accent: AppColors.hotWater,
      builder: (_) => const UnventedCylinderSimScreen(),
    ),
    _SimEntry(
      title: 'Secondary circulation',
      subtitle:
          'Hot water return loop, pump, timer, dead-leg control and Legionella.',
      category: 'Hot water',
      icon: Icons.loop,
      accent: AppColors.hotWater,
      builder: (_) => const SecondaryCirculationSimScreen(),
    ),
    _SimEntry(
      title: 'Solar thermal hot water',
      subtitle:
          'Twin-coil cylinder, glycol primary, differential controller and backup.',
      category: 'Hot water',
      icon: Icons.wb_sunny,
      accent: AppColors.gas,
      builder: (_) => const SolarThermalSimScreen(),
    ),
    _SimEntry(
      title: 'Combi boiler operation',
      subtitle: 'Diverter valve, plate exchanger, idle / heating / hot tap.',
      category: 'Boiler',
      icon: Icons.whatshot,
      accent: AppColors.gas,
      builder: (_) => const CombiBoilerSimScreen(),
    ),
    _SimEntry(
      title: 'Boiler firing cycle',
      subtitle:
          'Pre-purge, ignition, modulation, condensing and post-purge in detail.',
      category: 'Boiler',
      icon: Icons.device_thermostat,
      accent: AppColors.brass,
      builder: (_) => const BoilerCycleSimScreen(),
    ),
    _SimEntry(
      title: 'Electric boiler cycle',
      subtitle:
          'No flame, no flue — pump prove, element staging, overheat lockout.',
      category: 'Boiler',
      icon: Icons.electric_bolt,
      accent: AppColors.primary,
      builder: (_) => const ElectricBoilerSimScreen(),
    ),
    _SimEntry(
      title: 'S-plan central heating',
      subtitle: 'Two zone valves, radiators, cylinder coil, expansion control.',
      category: 'Heating',
      icon: Icons.heat_pump,
      accent: AppColors.primary,
      builder: (_) => const CentralHeatingSimScreen(),
    ),
    _SimEntry(
      title: 'Y-plan with mid-position valve',
      subtitle:
          'A single 3-port valve doing the work of two — heating, HW or both.',
      category: 'Heating',
      icon: Icons.alt_route,
      accent: AppColors.primary,
      builder: (_) => const YPlanHeatingSimScreen(),
    ),
    _SimEntry(
      title: 'Underfloor heating',
      subtitle: 'Manifold, blending unit, four loops, balancing and screed.',
      category: 'Heating',
      icon: Icons.dashboard,
      accent: AppColors.primary,
      builder: (_) => const UnderfloorHeatingSimScreen(),
    ),
    _SimEntry(
      title: 'Weather compensation',
      subtitle: 'Outside sensor, heat curve, modulating flow temperature.',
      category: 'Heating',
      icon: Icons.thermostat,
      accent: AppColors.primary,
      builder: (_) => const WeatherCompensationSimScreen(),
    ),
    _SimEntry(
      title: 'Bleeding a radiator',
      subtitle:
          'Step-by-step venting of trapped air with re-pressurisation.',
      category: 'Heating',
      icon: Icons.engineering,
      accent: AppColors.accent,
      builder: (_) => const RadiatorBleedSimScreen(),
    ),
    _SimEntry(
      title: 'Drainage and traps',
      subtitle:
          'P vs S traps, self- and induced-siphonage, AAV, soil stack venting.',
      category: 'Drainage',
      icon: Icons.plumbing,
      accent: AppColors.waste,
      builder: (_) => const DrainageTrapSimScreen(),
    ),
    _SimEntry(
      title: 'Rainwater drainage',
      subtitle:
          'Gutter, downpipe, gully, soakaway — sizing, falls and overflow faults.',
      category: 'Rainwater',
      icon: Icons.umbrella,
      accent: AppColors.coldWater,
      builder: (_) => const RainwaterDrainageSimScreen(),
    ),
    _SimEntry(
      title: 'Rainwater harvesting',
      subtitle:
          'First-flush, calmed inlet, pump, mains top-up via air gap.',
      category: 'Rainwater',
      icon: Icons.water,
      accent: AppColors.coldWater,
      builder: (_) => const RainwaterHarvestingSimScreen(),
    ),
    _SimEntry(
      title: 'Soakaway',
      subtitle:
          'BRE 365 test, sand vs clay soils, rubble vs crate construction.',
      category: 'Rainwater',
      icon: Icons.terrain,
      accent: AppColors.waste,
      builder: (_) => const SoakawaySimScreen(),
    ),
    _SimEntry(
      title: 'Pipe joining techniques',
      subtitle: 'Compression, push-fit and solder capillary side by side.',
      category: 'Process',
      icon: Icons.build,
      accent: AppColors.copper,
      builder: (_) => const PipeJoiningSimScreen(),
    ),
    _SimEntry(
      title: 'Pipe bending',
      subtitle: 'Spring vs machine bender, set-back and spring-back.',
      category: 'Process',
      icon: Icons.architecture,
      accent: AppColors.copper,
      builder: (_) => const PipeBendingSimScreen(),
    ),
    _SimEntry(
      title: 'Pressure testing',
      subtitle:
          'Hydrostatic test pump, hold time, acceptable drop, leak finding.',
      category: 'Process',
      icon: Icons.speed,
      accent: AppColors.accent,
      builder: (_) => const PressureTestSimScreen(),
    ),
    _SimEntry(
      title: 'Water hammer',
      subtitle:
          'Cause, effect and how an arrestor absorbs the surge.',
      category: 'Process',
      icon: Icons.bolt,
      accent: AppColors.accent,
      builder: (_) => const WaterHammerSimScreen(),
    ),
    _SimEntry(
      title: 'Boiler fault codes',
      subtitle:
          'F1, F7, F22, EA, A04, F28 — read the code, find the cause, reset.',
      category: 'Faults',
      icon: Icons.error_outline,
      accent: AppColors.accent,
      builder: (_) => const BoilerFaultCodesSimScreen(),
    ),
    _SimEntry(
      title: 'Frozen condensate pipe',
      subtitle:
          'Winter lockout — locate, thaw safely, prevent recurrence.',
      category: 'Faults',
      icon: Icons.ac_unit,
      accent: AppColors.coldWater,
      builder: (_) => const FrozenCondensateSimScreen(),
    ),
    _SimEntry(
      title: 'Kettling and descale',
      subtitle:
          'Limescale, noise and lost efficiency — descale or power flush.',
      category: 'Faults',
      icon: Icons.volume_up,
      accent: AppColors.gas,
      builder: (_) => const KettlingDescaleSimScreen(),
    ),
    _SimEntry(
      title: 'Cold radiator diagnosis',
      subtitle:
          'Six common causes — air, sludge, TRV, low pressure, lockshield, flow.',
      category: 'Faults',
      icon: Icons.thermostat_auto,
      accent: AppColors.hotWater,
      builder: (_) => const ColdRadiatorDiagnosticSimScreen(),
    ),
    _SimEntry(
      title: 'Pressure keeps dropping',
      subtitle:
          'Find a leak, a passing PRV or a failed expansion vessel.',
      category: 'Faults',
      icon: Icons.trending_down,
      accent: AppColors.accent,
      builder: (_) => const PressureLossDiagnosticSimScreen(),
    ),
    _SimEntry(
      title: 'No hot water (combi)',
      subtitle:
          'Diverter, flow turbine, plate exchanger and pressure faults.',
      category: 'Faults',
      icon: Icons.water_damage,
      accent: AppColors.hotWater,
      builder: (_) => const NoHotWaterDiagSimScreen(),
    ),
    _SimEntry(
      title: 'Blocked sink',
      subtitle:
          'Plunger, trap removal, drain rod and customer advice.',
      category: 'Faults',
      icon: Icons.kitchen,
      accent: AppColors.waste,
      builder: (_) => const BlockedSinkSimScreen(),
    ),
    _SimEntry(
      title: 'Blocked WC',
      subtitle:
          'WC plunger, auger, bucket pour, lift-pan as last resort.',
      category: 'Faults',
      icon: Icons.wc,
      accent: AppColors.waste,
      builder: (_) => const BlockedWcSimScreen(),
    ),
    _SimEntry(
      title: 'Running WC cistern',
      subtitle:
          'Float valve vs flush diaphragm, dye test, set the level right.',
      category: 'Faults',
      icon: Icons.water,
      accent: AppColors.coldWater,
      builder: (_) => const RunningWcSimScreen(),
    ),
    _SimEntry(
      title: 'Dripping tap',
      subtitle:
          'Compression washer or ceramic cartridge — strip and replace.',
      category: 'Faults',
      icon: Icons.opacity,
      accent: AppColors.coldWater,
      builder: (_) => const DrippingTapSimScreen(),
    ),
    _SimEntry(
      title: 'Smelly drains',
      subtitle:
          'Dried trap, failed AAV, missing vent or cracked joint.',
      category: 'Faults',
      icon: Icons.air,
      accent: AppColors.waste,
      builder: (_) => const SmellyDrainSimScreen(),
    ),
    _SimEntry(
      title: 'Hidden leak detection',
      subtitle:
          'Meter test, acoustic, thermal, dye and section pressure tests.',
      category: 'Faults',
      icon: Icons.search,
      accent: AppColors.accent,
      builder: (_) => const HiddenLeakSimScreen(),
    ),
    _SimEntry(
      title: 'Safe isolation procedure',
      subtitle:
          'The seven recognised steps to prove a circuit dead before working.',
      category: 'Electrical',
      icon: Icons.power_off,
      accent: AppColors.gas,
      builder: (_) => const SafeIsolationSimScreen(),
    ),
    _SimEntry(
      title: 'Air-source heat pump cycle',
      subtitle:
          'Refrigerant cycle, COP, low-flow-temperature emitter design.',
      category: 'Renewables',
      icon: Icons.heat_pump,
      accent: AppColors.accent,
      builder: (_) => const HeatPumpSimScreen(),
    ),
    _SimEntry(
      title: 'Solar photovoltaic',
      subtitle: 'DC strings, inverter, diversion, battery and grid export.',
      category: 'Renewables',
      icon: Icons.solar_power,
      accent: AppColors.gas,
      builder: (_) => const SolarPvSimScreen(),
    ),
    _SimEntry(
      title: 'MVHR — Mechanical ventilation with heat recovery',
      subtitle:
          'Counter-flow exchanger, ducting, filters and commissioning.',
      category: 'Renewables',
      icon: Icons.air,
      accent: AppColors.coldWater,
      builder: (_) => const MvhrSimScreen(),
    ),
    _SimEntry(
      title: 'Flue types comparison',
      subtitle: 'Open, balanced (room-sealed) and fan-assisted, side by side.',
      category: 'Fuels',
      icon: Icons.local_fire_department,
      accent: AppColors.gas,
      builder: (_) => const FlueTypesSimScreen(),
    ),
    _SimEntry(
      title: 'Combustion analyser readings',
      subtitle:
          'CO2, O2, CO/CO2 ratio — healthy, lean, rich and faulty modes.',
      category: 'Fuels',
      icon: Icons.science,
      accent: AppColors.gas,
      builder: (_) => const CombustionAnalyserSimScreen(),
    ),
    _SimEntry(
      title: 'LPG and oil installations',
      subtitle:
          'Bulk LPG vapour offtake, oil tank bunding and the fire valve.',
      category: 'Fuels',
      icon: Icons.propane_tank,
      accent: AppColors.gas,
      builder: (_) => const LpgOilSimScreen(),
    ),
    _SimEntry(
      title: 'Backflow protection devices',
      subtitle:
          'Air gaps, check valves and RPZ — pick the right device for the job.',
      category: 'Backflow',
      icon: Icons.shield,
      accent: AppColors.coldWater,
      builder: (_) => const BackflowProtectionSimScreen(),
    ),
    _SimEntry(
      title: 'Fluid categories quiz-walk',
      subtitle:
          'Tap fittings around the home and identify their fluid category.',
      category: 'Backflow',
      icon: Icons.water_drop,
      accent: AppColors.coldWater,
      builder: (_) => const FluidCategoriesSimScreen(),
    ),
  ];

  List<String> get _categories {
    final s = <String>{'All'};
    for (final e in _all) {
      s.add(e.category);
    }
    return s.toList();
  }

  List<_SimEntry> get _filtered {
    if (_category == 'All') return _all;
    return _all.where((e) => e.category == _category).toList();
  }

  void _open(BuildContext context, _SimEntry entry) {
    TtsService.instance.speak(entry.title);
    final id = 'sim:${entry.title.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), "_")}';
    ProgressService.instance.markVisited(id);
    Navigator.of(context).push(MaterialPageRoute(builder: entry.builder));
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filtered;
    final freeEntries = _all.take(ProEntitlement.freeLimit).toSet();
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        title: const Text('Practical simulations'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: ProEntitlement.instance,
        builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final cross = w >= 1100 ? 3 : (w >= 720 ? 2 : 1);
          return Column(
            children: [
              SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final c = _categories[i];
                    return ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: Row(
                  children: [
                    Text(
                      '${entries.length} simulation${entries.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GridView.builder(
                    itemCount: entries.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: cross == 1 ? 2.6 : 1.55,
                    ),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final locked = !ProEntitlement.instance.isPro &&
                          !freeEntries.contains(entry);
                      return ProLockOverlay(
                        locked: locked,
                        child: _SimCard(
                          entry: entry,
                          onTap: () => _open(context, entry),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}

class _SimCard extends StatelessWidget {
  final _SimEntry entry;
  final VoidCallback onTap;

  const _SimCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: entry.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: entry.accent.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                child: Icon(entry.icon, color: entry.accent, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CategoryBadge(
                          label: entry.category,
                          color: entry.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

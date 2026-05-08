import 'package:flutter/material.dart';

import '../theme.dart';

// Data sources.
import 'lessons_data.dart';
import 'electrical_lessons_data.dart';
import 'renewables_lessons_data.dart';
import 'fuels_lessons_data.dart';
import 'backflow_lessons_data.dart';
import 'heat_pump_lessons_data.dart';
import 'commercial_lessons_data.dart';
import 'commercial_gas_lessons_data.dart';
import 'lpg_oil_lessons_data.dart';
import 'medical_gases_lessons_data.dart';
import 'sprinklers_lessons_data.dart';

import 'quiz_data.dart';
import 'electrical_quiz_data.dart';
import 'renewables_quiz_data.dart';
import 'fuels_quiz_data.dart';
import 'backflow_quiz_data.dart';
import 'commercial_quiz_data.dart';
import 'commercial_gas_quiz_data.dart';
import 'lpg_oil_quiz_data.dart';
import 'medical_gases_quiz_data.dart';
import 'sprinklers_quiz_data.dart';

import 'scenarios_data.dart';

import 'checklists_data.dart';
import 'commercial_checklists_data.dart';
import 'commercial_gas_checklists_data.dart';
import 'heat_pump_checklists_data.dart';
import 'lpg_oil_checklists_data.dart';
import 'medical_gases_checklists_data.dart';
import 'sprinklers_checklists_data.dart';

import 'glossary_data.dart';
import 'regulations_data.dart';
import 'troubleshooting_data.dart';
import 'explainers_data.dart';
import 'tools_data.dart';

// Detail and list screens.
import '../screens/lessons_screen.dart';
import '../screens/quiz_session_screen.dart';
import '../screens/scenario_session_screen.dart';
import '../screens/checklists_screen.dart';
import '../screens/glossary_screen.dart';
import '../screens/regulations_screen.dart';
import '../screens/troubleshooter_screen.dart';
import '../screens/customer_explainers_screen.dart';
import '../screens/tools_encyclopedia_screen.dart';

// Hub screens.
import '../screens/heat_pump_hub_screen.dart';
import '../screens/commercial_hub_screen.dart';
import '../screens/commercial_gas_hub_screen.dart';
import '../screens/lpg_oil_hub_screen.dart';
import '../screens/medical_gases_hub_screen.dart';
import '../screens/sprinklers_hub_screen.dart';
import '../screens/careers_screen.dart';
import '../screens/synoptic_screen.dart';
import '../screens/calculators_screen.dart';
import '../screens/conversions_screen.dart';
import '../screens/pas_2035_screen.dart';
import '../screens/g99_process_screen.dart';
import '../screens/hp_fault_codes_screen.dart';

// Simulations.
import '../simulations/cold_water_sim.dart';
import '../simulations/mains_entry_sim.dart';
import '../simulations/hot_water_vented_sim.dart';
import '../simulations/unvented_cylinder_sim.dart';
import '../simulations/secondary_circulation_sim.dart';
import '../simulations/solar_thermal_sim.dart';
import '../simulations/combi_boiler_sim.dart';
import '../simulations/boiler_cycle_sim.dart';
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
import '../simulations/hydraulic_separation_sim.dart';
import '../simulations/dhw_priority_sim.dart';
import '../simulations/weather_comp_tutor_sim.dart';
import '../simulations/defrost_cycle_sim.dart';
import '../simulations/cascade_boiler_sim.dart';
import '../simulations/catering_interlock_sim.dart';
import '../simulations/avsu_sim.dart';
import '../simulations/sprinkler_activation_sim.dart';
import '../simulations/hybrid_system_sim.dart';

/// A single searchable, bookmarkable entry surfaced by the global search and
/// bookmarks screens. Each entry knows how to navigate to its own detail view
/// via [builder].
class SearchEntry {
  /// Globally unique id, e.g. `lesson:cold_water_basics`.
  final String id;

  /// Human readable type label, e.g. `Lesson`, `Quiz`, `Simulation`,
  /// `Scenario`, `Checklist`, `Glossary`, `Regulation`, `Troubleshooter`,
  /// `Customer explainer`, `Tool`, `Hub`, `Calculator`.
  final String type;

  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;

  const SearchEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
    required this.builder,
  });

  /// Whether this entry's title, subtitle, category or type
  /// (case-insensitive) contains [q]. An empty query matches everything.
  bool matches(String q) {
    if (q.isEmpty) return true;
    final lq = q.toLowerCase();
    return title.toLowerCase().contains(lq) ||
        subtitle.toLowerCase().contains(lq) ||
        category.toLowerCase().contains(lq) ||
        type.toLowerCase().contains(lq);
  }
}

// ─── Per-type colour and icon defaults ──────────────────────────────────────

const _lessonIcon = Icons.menu_book;
const _quizIcon = Icons.quiz;
const _scenarioIcon = Icons.assignment_ind;
const _checklistIcon = Icons.checklist;
const _glossaryIcon = Icons.menu_book_outlined;
const _regIcon = Icons.gavel;
const _troubleIcon = Icons.troubleshoot;
const _explainerIcon = Icons.record_voice_over;

const _lessonColor = Color(0xFF2A9D8F);
const _quizColor = AppColors.primary;
const _scenarioColor = AppColors.primaryDark;
const _checklistColor = AppColors.primary;
const _glossaryColor = AppColors.muted;
const _regColor = AppColors.brass;
const _troubleColor = AppColors.accent;
const _explainerColor = AppColors.hotWater;
const _toolColor = AppColors.copper;

/// One small data class used only inside this file to declare the simulations
/// table compactly.
class _SimDef {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
  const _SimDef(this.id, this.title, this.subtitle, this.category, this.icon,
      this.color, this.builder);
}

const List<_SimDef> _sims = <_SimDef>[
  _SimDef(
    'mains_entry',
    'Mains entry',
    'From the public main, through the boundary stop and into the rising main.',
    'Cold water',
    Icons.fork_left,
    AppColors.coldWater,
    _bMainsEntry,
  ),
  _SimDef(
    'cold_water',
    'Cold water system',
    'Direct vs indirect distribution, stop valves, drain offs, backflow.',
    'Cold water',
    Icons.water_drop,
    AppColors.coldWater,
    _bColdWater,
  ),
  _SimDef(
    'hot_water_vented',
    'Vented hot water cylinder',
    'Gravity feed, primary coil, stratification, vent pipe and immersion.',
    'Hot water',
    Icons.local_fire_department,
    AppColors.hotWater,
    _bHotWaterVented,
  ),
  _SimDef(
    'unvented_cylinder',
    'Unvented cylinder',
    'PRV, expansion vessel, T&P relief, tundish — every safety device explained.',
    'Hot water',
    Icons.shield,
    AppColors.hotWater,
    _bUnvented,
  ),
  _SimDef(
    'secondary_circulation',
    'Secondary circulation',
    'Hot water return loop, pump, timer, dead-leg control and Legionella.',
    'Hot water',
    Icons.loop,
    AppColors.hotWater,
    _bSecondary,
  ),
  _SimDef(
    'solar_thermal',
    'Solar thermal hot water',
    'Twin-coil cylinder, glycol primary, differential controller and backup.',
    'Hot water',
    Icons.wb_sunny,
    AppColors.gas,
    _bSolarThermal,
  ),
  _SimDef(
    'combi_boiler',
    'Combi boiler operation',
    'Diverter valve, plate exchanger, idle / heating / hot tap.',
    'Boiler',
    Icons.whatshot,
    AppColors.gas,
    _bCombi,
  ),
  _SimDef(
    'boiler_cycle',
    'Boiler firing cycle',
    'Pre-purge, ignition, modulation, condensing and post-purge in detail.',
    'Boiler',
    Icons.device_thermostat,
    AppColors.brass,
    _bBoilerCycle,
  ),
  _SimDef(
    'central_heating',
    'S-plan central heating',
    'Two zone valves, radiators, cylinder coil, expansion control.',
    'Heating',
    Icons.heat_pump,
    AppColors.primary,
    _bCentralHeating,
  ),
  _SimDef(
    'y_plan_heating',
    'Y-plan with mid-position valve',
    'A single 3-port valve doing the work of two — heating, HW or both.',
    'Heating',
    Icons.alt_route,
    AppColors.primary,
    _bYPlan,
  ),
  _SimDef(
    'underfloor_heating',
    'Underfloor heating',
    'Manifold, blending unit, four loops, balancing and screed.',
    'Heating',
    Icons.dashboard,
    AppColors.primary,
    _bUnderfloor,
  ),
  _SimDef(
    'weather_compensation',
    'Weather compensation',
    'Outside sensor, heat curve, modulating flow temperature.',
    'Heating',
    Icons.thermostat,
    AppColors.primary,
    _bWeatherComp,
  ),
  _SimDef(
    'radiator_bleed',
    'Bleeding a radiator',
    'Step-by-step venting of trapped air with re-pressurisation.',
    'Heating',
    Icons.engineering,
    AppColors.accent,
    _bRadBleed,
  ),
  _SimDef(
    'drainage_trap',
    'Drainage and traps',
    'P vs S traps, self- and induced-siphonage, AAV, soil stack venting.',
    'Drainage',
    Icons.plumbing,
    AppColors.waste,
    _bDrainTrap,
  ),
  _SimDef(
    'rainwater_drainage',
    'Rainwater drainage',
    'Gutter, downpipe, gully, soakaway — sizing, falls and overflow faults.',
    'Rainwater',
    Icons.umbrella,
    AppColors.coldWater,
    _bRainDrain,
  ),
  _SimDef(
    'rainwater_harvesting',
    'Rainwater harvesting',
    'First-flush, calmed inlet, pump, mains top-up via air gap.',
    'Rainwater',
    Icons.water,
    AppColors.coldWater,
    _bRainHarvest,
  ),
  _SimDef(
    'soakaway',
    'Soakaway',
    'BRE 365 test, sand vs clay soils, rubble vs crate construction.',
    'Rainwater',
    Icons.terrain,
    AppColors.waste,
    _bSoakaway,
  ),
  _SimDef(
    'pipe_joining',
    'Pipe joining techniques',
    'Compression, push-fit and solder capillary side by side.',
    'Process',
    Icons.build,
    AppColors.copper,
    _bPipeJoin,
  ),
  _SimDef(
    'pipe_bending',
    'Pipe bending',
    'Spring vs machine bender, set-back and spring-back.',
    'Process',
    Icons.architecture,
    AppColors.copper,
    _bPipeBend,
  ),
  _SimDef(
    'pressure_test',
    'Pressure testing',
    'Hydrostatic test pump, hold time, acceptable drop, leak finding.',
    'Process',
    Icons.speed,
    AppColors.accent,
    _bPressureTest,
  ),
  _SimDef(
    'water_hammer',
    'Water hammer',
    'Cause, effect and how an arrestor absorbs the surge.',
    'Process',
    Icons.bolt,
    AppColors.accent,
    _bWaterHammer,
  ),
  _SimDef(
    'boiler_fault_codes',
    'Boiler fault codes',
    'F1, F7, F22, EA, A04, F28 — read the code, find the cause, reset.',
    'Faults',
    Icons.error_outline,
    AppColors.accent,
    _bBoilerFault,
  ),
  _SimDef(
    'frozen_condensate',
    'Frozen condensate pipe',
    'Winter lockout — locate, thaw safely, prevent recurrence.',
    'Faults',
    Icons.ac_unit,
    AppColors.coldWater,
    _bFrozenCond,
  ),
  _SimDef(
    'kettling_descale',
    'Kettling and descale',
    'Limescale, noise and lost efficiency — descale or power flush.',
    'Faults',
    Icons.volume_up,
    AppColors.gas,
    _bKettling,
  ),
  _SimDef(
    'cold_radiator_diagnostic',
    'Cold radiator diagnosis',
    'Six common causes — air, sludge, TRV, low pressure, lockshield, flow.',
    'Faults',
    Icons.thermostat_auto,
    AppColors.hotWater,
    _bColdRad,
  ),
  _SimDef(
    'pressure_loss_diagnostic',
    'Pressure keeps dropping',
    'Find a leak, a passing PRV or a failed expansion vessel.',
    'Faults',
    Icons.trending_down,
    AppColors.accent,
    _bPressureLoss,
  ),
  _SimDef(
    'no_hot_water',
    'No hot water (combi)',
    'Diverter, flow turbine, plate exchanger and pressure faults.',
    'Faults',
    Icons.water_damage,
    AppColors.hotWater,
    _bNoHotWater,
  ),
  _SimDef(
    'blocked_sink',
    'Blocked sink',
    'Plunger, trap removal, drain rod and customer advice.',
    'Faults',
    Icons.kitchen,
    AppColors.waste,
    _bBlockedSink,
  ),
  _SimDef(
    'blocked_wc',
    'Blocked WC',
    'WC plunger, auger, bucket pour, lift-pan as last resort.',
    'Faults',
    Icons.wc,
    AppColors.waste,
    _bBlockedWc,
  ),
  _SimDef(
    'running_wc',
    'Running WC cistern',
    'Float valve vs flush diaphragm, dye test, set the level right.',
    'Faults',
    Icons.water,
    AppColors.coldWater,
    _bRunningWc,
  ),
  _SimDef(
    'dripping_tap',
    'Dripping tap',
    'Compression washer or ceramic cartridge — strip and replace.',
    'Faults',
    Icons.opacity,
    AppColors.coldWater,
    _bDrippingTap,
  ),
  _SimDef(
    'smelly_drain',
    'Smelly drains',
    'Dried trap, failed AAV, missing vent or cracked joint.',
    'Faults',
    Icons.air,
    AppColors.waste,
    _bSmellyDrain,
  ),
  _SimDef(
    'hidden_leak',
    'Hidden leak detection',
    'Meter test, acoustic, thermal, dye and section pressure tests.',
    'Faults',
    Icons.search,
    AppColors.accent,
    _bHiddenLeak,
  ),
  _SimDef(
    'safe_isolation',
    'Safe isolation procedure',
    'The seven recognised steps to prove a circuit dead before working.',
    'Electrical',
    Icons.power_off,
    AppColors.gas,
    _bSafeIso,
  ),
  _SimDef(
    'heat_pump',
    'Air-source heat pump cycle',
    'Refrigerant cycle, COP, low-flow-temperature emitter design.',
    'Renewables',
    Icons.heat_pump,
    AppColors.accent,
    _bHeatPump,
  ),
  _SimDef(
    'solar_pv',
    'Solar photovoltaic',
    'DC strings, inverter, diversion, battery and grid export.',
    'Renewables',
    Icons.solar_power,
    AppColors.gas,
    _bSolarPv,
  ),
  _SimDef(
    'mvhr',
    'MVHR — Mechanical ventilation with heat recovery',
    'Counter-flow exchanger, ducting, filters and commissioning.',
    'Renewables',
    Icons.air,
    AppColors.coldWater,
    _bMvhr,
  ),
  _SimDef(
    'flue_types',
    'Flue types comparison',
    'Open, balanced (room-sealed) and fan-assisted, side by side.',
    'Fuels',
    Icons.local_fire_department,
    AppColors.gas,
    _bFlueTypes,
  ),
  _SimDef(
    'combustion_analyser',
    'Combustion analyser readings',
    'CO2, O2, CO/CO2 ratio — healthy, lean, rich and faulty modes.',
    'Fuels',
    Icons.science,
    AppColors.gas,
    _bCombustion,
  ),
  _SimDef(
    'lpg_oil',
    'LPG and oil installations',
    'Bulk LPG vapour offtake, oil tank bunding and the fire valve.',
    'Fuels',
    Icons.propane_tank,
    AppColors.gas,
    _bLpgOil,
  ),
  _SimDef(
    'backflow_protection',
    'Backflow protection devices',
    'Air gaps, check valves and RPZ — pick the right device for the job.',
    'Backflow',
    Icons.shield,
    AppColors.coldWater,
    _bBackflow,
  ),
  _SimDef(
    'fluid_categories',
    'Fluid categories quiz-walk',
    'Tap fittings around the home and identify their fluid category.',
    'Backflow',
    Icons.water_drop,
    AppColors.coldWater,
    _bFluidCats,
  ),
  _SimDef(
    'hydraulic_separation',
    'Hydraulic separation',
    'Low-loss header and buffer tank — keep primary and secondary loops apart.',
    'Heating',
    Icons.alt_route,
    AppColors.primary,
    _bHydSep,
  ),
  _SimDef(
    'dhw_priority',
    'DHW priority on heat pumps',
    'How a heat pump pauses heating to lift the cylinder coil temperature.',
    'Renewables',
    Icons.priority_high,
    AppColors.accent,
    _bDhwPri,
  ),
  _SimDef(
    'weather_comp_tutor',
    'Weather compensation tutor',
    'Tune the heat curve and watch flow temperature track the weather.',
    'Heating',
    Icons.tune,
    AppColors.primary,
    _bWeatherTutor,
  ),
  _SimDef(
    'defrost_cycle',
    'Heat pump defrost cycle',
    'Reverse cycle, frost build-up and the brief drop in delivered heat.',
    'Renewables',
    Icons.ac_unit,
    AppColors.coldWater,
    _bDefrost,
  ),
  _SimDef(
    'cascade_boiler',
    'Commercial cascade boilers',
    'Sequencing, lead/lag rotation and modulation across multiple boilers.',
    'Commercial',
    Icons.view_module,
    AppColors.gas,
    _bCascade,
  ),
  _SimDef(
    'catering_interlock',
    'Catering gas interlock',
    'Extract proving, gas solenoid and emergency knock-off in a kitchen.',
    'Commercial',
    Icons.restaurant,
    AppColors.gas,
    _bCatering,
  ),
  _SimDef(
    'avsu',
    'AVSU — area valve service unit',
    'Medical gas isolation, alarm and emergency shut-off behaviour.',
    'Medical gases',
    Icons.medical_services,
    AppColors.hotWater,
    _bAvsu,
  ),
  _SimDef(
    'sprinkler_activation',
    'Sprinkler head activation',
    'Glass bulb burst, water release and the three coverage patterns.',
    'Sprinklers',
    Icons.water_drop,
    AppColors.accent,
    _bSprinkler,
  ),
  _SimDef(
    'hybrid_system',
    'Hybrid heat pump + boiler',
    'Bivalent point, smart switching and balancing carbon vs cost.',
    'Renewables',
    Icons.compare_arrows,
    AppColors.primary,
    _bHybrid,
  ),
];

// Top-level constant builders (each must be a const tear-off target so the
// _SimDef list above can stay const — Dart only allows const closures via
// top-level functions referenced as tear-offs).
Widget _bMainsEntry(BuildContext _) => const MainsEntrySimScreen();
Widget _bColdWater(BuildContext _) => const ColdWaterSimScreen();
Widget _bHotWaterVented(BuildContext _) => const HotWaterVentedSimScreen();
Widget _bUnvented(BuildContext _) => const UnventedCylinderSimScreen();
Widget _bSecondary(BuildContext _) => const SecondaryCirculationSimScreen();
Widget _bSolarThermal(BuildContext _) => const SolarThermalSimScreen();
Widget _bCombi(BuildContext _) => const CombiBoilerSimScreen();
Widget _bBoilerCycle(BuildContext _) => const BoilerCycleSimScreen();
Widget _bCentralHeating(BuildContext _) => const CentralHeatingSimScreen();
Widget _bYPlan(BuildContext _) => const YPlanHeatingSimScreen();
Widget _bUnderfloor(BuildContext _) => const UnderfloorHeatingSimScreen();
Widget _bWeatherComp(BuildContext _) => const WeatherCompensationSimScreen();
Widget _bRadBleed(BuildContext _) => const RadiatorBleedSimScreen();
Widget _bDrainTrap(BuildContext _) => const DrainageTrapSimScreen();
Widget _bRainDrain(BuildContext _) => const RainwaterDrainageSimScreen();
Widget _bRainHarvest(BuildContext _) => const RainwaterHarvestingSimScreen();
Widget _bSoakaway(BuildContext _) => const SoakawaySimScreen();
Widget _bPipeJoin(BuildContext _) => const PipeJoiningSimScreen();
Widget _bPipeBend(BuildContext _) => const PipeBendingSimScreen();
Widget _bPressureTest(BuildContext _) => const PressureTestSimScreen();
Widget _bWaterHammer(BuildContext _) => const WaterHammerSimScreen();
Widget _bBoilerFault(BuildContext _) => const BoilerFaultCodesSimScreen();
Widget _bFrozenCond(BuildContext _) => const FrozenCondensateSimScreen();
Widget _bKettling(BuildContext _) => const KettlingDescaleSimScreen();
Widget _bColdRad(BuildContext _) => const ColdRadiatorDiagnosticSimScreen();
Widget _bPressureLoss(BuildContext _) => const PressureLossDiagnosticSimScreen();
Widget _bNoHotWater(BuildContext _) => const NoHotWaterDiagSimScreen();
Widget _bBlockedSink(BuildContext _) => const BlockedSinkSimScreen();
Widget _bBlockedWc(BuildContext _) => const BlockedWcSimScreen();
Widget _bRunningWc(BuildContext _) => const RunningWcSimScreen();
Widget _bDrippingTap(BuildContext _) => const DrippingTapSimScreen();
Widget _bSmellyDrain(BuildContext _) => const SmellyDrainSimScreen();
Widget _bHiddenLeak(BuildContext _) => const HiddenLeakSimScreen();
Widget _bSafeIso(BuildContext _) => const SafeIsolationSimScreen();
Widget _bHeatPump(BuildContext _) => const HeatPumpSimScreen();
Widget _bSolarPv(BuildContext _) => const SolarPvSimScreen();
Widget _bMvhr(BuildContext _) => const MvhrSimScreen();
Widget _bFlueTypes(BuildContext _) => const FlueTypesSimScreen();
Widget _bCombustion(BuildContext _) => const CombustionAnalyserSimScreen();
Widget _bLpgOil(BuildContext _) => const LpgOilSimScreen();
Widget _bBackflow(BuildContext _) => const BackflowProtectionSimScreen();
Widget _bFluidCats(BuildContext _) => const FluidCategoriesSimScreen();
Widget _bHydSep(BuildContext _) => const HydraulicSeparationSimScreen();
Widget _bDhwPri(BuildContext _) => const DhwPrioritySimScreen();
Widget _bWeatherTutor(BuildContext _) => const WeatherCompTutorSimScreen();
Widget _bDefrost(BuildContext _) => const DefrostCycleSimScreen();
Widget _bCascade(BuildContext _) => const CascadeBoilerSimScreen();
Widget _bCatering(BuildContext _) => const CateringInterlockSimScreen();
Widget _bAvsu(BuildContext _) => const AvsuSimScreen();
Widget _bSprinkler(BuildContext _) => const SprinklerActivationSimScreen();
Widget _bHybrid(BuildContext _) => const HybridSystemSimScreen();

// ─── Hub / top-level definitions ────────────────────────────────────────────

class _HubDef {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
  final String type;
  const _HubDef(this.id, this.title, this.subtitle, this.category, this.icon,
      this.color, this.builder,
      {this.type = 'Hub'});
}

Widget _bHeatPumpHub(BuildContext _) => const HeatPumpHubScreen();
Widget _bCommercialHub(BuildContext _) => const CommercialHubScreen();
Widget _bCommercialGasHub(BuildContext _) => const CommercialGasHubScreen();
Widget _bLpgOilHub(BuildContext _) => const LpgOilHubScreen();
Widget _bMedicalGasesHub(BuildContext _) => const MedicalGasesHubScreen();
Widget _bSprinklersHub(BuildContext _) => const SprinklersHubScreen();
Widget _bCareers(BuildContext _) => const CareersScreen();
Widget _bSynoptic(BuildContext _) => const SynopticScreen();
Widget _bCalculators(BuildContext _) => const CalculatorsScreen();
Widget _bConversions(BuildContext _) => const ConversionsScreen();
Widget _bPas2035(BuildContext _) => const Pas2035Screen();
Widget _bG99(BuildContext _) => const G99ProcessScreen();
Widget _bHpFault(BuildContext _) => const HpFaultCodesScreen();

const List<_HubDef> _hubs = <_HubDef>[
  _HubDef(
    'heat_pump',
    'Heat pump installer',
    'Lessons, sizing, fault codes and checklists for ASHP and GSHP work.',
    'Heat pumps',
    Icons.heat_pump,
    AppColors.accent,
    _bHeatPumpHub,
  ),
  _HubDef(
    'commercial',
    'Commercial plumbing engineer',
    'Booster sets, calorifiers, L8 risk and large-bore pipework.',
    'Commercial',
    Icons.business,
    AppColors.primaryDark,
    _bCommercialHub,
  ),
  _HubDef(
    'commercial_gas',
    'Commercial gas engineer',
    'Cascade boilers, gas pipe sizing, tightness testing and ventilation.',
    'Commercial gas',
    Icons.local_fire_department,
    AppColors.gas,
    _bCommercialGasHub,
  ),
  _HubDef(
    'lpg_oil',
    'LPG and oil specialist',
    'Bulk LPG vapour offtake, oil tanks, bunding and fire valves.',
    'LPG and oil',
    Icons.propane_tank,
    AppColors.gas,
    _bLpgOilHub,
  ),
  _HubDef(
    'medical_gases',
    'Medical gas pipelines',
    'AVSU, BS 1710 colour codes and HTM 02-01 requirements.',
    'Medical gases',
    Icons.medical_services,
    AppColors.hotWater,
    _bMedicalGasesHub,
  ),
  _HubDef(
    'sprinklers',
    'Fire sprinkler systems',
    'BS 9251 design, head selection and commissioning.',
    'Sprinklers',
    Icons.water_drop,
    AppColors.accent,
    _bSprinklersHub,
  ),
  _HubDef(
    'careers',
    'Career pathway',
    'Apprentice to engineer — qualifications, day rates and progression.',
    'Career',
    Icons.school,
    AppColors.primary,
    _bCareers,
  ),
  _HubDef(
    'synoptic',
    'Synoptic mock assessment',
    'End-of-course practical-style assessment with timed tasks.',
    'Assessment',
    Icons.fact_check,
    AppColors.primaryDark,
    _bSynoptic,
  ),
  _HubDef(
    'calculators',
    'Calculators',
    'Heat loss, emitter sizing, cylinder sizing, pipe sizing and more.',
    'Tools',
    Icons.calculate,
    AppColors.primary,
    _bCalculators,
    type: 'Calculator',
  ),
  _HubDef(
    'conversions',
    'Unit conversions',
    'Pressure, flow rate, length, energy and temperature conversions.',
    'Tools',
    Icons.swap_horiz,
    AppColors.primary,
    _bConversions,
    type: 'Calculator',
  ),
  _HubDef(
    'pas_2035',
    'PAS 2035 retrofit',
    'Whole-house retrofit standard, roles and the assessment workflow.',
    'Retrofit',
    Icons.home_work,
    AppColors.brass,
    _bPas2035,
  ),
  _HubDef(
    'g99_process',
    'G98 / G99 process',
    'Grid connection notification thresholds and timelines for inverters.',
    'Renewables',
    Icons.electrical_services,
    AppColors.gas,
    _bG99,
  ),
  _HubDef(
    'hp_fault_codes',
    'Heat pump fault codes',
    'Common ASHP fault codes by manufacturer with likely causes and fixes.',
    'Heat pumps',
    Icons.error_outline,
    AppColors.accent,
    _bHpFault,
  ),
];

// ─── Build the index ────────────────────────────────────────────────────────

/// All searchable / bookmarkable content in the app.
///
/// Called once per screen build — keep it cheap. Each [SearchEntry.builder]
/// pushes the appropriate detail or list screen.
List<SearchEntry> buildContentIndex() {
  final out = <SearchEntry>[];

  // ── Lessons ──────────────────────────────────────────────────────────────
  void addLessons(List<LessonTopic> list) {
    for (final t in list) {
      out.add(SearchEntry(
        id: 'lesson:${t.id}',
        type: 'Lesson',
        title: t.title,
        subtitle: t.summary,
        category: t.category,
        icon: _lessonIcon,
        color: _lessonColor,
        builder: (_) => LessonDetailScreen(topic: t),
      ));
    }
  }

  addLessons(lessonTopics);
  addLessons(electricalLessonTopics);
  addLessons(renewablesLessonTopics);
  addLessons(fuelsLessonTopics);
  addLessons(backflowLessonTopics);
  addLessons(heatPumpLessonTopics);
  addLessons(commercialLessonTopics);
  addLessons(commercialGasLessonTopics);
  addLessons(lpgOilLessonTopics);
  addLessons(medicalGasesLessonTopics);
  addLessons(sprinklersLessonTopics);

  // ── Quizzes ──────────────────────────────────────────────────────────────
  void addQuizzes(List<QuizTopic> list) {
    for (final t in list) {
      out.add(SearchEntry(
        id: 'quiz:${t.id}',
        type: 'Quiz',
        title: t.title,
        subtitle: t.summary,
        category: t.category,
        icon: _quizIcon,
        color: _quizColor,
        builder: (_) => QuizSessionScreen(topic: t, mode: QuizMode.practice),
      ));
    }
  }

  addQuizzes(quizTopics);
  addQuizzes(electricalQuizTopics);
  addQuizzes(renewablesQuizTopics);
  addQuizzes(fuelsQuizTopics);
  addQuizzes(backflowQuizTopics);
  addQuizzes(commercialQuizTopics);
  addQuizzes(commercialGasQuizTopics);
  addQuizzes(lpgOilQuizTopics);
  addQuizzes(medicalGasesQuizTopics);
  addQuizzes(sprinklersQuizTopics);

  // ── Simulations ──────────────────────────────────────────────────────────
  for (final s in _sims) {
    out.add(SearchEntry(
      id: 'sim:${s.id}',
      type: 'Simulation',
      title: s.title,
      subtitle: s.subtitle,
      category: s.category,
      icon: s.icon,
      color: s.color,
      builder: s.builder,
    ));
  }

  // ── Job scenarios ────────────────────────────────────────────────────────
  for (final s in jobScenarios) {
    out.add(SearchEntry(
      id: 'scenario:${s.id}',
      type: 'Scenario',
      title: s.title,
      subtitle: s.customerBrief,
      category: s.category,
      icon: _scenarioIcon,
      color: _scenarioColor,
      builder: (_) => ScenarioSessionScreen(scenario: s),
    ));
  }

  // ── Checklists ───────────────────────────────────────────────────────────
  void addChecklists(List<JobChecklist> list) {
    for (final cl in list) {
      out.add(SearchEntry(
        id: 'checklist:${cl.id}',
        type: 'Checklist',
        title: cl.title,
        subtitle: cl.summary,
        category: cl.category,
        icon: _checklistIcon,
        color: _checklistColor,
        builder: (_) => ChecklistDetailScreen(checklist: cl),
      ));
    }
  }

  addChecklists(jobChecklists);
  addChecklists(commercialChecklists);
  addChecklists(commercialGasChecklists);
  addChecklists(heatPumpChecklists);
  addChecklists(lpgOilChecklists);
  addChecklists(medicalGasesChecklists);
  addChecklists(sprinklersChecklists);

  // ── Glossary ─────────────────────────────────────────────────────────────
  for (final g in glossary) {
    out.add(SearchEntry(
      id: 'glossary:${g.term}',
      type: 'Glossary',
      title: g.term,
      subtitle: g.definition,
      category: 'Glossary',
      icon: _glossaryIcon,
      color: _glossaryColor,
      builder: (_) => const GlossaryScreen(),
    ));
  }

  // ── Regulations ──────────────────────────────────────────────────────────
  for (final r in regulationEntries) {
    out.add(SearchEntry(
      id: 'reg:${r.code}',
      type: 'Regulation',
      title: '${r.code} — ${r.topic}',
      subtitle: r.summary,
      category: r.category,
      icon: _regIcon,
      color: _regColor,
      builder: (_) => const RegulationsScreen(),
    ));
  }

  // ── Troubleshooter cases ─────────────────────────────────────────────────
  for (final c in troubleCases) {
    out.add(SearchEntry(
      id: 'trouble:${c.id}',
      type: 'Troubleshooter',
      title: c.symptom,
      subtitle: 'Likely causes and a step-by-step diagnostic walk-through.',
      category: c.system,
      icon: _troubleIcon,
      color: _troubleColor,
      builder: (_) => const TroubleshooterScreen(),
    ));
  }

  // ── Customer explainers ──────────────────────────────────────────────────
  for (final e in customerExplainers) {
    out.add(SearchEntry(
      id: 'explainer:${e.id}',
      type: 'Customer explainer',
      title: e.title,
      subtitle: e.oneLine,
      category: e.category,
      icon: _explainerIcon,
      color: _explainerColor,
      builder: (_) => const CustomerExplainersScreen(),
    ));
  }

  // ── Tool encyclopedia ────────────────────────────────────────────────────
  for (final t in toolEntries) {
    out.add(SearchEntry(
      id: 'tool:${t.name}',
      type: 'Tool',
      title: t.name,
      subtitle: t.purpose,
      category: t.category,
      icon: t.icon,
      color: _toolColor,
      builder: (_) => const ToolsEncyclopediaScreen(),
    ));
  }

  // ── Hubs and other top-level destinations ────────────────────────────────
  for (final h in _hubs) {
    out.add(SearchEntry(
      id: 'hub:${h.id}',
      type: h.type,
      title: h.title,
      subtitle: h.subtitle,
      category: h.category,
      icon: h.icon,
      color: h.color,
      builder: h.builder,
    ));
  }

  return out;
}

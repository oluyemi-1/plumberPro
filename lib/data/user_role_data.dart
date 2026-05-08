import 'package:flutter/material.dart';

import '../theme.dart';

/// Specialism the user identifies with. Used to personalise the home screen
/// and to highlight the primary hub on first launch.
enum UserRole {
  trainee,
  domestic,
  heating,
  heatPump,
  commercialPlumber,
  commercialGas,
  lpgOil,
  medical,
  sprinkler,
}

class UserRoleInfo {
  final UserRole role;
  final String label;
  final String tagline;
  final IconData icon;
  final Color color;
  final String hubRouteHint; // descriptive id, used by home screen
  final List<String> recommendedModules;
  const UserRoleInfo({
    required this.role,
    required this.label,
    required this.tagline,
    required this.icon,
    required this.color,
    required this.hubRouteHint,
    required this.recommendedModules,
  });
}

/// Names referenced by [recommendedModules] correspond to the home-screen
/// module tile titles. The home screen uses these strings to surface the
/// "recommended for you" section.
const userRoleInfo = <UserRole, UserRoleInfo>{
  UserRole.trainee: UserRoleInfo(
    role: UserRole.trainee,
    label: 'Trainee / apprentice',
    tagline: 'Working through Level 2 / 3 — building foundations.',
    icon: Icons.school,
    color: Color(0xFF2A9D8F),
    hubRouteHint: 'lessons',
    recommendedModules: [
      'Lessons and theory',
      'Practical simulations',
      'Quizzes',
      'Tool encyclopedia',
      'Glossary',
      'Career pathway',
    ],
  ),
  UserRole.domestic: UserRoleInfo(
    role: UserRole.domestic,
    label: 'Domestic plumber',
    tagline: 'Day-to-day work in homes — installs, repairs, services.',
    icon: Icons.home,
    color: AppColors.primary,
    hubRouteHint: 'simulations',
    recommendedModules: [
      'Practical simulations',
      'Troubleshooter',
      'Job scenarios',
      'Pre-job checklists',
      'Customer explainers',
      'Calculators',
    ],
  ),
  UserRole.heating: UserRoleInfo(
    role: UserRole.heating,
    label: 'Heating engineer (Gas Safe domestic)',
    tagline: 'Boiler installs, services and gas work in homes.',
    icon: Icons.local_fire_department,
    color: AppColors.gas,
    hubRouteHint: 'simulations',
    recommendedModules: [
      'Practical simulations',
      'Pre-job checklists',
      'Calculators',
      'Troubleshooter',
      'Regulations & standards',
      'Synoptic mock assessment',
    ],
  ),
  UserRole.heatPump: UserRoleInfo(
    role: UserRole.heatPump,
    label: 'Heat pump installer',
    tagline: 'BUS-grant work — MCS design, MIS 3005 commissioning.',
    icon: Icons.heat_pump,
    color: Color(0xFFE76F51),
    hubRouteHint: 'heat_pump',
    recommendedModules: [
      'Heat pump installer',
      'Practical simulations',
      'Calculators',
      'Regulations & standards',
      'Career pathway',
    ],
  ),
  UserRole.commercialPlumber: UserRoleInfo(
    role: UserRole.commercialPlumber,
    label: 'Commercial plumbing engineer',
    tagline: 'Booster sets, calorifiers, cascade boilers, water hygiene.',
    icon: Icons.apartment,
    color: Color(0xFF073B4C),
    hubRouteHint: 'commercial',
    recommendedModules: [
      'Commercial plumbing engineer',
      'Calculators',
      'Regulations & standards',
      'Pre-job checklists',
    ],
  ),
  UserRole.commercialGas: UserRoleInfo(
    role: UserRole.commercialGas,
    label: 'Commercial gas engineer',
    tagline: 'IGEM/UP standards, boiler rooms, catering interlocks.',
    icon: Icons.local_fire_department,
    color: Color(0xFFB8860B),
    hubRouteHint: 'commercial_gas',
    recommendedModules: [
      'Commercial gas engineer',
      'Pre-job checklists',
      'Regulations & standards',
      'Synoptic mock assessment',
    ],
  ),
  UserRole.lpgOil: UserRoleInfo(
    role: UserRole.lpgOil,
    label: 'LPG / oil specialist',
    tagline: 'Off-grid heating — UKLPG and OFTEC work.',
    icon: Icons.propane_tank,
    color: Color(0xFF7B2CBF),
    hubRouteHint: 'lpg_oil',
    recommendedModules: [
      'LPG & oil specialist',
      'Pre-job checklists',
      'Calculators',
      'Regulations & standards',
    ],
  ),
  UserRole.medical: UserRoleInfo(
    role: UserRole.medical,
    label: 'Medical gas engineer',
    tagline: 'Healthcare engineering — HTM 02-01, AP-MGPS oversight.',
    icon: Icons.local_hospital,
    color: Color(0xFF0077B6),
    hubRouteHint: 'medical',
    recommendedModules: [
      'Medical gas pipelines',
      'Regulations & standards',
      'Pre-job checklists',
      'Tool encyclopedia',
    ],
  ),
  UserRole.sprinkler: UserRoleInfo(
    role: UserRole.sprinkler,
    label: 'Fire sprinkler installer',
    tagline: 'Life-safety work — BS 9251 / BS EN 12845.',
    icon: Icons.fire_extinguisher,
    color: Color(0xFFD62828),
    hubRouteHint: 'sprinkler',
    recommendedModules: [
      'Fire sprinkler systems',
      'Calculators',
      'Pre-job checklists',
      'Regulations & standards',
    ],
  ),
};

class UserGoal {
  final String id;
  final String label;
  final String description;
  const UserGoal({
    required this.id,
    required this.label,
    required this.description,
  });
}

const userGoals = <UserGoal>[
  UserGoal(
    id: 'nvq_level_2',
    label: 'NVQ Level 2',
    description: 'Foundation plumbing qualification.',
  ),
  UserGoal(
    id: 'nvq_level_3',
    label: 'NVQ Level 3',
    description: 'Time-served competence in the trade.',
  ),
  UserGoal(
    id: 'gas_safe_acs',
    label: 'Gas Safe ACS',
    description: 'Domestic gas competence assessments.',
  ),
  UserGoal(
    id: 'mcs_heat_pump',
    label: 'MCS heat pump installer',
    description: 'BUS-grant qualifying installer status.',
  ),
  UserGoal(
    id: 'unvented_g3',
    label: 'Unvented G3',
    description: 'Hot water systems competent person.',
  ),
  UserGoal(
    id: 'oftec',
    label: 'OFTEC oil',
    description: 'Oil-fired appliance installation and service.',
  ),
  UserGoal(
    id: 'uklpg',
    label: 'UKLPG',
    description: 'LPG installation competence.',
  ),
  UserGoal(
    id: 'water_regs',
    label: 'WIAPS / Water Regs',
    description: 'Water Industry Approved Plumber.',
  ),
  UserGoal(
    id: 'cpd',
    label: 'General CPD',
    description: 'Continuing professional development.',
  ),
  UserGoal(
    id: 'commercial_pipework',
    label: 'Commercial pipework competence',
    description: 'Booster sets, calorifiers, cascade systems.',
  ),
];

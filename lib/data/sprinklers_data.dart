// Reference data for UK domestic / residential fire sprinkler systems.
//
// Hazard categories follow BS 9251:2021 for residential and domestic
// premises. Heads list metric K-factors and typical activation
// temperatures. Supply types match BS 9251 supply classifications 1-4.

class HazardCategory {
  final String label;
  final String typicalUse;
  final double densityMmMin;
  final int simultaneousHeads;
  final double assumedAreaM2;
  final int durationMin;
  final String reference;
  const HazardCategory({
    required this.label,
    required this.typicalUse,
    required this.densityMmMin,
    required this.simultaneousHeads,
    required this.assumedAreaM2,
    required this.durationMin,
    required this.reference,
  });
}

class SprinklerHead {
  final String label;
  final double kFactor;
  final int activationTempC;
  final String orientation;
  final String use;
  const SprinklerHead({
    required this.label,
    required this.kFactor,
    required this.activationTempC,
    required this.orientation,
    required this.use,
  });
}

class SupplyType {
  final String label;
  final String description;
  final String suitability;
  const SupplyType({
    required this.label,
    required this.description,
    required this.suitability,
  });
}

const hazardCategories = <HazardCategory>[
  HazardCategory(
    label: 'Cat 1 — domestic',
    typicalUse: 'Single family dwellings up to 3 storeys',
    densityMmMin: 4.0,
    simultaneousHeads: 1,
    assumedAreaM2: 12.0,
    durationMin: 10,
    reference: 'BS 9251:2021 §5',
  ),
  HazardCategory(
    label: 'Cat 2 — residential, low rise',
    typicalUse: 'Flats and HMOs up to 18 m, sheltered housing',
    densityMmMin: 5.0,
    simultaneousHeads: 4,
    assumedAreaM2: 12.0,
    durationMin: 30,
    reference: 'BS 9251:2021 §5',
  ),
  HazardCategory(
    label: 'Cat 3 — residential, taller / sleeping risk',
    typicalUse: 'Care homes, taller residential, mixed sleeping use',
    densityMmMin: 7.5,
    simultaneousHeads: 4,
    assumedAreaM2: 24.0,
    durationMin: 30,
    reference: 'BS 9251:2021 §5',
  ),
  HazardCategory(
    label: 'Cat 4 — special / bespoke',
    typicalUse: 'Specialist nursing, dependent occupancy, bespoke design',
    densityMmMin: 7.5,
    simultaneousHeads: 4,
    assumedAreaM2: 24.0,
    durationMin: 60,
    reference: 'BS 9251:2021 §5 (bespoke)',
  ),
];

const sprinklerHeads = <SprinklerHead>[
  SprinklerHead(
    label: 'K57 quick response 57 °C',
    kFactor: 57,
    activationTempC: 57,
    orientation: 'pendent',
    use: 'Domestic ceilings, low ambient rooms',
  ),
  SprinklerHead(
    label: 'K57 quick response 68 °C',
    kFactor: 57,
    activationTempC: 68,
    orientation: 'pendent / sidewall',
    use: 'General domestic and residential bedrooms',
  ),
  SprinklerHead(
    label: 'K80 quick response 68 °C',
    kFactor: 80,
    activationTempC: 68,
    orientation: 'pendent',
    use: 'Cat 2 and Cat 3 residential, kitchens',
  ),
  SprinklerHead(
    label: 'K80 quick response 79 °C',
    kFactor: 80,
    activationTempC: 79,
    orientation: 'upright',
    use: 'Loft spaces or higher ambient temperatures',
  ),
  SprinklerHead(
    label: 'K115 standard response 68 °C',
    kFactor: 115,
    activationTempC: 68,
    orientation: 'pendent',
    use: 'Larger residential rooms, communal areas',
  ),
  SprinklerHead(
    label: 'K115 standard response 93 °C',
    kFactor: 115,
    activationTempC: 93,
    orientation: 'upright',
    use: 'Plant rooms and high ambient zones',
  ),
];

const supplyTypes = <SupplyType>[
  SupplyType(
    label: 'Type 1 — boosted town main',
    description:
        'Direct connection to the water authority main with a boost pump set where pressure or flow is marginal. No on-site storage.',
    suitability: 'Where a strong, steady main can meet sprinkler demand.',
  ),
  SupplyType(
    label: 'Type 2 — mains only',
    description:
        'Direct connection to the water authority main with no booster pump and no storage. Demand must be met by the main alone.',
    suitability: 'Cat 1 domestic with proven hydraulic margin.',
  ),
  SupplyType(
    label: 'Type 3 — mains plus tank and pump',
    description:
        'Town main feeds a storage cistern, with a pump set drawing from the cistern. Mains and stored water both contribute.',
    suitability: 'Cat 2 and Cat 3 where mains alone is insufficient.',
  ),
  SupplyType(
    label: 'Type 4 — tank and pump only',
    description:
        'Dedicated stored water in a sprinkler cistern with a duty plus standby pump set. Independent of the town main during a fire.',
    suitability: 'Cat 3 sleeping risk, where a fully assured supply is required.',
  ),
];

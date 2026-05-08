/// Reference data for hazardous-area classification of natural gas
/// installations under IGEM/UP/16, with cross-references to BS EN 60079-10-1
/// (DSEAR) zone definitions.
///
/// All text is intentionally generic and educational and is intended to
/// support training rather than to replace a site-specific area
/// classification by a competent person.
library;

class HazardousZone {
  /// Short label such as 'Zone 0', 'Zone 1', 'Zone 2', 'Non-hazardous'.
  final String label;

  /// Display colour stored as a 32-bit ARGB integer so the data file does
  /// not depend on Flutter's Color class.
  final int colourArgb;

  /// Technical definition lifted from BS EN 60079-10-1 / DSEAR ACoP.
  final String definition;

  /// Plain-language examples of where this zone is typically encountered
  /// on gas installations covered by IGEM/UP/16.
  final String examples;

  /// Required electrical equipment Ex category for this zone.
  final String equipment;

  const HazardousZone({
    required this.label,
    required this.colourArgb,
    required this.definition,
    required this.examples,
    required this.equipment,
  });

  /// TTS-friendly read-aloud version of the entry.
  String get speakable =>
      '$label. Definition. $definition. Typical examples. $examples. Required equipment. $equipment';
}

class HazardLocation {
  /// Description of the location e.g. 'Within 1 m of a pressure relief valve outlet'.
  final String label;

  /// Matches one of the [HazardousZone.label] values.
  final String zone;

  /// Brief reasoning for the assigned zone.
  final String reasoning;

  const HazardLocation({
    required this.label,
    required this.zone,
    required this.reasoning,
  });
}

/// The four classification categories used in IGEM/UP/16 worked examples.
const hazardousZones = <HazardousZone>[
  HazardousZone(
    label: 'Zone 0',
    colourArgb: 0xFFD32F2F, // red
    definition:
        'A place in which an explosive gas atmosphere is present continuously, '
        'for long periods or frequently. In gas industry practice this is '
        'usually confined to the inside of vent pipework, the inside of '
        'governor breather lines and other points where gas is permanently '
        'present in flammable concentration.',
    examples:
        'Inside an open vent of a gas pressure regulator, inside a relief '
        'valve discharge stack, inside a fuel gas vent line during normal '
        'operation, inside an LPG cylinder vapour space.',
    equipment:
        'Electrical apparatus must be Equipment Category 1 (EPL Ga), '
        'typically marked Ex ia IIA T1 or better. Most installations '
        'avoid placing any electrical equipment inside Zone 0.',
  ),
  HazardousZone(
    label: 'Zone 1',
    colourArgb: 0xFFEF6C00, // orange
    definition:
        'A place in which an explosive gas atmosphere is likely to occur in '
        'normal operation occasionally. Releases are expected during routine '
        'activities such as venting, purging, sampling or relief operation.',
    examples:
        'Within 1 m of a regulator vent termination outdoors, immediately '
        'around an open flange or sample point, inside a below-ground meter '
        'pit on entry, inside an LPG cylinder cabinet.',
    equipment:
        'Equipment Category 2 (EPL Gb), e.g. Ex d, Ex e, Ex p or Ex ib '
        'with the correct gas group (IIA for natural gas, IIB for some '
        'commercial fuels) and temperature class (T1 minimum for methane).',
  ),
  HazardousZone(
    label: 'Zone 2',
    colourArgb: 0xFFF9A825, // amber / yellow
    definition:
        'A place in which an explosive gas atmosphere is not likely to occur '
        'in normal operation but, if it does occur, will persist for a short '
        'period only. This typically extends a short distance beyond Zone 1 '
        'sources of release.',
    examples:
        'Within 3 m of a domestic meter installation indoors with adequate '
        'ventilation, inside a gas-fired boiler casing, the volume immediately '
        'above a sealed meter cabinet, inside a plant room where leakage is '
        'controlled by detection and forced extract.',
    equipment:
        'Equipment Category 3 (EPL Gc), e.g. Ex nA, Ex nC, Ex ic. Standard '
        'industrial enclosures may be acceptable if rated to the correct '
        'gas group and temperature class for natural gas (IIA T1).',
  ),
  HazardousZone(
    label: 'Non-hazardous',
    colourArgb: 0xFF2E7D32, // green
    definition:
        'A place in which an explosive gas atmosphere is not expected to be '
        'present in such quantities as to require special precautions for the '
        'construction, installation and use of electrical apparatus.',
    examples:
        'A typical kitchen, occupied living space, ventilated boiler room '
        'meeting EN 1775 separation distances, a corridor more than 3 m from '
        'any meter or relief termination.',
    equipment:
        'No special Ex rating required. Standard IP-rated equipment is '
        'acceptable, however statutory separation distances from sources of '
        'ignition still apply (BS 6891, BS 6173, IGEM/UP/1 series).',
  ),
];

/// Twelve+ worked examples drawn from IGEM/UP/16 Appendix B-style scenarios.
const typicalLocations = <HazardLocation>[
  HazardLocation(
    label: 'Inside an open vent of a gas governor',
    zone: 'Zone 0',
    reasoning:
        'During governor breathing the vent contains a flammable mixture '
        'continuously or frequently, so the internal volume is Zone 0.',
  ),
  HazardLocation(
    label: 'Within 1 m of a pressure-regulating valve vent terminal',
    zone: 'Zone 1',
    reasoning:
        'Gas is released to atmosphere in normal operation when the regulator '
        'breathes, creating a likely flammable atmosphere within 1 m of the '
        'terminal.',
  ),
  HazardLocation(
    label: 'Within 3 m of a domestic gas meter installation indoors with adequate ventilation',
    zone: 'Zone 2',
    reasoning:
        'A flammable atmosphere is not expected in normal operation. Should a '
        'small fugitive leak occur, ventilation will disperse it briefly, '
        'satisfying the Zone 2 criteria.',
  ),
  HazardLocation(
    label: 'Inside a gas-fired boiler casing',
    zone: 'Zone 2',
    reasoning:
        'Manufacturer technical files commonly classify the inside of the '
        'casing as Zone 2 — small fugitive leaks are improbable in normal '
        'operation and would dissipate quickly through casing ventilation.',
  ),
  HazardLocation(
    label: 'Within 1 m of an open flange or known leak source',
    zone: 'Zone 1',
    reasoning:
        'Open flanges can leak in normal operation, producing flammable '
        'atmospheres often enough to warrant Zone 1 classification.',
  ),
  HazardLocation(
    label: 'Plant room with leakage controlled by detection and forced extract',
    zone: 'Zone 2',
    reasoning:
        'Continuous extract plus gas detection reduces the duration and '
        'probability of any flammable atmosphere to Zone 2; without these '
        'controls the room could fall under Zone 1 or worse.',
  ),
  HazardLocation(
    label: 'Outside a building, within 1 m of any pressure relief termination',
    zone: 'Zone 1',
    reasoning:
        'Reliefs may operate occasionally in normal operation. The 1 m sphere '
        'around the discharge is treated as Zone 1, with Zone 2 extending a '
        'further short distance.',
  ),
  HazardLocation(
    label: 'Inside an external LPG cylinder cabinet',
    zone: 'Zone 1',
    reasoning:
        'Vapour can collect inside the cabinet during cylinder change-over or '
        'small fitting leaks; the internal volume is therefore Zone 1, with '
        'Zone 2 extending up to 1 m around any louvre.',
  ),
  HazardLocation(
    label: 'Below-ground meter pit on entry',
    zone: 'Zone 1',
    reasoning:
        'Below-ground enclosures cannot dissipate gas naturally. On opening, '
        'any leakage that has accumulated must be assumed flammable, giving a '
        'Zone 1 inside the pit.',
  ),
  HazardLocation(
    label: 'Volume immediately above a sealed gas meter cabinet (within 0.5 m)',
    zone: 'Zone 2',
    reasoning:
        'Sealed cabinets vent upwards. The half-metre envelope above the vent '
        'is treated as Zone 2 because any release would be brief and small.',
  ),
  HazardLocation(
    label: 'Inside a gas pressure-proving system enclosure',
    zone: 'Zone 2',
    reasoning:
        'GPPS enclosures contain gas under controlled test conditions only; '
        'releases are short, infrequent and controlled, supporting a Zone 2 '
        'classification.',
  ),
  HazardLocation(
    label: 'Behind a kitchen extraction hood near a leaking flexible connector',
    zone: 'Zone 1',
    reasoning:
        'Damaged or aged flexibles release gas occasionally during normal '
        'cooking operation. Combined with the local low-velocity zone behind '
        'the hood, Zone 1 applies until the flexible is replaced.',
  ),
  HazardLocation(
    label: 'Living space at least 3 m from any gas appliance or fitting',
    zone: 'Non-hazardous',
    reasoning:
        'Outside the influence of any source of release, the volume is treated '
        'as non-hazardous, although general fire-safety separation distances '
        'still apply.',
  ),
  HazardLocation(
    label: 'Within 1 m around the louvres of an LPG cylinder cabinet',
    zone: 'Zone 2',
    reasoning:
        'Vapour escaping the cabinet louvres will dissipate quickly outdoors, '
        'so the surrounding 1 m envelope is Zone 2 rather than Zone 1.',
  ),
];

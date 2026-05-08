// BS 1710 pipe identification colour codes (UK).
//
// Basic colour identifies the contents class; coloured bands give the
// specific service. ARGB integers are used for portability.

class PipeColourCode {
  final String service;
  final String category;
  final int basicARGB;
  final List<int> codeBands;
  final String label;
  final String details;

  const PipeColourCode({
    required this.service,
    required this.category,
    required this.basicARGB,
    required this.codeBands,
    required this.label,
    required this.details,
  });

  String get speakable => '$service. Colour code $label. $details';
}

// Common ARGB constants used below.
const int _green = 0xFF1B5E20;       // basic colour for water
const int _blue = 0xFF1565C0;        // band: drinking, also auxiliary blue
const int _auxBlue = 0xFF64B5F6;     // auxiliary blue (lighter)
const int _white = 0xFFF5F5F5;       // white band
const int _red = 0xFFC62828;         // band: hot/fire/etc.
const int _silver = 0xFFB0B0B0;      // basic for steam/fire
const int _yellowOchre = 0xFFB58B00; // basic for gas
const int _brown = 0xFF5D4037;       // basic for fuel oil
const int _black = 0xFF111111;       // drainage / band
const int _crimson = 0xFFB71C1C;     // deeper red for MTHW
const int _orange = 0xFFEF6C00;      // foam / sprinkler accent

const pipeColourCodes = <PipeColourCode>[
  // ---------------- Water services ----------------
  PipeColourCode(
    service: 'Drinking water',
    category: 'Water',
    basicARGB: _green,
    codeBands: [_green, _blue, _green],
    label: 'Green / blue / green',
    details:
        'Wholesome cold water for human consumption. WRAS-listed materials only. Identification required at access points and either side of partitions.',
  ),
  PipeColourCode(
    service: 'Cold down service',
    category: 'Water',
    basicARGB: _green,
    codeBands: [_green, _white, _green],
    label: 'Green / white / green',
    details:
        'Cold water distribution from a storage cistern. Insulate to keep below 20 C and prevent heat gain.',
  ),
  PipeColourCode(
    service: 'Treated water',
    category: 'Water',
    basicARGB: _green,
    codeBands: [_auxBlue],
    label: 'Auxiliary blue',
    details:
        'Softened or otherwise treated water. Where the treatment makes the water non-potable add a Cat 5 backflow device upstream.',
  ),
  PipeColourCode(
    service: 'Domestic hot water flow',
    category: 'Water',
    basicARGB: _green,
    codeBands: [_green, _red, _green],
    label: 'Green / red / green',
    details:
        'Hot water service flow. Store at 60 C or above; deliver at 50 C minimum at sentinel taps within one minute.',
  ),
  PipeColourCode(
    service: 'Domestic hot water return',
    category: 'Water',
    basicARGB: _green,
    codeBands: [_green, _red, _white, _red, _green],
    label: 'Green / red / white / red / green',
    details:
        'Secondary return loop ensuring distribution remains above 50 C. Verify with thermometric balance at the calorifier return.',
  ),

  // ---------------- Heating ----------------
  PipeColourCode(
    service: 'LTHW flow',
    category: 'Heating',
    basicARGB: _blue,
    codeBands: [_blue, _red, _blue],
    label: 'Blue / red / blue',
    details:
        'Low temperature hot water heating flow, up to 100 C. Typical commercial wet system flow temperature 70 to 82 C.',
  ),
  PipeColourCode(
    service: 'LTHW return',
    category: 'Heating',
    basicARGB: _blue,
    codeBands: [_blue, _white, _red, _white, _blue],
    label: 'Blue / white / red / white / blue',
    details:
        'LTHW return to boiler. Design delta T typically 10 to 20 K depending on emitter type.',
  ),
  PipeColourCode(
    service: 'MTHW flow',
    category: 'Heating',
    basicARGB: _blue,
    codeBands: [_blue, _crimson, _blue],
    label: 'Blue / crimson / blue',
    details:
        'Medium temperature hot water 100 to 120 C. Pressurised system, fit appropriate safety valves and expansion provision.',
  ),
  PipeColourCode(
    service: 'MTHW return',
    category: 'Heating',
    basicARGB: _blue,
    codeBands: [_blue, _white, _crimson, _white, _blue],
    label: 'Blue / white / crimson / white / blue',
    details:
        'MTHW return. Inspect insulation and pipe supports to BS 5970 owing to thermal movement.',
  ),

  // ---------------- Cooling ----------------
  PipeColourCode(
    service: 'Chilled water flow',
    category: 'Cooling',
    basicARGB: _auxBlue,
    codeBands: [_auxBlue, _white, _auxBlue],
    label: 'Auxiliary blue / white / auxiliary blue',
    details:
        'Chilled water flow, typically 6 C. Vapour-sealed insulation essential to prevent surface condensation.',
  ),
  PipeColourCode(
    service: 'Chilled water return',
    category: 'Cooling',
    basicARGB: _auxBlue,
    codeBands: [_auxBlue, _white, _white, _auxBlue],
    label: 'Auxiliary blue / white / white / auxiliary blue',
    details:
        'Chilled water return, typically 12 C. Maintain delta T of around 6 K for FCU coils.',
  ),

  // ---------------- Steam and condensate ----------------
  PipeColourCode(
    service: 'Steam',
    category: 'Steam / condensate',
    basicARGB: _silver,
    codeBands: [_silver, _red, _silver],
    label: 'Silver / red / silver',
    details:
        'Saturated steam mains. Identify pressure rating on labels. Provide steam traps at all low points.',
  ),
  PipeColourCode(
    service: 'Condensate',
    category: 'Steam / condensate',
    basicARGB: _silver,
    codeBands: [_silver, _green, _silver],
    label: 'Silver / green / silver',
    details:
        'Returning condensate from steam plant. Beware flash steam at vented receivers; use hook-ups for hazard.',
  ),

  // ---------------- Compressed air and vacuum ----------------
  PipeColourCode(
    service: 'Compressed air',
    category: 'Other',
    basicARGB: _auxBlue,
    codeBands: [_auxBlue],
    label: 'Light blue (auxiliary blue)',
    details:
        'Compressed air ring main. Mark working pressure and drop legs. Use only WRAS-approved hose where breathing air is required.',
  ),
  PipeColourCode(
    service: 'Vacuum',
    category: 'Other',
    basicARGB: _auxBlue,
    codeBands: [_auxBlue, _white, _auxBlue],
    label: 'Light blue / white / light blue',
    details:
        'Vacuum lines. Indicate direction of flow toward receiver and isolating valve.',
  ),

  // ---------------- Fuel ----------------
  PipeColourCode(
    service: 'Natural gas',
    category: 'Fuel',
    basicARGB: _yellowOchre,
    codeBands: [_yellowOchre],
    label: 'Yellow ochre',
    details:
        'Natural gas service in commercial premises. Label meter pressure and ECV location. Comply with IGEM/UP/2 for installation.',
  ),
  PipeColourCode(
    service: 'Fuel oil',
    category: 'Fuel',
    basicARGB: _brown,
    codeBands: [_brown],
    label: 'Brown',
    details:
        'Heating oil supply or return. Bunding and fire valves required per OFTEC and Building Regulations Approved Document J.',
  ),

  // ---------------- Fire services ----------------
  PipeColourCode(
    service: 'Fire main (wet riser / hydrant)',
    category: 'Fire',
    basicARGB: _silver,
    codeBands: [_red, _silver, _red],
    label: 'Red / silver / red',
    details:
        'Pressurised fire main. Label inlet location and zone valves. Test annually to BS 9990.',
  ),
  PipeColourCode(
    service: 'Sprinkler',
    category: 'Fire',
    basicARGB: _silver,
    codeBands: [_red, _orange, _red],
    label: 'Red / orange / red',
    details:
        'Sprinkler distribution. Maintain to BS EN 12845 and never isolate without permit-to-work.',
  ),

  // ---------------- Drainage ----------------
  PipeColourCode(
    service: 'Foul drainage',
    category: 'Drainage',
    basicARGB: _black,
    codeBands: [_black],
    label: 'Black',
    details:
        'Soil and waste drainage from sanitary appliances. Vent to atmosphere per BS EN 12056-2; do not connect to surface water.',
  ),
  PipeColourCode(
    service: 'Surface water',
    category: 'Drainage',
    basicARGB: _black,
    codeBands: [_green, _black, _green],
    label: 'Green / black / green',
    details:
        'Rainwater and surface runoff. Discharge to soakaway, watercourse or separate sewer per Approved Document H.',
  ),
];

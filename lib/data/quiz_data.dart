/// Multi-choice question bank used by the quiz module. Each question has
/// exactly four options and one correct answer plus an explanation that is
/// shown on review.
class QuizQuestion {
  final String prompt;
  final List<String> choices;
  final int correctIndex;
  final String explanation;
  const QuizQuestion({
    required this.prompt,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
  });

  String get correctAnswer => choices[correctIndex];
}

class QuizTopic {
  final String id;
  final String title;
  final String category;
  final String summary;
  final List<QuizQuestion> questions;
  const QuizTopic({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.questions,
  });
}

const quizTopics = <QuizTopic>[
  // ───────────────────────────────────────────────────────────────────────
  QuizTopic(
    id: 'cold_water',
    title: 'Cold water supply',
    category: 'Cold water',
    summary:
        'Service pipe, stop valves, direct vs indirect distribution and backflow.',
    questions: [
      QuizQuestion(
        prompt:
            'What is the minimum depth at which a service pipe should be buried for frost protection?',
        choices: ['450 mm', '600 mm', '750 mm', '1200 mm'],
        correctIndex: 2,
        explanation:
            'A service pipe must be at least 750 mm below ground level to keep it below the typical frost line.',
      ),
      QuizQuestion(
        prompt:
            'On a direct cold water system, which outlet is fed from a storage cistern?',
        choices: [
          'Kitchen sink cold tap',
          'Outside tap',
          'None — every outlet runs from the rising main',
          'WC cistern only',
        ],
        correctIndex: 2,
        explanation:
            'A direct system feeds every cold draw-off straight from the rising main at mains pressure.',
      ),
      QuizQuestion(
        prompt:
            'Which fitting is normally installed immediately above the internal stop valve?',
        choices: [
          'A drain-off cock',
          'A pressure reducing valve',
          'A water meter',
          'An expansion vessel',
        ],
        correctIndex: 0,
        explanation:
            'A drain-off cock above the stop valve lets the system be drained for maintenance.',
      ),
      QuizQuestion(
        prompt:
            'What is the purpose of a double check valve on an outside tap?',
        choices: [
          'To increase outlet pressure',
          'To prevent backflow into the wholesome supply',
          'To reduce noise',
          'To filter the water',
        ],
        correctIndex: 1,
        explanation:
            'An outside tap could be connected to a hose; a double check valve provides backflow protection.',
      ),
      QuizQuestion(
        prompt:
            'Typical mains cold water pressure delivered to a UK domestic property is in the range of:',
        choices: [
          '0.5 to 1 bar',
          '2 to 4 bar',
          '6 to 8 bar',
          '10 to 12 bar',
        ],
        correctIndex: 1,
        explanation:
            'Mains pressure typically sits between 2 and 4 bar; the water company guarantees a minimum of 1 bar at the boundary.',
      ),
      QuizQuestion(
        prompt:
            'On an indirect cold water system, which appliance is still fed directly from the rising main?',
        choices: [
          'Bath cold',
          'Basin cold',
          'WC cistern',
          'Kitchen sink cold tap',
        ],
        correctIndex: 3,
        explanation:
            'The kitchen tap must remain on the wholesome rising main as it is the drinking water point.',
      ),
      QuizQuestion(
        prompt:
            'A cold water storage cistern in a loft must have, as a minimum:',
        choices: [
          'Insulated jacket, lid, screened overflow and screened vent',
          'A heater to prevent freezing',
          'A pressure reducing valve on the inlet',
          'A circulating pump',
        ],
        correctIndex: 0,
        explanation:
            'Lid, insulation, screened overflow and screened vent prevent contamination and freezing.',
      ),
      QuizQuestion(
        prompt:
            'Who owns and is responsible for the boundary stop valve?',
        choices: [
          'The plumber who fitted it',
          'The water authority / undertaker',
          'The home owner',
          'The local authority',
        ],
        correctIndex: 1,
        explanation:
            'The water company owns the supply up to and including the boundary stop valve.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────────────
  QuizTopic(
    id: 'hot_water',
    title: 'Hot water systems',
    category: 'Hot water',
    summary:
        'Combi, vented and unvented systems plus safety devices and Legionella.',
    questions: [
      QuizQuestion(
        prompt:
            'Stored hot water should be kept at what minimum temperature to suppress Legionella?',
        choices: ['45 °C', '50 °C', '60 °C', '75 °C'],
        correctIndex: 2,
        explanation:
            'Storing at 60 °C and distributing above 50 °C controls Legionella growth.',
      ),
      QuizQuestion(
        prompt:
            'Inside a combi boiler, which valve diverts flow between heating and DHW?',
        choices: [
          'Pressure relief valve',
          'Diverter valve',
          'Lockshield',
          'Cylinder thermostat',
        ],
        correctIndex: 1,
        explanation:
            'When a hot tap opens, the diverter switches flow from radiators to the plate heat exchanger.',
      ),
      QuizQuestion(
        prompt:
            'On an unvented cylinder, the temperature and pressure relief valve is normally set to open at:',
        choices: [
          '60 °C / 3 bar',
          '90 °C / 7 bar',
          '120 °C / 10 bar',
          '85 °C / 4 bar',
        ],
        correctIndex: 1,
        explanation:
            'A T&P relief on an unvented cylinder typically lifts at 90 °C or 7 bar, whichever occurs first.',
      ),
      QuizQuestion(
        prompt: 'What is the purpose of a tundish?',
        choices: [
          'To filter limescale',
          'To pre-heat cold water',
          'To provide a visible air break on a relief discharge',
          'To balance flow between coils',
        ],
        correctIndex: 2,
        explanation:
            'The tundish gives a visible air gap so any relief discharge cannot be missed.',
      ),
      QuizQuestion(
        prompt:
            'A bath tap blended for a vulnerable user must be limited to a maximum of:',
        choices: ['38 °C', '41 °C', '43 °C', '46 °C'],
        correctIndex: 2,
        explanation:
            'A blending TMV at a bath should be set to a maximum of 43 °C to prevent scalding.',
      ),
      QuizQuestion(
        prompt:
            'A vented hot water cylinder is normally fed from:',
        choices: [
          'The cold mains directly',
          'A cold water storage cistern in the loft',
          'The boiler return',
          'A pressure reducing valve',
        ],
        correctIndex: 1,
        explanation:
            'A vented system uses gravity feed from a cistern, which also receives expansion via the open vent.',
      ),
      QuizQuestion(
        prompt:
            'Which of these is NOT part of an unvented cylinder inlet group?',
        choices: [
          'Pressure reducing valve',
          'Single check valve',
          'Expansion vessel',
          'Cylinder thermostat',
        ],
        correctIndex: 3,
        explanation:
            'The cylinder thermostat is on the body of the cylinder, not in the cold inlet group.',
      ),
      QuizQuestion(
        prompt:
            'Why are secondary circulation pumps fitted on long hot water runs?',
        choices: [
          'To raise stored water temperature',
          'To eliminate dead legs and waste',
          'To reduce mains pressure',
          'To remove sediment',
        ],
        correctIndex: 1,
        explanation:
            'A return loop avoids the user waiting and wasting cold water from a long dead leg.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────────────
  QuizTopic(
    id: 'central_heating',
    title: 'Wet central heating',
    category: 'Heating',
    summary:
        'Sealed system pressures, plans, balancing and inhibitors.',
    questions: [
      QuizQuestion(
        prompt:
            'A sealed heating system should read what pressure when cold?',
        choices: [
          '0.3 to 0.5 bar',
          '1.0 to 1.5 bar',
          '2.5 to 3.0 bar',
          '4.0 bar',
        ],
        correctIndex: 1,
        explanation:
            'Cold pressure should sit between roughly 1 and 1.5 bar; it rises around 0.5 bar when hot.',
      ),
      QuizQuestion(
        prompt:
            'A pressure relief valve on a domestic sealed system is set to lift at:',
        choices: ['1.5 bar', '2.5 bar', '3.0 bar', '6.0 bar'],
        correctIndex: 2,
        explanation:
            'The PRV on a sealed system is normally factory-set to 3 bar.',
      ),
      QuizQuestion(
        prompt:
            'Which radiator valve is used for balancing flow?',
        choices: [
          'TRV head',
          'Lockshield',
          'Bleed screw',
          'Drain-off cock',
        ],
        correctIndex: 1,
        explanation:
            'The lockshield is throttled during balancing to give each radiator the correct flow.',
      ),
      QuizQuestion(
        prompt: 'How many motorised valves does an S-plan use?',
        choices: ['One', 'Two', 'Three', 'None'],
        correctIndex: 1,
        explanation:
            'S-plan uses two two-port valves, one for heating and one for hot water.',
      ),
      QuizQuestion(
        prompt:
            'Typical inhibitor dose for a heating system is:',
        choices: [
          '1 litre per 10 litres of system water',
          '1 litre per 100 litres of system water',
          '5 litres regardless of system size',
          'No fixed dose, add to taste',
        ],
        correctIndex: 1,
        explanation:
            'A standard dose is 1 litre of inhibitor per 100 litres of system water.',
      ),
      QuizQuestion(
        prompt:
            'A radiator that is hot at the bottom but cold at the top usually has:',
        choices: [
          'Sludge build-up',
          'A failed lockshield',
          'Trapped air at the top',
          'Excessive system pressure',
        ],
        correctIndex: 2,
        explanation:
            'Air sits at the top of the radiator and prevents water reaching the upper section.',
      ),
      QuizQuestion(
        prompt:
            'A radiator that is hot at the top but cold at the bottom usually has:',
        choices: [
          'Trapped air',
          'Sludge build-up at the base',
          'A blocked vent',
          'Closed bleed screw',
        ],
        correctIndex: 1,
        explanation:
            'Iron oxide sludge settles in the bottom of the radiator, blocking flow at the base.',
      ),
      QuizQuestion(
        prompt:
            'What is the purpose of an automatic air vent (AAV) on a heating system?',
        choices: [
          'To release foul gases',
          'To release trapped air automatically at the high point',
          'To regulate cold water inlet',
          'To act as a pressure relief',
        ],
        correctIndex: 1,
        explanation:
            'An AAV allows air to vent automatically at the system high point during operation.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────────────
  QuizTopic(
    id: 'drainage',
    title: 'Drainage and traps',
    category: 'Drainage',
    summary:
        'Trap seals, siphonage, vents, falls and access.',
    questions: [
      QuizQuestion(
        prompt:
            'The minimum depth of water seal in a deep trap is normally:',
        choices: ['25 mm', '38 mm', '50 mm', '75 mm'],
        correctIndex: 3,
        explanation:
            'Most domestic traps retain a 75 mm water seal; shallow 38 mm traps are only allowed where space prevents a deeper trap.',
      ),
      QuizQuestion(
        prompt:
            'Self-siphonage of a trap occurs when:',
        choices: [
          'A nearby appliance discharges',
          'The appliance itself discharges a long slug of water',
          'Wind blows across the vent stack',
          'Water evaporates from the trap',
        ],
        correctIndex: 1,
        explanation:
            'A long discharge from the appliance itself can pull the seal out behind it.',
      ),
      QuizQuestion(
        prompt:
            'The standard fall on a 100 mm foul drain is:',
        choices: ['1 in 20', '1 in 40', '1 in 80', '1 in 200'],
        correctIndex: 1,
        explanation:
            'A 100 mm drain is usually laid at 1 in 40 to keep solids in suspension.',
      ),
      QuizQuestion(
        prompt:
            'A soil and vent pipe terminating outside must end at least:',
        choices: [
          '300 mm above any opening within 3 m',
          '600 mm above any opening within 3 m',
          '900 mm above any opening within 3 m',
          '1500 mm above any opening within 3 m',
        ],
        correctIndex: 2,
        explanation:
            'A vent terminal must be at least 900 mm above any window or opening within 3 m.',
      ),
      QuizQuestion(
        prompt: 'An air admittance valve (AAV) is fitted to:',
        choices: [
          'Discharge foul air outside',
          'Allow air in when negative pressure forms',
          'Provide drinking water backup',
          'Reduce mains pressure',
        ],
        correctIndex: 1,
        explanation:
            'An AAV opens to admit air, equalising pressure to protect trap seals, but stays closed against odour.',
      ),
      QuizQuestion(
        prompt:
            'Which of these is NOT a way a trap can lose its seal?',
        choices: [
          'Self-siphonage',
          'Induced siphonage',
          'Compression / back pressure',
          'Overpressurisation of the supply',
        ],
        correctIndex: 3,
        explanation:
            'Supply-side pressure does not affect a waste trap; loss of seal is a drainage-side problem.',
      ),
      QuizQuestion(
        prompt:
            'Drainage rodding access should be provided so that:',
        choices: [
          'Only every junction is accessible',
          'Every length of drain has access for clearing blockages',
          'Each room contains a rodding eye',
          'Only the soil stack base needs an access',
        ],
        correctIndex: 1,
        explanation:
            'Rodding points or chambers must allow every length of drain to be cleared.',
      ),
      QuizQuestion(
        prompt:
            'A bath waste typically uses a trap with:',
        choices: [
          '38 mm water seal',
          '50 mm water seal',
          '75 mm water seal',
          'No water seal at all',
        ],
        correctIndex: 0,
        explanation:
            'A bath has restricted depth so a shallow 38 mm trap is acceptable.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────────────
  QuizTopic(
    id: 'materials',
    title: 'Pipe materials and joints',
    category: 'Materials',
    summary:
        'Copper, plastic, joining methods and common errors.',
    questions: [
      QuizQuestion(
        prompt:
            'When making a compression joint, the correct technique after hand-tightening is:',
        choices: [
          'Three full turns with a spanner',
          'One full turn past hand tight, two spanners',
          'Tighten until the pipe deforms',
          'No spanner needed',
        ],
        correctIndex: 1,
        explanation:
            'Roughly one full turn past hand-tight, with two spanners (one on the body, one on the nut), avoids splitting the olive.',
      ),
      QuizQuestion(
        prompt:
            'Which lead-free solder alloy is suitable for capillary fittings on potable water pipework?',
        choices: ['Tin-lead 60/40', 'Tin-copper or tin-silver', 'Pure tin', 'Brass solder'],
        correctIndex: 1,
        explanation:
            'Tin-copper or tin-silver lead-free alloys are required for potable systems.',
      ),
      QuizQuestion(
        prompt:
            'Push-fit fittings on plastic pipe REQUIRE:',
        choices: [
          'A flux paste',
          'A pipe insert / support sleeve',
          'A solder ring',
          'A back nut',
        ],
        correctIndex: 1,
        explanation:
            'A support sleeve keeps the pipe round under the o-ring; without it the joint will leak.',
      ),
      QuizQuestion(
        prompt:
            'Plastic pipe must NOT be connected closer than what distance from a boiler?',
        choices: ['250 mm', '500 mm', '1000 mm', '2000 mm'],
        correctIndex: 2,
        explanation:
            'Most manufacturers require at least 1 m of metal pipe from the boiler outlet.',
      ),
      QuizQuestion(
        prompt:
            'A pipe slice is preferred to a hacksaw because:',
        choices: [
          'It is faster',
          'It produces a square clean cut without swarf',
          'It is cheaper',
          'It needs less skill',
        ],
        correctIndex: 1,
        explanation:
            'A pipe slice gives a square cut and leaves no swarf in the bore that could damage seals.',
      ),
      QuizQuestion(
        prompt:
            'Before making a soldered capillary joint, the pipe and socket should be:',
        choices: [
          'Painted',
          'Cleaned bright with wire wool then fluxed',
          'Sandblasted',
          'Heated to red hot',
        ],
        correctIndex: 1,
        explanation:
            'Bright copper plus flux lets the solder wet the metal cleanly during capillary action.',
      ),
      QuizQuestion(
        prompt:
            'When tightening a plastic push-fit, you should:',
        choices: [
          'Use jointing compound',
          'Push fully, mark insertion depth, pull back to confirm latched',
          'Tighten with a spanner',
          'Heat with a torch',
        ],
        correctIndex: 1,
        explanation:
            'Push to full depth, then pull back to verify the grab ring has engaged. No spanner is required.',
      ),
      QuizQuestion(
        prompt:
            'Copper tube standard sizes for domestic plumbing in the UK include:',
        choices: [
          '8 mm, 10 mm, 12 mm only',
          '15 mm, 22 mm, 28 mm',
          '20 mm, 25 mm, 32 mm',
          '½ inch and ¾ inch only',
        ],
        correctIndex: 1,
        explanation:
            'Standard UK domestic copper sizes are 15, 22 and 28 mm in BS EN 1057 R250.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────────────
  QuizTopic(
    id: 'regs_safety',
    title: 'Regulations and safety',
    category: 'Safety',
    summary: 'Water Regs, Gas Safe, electrical bonding and PPE.',
    questions: [
      QuizQuestion(
        prompt:
            'Who must carry out work on gas pipework or appliances?',
        choices: [
          'Any qualified plumber',
          'A Gas Safe registered engineer',
          'The home owner',
          'A building inspector',
        ],
        correctIndex: 1,
        explanation:
            'Only Gas Safe registered engineers may legally work on gas in the UK.',
      ),
      QuizQuestion(
        prompt:
            'Main equipotential bonding to incoming metal services should be made within what distance of the meter?',
        choices: ['100 mm', '300 mm', '600 mm', '1500 mm'],
        correctIndex: 2,
        explanation:
            'Main bonding is fitted within 600 mm of the meter or where the service enters the building.',
      ),
      QuizQuestion(
        prompt:
            'What is the UK national gas emergency number?',
        choices: [
          '999',
          '0800 111 999',
          '101',
          '0345 600 6611',
        ],
        correctIndex: 1,
        explanation:
            'For a smell of gas, call 0800 111 999 — the National Gas Emergency Service.',
      ),
      QuizQuestion(
        prompt:
            'Which document records the installation and commissioning of a domestic heating appliance?',
        choices: [
          'Site logbook',
          'Benchmark commissioning checklist',
          'CAR / Gas Safe Certificate of Compliance',
          'Both Benchmark and a Gas Safe certificate',
        ],
        correctIndex: 3,
        explanation:
            'A boiler installation requires both the Benchmark book completed and a Gas Safe notification.',
      ),
      QuizQuestion(
        prompt:
            'When soldering, you should keep a fire watch for at least:',
        choices: [
          '5 minutes',
          '15 minutes',
          '30 minutes',
          '2 hours',
        ],
        correctIndex: 2,
        explanation:
            'A 30-minute fire watch after leaving the area helps catch slow-smouldering ignition.',
      ),
      QuizQuestion(
        prompt:
            'The Water Supply (Water Fittings) Regulations exist primarily to prevent:',
        choices: [
          'Drainage failure',
          'Waste, misuse, undue consumption and contamination of water',
          'Excessive cost to consumers',
          'Boiler corrosion',
        ],
        correctIndex: 1,
        explanation:
            'The four core duties of the Water Regulations are to prevent waste, misuse, undue consumption and contamination.',
      ),
      QuizQuestion(
        prompt:
            'Installing an unvented hot water cylinder over 15 litres is:',
        choices: [
          'Permitted development for any plumber',
          'Notifiable building control work; requires a competent person',
          'Banned in dwellings',
          'Subject to gas safe registration only',
        ],
        correctIndex: 1,
        explanation:
            'It is notifiable under building regulations and must be carried out by a competent-person scheme installer.',
      ),
      QuizQuestion(
        prompt:
            'When you replace a length of metal pipe with plastic, the equipotential bond may be broken. You must:',
        choices: [
          'Leave it for the electrician',
          'Restore continuity before leaving site',
          'Remove the bond completely',
          'Connect bond to gas line instead',
        ],
        correctIndex: 1,
        explanation:
            'You must not leave site with a broken bond — restore continuity or escalate to an electrician.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────────────
  QuizTopic(
    id: 'rainwater',
    title: 'Rainwater and surface water',
    category: 'Rainwater',
    summary: 'Gutters, downpipes, soakaways and harvesting.',
    questions: [
      QuizQuestion(
        prompt:
            'A typical gutter fall is set at:',
        choices: [
          '1 in 60',
          '1 in 100',
          '1 in 600',
          '1 in 1000',
        ],
        correctIndex: 2,
        explanation:
            'Gutters fall at roughly 1 in 600 to the outlet — enough to drain, shallow enough not to look obviously sloped.',
      ),
      QuizQuestion(
        prompt:
            'The minimum distance of a soakaway from any building is:',
        choices: ['1 m', '3 m', '5 m', '10 m'],
        correctIndex: 2,
        explanation:
            'Soakaways must be at least 5 m from buildings to protect foundations.',
      ),
      QuizQuestion(
        prompt: 'Surface water should NEVER be discharged into:',
        choices: [
          'A soakaway',
          'A surface water sewer',
          'A foul sewer',
          'A watercourse with consent',
        ],
        correctIndex: 2,
        explanation:
            'Connecting surface water into a foul sewer overloads treatment works and is generally prohibited.',
      ),
      QuizQuestion(
        prompt:
            'A first-flush diverter on a rainwater harvesting system is used to:',
        choices: [
          'Reduce mains pressure',
          'Discard the initial debris-laden water',
          'Heat the water',
          'Filter sediment from the tank',
        ],
        correctIndex: 1,
        explanation:
            'The first-flush device dumps the dirty initial water before storage to keep the tank clean.',
      ),
      QuizQuestion(
        prompt:
            'Mains top-up to a rainwater harvesting tank must be via:',
        choices: [
          'A direct cross connection',
          'An air-gap break tank (Type AA)',
          'A simple ball valve',
          'A check valve only',
        ],
        correctIndex: 1,
        explanation:
            'A Type AA air gap is required to prevent contaminating the wholesome supply.',
      ),
      QuizQuestion(
        prompt:
            'A 68 mm round downpipe typically serves a roof area up to about:',
        choices: ['10 m²', '20 m²', '40 m²', '100 m²'],
        correctIndex: 2,
        explanation:
            'A 68 mm RWP serves around 40 m² of roof at typical UK design rainfall.',
      ),
      QuizQuestion(
        prompt:
            'BRE 365 is the test used to:',
        choices: [
          'Pressure test pipework',
          'Determine soil infiltration rate for a soakaway',
          'Check gutter falls',
          'Calibrate a flow meter',
        ],
        correctIndex: 1,
        explanation:
            'BRE Digest 365 sets out three sequential percolation tests; the worst result sizes the soakaway.',
      ),
      QuizQuestion(
        prompt:
            'Non-potable rainwater pipework supplying WCs must be:',
        choices: [
          'Painted blue',
          'Identical to wholesome pipework',
          'Clearly labelled and outlets warned non-potable',
          'Made of lead',
        ],
        correctIndex: 2,
        explanation:
            'Pipework and outlets must be labelled non-potable so no-one drinks from them by accident.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────────────
  QuizTopic(
    id: 'underfloor',
    title: 'Underfloor heating',
    category: 'Heating',
    summary: 'Manifolds, blending, loop length and commissioning.',
    questions: [
      QuizQuestion(
        prompt:
            'Typical UFH flow temperature is:',
        choices: ['20 °C', '40 °C', '60 °C', '80 °C'],
        correctIndex: 1,
        explanation:
            'A UFH circuit is normally 40 °C flow with about 30 °C return — a low-temperature emitter.',
      ),
      QuizQuestion(
        prompt:
            'Maximum loop length of 16 mm UFH pipe before pressure loss becomes excessive:',
        choices: ['25 m', '50 m', '100 m', '200 m'],
        correctIndex: 2,
        explanation:
            'Manufacturers cap 16 mm loops at around 100 m for normal pump duties.',
      ),
      QuizQuestion(
        prompt:
            'Floor surface temperature over occupied areas is limited to:',
        choices: ['22 °C', '29 °C', '35 °C', '45 °C'],
        correctIndex: 1,
        explanation:
            'BS EN 1264 limits floor surface temp to 29 °C in occupied zones for comfort.',
      ),
      QuizQuestion(
        prompt:
            'A blending unit on a UFH manifold drops the primary temperature by mixing flow with:',
        choices: [
          'Cold mains water',
          'Return water',
          'Stored hot water',
          'Steam',
        ],
        correctIndex: 1,
        explanation:
            'Blending mixes hot primary flow with cooler UFH return to hit the target circuit temperature.',
      ),
      QuizQuestion(
        prompt:
            'After laying screed over UFH, the system must be:',
        choices: [
          'Brought straight to design temperature',
          'Warmed up gradually over several days',
          'Left cold for a month',
          'Filled with antifreeze',
        ],
        correctIndex: 1,
        explanation:
            'Slow warm-up protects the curing screed from cracking.',
      ),
      QuizQuestion(
        prompt:
            'A UFH actuator is normally what type?',
        choices: [
          'Normally open, fail dangerous',
          'Normally closed, fail safe',
          'Spring open',
          'Hydraulically piloted',
        ],
        correctIndex: 1,
        explanation:
            'NC actuators close when de-energised or on power loss, which is the safe state.',
      ),
      QuizQuestion(
        prompt:
            'Pre-screed pressure test of UFH pipework is typically held at:',
        choices: ['1.5 bar', '3 bar', '6 bar', '10 bar'],
        correctIndex: 2,
        explanation:
            'A 6 bar test for at least 30 minutes is standard before screed is poured over the loops.',
      ),
      QuizQuestion(
        prompt:
            'Pipe centres in a main-room UFH layout are typically:',
        choices: ['50 mm', '150 mm', '300 mm', '600 mm'],
        correctIndex: 1,
        explanation:
            'About 150 mm pipe spacing in main rooms, sometimes tighter at perimeter zones.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────────────
  QuizTopic(
    id: 'pressure_testing',
    title: 'Pressure testing & commissioning',
    category: 'Process',
    summary:
        'Test medium, hold times, acceptance and recording.',
    questions: [
      QuizQuestion(
        prompt:
            'For pressure testing pipework, the correct medium is:',
        choices: ['Compressed air', 'Compressed CO₂', 'Water', 'Nitrogen'],
        correctIndex: 2,
        explanation:
            'Water is essentially incompressible — a leak releases little energy. Compressed gas is dangerous in a long pipe.',
      ),
      QuizQuestion(
        prompt:
            'Hydrostatic test pressure is normally what proportion of working pressure?',
        choices: [
          '1 ×',
          '1.5 ×',
          '3 ×',
          '5 ×',
        ],
        correctIndex: 1,
        explanation:
            'Test pressure is commonly 1.5 × maximum working pressure for at least 30 minutes.',
      ),
      QuizQuestion(
        prompt:
            'During a pressure test you observe a small pressure drop on a plastic system. This is:',
        choices: [
          'Always a leak — refuse the system',
          'Acceptable due to slight pipe expansion',
          'Caused by air in the line only',
          'Indicative of a passing valve',
        ],
        correctIndex: 1,
        explanation:
            'Plastic pipe expands slightly under pressure so a small drop is normal; rigid metal should hold.',
      ),
      QuizQuestion(
        prompt:
            'Air should be purged from pipework before pressure testing because:',
        choices: [
          'It looks tidier',
          'It can mask leaks and is dangerous if released suddenly',
          'It is heavier than water',
          'It contaminates the gauge',
        ],
        correctIndex: 1,
        explanation:
            'Trapped air stores energy; it can also rapidly absorb pressure changes that mask a leak.',
      ),
      QuizQuestion(
        prompt:
            'The most reliable way to find a small leak revealed by pressure decay is:',
        choices: [
          'A multimeter',
          'A paper towel walked along every joint',
          'Pouring inhibitor on each fitting',
          'Listening with a stethoscope only',
        ],
        correctIndex: 1,
        explanation:
            'A dry paper towel finds tiny weeps that the eye can miss — the standard manual technique.',
      ),
      QuizQuestion(
        prompt:
            'After a successful pressure test, you should:',
        choices: [
          'Leave the system pressurised',
          'Depressurise, inspect joints again, document on the install record',
          'Open every drain-off',
          'Re-fit a higher PRV',
        ],
        correctIndex: 1,
        explanation:
            'Depressurise carefully, do a final visual, and document the result for the customer record.',
      ),
      QuizQuestion(
        prompt:
            'A condensing boiler should achieve a flue gas CO₂ reading of approximately:',
        choices: [
          '2-3 % in natural gas',
          '4-5 % in natural gas',
          '8-10 % in natural gas',
          '14-16 % in natural gas',
        ],
        correctIndex: 2,
        explanation:
            'A correctly burning natural gas condensing boiler reads about 8-10 % CO₂.',
      ),
      QuizQuestion(
        prompt:
            'When commissioning a sealed heating system you should set the cold pressure to roughly:',
        choices: [
          '0.3 bar',
          '1.0 bar',
          '2.5 bar',
          '3.0 bar',
        ],
        correctIndex: 1,
        explanation:
            'About 1 bar cold gives roughly 1.5 bar hot, well below the 3 bar PRV setting.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────────────
  QuizTopic(
    id: 'fault_finding',
    title: 'Fault finding & boiler codes',
    category: 'Faults',
    summary: 'Reading the symptom, the gauge and the LCD code.',
    questions: [
      QuizQuestion(
        prompt:
            'A boiler displays low-pressure fault code F1 with the gauge at 0.3 bar. Your first action is:',
        choices: [
          'Replace the PCB',
          'Top up via the filling loop and look for a leak',
          'Replace the diverter',
          'Order a new boiler',
        ],
        correctIndex: 1,
        explanation:
            'Restore pressure to about 1 bar, watch the gauge over the next day or so to detect a leak before any parts are changed.',
      ),
      QuizQuestion(
        prompt:
            'A combi gives no hot water but central heating works fine. The most common cause is:',
        choices: [
          'Failed PCB',
          'Sticky diverter valve or scaled plate exchanger',
          'Blocked condensate',
          'Low gas pressure',
        ],
        correctIndex: 1,
        explanation:
            'If heating runs but DHW is cold, the diverter has failed to switch or the plate exchanger is bottlenecked by scale.',
      ),
      QuizQuestion(
        prompt:
            'A boiler locks out in cold weather with code A02 / F19. The likely cause is:',
        choices: [
          'Frozen condensate trap or external condensate pipe',
          'Failed gas valve',
          'Failed thermostat',
          'Low water pressure',
        ],
        correctIndex: 0,
        explanation:
            'A02 / F19 codes typically indicate a blocked condensate, often frozen in winter.',
      ),
      QuizQuestion(
        prompt:
            'A whistling, kettling boiler with reduced efficiency is most likely due to:',
        choices: [
          'A loose flue',
          'Limescale on the heat exchanger',
          'Air in the radiators',
          'Mains pressure too high',
        ],
        correctIndex: 1,
        explanation:
            'Scale on the HX surface causes localised boiling and the characteristic kettling noise.',
      ),
      QuizQuestion(
        prompt:
            'Pressure on a sealed system rises sharply when hot then falls below 1 bar when cold. The most likely cause is:',
        choices: [
          'A passing PRV',
          'A failed expansion vessel',
          'A blocked AAV',
          'A stuck zone valve',
        ],
        correctIndex: 1,
        explanation:
            'A waterlogged or failed expansion vessel cannot absorb expansion; pressure cycles widely between hot and cold.',
      ),
      QuizQuestion(
        prompt:
            'Customer reports a "running" WC. Lift the lid and water is at the correct level but a steady drip enters the pan. The fault is:',
        choices: [
          'Float valve fails to shut off',
          'Flush valve diaphragm leaking',
          'Cracked cistern',
          'Blocked overflow',
        ],
        correctIndex: 1,
        explanation:
            'If level is correct but water keeps entering the pan, the flush valve diaphragm is leaking.',
      ),
      QuizQuestion(
        prompt:
            'Bad smell from a seldom-used downstairs cloakroom. The most common cause is:',
        choices: [
          'A burst pipe',
          'A dried-out trap seal',
          'A failed PRV',
          'Low water pressure',
        ],
        correctIndex: 1,
        explanation:
            'Evaporation empties the seal in seldom-used appliances; topping up with water restores it instantly.',
      ),
      QuizQuestion(
        prompt:
            'Banging pipes when a washing machine valve shuts is best mitigated by:',
        choices: [
          'Increasing mains pressure',
          'Fitting a water hammer arrestor near the appliance',
          'Removing pipe clips',
          'Fitting an additional check valve',
        ],
        correctIndex: 1,
        explanation:
            'A piston or stub arrestor close to the offending appliance absorbs the surge and stops the banging.',
      ),
    ],
  ),
];

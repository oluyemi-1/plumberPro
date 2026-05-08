import 'quiz_data.dart';

/// Quiz banks for the Renewables module.
const renewablesQuizTopics = <QuizTopic>[
  QuizTopic(
    id: 'renewables_basics',
    title: 'Renewables fundamentals',
    category: 'Renewables',
    summary:
        'Heat pump cycle, COP and SCOP, MCS, Boiler Upgrade Scheme and low flow temperature design.',
    questions: [
      QuizQuestion(
        prompt:
            'In an air-source heat pump cycle, where is heat absorbed from the outside air?',
        choices: [
          'At the condenser',
          'At the compressor',
          'At the evaporator',
          'At the expansion valve',
        ],
        correctIndex: 2,
        explanation:
            'Liquid refrigerant boils into vapour in the outdoor evaporator coil, and that phase change is what absorbs heat from the air.',
      ),
      QuizQuestion(
        prompt:
            'Which value best describes a heat pump\'s real efficiency over a UK heating season?',
        choices: ['COP', 'EER', 'SCOP', 'SEER'],
        correctIndex: 2,
        explanation:
            'SCOP, the Seasonal Coefficient of Performance, averages efficiency across the seasonal range of outside temperatures and is the more honest indicator of running cost.',
      ),
      QuizQuestion(
        prompt:
            'A heat pump produces 4 kW of heat for every 1 kW of electrical input. Its COP is:',
        choices: ['0.25', '1', '4', '5'],
        correctIndex: 2,
        explanation:
            'COP is heat out divided by electricity in, so 4 kW out / 1 kW in equals a COP of 4.',
      ),
      QuizQuestion(
        prompt:
            'What is currently the Boiler Upgrade Scheme grant towards an air-source heat pump in England?',
        choices: ['2500 pounds', '5000 pounds', '7500 pounds', '10000 pounds'],
        correctIndex: 2,
        explanation:
            'The BUS grant in England and Wales is 7500 pounds for an air-source heat pump and the same for a ground-source unit.',
      ),
      QuizQuestion(
        prompt: 'For a customer to claim the BUS grant, the install must be:',
        choices: [
          'OFTEC registered only',
          'Carried out by an MCS certified contractor',
          'Notified to Building Control only',
          'Approved by the energy supplier',
        ],
        correctIndex: 1,
        explanation:
            'The BUS rules require that the work is carried out and certified by an MCS contractor.',
      ),
      QuizQuestion(
        prompt: 'A typical heat pump heating circuit is designed to run at:',
        choices: [
          'A flow temperature of 80 degrees C',
          'A flow temperature of 35 to 45 degrees C',
          'A flow temperature below 20 degrees C',
          'Whatever the boiler control sets',
        ],
        correctIndex: 1,
        explanation:
            'Heat pumps work best at low flow temperatures, typically 35 to 45 degrees, which is why emitters are often upsized.',
      ),
      QuizQuestion(
        prompt:
            'Why are radiators often upsized when converting a property from boiler to heat pump?',
        choices: [
          'To reduce the system pressure',
          'To make the install look tidier',
          'Because lower flow temperatures need a larger emitter to give the same output',
          'To stop the pump cavitating',
        ],
        correctIndex: 2,
        explanation:
            'A radiator gives less output at 45 degrees than at 75 degrees, so its surface area must increase to deliver the design heat loss.',
      ),
      QuizQuestion(
        prompt:
            'In the refrigerant cycle, what is the role of the expansion valve?',
        choices: [
          'To raise refrigerant pressure',
          'To absorb heat from the air',
          'To drop the pressure so the refrigerant can evaporate again',
          'To switch the cycle between heating and cooling',
        ],
        correctIndex: 2,
        explanation:
            'The expansion valve drops pressure on the high-pressure liquid leaving the condenser so it can evaporate at a low temperature in the outdoor coil.',
      ),
    ],
  ),
  QuizTopic(
    id: 'renewables_install',
    title: 'Renewables installation',
    category: 'Renewables',
    summary:
        'Ground loops, ASHP noise, PV inverter, MVHR balancing and condensate disposal in the field.',
    questions: [
      QuizQuestion(
        prompt: 'A horizontal slinky for a ground-source heat pump is normally laid at a depth of:',
        choices: ['300 mm', '600 mm', '1.2 m', '3 m'],
        correctIndex: 2,
        explanation:
            'Slinky trenches are dug to roughly 1.2 metres so the pipework sits below the seasonal frost line and in stable soil temperatures.',
      ),
      QuizQuestion(
        prompt:
            'Under MCS 020, the maximum sound from a domestic outdoor ASHP at the neighbour boundary is approximately:',
        choices: ['25 dB(A)', '42 dB(A)', '60 dB(A)', '85 dB(A)'],
        correctIndex: 1,
        explanation:
            'The MCS 020 noise calculation must show the assessed sound is at or below 42 dB(A) at the assessment position.',
      ),
      QuizQuestion(
        prompt: 'A solar PV string inverter:',
        choices: [
          'Converts AC from the panels to DC for the grid',
          'Converts DC from the panels to AC at 230 V 50 Hz',
          'Steps grid voltage down for the panels',
          'Stores energy in capacitors for night use',
        ],
        correctIndex: 1,
        explanation:
            'The inverter converts the DC output of the array into a clean AC waveform synchronised with the 230 V 50 Hz grid.',
      ),
      QuizQuestion(
        prompt:
            'What is the typical heat extraction rate for a horizontal slinky in average UK soil?',
        choices: [
          '5 to 10 W per square metre',
          '30 to 40 W per square metre',
          '100 to 150 W per square metre',
          '500 W per square metre',
        ],
        correctIndex: 1,
        explanation:
            'A useful sizing rule of thumb is 30 to 40 watts of heat extraction per square metre of slinky ground area.',
      ),
      QuizQuestion(
        prompt:
            'In an MVHR system, supply terminals are normally placed in:',
        choices: [
          'Bathrooms and the kitchen',
          'WC compartments only',
          'Habitable rooms such as bedrooms and the lounge',
          'Outside the property',
        ],
        correctIndex: 2,
        explanation:
            'Fresh filtered air is supplied to bedrooms and living areas, while stale air is extracted from wet rooms.',
      ),
      QuizQuestion(
        prompt:
            'During MVHR commissioning, a measured air flow at each terminal must normally be within what tolerance of design?',
        choices: [
          'Plus or minus 1 percent',
          'Plus or minus 10 percent',
          'Plus or minus 25 percent',
          'No tolerance, must be exact',
        ],
        correctIndex: 1,
        explanation:
            'Each terminal is adjusted until the measured flow is within plus or minus 10 percent of the designed value.',
      ),
      QuizQuestion(
        prompt:
            'Where can a heat pump condensate pipe terminate to comply with current best practice?',
        choices: [
          'Internally into a sealed empty container',
          'Direct to the soil stack with no air break',
          'Via a trapped tundish to a soakaway or external gully, with frost protection',
          'Discharged onto the path so it evaporates',
        ],
        correctIndex: 2,
        explanation:
            'Condensate is mildly acidic and must drain via a trap to a suitable point such as a soakaway, with trace heating or limestone fill to prevent freezing.',
      ),
      QuizQuestion(
        prompt:
            'In an MVHR unit, the typical filter classes used on supply and extract are:',
        choices: [
          'F7 supply, G4 extract',
          'G2 both sides',
          'HEPA H14 supply, none on extract',
          'Carbon supply, F7 extract',
        ],
        correctIndex: 0,
        explanation:
            'A coarser G4 panel filter protects the extract, while an F7 fine filter is used on the supply to remove pollen and fine particles before air enters the dwelling.',
      ),
    ],
  ),
];

import 'quiz_data.dart';

const commercialGasQuizTopics = <QuizTopic>[
  QuizTopic(
    id: 'comm_gas_basics',
    title: 'Commercial gas fundamentals',
    category: 'Commercial gas',
    summary:
        'Test core knowledge of IGEM standards, ACS qualifications, pressure tiers, materials and BS 6644 essentials.',
    questions: <QuizQuestion>[
      QuizQuestion(
        prompt:
            'Which IGEM standard governs the design and installation of commercial steel and copper gas pipework above the domestic threshold?',
        choices: <String>['IGEM/UP/1', 'IGEM/UP/2', 'IGEM/UP/4', 'IGEM/UP/10'],
        correctIndex: 1,
        explanation:
            'IGEM/UP/2 covers installation pipework on industrial and commercial premises. UP/1 is tightness testing, UP/4 is commissioning and UP/10 is installation in industrial and commercial buildings.',
      ),
      QuizQuestion(
        prompt: 'What is the upper limit of the low-pressure (LP) tier in commercial natural gas work?',
        choices: <String>['21 mbar', '50 mbar', '75 mbar', '100 mbar'],
        correctIndex: 2,
        explanation:
            'LP is defined as up to and including 75 mbar. Typical working pressure downstream of the meter governor is 21 mbar, but the tier extends to 75 mbar.',
      ),
      QuizQuestion(
        prompt:
            'An engineer is performing core gas safety duties on commercial natural-gas pipework and appliances. Which ACS category is the foundation requirement?',
        choices: <String>['CCN1', 'COCNGI1', 'CMET1', 'CKR1'],
        correctIndex: 1,
        explanation:
            'COCNGI1 is the core commercial natural gas installation category. CCN1 is the domestic core; CMET1 covers metering and CKR1 is domestic cookers.',
      ),
      QuizQuestion(
        prompt: 'Which qualification covers tightness testing and direct purging on commercial pipework?',
        choices: <String>['CDGA1', 'TPCP1', 'ICPN1', 'CIGA1'],
        correctIndex: 1,
        explanation:
            'TPCP1 (sometimes TPCP1A) is the tightness testing and direct purging category. ICPN1 covers commercial pipework, CIGA1 indirect-fired appliances and CDGA1 direct-fired.',
      ),
      QuizQuestion(
        prompt: 'BS 6644 applies to gas-fired boilers with what range of individual net heat inputs?',
        choices: <String>[
          'Up to 70 kW',
          'Above 70 kW up to 1.8 MW',
          '1.8 MW to 8 MW',
          'Above 8 MW only',
        ],
        correctIndex: 1,
        explanation:
            'BS 6644 covers single boilers above 70 kW net up to 1.8 MW, with total plant input up to 8 MW. Below 70 kW falls under domestic-style standards; above 1.8 MW per unit needs IGE guidance.',
      ),
      QuizQuestion(
        prompt:
            'When sizing LP pipework at 21 mbar working pressure, what is the maximum permitted total pressure drop from meter outlet to the most remote appliance?',
        choices: <String>['0.5 mbar', '1.0 mbar', '2.5 mbar', '5.0 mbar'],
        correctIndex: 1,
        explanation:
            'IGEM/UP/2 sizing aims to keep total drop within 1 mbar so the appliance receives at least 19 mbar at full load.',
      ),
      QuizQuestion(
        prompt:
            'Which mild-steel pipe specification is most commonly used for screwed and welded commercial gas mains?',
        choices: <String>['BS EN 1057', 'BS EN 10255 (formerly BS 1387)', 'BS 6362', 'BS EN 1254'],
        correctIndex: 1,
        explanation:
            'Heavy-grade steel tube to BS EN 10255 (the successor to BS 1387) is the standard for commercial gas mains. BS EN 1057 is copper tube.',
      ),
      QuizQuestion(
        prompt:
            'Under BS 1710, what is the basic identification colour and lettering used to mark exposed gas pipework?',
        choices: <String>[
          'Yellow ochre with the word GAS',
          'Light blue with the word AIR',
          'Green with a yellow band',
          'Silver-grey with the word STEAM',
        ],
        correctIndex: 0,
        explanation:
            'BS 1710 specifies yellow ochre as the basic colour for gas with the word GAS in black on the safety colour band, plus directional flow arrows.',
      ),
    ],
  ),
  QuizTopic(
    id: 'tightness_testing',
    title: 'Tightness testing & purging',
    category: 'Commercial gas',
    summary:
        'Check your understanding of UP/1 and UP/1A criteria, stabilisation, allowable drops, purging and certification.',
    questions: <QuizQuestion>[
      QuizQuestion(
        prompt: 'IGEM/UP/1A may be used in place of the full UP/1 procedure when the installation meets which limits?',
        choices: <String>[
          'Any size, up to 75 mbar',
          'Up to DN 50 and installation volume not exceeding 1 m3 at 21 mbar',
          'Up to DN 100 at any pressure',
          'Domestic installations only',
        ],
        correctIndex: 1,
        explanation:
            'UP/1A is the simplified procedure for small LP commercial systems up to DN 50 with installation volume up to 1 m3 at 21 mbar working pressure.',
      ),
      QuizQuestion(
        prompt: 'Which test medium is required for the strength test on new commercial pipework above 21 mbar?',
        choices: <String>['Natural gas', 'Air or inert gas such as nitrogen', 'Carbon dioxide only', 'Water'],
        correctIndex: 1,
        explanation:
            'Strength tests on new pipework use air or an inert gas (commonly nitrogen). Natural gas may only be used for tightness testing on existing systems within prescribed limits.',
      ),
      QuizQuestion(
        prompt: 'During the let-by test, what observation invalidates the procedure and indicates a faulty isolation valve?',
        choices: <String>[
          'A pressure drop greater than the allowable',
          'A rise in pressure on the gauge',
          'No movement on the gauge',
          'Temperature change of 0.5 degrees Celsius',
        ],
        correctIndex: 1,
        explanation:
            'Any rise on the gauge during the let-by phase shows that gas is passing the upstream isolation valve, so the valve must be repaired or replaced before testing continues.',
      ),
      QuizQuestion(
        prompt: 'Why is a stabilisation period observed before the timed tightness test phase?',
        choices: <String>[
          'To allow leak detection fluid to dry',
          'To allow temperature equalisation between pipe wall and contained medium',
          'To purge moisture from the gauge',
          'To pressurise the test rig',
        ],
        correctIndex: 1,
        explanation:
            'Stabilisation lets the test medium reach thermal equilibrium with the pipework so apparent pressure changes during the test reflect real leakage rather than thermal effects.',
      ),
      QuizQuestion(
        prompt: 'What resolution is required for an electronic pressure gauge used on LP tightness tests?',
        choices: <String>['1 mbar', '0.5 mbar', '0.1 mbar or better', '10 Pa'],
        correctIndex: 2,
        explanation:
            'IGEM/UP/1 requires gauges with a resolution of 0.1 mbar or better at LP, with current calibration certificates that must be available on request.',
      ),
      QuizQuestion(
        prompt: 'Which method is normally used to purge installation volumes above 0.02 m3 on commercial work?',
        choices: <String>[
          'Direct displacement with the supply gas, or fan-assisted purging',
          'Vacuum extraction',
          'Steam injection',
          'CO2 flooding',
        ],
        correctIndex: 0,
        explanation:
            'IGEM/UP/1 Section 9 sets out direct displacement using the supply gas, or fan-assisted purging through a temporary stack on larger volumes, with a safe discharge point.',
      ),
      QuizQuestion(
        prompt: 'What gas concentration at the purge discharge confirms complete air displacement?',
        choices: <String>['10 percent gas', '50 percent gas', '90 percent gas on two consecutive readings', '100 percent gas'],
        correctIndex: 2,
        explanation:
            'Two consecutive readings of 90 percent gas or above at the discharge point confirm that the air has been fully displaced and the installation may be lit through.',
      ),
      QuizQuestion(
        prompt: 'Which detail is NOT required on a commercial tightness test certificate?',
        choices: <String>[
          'Instrument serial number and calibration date',
          'Allowable and actual pressure drop',
          'Ambient temperature at start and finish',
          'Cost of the materials installed',
        ],
        correctIndex: 3,
        explanation:
            'Material costs do not feature on the test record. The certificate must show test pressures, durations, drops, ambient temperature, instrument identity and calibration status, and the operatives ACS reference.',
      ),
    ],
  ),
];

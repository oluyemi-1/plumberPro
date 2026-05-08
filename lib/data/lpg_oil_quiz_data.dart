import 'quiz_data.dart';

const lpgOilQuizTopics = <QuizTopic>[
  QuizTopic(
    id: 'lpg_oil_basics',
    title: 'LPG and oil installations',
    category: 'LPG / Oil',
    summary:
        'Regulator pressure, separation distances, bunding, fire valve location and OFTEC competence requirements.',
    questions: [
      QuizQuestion(
        prompt:
            'What is the standard appliance working pressure for a domestic propane installation in the UK?',
        choices: ['21 mbar', '28 mbar', '37 mbar', '50 mbar'],
        correctIndex: 2,
        explanation:
            'Propane is regulated to 37 mbar at the appliance by the second-stage regulator. Natural gas is 21 mbar and butane is 28 mbar.',
      ),
      QuizQuestion(
        prompt:
            'Under UKLPG Code of Practice 1, what is the typical minimum separation between a 1200 L above-ground LPG tank and any building opening, drain or ignition source?',
        choices: ['1 metre', '1.5 metres', '3 metres', '7.5 metres'],
        correctIndex: 2,
        explanation:
            'A 3 m straight-line separation is the standard for tanks up to about 2500 L. A purpose-built fire wall to 30 minute integrity allows the distance to be measured around the wall.',
      ),
      QuizQuestion(
        prompt:
            'A single-skin oil tank holds 1300 L of kerosene. What is the minimum capacity of the secondary masonry bund?',
        choices: ['1300 L', '1430 L', '1560 L', '2600 L'],
        correctIndex: 1,
        explanation:
            'A bund must contain at least 110 per cent of the tank volume. 1300 L times 1.1 equals 1430 L, allowing for rainwater and surge.',
      ),
      QuizQuestion(
        prompt:
            'On a domestic oil-fired boiler installation, where should the fire valve sensing element be located?',
        choices: [
          'At the tank outlet',
          'Halfway along the supply line',
          'At the appliance, sensing the burner area',
          'Inside the boiler casing on the return',
        ],
        correctIndex: 2,
        explanation:
            'The fire valve sensor sits at the appliance so that high temperatures from a burner-room fire trip the remote valve at the tank, isolating fuel.',
      ),
      QuizQuestion(
        prompt:
            'What is the function of an OPSO valve fitted to a bulk LPG regulator set?',
        choices: [
          'It opens to vent excess pressure to atmosphere',
          'It latches closed if downstream pressure rises above a safe limit',
          'It maintains 75 mbar across the service line',
          'It bleeds air from the second-stage regulator',
        ],
        correctIndex: 1,
        explanation:
            'OPSO stands for over-pressure shut-off. It latches closed on high downstream pressure and must be manually reset after the fault is found.',
      ),
      QuizQuestion(
        prompt:
            'A pressure-jet kerosene burner is being commissioned. What pump pressure range is typical at the nozzle for a domestic boiler?',
        choices: ['1 to 2 bar', '3 to 5 bar', '7 to 10 bar', '15 to 20 bar'],
        correctIndex: 2,
        explanation:
            'Domestic pressure-jet burners run between 7 and 10 bar at the nozzle, with the exact figure taken from the appliance data badge.',
      ),
      QuizQuestion(
        prompt:
            'During combustion analysis on a kerosene boiler, what smoke number on the Bacharach scale indicates a clean burn?',
        choices: ['0 to 1', '2 to 3', '4 to 5', '6 to 9'],
        correctIndex: 0,
        explanation:
            'A correctly set kerosene burner produces a smoke number of 0 or 1. Anything higher indicates soot, wrong nozzle, low pump pressure or insufficient air.',
      ),
      QuizQuestion(
        prompt:
            'Which competence is required to notify a domestic oil-fired boiler installation under the OFTEC Competent Persons Scheme?',
        choices: [
          'Gas Safe ACS CCN1',
          'OFTEC OFT 50 and OFT 101 (or 105E for cookers)',
          'WRAS approved plumber',
          'Part P electrical registration',
        ],
        correctIndex: 1,
        explanation:
            'OFT 50 covers oil storage and supply, OFT 101 the boiler/burner. OFT 105E covers oil-fired range cookers. Without these the installation must go through Building Control.',
      ),
    ],
  ),
];

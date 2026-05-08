import 'quiz_data.dart';

const fuelsQuizTopics = <QuizTopic>[
  QuizTopic(
    id: 'fuels_basics',
    title: 'Fuels and combustion basics',
    category: 'Fuels',
    summary:
        'Calorific value, gross vs net, products of combustion and CO health hazards.',
    questions: [
      QuizQuestion(
        prompt:
            'Which two products are the desired output of complete combustion of a hydrocarbon fuel?',
        choices: [
          'Carbon monoxide and hydrogen',
          'Carbon dioxide and water vapour',
          'Methane and oxygen',
          'Soot and nitrogen',
        ],
        correctIndex: 1,
        explanation:
            'Complete combustion of a hydrocarbon yields CO2 and H2O along with the released heat.',
      ),
      QuizQuestion(
        prompt:
            'Why is UK boiler efficiency now quoted against the GROSS calorific value rather than net?',
        choices: [
          'To make boilers look less efficient',
          'Because condensing boilers recover latent heat from the water vapour',
          'Because gross is always smaller',
          'Because net is illegal in the UK',
        ],
        correctIndex: 1,
        explanation:
            'Modern condensing boilers actually capture latent heat in the flue gas, so gross is the honest reference.',
      ),
      QuizQuestion(
        prompt:
            'A healthy natural gas appliance reads roughly:',
        choices: [
          'CO2 around 2 percent and O2 around 18 percent',
          'CO2 around 9 percent and O2 around 4 to 5 percent',
          'CO2 around 14 percent and O2 around 0 percent',
          'CO2 around 6 percent and O2 around 12 percent',
        ],
        correctIndex: 1,
        explanation:
            'Around 9 percent CO2 with 4 to 5 percent O2 indicates good combustion with sensible excess air.',
      ),
      QuizQuestion(
        prompt:
            'Carbon monoxide is dangerous primarily because it:',
        choices: [
          'Smells very strongly',
          'Bonds to haemoglobin far more readily than oxygen',
          'Is highly explosive at low concentration',
          'Is heavier than air and pools',
        ],
        correctIndex: 1,
        explanation:
            'CO binds to haemoglobin about 240 times more readily than oxygen, starving the body of oxygen with no warning smell.',
      ),
      QuizQuestion(
        prompt:
            'A CO/CO2 ratio above which figure indicates a dangerous appliance that must be taken off and reported?',
        choices: ['0.0004', '0.004', '0.02', '0.2'],
        correctIndex: 2,
        explanation:
            'Standard limit is 0.004; the action limit is 0.008; above 0.02 the appliance is immediately dangerous.',
      ),
      QuizQuestion(
        prompt:
            'Stoichiometric combustion of natural gas requires approximately how many volumes of air per volume of gas?',
        choices: ['1', '5', '10', '25'],
        correctIndex: 2,
        explanation:
            'Roughly 10 volumes of air per volume of natural gas is the chemically perfect ratio.',
      ),
      QuizQuestion(
        prompt:
            'Excess air is added to a burner mainly to:',
        choices: [
          'Cool the heat exchanger',
          'Ensure complete combustion despite imperfect mixing',
          'Increase the flame length',
          'Reduce the boiler noise',
        ],
        correctIndex: 1,
        explanation:
            'Around 15-25 percent excess air guarantees every fuel molecule meets enough oxygen to burn cleanly.',
      ),
      QuizQuestion(
        prompt:
            'Standard inlet pressure at a UK natural gas appliance governor is:',
        choices: ['10 mbar', '21 mbar', '37 mbar', '75 mbar'],
        correctIndex: 1,
        explanation:
            'UK natural gas is supplied at 21 mbar working pressure; LPG is at 37 mbar.',
      ),
    ],
  ),
  QuizTopic(
    id: 'flues_install',
    title: 'Flues and fuel installations',
    category: 'Fuels',
    summary:
        'Flue classes, terminal clearances, balanced flues, oil bunds and fire valves.',
    questions: [
      QuizQuestion(
        prompt:
            'A fanned balanced flue terminal must be at least how far below an opening window?',
        choices: ['75 mm', '150 mm', '300 mm', '600 mm'],
        correctIndex: 2,
        explanation:
            'Approved Document J and BS 5440 require at least 300 mm below an opening window for a fanned balanced flue.',
      ),
      QuizQuestion(
        prompt:
            'Class I in the flue terminology refers to:',
        choices: [
          'A balanced flue',
          'A fan-assisted flue',
          'An open flue connected to a chimney',
          'A class FL concentric flue',
        ],
        correctIndex: 2,
        explanation:
            'Class I describes an open-flued appliance using a chimney; combustion air comes from the room.',
      ),
      QuizQuestion(
        prompt:
            'A balanced flue terminal is concentric so that:',
        choices: [
          'It looks neater',
          'It draws air from outside and discharges flue gas through the same terminal',
          'It can be cleaned more easily',
          'It uses less material',
        ],
        correctIndex: 1,
        explanation:
            'A concentric balanced flue takes outside air through one annulus and discharges products through the other.',
      ),
      QuizQuestion(
        prompt:
            'On an oil tank installation, the bund must contain a minimum of:',
        choices: [
          '50 percent of tank capacity',
          '75 percent of tank capacity',
          '110 percent of tank capacity',
          '200 percent of tank capacity',
        ],
        correctIndex: 2,
        explanation:
            'OFTEC TI/133 requires the bund to retain at least 110 percent of the tank capacity in case of a full release.',
      ),
      QuizQuestion(
        prompt:
            'A remote-acting fire valve sensor on an oil-fired installation must be mounted:',
        choices: [
          'At the oil tank only',
          'Within 150 mm of the burner',
          'In the boiler flue',
          'On the kitchen ceiling',
        ],
        correctIndex: 1,
        explanation:
            'The fusible sensor sits within 150 mm of the burner so that a fire melts it and trips the valve at the supply line.',
      ),
      QuizQuestion(
        prompt:
            'A bulk LPG tank must normally be located at least how far from a building?',
        choices: ['1 m', '1.5 m', '3 m', '7 m'],
        correctIndex: 2,
        explanation:
            'Typical separation is 3 m from a building and 1.5 m from a boundary unless a fire wall is fitted.',
      ),
      QuizQuestion(
        prompt:
            'When inspecting an existing brick chimney for connection to a gas boiler, the usual requirement is:',
        choices: [
          'No liner needed',
          'A flexible stainless steel liner sized to the manufacturer table',
          'A galvanised mild steel liner',
          'Plastic flue liner only',
        ],
        correctIndex: 1,
        explanation:
            'Typically a 904 grade flexible stainless steel liner is fitted, sized from the boiler manufacturer table.',
      ),
      QuizQuestion(
        prompt:
            'Why is high-level ventilation alone insufficient for an LPG appliance space?',
        choices: [
          'LPG is lighter than air and rises quickly',
          'LPG is heavier than air and sinks, so low-level ventilation is required as well',
          'LPG smells too strongly to ignore',
          'LPG cannot ignite without oxygen at ceiling level',
        ],
        correctIndex: 1,
        explanation:
            'LPG vapour is heavier than air and pools at low level, so low-level ventilation and care near drains and cellars are essential.',
      ),
    ],
  ),
];

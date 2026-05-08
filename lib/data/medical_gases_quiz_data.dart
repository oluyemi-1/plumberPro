import 'quiz_data.dart';

/// Quiz topics covering Medical Gas Pipeline System fundamentals to
/// HTM 02-01 and BS EN ISO 7396-1.
const medicalGasesQuizTopics = <QuizTopic>[
  QuizTopic(
    id: 'mgps_basics',
    title: 'Medical gas pipeline fundamentals',
    category: 'Medical gases',
    summary:
        'HTM 02-01, pipeline pressures, terminal units, brazing under nitrogen and validation.',
    questions: [
      QuizQuestion(
        prompt:
            'Which UK guidance document sets out design and operational requirements for MGPS in NHS premises?',
        choices: [
          'HTM 04-01',
          'HTM 02-01',
          'HTM 03-01',
          'BS 6700',
        ],
        correctIndex: 1,
        explanation:
            'HTM 02-01 Parts A and B cover design, installation, validation and operational management of medical gas pipeline systems.',
      ),
      QuizQuestion(
        prompt:
            'The nominal pipeline distribution pressure for medical oxygen, 4 bar medical air and nitrous oxide is approximately:',
        choices: [
          '2.0 bar',
          '4.1 bar',
          '7.0 bar',
          '10 bar',
        ],
        correctIndex: 1,
        explanation:
            'These gases are distributed at a nominal 4.1 bar at the terminal unit; surgical air runs at 7 bar separately.',
      ),
      QuizQuestion(
        prompt:
            'Patient terminal units in the UK use which mechanical standard for the gas-specific probe?',
        choices: [
          'BS 1212',
          'BS 5682',
          'BS EN 1057',
          'BS 6920',
        ],
        correctIndex: 1,
        explanation:
            'BS 5682 specifies the gas-specific probe and socket for UK medical gas terminal units; equipment screw threads follow EN ISO 9170-1 (NIST).',
      ),
      QuizQuestion(
        prompt:
            'Why is an oxygen-free nitrogen purge required while silver brazing MGPS copper?',
        choices: [
          'To cool the joint quickly',
          'To prevent black cupric oxide scale forming inside the pipe',
          'To increase the strength of the braze',
          'To replace the need for filler rod',
        ],
        correctIndex: 1,
        explanation:
            'Without an inert purge the bore oxidises into loose black scale that can break free into the gas stream and block regulators and terminal units.',
      ),
      QuizQuestion(
        prompt: 'An Area Valve Service Unit (AVSU) is normally:',
        choices: [
          'Left open and unlabelled for quick access',
          'Locked closed only during maintenance',
          'Locked or secured shut against accidental closure, openable by key or break-glass in an emergency',
          'Operated automatically by the alarm panel',
        ],
        correctIndex: 2,
        explanation:
            'AVSUs are kept locked or secured to prevent accidental operation; they are only operated under permit-to-work or in a genuine emergency.',
      ),
      QuizQuestion(
        prompt:
            'Which validation test is intended to detect any unintended interconnection between two medical gases?',
        choices: [
          'Pressure decay test',
          'Cross connection test',
          'Particulate test',
          'Flow test',
        ],
        correctIndex: 1,
        explanation:
            'Each gas is pressurised in turn and every terminal of every other gas is checked for any pressure rise; even a small movement indicates a cross connection.',
      ),
      QuizQuestion(
        prompt:
            'Who issues the permit to work and signs the Quality Test Certificate before an MGPS is released for clinical use?',
        choices: [
          'The installing plumber',
          'The hospital electrician',
          'The Authorised Person for MGPS (AP-MGPS)',
          'The clinical matron',
        ],
        correctIndex: 2,
        explanation:
            'The Authorised Person for MGPS is the named individual who oversees permits to work and signs off validation before release to clinical use.',
      ),
      QuizQuestion(
        prompt:
            'Why must oxygen pipework be kept clear of oils, greases and combustible materials?',
        choices: [
          'Oils contaminate the taste of the gas',
          'Oxygen will oxidise the copper through grease',
          'In an enriched oxygen atmosphere the ignition energy of organic material is dramatically reduced and a fire can become explosive',
          'Grease blocks the regulator filter',
        ],
        correctIndex: 2,
        explanation:
            'Oxygen does not burn but it greatly accelerates combustion; oils, greases and even cotton fibres can ignite under conditions that would not normally cause fire.',
      ),
    ],
  ),
];

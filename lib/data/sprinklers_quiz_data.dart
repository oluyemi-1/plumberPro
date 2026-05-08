import 'quiz_data.dart';

/// Mid-difficulty quiz for UK domestic / residential fire sprinklers,
/// referencing BS 9251:2021 design and installation rules.
const sprinklersQuizTopics = <QuizTopic>[
  QuizTopic(
    id: 'sprinklers_basics',
    title: 'Sprinkler fundamentals',
    category: 'Sprinklers',
    summary:
        'K-factor flow, hazard categories, supply types, head temperatures and the relevant British Standards.',
    questions: [
      QuizQuestion(
        prompt:
            'A K80 sprinkler head is operating at 1.44 bar. What is the approximate flow at the head?',
        choices: [
          '57 l/min',
          '80 l/min',
          '96 l/min',
          '160 l/min',
        ],
        correctIndex: 2,
        explanation:
            'Q = K × √P. 80 × √1.44 = 80 × 1.2 = 96 l/min.',
      ),
      QuizQuestion(
        prompt:
            'Which British Standard covers fire sprinkler systems in residential and domestic premises?',
        choices: [
          'BS EN 12845',
          'BS 9990',
          'BS 9251:2021',
          'BS 5839',
        ],
        correctIndex: 2,
        explanation:
            'BS 9251:2021 is the residential and domestic sprinkler standard. BS EN 12845 covers commercial; BS 9990 covers rising mains.',
      ),
      QuizQuestion(
        prompt:
            'A BS 9251 Category 2 system is designed for what density and number of operating heads?',
        choices: [
          '4 mm/min, 1 head',
          '5 mm/min, 4 heads',
          '7.5 mm/min, 4 heads',
          '10 mm/min, 6 heads',
        ],
        correctIndex: 1,
        explanation:
            'Cat 2 residential is 5 mm/min over 12 m² with 4 heads operating simultaneously.',
      ),
      QuizQuestion(
        prompt:
            'Which BS 9251 supply type uses a stored water tank with a pump set and no town main contribution during a fire?',
        choices: [
          'Type 1 — boosted main',
          'Type 2 — mains only',
          'Type 3 — mains plus tank and pump',
          'Type 4 — tank and pump only',
        ],
        correctIndex: 3,
        explanation:
            'Type 4 is fully independent of the town main and is used where total reliability of supply is required.',
      ),
      QuizQuestion(
        prompt:
            'A typical residential sprinkler head used in living areas activates at:',
        choices: [
          '38 °C',
          '57 °C or 68 °C',
          '120 °C',
          '200 °C',
        ],
        correctIndex: 1,
        explanation:
            'Quick response residential heads are usually rated 57 °C or 68 °C; higher ratings are used in lofts and plant rooms.',
      ),
      QuizQuestion(
        prompt:
            'Which standard covers wet and dry rising mains for fire service use, NOT automatic sprinklers?',
        choices: [
          'BS 9251',
          'BS EN 12845',
          'BS 9990',
          'BS 7671',
        ],
        correctIndex: 2,
        explanation:
            'BS 9990 deals with rising mains. Automatic sprinkler design is BS 9251 (residential) or BS EN 12845 (commercial).',
      ),
      QuizQuestion(
        prompt:
            'Which orientation of sprinkler head is normally fitted hanging downward from a finished ceiling in a living room?',
        choices: [
          'Upright',
          'Sidewall',
          'Pendent',
          'Recessed in floor',
        ],
        correctIndex: 2,
        explanation:
            'A pendent head hangs below the ceiling so the deflector can spread water across the room when activated.',
      ),
      QuizQuestion(
        prompt:
            'In domestic sprinkler pipework that runs through an unheated loft, the BS 9251 preferred frost protection is:',
        choices: [
          'Pure water with no insulation',
          'Concentrated antifreeze with no air gap',
          'Reroute within the heated envelope, or insulate and trace heat',
          'A second header tank in the cold area',
        ],
        correctIndex: 2,
        explanation:
            'Keep pipework warm by routing or trace heating; antifreeze is a last resort because it can affect spray formation and requires a Type AB air gap.',
      ),
    ],
  ),
];

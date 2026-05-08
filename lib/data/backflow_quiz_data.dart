import 'quiz_data.dart';

/// Quiz topics covering UK backflow protection: fluid categories and the
/// devices used to keep each category separate from wholesome water.
const backflowQuizTopics = <QuizTopic>[
  QuizTopic(
    id: 'backflow_categories',
    title: 'Fluid categories',
    category: 'Backflow',
    summary:
        'Identifying the fluid category at common outlets and the protection it requires.',
    questions: [
      QuizQuestion(
        prompt:
            'Wholesome cold water at the rising main of a dwelling is which fluid category?',
        choices: ['Category 1', 'Category 2', 'Category 3', 'Category 5'],
        correctIndex: 0,
        explanation:
            'Category 1 is wholesome water as supplied by the water undertaker, fit to drink without further treatment.',
      ),
      QuizQuestion(
        prompt:
            'Hot wholesome water at a domestic kitchen mixer is which fluid category?',
        choices: ['Category 1', 'Category 2', 'Category 3', 'Category 4'],
        correctIndex: 1,
        explanation:
            'Heated wholesome water with no additive is a Category 2 — only the aesthetic quality has changed.',
      ),
      QuizQuestion(
        prompt:
            'Water in a domestic wash basin is which fluid category?',
        choices: ['Category 1', 'Category 2', 'Category 3', 'Category 5'],
        correctIndex: 2,
        explanation:
            'A wash basin is a slight health risk — Category 3 — because hands and toiletries contact the water.',
      ),
      QuizQuestion(
        prompt:
            'A domestic central heating circuit dosed with corrosion inhibitor is which fluid category?',
        choices: ['Category 2', 'Category 3', 'Category 4', 'Category 5'],
        correctIndex: 1,
        explanation:
            'Domestic heating water with inhibitor is Category 3 — slight health risk. Higher concentrations on commercial systems may rise to Category 4.',
      ),
      QuizQuestion(
        prompt:
            'A commercial dishwasher in a hotel kitchen is which fluid category?',
        choices: ['Category 2', 'Category 3', 'Category 4', 'Category 5'],
        correctIndex: 2,
        explanation:
            'Commercial dishwashers contain detergents and food residue and are classified Category 4 — significant health risk.',
      ),
      QuizQuestion(
        prompt:
            'A WC pan is which fluid category?',
        choices: ['Category 3', 'Category 4', 'Category 5', 'Category 2'],
        correctIndex: 2,
        explanation:
            'A WC pan contains pathogens and is Category 5 — only an air gap is acceptable backflow protection.',
      ),
      QuizQuestion(
        prompt:
            'An agricultural trough or irrigation outlet is which fluid category?',
        choices: ['Category 3', 'Category 4', 'Category 5', 'Category 1'],
        correctIndex: 2,
        explanation:
            'Animal contact and run off place agricultural and irrigation supplies firmly in Category 5.',
      ),
      QuizQuestion(
        prompt:
            'Which is the minimum acceptable backflow protection for a Category 5 outlet?',
        choices: [
          'Single check valve',
          'Double check valve',
          'A physical air gap such as Type AA, AB or AUK1',
          'A reduced pressure zone valve',
        ],
        correctIndex: 2,
        explanation:
            'Category 5 always requires a physical air gap. Mechanical valves, including RPZ, are not accepted on Category 5.',
      ),
    ],
  ),
  QuizTopic(
    id: 'backflow_devices',
    title: 'Backflow devices',
    category: 'Backflow',
    summary:
        'Picking the correct device for the job and the rules around RPZ testing.',
    questions: [
      QuizQuestion(
        prompt:
            'A domestic outside tap is normally protected by which device?',
        choices: [
          'Single check valve',
          'Double check valve',
          'Reduced pressure zone valve',
          'No protection required',
        ],
        correctIndex: 1,
        explanation:
            'A garden hose makes the tap a Category 3 risk minimum, so a double check valve is the standard fitting.',
      ),
      QuizQuestion(
        prompt:
            'A commercial dishwasher must be protected by:',
        choices: [
          'A double check valve only',
          'A Type AB air gap break tank or an RPZ valve',
          'A single check valve',
          'A Type AUK2 air gap',
        ],
        correctIndex: 1,
        explanation:
            'Category 4 requires Type AB, AD, or an RPZ — a DCV alone is no longer acceptable for commercial appliances.',
      ),
      QuizQuestion(
        prompt:
            'How often must an installed RPZ valve be tested in service?',
        choices: [
          'Every six months',
          'Annually by an approved tester',
          'Every five years',
          'Only at install',
        ],
        correctIndex: 1,
        explanation:
            'RPZ devices must be tested annually by an approved tester with the result logged with the water undertaker.',
      ),
      QuizQuestion(
        prompt:
            'AUK1 is the air gap found:',
        choices: [
          'At a domestic basin tap above the rim',
          'Inside a WC cistern between float valve and overflow',
          'Above a commercial sink',
          'On a hose union tap outdoors',
        ],
        correctIndex: 1,
        explanation:
            'AUK1 is the Category 5 air gap inside a WC cistern, between the float valve outlet and the critical water level.',
      ),
      QuizQuestion(
        prompt:
            'AUK2 is the air gap found at:',
        choices: [
          'A domestic tap discharging over a basin, sink or bath rim',
          'Inside a WC cistern',
          'A commercial dishwasher break tank',
          'A hose union tap',
        ],
        correctIndex: 0,
        explanation:
            'AUK2 protects to Category 3 — the gap at a domestic tap above the spillover of a basin, sink or bath.',
      ),
      QuizQuestion(
        prompt:
            'AUK3 is used where the risk is:',
        choices: [
          'Wholesome only',
          'Aesthetic change only',
          'Higher than AUK2 — commercial or higher Category 3 / 4 outlets',
          'Always Category 5',
        ],
        correctIndex: 2,
        explanation:
            'AUK3 is the larger gap used at non domestic appliances and at hose union taps where AUK2 is not enough.',
      ),
      QuizQuestion(
        prompt:
            'A washing machine in a domestic kitchen is normally protected by:',
        choices: [
          'A built in single check valve plus the AUK2 gap at the standpipe',
          'A Type AA air gap break tank',
          'An RPZ valve',
          'No backflow protection',
        ],
        correctIndex: 0,
        explanation:
            'For Category 3 a domestic washing machine relies on the integral SCV plus the AUK2 air gap above the standpipe rim.',
      ),
      QuizQuestion(
        prompt:
            'The relief outlet on an RPZ valve must:',
        choices: [
          'Be capped off',
          'Discharge into a visible tundish piped to a safe point',
          'Be plumbed directly into the foul drain',
          'Be left open into the room',
        ],
        correctIndex: 1,
        explanation:
            'The relief must discharge through a visible tundish to a safe point, so any failure is obvious and traceable.',
      ),
    ],
  ),
];

import 'quiz_data.dart';

/// Quiz topics covering UK electric boilers — paired with the lessons
/// in `electric_boiler_lessons_data.dart`. Questions are pitched at
/// working engineer level, not theory exam level.
const electricBoilerQuizTopics = <QuizTopic>[
  QuizTopic(
    id: 'electric_boiler_basics',
    title: 'Electric boilers — basics',
    category: 'Electric boiler',
    summary:
        'How an electric boiler works, where it suits a property, and the first-principles relationship between kilowatts and amps.',
    questions: [
      QuizQuestion(
        prompt:
            'A nine kilowatt single-phase electric boiler draws roughly what current when firing at full output?',
        choices: ['Ten amps', 'Twenty amps', 'Forty amps', 'Sixty amps'],
        correctIndex: 2,
        explanation:
            'Power in watts equals volts times amps. Nine thousand divided by two hundred and thirty gives about thirty-nine amps, so roughly forty amps. This is why a nine kilowatt boiler needs a dedicated forty amp circuit on a single-phase supply.',
      ),
      QuizQuestion(
        prompt:
            'Which property is most likely a good fit for an electric boiler?',
        choices: [
          'A four-bed detached house with mains gas already connected',
          'A first-floor flat with no gas supply and a thermal store',
          'A large rural farmhouse with cheap oil delivery',
          'A new build commercial unit with a high heat demand',
        ],
        correctIndex: 1,
        explanation:
            'Electric boilers shine where there is no gas, where flue routing is impossible, and where heat load is modest. Flats without gas and good cylinder storage are the textbook fit. They are usually too expensive to run for a big detached house with gas already on.',
      ),
      QuizQuestion(
        prompt:
            'Why is a magnetic system filter especially important on an electric boiler installation?',
        choices: [
          'Because electric boilers run at higher pressures than gas',
          'Because sludge causes element hot-spots and premature burn-out',
          'Because the law requires a filter on every electric heat source',
          'Because the filter improves SAP rating for Part L',
        ],
        correctIndex: 1,
        explanation:
            'An electric element relies on water in direct contact with its surface to carry heat away. Sludge insulates patches of the element, those spots overheat, and the element fails. A magnetic filter and an annual inhibitor check are the cheapest insurance you can buy on an electric install.',
      ),
      QuizQuestion(
        prompt:
            'Which of these is NOT typically found inside a wet-element electric boiler?',
        choices: [
          'A contactor or relay',
          'A flue gas analyser test point',
          'An overheat thermostat',
          'A flow-proving switch',
        ],
        correctIndex: 1,
        explanation:
            'Electric boilers have no flue and no combustion, so there is no test point for a flue gas analyser. The contactor switches the element on, the overheat thermostat protects against dry-fire, and the flow switch proves water is moving before the element is allowed to energise.',
      ),
      QuizQuestion(
        prompt: 'What does "staging" mean on a multi-element electric boiler?',
        choices: [
          'Running the boiler at different flow temperatures over the day',
          'Switching individual elements in or out so the boiler matches load in steps',
          'The yearly service procedure performed in stages',
          'The commissioning sequence used at handover',
        ],
        correctIndex: 1,
        explanation:
            'Staging means the PCB enables one element at a time as demand rises and disables them as demand falls. A nine kilowatt boiler with three three-kilowatt elements can run at three, six, or nine kilowatts — far better than a single nine-kilowatt block that is always all-or-nothing.',
      ),
      QuizQuestion(
        prompt:
            'A property has an existing 60 amp main fuse and the customer wants a 12 kilowatt electric boiler. What is the correct first action?',
        choices: [
          'Install the boiler — 60 amps is enough',
          'Recommend a supply upgrade via the DNO before installing',
          'Fit a smaller 6 kilowatt boiler and add immersion top-up',
          'Install the boiler with reduced output settings only',
        ],
        correctIndex: 1,
        explanation:
            'A twelve kilowatt boiler needs about fifty-two amps just for itself. With cooker, shower, and other loads on the same sixty amp main fuse the supply will not cope. The DNO can usually upgrade to one hundred amps; without that, the install is unsafe.',
      ),
      QuizQuestion(
        prompt:
            'Why are electric boilers far less common in instantaneous combi form than gas boilers are?',
        choices: [
          'They are heavier than gas combi boilers',
          'The kilowatt rating to heat flowing tap water on-the-fly is impractically high',
          'UK regulations specifically prohibit instantaneous electric DHW',
          'They cannot be installed in kitchens',
        ],
        correctIndex: 1,
        explanation:
            'A combi-style instantaneous hot water output needs around twenty-four kilowatts plus. The required electrical supply, cable size, and ongoing running cost make it unrealistic in most homes. Electric installs almost always include a thermal store or unvented cylinder instead.',
      ),
    ],
  ),
  QuizTopic(
    id: 'electric_boiler_install_regs',
    title: 'Electric boilers — install and regs',
    category: 'Electric boiler',
    summary:
        'Part P, BS 7671, Part L, G3 and the practical install rules that catch out engineers more used to gas.',
    questions: [
      QuizQuestion(
        prompt:
            'A new dedicated circuit for an electric boiler in a domestic property is which kind of work under Building Regulations?',
        choices: [
          'Non-notifiable, any competent person can complete it',
          'Notifiable under Part P — either a Part P registered electrician or a building notice is required',
          'Notifiable under Part L for energy efficiency only',
          'Subject only to Gas Safe registration rules',
        ],
        correctIndex: 1,
        explanation:
            'Adding a new circuit at the consumer unit is notifiable under Part P in England and Wales. As a plumber you can complete the wet-side install, but the circuit design and certification must come from a Part P registered electrician unless you notify via building control.',
      ),
      QuizQuestion(
        prompt:
            'Which protective device combination would you typically expect on the dedicated electric boiler circuit?',
        choices: [
          'A single MCB only, sized for the boiler current',
          'A type AC RCD on the main switch with no overcurrent protection',
          'An RCBO sized for the boiler current, providing both overcurrent and earth fault protection',
          'A 13 amp fused spur from a ring final circuit',
        ],
        correctIndex: 2,
        explanation:
            'A modern install uses an RCBO of the correct rating — for a nine kilowatt boiler typically a forty amp RCBO. It gives overcurrent protection like an MCB and thirty milliamp earth fault protection in one device. A fused spur from a ring is nowhere near rated for the load.',
      ),
      QuizQuestion(
        prompt:
            'Where the electric boiler is integrated with an unvented cylinder, which extra qualification or certification applies?',
        choices: [
          'A Gas Safe ACS qualification on hot water',
          'Unvented hot water G3 competent person certification',
          'An MCS heat pump installer accreditation',
          'A Legionella risk assessor qualification',
        ],
        correctIndex: 1,
        explanation:
            'Any unvented hot water system, no matter the heat source, requires a G3 competent person to install and certify it. The Heatrae Sadia Electromax and EHC Comet are examples of integrated electric-boiler-and-cylinder units that fall under G3.',
      ),
      QuizQuestion(
        prompt:
            'During electric boiler commissioning, why is the system flushed and dosed with inhibitor before first firing?',
        choices: [
          'To meet Part G requirements on potable water',
          'To prevent the immersed element from suffering scale and sludge damage during its first operating cycles',
          'To set the correct expansion vessel pressure',
          'To allow the contactor to seat properly',
        ],
        correctIndex: 1,
        explanation:
            'BS 7593 cleaning and inhibitor dosing protects every modern wet system, but it is especially critical with an immersed element which is in direct contact with the system water. A first-fire on dirty water can scale or pit the element surface and shorten its life dramatically.',
      ),
      QuizQuestion(
        prompt:
            'An electric boiler is replacing an old gas boiler in a domestic property with mains gas still connected. What additional documentation is recommended?',
        choices: [
          'Nothing extra — like-for-like swap',
          'Customer sign-off acknowledging that running costs and SAP rating may be higher than gas',
          'A Gas Safe disconnection notice only',
          'An MCS retrofit certificate',
        ],
        correctIndex: 1,
        explanation:
            'Switching from gas to electric on a property with gas already connected is allowed, but running costs and the property\'s SAP rating will usually worsen. Document the customer\'s informed decision in writing so there is no comeback later and so the work survives an EPC review at resale.',
      ),
      QuizQuestion(
        prompt:
            'Which of these wet-side fittings is most commonly skipped on an electric boiler install — and is the single most common reason for premature element failure?',
        choices: [
          'The filling loop',
          'The expansion vessel',
          'The magnetic system filter',
          'The automatic air vent',
        ],
        correctIndex: 2,
        explanation:
            'The magnetic filter on the return is often left out by installers used to assuming the boiler\'s own dirt trap is enough. With an immersed element, system magnetite collects against the element and causes hot spots. Fit the filter, service it annually, every time.',
      ),
    ],
  ),
];

import 'quiz_data.dart';

const commercialQuizTopics = <QuizTopic>[
  QuizTopic(
    id: 'commercial_systems',
    title: 'Commercial systems fundamentals',
    category: 'Commercial',
    summary:
        'Booster sets, calorifiers, cascade boilers, low-loss headers and secondary circulation in non-domestic buildings.',
    questions: [
      QuizQuestion(
        prompt:
            'A variable-speed pumped (VSP) booster set is preferred over a hydropneumatic set mainly because it:',
        choices: [
          'Costs less to install on a small project',
          'Holds outlet pressure smoothly and saves energy under varying demand',
          'Eliminates the need for a break tank upstream',
          'Removes the requirement for duty/standby pump arrangements',
        ],
        correctIndex: 1,
        explanation:
            'Inverter control on a VSP set ramps pump speed to match flow, holding a steady outlet pressure and reducing energy use compared with on/off cycling around an air vessel.',
      ),
      QuizQuestion(
        prompt:
            'In a tall building, what is the typical maximum static pressure aimed for at any outlet to protect taps, TMVs and appliances?',
        choices: ['About 2 bar', 'About 5 bar', 'About 8 bar', 'About 10 bar'],
        correctIndex: 1,
        explanation:
            'Pressure zoning and PRVs are normally arranged so that no outlet sees more than around 5 bar static, both for fittings life and to comply with manufacturer limits.',
      ),
      QuizQuestion(
        prompt:
            'A plate heat exchanger generating DHW with a small downstream buffer instead of a large calorifier mainly offers:',
        choices: [
          'Higher stored volume and slower legionella response',
          'Reduced stored hot water volume and quicker response',
          'Elimination of the need for any secondary circulation',
          'A guaranteed 60 °C delivery without further controls',
        ],
        correctIndex: 1,
        explanation:
            'PHEs heat instantaneously, so stored volume can be much smaller. This reduces stagnation risk and gives faster response, though primary control must be tighter.',
      ),
      QuizQuestion(
        prompt:
            'Why is a cascade of four 200 kW modulating boilers usually more efficient than a single 800 kW boiler on a commercial heating plant?',
        choices: [
          'A larger boiler always condenses better than smaller ones',
          'The cascade gives a much wider effective turndown so the plant matches part-load',
          'Single large boilers cannot meet UK Building Regulations',
          'Cascades remove the need for a low-loss header',
        ],
        correctIndex: 1,
        explanation:
            'Modulating four boilers gives turndown from full load down to a small fraction of one boiler, so the plant runs longer in the condensing band and avoids short-cycling.',
      ),
      QuizQuestion(
        prompt:
            'The primary purpose of a low-loss header in a cascade boiler installation is to:',
        choices: [
          'Act as the main expansion vessel for the system',
          'Hydraulically decouple primary boiler flow from variable secondary flow',
          'Replace the need for individual boiler isolation valves',
          'Increase static pressure on the secondary circuits',
        ],
        correctIndex: 1,
        explanation:
            'A low-loss header lets primary and secondary pumps run at different flow rates without one upsetting the other, while also acting as an air and dirt separator.',
      ),
      QuizQuestion(
        prompt:
            'In a primary-secondary heating arrangement, the primary circuit pumps:',
        choices: [
          'Are driven by the secondary circuits and have no pumps of their own',
          'Each serve their own boiler and feed the common header at constant flow',
          'Replace the need for any secondary pumps',
          'Modulate to follow building demand directly',
        ],
        correctIndex: 1,
        explanation:
            'In a classic primary-secondary layout each boiler has a dedicated primary pump giving stable flow through the boiler, while separate secondary pumps draw off the header to serve the loads.',
      ),
      QuizQuestion(
        prompt:
            'Secondary circulation on commercial DHW pipework is mandatory because:',
        choices: [
          'It increases the storage temperature of the calorifier',
          'It maintains 50 °C at outlets within a minute and avoids stagnant warm water',
          'It removes the need for any TMVs at outlets',
          'It is only a manufacturer recommendation, not a regulatory one',
        ],
        correctIndex: 1,
        explanation:
            'A secondary loop keeps the distribution above 55 °C and delivers 50 °C within a minute at outlets, preventing water sitting in the legionella growth window between uses.',
      ),
      QuizQuestion(
        prompt:
            'A point-of-use water heater is often the better choice when:',
        choices: [
          'It serves the busiest outlets in the building',
          'An outlet is remote, intermittently used and would form a long dead leg on the main loop',
          'The site has no electrical supply available',
          'L8 monitoring is not required at that outlet',
        ],
        correctIndex: 1,
        explanation:
            'POU heaters eliminate long lightly used branches, cut secondary pumping power and reduce legionella risk. They still need to appear in the L8 written scheme.',
      ),
    ],
  ),
  QuizTopic(
    id: 'water_hygiene',
    title: 'Water hygiene & L8',
    category: 'Commercial',
    summary:
        'HSE ACoP L8, HSG 274, named Responsible Persons, monitoring routines and the temperature regime for hot and cold water.',
    questions: [
      QuizQuestion(
        prompt:
            'The Approved Code of Practice L8 sits under which legal framework?',
        choices: [
          'The Building Safety Act 2022 alone',
          'The Health and Safety at Work etc. Act and COSHH Regulations',
          'The Water Industry Act 1991 only',
          'The Gas Safety (Installation and Use) Regulations 1998',
        ],
        correctIndex: 1,
        explanation:
            'L8 is approved guidance under HSWA and COSHH, and breach can lead to HSE enforcement action including prosecution of individuals and companies.',
      ),
      QuizQuestion(
        prompt:
            'Who must the duty-holder formally appoint to manage the day-to-day implementation of the L8 written scheme?',
        choices: [
          'The on-site cleaner',
          'A named, competent Responsible Person, in writing',
          'The water-supply company',
          'The local authority Environmental Health Officer',
        ],
        correctIndex: 1,
        explanation:
            'L8 requires a named, competent Responsible Person appointed in writing with the authority and resources to manage the scheme. Accountability still rests with the duty-holder.',
      ),
      QuizQuestion(
        prompt:
            'How often should TMVs serving vulnerable users typically have their mixed temperature and fail-safe shut-off checked under HSG 274?',
        choices: ['Daily', 'Monthly', 'Annually only', 'Every five years'],
        correctIndex: 1,
        explanation:
            'HSG 274 Part 2 calls for monthly mixed-temperature and fail-safe checks on TMVs in healthcare and similar settings, with full annual strip-down servicing.',
      ),
      QuizQuestion(
        prompt:
            'A capped branch left from a refurbishment, holding more than three litres of stagnant water, is best described as a:',
        choices: [
          'Loop branch',
          'Dead leg requiring removal back to the main',
          'Compliant isolation point',
          'Sentinel outlet',
        ],
        correctIndex: 1,
        explanation:
            'Such a branch is a classic dead leg. Best practice is to cut it back to the tee on the live main and cap at the tee to remove the stagnation risk.',
      ),
      QuizQuestion(
        prompt:
            'According to the standard 60-55-50 rule for commercial DHW, the flow at the cylinder outlet and the return temperature should not fall below:',
        choices: [
          '50 °C flow / 45 °C return',
          '60 °C flow / 55 °C return',
          '65 °C flow / 60 °C return',
          '55 °C flow / 50 °C return',
        ],
        correctIndex: 1,
        explanation:
            'Store at 60, distribute flow at 60, return at not less than 55 and deliver 50 within one minute at the outlet (55 in healthcare).',
      ),
      QuizQuestion(
        prompt:
            'Cold water should reach outlets below what temperature, within two minutes of running, to stay out of the legionella growth window?',
        choices: ['Below 30 °C', 'Below 25 °C', 'Below 20 °C', 'Below 15 °C'],
        correctIndex: 2,
        explanation:
            'HSG 274 requires cold water to be below 20 °C at the outlet within two minutes. Between 20 and 45 °C is the principal legionella growth band.',
      ),
      QuizQuestion(
        prompt:
            'Which of the following best describes a sentinel outlet for monthly temperature monitoring?',
        choices: [
          'Any outlet picked at random each month',
          'The nearest and the furthest outlet on each loop or branch',
          'Only outlets serving vulnerable users',
          'The outlet closest to the incoming main',
        ],
        correctIndex: 1,
        explanation:
            'Sentinel outlets are the closest and furthest from the heat source on each loop, giving a representative view of distribution temperatures for the monthly log.',
      ),
      QuizQuestion(
        prompt:
            'L8 monitoring records and the written scheme should typically be retained on site for at least:',
        choices: ['One year', 'Two years', 'Five years', 'Ten years'],
        correctIndex: 2,
        explanation:
            'The standard expectation is at least five years of records, kept available for inspection by the HSE and used to demonstrate compliance over time.',
      ),
    ],
  ),
];

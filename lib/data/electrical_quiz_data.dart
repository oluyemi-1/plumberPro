import 'quiz_data.dart';

/// Additional quiz topics on electrical principles for plumbers.
const electricalQuizTopics = <QuizTopic>[
  QuizTopic(
    id: 'electrical_basics',
    title: 'Electrical principles',
    category: 'Electrical',
    summary:
        'Volts, amps, watts and how a domestic supply is wired.',
    questions: [
      QuizQuestion(
        prompt: 'A 3 kW immersion heater on a 230 V supply draws roughly:',
        choices: ['0.13 A', '1.3 A', '13 A', '130 A'],
        correctIndex: 2,
        explanation:
            'I = P / V = 3000 / 230 ≈ 13 A. Hence the standard 13 A fused spur for an immersion heater.',
      ),
      QuizQuestion(
        prompt: 'Modern UK cable colours for line, neutral and earth are:',
        choices: [
          'Red, black, green',
          'Brown, blue, green and yellow',
          'Black, red, blue',
          'Yellow, blue, green',
        ],
        correctIndex: 1,
        explanation:
            'Harmonised colours since 2004: brown line, blue neutral, green/yellow earth.',
      ),
      QuizQuestion(
        prompt: 'An RCD typically trips at what residual current within how long?',
        choices: [
          '300 mA in 1 second',
          '30 mA in 40 milliseconds',
          '3 A in 100 milliseconds',
          '100 mA in 0.5 seconds',
        ],
        correctIndex: 1,
        explanation:
            'A 30 mA RCD in a domestic socket circuit must trip within 40 ms at 5 × rated to protect against electric shock.',
      ),
      QuizQuestion(
        prompt:
            'What does an MCB protect against?',
        choices: [
          'Overload and short circuit only',
          'Earth leakage only',
          'Both overload and earth leakage',
          'Lightning strikes',
        ],
        correctIndex: 0,
        explanation:
            'An MCB protects against overload and short circuit. RCDs protect against earth leakage; an RCBO combines both.',
      ),
      QuizQuestion(
        prompt:
            'Notifiable work under Building Regs Part P includes:',
        choices: [
          'Any new circuit, any consumer unit work, any work in special locations',
          'Only commercial electrical work',
          'Replacing a like-for-like immersion element',
          'Replacing a TRV head',
        ],
        correctIndex: 0,
        explanation:
            'Part P notifiable work includes new circuits, consumer unit alterations, and work in bathrooms or kitchens.',
      ),
      QuizQuestion(
        prompt:
            'A boiler interlock prevents the boiler firing unless:',
        choices: [
          'The pump is energised',
          'A genuine demand exists from at least one thermostat and the corresponding zone valve is open',
          'The pressure exceeds 1 bar',
          'The flue temperature is above 50 °C',
        ],
        correctIndex: 1,
        explanation:
            'Interlock requires the boiler not to fire unless a thermostat is calling and a zone valve auxiliary switch is closed.',
      ),
      QuizQuestion(
        prompt:
            'The end-switch on a motorised valve is sometimes called:',
        choices: [
          'The diverter switch',
          'The auxiliary switch',
          'The pilot switch',
          'The aquastat',
        ],
        correctIndex: 1,
        explanation:
            'The auxiliary or end switch closes when the valve is fully open and energises the boiler call.',
      ),
      QuizQuestion(
        prompt:
            'What is the BS 7671 (IET) standard?',
        choices: [
          'The Gas Safety regulations',
          'The Wiring Regulations for the UK',
          'A British standard for plastic pipework',
          'The water fittings regulations',
        ],
        correctIndex: 1,
        explanation:
            'BS 7671 is the UK Wiring Regulations (the 18th Edition is current).',
      ),
    ],
  ),
  QuizTopic(
    id: 'safe_isolation',
    title: 'Safe isolation procedure',
    category: 'Electrical',
    summary:
        'Step-by-step proof of the dead before any work on a wired component.',
    questions: [
      QuizQuestion(
        prompt: 'Before testing a circuit dead you must:',
        choices: [
          'Test on a known live source first',
          'Trust the labelling on the consumer unit',
          'Open the circuit at the appliance only',
          'Disconnect the earth',
        ],
        correctIndex: 0,
        explanation:
            'Always prove the tester is working by testing it on a known live source before and after.',
      ),
      QuizQuestion(
        prompt:
            'When isolating a circuit, you must test between:',
        choices: [
          'Line and neutral only',
          'Line to neutral, line to earth and neutral to earth',
          'Earth and earth',
          'Earth and a water pipe',
        ],
        correctIndex: 1,
        explanation:
            'All three combinations must read zero volts before the circuit is treated as dead.',
      ),
      QuizQuestion(
        prompt: 'After isolation, you must:',
        choices: [
          'Lock off the breaker and tag with your name and date',
          'Tape over the breaker',
          'Tell the customer not to touch it',
          'Take a photograph and leave',
        ],
        correctIndex: 0,
        explanation:
            'A personal padlock and signed tag is the only acceptable lock-off method.',
      ),
      QuizQuestion(
        prompt:
            'During a job, who may remove your padlock from a locked-off device?',
        choices: [
          'The customer',
          'Anyone with a master key',
          'Only the engineer who fitted it',
          'The building owner',
        ],
        correctIndex: 2,
        explanation:
            'Only the engineer who applied the lock should remove it, ensuring no-one is exposed to the risk.',
      ),
      QuizQuestion(
        prompt: 'A voltage proving unit is used to:',
        choices: [
          'Verify the tester functions correctly',
          'Measure earth fault loop impedance',
          'Test insulation resistance',
          'Identify line and neutral',
        ],
        correctIndex: 0,
        explanation:
            'A proving unit gives a known voltage, used to verify the tester before and after a dead-test.',
      ),
      QuizQuestion(
        prompt:
            'The Electricity at Work Regulations require all work be carried out:',
        choices: [
          'Live where possible',
          'Dead unless live work is specifically justified and risk-assessed',
          'Only by Gas Safe engineers',
          'Without testing afterwards',
        ],
        correctIndex: 1,
        explanation:
            'EAWR 1989 — work dead by default. Live work needs explicit justification and a risk assessment.',
      ),
      QuizQuestion(
        prompt: 'Replacing an immersion heater element like-for-like is:',
        choices: [
          'Always notifiable under Part P',
          'Permitted maintenance, not normally notifiable, but you must safely isolate and test',
          'Only for electricians',
          'Notifiable only if the cylinder is unvented',
        ],
        correctIndex: 1,
        explanation:
            'Like-for-like maintenance is not notifiable but the work must be done safely with proper isolation and testing.',
      ),
      QuizQuestion(
        prompt: 'After completing electrical work, the engineer should issue:',
        choices: [
          'Nothing',
          'A minor works or installation certificate covering testing',
          'A verbal confirmation only',
          'A receipt',
        ],
        correctIndex: 1,
        explanation:
            'Electrical work must be documented on the appropriate certificate to confirm it has been tested and is safe.',
      ),
    ],
  ),
];

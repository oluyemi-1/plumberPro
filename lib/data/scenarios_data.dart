/// Real-world plumber call-out scenarios. Each scenario chains a customer
/// brief, a series of multi-choice decision points and a final outcome.
/// The scoring system rewards the best diagnostic action at each step,
/// penalises wrong actions, and ends immediately on dangerous choices.
class JobOption {
  final String text;
  final String feedback;
  final int pointsDelta;
  final bool isDangerous;
  final bool isCorrect;
  const JobOption({
    required this.text,
    required this.feedback,
    required this.pointsDelta,
    this.isDangerous = false,
    this.isCorrect = false,
  });
}

class JobStep {
  final String prompt;
  final String? sceneNote; // e.g. "Boiler shows F22, gauge at 0.4 bar"
  final List<JobOption> options;
  const JobStep({
    required this.prompt,
    this.sceneNote,
    required this.options,
  });
}

class JobScenario {
  final String id;
  final String title;
  final String category;
  final String customerBrief;
  final String onArrival;
  final String safetyNote;
  final int timeLimitSeconds; // 0 if no clock
  final List<JobStep> steps;
  final String passOutcome;
  final String failOutcome;
  const JobScenario({
    required this.id,
    required this.title,
    required this.category,
    required this.customerBrief,
    required this.onArrival,
    required this.safetyNote,
    required this.timeLimitSeconds,
    required this.steps,
    required this.passOutcome,
    required this.failOutcome,
  });

  int get maxScore {
    var total = 0;
    for (final s in steps) {
      var best = 0;
      for (final o in s.options) {
        if (o.pointsDelta > best) best = o.pointsDelta;
      }
      total += best;
    }
    return total;
  }
}

const jobScenarios = <JobScenario>[
  // ─────────────────────────────────────────────────────────────────────
  JobScenario(
    id: 'boiler_no_heat_low_pressure',
    title: 'No heat, no hot water, F22 on the boiler',
    category: 'Boiler',
    customerBrief:
        'A regular customer calls in the morning. The house is cold, the boiler is showing the code F22, and a small puddle has formed under one of the radiators upstairs.',
    onArrival:
        'Boiler displays F22. System pressure gauge reads 0.4 bar. The radiator in the back bedroom has a damp carpet at the corner.',
    safetyNote:
        'F22 means low water content. Do not let the boiler dry-fire. Isolate the gas if anything looks off, and keep electricity isolated while you fault-find on water.',
    timeLimitSeconds: 480,
    steps: [
      JobStep(
        prompt: 'What is the very first action you take after greeting the customer?',
        sceneNote: 'Display: F22. Gauge: 0.4 bar.',
        options: [
          JobOption(
            text: 'Reset the boiler and try to relight straight away.',
            feedback:
                'Resetting before finding the leak risks dry-firing and damaging the heat exchanger.',
            pointsDelta: -2,
          ),
          JobOption(
            text: 'Locate the leak by walking every radiator with a paper towel.',
            feedback:
                'Right call — find the cause before you replace the lost water. F22 will keep coming back if you do not.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Top up via the filling loop to 2 bar and walk away.',
            feedback:
                'Over-pressurising lifts the PRV and you have not addressed the leak. Customer will call back.',
            pointsDelta: -1,
          ),
          JobOption(
            text: 'Recommend a new boiler before any diagnosis.',
            feedback:
                'Replacing parts or appliances before diagnosis is unprofessional and expensive for the customer.',
            pointsDelta: -2,
          ),
        ],
      ),
      JobStep(
        prompt:
            'You confirm a weep on the lockshield of the bedroom radiator. What next?',
        sceneNote: 'Damp carpet, drip every 5 seconds from the lockshield nut.',
        options: [
          JobOption(
            text: 'Tighten the nut hard until the drip stops.',
            feedback:
                'Over-tightening can split the olive or strip the threads. Use a measured action.',
            pointsDelta: -1,
          ),
          JobOption(
            text:
                'Drain to below the leak, replace the olive and remake the joint with a quarter turn past hand-tight, two spanners.',
            feedback:
                'Correct method. Capture water in a tray, work cleanly, and bring olive plus tape to site.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Wrap the joint in tape and call it done.',
            feedback: 'Tape is not a repair. The customer will be back, and the carpet will be ruined.',
            pointsDelta: -3,
          ),
          JobOption(
            text: 'Cap the radiator off, remove it and bill them for a new one.',
            feedback:
                'Excessive scope. The radiator is fine; only the joint is the problem.',
            pointsDelta: -2,
          ),
        ],
      ),
      JobStep(
        prompt:
            'Joint is remade. Now you need to refill the system. To what cold pressure?',
        sceneNote: 'PRV set 3 bar. System cold.',
        options: [
          JobOption(
            text: 'About 1.0 to 1.5 bar — fill slowly via the filling loop.',
            feedback:
                'Right. About half a bar will rise during operation, well clear of the 3 bar PRV.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: '2.5 bar so it lasts longer.',
            feedback:
                'Too high. When the system heats it will lift the PRV and discharge.',
            pointsDelta: -2,
          ),
          JobOption(
            text: '0.5 bar to be safe.',
            feedback:
                'Too low. Upstairs radiators will not get water and the boiler will lock out again.',
            pointsDelta: -1,
          ),
          JobOption(
            text: 'Whatever the gauge happens to read after a few seconds.',
            feedback:
                'Fill deliberately and watch the gauge. Drift is not commissioning.',
            pointsDelta: -1,
          ),
        ],
      ),
      JobStep(
        prompt:
            'Before you leave, what do you do to verify the system is healthy?',
        sceneNote: 'Boiler reset, system filled.',
        options: [
          JobOption(
            text: 'Run a heating cycle, watch pressure cold to hot, bleed any air, retest the lockshield with a paper towel.',
            feedback:
                'Best practice. Verify under load and prove the leak is gone before you leave.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Pack up — pressure looks fine.',
            feedback:
                'Only a hot test confirms the joint holds at full operating temperature.',
            pointsDelta: -2,
          ),
          JobOption(
            text: 'Bleed every radiator until water gushes everywhere.',
            feedback:
                'Bleed only the ones that need it; uncontrolled venting drops pressure further.',
            pointsDelta: -1,
          ),
          JobOption(
            text: 'Add a litre of inhibitor through the same leaky valve.',
            feedback:
                'Inhibitor goes in via a magnetic filter or an injection point, not through the joint you just remade.',
            pointsDelta: -1,
          ),
        ],
      ),
    ],
    passOutcome:
        'Heat back on, leak resolved at the source, system pressurised to 1 bar, hot test confirms a dry joint. The customer is delighted. You record the work and advise them to top up only if it falls below 1 bar.',
    failOutcome:
        'You will be back. F22 will return because the leak is still active or the system was left in an unsafe state.',
  ),

  // ─────────────────────────────────────────────────────────────────────
  JobScenario(
    id: 'frozen_condensate',
    title: 'Boiler in lockout on a freezing morning',
    category: 'Boiler',
    customerBrief:
        'It is minus four overnight. Customer has no heating and no hot water. The boiler shows A02 and is making a clicking sound on attempted ignition.',
    onArrival:
        'Combi boiler in the kitchen. Display: A02 / EA range. Outside, a 21.5 mm white pipe runs down the wall and ends at a small grating. There is visible frost on the pipe and an icicle at the open end.',
    safetyNote:
        'A02 family codes typically indicate a blocked condensate. NEVER pour boiling water on the pipe — the temperature shock can crack it.',
    timeLimitSeconds: 360,
    steps: [
      JobStep(
        prompt: 'Customer asks if she should keep pressing the reset button. Your advice?',
        sceneNote: 'Display flashes A02. Resets keep failing.',
        options: [
          JobOption(
            text: 'Yes, keep resetting until it fires.',
            feedback:
                'Repeated resetting on a known fault stresses the appliance and burns the lockout count.',
            pointsDelta: -2,
          ),
          JobOption(
            text: 'Stop resetting until the cause is found.',
            feedback:
                'Correct. An A02 is the boiler protecting itself; honour that until you find the blockage.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Switch the boiler off at the spur and leave for an hour.',
            feedback:
                'Doing nothing does not thaw a frozen pipe; it can make it worse.',
            pointsDelta: -1,
          ),
          JobOption(
            text: 'Reset once more, then call a different engineer.',
            feedback: 'You are the engineer. Diagnose first.',
            pointsDelta: -1,
          ),
        ],
      ),
      JobStep(
        prompt: 'How do you safely thaw the external condensate pipe?',
        sceneNote: 'Outdoor temperature minus four. Frosted pipe with ice plug.',
        options: [
          JobOption(
            text: 'Boil a kettle and pour the water along the pipe.',
            feedback:
                'Boiling water can crack PVC. Use warm, not boiling.',
            pointsDelta: -3,
            isDangerous: true,
          ),
          JobOption(
            text: 'Pour warm (not boiling) water along the pipe and at the trap, repeat until clear.',
            feedback:
                'Right. Hand-warm water repeatedly applied is the manufacturer-approved method.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Use a blow torch on the outside of the pipe.',
            feedback:
                'Plastic pipework will deform or melt. Never apply naked flame.',
            pointsDelta: -3,
            isDangerous: true,
          ),
          JobOption(
            text: 'Wait for the temperature to rise during the day.',
            feedback:
                'Customer is cold now. Do the work.',
            pointsDelta: -1,
          ),
        ],
      ),
      JobStep(
        prompt: 'Once flow is restored and the boiler resets cleanly, what do you recommend to prevent recurrence?',
        sceneNote: 'Boiler firing. Condensate dripping freely.',
        options: [
          JobOption(
            text: 'Insulate the external section with proprietary lagging and increase its diameter to 32 mm minimum.',
            feedback:
                'Standard advice. Where possible, terminate internally or run inside the building.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Fit a check valve on the condensate.',
            feedback:
                'A check valve can trap water and freeze worse. Wrong fitting for the job.',
            pointsDelta: -2,
          ),
          JobOption(
            text: 'Move the boiler to the loft.',
            feedback:
                'Out of scope and expensive. There are simpler fixes.',
            pointsDelta: -1,
          ),
          JobOption(
            text: 'Tell the customer to leave the heating on overnight.',
            feedback:
                'Helpful tip but not the structural fix. Lag the pipe properly.',
            pointsDelta: 1,
          ),
        ],
      ),
    ],
    passOutcome:
        'Boiler running normally, ice plug cleared with warm water, customer briefed and the external pipe lagged. You leave a tidy job sheet and book a follow-up to upsize the discharge run if needed.',
    failOutcome:
        'The pipe is damaged or the customer is no warmer. Either way, this was avoidable.',
  ),

  // ─────────────────────────────────────────────────────────────────────
  JobScenario(
    id: 'cold_radiator_air',
    title: 'Cold radiator upstairs, the rest are warm',
    category: 'Heating',
    customerBrief:
        'Customer says the radiator in the spare bedroom never gets warm at the top. The other radiators in the house are fine. The boiler runs normally.',
    onArrival:
        'Bedroom radiator: bottom feels hot, top is cold to the touch. Boiler reading 1.2 bar cold, 1.6 bar at temperature. No leaks visible. TRV set to 4.',
    safetyNote:
        'Trapped air at the top is the classic cause. Bleed with the heating off or set very low so you are not catching scalding water.',
    timeLimitSeconds: 240,
    steps: [
      JobStep(
        prompt: 'You feel the radiator. What is the pattern, and what does it suggest?',
        sceneNote: 'Bottom warm, top cold.',
        options: [
          JobOption(
            text: 'Cold top, warm bottom — air at the top.',
            feedback:
                'Correct diagnosis from a single feel. Easy fix incoming.',
            pointsDelta: 3,
            isCorrect: true,
          ),
          JobOption(
            text: 'Cold bottom, warm top — sludge.',
            feedback:
                'Wrong way around. That pattern is sludge, not air.',
            pointsDelta: -2,
          ),
          JobOption(
            text: 'All cold — TRV closed.',
            feedback:
                'Bottom is warm, so flow is reaching the rad.',
            pointsDelta: -1,
          ),
          JobOption(
            text: 'All hot — false complaint.',
            feedback:
                'You can clearly feel the cold top. Trust the feel.',
            pointsDelta: -2,
          ),
        ],
      ),
      JobStep(
        prompt: 'Before opening the bleed screw, what do you do?',
        sceneNote: 'Square key in the van. Cloth to hand.',
        options: [
          JobOption(
            text: 'Turn the heating off and let the radiator cool a touch, lay a cloth and tray under the bleed screw.',
            feedback:
                'Right. You avoid scalding water and you protect the floor.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Bleed it while it is full pressure and full heat for a faster job.',
            feedback:
                'Boiling water shooting from a bleed key onto a customer floor — bad day at the office.',
            pointsDelta: -3,
            isDangerous: true,
          ),
          JobOption(
            text: 'Turn the system pressure up to 2.5 bar first.',
            feedback:
                'Will only push air around faster and stress the system.',
            pointsDelta: -2,
          ),
          JobOption(
            text: 'Skip the cloth — the carpet is dark anyway.',
            feedback:
                'Customer will not be amused. Always protect the customer property.',
            pointsDelta: -1,
          ),
        ],
      ),
      JobStep(
        prompt: 'You open the bleed key. Air hisses out, then water dribbles. What now?',
        sceneNote: 'Steady stream of clean water.',
        options: [
          JobOption(
            text: 'Close the bleed screw immediately when the stream is steady, then check pressure at the boiler.',
            feedback:
                'Correct. Quick close prevents pressure loss.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Let it run for two minutes to be sure.',
            feedback:
                'Pressure will plummet, requiring a refill and risking re-introducing air.',
            pointsDelta: -2,
          ),
          JobOption(
            text: 'Walk to the boiler with the key still loose.',
            feedback:
                'Water everywhere by the time you return.',
            pointsDelta: -3,
          ),
          JobOption(
            text: 'Tighten until the screw threads strip.',
            feedback:
                'Snug, not gorilla. The seat is the seal, not the thread tension.',
            pointsDelta: -2,
          ),
        ],
      ),
      JobStep(
        prompt: 'Pressure has dropped to 0.7 bar. What is the right action?',
        sceneNote: 'Boiler gauge: 0.7 bar.',
        options: [
          JobOption(
            text: 'Re-pressurise via the filling loop to about 1 bar cold, isolate the loop, run a heat cycle and verify.',
            feedback:
                'Standard recovery. Filling loop OFF afterwards, always.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Leave the filling loop permanently connected so the customer can top up.',
            feedback:
                'Permanent connection breaches the Water Regs. Use a flexible loop and remove it after filling.',
            pointsDelta: -3,
            isDangerous: true,
          ),
          JobOption(
            text: 'Top up to 3 bar so it lasts a long time.',
            feedback:
                'PRV will lift. You will create a new fault.',
            pointsDelta: -2,
          ),
          JobOption(
            text: 'Tell the customer to top it up next week.',
            feedback:
                'They are paying you. Finish the job.',
            pointsDelta: -1,
          ),
        ],
      ),
    ],
    passOutcome:
        'Bedroom radiator now fully warm top to bottom, system at 1 bar cold and 1.5 bar hot, filling loop disconnected. You note the date in the customer record so they can rebook a service.',
    failOutcome:
        'Air still trapped, mess made, or the system left in an unsafe state. Customer will rate you accordingly.',
  ),

  // ─────────────────────────────────────────────────────────────────────
  JobScenario(
    id: 'gas_smell_callout',
    title: 'Smell of gas in a domestic kitchen',
    category: 'Gas safety',
    customerBrief:
        'A customer phones from a mobile outside the property. They came home to a strong smell of gas in the hallway and kitchen. Children are at school, partner is at work, no-one else in the house.',
    onArrival:
        'Approaching the front door from the path you can already smell gas. Smell strongest by the kitchen.',
    safetyNote:
        'This is the only scenario in the app where you can fail by taking even one wrong action. Follow the gas-emergency procedure exactly.',
    timeLimitSeconds: 0,
    steps: [
      JobStep(
        prompt: 'You arrive at the door. What is your first action?',
        sceneNote: 'Smell of gas detectable outside.',
        options: [
          JobOption(
            text: 'Tell the customer not to enter, and do not enter yourself until the property is ventilated.',
            feedback:
                'Correct. Until you can ventilate and isolate, no-one enters.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Walk in and switch on the kitchen light to investigate.',
            feedback:
                'Spark from the switch can ignite a gas-air mix. Catastrophic failure.',
            pointsDelta: -10,
            isDangerous: true,
          ),
          JobOption(
            text: 'Take a photo on your phone for the report.',
            feedback:
                'Mobile phones can ignite a flammable atmosphere. Bag it outside before you go in.',
            pointsDelta: -10,
            isDangerous: true,
          ),
          JobOption(
            text: 'Light a match to verify by smell.',
            feedback:
                'Words fail. Never.',
            pointsDelta: -10,
            isDangerous: true,
          ),
        ],
      ),
      JobStep(
        prompt: 'How do you ventilate and isolate?',
        sceneNote: 'Front door open, you have intrinsically safe torch.',
        options: [
          JobOption(
            text: 'Open all external doors and windows, isolate the gas at the emergency control valve at the meter, do not operate any electrical switches.',
            feedback:
                'Right. ECV off, ventilation, no electrics.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Switch on the extractor fan to clear the air.',
            feedback:
                'Switching the fan on creates a spark. Do not.',
            pointsDelta: -10,
            isDangerous: true,
          ),
          JobOption(
            text: 'Close all the doors and windows to contain the gas.',
            feedback:
                'You want gas OUT, not concentrated.',
            pointsDelta: -8,
            isDangerous: true,
          ),
          JobOption(
            text: 'Run upstairs to find the meter.',
            feedback:
                'Identify meter location calmly. Running risks falling and missing valves.',
            pointsDelta: -1,
          ),
        ],
      ),
      JobStep(
        prompt: 'Gas is isolated and the property ventilated. The smell remains. Who do you call?',
        sceneNote: 'Customer waiting outside.',
        options: [
          JobOption(
            text: 'Call 0800 111 999 — the National Gas Emergency Service — and stay on site to advise.',
            feedback:
                'Correct UK emergency number. Stay on site to liaise.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Call your boss to ask what to do.',
            feedback:
                'You know what to do. Call the emergency number first.',
            pointsDelta: -3,
          ),
          JobOption(
            text: 'Try to find the leak yourself with a smartphone app.',
            feedback:
                'Out of scope until the area is declared safe. Call the emergency line.',
            pointsDelta: -3,
          ),
          JobOption(
            text: 'Leave a note and depart.',
            feedback:
                'Never abandon a live gas hazard.',
            pointsDelta: -10,
            isDangerous: true,
          ),
        ],
      ),
    ],
    passOutcome:
        'Property safe, gas isolated, emergency service called and on the way. You have logged the time and your decisions. Lives protected.',
    failOutcome:
        'Any wrong action in a gas-leak emergency is one too many. Re-read the safety procedure before you take this scenario again.',
  ),

  // ─────────────────────────────────────────────────────────────────────
  JobScenario(
    id: 'unvented_discharge',
    title: 'Tundish dripping continuously',
    category: 'Hot water',
    customerBrief:
        'Customer noticed a slow drip into the tundish under their hot water cylinder, into a pipe that runs outside. They report no other symptoms.',
    onArrival:
        'Cylinder is unvented, fitted in airing cupboard. Inlet group on the cold side. Tundish has a steady drip — about one every two seconds — into D2 outside. Cylinder thermostat reads 60 °C.',
    safetyNote:
        'The tundish is a safety-discharge sentinel. Never block it. A constant drip means either over-pressure or a passing relief valve — both must be diagnosed before any reset.',
    timeLimitSeconds: 360,
    steps: [
      JobStep(
        prompt: 'What do you check first to narrow the cause?',
        sceneNote: 'PRV reading 3.5 bar inlet, cylinder T&P at 60 °C.',
        options: [
          JobOption(
            text: 'Inlet pressure with a gauge — is the PRV holding the cold inlet at its set pressure (typically 3 bar)?',
            feedback:
                'Right starting point. If inlet is too high, water cannot accommodate expansion and the relief opens.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Open every hot tap on full to ease pressure.',
            feedback:
                'Symptom-treatment, not diagnosis. The drip will return as soon as taps close.',
            pointsDelta: -1,
          ),
          JobOption(
            text: 'Cap off the tundish to stop the noise.',
            feedback:
                'Catastrophic. The tundish is a required visible air break and must never be blocked.',
            pointsDelta: -10,
            isDangerous: true,
          ),
          JobOption(
            text: 'Turn the cylinder thermostat to 90 °C.',
            feedback:
                'Will worsen expansion and may cause T&P relief to lift. Do not.',
            pointsDelta: -3,
            isDangerous: true,
          ),
        ],
      ),
      JobStep(
        prompt: 'Inlet pressure is 3.0 bar (correct). What is the next test?',
        sceneNote: 'Expansion vessel hangs off the inlet.',
        options: [
          JobOption(
            text: 'Test the expansion vessel — depressurise the cylinder, press the Schrader valve. Water = failed diaphragm.',
            feedback:
                'Excellent. A waterlogged vessel will not absorb expansion, lifting the relief.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Replace the PRV outright.',
            feedback:
                'Premature. Confirm the diagnosis first.',
            pointsDelta: -2,
          ),
          JobOption(
            text: 'Replace the whole cylinder.',
            feedback:
                'Massive over-scope. The cylinder may be fine.',
            pointsDelta: -3,
          ),
          JobOption(
            text: 'Run a hot tap and listen.',
            feedback:
                'Diagnosis by ear is not enough on a safety device.',
            pointsDelta: -1,
          ),
        ],
      ),
      JobStep(
        prompt:
            'You press the Schrader and water comes out. The diaphragm has failed. What is the safest fix path?',
        sceneNote: 'Water from Schrader valve.',
        options: [
          JobOption(
            text: 'Isolate, drain to zero pressure, fit a new expansion vessel pre-charged to 3 bar (matching the PRV setting), refill carefully.',
            feedback:
                'Right. Pre-charge must match PRV setting. Document the work.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Pump air into the existing waterlogged vessel.',
            feedback:
                'Cannot recover a perforated diaphragm. Replace it.',
            pointsDelta: -3,
          ),
          JobOption(
            text: 'Fit an extra expansion vessel in parallel without replacing the failed one.',
            feedback:
                'The failed one will keep flooding and short-circuit your fix.',
            pointsDelta: -2,
          ),
          JobOption(
            text: 'Remove the expansion vessel altogether.',
            feedback:
                'Removing the expansion vessel is a Building Regs G3 breach. Never.',
            pointsDelta: -10,
            isDangerous: true,
          ),
        ],
      ),
      JobStep(
        prompt: 'Closing checks — what is essential before sign-off?',
        sceneNote: 'Vessel replaced. System refilled.',
        options: [
          JobOption(
            text: 'Operate every relief device through its test lever, confirm reseat, observe the tundish, record G3 commissioning.',
            feedback:
                'Industry-standard hand-over. Tick every box on the Benchmark.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Skip the test levers — the customer is in a hurry.',
            feedback:
                'Test levers are required at commissioning. No shortcuts on safety.',
            pointsDelta: -3,
            isDangerous: true,
          ),
          JobOption(
            text: 'Hand over without the manufacturer pack.',
            feedback:
                'The customer needs the pack for warranty and future service.',
            pointsDelta: -1,
          ),
          JobOption(
            text: 'Reset the cylinder thermostat to 80 °C.',
            feedback:
                '60 °C is the typical setpoint for Legionella suppression. 80 °C is unnecessary and risky.',
            pointsDelta: -2,
          ),
        ],
      ),
    ],
    passOutcome:
        'Tundish dry. Expansion vessel correctly charged. Test levers operated. Customer holds a properly completed Benchmark commissioning record. You have done a textbook job.',
    failOutcome:
        'Either the system is leaking again, or you have left it unsafe and undocumented. Re-read Part G3 before retrying.',
  ),

  // ─────────────────────────────────────────────────────────────────────
  JobScenario(
    id: 'blocked_basin',
    title: 'Slow-draining bathroom basin',
    category: 'Drainage',
    customerBrief:
        'Customer reports the en-suite basin drains very slowly. Bath in the same room is fine. Has tried supermarket drain cleaner with little effect.',
    onArrival:
        'Pop-up waste in basin. Water level slowly drains over a minute. P-trap visible under the basin within a vanity unit.',
    safetyNote:
        'Caustic drain unblocker may be in the trap. Wear gloves and eye protection until proven absent. Have plenty of clean water for skin contact in the worst case.',
    timeLimitSeconds: 240,
    steps: [
      JobStep(
        prompt: 'First action?',
        sceneNote: 'Vanity unit doors closed. Cleaner bottle on the side.',
        options: [
          JobOption(
            text: 'PPE on, ask whether the customer used drain cleaner today and how much.',
            feedback:
                'Right. Establish the chemical hazard before you open anything.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Crawl straight under the basin and unscrew the trap.',
            feedback:
                'Risk of caustic splash on face and chest. Always know what is in the line.',
            pointsDelta: -3,
            isDangerous: true,
          ),
          JobOption(
            text: 'Pour bleach into the basin to "react with the cleaner".',
            feedback:
                'Mixing chemicals is dangerous and may release chlorine gas.',
            pointsDelta: -10,
            isDangerous: true,
          ),
          JobOption(
            text: 'Refuse the job.',
            feedback:
                'Common job, can be done safely with PPE and care.',
            pointsDelta: -2,
          ),
        ],
      ),
      JobStep(
        prompt: 'Customer says they used a small amount yesterday and the basin has been slow ever since. What next?',
        sceneNote: 'Pop-up waste plug visible.',
        options: [
          JobOption(
            text: 'Lift the pop-up plug, clean the strainer of hair and soap, run hot water, then re-test.',
            feedback:
                'Probably solves 70 percent of slow-drain calls.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Skip the strainer and go straight to the trap.',
            feedback:
                'Quickest is usually slowest — start at the easiest point.',
            pointsDelta: -1,
          ),
          JobOption(
            text: 'Drill the basin to make a bigger hole.',
            feedback:
                'No.',
            pointsDelta: -10,
          ),
          JobOption(
            text: 'Tell the customer to keep using cleaner.',
            feedback:
                'Cleaner is the cause of half of these calls. You are there to do the work properly.',
            pointsDelta: -2,
          ),
        ],
      ),
      JobStep(
        prompt: 'Strainer is clean but flow is still slow. Next?',
        sceneNote: 'Bucket and PPE ready.',
        options: [
          JobOption(
            text: 'Bucket under, hand-loosen the trap nuts, capture water, clean the trap, hand-tighten only on refit.',
            feedback:
                'Right. Plastic trap nuts are hand-tight; spanners crack them.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Use a spanner to tighten plastic trap nuts.',
            feedback:
                'You will split the thread and create a leak.',
            pointsDelta: -3,
          ),
          JobOption(
            text: 'Reach in with your fingers without a bucket.',
            feedback:
                'Bucket-or-bust on every wet job.',
            pointsDelta: -2,
          ),
          JobOption(
            text: 'Pour boiling water down the basin.',
            feedback:
                'Boiling water can crack porcelain and may not clear a hair clog anyway.',
            pointsDelta: -2,
          ),
        ],
      ),
      JobStep(
        prompt: 'Trap is clean, flow still slow. Where is the blockage?',
        sceneNote: 'Branch waste runs into the soil stack.',
        options: [
          JobOption(
            text: 'Downstream of the trap. Use a small drain rod / mini auger up the branch toward the stack.',
            feedback:
                'Right diagnosis. Many household clogs are at the branch, not the trap.',
            pointsDelta: 4,
            isCorrect: true,
          ),
          JobOption(
            text: 'Replace the basin.',
            feedback:
                'Massively over-scoped.',
            pointsDelta: -3,
          ),
          JobOption(
            text: 'Recommend the customer keeps using chemical cleaner weekly.',
            feedback:
                'You are paid to fix it, not to delay it.',
            pointsDelta: -2,
          ),
          JobOption(
            text: 'Tell them you cannot help further and leave.',
            feedback:
                'Branch rodding is in scope. Try it.',
            pointsDelta: -2,
          ),
        ],
      ),
    ],
    passOutcome:
        'Basin draining freely. Trap reseated by hand. You advise the customer to fit a hair-strainer cap and to avoid caustic cleaners — they erode plastic traps. Good aftercare.',
    failOutcome:
        'Customer still has a slow basin or worse, a chemical injury. Get the safety basics right first.',
  ),

  // ─── Electric boiler scenarios ──────────────────────────────────────────
  JobScenario(
    id: 'electric_boiler_no_heat_flat',
    title: 'Top-floor flat, no heat, Elnur Mattira',
    category: 'Electric boiler',
    customerBrief:
        'Tenant in a top-floor one-bed flat called. Heating and hot water both off since this morning. Property has no gas; everything runs from a wall-hung electric boiler in the airing cupboard.',
    onArrival:
        'You let yourself in with the agent key. The hallway is cold. The airing cupboard has an Elnur Mattira boiler with a blank display. Below it is a sealed unvented cylinder. There is a single rotary isolator beside the boiler, in the on position.',
    safetyNote:
        'Treat the boiler as live until proved dead. The customer cannot tell you whether the upstream consumer unit has tripped.',
    timeLimitSeconds: 0,
    steps: [
      JobStep(
        prompt: 'Display is blank. What is your first action?',
        sceneNote: 'No noises. Hallway is cold. Local isolator is on.',
        options: [
          JobOption(
            text:
                'Open the boiler cover and start probing terminals to find the fault.',
            feedback:
                'No isolation, no proving dead — that is a shock risk. Always go to the consumer unit first.',
            pointsDelta: -3,
            isDangerous: true,
          ),
          JobOption(
            text:
                'Go to the consumer unit and check whether the boiler RCBO has tripped.',
            feedback:
                'Correct first step — a tripped RCBO is by far the most common reason for a dead display.',
            pointsDelta: 3,
            isCorrect: true,
          ),
          JobOption(
            text: 'Reset the boiler from the front panel.',
            feedback: 'The display is blank, so there is no panel to reset.',
            pointsDelta: -1,
          ),
        ],
      ),
      JobStep(
        prompt:
            'At the consumer unit you find the boiler RCBO has tripped. What do you do next?',
        sceneNote:
            'It is a 40 A type-AC RCBO labelled "boiler". Other circuits look untouched.',
        options: [
          JobOption(
            text:
                'Reset the RCBO and walk away — job done, just a nuisance trip.',
            feedback:
                'Repeated trips can hide a real fault that needs investigating. Resetting once and leaving without watching it under load risks a callback or worse.',
            pointsDelta: -2,
          ),
          JobOption(
            text:
                'Reset the RCBO, then go back to the boiler and watch it through one full firing cycle before leaving.',
            feedback:
                'Sensible. A tripped device deserves a one-off reset and observation. If it trips again under load the cause is real.',
            pointsDelta: 3,
            isCorrect: true,
          ),
          JobOption(
            text:
                'Tape the RCBO closed so it does not trip again and leave.',
            feedback:
                'This is dangerous — that RCBO is a safety device. Never defeat it.',
            pointsDelta: -5,
            isDangerous: true,
          ),
        ],
      ),
      JobStep(
        prompt:
            'You reset the RCBO. The boiler fires for thirty seconds and the RCBO trips again. What is the most likely cause?',
        sceneNote:
            'You hear a brief contactor click, the pump start, then a loud snap as the RCBO trips.',
        options: [
          JobOption(
            text: 'The pump is taking too much starting current.',
            feedback:
                'Pump starting current is well within the RCBO trip curve. Rapid trip on energising is almost always earth leakage from the element.',
            pointsDelta: -1,
          ),
          JobOption(
            text:
                'Earth leakage from a degraded element seal. Insulation resistance test on each element will confirm.',
            feedback:
                'Yes. A nearly-instant trip on firing with no overcurrent fault is a textbook earth-leakage signature. An insulation test at five hundred volts to earth will identify the faulty element.',
            pointsDelta: 3,
            isCorrect: true,
          ),
          JobOption(
            text: 'The customer is on a faulty tariff meter.',
            feedback: 'Tariffs have nothing to do with earth fault protection.',
            pointsDelta: -2,
          ),
        ],
      ),
      JobStep(
        prompt:
            'An insulation test confirms one element has broken down to earth. The boiler is six years old. What do you advise the customer?',
        sceneNote:
            'You have the manufacturer\'s replacement element on the van.',
        options: [
          JobOption(
            text:
                'Replace just the failed element, retest insulation, fire up.',
            feedback:
                'Acceptable, but at six years the other elements may not be far behind. Worth at least proposing inhibitor refresh and a filter check.',
            pointsDelta: 1,
          ),
          JobOption(
            text:
                'Replace the failed element, retest insulation, flush and re-dose inhibitor, fit a magnetic filter if absent.',
            feedback:
                'This is the right professional answer. Element failure is usually a symptom of water quality. Without addressing the root cause the next element will fail soon.',
            pointsDelta: 3,
            isCorrect: true,
          ),
          JobOption(
            text:
                'Refuse the repair on a six-year-old boiler and quote a full replacement.',
            feedback:
                'Six years is not the end of life for a serviceable electric boiler. Be straight with the customer about lifespan and let them choose.',
            pointsDelta: -1,
          ),
        ],
      ),
    ],
    passOutcome:
        'Element swapped under safe isolation, insulation retested at five hundred volts and confirmed sound, system flushed and re-dosed, magnetic filter fitted, boiler watched through a full hot cycle. Customer warm, agent informed, paperwork signed.',
    failOutcome:
        'Job ended with a defeated RCBO, shocked tenant, or shock-injured engineer. None of those are acceptable. Slow down, isolate, prove dead, find the cause.',
  ),

  JobScenario(
    id: 'electric_boiler_survey',
    title: 'Oil-to-electric conversion survey, rural cottage',
    category: 'Electric boiler',
    customerBrief:
        'Customer is selling her late mother\'s rural cottage and wants the oil-fired boiler removed and replaced with an electric system before the EPC inspection in three weeks. She has heard electric is greener and easier than oil. You are there for a survey, no work today.',
    onArrival:
        'A 1960s detached cottage with a kitchen-mounted oil boiler discharging into a flue out the gable. Heat load looks moderate — three bedrooms, single glazing, partly-filled cavity walls, oil tank in the garden. The cut-out at the meter is sixty amps.',
    safetyNote:
        'This is a survey only. No live work today. Your job is to gather facts and write an honest quote.',
    timeLimitSeconds: 0,
    steps: [
      JobStep(
        prompt:
            'The customer asks you to quote a twelve kilowatt electric flow boiler. What is your first concern?',
        sceneNote:
            'The kitchen consumer unit is a 1990s wired-fuse unit fed from the sixty amp main cut-out.',
        options: [
          JobOption(
            text: 'Quote the boiler — sixty amps is plenty.',
            feedback:
                'A twelve kilowatt boiler needs over fifty-two amps just for itself. With the cooker, shower and immersion in the same property the supply will not cope.',
            pointsDelta: -3,
          ),
          JobOption(
            text:
                'Explain the supply limit and recommend the customer apply to the DNO for a hundred amp supply upgrade before proceeding.',
            feedback:
                'Correct. The DNO upgrade is non-trivial — weeks of lead time and usually a separate cost. The customer needs that decision in writing before the boiler is ordered.',
            pointsDelta: 3,
            isCorrect: true,
          ),
          JobOption(
            text:
                'Downsize to a four kilowatt boiler so it fits the existing supply.',
            feedback:
                'A four kilowatt boiler will not heat a three-bed cottage with single glazing. Honest sizing comes from heat loss, not from the supply you happen to have.',
            pointsDelta: -2,
          ),
        ],
      ),
      JobStep(
        prompt:
            'You explain SAP and running cost implications. The customer says she will pay any installation cost as long as the EPC is acceptable. What do you do?',
        sceneNote:
            'Three weeks to EPC. Oil is the current heat source. Customer is selling, not staying.',
        options: [
          JobOption(
            text:
                'Promise her a better EPC after the swap to electric.',
            feedback:
                'Electric heating typically gives a worse SAP rating than oil because of the carbon factor of grid electricity. This promise will rebound badly.',
            pointsDelta: -3,
          ),
          JobOption(
            text:
                'Explain that grid electricity has a higher SAP carbon factor than oil, so an oil-to-electric swap is likely to worsen the EPC, not improve it. Get her informed decision in writing.',
            feedback:
                'Exactly right. Many customers misunderstand this. Documenting the conversation protects you and gives her time to reconsider before committing.',
            pointsDelta: 3,
            isCorrect: true,
          ),
          JobOption(
            text:
                'Suggest she keep the oil boiler but swap the burner.',
            feedback:
                'Not what she asked. The brief is a replacement, not a service.',
            pointsDelta: 0,
          ),
        ],
      ),
      JobStep(
        prompt:
            'Customer agrees to keep the oil boiler. She asks for a quote on a full oil service and tank inspection instead. How do you handle scope?',
        sceneNote:
            'You are OFTEC registered. She has not had the boiler serviced for two years.',
        options: [
          JobOption(
            text:
                'Refuse and walk away — you came to fit electric, not service oil.',
            feedback:
                'Disrespectful and short-sighted. Within your scope, accept the change of brief and quote the right work.',
            pointsDelta: -1,
          ),
          JobOption(
            text:
                'Quote the OFTEC service, tank inspection, and any insurance-related paperwork the EPC inspector may want.',
            feedback:
                'Good. The customer\'s real goal is a sellable property. Help her get there with the right work.',
            pointsDelta: 3,
            isCorrect: true,
          ),
          JobOption(
            text:
                'Do the service now, off the books.',
            feedback:
                'Never. OFTEC servicing is documented work, not a cash favour.',
            pointsDelta: -3,
            isDangerous: true,
          ),
        ],
      ),
    ],
    passOutcome:
        'Honest survey. Customer informed about SAP implications, supply limits, and the realistic cost of an electric conversion. She elects to keep the oil boiler with a proper service. You write a clear quote and leave with a job and a customer who trusts you.',
    failOutcome:
        'Customer pays for an electric install that worsens her EPC, fails the inspection, and damages her property sale. Bad outcome and a bad reputation.',
  ),

  JobScenario(
    id: 'electric_boiler_service',
    title: 'Annual service, EHC SlimJim, second-floor flat',
    category: 'Electric boiler',
    customerBrief:
        'Annual service booked by a residents\' management agent. Eight identical flats in the block, each with an EHC SlimJim electric boiler installed five years ago. You are doing one as a pilot before the full block of eight.',
    onArrival:
        'Flat is tidy. The boiler is in a hallway cupboard with a magnetic filter and a small unvented cylinder beside it. System pressure shows zero on the boiler display. There is no obvious leak. Customer reports heating fine until last week.',
    safetyNote:
        'Live electrical kit. Safe isolation rules apply throughout. Treat unvented cylinder G3 requirements with full respect.',
    timeLimitSeconds: 0,
    steps: [
      JobStep(
        prompt:
            'Display shows zero bar. Customer says heating was working last week. What do you do first?',
        sceneNote:
            'No water on the floor. No obvious damp on the ceiling below from the flat above.',
        options: [
          JobOption(
            text:
                'Open the filling loop and refill the system to one bar straight away.',
            feedback:
                'You have not found out why the pressure dropped. Refilling without investigating risks repeat callouts and a hidden small leak that will damage the flat below.',
            pointsDelta: -1,
          ),
          JobOption(
            text:
                'Inspect every visible joint, every TRV, the PRV outlet and the expansion vessel before refilling.',
            feedback:
                'Right approach. A pressure drop without a visible leak often means PRV release from a failed expansion vessel, or a weep at a TRV stem. Find it first.',
            pointsDelta: 3,
            isCorrect: true,
          ),
          JobOption(
            text:
                'Tell the customer the boiler is at end of life and quote a replacement.',
            feedback:
                'A pressure drop is not end of life on a five-year-old boiler. Diagnose before you sell.',
            pointsDelta: -3,
          ),
        ],
      ),
      JobStep(
        prompt:
            'You check the expansion vessel. The Schrader valve gives no pressure at all and a drop of water comes out when you press it. What does this mean?',
        sceneNote:
            'Air side of the vessel is dry on every other charge you have ever pressed.',
        options: [
          JobOption(
            text:
                'Just re-pressurise the vessel through the Schrader.',
            feedback:
                'Water out of the Schrader means the rubber bladder has ruptured. You cannot fix it by pumping air in.',
            pointsDelta: -3,
          ),
          JobOption(
            text:
                'The diaphragm has failed. Replace the expansion vessel before refilling and firing up.',
            feedback:
                'Correct. The PRV has been dumping system water every time the boiler heated up — and the unattended discharge has slowly drained the system to zero.',
            pointsDelta: 3,
            isCorrect: true,
          ),
          JobOption(
            text:
                'Tighten the Schrader valve harder.',
            feedback:
                'You cannot reseat a torn bladder by tightening the Schrader.',
            pointsDelta: -2,
          ),
        ],
      ),
      JobStep(
        prompt:
            'You replace the vessel, re-pressurise the system, and now want to complete the service properly. Pick the right service steps.',
        sceneNote:
            'You have time and the customer is patient.',
        options: [
          JobOption(
            text:
                'Just refit the cover and leave — heating works.',
            feedback:
                'You have not completed the service you were paid for.',
            pointsDelta: -2,
          ),
          JobOption(
            text:
                'Test the PRV by lifting the lever, check inhibitor concentration, clean the magnetic filter, listen for clean contactor operation, watch a full firing cycle, and update the benchmark log.',
            feedback:
                'Full professional service. Each step protects the customer and adds a useful data point for next year.',
            pointsDelta: 3,
            isCorrect: true,
          ),
          JobOption(
            text:
                'Drain the system and refill with fresh water with no inhibitor — easier than testing.',
            feedback:
                'Skipping inhibitor on an electric system is a fast route to a failed element. Never leave a system uninhibited.',
            pointsDelta: -3,
          ),
        ],
      ),
    ],
    passOutcome:
        'Vessel replaced, system re-pressurised and re-dosed, full service completed and logged. You write a clear note to the agent recommending vessel inspection in the other seven flats — likely the same problem brewing. Agent grateful, you have just turned one job into eight.',
    failOutcome:
        'Quick refill, no diagnosis. Within a month the same flat has dropped pressure again and the ceiling of the flat below is stained. Agent unhappy, reputation damaged, eight jobs lost.',
  ),
];

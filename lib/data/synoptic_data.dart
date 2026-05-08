// Data model for synoptic (final practical) mock assessments.
//
// A SynopticAssessment is a longer scenario containing a mixture of
// SynopticTasks — multiple choice, calculation and free text — that
// together test learning across several plumbing topics.

enum SynopticTaskType { multipleChoice, calculation, freeText }

class SynopticTask {
  final SynopticTaskType type;
  final String prompt;
  final List<String>? choices;
  final int? correctIndex;
  final double? expectedValue;
  final double? tolerance;
  final String? unit;
  final String explanation;
  final int marks;

  const SynopticTask({
    required this.type,
    required this.prompt,
    this.choices,
    this.correctIndex,
    this.expectedValue,
    this.tolerance,
    this.unit,
    required this.explanation,
    required this.marks,
  });
}

class SynopticAssessment {
  final String id;
  final String title;
  final String scenario;
  final String coverage;
  final int timeLimitMinutes;
  final List<SynopticTask> tasks;

  const SynopticAssessment({
    required this.id,
    required this.title,
    required this.scenario,
    required this.coverage,
    required this.timeLimitMinutes,
    required this.tasks,
  });

  int get totalMarks => tasks.fold(0, (a, t) => a + t.marks);
}

const synopticAssessments = <SynopticAssessment>[
  SynopticAssessment(
    id: 'unvented_install',
    title: 'Install an unvented hot water system',
    scenario:
        'You have been called to a three-bedroom semi-detached house in '
        'Manchester. The customer wants their existing vented cylinder '
        'replaced with a 210 litre unvented direct cylinder fed from a '
        '22 mm cold mains running at 3.5 bar dynamic. The hot water demand '
        'is for one bathroom, an en-suite shower and a kitchen sink. You '
        'must size, install and commission the system to G3 of the Building '
        'Regulations and BS EN 12897. Use the data sheet supplied: cylinder '
        'volume 210 litres, expansion factor 0.04, vessel pre-charge to be '
        'set to incoming dynamic pressure.',
    coverage:
        'Hot water | Unvented G3 | Pressure and expansion | Discharge pipework',
    timeLimitMinutes: 45,
    tasks: [
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'Which fluid category best describes hot water from an unvented '
            'cylinder serving domestic outlets?',
        choices: ['Category 1', 'Category 2', 'Category 3', 'Category 5'],
        correctIndex: 1,
        explanation:
            'Heated wholesome water becomes Category 2 once temperature or '
            'taste has been changed. Higher categories apply to chemical or '
            'biological hazards which are not present here.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.calculation,
        prompt:
            'Calculate the minimum expansion volume required for the 210 '
            'litre cylinder using an expansion factor of 0.04.',
        expectedValue: 8.4,
        tolerance: 0.2,
        unit: 'litres',
        explanation:
            '210 multiplied by 0.04 equals 8.4 litres. The expansion vessel '
            'must accommodate at least this volume, so a 12 litre vessel is '
            'normally selected to give a margin.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.calculation,
        prompt:
            'What pre-charge pressure (in bar) should the expansion vessel '
            'be set to for an incoming dynamic mains pressure of 3.5 bar?',
        expectedValue: 3.5,
        tolerance: 0.1,
        unit: 'bar',
        explanation:
            'The expansion vessel pre-charge is set to match the incoming '
            'cold mains dynamic pressure so that water only enters the '
            'vessel once expansion begins, maximising acceptance volume.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'Which valve arrangement provides primary protection against '
            'over-temperature on an unvented cylinder?',
        choices: [
          'A pressure reducing valve set to 3 bar',
          'A combined temperature and pressure relief valve',
          'A double check valve on the cold supply',
          'A drain cock at the cylinder base',
        ],
        correctIndex: 1,
        explanation:
            'Three independent safety devices are required: cylinder '
            'thermostat, energy cut-out and a temperature and pressure '
            'relief valve. The T and P relief valve is the final safety '
            'device for over-temperature.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'The expansion relief valve discharges at what pressure on a '
            'standard domestic system?',
        choices: ['3 bar', '6 bar', '7 bar', '10 bar'],
        correctIndex: 1,
        explanation:
            'The expansion relief valve is set to 6 bar, below the 7 bar '
            'temperature and pressure relief valve, so it operates first if '
            'the vessel fails or pressure rises in normal use.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.calculation,
        prompt:
            'The tundish is fitted 500 mm below the temperature relief '
            'valve. The D2 discharge run uses two 90-degree bends and '
            'terminates outside. Each metre of 22 mm copper is taken as 0.3 '
            'metres resistance, and each elbow as 0.8 metres. If the total '
            'allowed equivalent length for 22 mm is 9 metres, what is the '
            'maximum straight length permitted for a run with two elbows?',
        expectedValue: 7.4,
        tolerance: 0.2,
        unit: 'metres',
        explanation:
            '9 metres total minus 2 elbows at 0.8 metres each (1.6 metres) '
            'leaves 7.4 metres of straight pipe. Each additional elbow '
            'further reduces the permitted straight length.',
        marks: 3,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'The minimum size for the D1 pipe between the temperature '
            'relief valve and the tundish must be at least the size of:',
        choices: [
          'The cold feed to the cylinder',
          'The relief valve outlet',
          '15 mm copper',
          '22 mm copper',
        ],
        correctIndex: 1,
        explanation:
            'D1 must be no smaller than the relief valve outlet. D2 '
            'downstream of the tundish must be at least one pipe size '
            'larger than D1.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'What is the maximum allowable distance from the temperature '
            'relief valve to the tundish?',
        choices: ['300 mm', '500 mm', '600 mm', '1 metre'],
        correctIndex: 2,
        explanation:
            'The tundish must be vertical and within 600 mm of the '
            'temperature relief valve so the discharge is visible and short.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.freeText,
        prompt:
            'List two acceptable termination points for the D2 discharge '
            'pipework outside the building.',
        explanation:
            'Acceptable terminations include a low level termination near '
            'a gully, into a hopper head, a soakaway, or to the outside '
            'wall above the gully but visible. The discharge must be '
            'visible and away from any pedestrian or window.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'During commissioning, the cylinder is filled and you find air '
            'spitting at the hot taps. What is the correct first action?',
        choices: [
          'Drain the cylinder and refill from the bottom',
          'Open every hot tap fully starting at the highest, working down',
          'Increase the incoming mains pressure',
          'Reduce the expansion vessel pre-charge',
        ],
        correctIndex: 1,
        explanation:
            'Open all hot taps starting from the highest outlet and work '
            'down until water flows clear with no air. This purges the air '
            'pocket through the system in the correct direction.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.calculation,
        prompt:
            'You measure the static cold mains as 4.0 bar. Convert this to '
            'kilopascals.',
        expectedValue: 400,
        tolerance: 5,
        unit: 'kPa',
        explanation:
            '1 bar equals 100 kPa, so 4.0 bar equals 400 kPa. Useful when '
            'data sheets quote pressure in different units.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'The customer wants the hot water set to 65 degrees Celsius. '
            'What is the principal reason for not setting it lower than '
            '60 degrees?',
        choices: [
          'To increase mains pressure',
          'To control Legionella bacteria',
          'To save energy',
          'To reduce expansion volume',
        ],
        correctIndex: 1,
        explanation:
            'Storage above 60 degrees Celsius helps to control Legionella. '
            'Mixing valves can then deliver water to outlets at safe '
            'temperatures of 38 to 43 degrees.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.freeText,
        prompt:
            'Write a brief handover note that you would leave for the '
            'customer covering the three things they should check or do in '
            'the first month after the install.',
        explanation:
            'A good handover mentions watching the tundish for any '
            'discharge, periodically operating the temperature and '
            'expansion relief valves, and arranging an annual service. '
            'Mention also retaining the Benchmark commissioning record.',
        marks: 3,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'Which document must be left with the customer after '
            'commissioning?',
        choices: [
          'Energy Performance Certificate',
          'Benchmark commissioning checklist',
          'Building Regulations Part L compliance form',
          'WRAS audit report',
        ],
        correctIndex: 1,
        explanation:
            'The Benchmark commissioning checklist must be filled in and '
            'left with the customer. It also forms a record for the '
            'manufacturer warranty.',
        marks: 1,
      ),
    ],
  ),
  SynopticAssessment(
    id: 'cold_water_design',
    title: 'Design a cold water installation in a four-bedroom house',
    scenario:
        'You are designing the cold water installation for a new four-'
        'bedroom detached house. The property has two full bathrooms, an '
        'en-suite, a downstairs WC and a kitchen. Incoming supply is a 25 '
        'mm MDPE pipe at 3.0 bar dynamic and 4.0 bar static. The customer '
        'wants a fully pumped indirect system with a 230 litre cold water '
        'storage cistern in the loft serving the cylinder, and a fully '
        'mains-fed cold supply to all drinking points. Demand units are '
        'shown on the design sheet.',
    coverage:
        'Cold water | Sizing | Cistern design | Backflow | Pressure',
    timeLimitMinutes: 40,
    tasks: [
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'What is the minimum acceptable dynamic pressure at the highest '
            'tap in a domestic cold supply?',
        choices: ['0.1 bar', '0.5 bar', '1.0 bar', '1.5 bar'],
        correctIndex: 2,
        explanation:
            'A working dynamic pressure of about 1 bar at the most '
            'remote outlet is the usual design target so that mixer taps '
            'and showers operate correctly.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.calculation,
        prompt:
            'A 230 litre cistern feeds the cylinder only. If the household '
            'hot water demand is 200 litres in 30 minutes, calculate the '
            'minimum cistern volume that would meet "one days storage" of '
            '230 litres for safety. Express the chosen cistern as a '
            'percentage of the daily demand in litres.',
        expectedValue: 115,
        tolerance: 2,
        unit: '%',
        explanation:
            '230 divided by 200 equals 1.15, or 115 percent of the daily '
            'hot water demand. Anything above 100 percent provides at '
            'least one days reserve.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'Which pipework material is most commonly used for the rising '
            'main from the stop tap to the kitchen tap in modern houses?',
        choices: [
          '15 mm copper',
          '22 mm copper',
          '25 mm MDPE then reduced to 22 mm copper',
          'Lead',
        ],
        correctIndex: 2,
        explanation:
            'A 25 mm MDPE underground service is reduced to 22 mm copper '
            'inside the property, with a 15 mm branch up to the kitchen '
            'sink so the drinking water is taken from the mains.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'A garden tap is fed directly from the rising main. Which '
            'backflow device must be fitted upstream of the tap?',
        choices: [
          'Single check valve, type EB',
          'Double check valve, type ED',
          'Reduced pressure zone valve, type BA',
          'No device required',
        ],
        correctIndex: 1,
        explanation:
            'A garden tap is a Category 3 risk because of fluid in hoses '
            'and watering cans. A double check valve is the minimum '
            'requirement, fitted internally where it cannot freeze.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'You measure incoming static pressure at 4.0 bar and dynamic '
            'pressure at 3.0 bar. What does the difference suggest?',
        choices: [
          'A leak on the rising main',
          'Friction loss in the supply at flow',
          'A faulty pressure reducing valve',
          'A blocked stop tap',
        ],
        correctIndex: 1,
        explanation:
            'Dynamic pressure is always lower than static because of '
            'friction losses in the supply pipework. A 1 bar drop on a '
            'short domestic service is normal.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.calculation,
        prompt:
            'The cold supply rises 6 metres from the stop tap to the highest '
            'outlet. Static head loss for 6 metres of water is approximately '
            'how many bar? (Use 10 m of head equals 1 bar.)',
        expectedValue: 0.6,
        tolerance: 0.05,
        unit: 'bar',
        explanation:
            '6 metres divided by 10 metres per bar equals 0.6 bar of '
            'static head loss. This must be subtracted from the incoming '
            'pressure when sizing.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'A loft cistern must include which of the following protections '
            'under the Water Regulations?',
        choices: [
          'Insulated lid, screened overflow and warning pipe',
          'Open top with a wire mesh cover',
          'Direct connection to the rising main without a float valve',
          'Secondary return to the cylinder',
        ],
        correctIndex: 0,
        explanation:
            'Loft cisterns must be enclosed with an insulated lid, '
            'screened or filtered to prevent insect entry, and have a '
            'warning pipe and overflow above the float valve.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.calculation,
        prompt:
            'The cistern is 1.0 metre by 0.6 metre by 0.5 metre internal. '
            'Calculate its capacity in litres (1 cubic metre equals 1000 '
            'litres).',
        expectedValue: 300,
        tolerance: 5,
        unit: 'litres',
        explanation:
            '1.0 multiplied by 0.6 multiplied by 0.5 equals 0.3 cubic '
            'metres, which is 300 litres of nominal capacity. Actual '
            'capacity will be slightly less because the float valve sits '
            'below the rim.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'The kitchen sink cold supply must be taken from where, to '
            'comply with the Water Regulations?',
        choices: [
          'Off the cistern in the loft',
          'Off the cylinder cold feed',
          'Direct from the rising main',
          'From the bathroom basin tee',
        ],
        correctIndex: 2,
        explanation:
            'Drinking water at the kitchen sink must come from a wholesome '
            'mains supply, normally direct from the rising main with no '
            'storage upstream.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'Which fluid category applies to a WC cistern with a flush '
            'valve and no chemical tablet?',
        choices: ['Category 2', 'Category 3', 'Category 4', 'Category 5'],
        correctIndex: 1,
        explanation:
            'A WC without chemicals is Category 3. With chemical tablets '
            'or other dosing it becomes Category 5. Both require the '
            'appropriate air-gap or backflow device.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.freeText,
        prompt:
            'Briefly describe the test you would carry out before handing '
            'over the cold water installation.',
        explanation:
            'A pressure or soundness test holds the system at 1.5 times '
            'working pressure for at least an hour, with no measurable '
            'drop, while flushing and chlorination per BS 8558 are also '
            'required before use.',
        marks: 3,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'Which document records the cold water commissioning?',
        choices: [
          'Benchmark heating commissioning',
          'WRAS notification form',
          'Cold water installation commissioning record per BS 8558',
          'Gas Safe CP12',
        ],
        correctIndex: 2,
        explanation:
            'BS 8558 sets out the commissioning record to be retained, '
            'including pressure test, disinfection and final flushing '
            'results.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'What flow rate, in litres per minute, is normally used as a '
            'design target at a kitchen tap?',
        choices: ['3 lpm', '6 lpm', '12 lpm', '20 lpm'],
        correctIndex: 2,
        explanation:
            'A kitchen tap is typically designed for 12 litres per '
            'minute, with shower heads at 9 to 12 lpm and basin taps at '
            'around 6 lpm.',
        marks: 1,
      ),
    ],
  ),
  SynopticAssessment(
    id: 'central_heating_diagnose',
    title: 'Diagnose and repair an S-plan central heating fault',
    scenario:
        'A homeowner reports that her seven-year-old S-plan central '
        'heating system gives plenty of hot water but no radiators, even '
        'with the room thermostat calling for heat. The system has a '
        'system boiler, an unvented cylinder, two two-port motorised '
        'valves, a programmer, a cylinder thermostat and a room '
        'thermostat. The system holds approximately 110 litres including '
        'the radiators, pipework and cylinder primary. You have a '
        'multimeter, a manometer and standard tools.',
    coverage:
        'Central heating | S-plan | Diagnosis | Inhibitor | Paperwork',
    timeLimitMinutes: 50,
    tasks: [
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'In an S-plan, what does the heating zone valve do when the '
            'room thermostat is satisfied?',
        choices: [
          'Stays open, boiler keeps firing for hot water only',
          'Closes, removing the call to the boiler from the heating zone',
          'Opens fully and forces the pump to over-run',
          'Opens the cylinder valve in parallel',
        ],
        correctIndex: 1,
        explanation:
            'When the room stat is satisfied, its zone valve closes and '
            'breaks the call for heat from that zone. The cylinder zone '
            'can still call independently.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'The heating zone valve does not open when the room '
            'thermostat calls. What is the most likely first check?',
        choices: [
          'Replace the boiler PCB',
          'Confirm 230 V at the brown wire of the valve when calling',
          'Power-flush the radiators',
          'Drain the cylinder',
        ],
        correctIndex: 1,
        explanation:
            'A logical electrical check is to verify 230 V live appears at '
            'the valves brown wire when the thermostat calls. If absent, '
            'fault is upstream; if present and the valve does not open, '
            'fault is the valve motor or actuator.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'You confirm 230 V at the brown wire but the valve does not '
            'rotate. Which is the correct next action?',
        choices: [
          'Manually lever the valve open and leave it',
          'Replace the actuator head and re-test',
          'Bypass the valve permanently',
          'Increase the room thermostat by ten degrees',
        ],
        correctIndex: 1,
        explanation:
            'With confirmed power and no movement, the actuator head '
            'should be replaced. Manual levers are for service only and '
            'leaving them latched defeats the safety logic.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.calculation,
        prompt:
            'The system holds 110 litres. Inhibitor is dosed at 1 litre '
            'per 100 litres of system water. How much inhibitor is required?',
        expectedValue: 1.1,
        tolerance: 0.05,
        unit: 'litres',
        explanation:
            '110 divided by 100 equals 1.1 litres. Always round up to the '
            'nearest available bottle size and refer to the manufacturer '
            'data sheet for the chosen inhibitor.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.calculation,
        prompt:
            'After repair, you fill and pressurise the system. Cold fill '
            'should be approximately 1.0 bar. The customer reports the '
            'gauge climbing to 2.8 bar at full operating temperature. By '
            'how much has the pressure increased due to expansion?',
        expectedValue: 1.8,
        tolerance: 0.1,
        unit: 'bar',
        explanation:
            '2.8 minus 1.0 equals 1.8 bar of rise. A normal sealed system '
            'should rise no more than about 1 bar; a 1.8 bar rise '
            'indicates a deflated or failed expansion vessel.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'A pressure rise far above 1 bar most commonly points to '
            'which fault?',
        choices: [
          'Stuck pump impeller',
          'Failed expansion vessel diaphragm or low pre-charge',
          'Frozen condensate pipe',
          'Blocked magnetic filter',
        ],
        correctIndex: 1,
        explanation:
            'A high temperature pressure rise typically means the '
            'expansion vessel is waterlogged or has lost its pre-charge, '
            'so the system has nowhere to absorb expansion.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'You isolate, drain and re-pressurise the expansion vessel. '
            'What pre-charge should you set the vessel to on a typical '
            'sealed domestic heating system?',
        choices: ['0.5 bar', '1.0 bar', '1.5 bar', '3.0 bar'],
        correctIndex: 1,
        explanation:
            'A nominal 1.0 bar pre-charge matches the cold-fill pressure, '
            'so the vessel just begins to accept water as the system '
            'heats. Always check the boiler manual for the exact figure.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'After repair, the boiler short-cycles on heating but is fine '
            'on hot water. What is the most likely cause?',
        choices: [
          'Excess flow rate, pump too fast or wrong speed setting',
          'Cylinder thermostat too high',
          'Flue blocked',
          'Gas inlet pressure too high',
        ],
        correctIndex: 0,
        explanation:
            'Heating short cycling is often related to flow rate or '
            'differential temperature being wrong. Too much flow returns '
            'water that is still hot, so the boiler thermostats off.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.calculation,
        prompt:
            'You balance a radiator using lockshield. Flow temperature is '
            '75 degrees Celsius and you want a 20 Kelvin drop. What '
            'should the return temperature read?',
        expectedValue: 55,
        tolerance: 1,
        unit: 'degrees Celsius',
        explanation:
            '75 minus 20 equals 55 degrees Celsius return temperature. '
            'Use a clip-on pipe thermometer and adjust the lockshield in '
            'small increments, working from the index radiator outwards.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'Why is system filter and inhibitor protection now considered '
            'best practice on heating systems?',
        choices: [
          'It improves boiler efficiency by reducing magnetite and scale',
          'It is required for the WRAS form',
          'It increases system pressure',
          'It removes the need for an expansion vessel',
        ],
        correctIndex: 0,
        explanation:
            'A magnetic filter and corrosion inhibitor reduce the '
            'magnetite that fouls heat exchangers and pumps. They '
            'extend boiler life and maintain efficiency, supporting the '
            'manufacturers warranty.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.freeText,
        prompt:
            'List three things you would write on the customer invoice or '
            'job sheet describing the work done.',
        explanation:
            'A good record covers the fault diagnosis, the parts replaced '
            '(actuator head, inhibitor), the readings taken (cold-fill '
            'pressure, flow and return temperatures, gas working pressure '
            'if applicable) and any guidance to the customer.',
        marks: 3,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'Which Building Regulation covers the energy performance of '
            'heating systems?',
        choices: ['Part G', 'Part L', 'Part J', 'Part P'],
        correctIndex: 1,
        explanation:
            'Part L covers conservation of fuel and power. The Domestic '
            'Building Services Compliance Guide sits under it and sets the '
            'minimum standards for new boiler installations.',
        marks: 1,
      ),
      SynopticTask(
        type: SynopticTaskType.calculation,
        prompt:
            'A power-flush adds 50 litres of fresh water to the 110 litre '
            'system before re-dosing. After dosing 1.1 litres of '
            'inhibitor, what is the inhibitor concentration in percent by '
            'volume of system water?',
        expectedValue: 1.0,
        tolerance: 0.1,
        unit: '%',
        explanation:
            '1.1 litres in 110 litres equals 0.01, or 1.0 percent by '
            'volume, which is the typical 1 in 100 dose recommended by '
            'most manufacturers.',
        marks: 2,
      ),
      SynopticTask(
        type: SynopticTaskType.multipleChoice,
        prompt:
            'Final step before leaving the customer. What must you do?',
        choices: [
          'Demonstrate operation and complete the Benchmark service record',
          'Drain and refill the system once more',
          'Disconnect the room thermostat',
          'Power-flush the cylinder primary',
        ],
        correctIndex: 0,
        explanation:
            'Always demonstrate normal operation, fill in the service '
            'section of the Benchmark book and provide an invoice or job '
            'sheet detailing the work and any recommendations.',
        marks: 1,
      ),
    ],
  ),
];

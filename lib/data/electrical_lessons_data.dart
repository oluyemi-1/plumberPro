import 'lessons_data.dart';

/// Additional lesson topics on electrical principles for plumbers.
const electricalLessonTopics = <LessonTopic>[
  LessonTopic(
    id: 'electrical_principles',
    title: 'Electrical principles for plumbers',
    category: 'Electrical',
    summary:
        'The electrical knowledge a plumber must have to work safely on heating controls, immersion heaters and pumps.',
    sections: [
      LessonSection(
        'Voltage, current and power',
        'A plumber works regularly on circuits at two voltages, the mains supply at two hundred and thirty volts alternating current and extra-low voltage controls at twenty four volts on some heating systems. Voltage is the pressure that pushes electrons along a wire, current measured in amperes is the flow itself, and power in watts is the product of the two. A three kilowatt immersion heater draws thirteen amperes at two hundred and thirty volts, which is why immersion heaters are usually fitted on a dedicated circuit through their own thermal cut-out and through a fused spur. If you cannot remember the formula, watts equal volts times amps.',
      ),
      LessonSection(
        'Single phase, neutral and earth',
        'A domestic supply provides three conductors, line in brown, neutral in blue, and earth in green and yellow. The line carries the voltage, the neutral returns current to the substation, and the earth provides a low impedance path to ground if a fault occurs so the protective device can clear the fault quickly. Older installations used red for line and black for neutral, with green for earth, and you will encounter both colour codes for years to come. Always verify with a tester, not by colour alone.',
      ),
      LessonSection(
        'Protective devices',
        'A miniature circuit breaker, the MCB, protects a circuit against overload and short circuit. A residual current device, the RCD, monitors the balance between line and neutral currents and trips quickly if a small leakage to earth is detected, typically thirty milliamperes within forty milliseconds, which protects a person against electric shock. Modern boards often combine the two functions in a single device called an RCBO. Every circuit you alter must be on the appropriate protection, and you must test it after work.',
      ),
      LessonSection(
        'Where a plumber must call an electrician',
        'Notifiable electrical work in a dwelling under Building Regulations Part P includes any new circuit, any work in a special location like a bathroom or a kitchen wash zone, or any change to the consumer unit. As a plumber you are usually permitted to replace like for like a heating control, an immersion heater element, or a pump, provided the existing protective devices remain in place and the work is competently tested. If in doubt, employ a Part P registered electrician.',
      ),
    ],
  ),
  LessonTopic(
    id: 'safe_isolation',
    title: 'Safe isolation procedure',
    category: 'Electrical',
    summary:
        'The seven step procedure that ensures a circuit is dead before you work on it.',
    sections: [
      LessonSection(
        'Why we isolate',
        'Working on a live circuit risks electric shock, burns, falls and arc-flash injury. The Electricity at Work Regulations nineteen eighty-nine require all work to be carried out dead unless there is a properly justified reason and a documented risk assessment for live work. In practice that means every plumber working on heating controls, immersion heaters, pumps or any wired component must isolate, prove dead, and lock off before they touch a single conductor.',
      ),
      LessonSection(
        'The seven steps',
        'First, identify the supply, locate the right circuit on the consumer unit and confirm with the customer. Second, tell occupants what you are about to do. Third, switch off the appropriate protective device. Fourth, prove that your tester is working on a known live source, often a voltage proving unit or a test socket. Fifth, test all combinations at the point of isolation, line to neutral, line to earth, and neutral to earth, to confirm the circuit is dead. Sixth, prove the tester again on the known source, confirming it has not failed during the test. Seventh, lock off with a padlock and tag the consumer unit with your name and the date.',
      ),
      LessonSection(
        'Locking off and signage',
        'A miniature lock-out hasp is fitted to the breaker, and a personal padlock secures it. Each engineer carries their own key. A warning tag is attached, signed and dated. If multiple engineers work on the same circuit a multi-hasp is used so each engineer fits their own padlock. The keys never leave the engineer, and the lock is only removed by the same person who fitted it.',
      ),
      LessonSection(
        'After the work',
        'When the work is complete, retest the circuit including continuity and insulation resistance where required, restore covers, remove your lock and tag, switch the breaker back on, and demonstrate operation to the customer. Record what you did on a minor works certificate or hand the work over to a registered electrician for testing if the work was notifiable. Never leave site with the lock still fitted.',
      ),
    ],
  ),
  LessonTopic(
    id: 'heating_wiring',
    title: 'Heating system wiring fundamentals',
    category: 'Electrical',
    summary:
        'How a programmer, room thermostat, cylinder thermostat and motorised valves are interconnected.',
    sections: [
      LessonSection(
        'The wiring centre',
        'A wiring centre is a junction box where the boiler, programmer, thermostats and motorised valves are joined. Modern wiring centres come pre-printed with terminals for the standard plans, S-plan and Y-plan, so the engineer connects each component to the appropriate numbered terminal. The result is that the boiler only fires when one or both of the thermostats call for heat, and the appropriate motorised valve is fully open, satisfying the boiler interlock requirement of Building Regulations Part L.',
      ),
      LessonSection(
        'Boiler interlock',
        'Boiler interlock means the boiler is prevented from firing unless there is a genuine demand for heat in the dwelling. The mechanism uses the auxiliary or end-switch contact on each motorised valve. When the valve is driven fully open, the auxiliary switch closes and energises the boiler call-for-heat input. If neither thermostat is calling, no valve opens, no auxiliary switch closes, and the boiler will not fire. This control is mandatory for energy efficiency in modern installations.',
      ),
      LessonSection(
        'TPI and load compensation',
        'A modern programmable thermostat may use time proportional and integral control, where it cycles the boiler on and off to deliver the average temperature requested by the user. Load compensation goes further by reducing the boiler flow temperature as the room approaches setpoint, increasing the time the boiler spends in condensing mode and improving efficiency. Where the boiler supports it, fit a compatible thermostat to take advantage of these features.',
      ),
      LessonSection(
        'Common wiring faults',
        'A loose terminal in the wiring centre is the single most common heating fault and can cause intermittent operation that is hard to track down. A failed motorised valve actuator presents as a system that calls for heat but the boiler will not fire, because the auxiliary switch is not made. A reversed line and neutral on the boiler can cause a sensitive ignition control to behave erratically. Always test polarity at the boiler isolator after any electrical work.',
      ),
    ],
  ),
];

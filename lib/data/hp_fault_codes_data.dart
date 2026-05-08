// Lookup of common UK heat pump fault codes by brand.
//
// Curated from publicly-available manufacturer service manuals and the
// codes UK installers most frequently encounter on commissioning and
// service visits. Where a code's full meaning could not be cross-checked
// against current manufacturer documentation, the description ends with
// 'Manufacturer documentation must be confirmed.' so the trainee always
// validates against the current installation manual on site.

class HpFaultCode {
  final String code;
  final String description;
  final String likelyCauses;
  final String diagnosticSteps;
  final String fixSteps;
  final String safetyNote;
  final String severity;

  const HpFaultCode({
    required this.code,
    required this.description,
    required this.likelyCauses,
    required this.diagnosticSteps,
    required this.fixSteps,
    required this.safetyNote,
    required this.severity,
  });

  String get speakable =>
      'Code $code. $description. Likely causes. $likelyCauses. '
      'Diagnostic steps. $diagnosticSteps. Fix. $fixSteps. '
      'Safety. $safetyNote';
}

class HpBrand {
  final String name;
  final String marketNote;
  final List<HpFaultCode> codes;

  const HpBrand({
    required this.name,
    required this.marketNote,
    required this.codes,
  });
}

const hpBrands = <HpBrand>[
  HpBrand(
    name: 'Vaillant aroTHERM plus',
    marketNote:
        'A propane (R290) monobloc widely deployed under the UK BUS scheme; faults usually shown on the sensoCOMFORT or VRC controller as F.xx codes.',
    codes: <HpFaultCode>[
      HpFaultCode(
        code: 'F.22',
        description:
            'Dry fire / low system water pressure detected by the heating circuit pressure sensor.',
        likelyCauses:
            'System pressure has fallen below the minimum threshold, typically around 0.5 bar. Common causes are a leak on the heating circuit, an exhausted expansion vessel, or a stuck pressure relief valve discharging to drain.',
        diagnosticSteps:
            'Read the pressure on the controller and cross-check against an external gauge on the filling loop. Inspect emitters, manifolds and the PRV tundish for evidence of water loss. Check the expansion vessel charge with the system depressurised.',
        fixSteps:
            'Locate and rectify the leak before topping up. Re-pressurise to 1.0 to 1.5 bar cold via the filling loop, vent emitters, and recharge or replace the expansion vessel if it has lost its gas charge. Reset the appliance only after pressure is stable.',
        safetyNote:
            'Never repeatedly top up a heat pump without finding the leak; oxygen ingress will damage the plate heat exchanger and pump.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'F.75',
        description:
            'Pressure jump on start of pump not detected — pump or pressure sensor fault.',
        likelyCauses:
            'The controller does not see the expected pressure rise when the primary circulator starts. This typically indicates a seized or air-locked pump, a faulty pressure sensor, or a closed isolation valve on the heating return.',
        diagnosticSteps:
            'Check that all service valves on the heat pump are fully open. Listen and feel for the pump running, then bleed any trapped air from the high points. Read the live pressure value in the installer menu while manually starting the pump.',
        fixSteps:
            'Vent the system thoroughly, including the magnetic filter and low-loss header if fitted. Replace the pressure sensor or the primary pump if the head is not developing. Clear the F.75 lockout from the installer menu after a successful test.',
        safetyNote:
            'Isolate electrically before working on the pump head and beware of hot water if the system has been running.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'F.85',
        description:
            'Flow and return temperature sensors swapped or reading implausibly close.',
        likelyCauses:
            'The NTC sensors on the flow and return have been fitted to the wrong pockets, the sensor leads are reversed at the PCB, or one of the sensors has drifted out of tolerance. It is most often seen immediately after commissioning or a parts swap.',
        diagnosticSteps:
            'Compare flow and return readings on the controller to a clamp-on contact thermometer at each pipe. Verify the wiring against the installation diagram and check sensor resistance against the NTC table.',
        fixSteps:
            'Refit each sensor to its correct pocket with fresh thermal paste, or swap the connections at the terminal block. Replace any sensor that is out of tolerance. Reset and run a heating cycle to confirm a normal delta-T.',
        safetyNote:
            'Sensor pockets can be hot when the system has just been running; allow to cool before handling.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'F.91',
        description:
            'Communication fault between indoor hydraulic unit and outdoor unit (eBus).',
        likelyCauses:
            'The eBus link between indoor and outdoor units is broken, miswired or affected by induced noise. Causes include damaged cable, reversed polarity, or running the bus in the same conduit as mains cabling.',
        diagnosticSteps:
            'Check eBus voltage at both ends — a healthy bus reads roughly 15 to 24 V DC. Inspect the cable for damage, swap polarity if comms are intermittent, and confirm correct termination per the installation manual.',
        fixSteps:
            'Re-terminate or replace the eBus cable, route it away from mains, and ensure each PCB is on the latest firmware. Power cycle both units after the repair.',
        safetyNote:
            'Always isolate the unit at both indoor and outdoor disconnects before opening enclosures.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'F.12',
        description:
            'Cylinder (DHW) sensor fault — short circuit, open circuit or out of range.',
        likelyCauses:
            'The DHW NTC sensor in the cylinder pocket is damaged, the lead has been crushed in a clip, or the connector at the PCB is loose. It can also be caused by a sensor not seated fully into the pocket.',
        diagnosticSteps:
            'Disconnect the sensor at the PCB and measure resistance — at 20 C an NTC 10k reads about 12.5 kilo-ohm. Check for continuity of the lead and that the sensor is fully home in the pocket with thermal paste.',
        fixSteps:
            'Replace the sensor if out of tolerance, re-seat in the pocket, and clip the lead clear of sharp edges. Re-power the appliance and run a hot water demand to confirm a sensible reading.',
        safetyNote:
            'The cylinder may be hot — drain or allow to cool before removing the sensor pocket if needed.',
        severity: 'Service required',
      ),
      HpFaultCode(
        code: 'F.42',
        description:
            'Coding resistor fault — appliance has not detected the correct unit ID resistor.',
        likelyCauses:
            'The coding resistor on the appliance loom is missing, damaged, or a replacement PCB has been fitted without being matched to the outdoor unit. It can also follow incorrect parameter setting after a board swap.',
        diagnosticSteps:
            'Verify the resistor value against the model-specific table in the service manual. Check the connector is fully home and the leads are intact.',
        fixSteps:
            'Refit or replace the coding resistor with the correct value for the unit. After replacement run the installer assistant to re-pair the boards and clear the lockout.',
        safetyNote:
            'Manufacturer documentation must be confirmed for the exact resistor value before fitting.',
        severity: 'Lockout',
      ),
    ],
  ),
  HpBrand(
    name: 'Daikin Altherma 3',
    marketNote:
        'Daikin Altherma 3 (R32) split and monobloc systems are common in UK new-build; codes are shown on the Madoka or room controller as a two-character master/slave pair.',
    codes: <HpFaultCode>[
      HpFaultCode(
        code: 'L4',
        description:
            'Compressor / inverter PCB high temperature — heatsink overtemperature on the outdoor PCB.',
        likelyCauses:
            'Airflow over the inverter heatsink is restricted or the unit is running at maximum demand on a hot day. Causes include a blocked outdoor coil, dirty fan, failed inverter fan, or thermal grease that has dried out.',
        diagnosticSteps:
            'Inspect the outdoor coil and fan for debris, leaves and ice. Read the heatsink temperature in the service menu and check fan operation through a forced cooling run.',
        fixSteps:
            'Clean the coil with a soft brush from the inside out, replace the fan motor if seized, and renew thermal compound on the inverter module if it has dried. Reset the lockout after a 10 minute cool-down.',
        safetyNote:
            'High DC bus voltages remain on the inverter board after isolation — wait at least 10 minutes before touching internal components.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: '7H',
        description:
            'Insufficient water flow detected by the flow switch or flow sensor.',
        likelyCauses:
            'The primary water flow rate has fallen below the minimum required by the unit, often around 12 to 15 litres per minute on a 6 to 8 kW Altherma. Causes include a partially closed valve, blocked strainer, air-locked emitters, or a failing primary pump.',
        diagnosticSteps:
            'Read the live flow rate on the controller. Check the magnetic filter, strainer and isolation valves on the heating circuit, then bleed all emitters and the air separator.',
        fixSteps:
            'Clean the filter, fully open all valves, vent the system and increase pump speed if necessary. If the flow sensor itself is suspect, check its output against a clamp-on flow meter.',
        safetyNote:
            'Do not bypass the flow switch — operating without minimum flow risks plate heat exchanger freeze damage.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'C7',
        description:
            'Outdoor fan motor fault — motor over-current, locked rotor or feedback signal missing.',
        likelyCauses:
            'The fan blade is obstructed by ice or debris, the bearings have failed, or the brushless DC fan controller has lost its Hall feedback. Coastal salt corrosion is a common UK cause on units more than five winters old.',
        diagnosticSteps:
            'With power isolated, spin the fan by hand to feel for stiffness or roughness. Inspect the wiring loom to the fan and check the resistance of each phase. Power up and watch the fan during a heating start.',
        fixSteps:
            'Clear any obstruction, replace the fan motor if the bearings are noisy, and renew the loom or PCB if the drive output is faulty. Confirm correct rotation direction after refit.',
        safetyNote:
            'Inverter capacitors hold dangerous charge — wait the manufacturer-specified discharge time before touching the PCB.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'U0',
        description:
            'Refrigerant shortage — low pressure or low superheat detected by the inverter logic.',
        likelyCauses:
            'A leak on the refrigerant circuit, a partially closed service valve, or a blocked expansion valve causing apparent shortage. New installations sometimes show U0 if the pre-charge is short for the actual pipe length.',
        diagnosticSteps:
            'Check that both liquid and gas service valves are fully open. Connect manifold gauges and compare suction and discharge pressures with the manufacturer chart. Carry out a leak test with electronic detector and bubble spray on flares.',
        fixSteps:
            'Repair any leak found, evacuate to 500 microns, and weigh in the correct charge for the pipe length. F-Gas certification is required for any refrigerant work.',
        safetyNote:
            'R32 is mildly flammable (A2L); use spark-free tools and ventilate the area before any work on the refrigerant circuit.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'J3',
        description:
            'Discharge pipe thermistor fault — open or short circuit on the compressor discharge sensor.',
        likelyCauses:
            'The discharge thermistor has failed open or short, or its lead has been damaged at the compressor terminal box. It can also be tripped by a single intermittent connection in the JST connector at the PCB.',
        diagnosticSteps:
            'Disconnect at the PCB and measure resistance against the manufacturer chart at ambient temperature. Wiggle-test the lead from the sensor to the terminal box and PCB.',
        fixSteps:
            'Replace the thermistor with the correct OEM part, route it clear of sharp edges, and re-secure with the original cable ties. Reset the unit and run a heating cycle to confirm sensible discharge readings.',
        safetyNote:
            'The discharge pipe runs above 90 C in operation; allow the compressor to cool fully before touching.',
        severity: 'Service required',
      ),
      HpFaultCode(
        code: 'AA',
        description:
            'Communication fault between indoor unit (hydrobox) and user interface or room controller.',
        likelyCauses:
            'A broken or miswired P1/P2 control cable, polarity reversed, or a faulty Madoka / room controller. EMI from nearby switching power supplies can also induce noise on long runs.',
        diagnosticSteps:
            'Measure DC voltage across P1/P2 — typically around 16 V DC. Inspect the cable for damage, especially where it passes through metalwork, and check both connectors are home.',
        fixSteps:
            'Re-terminate the cable, swap to a screened pair if induced noise is suspected, and replace the room controller if the indoor unit comms are otherwise healthy.',
        safetyNote:
            'Manufacturer documentation must be confirmed for the exact code mapping on your specific Altherma 3 model variant.',
        severity: 'Warning',
      ),
    ],
  ),
  HpBrand(
    name: 'Mitsubishi Ecodan',
    marketNote:
        'Mitsubishi Ecodan (R32 PUZ-WM and PUD ranges) is one of the most-installed heat pumps under MCS in the UK; codes are shown as letter-number pairs on the FTC controller.',
    codes: <HpFaultCode>[
      HpFaultCode(
        code: 'P5',
        description:
            'Frost protection — primary water temperature has fallen close to freezing.',
        likelyCauses:
            'Loss of flow during a defrost, a stuck three-way valve, or a power interruption when the system was at low temperature. It can also be triggered by a faulty thermistor.',
        diagnosticSteps:
            'Check the flow temperature on the FTC monitor screens, inspect the three-way valve actuator, and verify the primary pump is running on a heat demand. Read the THW thermistors and compare to ambient.',
        fixSteps:
            'Restore flow, replace any failed thermistor or valve actuator, and check the primary circuit for glycol concentration if installed in an unheated plant room. Clear the lockout via the FTC service menu.',
        safetyNote:
            'If a freeze burst is suspected, isolate water and refrigerant before re-energising — a cracked plate heat exchanger can mix water and refrigerant.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'P8',
        description:
            'Abnormal water circulation — flow detected but flow/return temperatures do not behave as expected.',
        likelyCauses:
            'Air in the system, a stuck mixing valve, or a primary pump running below its minimum duty point. It is often seen on systems with a low-loss header that has not been fully vented.',
        diagnosticSteps:
            'Read flow, return and target temperatures on the FTC. Vent all high points and the air separator. Verify pump speed and check the magnetic filter for blockage.',
        fixSteps:
            'Vent thoroughly, increase pump speed if delta-T is too high, and clean the filter. Replace the pump or mixing valve actuator if behaviour does not normalise.',
        safetyNote:
            'Hot water can scald — open vents slowly and use suitable PPE.',
        severity: 'Warning',
      ),
      HpFaultCode(
        code: 'F0',
        description:
            'Anti-freeze cycle running — outdoor unit pumping heat back into the water briefly to prevent freezing.',
        likelyCauses:
            'Not strictly a fault; the controller logs F0 when ambient and water temperatures are low enough that the anti-freeze logic engages. Frequent F0 events outside cold weather indicate poor heat retention or a stuck pump.',
        diagnosticSteps:
            'Review the event history alongside outside temperature data. Check that emitters are not isolated overnight by zone valves and that the pump runs as scheduled.',
        fixSteps:
            'Adjust controls so the system circulates during freezing weather, add weather compensation if not present, and add glycol to circuits in unheated areas where appropriate.',
        safetyNote:
            'Glycol must be a heat-pump approved inhibitor at the correct concentration; over-strong glycol reduces heat transfer significantly.',
        severity: 'Warning',
      ),
      HpFaultCode(
        code: 'L9',
        description:
            'Refrigerant or low-pressure protection — system has detected abnormally low suction pressure or undercharge.',
        likelyCauses:
            'A refrigerant leak, blocked outdoor coil reducing evaporation, or an electronic expansion valve stuck partially closed. Severe icing of the outdoor coil during prolonged cold/wet weather can also trigger it.',
        diagnosticSteps:
            'Inspect the outdoor coil for ice and clear any obvious blockage. Read live suction pressure and superheat in the service menu, and leak-test all flares and brazed joints.',
        fixSteps:
            'Repair leaks under F-Gas regulations, evacuate and recharge by weight. Replace the EEV coil or body if it is not stepping correctly. Confirm defrost cycle operation after repair.',
        safetyNote:
            'Manufacturer documentation must be confirmed — code mapping varies between PUZ-WM and PUD generations.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'E0',
        description:
            'Communication error — remote controller and FTC not exchanging data.',
        likelyCauses:
            'Wiring fault on the M-NET or two-wire control cable, controller addressing conflict, or a failed FTC interface board. Often follows house-rewiring work where the controller cable has been disturbed.',
        diagnosticSteps:
            'Check polarity and continuity on the controller cable. Confirm the controller address is set correctly and only one main controller is configured per group.',
        fixSteps:
            'Re-terminate the controller cable, set addresses per the installation manual, and replace the controller or FTC if comms remain absent. Power cycle both units after repair.',
        safetyNote:
            'Always isolate before opening the FTC; mains and low-voltage terminals share the same enclosure.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'L3',
        description:
            'Circulation water temperature overheat — primary water has exceeded the safe operating limit.',
        likelyCauses:
            'A stuck three-way valve sending all flow through the immersion or backup heater, a failed flow thermistor reading low, or a closed zone valve preventing dissipation of generated heat.',
        diagnosticSteps:
            'Check the position of the three-way valve and the state of all zone valves. Compare THW1/THW2 readings to a contact thermometer. Verify the backup heater is not energised when it should not be.',
        fixSteps:
            'Free or replace the diverter valve, replace the flow thermistor if drifting, and confirm zone wiring centres operate correctly. Allow the system to cool before resetting.',
        safetyNote:
            'Water above 60 C will scald in seconds; relieve pressure carefully before opening any joint.',
        severity: 'Lockout',
      ),
    ],
  ),
  HpBrand(
    name: 'Samsung EHS',
    marketNote:
        'Samsung EHS Mono and ClimateHub units are widely deployed on UK social housing and new-build; faults are shown as four-digit E codes on the wired controller.',
    codes: <HpFaultCode>[
      HpFaultCode(
        code: 'E101',
        description:
            'Communication error between indoor and outdoor unit.',
        likelyCauses:
            'F1/F2 communication cable is damaged, miswired, or polarity reversed. Long parallel runs with mains cabling, missing screen earthing, or a failed comms transformer on either PCB also cause it.',
        diagnosticSteps:
            'Measure DC voltage across F1/F2 at both indoor and outdoor terminals. Inspect cable routing for damage and proximity to mains. Confirm both units are powered and circuit breakers are in.',
        fixSteps:
            'Re-terminate or replace the comms cable using a screened twisted pair, ensure correct polarity, and isolate from mains conduit. Replace the comms transformer or PCB if voltage is absent.',
        safetyNote:
            'Mains and low-voltage share the indoor terminal block — fully isolate before testing.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'E202',
        description:
            'Outdoor unit not responding to indoor request — comms timeout after handshake.',
        likelyCauses:
            'Outdoor unit has lost mains power, an outdoor PCB fault, or addressing mismatch after a parts replacement. It can also follow an inverter trip that left the outdoor unit in a fault hold.',
        diagnosticSteps:
            'Confirm mains at the outdoor isolator and check the outdoor LED diagnostics. Read the address dip switches on both PCBs and compare with the installation manual.',
        fixSteps:
            'Restore mains, correct addressing, and reset both units. Replace the outdoor main PCB if it does not boot or shows continuous error LEDs.',
        safetyNote:
            'Wait at least 10 minutes after isolation before opening the outdoor PCB cover to allow capacitors to discharge.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'E416',
        description:
            'Discharge temperature too high — compressor discharge thermistor reading above safe limit.',
        likelyCauses:
            'Refrigerant undercharge causing high superheat, EEV stuck closed, or restricted condenser airflow. Operating in very low ambient with poor evaporator performance can also push discharge temperature into trip.',
        diagnosticSteps:
            'Read live discharge temperature, suction pressure and superheat. Inspect outdoor coil for ice or debris, and verify EEV stepping during a controlled run.',
        fixSteps:
            'Recover and weigh-in correct charge if undercharged, replace the EEV coil or body if stuck, and clean the coil. F-Gas qualification is required for refrigerant work.',
        safetyNote:
            'R32 is A2L flammable; ensure good ventilation and remove ignition sources before any refrigerant work.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'E458',
        description:
            'Outdoor fan motor fault — fan has not reached target speed or feedback is missing.',
        likelyCauses:
            'Obstructed fan blade, failed fan bearings, water ingress into the fan motor, or a failed fan drive on the outdoor PCB. UK coastal sites see this regularly from salt corrosion.',
        diagnosticSteps:
            'Power off and spin the fan by hand to feel for resistance or grinding. Check the fan loom for water ingress and measure the motor windings.',
        fixSteps:
            'Replace the fan motor with the correct part, drying or replacing any waterlogged loom. Run a forced fan test from the service menu to confirm.',
        safetyNote:
            'Always isolate at the outdoor disconnect; the fan can spool up unexpectedly during a defrost.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'E554',
        description:
            'Refrigerant leak suspected — system pressures or temperatures indicate insufficient charge.',
        likelyCauses:
            'A leak on a flare joint, brazed connection or service port. New installations sometimes show E554 if vacuum was inadequate and non-condensables remain in the circuit.',
        diagnosticSteps:
            'Carry out an electronic leak test on all joints and brazed connections, then bubble-test under nitrogen if necessary. Check service port caps are correctly torqued.',
        fixSteps:
            'Repair leaks, evacuate to 500 microns, and weigh in the correct charge per the data plate. Run a commissioning cycle and confirm pressures and superheat.',
        safetyNote:
            'Refrigerant must be recovered, not vented, under EU/UK F-Gas regulations.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'E904',
        description:
            'Water flow rate too low — flow switch or flow sensor below threshold.',
        likelyCauses:
            'Closed isolation valve, blocked Y-strainer or magnetic filter, air-locked system, or failing primary pump. Common after a service where the filter has not been re-opened fully.',
        diagnosticSteps:
            'Check live flow rate on the controller, inspect the strainer and magnetic filter, and verify all service valves are open. Bleed all emitters and the air separator.',
        fixSteps:
            'Clean the filter, vent the system, increase pump speed and confirm flow. Replace the pump or flow sensor if the readings remain low after venting.',
        safetyNote:
            'Do not run the unit on a known low flow — the plate heat exchanger can freeze and crack within minutes.',
        severity: 'Lockout',
      ),
    ],
  ),
  HpBrand(
    name: 'Grant Aerona3',
    marketNote:
        'Grant Aerona3 (R32) monoblocs are popular on UK off-gas oil-replacement projects; faults are shown on the wired controller as P, E, HP or LP indicators.',
    codes: <HpFaultCode>[
      HpFaultCode(
        code: 'P4',
        description:
            'High pressure fault — discharge pressure has exceeded the high-pressure cut-out setting.',
        likelyCauses:
            'Restricted water flow on the condenser side, system temperature already very high, scale or sludge fouling the plate heat exchanger, or non-condensables in the refrigerant circuit. Operating into a closed zone can also push pressure up rapidly.',
        diagnosticSteps:
            'Read condenser water flow and delta-T, inspect the magnetic filter, and confirm zone valves are open. Connect gauges and compare discharge pressure to the manufacturer chart for the running condition.',
        fixSteps:
            'Restore flow, flush the plate exchanger if scaled, and recover and recharge if non-condensables are suspected. Reset the lockout once pressures are stable.',
        safetyNote:
            'Discharge side pipework can exceed 80 C; allow to cool and use suitable PPE for any disconnection.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'P6',
        description:
            'Low pressure fault — suction pressure has fallen below the low-pressure cut-out setting.',
        likelyCauses:
            'Refrigerant undercharge, blocked outdoor coil, partial EEV blockage, or running in extreme cold without adequate defrost. A failed low-pressure transducer can also report a false low.',
        diagnosticSteps:
            'Inspect the outdoor coil for icing or debris, run a forced defrost, and check live suction pressure on the controller. Leak-test the circuit and verify the transducer signal.',
        fixSteps:
            'Clean the coil, repair any leak, recharge by weight, and renew the EEV or transducer if faulty. Confirm normal pressures across a heating run before handing back.',
        safetyNote:
            'R32 is A2L flammable — ventilate the area and remove ignition sources before opening the refrigerant circuit.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'P9',
        description:
            'DHW (cylinder) sensor fault — open, short or out-of-range reading.',
        likelyCauses:
            'Damaged sensor lead, sensor not fully home in the cylinder pocket, or a failed NTC element. Sometimes follows installation of a new cylinder where the old sensor was reused.',
        diagnosticSteps:
            'Disconnect at the controller and measure resistance against the NTC chart, then check continuity along the lead. Confirm the sensor is fully seated with thermal paste.',
        fixSteps:
            'Replace the sensor if out of tolerance, re-seat into the pocket, and clip the lead clear of the cylinder thermostat strap. Reset the appliance and run a hot water demand.',
        safetyNote:
            'Cylinder may be hot — beware of scalding when removing the sensor pocket cap.',
        severity: 'Service required',
      ),
      HpFaultCode(
        code: 'E5',
        description:
            'Water flow fault — primary flow below required minimum.',
        likelyCauses:
            'Blocked filter, closed isolation valve, air-locked system or failing primary pump. Frequently appears after annual service if the filter has not been refitted correctly.',
        diagnosticSteps:
            'Check live flow on the controller, inspect filters, and verify all valves are open. Vent the system thoroughly and confirm the pump is running at the correct speed.',
        fixSteps:
            'Clean the filter, vent emitters, increase pump duty, and replace the pump if it cannot develop the required head. Reset and confirm normal operation.',
        safetyNote:
            'Never bypass the flow switch to clear E5 — operating at low flow risks freezing and bursting the plate heat exchanger.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'HP',
        description:
            'High-pressure switch tripped (mechanical) — discharge pressure cut-out has opened the safety circuit.',
        likelyCauses:
            'Same root causes as P4 but reaching the mechanical safety cut-out. Often the result of a sudden loss of water flow during operation, or a severely fouled plate heat exchanger.',
        diagnosticSteps:
            'Allow the system to cool, then check water flow, filters and zone valve states. Inspect the high-pressure switch wiring and continuity once cool.',
        fixSteps:
            'Restore flow and clean the plate heat exchanger if scaled. Replace the high-pressure switch if it does not reset cleanly. Manufacturer documentation must be confirmed for the exact reset procedure on your firmware revision.',
        safetyNote:
            'Repeated HP trips indicate a real fault — do not simply reset and run; investigate before re-energising.',
        severity: 'Lockout',
      ),
      HpFaultCode(
        code: 'LP',
        description:
            'Low-pressure switch tripped (mechanical) — suction pressure cut-out has opened the safety circuit.',
        likelyCauses:
            'Refrigerant leak, severe coil icing, or a failed low-pressure switch. After long winter idle periods a slow leak from a flare joint is the most common UK cause.',
        diagnosticSteps:
            'Inspect the outdoor coil for ice or blockage, run a forced defrost if available, and leak-test the circuit. Confirm the switch contacts make and break correctly.',
        fixSteps:
            'Repair leaks, evacuate and recharge by weight under F-Gas. Replace the LP switch if it does not reset cleanly after pressure is restored.',
        safetyNote:
            'Refrigerant must be recovered, not vented; only F-Gas certified engineers may break into the refrigerant circuit.',
        severity: 'Lockout',
      ),
    ],
  ),
];

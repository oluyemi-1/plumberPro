class TroubleCase {
  final String id;
  final String symptom;
  final String system;
  final List<String> likelyCauses;
  final List<String> diagnosticSteps;
  final List<String> fixSteps;
  final String safetyNote;
  const TroubleCase({
    required this.id,
    required this.symptom,
    required this.system,
    required this.likelyCauses,
    required this.diagnosticSteps,
    required this.fixSteps,
    required this.safetyNote,
  });

  String get narration =>
      'Symptom. $symptom. Likely causes. ${likelyCauses.join(". ")}. Diagnostic steps. ${diagnosticSteps.join(". ")}. Fix. ${fixSteps.join(". ")}. Safety note. $safetyNote';
}

const troubleCases = <TroubleCase>[
  TroubleCase(
    id: 'no_hot_water_combi',
    symptom: 'No hot water from a combi boiler, but central heating works',
    system: 'Hot water',
    likelyCauses: [
      'A stuck diverter valve keeping the boiler in heating mode',
      'A failed domestic hot water flow switch or turbine',
      'A scaled or blocked secondary plate heat exchanger',
    ],
    diagnosticSteps: [
      'Open a hot tap fully and listen for the boiler firing within a few seconds',
      'Check the boiler display for fault codes indicating diverter or flow sensor failure',
      'With the tap running, feel the plate heat exchanger, it should warm quickly if the diverter has moved',
      'Check the incoming cold pressure is at least one bar, because low flow can prevent firing',
    ],
    fixSteps: [
      'Isolate electrical and water supplies to the boiler',
      'Remove the diverter motor head and manually free the spindle, if seized replace the diverter cartridge',
      'If the plate heat exchanger is scaled, isolate it, flush with a descaler or replace',
      'Refit, refill the system to one bar, bleed the domestic hot water circuit and re-commission',
    ],
    safetyNote:
        'This work involves a gas appliance and must be carried out by a Gas Safe registered engineer. Always cap the gas supply while the boiler case is open.',
  ),
  TroubleCase(
    id: 'radiator_cold_top',
    symptom: 'Radiator is cold at the top but hot at the bottom',
    system: 'Heating',
    likelyCauses: [
      'Trapped air at the top of the radiator, the most common cause',
      'Insufficient system pressure so water cannot reach upper floors',
    ],
    diagnosticSteps: [
      'Feel the radiator, the hot at the bottom cold at the top pattern is classic for air',
      'Check the system pressure gauge at the boiler, it should read between one and one and a half bar cold',
      'Check that the flow valve at the bottom of the radiator is fully open',
    ],
    fixSteps: [
      'Place a cloth or tray under the bleed screw to catch drips',
      'Open the bleed screw with a radiator key one full turn, air will hiss out',
      'Close the screw as soon as a steady stream of water appears',
      'Re-pressurise the boiler to one bar using the filling loop',
      'Recheck each radiator in turn working from the boiler outwards',
    ],
    safetyNote:
        'The water inside the radiator may be very hot. Turn off the heating at least an hour before bleeding and wear gloves.',
  ),
  TroubleCase(
    id: 'radiator_cold_bottom',
    symptom: 'Radiator is hot at the top but cold at the bottom',
    system: 'Heating',
    likelyCauses: [
      'Sludge build-up of iron oxide at the bottom of the radiator',
      'Poorly inhibited system with previous air ingress',
    ],
    diagnosticSteps: [
      'Feel the radiator body, cold at the bottom indicates solids blocking the base',
      'Test the system water with an inhibitor strip, a low inhibitor reading correlates with sludge',
      'Inspect the filling loop and look for recent top ups that dilute the inhibitor',
    ],
    fixSteps: [
      'Isolate the radiator at both valves counting the turns on the lockshield',
      'Unscrew the tail nuts, lift the radiator, take it outside and flush with a hose until clear',
      'Refit, balance by returning the lockshield to its original position, vent the air',
      'Dose the system with a proprietary cleaner, circulate for one week, drain and refill with fresh water plus inhibitor',
      'Consider a power flush or a magnetic filter if the whole system is affected',
    ],
    safetyNote:
        'Drained water from a dirty system stains carpets badly. Lay a waterproof sheet and protect skirtings before lifting the radiator.',
  ),
  TroubleCase(
    id: 'pressure_drop_sealed',
    symptom: 'Sealed system pressure keeps falling',
    system: 'Heating',
    likelyCauses: [
      'A visible or hidden leak in pipework or on a radiator valve',
      'A failed or waterlogged expansion vessel',
      'A passing pressure relief valve discharging quietly to the tundish or outside',
    ],
    diagnosticSteps: [
      'Walk every radiator and valve with a dry paper towel, feeling for moisture',
      'Check the pressure relief discharge pipe outside, a dripping pipe indicates either high pressure or a passing valve',
      'Turn off the boiler, let the system cool, compare pressure hot to cold, a healthy expansion vessel gives a rise of about half a bar between cold and full operating temperature',
      'Check the Schrader valve on the expansion vessel, if water comes out the diaphragm has failed',
    ],
    fixSteps: [
      'Repair any visible leak, tighten compression joints a quarter turn at a time, do not over tighten',
      'If the expansion vessel is waterlogged, isolate it, drain the system to zero bar, re-charge the vessel to one bar, refill',
      'If the pressure relief valve is passing because of scale, replace the valve outright, never leave one jammed shut',
    ],
    safetyNote:
        'Never block a pressure relief discharge pipe. It is a safety device and must terminate where a discharge is visible and cannot scald anyone.',
  ),
  TroubleCase(
    id: 'tap_dripping',
    symptom: 'Tap drips when fully closed',
    system: 'Taps',
    likelyCauses: [
      'A worn washer or ceramic cartridge',
      'A damaged seat inside the body of the tap',
      'Excessive mains pressure stressing the tap',
    ],
    diagnosticSteps: [
      'Identify the tap type, a traditional compression tap uses a rubber washer, a quarter turn tap uses a ceramic disc cartridge',
      'Inspect the seat with a torch for pitting or scale',
      'Measure the mains pressure, anything over five bar suggests a pressure reducing valve is needed',
    ],
    fixSteps: [
      'Isolate the water supply using the service valve on the tap tail',
      'Strip the tap, replace the washer or the ceramic cartridge, clean the seat with a reseating tool if pitted',
      'Reassemble, turn the water back on slowly and check for weeping',
    ],
    safetyNote:
        'Plug the basin first, loose screws can vanish down the waste in a second. Keep replacement washers in a range of sizes in the van.',
  ),
  TroubleCase(
    id: 'wc_running',
    symptom: 'WC cistern is continuously running or overflowing',
    system: 'Drainage',
    likelyCauses: [
      'A failed float valve that will not shut off at the correct level',
      'A perished flush valve diaphragm allowing water to leak through into the pan',
      'A blocked or incorrectly set overflow standpipe in a bottom entry cistern',
    ],
    diagnosticSteps: [
      'Lift the cistern lid and watch the water level, if it exceeds the waterline mark the float valve is at fault',
      'Add a few drops of food dye to the cistern, if colour appears in the pan without flushing, the flush valve is leaking',
    ],
    fixSteps: [
      'Isolate the service valve on the cistern supply',
      'Adjust or replace the float valve, setting the shutoff level about twenty five millimetres below the overflow',
      'Replace the flush valve diaphragm, most modern valves are pull out cartridges',
      'Refit, check cycle the flush two or three times to confirm shutoff',
    ],
    safetyNote:
        'An overflow running continuously wastes enormous volumes of water and may be a notifiable nuisance under the water regulations.',
  ),
  TroubleCase(
    id: 'blocked_basin',
    symptom: 'Basin draining slowly or not at all',
    system: 'Drainage',
    likelyCauses: [
      'Hair and soap build-up in the pop up waste and trap',
      'A downstream blockage further along the branch',
    ],
    diagnosticSteps: [
      'Remove the pop up plug and inspect the strainer',
      'Pour a kettle of hot water to confirm partial flow',
      'If flow is zero after clearing the plug, the blockage is in the trap or branch',
    ],
    fixSteps: [
      'Place a bucket under the trap and unscrew the two access nuts',
      'Lift the trap out, flush under a running tap, refit using hand pressure only, plastic traps do not need a wrench',
      'Check the seal of the washers and test run the basin for ten seconds',
    ],
    safetyNote:
        'Do not use caustic drain unblocker without eye protection. Never mix different drain cleaners, the reaction can generate chlorine gas.',
  ),
  TroubleCase(
    id: 'boiler_lockout',
    symptom: 'Boiler keeps locking out with an ignition fault',
    system: 'Boiler',
    likelyCauses: [
      'Failed ignition electrode or lead',
      'Incorrect gas pressure at the appliance',
      'A blocked condensate pipe freezing in winter',
    ],
    diagnosticSteps: [
      'Record the fault code displayed and check the manufacturer book',
      'Inspect the electrode gap, a scorched or broken tip prevents spark',
      'Test gas working pressure at the inlet, typically around twenty millibar natural gas',
      'Check the condensate pipe outside, if frozen thaw with warm water and insulate',
    ],
    fixSteps: [
      'Replace the ignition electrode and its lead as a pair',
      'Adjust gas valve to manufacturer spec if required, never guess, use a combustion analyser',
      'Reset, fire the boiler, take full combustion readings and record on the service record',
    ],
    safetyNote:
        'This is Gas Safe notifiable work. Never bypass a lockout, the boiler has shut down because it has detected an unsafe condition.',
  ),

  // ─── Electric boiler trouble cases ──────────────────────────────────────
  TroubleCase(
    id: 'eb_no_display',
    symptom: 'Electric boiler completely dead — no display, no LEDs',
    system: 'Electric boiler',
    likelyCauses: [
      'The dedicated boiler circuit RCBO or MCB has tripped at the consumer unit',
      'The local isolator switch beside the boiler is off',
      'Internal low-voltage fuse on the PCB has blown',
      'The PCB itself has failed',
    ],
    diagnosticSteps: [
      'Check the consumer unit for a tripped RCBO or MCB on the boiler circuit',
      'Check the local rotary isolator or fused spur next to the boiler',
      'Safely isolate, prove dead, and lock off before removing the front cover',
      'With the cover off and the supply restored, measure two hundred and thirty volts at the boiler terminal block',
      'If voltage is present at the terminals but no display, suspect a blown PCB fuse or PCB failure',
    ],
    fixSteps: [
      'Reset the protective device once and observe whether it holds, repeated trips mean a fault to investigate not a reset to chase',
      'If a PCB fuse is blown, replace like-for-like and only fire up after insulation resistance testing the element',
      'If the PCB itself is dead, fit the manufacturer replacement and re-commission per the install manual',
    ],
    safetyNote:
        'Treat every cover removal as live electrical work. Safe isolation, lock off, prove dead with a known-good tester before fingers anywhere near the terminal block.',
  ),
  TroubleCase(
    id: 'eb_overheat_lockout',
    symptom: 'Electric boiler locks out on overheat shortly after firing',
    system: 'Electric boiler',
    likelyCauses: [
      'Pump has failed or is air-locked, so heat is not being carried away from the element',
      'Closed isolation valve or stuck thermostatic radiator valves are blocking flow',
      'Automatic bypass valve is shut so the pump has no flow path at low demand',
      'Heavy scale or sludge build-up on the element insulating it from the water',
    ],
    diagnosticSteps: [
      'Look and listen — is the pump running when the boiler is calling for heat',
      'Feel the flow and return pipes — both should warm together; cold return means no circulation',
      'Check system pressure between one and one-and-a-half bar cold',
      'Vent every radiator at the upstairs ends of the system to clear air',
      'Inspect the bypass valve and the magnetic filter, clean and reset both',
      'Drop the front cover and check the element for visible scale or sludge after isolation',
    ],
    fixSteps: [
      'Bleed air, reset the bypass valve, refit the magnetic filter clean',
      'If the pump is failed or seized, replace with the manufacturer specified pump',
      'If the element is scaled, descale or replace the element; treat the water with fresh inhibitor',
      'After the fix, do a controlled fire-up and watch one full cycle to setpoint without further overheat',
    ],
    safetyNote:
        'An overheat lockout has done its job — it has prevented a dry-fire or scalding incident. Never bypass it; find and clear the underlying cause.',
  ),
  TroubleCase(
    id: 'eb_short_cycling',
    symptom: 'Electric boiler short-cycles, firing and stopping every minute',
    system: 'Electric boiler',
    likelyCauses: [
      'Boiler is significantly oversized relative to heat loss',
      'Pump speed too low for the system, causing rapid local temperature rise',
      'Cylinder or thermal store anti-cycle timer is wrongly set',
      'Sticking flow temperature sensor reading too hot too quickly',
    ],
    diagnosticSteps: [
      'Confirm the boiler kW rating against the original heat loss calc, an oversized boiler will always cycle',
      'Check the pump speed setting and the system bypass setting',
      'Read the boiler manual for any anti-cycle parameter and check it is at the default',
      'Compare the flow sensor reading on the display with an independent contact thermometer on the flow pipe',
    ],
    fixSteps: [
      'Increase pump speed where the manufacturer allows it',
      'Enable or extend the anti-cycle delay parameter, typically five to ten minutes between firings',
      'Replace the flow sensor if it is reading false-high; recalibrate after replacement',
      'If the boiler is genuinely oversized, advise the customer; staging or modulation modes may help, replacement may be the honest answer',
    ],
    safetyNote:
        'Short cycling shortens contactor life dramatically. Cycle counters in the PCB log of some manufacturers void the warranty above a threshold; document the cause.',
  ),
  TroubleCase(
    id: 'eb_rcbo_trips',
    symptom: 'The dedicated RCBO trips every time the boiler fires',
    system: 'Electric boiler',
    likelyCauses: [
      'Leakage to earth from a degraded element seal allowing water onto the live terminal',
      'Damaged supply cable or chafed insulation inside the boiler enclosure',
      'A faulty contactor with arcing contacts',
      'Cumulative earth leakage from multiple appliances exceeding the thirty milliamp threshold',
    ],
    diagnosticSteps: [
      'Isolate and prove dead, then test insulation resistance from each element terminal to earth at five hundred volts',
      'A reading below one megohm on an element is condemning evidence of breakdown',
      'Inspect the cable entry and terminal block for water ingress or rodent damage',
      'Energise carefully and listen for contactor chatter, which indicates worn contacts',
    ],
    fixSteps: [
      'Replace the failed element and gasket, retest insulation resistance before energising',
      'Replace damaged supply cable to the next safe termination point',
      'Replace the contactor as a sealed unit; never repair contact tips',
      'If cumulative leakage is the cause, recommend the customer\'s electrician redistribute appliances over multiple RCDs',
    ],
    safetyNote:
        'A tripping RCD is protecting a person from a shock — never disable it, never replace with a higher rated device. Find the leakage and clear it.',
  ),
  TroubleCase(
    id: 'eb_one_stage_dead',
    symptom: 'Multi-element boiler runs but never reaches setpoint quickly',
    system: 'Electric boiler',
    likelyCauses: [
      'One element or one stage relay has failed open',
      'The PCB has flagged a stage as faulty and disabled it after multiple trips',
      'A loose terminal on one of the element wires',
    ],
    diagnosticSteps: [
      'Isolate and prove dead',
      'Measure resistance across each element with a multimeter — expect a similar value for each',
      'An open circuit reading on one element confirms its failure',
      'Inspect each element terminal for discoloration, looseness, or burnt insulation',
      'Check the PCB log if the manufacturer exposes one, for stored stage faults',
    ],
    fixSteps: [
      'Replace the failed element with the OEM equivalent and a fresh gasket',
      'If the stage relay on the PCB is the failure, fit the manufacturer replacement PCB or relay',
      'Retest insulation and resistance before powering up',
    ],
    safetyNote:
        'Confirm dead and use a calibrated insulation tester at the manufacturer\'s recommended voltage. Customers may have been running for weeks on reduced output, blissfully unaware of the failure.',
  ),
  TroubleCase(
    id: 'eb_prv_dripping',
    symptom: 'Pressure relief valve is dripping water through the tundish',
    system: 'Electric boiler',
    likelyCauses: [
      'Failed or under-pressurised expansion vessel',
      'System over-pressurised beyond three bar by the filling loop being left open',
      'Failed PRV seat from particulate or limescale',
    ],
    diagnosticSteps: [
      'Check the system gauge while the boiler is firing, pressure rising above three bar confirms expansion fault',
      'With the system cold and isolated, depressurise and check the expansion vessel air charge at the Schrader valve, target one bar',
      'Inspect the PRV outlet for a coating of limescale indicating long-term seepage',
    ],
    fixSteps: [
      'Re-pressurise or replace the expansion vessel as appropriate',
      'Replace the PRV if its seat is compromised, do not attempt to clean and reuse',
      'After any work, reset cold pressure to one bar and confirm safe behaviour through a full firing cycle',
    ],
    safetyNote:
        'PRV discharge must terminate visibly through a tundish to a safe drainage point. Never blank or extend it in a way that hides the discharge.',
  ),
  TroubleCase(
    id: 'eb_anti_cycle_lockout',
    symptom: 'Boiler displays anti-cycle wait and refuses to refire',
    system: 'Electric boiler',
    likelyCauses: [
      'The boiler has fired and stopped repeatedly inside the protection window',
      'A repeating thermostat call from a TPI controller is triggering the protection',
      'Genuine fault that caused multiple short fire-and-stop cycles',
    ],
    diagnosticSteps: [
      'Read the display log to see the recent firing pattern and any error codes',
      'Watch one full call from thermostat through to satisfaction — confirm the boiler is not being asked to start every minute',
      'Check the TPI or weather-comp settings on the room thermostat for unusually aggressive cycling',
    ],
    fixSteps: [
      'Power-cycle the boiler to clear the anti-cycle counter as a one-off',
      'Adjust the controller cycle rate to a longer interval, six to ten cycles per hour is normal',
      'If a genuine underlying fault is found, fix it before re-energising; anti-cycle is symptom not cause',
    ],
    safetyNote:
        'Do not patch around an anti-cycle lockout — it is the boiler telling you something is wrong upstream.',
  ),
  TroubleCase(
    id: 'eb_smell_burning',
    symptom: 'Customer reports a burning smell from the boiler enclosure',
    system: 'Electric boiler',
    likelyCauses: [
      'Loose terminal causing arcing at the boiler terminal block or contactor',
      'Overheated cable insulation behind the boiler from undersized supply cable',
      'Failed contactor with welded or arcing contacts',
      'Failed PCB component with localised burning',
    ],
    diagnosticSteps: [
      'Isolate and prove dead immediately — this is a fire risk symptom',
      'Open the boiler and inspect every termination for discoloration, browning, or melted insulation',
      'Inspect the supply cable from the consumer unit for hot spots or heat damage',
      'Measure cable size against the boiler rating, undersized cable explains slow heating and burning',
    ],
    fixSteps: [
      'Replace any heat-damaged termination block, cable section, or component identified',
      'If the cable is undersized, the dedicated circuit must be upgraded by a Part P electrician before re-energising',
      'After repair, megger the new circuit and load-test it for thirty minutes monitoring temperature at terminals',
    ],
    safetyNote:
        'Do not advise the customer to re-energise even briefly. A burning smell is a notifiable safety concern. If in doubt, lock off and call the Distribution Network Operator.',
  ),
  TroubleCase(
    id: 'eb_flow_low_lockout',
    symptom: 'Boiler locks out citing low flow or flow-proof failure',
    system: 'Electric boiler',
    likelyCauses: [
      'Pump failed, seized or air-locked',
      'Magnetic filter or boiler dirt trap clogged',
      'TRVs all closed when the boiler is calling, leaving no flow path',
      'Flow switch itself stuck open',
    ],
    diagnosticSteps: [
      'Confirm pump runs when boiler calls — listen, feel for vibration, check the wiring',
      'Open the magnetic filter and check for sludge cake on the magnet',
      'Confirm at least one radiator is open or a bypass exists, so the pump always has a flow path',
      'If pump and filter are clean, suspect the flow switch and check continuity at the switch terminals while running',
    ],
    fixSteps: [
      'Free or replace the pump as needed',
      'Clean the filter, top up inhibitor',
      'Open a bypass radiator and set its lockshield, or fit an automatic bypass valve',
      'Replace the flow switch with the OEM part if it has failed',
    ],
    safetyNote:
        'The flow switch protects the element from dry-firing. If the boiler is bypassed at the flow switch the element will fail in seconds and may scald the engineer when drained.',
  ),
  TroubleCase(
    id: 'eb_costly_running',
    symptom: 'Customer complains running costs are much higher than expected',
    system: 'Electric boiler',
    likelyCauses: [
      'Tariff is on a flat single-rate without time-of-use pricing',
      'Storage cylinder is oversized for actual hot water demand',
      'Thermostat setpoint is unnecessarily high',
      'Property has poor insulation pushing heat load above the design figure',
    ],
    diagnosticSteps: [
      'Confirm the customer\'s electricity tariff and whether Economy seven or off-peak is available',
      'Read the cylinder thermostat setpoint, sixty degrees is the practical ceiling for Legionella plus efficiency',
      'Confirm the room thermostat setpoint and habits — every degree raised costs about eight percent more energy',
      'Review the property fabric — loft, walls, glazing — for obvious quick wins',
    ],
    fixSteps: [
      'Recommend a time-of-use tariff and adjust the schedule to charge stored hot water on cheap rate where possible',
      'Reduce cylinder setpoint to sixty degrees',
      'Educate the customer on thermostat settings and on closing unused rooms',
      'Refer the customer to a retrofit assessor under PAS 2035 for insulation upgrades',
    ],
    safetyNote:
        'Running costs are a customer-relations issue, not a safety issue, but record advice given in writing to protect against later complaints.',
  ),
];

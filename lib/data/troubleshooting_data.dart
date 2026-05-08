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
];

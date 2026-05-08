// Pre-job checklists data for plumbing and heating training app.
// Contains realistic UK field-practice checklists across boiler, hot water,
// heating, bathroom, drainage and survey categories.

class ChecklistItem {
  final String label;
  final String? hint; // optional one-line teaching note
  const ChecklistItem(this.label, {this.hint});
  String get speakable => hint == null ? label : '$label. $hint';
}

class ChecklistSection {
  final String heading;
  final List<ChecklistItem> items;
  const ChecklistSection(this.heading, this.items);
}

class JobChecklist {
  final String id;
  final String title;
  final String category; // 'Boiler', 'Hot water', 'Heating', 'Bathroom', 'Drainage', 'Survey'
  final String summary;
  final List<ChecklistSection> sections;
  const JobChecklist({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.sections,
  });
  int get totalItems => sections.fold(0, (a, s) => a + s.items.length);
}

const jobChecklists = <JobChecklist>[
  // 1. Combi boiler swap
  JobChecklist(
    id: 'combi_swap',
    title: 'Combi boiler swap',
    category: 'Boiler',
    summary:
        'Like-for-like combi replacement covering survey, removal, install and benchmark sign-off.',
    sections: [
      ChecklistSection('Survey and arrival', [
        ChecklistItem('Confirm Gas Safe ID and customer expectations',
            hint: 'Show ID card and run through scope of works'),
        ChecklistItem('Check appliance location and clearances',
            hint: 'Front, sides and below as per manufacturer'),
        ChecklistItem('Inspect existing flue route and termination',
            hint: 'Check 300 mm from openings and boundary distances'),
        ChecklistItem('Verify gas meter and supply pipework size',
            hint: 'U6 meter and 22 mm gas where required'),
        ChecklistItem('Test incoming mains pressure and flow rate',
            hint: 'Aim for 1.5 bar dynamic and 12 L/min minimum'),
        ChecklistItem('Lay dust sheets and protect flooring'),
      ]),
      ChecklistSection('Isolation and drain down', [
        ChecklistItem('Isolate gas at meter ECV and lock off'),
        ChecklistItem('Isolate electrical supply at fused spur'),
        ChecklistItem('Close mains stopcock and drain CH circuit',
            hint: 'Use lowest drain-off, vent radiators top down'),
        ChecklistItem('Drain DHW side via lowest tap'),
        ChecklistItem('Cap open ends to prevent debris ingress'),
      ]),
      ChecklistSection('Removal of old appliance', [
        ChecklistItem('Disconnect flue and seal builders opening'),
        ChecklistItem('Disconnect gas, flow, return, cold mains and DHW'),
        ChecklistItem('Remove old boiler from wall safely',
            hint: 'Two-person lift, weight can exceed 30 kg'),
        ChecklistItem('Inspect wall fixings and make good as needed'),
      ]),
      ChecklistSection('Installation', [
        ChecklistItem('Fit new wall plate level and to torque'),
        ChecklistItem('Install system filter on return',
            hint: 'Magnetic filter mandatory under Boiler Plus'),
        ChecklistItem('Connect flue with locking bands and gaskets'),
        ChecklistItem('Run condensate to internal soil where possible',
            hint: '32 mm minimum, 3 degree fall, lagged externally'),
        ChecklistItem('Connect gas in 22 mm and pressure test'),
        ChecklistItem('Wire programmer, room stat and load compensation',
            hint: 'Boiler Plus needs one efficiency control'),
      ]),
      ChecklistSection('Commissioning and hand-over', [
        ChecklistItem('Flush system to BS 7593 and dose inhibitor',
            hint: 'X800 cleanse then X100 dose at 1% volume'),
        ChecklistItem('Pressurise system to 1.0-1.5 bar cold',
            hint: 'Match expansion vessel pre-charge'),
        ChecklistItem('Carry out tightness test and let-by check'),
        ChecklistItem('Run combustion analyser at high and low rate',
            hint: 'CO2 8.7-9.2 % and CO/CO2 ratio under 0.004'),
        ChecklistItem('Set CH flow to 65-75 C and DHW to 55-60 C'),
        ChecklistItem('Complete Benchmark logbook and Gas Safe notify',
            hint: 'Notify within 30 days via Gas Safe portal'),
        ChecklistItem('Demonstrate controls and leave manuals'),
      ]),
    ],
  ),

  // 2. Unvented cylinder install
  JobChecklist(
    id: 'unvented_cylinder',
    title: 'Unvented cylinder install',
    category: 'Hot water',
    summary:
        'G3 notifiable unvented hot water storage install with full discharge route.',
    sections: [
      ChecklistSection('Pre-install checks', [
        ChecklistItem('Confirm G3 ticket in date and competent persons scheme'),
        ChecklistItem('Check mains pressure and flow at peak times',
            hint: 'Minimum 1.5 bar dynamic, 20 L/min for multi-bath'),
        ChecklistItem('Verify discharge route to safe visible position'),
        ChecklistItem('Locate cylinder on solid base with access for service'),
        ChecklistItem('Check incoming main is 22 mm minimum'),
      ]),
      ChecklistSection('Isolation and removal', [
        ChecklistItem('Isolate electrics at consumer unit and lock off'),
        ChecklistItem('Drain existing cylinder and pipework'),
        ChecklistItem('Remove old vessel and dispose responsibly'),
        ChecklistItem('Strip back redundant F&E tank if converting'),
      ]),
      ChecklistSection('Inlet group setup', [
        ChecklistItem('Fit isolating valve, strainer and PRV at 3 bar',
            hint: 'PRV setting matches manufacturer, typically 3.0 bar'),
        ChecklistItem('Install single check valve after PRV'),
        ChecklistItem('Fit expansion vessel charged to 3 bar',
            hint: 'Pre-charge equal to PRV setting'),
        ChecklistItem('Install balanced cold tee for blended outlets'),
      ]),
      ChecklistSection('Discharge route D1 and D2', [
        ChecklistItem('D1 metallic from T&P valve to tundish',
            hint: 'Same size as outlet, vertical, under 600 mm'),
        ChecklistItem('Tundish visible within 500 mm of valve'),
        ChecklistItem('D2 one size larger than D1, continuous fall',
            hint: 'Min 300 mm vertical drop before any bend'),
        ChecklistItem('Resistance: each elbow equals 0.8 m of D2 length'),
        ChecklistItem('Terminate to safe visible low-level position',
            hint: 'Avoid pedestrian areas and freezing risk'),
      ]),
      ChecklistSection('Commissioning and notification', [
        ChecklistItem('Fill cylinder via mains and vent through highest tap'),
        ChecklistItem('Energise immersion or coil and check stat operation',
            hint: 'Stored at 60 C minimum to prevent legionella'),
        ChecklistItem('Test T&P valve and PRV by manual lift'),
        ChecklistItem('Check expansion through cycle, no weeping at PRV'),
        ChecklistItem('Complete benchmark and submit Building Control notice',
            hint: 'G3 notification via competent persons scheme'),
        ChecklistItem('Hand over manuals and explain annual service'),
      ]),
    ],
  ),

  // 3. Annual boiler service
  JobChecklist(
    id: 'annual_service',
    title: 'Annual boiler service',
    category: 'Boiler',
    summary:
        'Manufacturer-spec service for a gas combi or system boiler with FGA report.',
    sections: [
      ChecklistSection('Pre-flow checks', [
        ChecklistItem('Visual check of appliance and surroundings',
            hint: 'Look for staining, soot, water marks'),
        ChecklistItem('Check ventilation and clearances unchanged'),
        ChecklistItem('Confirm flue route and terminal condition'),
        ChecklistItem('Read system pressure and top up if needed',
            hint: 'Cold fill 1.0-1.5 bar'),
      ]),
      ChecklistSection('Casing off and inspection', [
        ChecklistItem('Isolate gas and electric, lock off'),
        ChecklistItem('Remove casing per torque pattern'),
        ChecklistItem('Photograph internals before disturbing'),
        ChecklistItem('Inspect heat exchanger for sooting and scale'),
        ChecklistItem('Check fan, electrodes and condensate trap'),
      ]),
      ChecklistSection('Combustion analyser test', [
        ChecklistItem('Warm boiler for 10 minutes before sampling'),
        ChecklistItem('Sample at high rate and record values',
            hint: 'CO2 typically 8.7-9.2 %, CO under 350 ppm'),
        ChecklistItem('Sample at low rate where applicable'),
        ChecklistItem('Calculate CO/CO2 ratio',
            hint: 'Must be below 0.004 for safe operation'),
        ChecklistItem('Check standing and working gas pressure',
            hint: 'Refer to data badge, often 20 mbar working'),
      ]),
      ChecklistSection('Component checks', [
        ChecklistItem('Clean condensate trap and refill with water'),
        ChecklistItem('Clean burner and electrodes if required'),
        ChecklistItem('Check expansion vessel charge with no water side',
            hint: 'Should match cold fill, usually 1 bar'),
        ChecklistItem('Test PRV by manual lift and reseat'),
        ChecklistItem('Check inhibitor concentration with test strip',
            hint: 'X100 inhibitor reading should be in range'),
      ]),
      ChecklistSection('Post checks and paperwork', [
        ChecklistItem('Refit casing with all screws and gaskets'),
        ChecklistItem('Re-test gas tightness'),
        ChecklistItem('Confirm room and cylinder stat operation'),
        ChecklistItem('Issue service record and FGA print-out'),
        ChecklistItem('Advise customer of any defects in writing',
            hint: 'Use AR/ID/NCS classifications where applicable'),
      ]),
    ],
  ),

  // 4. Sealed system commissioning
  JobChecklist(
    id: 'sealed_commission',
    title: 'Sealed system commissioning',
    category: 'Heating',
    summary:
        'Commissioning a sealed central heating system to BS 7593 with balancing.',
    sections: [
      ChecklistSection('Pre-fill checks', [
        ChecklistItem('Confirm system clean and pressure-tight',
            hint: 'Visual inspection of joints and unions'),
        ChecklistItem('Check filling loop fitted and removable',
            hint: 'Type CA double check valve required'),
        ChecklistItem('Verify expansion vessel sized correctly',
            hint: 'Approx 10 % of system volume'),
        ChecklistItem('Open all radiator valves fully'),
      ]),
      ChecklistSection('Fill, vent and test', [
        ChecklistItem('Fill slowly to 1.0-1.5 bar cold'),
        ChecklistItem('Vent radiators top floor down'),
        ChecklistItem('Pressure test to 1.5 x working pressure',
            hint: 'Hold for minimum 30 minutes, no drop'),
        ChecklistItem('Inspect every joint under test'),
      ]),
      ChecklistSection('Expansion vessel and PRV', [
        ChecklistItem('Drain water side of vessel to zero gauge'),
        ChecklistItem('Set vessel pre-charge to 1 bar',
            hint: 'Use a quality gauge, equal to cold fill'),
        ChecklistItem('Refit and refill, check for stable pressure'),
        ChecklistItem('Verify PRV discharges at 3 bar to safe location'),
      ]),
      ChecklistSection('Balancing and dosing', [
        ChecklistItem('Set lockshields for design ΔT',
            hint: 'Aim 11 K ΔT for condensing efficiency, up to 20 K'),
        ChecklistItem('Index circuit lockshield fully open'),
        ChecklistItem('Adjust pump to design flow rate'),
        ChecklistItem('Dose inhibitor to 1 % system volume',
            hint: 'X100 or equivalent BuildCert listed'),
      ]),
      ChecklistSection('Hand-over', [
        ChecklistItem('Set time and temperature controls'),
        ChecklistItem('Demonstrate filling loop and pressure top-up'),
        ChecklistItem('Record final commissioning data',
            hint: 'Pressures, ΔT, inhibitor, balancing notes'),
        ChecklistItem('Complete Benchmark commissioning section'),
      ]),
    ],
  ),

  // 5. Bathroom rough first fix
  JobChecklist(
    id: 'bathroom_first_fix',
    title: 'Bathroom refit (rough first fix)',
    category: 'Bathroom',
    summary:
        'Carcass plumbing for a full bathroom refit prior to plaster and tiling.',
    sections: [
      ChecklistSection('Survey and set out', [
        ChecklistItem('Confirm sanitaryware schedule and dimensions'),
        ChecklistItem('Mark centre lines for WC, basin, bath, shower'),
        ChecklistItem('Check joist and stud direction for fixings'),
        ChecklistItem('Identify soil stack and existing drainage falls'),
        ChecklistItem('Plan pipe routes to avoid joist mid-spans',
            hint: 'Holes within 0.25-0.4 of span centreline'),
      ]),
      ChecklistSection('Isolation and waste runs', [
        ChecklistItem('Isolate hot and cold mains, drain down'),
        ChecklistItem('Run 110 mm soil for WC at 1:40 to 1:110 fall',
            hint: '18-90 mm per metre on horizontal sections'),
        ChecklistItem('40 mm waste for bath and shower',
            hint: 'Max 3 m run with one bend, trap 50 mm seal'),
        ChecklistItem('32 mm waste for basin, 1 in 18 fall'),
        ChecklistItem('Fit AAV or vent stack as appropriate'),
      ]),
      ChecklistSection('Hot and cold runs', [
        ChecklistItem('Run 15 mm hot and cold to each outlet'),
        ChecklistItem('22 mm to bath taps and bath fill points'),
        ChecklistItem('Provide isolation valve at every outlet',
            hint: 'Servicing valves accessible behind panels'),
        ChecklistItem('Sleeve all pipes through walls and floors'),
      ]),
      ChecklistSection('Fixings and pressure test', [
        ChecklistItem('Clip pipework to manufacturer centres',
            hint: '15 mm copper at 1.2 m horizontal, 1.8 m vertical'),
        ChecklistItem('Lag hot pipes per Part L'),
        ChecklistItem('Pressure test to 1.5 x working pressure',
            hint: '6 bar test typical for new copper, hold 1 hour'),
        ChecklistItem('Photograph runs before plasterboard'),
      ]),
      ChecklistSection('Sign-off before close-up', [
        ChecklistItem('Walk through with builder or customer'),
        ChecklistItem('Mark stop ends and label hot/cold'),
        ChecklistItem('Confirm tile thickness allowance for fittings',
            hint: 'Typical 15 mm allowance for tile and adhesive'),
      ]),
    ],
  ),

  // 6. Bathroom second fix
  JobChecklist(
    id: 'bathroom_second_fix',
    title: 'Bathroom refit (second fix)',
    category: 'Bathroom',
    summary:
        'Final fix of sanitaryware after tiling, including commissioning and snags.',
    sections: [
      ChecklistSection('Sanitaryware install', [
        ChecklistItem('Set WC pan on level base, fit pan connector',
            hint: 'Use flexible only where alignment is fixed'),
        ChecklistItem('Mount basin and pedestal, level and plumb'),
        ChecklistItem('Install bath with adjustable feet, support cradle'),
        ChecklistItem('Fit shower tray on full mortar bed',
            hint: 'No voids under tray to prevent cracking'),
        ChecklistItem('Fit thermostatic shower valve at correct height'),
      ]),
      ChecklistSection('Sealing and finishing', [
        ChecklistItem('Apply sanitary silicone to baths and trays',
            hint: 'Mould-resistant, 5 mm minimum bead'),
        ChecklistItem('Seal around basin and WC to wall'),
        ChecklistItem('Check tile grout cured before sealing'),
        ChecklistItem('Tool joints with smoothing tool, not finger'),
      ]),
      ChecklistSection('Commissioning', [
        ChecklistItem('Open isolators and check for leaks'),
        ChecklistItem('Set TMV blend temperature to 41 C max for shower',
            hint: '38 C bath fill, 41 C shower per TMV2'),
        ChecklistItem('Test WC flush and refill timing'),
        ChecklistItem('Run all wastes, check trap seals retain'),
      ]),
      ChecklistSection('Snag list and hand-over', [
        ChecklistItem('Walk customer through controls'),
        ChecklistItem('Note any tiling, decoration or supply defects'),
        ChecklistItem('Photograph completed installation'),
        ChecklistItem('Leave manuals and care instructions'),
      ]),
    ],
  ),

  // 7. Gas tightness test
  JobChecklist(
    id: 'gas_tightness',
    title: 'Gas tightness test',
    category: 'Survey',
    summary:
        'Domestic let-by and tightness test on natural gas to IGEM/UP/1B.',
    sections: [
      ChecklistSection('Pre-test preparation', [
        ChecklistItem('Confirm Gas Safe registration covers work'),
        ChecklistItem('Identify all appliances and turn off pilots'),
        ChecklistItem('Check meter type and installation pipework size'),
        ChecklistItem('Connect calibrated manometer at test point',
            hint: 'Fit downstream of ECV via test nipple'),
      ]),
      ChecklistSection('Let-by and stabilisation', [
        ChecklistItem('Raise to operating pressure approx 21 mbar'),
        ChecklistItem('Carry out let-by test for 1 minute',
            hint: 'No rise = ECV holding tight'),
        ChecklistItem('Stabilise pipework for at least 1 minute',
            hint: 'Allow temperature equalisation'),
      ]),
      ChecklistSection('Tightness test method', [
        ChecklistItem('Test for 2 minutes once stable'),
        ChecklistItem('Record start and end pressures'),
        ChecklistItem('Check meter type for allowable drop',
            hint: 'U6 with no appliances: 0 mbar drop allowed new, up to 4 mbar existing'),
        ChecklistItem('Apply correction for appliance volume if applicable'),
      ]),
      ChecklistSection('Escape investigation', [
        ChecklistItem('Use leak detection fluid on every joint'),
        ChecklistItem('Use electronic gas detector for concealed runs'),
        ChecklistItem('Trace and rectify any escape before reuse',
            hint: 'Classify as ID or AR per GIUSP'),
        ChecklistItem('Re-test after repair to confirm tight'),
      ]),
      ChecklistSection('Paperwork', [
        ChecklistItem('Record pressures and durations on test sheet'),
        ChecklistItem('Issue gas safety record if applicable'),
        ChecklistItem('Advise customer of any defects in writing'),
        ChecklistItem('Notify under RIDDOR or GIUSP if dangerous'),
      ]),
    ],
  ),

  // 8. Power flush
  JobChecklist(
    id: 'power_flush',
    title: 'Power flush',
    category: 'Heating',
    summary:
        'Chemical power flush to BS 7593 to remove magnetite and restore output.',
    sections: [
      ChecklistSection('Survey suitability', [
        ChecklistItem('Inspect radiators for cold spots and pinholing',
            hint: 'Use thermal imaging if available'),
        ChecklistItem('Check system age and material mix',
            hint: 'Steel rads, copper pipe, brass fittings, dezincification risk'),
        ChecklistItem('Sample existing water for iron and bacteria'),
        ChecklistItem('Warn customer of leak risk on tired systems'),
      ]),
      ChecklistSection('Isolation and prep', [
        ChecklistItem('Isolate boiler electrics and gas'),
        ChecklistItem('Bypass boiler if heat exchanger fragile'),
        ChecklistItem('Protect floors and route hoses to drain'),
        ChecklistItem('Remove TRV heads and open lockshields fully'),
      ]),
      ChecklistSection('Machine connect', [
        ChecklistItem('Connect flush unit to circulation pump or rad tails'),
        ChecklistItem('Couple tank, hoses and dump line'),
        ChecklistItem('Fit magnetic filter to flush rig if available'),
        ChecklistItem('Pressure check connections before flow'),
      ]),
      ChecklistSection('Flushing sequence', [
        ChecklistItem('Dose cleanser X400 or equivalent'),
        ChecklistItem('Circulate hot for 1-2 hours per BS 7593'),
        ChecklistItem('Flush each radiator individually with reverse flow'),
        ChecklistItem('Continue until water runs clear at TDS check'),
        ChecklistItem('Apply descaler if hard water area',
            hint: 'Sentinel X300 for limescale-affected systems'),
      ]),
      ChecklistSection('Refill, dose and rebalance', [
        ChecklistItem('Drain and refill with clean water'),
        ChecklistItem('Dose inhibitor to 1 % system volume',
            hint: 'X100 BuildCert approved'),
        ChecklistItem('Pressurise to 1.0-1.5 bar cold'),
        ChecklistItem('Rebalance lockshields for design ΔT',
            hint: '11 K ΔT for condensing operation'),
        ChecklistItem('Refit TRV heads and set room targets'),
      ]),
      ChecklistSection('Paperwork', [
        ChecklistItem('Take TDS and inhibitor readings post-flush'),
        ChecklistItem('Issue power flush certificate'),
        ChecklistItem('Recommend annual inhibitor check',
            hint: 'BS 7593 requires annual water quality verification'),
        ChecklistItem('Advise on magnetic filter service interval'),
      ]),
    ],
  ),
];

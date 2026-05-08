import 'lessons_data.dart';

const commercialGasLessonTopics = <LessonTopic>[
  LessonTopic(
    id: 'comm_gas_pipework',
    title: 'Commercial gas pipework',
    category: 'Commercial gas',
    summary:
        'Designing, sizing and installing commercial natural gas pipework to IGEM/UP/2, including material selection, pressure tiers and identification.',
    sections: <LessonSection>[
      LessonSection(
        'Design to IGEM/UP/2',
        'Commercial gas pipework above 35 mm diameter or operating beyond domestic conditions falls under IGEM/UP/2 Edition 3. The standard covers the design, installation and testing of steel, copper and stainless press-fit systems on premises with a meter capacity above 16 m3/h or pressures above 75 mbar. The designer assesses the load profile, diversity, route, accessibility and likely future extension. A schematic with node numbering, design pressure and flow rate is produced before any pipe is cut. Risk assessments cover pipe in voids, escape routes and protected shafts. Sleeving and fire-stopping at compartment penetrations must be specified. Pipework in unventilated voids longer than two metres requires gas detection or alternative protection in line with the standard.',
      ),
      LessonSection(
        'Material selection and pressure tiers',
        'Three pressure tiers are recognised in commercial work. Low pressure (LP) is up to and including 75 mbar, the typical tier downstream of the meter governor at 21 mbar working pressure. Medium pressure (MP) covers above 75 mbar to 2 bar, while intermediate pressure (IP) runs from 2 bar to 7 bar. Mild steel to BS 1387 or BS EN 10255 with screwed or welded joints remains the workhorse material above 50 mm. Copper to BS EN 1057 with brazed joints suits smaller diameters and clean plant rooms. Stainless steel press-fit such as approved Geberit Mapress or Viega Profipress G is permitted where the manufacturer holds a current Kitemark or equivalent certification covering gas service, with O-rings rated for natural gas.',
      ),
      LessonSection(
        'Sizing, supports and expansion',
        'Pipework is sized so that the total pressure drop from meter outlet to the most remote appliance does not exceed 1 mbar at 21 mbar working pressure, with appliance inlet pressure held at 19 mbar minimum under full load. Sizing tables in IGE/UP/2 Annex use equivalent length, allowing for fittings. Supports must follow the spacing in BS 6891 and the IGEM standard, typically 2.0 to 3.0 metres for 50 mm steel horizontal runs, closer for vertical drops. Expansion is significant on long horizontal runs in plant rooms; offsets, loops or guided sliding supports accommodate movement. Anchors are used either side of expansion devices so that thermal growth is directed and not transferred into appliance unions.',
      ),
      LessonSection(
        'Identification and protection',
        'All exposed gas pipework must be identified to BS 1710 with the basic colour ochre yellow and a safety colour band of yellow with the word GAS, supplemented by flow arrows at branches, valves and either side of partitions. Buried pipework outside the building is sleeved or protected with factory-applied PE coating and warning tape 150 mm above. Inside the building, pipework is kept clear of electrical cables by at least 25 mm and never run in unventilated voids without gas detection. Earth continuity bonding to BS 7671 main protective bonding is fitted within 600 mm of the meter outlet using a 10 mm2 conductor minimum, clamped to clean metal with a label reading Safety Electrical Connection Do Not Remove.',
      ),
    ],
  ),
  LessonTopic(
    id: 'tightness_purging',
    title: 'Tightness testing and purging',
    category: 'Commercial gas',
    summary:
        'Carrying out tightness tests and purges on commercial installations to IGEM/UP/1 and UP/1A, including criteria, instruments and certification.',
    sections: <LessonSection>[
      LessonSection(
        'UP/1 versus UP/1A',
        'IGEM/UP/1 Edition 2 covers tightness testing of installations with installation volumes above 0.035 m3 or operating pressures above 21 mbar; the simpler IGEM/UP/1A applies to small low-pressure installations up to and including DN 50 with an installation volume not exceeding 1 m3 at 21 mbar. The choice of procedure depends on pipe diameter, total volume and operating pressure. UP/1A uses a strength test at 50 mbar and a tightness test at operating pressure, while UP/1 prescribes a strength test at 1.5 times the maximum incidental pressure followed by a tightness test with calculated allowable pressure drop based on volume, temperature compensation and time.',
      ),
      LessonSection(
        'Test medium and stabilisation',
        'Air or an inert gas such as nitrogen is used for the strength test on new installations and any work disturbing pipework above 21 mbar; natural gas may be used for the tightness test on existing systems. The installation must be allowed to stabilise so that pipe-wall temperature equalises with the contained medium. Stabilisation periods scale with pipe volume, typically 5 minutes for small bore but extending to 30 minutes or more on large LP plant-room mains. Electronic gauges with current calibration certificates and a resolution of 0.1 mbar or better are required for LP work. Ambient temperature should be recorded at start and finish, with corrections applied where the variation exceeds 1 degree Celsius.',
      ),
      LessonSection(
        'Allowable drop and decision',
        'For LP at 21 mbar the maximum permitted pressure drop during the tightness test is calculated from the installation volume and the test duration, with reference to the leak rate criteria in UP/1. As a working figure, a let-by test must show no movement, and the tightness test must show a drop within the calculated allowance. Any rise indicates governor let-by and invalidates the test. If the result fails, the installation must be leak-located using approved leak detection fluid or an electronic gas detector, repaired and retested. Tests are not negotiable: a fail means the system stays off and must not be commissioned until a pass is recorded and signed for.',
      ),
      LessonSection(
        'Purging and certification',
        'Purging on volumes above 0.02 m3 follows IGEM/UP/1 Section 9 using either direct displacement with the supply gas or, on larger plant, fan-assisted purging through a temporary stack discharging safely outside. Ventilation must be confirmed open, sources of ignition removed and gas detection used at the discharge point until two consecutive readings show 90 percent or more gas, confirming complete displacement of air. The installer completes a tightness test record showing test pressures, durations, allowable and actual drop, ambient temperature, instrument serial number and calibration date, and the purge volume. The certificate is signed by an ACS-qualified operative holding the relevant categories such as COCNGI1 and TPCP1 and retained by the duty holder.',
      ),
    ],
  ),
  LessonTopic(
    id: 'commercial_boiler_rooms',
    title: 'Commercial boiler rooms',
    category: 'Commercial gas',
    summary:
        'Designing and inspecting plant rooms for commercial gas-fired boilers under BS 6644, covering ventilation, gas detection and shutdown.',
    sections: <LessonSection>[
      LessonSection(
        'Plant-room volume and ventilation',
        'BS 6644:2011 plus A1:2016 applies to gas-fired boilers with individual net heat inputs above 70 kW up to 1.8 MW per unit and total inputs up to 8 MW. The plant room must be of sufficient volume and have permanent high and low-level ventilation sized on the total net input. For natural ventilation the low-level free area is calculated at 4 cm2 per kW of total net input, with high-level at half that figure, subject to a minimum of 0.1 m2. Mechanical ventilation provides a minimum of 0.5 m3/s per MW of input, interlocked with the gas supply so that loss of airflow shuts off the gas via a slam-shut valve at the meter or boiler-house entry.',
      ),
      LessonSection(
        'Gas detection and shutdown',
        'Two-level gas detection is fitted in plant rooms containing appliances above 70 kW. A low-level detector at floor level guards against any heavier hydrocarbon contamination, while a high-level detector positioned within 300 mm of the ceiling and away from ventilation streams responds to natural gas. The detector controller initiates a first-stage alarm at 10 percent of the lower explosive limit and a second-stage gas-supply shutdown at 20 percent LEL, closing the boiler-house solenoid valve. The system is interlocked with the building management system to alert the responsible person and stop forced-draught fans. Manual reset is required after a shutdown, only following a recorded leak investigation and successful retightness test.',
      ),
      LessonSection(
        'Primary and secondary heating',
        'Most commercial plants use sealed primary circuits with low-loss headers, plate heat exchangers and variable-speed pumps to feed secondary distribution serving radiators, AHUs, calorifiers and underfloor manifolds. Boilers are typically modulating condensing units cascading on a 0-10 V or BACnet signal from the BMS. Flow temperatures are weather-compensated, often resetting between 50 degrees Celsius and 75 degrees Celsius. Pressurisation units maintain a cold-fill pressure usually around 1.5 bar with expansion vessels sized for system water content. Safety devices include pressure-relief valves discharging to a tundish visible from the working area, low-water cut-outs on each boiler and high-limit thermostats independent of the control thermostat.',
      ),
      LessonSection(
        'Signage, access and lock-off',
        'Plant rooms must display warning signage at each entrance reading Gas Plant Room No Naked Lights and Authorised Personnel Only, together with an emergency contact and a No Smoking sign. The main gas isolation valve is located outside the plant room or immediately inside a normally-locked door, painted yellow and clearly labelled. A fireman switch may be required for the gas supply where local authorities ask for it. All electrical isolators carry padlock hasps for safe isolation during maintenance, and a permit-to-work system controls hot work. Clear access of 600 mm minimum is maintained around boilers for service, with overhead clearance of 1.0 metre or as stated by the manufacturer.',
      ),
    ],
  ),
  LessonTopic(
    id: 'catering_bs6173',
    title: 'Catering installations BS 6173',
    category: 'Commercial gas',
    summary:
        'Installing and commissioning commercial catering gas appliances to BS 6173, including interlocks, ventilation and proving systems.',
    sections: <LessonSection>[
      LessonSection(
        'Ventilation interlocks',
        'BS 6173:2020 requires an interlock between the gas supply and the kitchen ventilation system in any commercial catering installation. The canopy extract and any mechanical supply must be running and proven by an air-pressure or current-sensing device before the gas-supply solenoid is permitted to open. Loss of extract during cooking closes the gas valve within seconds. Air-pressure switches are mounted in the duct close to the canopy and tested at commissioning by partially blocking the inlet to verify trip. The interlock panel is fitted in a position visible to the chef, with a key-switch for authorised reset and a clearly labelled emergency knock-off button at each main exit from the kitchen.',
      ),
      LessonSection(
        'Gas pressure proving',
        'Where ventilation alone cannot provide a sufficiently safe regime, or where the kitchen has multiple isolation points, a gas pressure proving system is fitted between the manual isolation valve and the appliances. The proving system pressurises the downstream pipework, monitors the pressure for a fixed test period, then opens only if no leak is detected. A green light indicates that the system is live and gas is available. After any closure or extract failure the cycle repeats. Models such as Merlin or BG2000 are common. The system also includes an emergency stop link, fire-suppression interface from the canopy hood and a remote mains-fail relay so that gas cannot be live without ventilation.',
      ),
      LessonSection(
        'Layout and ergonomics',
        'Catering appliances generate high radiant temperatures and steam, so layout follows ergonomic and safety principles. A hot-shoe of non-combustible material is provided beneath and behind solid-top ranges and woks. Combustible surfaces within 150 mm of an open flame must be lined with a non-combustible board or maintained at a safe distance set by the manufacturer. Working aisles between cook lines should be a minimum of 1.2 metres clear, with non-slip flooring. Flexible appliance connectors comply with BS 669 Part 2 with a restraining chain shorter than the hose to prevent strain on the bayonet, and quick-disconnect couplings with self-sealing valves are preferred where appliances are moved for cleaning.',
      ),
      LessonSection(
        'Fire suppression and emergency stops',
        'Wet-chemical fire-suppression systems such as Ansul R-102 are fitted inside the canopy over deep-fat fryers and high-risk appliances. Activation, whether automatic via fusible link or manual via pull station, must drop the gas supply through the proving system and shut down the extract fan to prevent fire spread, while leaving make-up air on briefly to clear smoke if the design requires. Emergency stop buttons are sited near each escape route and are mushroom-headed, latching, red on yellow and protected against accidental knock. They are tested at least annually and on every gas safety inspection. Records of interlock, proving, suppression and stop tests are kept in the kitchen log book for inspection.',
      ),
    ],
  ),
  LessonTopic(
    id: 'haz_areas_up16',
    title: 'Hazardous areas (IGEM/UP/16)',
    category: 'Commercial gas',
    summary:
        'Classifying hazardous areas around gas installations using IGEM/UP/16, including zone definitions and equipment selection.',
    sections: <LessonSection>[
      LessonSection(
        'Zone definitions',
        'IGEM/UP/16 provides a methodology for classifying hazardous areas around natural gas installations such as governors, meter installations, vents and pressure-relief valves. Three zones are defined under DSEAR and the ATEX framework. Zone 0 is an area in which an explosive gas atmosphere is present continuously or for long periods; this is rare in natural gas work outside the interior of certain vent stacks. Zone 1 is an area in which an explosive gas atmosphere is likely to occur in normal operation, such as the immediate volume around a vent termination. Zone 2 is an area in which the atmosphere is not likely to occur in normal operation and, if it does occur, will persist only for a short period.',
      ),
      LessonSection(
        'Separation distances',
        'Typical separation distances are tabulated in IGEM/UP/16 from the source of release. Around a regulator vent on a low-pressure governor, Zone 2 might extend a radius of one metre with a smaller spherical Zone 1 of 150 mm at the vent itself. Around a relief stack on an MP installation the zones can extend several metres horizontally and vertically, with greater distances upward. Sources of ignition such as switchgear, sockets, luminaires, mobile phones in non-Ex housings and unprotected motor starters must be kept outside the zones. Where impossible, equipment certified for the appropriate zone is installed and the plant is documented in a hazardous-area drawing kept with the operations and maintenance manual.',
      ),
      LessonSection(
        'Equipment Ex categories',
        'Equipment installed within hazardous areas must hold ATEX or UKEX certification with marking that includes the equipment group, category and gas group such as II 2G Ex db IIA T3. Group II covers above-ground installations, category 2 is suitable for Zone 1 and category 3 for Zone 2. Common protection concepts include Ex d flameproof enclosures for switchgear, Ex e increased safety for terminal boxes, Ex i intrinsic safety for instrumentation and Ex n non-sparking for Zone 2 motors. Cable glands must be of a matching certified type and correctly torqued to maintain the protection. All Ex equipment is added to a register and inspected at intervals set out in BS EN 60079-17.',
      ),
      LessonSection(
        'Classification process and specialists',
        'Classification is carried out at design stage and reviewed whenever modifications are made. A competent person identifies sources of release, calculates release rates, considers ventilation effectiveness and applies the look-up tables of IGEM/UP/16 or detailed calculations. The output is a hazardous-area classification report and drawing showing zone shapes, dimensions and equipment list. For complex sites such as CHP plants, large meter installations above MOP 2 bar, biogas plants or kitchens with hydrogen-blend trials, specialist consultants and the gas transporter are involved early. Installers should not improvise zone reductions on site; if proposed plant layout brings ignition sources inside a zone, design changes or different equipment must be specified before work proceeds.',
      ),
    ],
  ),
];

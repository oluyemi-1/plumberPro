import 'lessons_data.dart';

const lpgOilLessonTopics = <LessonTopic>[
  LessonTopic(
    id: 'lpg_systems',
    title: 'LPG installation systems',
    category: 'LPG / Oil',
    summary:
        'Bulk versus cylinder supply, regulator stages, ventilation and the separation distances required by BS 5482 and the UKLPG Code of Practice 1.',
    sections: [
      LessonSection(
        'Bulk tanks and cylinder banks',
        'Liquefied petroleum gas is delivered to a property either as a bulk tank, refilled by tanker, or as a manifold of exchangeable cylinders. Bulk tanks suit higher off-takes such as a domestic boiler running a full central heating and hot water load, while cylinder banks are common where annual demand is modest or where the site cannot accept a tanker. Most domestic UK installations use propane, which has a useful working range down to around minus forty Celsius. Butane is reserved for indoor portable use because it stops vapourising near zero. The installer must size the supply for the connected load and confirm tanker access before siting.',
      ),
      LessonSection(
        'Vapour and liquid offtake',
        'Domestic and small commercial installations use vapour offtake. Liquid sits at the bottom of the tank and naturally vapourises into the headspace, where the regulator draws it off as a gas. The tank itself does the work of evaporation, so a larger tank gives a higher continuous kilogram-per-hour vapourisation rate. Liquid offtake, where liquid LPG is piped from the tank and vapourised at the appliance, is only used for very large industrial loads with a dedicated forced vapouriser. Sizing the tank for peak winter draw is essential, otherwise the tank chills, frost forms on the shell and pressure collapses.',
      ),
      LessonSection(
        'Two-stage regulation and pipework',
        'Bulk LPG tanks store propane at saturation pressure, typically around seven bar in summer. A first-stage regulator at the tank reduces this to around seventy-five millibar for the underground service line. A second-stage regulator close to the building drops the pressure further to the standard appliance working pressure of thirty-seven millibar for propane. Underground service pipe is usually polyethylene with tracer wire and a marker tape, transitioning to copper or steel above ground at a riser. Joints above ground are compression or brazed; the installation must be electrically bonded to earth at the riser.',
      ),
      LessonSection(
        'Separation distances and standards',
        'Siting follows the UKLPG Code of Practice 1 and BS 5482. A typical 1200 or 2000 litre above-ground tank requires three metres clear to any building opening, drain, ignition source or untrapped gulley, and one and a half metres from the site boundary. Where space is tight, a fire wall built to thirty minutes integrity allows these distances to be measured around the wall rather than in a straight line. The base must be a level, non-combustible plinth. Underground tanks have reduced surface separation but still need a clear vent stack and access lid.',
      ),
    ],
  ),
  LessonTopic(
    id: 'lpg_safety',
    title: 'LPG safety and emergencies',
    category: 'LPG / Oil',
    summary:
        'Why LPG behaves differently from natural gas, the protective devices fitted to bulk supplies and the correct response to a suspected leak.',
    sections: [
      LessonSection(
        'Heavier-than-air behaviour',
        'Propane vapour has a relative density of about one and a half compared with air, so any escape settles to the lowest point available. On a domestic site that means cellars, under-floor voids, lift pits, gulleys and inspection chambers. A leak that natural gas would disperse through a roof vent will instead pool at floor level. For this reason cellars and basements are not suitable for LPG appliances unless purpose-designed, and low-level ventilation to outside is required. Drain runs near a tank should be trapped, and any unused below-ground void within the separation distance must be filled or sealed before commissioning.',
      ),
      LessonSection(
        'Overpressure and underpressure shut-off',
        'Modern bulk regulators include an OPSO and a UPSO valve. The over-pressure shut-off latches closed if downstream pressure rises above a safe limit, which protects appliances from a failed first-stage regulator. The under-pressure shut-off latches closed if downstream pressure collapses, which prevents air ingress and unsafe re-light if the tank runs empty or a pipe is severed. Both devices are non-self-resetting and must be reset manually after the cause has been investigated. A fitter who simply re-pressurises a tripped OPSO without finding the fault is leaving a known hazard live on the system.',
      ),
      LessonSection(
        'Leak detection on site',
        'A suspected LPG leak is treated as more serious than a natural gas escape because of the pooling behaviour. Evacuate the property, isolate the supply at the tank service valve and ventilate at low level by opening doors. Do not operate any electrical switch, do not use a torch with a mechanical switch and do not allow electronic ignition near the area. Find the leak with leak detection fluid or an approved combustible gas detector working from low points upward. After repair, soundness test to the manufacturer or IGEM procedure before re-commissioning the appliance.',
      ),
      LessonSection(
        'Customer education and reporting',
        'Hand-over should cover the smell of stenched LPG, the location of the emergency control valve at the tank, the contact number for the gas supplier and the basic rule of evacuate, ventilate and call. Customers should also know not to store cylinders indoors or in cellars and not to plant shrubs over an underground tank. RIDDOR applies to any incident causing injury or significant damage involving LPG, and the installer must report dangerous occurrences to the Health and Safety Executive within the timeframe set by the regulations. Records of soundness testing and commissioning should be retained for the life of the installation.',
      ),
    ],
  ),
  LessonTopic(
    id: 'oil_systems',
    title: 'Oil installation systems (OFTEC)',
    category: 'LPG / Oil',
    summary:
        'Tank construction, bunding rules, the fire valve, oil-line components and the OFTEC technical information sheets that govern UK practice.',
    sections: [
      LessonSection(
        'Tank construction options',
        'Three tank constructions dominate the UK domestic market. A single-skin tank is a plain plastic or steel vessel that must sit inside a separate masonry or concrete bund to contain a leak. An integrally bunded tank has a tank-within-a-tank moulded as one unit, with the outer skin sized to hold the contents of the inner tank. A double-skinned steel tank is similar in principle but constructed of two welded shells with an interstitial space, often with a leak-detection probe. Every new domestic installation under OFTEC TI/133 carries a risk assessment that pushes the installer toward bunding wherever a watercourse, drain or hard surface is within range.',
      ),
      LessonSection(
        'Bunding and the 110 per cent rule',
        'A bund must contain at least one hundred and ten per cent of the tank volume. The extra ten per cent allows for rainwater and surge if the tank fails suddenly. For a single-skin one thousand three hundred litre tank that means a masonry bund of at least one thousand four hundred and thirty litres. Bunds must be impermeable, and any pipe penetrations must be sealed against fuel and water. Where the site cannot accept a bund of that size, an integrally bunded or double-skinned tank is the practical answer because the secondary containment is built into the unit and verified at the factory.',
      ),
      LessonSection(
        'Oil supply line components',
        'The supply line from tank to appliance starts with a tank outlet valve, runs through a fire valve sensor at the appliance, then a remote fire valve at the supply, an oil filter and finally a deaerator if the run uses a single-pipe system. Filters are typically rated at around ten micron and protect the burner pump and nozzle from particulate. A deaerator allows a single-pipe lift system without entrained air problems by venting bubbles back to the tank. Pipework above ground is normally soft copper to BS EN 1057 with flared or compression joints; underground it is sleeved or in a continuous coil to avoid joints below grade.',
      ),
      LessonSection(
        'Standards and OFTEC TIs',
        'OFTEC publishes a library of technical information sheets, the TI series, which act as the day-to-day rule book alongside BS 5410. TI/133 covers oil storage, TI/134 oil supply pipework, TI/103 commissioning and TI/171 servicing. A registered technician working under OFTEC must hold the relevant OFT 50, 101 or 105E competence and notify domestic installations under the OFTEC Competent Persons Scheme to satisfy Building Regulations. Working outside that scheme requires Building Control notification by the homeowner, which is slower and more costly, so registration is the normal route.',
      ),
    ],
  ),
  LessonTopic(
    id: 'oil_burner',
    title: 'Oil burner operation and commissioning',
    category: 'LPG / Oil',
    summary:
        'How a pressure-jet burner atomises kerosene, the role of the photocell, and the combustion analysis figures that confirm a clean burn.',
    sections: [
      LessonSection(
        'Pressure-jet versus vaporising burners',
        'The vast majority of UK domestic oil boilers use a pressure-jet burner. An electric pump pressurises the kerosene and forces it through a precision nozzle that atomises the oil into a fine cone. A high-tension transformer fires the electrodes, igniting the spray, and a fan supplies combustion air. Vaporising or pot burners, by contrast, evaporate kerosene from a heated dish; they are simpler but less controllable and now mostly limited to range cookers and small space heaters. A pressure-jet has more components but gives precise, repeatable combustion at a defined firing rate.',
      ),
      LessonSection(
        'Pump pressure and atomisation',
        'Burner manufacturers specify pump pressure and nozzle pairing. Pump pressure typically sits between seven and ten bar at the nozzle, sometimes higher on modern blue-flame burners. The nozzle is stamped with a US gallons-per-hour rating, a spray angle and a pattern letter. Raising the pump pressure increases throughput and shifts the spray finer; lowering it does the opposite. Atomisation is the heart of clean combustion, so the nozzle is replaced at every service rather than cleaned. Verify pressure with a calibrated gauge on the pump test point and adjust to the data badge before running combustion analysis.',
      ),
      LessonSection(
        'Photocell flame failure protection',
        'Oil burners use a cadmium sulphide photocell mounted in the burner head, looking back at the flame. When the flame is present, the cell conducts and the control box holds the oil solenoid open. If the flame fails, the cell goes high resistance and the control box locks out within a few seconds, closing the solenoid and stopping fuel. A safe-start check during pre-purge confirms the cell is dark before ignition begins. A dirty or aged cell is a common cause of nuisance lockouts and is replaced as part of routine service.',
      ),
      LessonSection(
        'Combustion analysis targets',
        'A clean kerosene burn measured at the flue with a calibrated analyser gives carbon dioxide between twelve and thirteen per cent, oxygen around four to five per cent, smoke number zero or one on the Bacharach scale and net thermal efficiency above ninety per cent on a condensing appliance. Carbon monoxide should be in single figures parts per million. Higher smoke or low CO2 points to soot build-up, wrong nozzle or low pump pressure. Service intervals are annual under OFTEC TI/171, with the nozzle, oil filter, photocell and combustion test forming the core of the visit.',
      ),
    ],
  ),
];

import 'lessons_data.dart';

const commercialLessonTopics = <LessonTopic>[
  LessonTopic(
    id: 'commercial_cold_water',
    title: 'Commercial cold water systems',
    category: 'Commercial',
    summary:
        'Break tanks, booster sets and pressure zoning for non-domestic buildings, sized to BS 8558 and the Water Regs.',
    sections: [
      LessonSection(
        'Break tanks and Category 5 protection',
        'In commercial buildings the incoming main is almost always isolated from the building system by a break tank with a Type AA or AB Category 5 air gap. This protects the public main from the very high fluid-category risks present in a typical office, hospital or kitchen. The tank must be WRAS-approved, insulated, vermin-proofed, fitted with a screened warning pipe and a sealed lid, and sized for around the average daily demand plus a buffer for incoming flow failure. Twin-compartment tanks let you isolate one side for cleaning without losing supply, which is essential where downtime is unacceptable. Float valves are usually delayed-action or solenoid-controlled to reduce hammer, and the overflow is always larger than the inlet.',
      ),
      LessonSection(
        'Booster sets: VSP versus hydropneumatic',
        'Once water is in the break tank it has to be pumped, and the choice is between a variable-speed pumped (VSP) set and a hydropneumatic pressure vessel set. A VSP set uses two, three or more pumps with inverters that ramp up and down to hold a constant outlet pressure regardless of demand; this is the modern default because it saves energy and gives smooth control. A hydropneumatic set uses fixed-speed pumps and a large air-charged accumulator, cutting in and out as pressure falls and rises; it is cheaper but cycles harder and is noisier. Whichever you fit, duty/standby/assist sequencing, run-hour balancing and cascade alarms back to the BMS are essential.',
      ),
      LessonSection(
        'Pressure zoning in tall buildings',
        'Static pressure rises by roughly one bar per ten metres, so a tall block cannot be served from a single pressure zone without bursting fittings on the lower floors. The standard solution is to split the building into vertical zones of around six to eight storeys, each fed either by its own booster pump set or by pressure-reducing valves from a single high-pressure riser. Each zone is given its own break tank where possible, sometimes with intermediate transfer pumps lifting water from a basement tank to a roof or mid-level tank. Maximum static pressure at any outlet should normally be held below five bar to protect taps, TMVs and appliances, with PRVs set and witnessed at commissioning.',
      ),
      LessonSection(
        'Sizing to BS 8558 and BS EN 806',
        'Commercial cold water pipework is sized using BS 8558 in conjunction with BS EN 806-3, which lists loading units for each appliance type: WCs, urinals, basins, showers, sinks, bedpan washers and so on. The designer adds the loading units, applies a probability-of-simultaneous-use curve to get a design flow rate, then sizes pipes for an acceptable velocity, normally 1.5 to 2.0 m/s, while keeping pressure loss within the available head. You also have to allow for fluctuating demands such as flush-valve WCs and kitchens, and to design out long dead legs that would breach the L8 turnover requirement. As a fitter, knowing the logic helps you spot mistakes on site before they become defects.',
      ),
    ],
  ),
  LessonTopic(
    id: 'commercial_hot_water',
    title: 'Commercial hot water systems',
    category: 'Commercial',
    summary:
        'Calorifiers, plate heat exchangers and secondary circulation, designed for peak demand and L8-compliant temperatures.',
    sections: [
      LessonSection(
        'Calorifiers and plate heat exchangers',
        'Most commercial buildings generate domestic hot water indirectly. A calorifier is essentially a large insulated cylinder, typically 200 to 5000 litres, heated by a primary coil from a boiler or LTHW circuit. It gives plenty of stored buffer for peaky demands such as showers in a gym or sports centre. A plate heat exchanger (PHE) takes a different approach: a small, high-surface-area unit transfers heat instantaneously from a primary flow to a secondary DHW flow, with a small storage vessel downstream for buffering. PHEs reduce stored volume, lower legionella risk and respond quickly, but they need careful primary-side control. Both options must be sized using diversified peak-hour loads, not just headcount, with attention to recovery times.',
      ),
      LessonSection(
        'Secondary circulation is mandatory',
        'In any non-domestic building, the Water Fittings Regulations and HSE ACoP L8 effectively require a secondary return on hot water distribution wherever the draw-off pipework volume exceeds three litres or the flow time to outlet is excessive. A small bronze or stainless circulator continuously pulls water back from the far end of the loop to the cylinder, keeping the entire flow leg above 50 °C and the return above 55 °C, and ensuring 60 °C storage. Without it, hot water sits stagnant in long branches between uses, dropping into the legionella growth window of 20 to 45 °C. Branches off the loop should be kept short, ideally under three litres of water content, and balancing valves fitted on each return.',
      ),
      LessonSection(
        'Peak-hour versus continuous design',
        'Domestic systems are generally sized on a quick recovery basis, but commercial DHW is sized around either peak-hour demand or continuous demand. Peak-hour design suits hotels, gyms, schools and changing rooms where a short, intense draw-off is followed by long quiet periods: you size the storage to ride out the peak, with a smaller boiler input for slow recovery. Continuous design suits hospitals, laundries and large kitchens where draw-off is sustained: you size the heat input close to the average flow and keep storage modest. Designers use CIBSE Guide G data for fixture flows and demand patterns. As an installer, knowing which model the system is built around helps you commission it correctly.',
      ),
      LessonSection(
        'Point-of-use heaters and their place',
        'Not every outlet should be on the main DHW loop. Where a sink or basin is far from the plant, sees only intermittent use, or sits beyond a long dead-leg, a point-of-use (POU) heater is often the better engineering answer. Unvented POU units of 5 to 15 litres serve isolated cleaners cupboards and remote tea points, while inline electric instantaneous heaters cover hand-wash basins. They cut secondary pumping power, eliminate stagnant branches and reduce legionella risk on lightly used outlets. They do, however, need their own electrical supply, an unvented G3 discharge route and an annual service regime, and they must still be included in the L8 written scheme along with everything else on site.',
      ),
    ],
  ),
  LessonTopic(
    id: 'cascade_boilers',
    title: 'Cascade modulating boilers',
    category: 'Commercial',
    summary:
        'Multiple modulating boilers sequenced together to deliver wide turndown, redundancy and high seasonal efficiency.',
    sections: [
      LessonSection(
        'Why cascade rather than one big boiler',
        'A single 800 kW boiler can only modulate down to perhaps 160 kW; below that it short-cycles and condensing efficiency collapses. Four 200 kW modulating boilers in cascade can modulate from around 800 kW all the way down to roughly 40 kW, matching real building load far more accurately. They run cooler return temperatures more of the time, so they spend more hours genuinely condensing and seasonal efficiency rises. Cascade also gives natural N+1 redundancy: if one boiler trips on a cold morning the other three carry the load, and you can isolate one for service without losing heat. Footprint is similar, and modular delivery often suits cramped commercial plant rooms with restricted access for craning.',
      ),
      LessonSection(
        'BMS sequencing strategies',
        'The cascade controller, whether a manufacturer module or the BMS itself, decides how many boilers fire and at what rate. Common strategies are first-on/first-off (simple but biases wear), last-on/first-off (kinder to seals on the lead boiler), and run-hour balancing where the controller rotates the lead boiler weekly to equalise wear. Modulation is staged: typically the lead boiler ramps to about 80 percent before the next boiler is enabled, and all firing boilers then drop to a shared lower rate to maximise condensing. Setpoint compensation against outside air temperature lets the flow temperature slide from 80 °C in deep winter down to 55 °C in mild weather, dramatically increasing condensing hours.',
      ),
      LessonSection(
        'Primary-secondary headers and low-loss headers',
        'Cascade plant is almost always hydraulically separated from the distribution circuits, because the boilers want stable flow regardless of what the building is doing. The traditional method is a primary-secondary arrangement: each boiler has its own primary pump, the boilers feed a common header, and separate secondary pumps draw from the header to feed heating, DHW and AHU coils. The modern shortcut is a low-loss header, a vertical vessel with four tappings that decouples primary and secondary flows hydraulically while also acting as an air separator and dirt pocket. Either way, the aim is to stop secondary pump changes upsetting boiler flow, which would trip flow switches or push return temperatures out of the condensing band.',
      ),
      LessonSection(
        'Designing for resilience',
        'Commercial heating cannot fail on a Monday morning, so cascade design always considers redundancy. The N+1 rule means installed capacity exceeds peak demand by one boiler, so a single failure does not cause loss of service. Pumps are duty/standby on each header, valves are arranged so any boiler can be isolated live, and pressurisation units have automatic make-up plus low-pressure alarms back to the BMS. Flue dilution fans, where used, are also duplicated. Service access is planned in: a metre clear in front of each boiler, lifting eyes overhead, and isolation pairs on every flow and return. Good resilience is what separates a competent commercial installation from a domestic system simply scaled up.',
      ),
    ],
  ),
  LessonTopic(
    id: 'water_hygiene_l8',
    title: 'Water hygiene under L8',
    category: 'Commercial',
    summary:
        'HSE ACoP L8 and HSG 274 obligations for written schemes, Responsible Persons and routine monitoring.',
    sections: [
      LessonSection(
        'ACoP L8 and HSG 274',
        'The Approved Code of Practice L8, fourth edition, sits under the Health and Safety at Work etc. Act and the COSHH Regulations, and gives guidance on controlling legionella in water systems. It is supplemented by HSG 274 in three parts: evaporative cooling systems, hot and cold water systems, and other risk systems such as spa pools. Together they place a duty on the building duty-holder, normally the employer or person in control of the premises, to identify and assess risk, manage that risk through a written scheme, keep records and review the arrangements regularly. Failure to comply has resulted in successful HSE prosecutions with six-figure fines and, in fatal cases, custodial sentences for individual managers.',
      ),
      LessonSection(
        'Written scheme and Responsible Person',
        'A site must have a written scheme of control, prepared from a current legionella risk assessment, that describes the system, identifies hazards and sets out the precautions and monitoring tasks needed. The duty-holder must appoint a competent named Responsible Person, in writing, with the authority and resources to manage the scheme. They may be supported by deputies and by an external water-hygiene contractor, but accountability stays with the named individual. The scheme covers tank inspections, temperature monitoring, descaling regimes, flushing of low-use outlets, microbiological sampling where appropriate, and a clear escalation route if results fall outside control limits. Records must be retained for at least five years and made available to the HSE on request.',
      ),
      LessonSection(
        'Routine monitoring tasks',
        'HSG 274 Part 2 sets out a monitoring rhythm: weekly flushing of little-used outlets for several minutes, monthly temperature checks at sentinel outlets (the nearest and furthest on each loop), monthly TMV mixed-temperature and fail-safe checks where they serve vulnerable users, six-monthly tank inspections, annual TMV strip-downs, and quarterly sampling for systems running below the standard temperatures. Calorifier flow and return temperatures are recorded monthly, and a drain-down with sludge inspection is carried out annually. As a fitter you are usually the person logging readings into the site logbook, so accurate data, signed and dated, is part of the deliverable. Anomalies must be reported to the Responsible Person the same day.',
      ),
      LessonSection(
        'The 50/55/60 rule and dead legs',
        'The cardinal temperature rule for hot water systems is 60-55-50: store at 60 °C, distribute the flow at 60 °C and the return at not less than 55 °C, and deliver at outlets within one minute at 50 °C, or 55 °C in healthcare. Cold water must reach outlets below 20 °C within two minutes. Anything between 20 and 45 °C is the legionella growth zone and must be minimised. Dead legs - branches with no flow, capped spurs left from refurbishments, redundant outlets - are a primary risk because water sits warm and stagnant. The rule of thumb is that any branch holding more than three litres of water without regular use should be cut back to the main and capped at the tee.',
      ),
    ],
  ),
  LessonTopic(
    id: 'commercial_drainage',
    title: 'Commercial drainage',
    category: 'Commercial',
    summary:
        'Above-ground drainage to BS EN 12056, multi-storey stack sizing and specialist features such as grease traps and pumped systems.',
    sections: [
      LessonSection(
        'BS EN 12056 and discharge units',
        'Above-ground drainage for non-domestic buildings is designed to BS EN 12056, which uses discharge units (DU) rather than the loading units used for water supply. Each appliance has a DU value: a WC at around 2.0, a basin at 0.5, a urinal at 0.5, a kitchen sink at 0.8 and so on. The designer totals the DUs on a stack, applies a frequency factor K, depending on use type from intermittent (0.5) to congested (1.2), and reads off the required pipe size and slope from the standard tables. System types I to IV define how branches and stacks combine: System III with separately ventilated branches is common in the UK for taller buildings. As an installer, getting the falls and venting right is what makes the maths work in practice.',
      ),
      LessonSection(
        'Separate vent stacks and stack sizing',
        'In a tall block a single discharge stack quickly runs out of capacity because the falling water column entrains air and pulls traps. The fix is a parallel ventilating stack cross-connected to the discharge stack at every floor or every other floor, often called a one-pipe vented system. Diameters are sized from BS EN 12056 plus the BS EN 12056-2 UK National Annex: typically 100 mm discharge with a 50 mm vent for office blocks, increasing to 150 mm for hospitals and busy hotels. Air admittance valves are useful for terminations inside the building envelope where running the vent through the roof is impractical, but at least one open vent stack should always remain to allow positive air movement in either direction.',
      ),
      LessonSection(
        'Grease traps for commercial kitchens',
        'Any commercial kitchen discharging fats, oils and grease (FOG) into the public sewer is breaking water-company trade-effluent rules unless it has effective grease management. The default is a passive grease separator sized to BS EN 1825, calculated from kitchen flow rate, sink size, density factor and a temperature factor. A 4 NS unit is typical for a small pub kitchen; large hotel kitchens may need 10 to 25 NS or an automated grease recovery unit (GRU). They sit downstream of dishwashers and pot wash sinks but never WCs, fitted with sample chambers and emptied on a contract, usually monthly. A blocked grease trap floods the kitchen at the worst possible moment, so service intervals must be set in the O and M.',
      ),
      LessonSection(
        'Pump stations, macerators and inspection',
        'Where appliances sit below the level of the public sewer - basement plant rooms, lower-ground toilets, lift pits - a pump station or sealed macerator is required. Twin-pump packaged stations with non-return valves on each rising main, a vortex-impeller chamber, level controls and a high-level alarm to the BMS are the commercial norm; single-pump units belong in domestic. Sizing follows BS EN 12056-4 with a 25 percent capacity margin. Below ground, BS EN 752 governs the drains: inspection chambers (smaller, no man-entry) at every change of direction up to about 1.2 m deep, then full manholes with step irons or a permanent ladder beyond that. All work must be CCTV surveyed and air-tested at handover.',
      ),
    ],
  ),
  LessonTopic(
    id: 'bms_controls',
    title: 'BMS and BACnet controls',
    category: 'Commercial',
    summary:
        'How the building management system orchestrates plant, communicates over BACnet and presents an interface to the plumber on site.',
    sections: [
      LessonSection(
        'What a BMS actually does',
        'A building management system is a network of controllers, sensors and actuators that runs the building services to a defined sequence of operation. It schedules plant on and off, holds setpoints, sequences cascade boilers and chillers, opens and closes motorised valves, modulates pumps and AHU dampers, and logs alarms. A typical commercial BMS will have a central server and graphical front end, field-level controllers in each plant room, and a bus running between them. The plumber sees it as a panel with a screen, a row of relays driving the plant, and terminals where the field wiring lands. Without the BMS, the plant runs only at hard-wired safeties; with it, the building reaches its design efficiency and comfort.',
      ),
      LessonSection(
        'Sensors and actuators on plumbing plant',
        'On a heating system the BMS will read flow and return temperatures at the boilers, the low-loss header and each heating circuit, plus outside air temperature for compensated control. Pressure sensors monitor the sealed system, water-meter pulses log make-up, and contact sets on the pressurisation unit raise low-pressure alarms. Actuated three-port and two-port valves modulate flow, variable-speed pump headers report run, fault and speed, and flow switches prove circulation. On DHW the BMS watches calorifier temperatures, runs a pasteurisation cycle, and proves the secondary return. A clean schedule of points - tag, type, range and units - is essential, both for the controls contractor and for you when you connect an immersion pocket or a strap-on sensor in the right place.',
      ),
      LessonSection(
        'BACnet, Modbus and KNX',
        'Three communication protocols dominate UK commercial work. BACnet (BS EN ISO 16484-5) is the open standard for HVAC and is used between BMS controllers, IP-based for backbones and MS/TP twisted pair for field devices; it is the default for new specifications. Modbus, originally an industrial bus, is widely used for meters, inverters and packaged plant such as boilers and chillers, often delivered over RS-485 or TCP. KNX is more common in lighting and small-building automation but appears on hotels and high-end residential. A modern BMS panel will typically host BACnet upstream and gateway off to Modbus or proprietary protocols on the plant. Knowing which bus you are dealing with helps you choose compatible boiler interface kits.',
      ),
      LessonSection(
        'Sequence of operation and your interface points',
        'Every commercial controls package is built around a written sequence of operation: cause-and-effect logic that says, in plain English, what the plant must do under each operating mode. Boiler enable on heating call, lead boiler rotates weekly, secondary pump runs continuously between 06:00 and 19:00, and so on. As the plumber you are not writing this, but you are responsible for delivering the plant on which the controls run: pockets in the right tee, pump heads with isolation, sensor wells fitted before flushing, and clean labelled cables back to the panel. Walk the sequence with the controls engineer at commissioning and witness the points list - that is what proves the install matches the spec.',
      ),
    ],
  ),
];

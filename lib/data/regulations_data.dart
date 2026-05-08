class RegulationEntry {
  final String code;
  final String topic;
  final String category;
  final String summary;
  final List<String> keyPoints;
  final String whoEnforces;

  const RegulationEntry({
    required this.code,
    required this.topic,
    required this.category,
    required this.summary,
    required this.keyPoints,
    required this.whoEnforces,
  });

  String get speakable =>
      '$code. $topic. $summary. Key points. ${keyPoints.join(". ")}. Who enforces it. $whoEnforces';
}

const regulationEntries = <RegulationEntry>[
  RegulationEntry(
    code: 'Building Regs Part G',
    topic: 'Sanitation, hot water safety and water efficiency',
    category: 'Building',
    summary:
        'Sets requirements for cold and hot water supply, water efficiency '
        '(125 litres per person per day for new dwellings) and the safe '
        'installation of hot water systems including unvented cylinders.',
    keyPoints: [
      'Wholesome cold water must be provided to any kitchen sink and to any '
          'wash basin or bath used for personal hygiene.',
      'Hot water systems must include vent pipes, temperature relief valves '
          'and expansion vessels suitable for the system type.',
      'Unvented hot water storage over 15 litres must be installed by a G3 '
          'qualified person and notified to building control.',
      'Hot water delivered to a bath must be limited to a maximum of 48 '
          'degrees Celsius using a thermostatic mixing valve.',
      'New dwellings must be designed to use no more than 125 litres of '
          'water per person per day, or 110 in optional tighter regions.',
      'Sanitary conveniences must have suitable washing facilities adjacent '
          'and discharge to an adequate drainage system.',
    ],
    whoEnforces: 'Local authority building control or an approved inspector.',
  ),
  RegulationEntry(
    code: 'Building Regs Part L',
    topic: 'Conservation of fuel and power',
    category: 'Building',
    summary:
        'Requires reasonable provision for the conservation of fuel and '
        'power in buildings, covering boiler efficiency, controls, pipe '
        'insulation and overall heating system performance.',
    keyPoints: [
      'New and replacement gas boilers in dwellings must be condensing with '
          'a minimum ErP seasonal efficiency, typically 92 per cent.',
      'Heating systems must have time and temperature control, boiler '
          'interlock and TRVs on radiators except in the room with the room '
          'thermostat.',
      'Hot and cold pipework in unheated areas must be insulated to the '
          'thicknesses given in the Domestic Building Services Compliance '
          'Guide.',
      'Hot water cylinders must meet minimum heat loss factors and be fitted '
          'with a cylinder thermostat and a separate timer or programmer.',
      'Notifiable work such as boiler replacement must be self-certified '
          'through a competent person scheme like Gas Safe or notified to '
          'building control.',
      'A Benchmark commissioning checklist must be completed and handed to '
          'the user on installation.',
    ],
    whoEnforces:
        'Building control, supported by competent person schemes such as '
        'Gas Safe Register.',
  ),
  RegulationEntry(
    code: 'Building Regs Part J',
    topic: 'Combustion appliances and fuel storage systems',
    category: 'Building',
    summary:
        'Covers the safe installation of heat producing appliances, flues '
        'and chimneys, as well as the provision of combustion air and the '
        'protection of buildings from heat and fire.',
    keyPoints: [
      'Combustion appliances must have an adequate supply of air for proper '
          'combustion and operation of the flue.',
      'Flue systems must be designed and installed to safely discharge '
          'products of combustion to outside air.',
      'Hearths, fireplaces, flues and chimneys must protect the building '
          'fabric from catching fire and from excessive heat.',
      'A carbon monoxide alarm must be fitted in the same room as any new '
          'or replacement solid fuel or wood burning appliance, and gas '
          'appliances in many regions.',
      'Flue terminals must be sited to avoid nuisance, ingress of products '
          'into openings, and risks to people, observing the distances in '
          'Diagram in Approved Document J.',
      'A notice plate giving information about hearths and flues must be '
          'fixed in the dwelling for new flues.',
    ],
    whoEnforces:
        'Building control and Gas Safe Register for gas appliances; HETAS '
        'for solid fuel.',
  ),
  RegulationEntry(
    code: 'Building Regs Part P',
    topic: 'Electrical safety in dwellings',
    category: 'Electrical',
    summary:
        'Requires that fixed electrical installations in dwellings are '
        'designed and installed to protect people from fire and injury, and '
        'sets out which work must be notified.',
    keyPoints: [
      'All fixed electrical work in a dwelling must comply with the '
          'fundamental safety principles of BS 7671.',
      'Notifiable work includes new circuits, consumer unit replacement and '
          'work in special locations such as bathrooms.',
      'Notifiable work should be carried out by a registered competent '
          'person, otherwise it must be notified to building control before '
          'starting.',
      'On completion the installer must issue an Electrical Installation '
          'Certificate or a Minor Electrical Installation Works Certificate.',
      'Plumbers carrying out bonding to incoming water and gas services '
          'must ensure connections meet BS 7671 requirements.',
      'Records and certificates should be passed to the homeowner and to '
          'building control where required.',
    ],
    whoEnforces:
        'Building control, with self-certification via schemes such as '
        'NICEIC, NAPIT and Stroma.',
  ),
  RegulationEntry(
    code: 'Water Supply (Water Fittings) Regulations 1999',
    topic: 'Prevention of waste, misuse, contamination of water',
    category: 'Water',
    summary:
        'Statutory requirements for the design, installation and '
        'maintenance of plumbing systems and water fittings supplied from '
        'the public mains, focused on backflow prevention and water '
        'quality.',
    keyPoints: [
      'Fluid Category 1 is wholesome water; Category 5 is the highest risk '
          'and represents a serious health hazard such as faecal matter.',
      'Backflow prevention must be appropriate to the fluid category, for '
          'example a Type AA or AB air gap for Category 5.',
      'Notice must be given to the water undertaker before certain works '
          'such as installing a bidet with ascending spray or a pond fill.',
      'Only fittings of an appropriate quality and standard, often WRAS or '
          'Regulation 4 approved, may be installed.',
      'Pipes must be protected against frost, corrosion and damage and '
          'isolation valves provided where required.',
      'Concealed pipework must not have mechanical joints unless they are '
          'of a type that does not require maintenance.',
    ],
    whoEnforces: 'The local water undertaker (water company) and WRAS.',
  ),
  RegulationEntry(
    code: 'Gas Safety (Installation and Use) Regulations 1998',
    topic: 'Safe installation, maintenance and use of gas',
    category: 'Gas',
    summary:
        'The principal legislation governing gas work in Great Britain. '
        'Anyone carrying out work on gas fittings or appliances for hire or '
        'reward must be competent and on the Gas Safe Register.',
    keyPoints: [
      'Only Gas Safe registered engineers may work on gas installations '
          'including pipework, appliances and meters.',
      'Operatives must hold current ACS competence for the specific work '
          'category, for example CCN1 and CENWAT.',
      'A tightness test and purge must be carried out before commissioning '
          'in accordance with IGEM/UP/1B.',
      'On finding an immediately dangerous or at risk situation, the '
          'engineer must follow the Gas Industry Unsafe Situations '
          'Procedure and label the appliance.',
      'In the event of a gas escape the engineer or user must call the '
          'National Gas Emergency Service on 0800 111 999.',
      'Landlords must arrange annual safety checks of gas appliances and '
          'flues and provide a CP12 record to tenants.',
    ],
    whoEnforces: 'Health and Safety Executive and the Gas Safe Register.',
  ),
  RegulationEntry(
    code: 'BS EN 12831',
    topic: 'Heating system design - method for calculation of heat load',
    category: 'Standards',
    summary:
        'European standard giving the method for calculating the design '
        'heat load of buildings, used for sizing radiators, boilers and '
        'heat pumps.',
    keyPoints: [
      'The standard provides a room by room method for calculating '
          'transmission and ventilation heat losses at design conditions.',
      'External design temperature is location specific and is taken from '
          'national annexes for the UK.',
      'Internal design temperatures are typically 21 in living rooms, 18 '
          'in bedrooms and 22 in bathrooms.',
      'Heat losses through the building fabric depend on U-values of '
          'walls, roof, floor, windows and doors.',
      'Air change rates account for ventilation and infiltration losses '
          'through the building envelope.',
      'The total of fabric and ventilation losses, plus any reheat '
          'allowance, gives the design heat load for the property.',
    ],
    whoEnforces:
        'Used as an industry standard, referenced by MCS for heat pumps '
        'and by the CIBSE design guides.',
  ),
  RegulationEntry(
    code: 'BS EN 806',
    topic: 'Specifications for installations inside buildings conveying '
        'water for human consumption',
    category: 'Standards',
    summary:
        'A multi part European standard covering the design, installation, '
        'commissioning, operation and maintenance of cold and hot water '
        'systems within buildings.',
    keyPoints: [
      'Part 1 covers general principles; Part 2 design; Part 3 pipe '
          'sizing using a simplified loading units method.',
      'Part 4 covers installation including pipe supports, jointing and '
          'protection from frost and damage.',
      'Part 5 covers operation and maintenance, including flushing, '
          'disinfection and periodic inspection.',
      'Pipe sizing uses loading units assigned to each fitting and design '
          'flow rates derived from the total loading units.',
      'Velocities should normally be limited to about 2 metres per second '
          'in copper to reduce noise and erosion.',
      'Systems should be designed to minimise dead legs and stagnation to '
          'control the risk of legionella.',
    ],
    whoEnforces:
        'Industry standard, referenced by water companies and approved '
        'document G of the Building Regulations.',
  ),
  RegulationEntry(
    code: 'BS 6700 / BS 8558',
    topic: 'Domestic water services within buildings',
    category: 'Standards',
    summary:
        'BS 8558 is the UK complementary guidance to BS EN 806 and '
        'replaces BS 6700. It gives recommendations on design, '
        'installation, testing and maintenance of water services in '
        'buildings.',
    keyPoints: [
      'BS 8558 provides UK specific guidance to be read alongside BS EN '
          '806 parts 1 to 5.',
      'It covers materials, jointing methods and the protection of '
          'potable water from contamination.',
      'Storage cisterns must be covered, insulated and labelled, and '
          'sized to provide adequate flow and protect from contamination.',
      'Hot water storage temperatures should be at least 60 degrees '
          'Celsius to control legionella, with distribution at 55 or '
          'above.',
      'Cold water should be delivered below 20 degrees Celsius where '
          'reasonably practicable to limit bacterial growth.',
      'Commissioning should include flushing, pressure testing and '
          'disinfection where required.',
    ],
    whoEnforces:
        'Industry standard, referenced by Water Regulations and Approved '
        'Document G.',
  ),
  RegulationEntry(
    code: 'BS 5572',
    topic: 'Sanitary pipework above ground',
    category: 'Standards',
    summary:
        'Code of practice giving recommendations for the design, layout '
        'and installation of sanitary pipework above ground for domestic '
        'and similar buildings.',
    keyPoints: [
      'Trap seals are typically 75 mm for above ground domestic '
          'appliances to resist loss by siphonage and back pressure.',
      'Branch pipe gradients should generally be between 18 and 90 '
          'millimetres per metre for WCs and basins.',
      'Maximum branch lengths and bends are specified to prevent self '
          'siphonage and trap seal loss.',
      'Stacks should be ventilated either by extending above the roof or '
          'by using an air admittance valve where permitted.',
      'Branch connections to the stack should avoid the bend at the foot '
          'of the stack within prescribed distances.',
      'All joints should be accessible for testing; the system is air '
          'tested at 38 millimetres of water gauge for 3 minutes.',
    ],
    whoEnforces:
        'Industry standard, referenced by Approved Document H of the '
        'Building Regulations.',
  ),
  RegulationEntry(
    code: 'Health and Safety at Work Act 1974',
    topic: 'General duties on employers, employees and the self employed',
    category: 'Building',
    summary:
        'The principal piece of UK health and safety legislation. Places '
        'duties on installers to ensure their work does not put '
        'themselves, colleagues or members of the public at risk.',
    keyPoints: [
      'Employers must, so far as is reasonably practicable, ensure the '
          'health, safety and welfare of all employees.',
      'Self employed plumbers must conduct their work so as not to '
          'expose themselves or others to risks to health or safety.',
      'Employees and operatives must take reasonable care for themselves '
          'and cooperate with their employer on safety matters.',
      'Risk assessments and method statements should be prepared for '
          'significant tasks such as hot works or working at height.',
      'Personal protective equipment must be supplied and used where '
          'risks cannot be otherwise eliminated.',
      'Reportable incidents must be notified under RIDDOR to the Health '
          'and Safety Executive.',
    ],
    whoEnforces:
        'Health and Safety Executive, supported by local authority '
        'environmental health.',
  ),
  RegulationEntry(
    code: 'WRAS Approval',
    topic: 'Approval of fittings and materials in contact with potable water',
    category: 'Water',
    summary:
        'WRAS, the Water Regulations Approval Scheme, certifies products '
        'and materials as compliant with the Water Supply (Water '
        'Fittings) Regulations and Scottish Byelaws.',
    keyPoints: [
      'WRAS approval covers both the mechanical performance of a '
          'product and the materials in contact with drinking water.',
      'Material approval confirms that the substance does not impart '
          'taste, odour or harmful chemicals to wholesome water.',
      'Product approval covers the whole fitting and means it can be '
          'installed without further testing on individual contracts.',
      'WRAS publishes an online directory where installers can search '
          'by manufacturer, product or material.',
      'Use of WRAS approved products is the simplest way to demonstrate '
          'compliance with the Water Fittings Regulations.',
      'Installers should record the make, model and approval reference '
          'where requested by the water undertaker.',
    ],
    whoEnforces: 'Water undertakers, working with WRAS.',
  ),
  RegulationEntry(
    code: 'Hot Water Association G3',
    topic: 'Unvented hot water storage system competence',
    category: 'Water',
    summary:
        'Approved Document G3 of the Building Regulations requires that '
        'unvented hot water storage systems over 15 litres are installed '
        'by a competent person holding a recognised G3 qualification.',
    keyPoints: [
      'Unvented systems must be supplied as a package or unit and have '
          'at least three levels of safety control.',
      'Required safety devices include a thermostat, a high limit '
          'thermostat and a temperature and pressure relief valve.',
      'A discharge pipe D1 from the relief valve must run to a tundish, '
          'then a D2 pipe to a safe visible termination.',
      'Installers must hold a current G3 certificate from a recognised '
          'awarding body and be registered with a competent person '
          'scheme or notify building control.',
      'Annual servicing of the cylinder, expansion vessel and pressure '
          'reducing valve is recommended.',
      'A Benchmark commissioning record must be completed and left with '
          'the user.',
    ],
    whoEnforces:
        'Building control and competent person schemes, with the Hot '
        'Water Association providing guidance.',
  ),
];

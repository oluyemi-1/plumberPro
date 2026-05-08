class RetrofitRole {
  final String title;
  final String summary;
  final String responsibilities;
  final List<String> deliverables;
  final String competence;

  const RetrofitRole({
    required this.title,
    required this.summary,
    required this.responsibilities,
    required this.deliverables,
    required this.competence,
  });

  String get speakable =>
      '$title. $summary. Responsibilities. $responsibilities. Deliverables. ${deliverables.join(". ")}. Competence. $competence';
}

class PasStage {
  final int order;
  final String name;
  final String description;
  final List<String> outputs;

  const PasStage({
    required this.order,
    required this.name,
    required this.description,
    required this.outputs,
  });

  String get speakable =>
      'Stage $order. $name. $description. Outputs. ${outputs.join(". ")}.';
}

class VentilationStrategy {
  final String label;
  final String airtightness;
  final String approach;

  const VentilationStrategy({
    required this.label,
    required this.airtightness,
    required this.approach,
  });

  String get speakable =>
      'Ventilation strategy $label. Airtightness $airtightness. Approach. $approach.';
}

class RiskPath {
  final String label;
  final String summary;
  final List<String> requirements;

  const RiskPath({
    required this.label,
    required this.summary,
    required this.requirements,
  });

  String get speakable =>
      'Risk path $label. $summary. Requirements. ${requirements.join(". ")}.';
}

const retrofitRoles = <RetrofitRole>[
  RetrofitRole(
    title: 'Retrofit Coordinator',
    summary: 'Overall project manager who steers the retrofit through every PAS 2035 stage.',
    responsibilities:
        'The Coordinator is the central point of accountability for the retrofit project. They appoint and manage all other PAS 2035 roles, confirm scope with the client, and oversee compliance with the standard from initial enquiry through to evaluation. They review the assessment, agree the risk path, sign off the Medium-Term Improvement Plan, and ensure the installer works to the design. Where conflicts arise between measures, the Coordinator resolves them. They also lodge the project on TrustMark and respond to any post-installation issues identified during the 24 month evaluation window.',
    deliverables: <String>[
      'Project plan and risk path decision',
      'Appointment letters for Assessor, Designer, Installer and Evaluator',
      'Signed-off MTIP and works specification',
      'TrustMark lodgement and customer handover pack',
      'Coordination of evaluation reports at 1, 6 and 12 months',
      'Compliance file for the dwelling',
    ],
    competence:
        'Retrofit Coordinator qualification (Level 5 Diploma) and registration with TrustMark via a Scheme Provider.',
  ),
  RetrofitRole(
    title: 'Retrofit Assessor',
    summary: 'Surveys the dwelling and produces the whole-house condition and energy report.',
    responsibilities:
        'The Assessor visits the property and carries out an RdSAP energy assessment alongside a whole-house condition survey. They record building fabric, services, ventilation, moisture risk, occupancy patterns and heritage features. The output is a comprehensive picture of how the dwelling currently performs, what condition it is in, and what constraints any retrofit must respect. The Assessor flags damp, mould, structural concerns and suspected asbestos for further investigation. Their report feeds directly into the Coordinator’s risk path decision and the Designer’s improvement plan.',
    deliverables: <String>[
      'RdSAP energy assessment and current EPC rating',
      'Whole-house condition survey report',
      'Occupancy assessment and ventilation review',
      'Photographic record and floor plans',
      'Identification of hazards and heritage constraints',
    ],
    competence:
        'Domestic Energy Assessor qualification plus Level 3 Award in Domestic Retrofit Assessment, lodged with an accreditation body.',
  ),
  RetrofitRole(
    title: 'Retrofit Designer',
    summary: 'Produces the Medium-Term Improvement Plan and detailed measure designs.',
    responsibilities:
        'The Designer takes the assessment and produces the Medium-Term Improvement Plan (MTIP), setting out the package of measures needed to bring the dwelling toward its retrofit target rating. They specify each measure technically, including heat loss calculations, ventilation strategy, moisture risk analysis and interface details between fabric and services. For Risk Path B and C projects the Designer must produce a fuller design package, which on heritage or traditional buildings should be signed off by a chartered designer. They liaise with the Coordinator and Installer to resolve buildability questions before works start.',
    deliverables: <String>[
      'Medium-Term Improvement Plan (MTIP)',
      'Heat loss calculations and emitter sizing',
      'Ventilation strategy selection (A/B/C/D)',
      'Moisture risk assessment per BS 5250',
      'Detailed drawings and junction details',
      'Specification for each retrofit measure',
    ],
    competence:
        'Level 5 Diploma in Retrofit Design or chartered status with CIBSE, RIBA or CIAT plus retrofit competence.',
  ),
  RetrofitRole(
    title: 'Retrofit Installer',
    summary: 'Installs the measures on site to the Designer’s specification.',
    responsibilities:
        'The Installer carries out the physical works, whether that is a heat pump, insulation, controls, ventilation or solar PV. They must follow the Designer’s specification and feed back any deviation through the Coordinator before changing the works. The Installer is responsible for site quality control, safe disposal of waste, and protecting occupants during the build. On completion they commission each measure to the manufacturer’s instructions and the design parameters, hand over to the customer with clear operating guidance, and submit certificates that go into the compliance file.',
    deliverables: <String>[
      'Installation in line with the design specification',
      'Commissioning records (e.g. Benchmark, MCS, BS 7593)',
      'Building Regulations notifications where applicable',
      'Customer handover pack and demonstration',
      'Manufacturer warranties and product datasheets',
    ],
    competence:
        'Trade qualifications (NVQ Level 2/3) plus MCS or PAS 2030 certification appropriate to the measure being installed.',
  ),
  RetrofitRole(
    title: 'Retrofit Evaluator',
    summary: 'Reviews the completed retrofit and reports back at fixed intervals.',
    responsibilities:
        'The Evaluator returns to the dwelling after handover to check that the retrofit is performing as intended. They review installer paperwork, interview occupants about comfort and bills, inspect the measures visually, and where appropriate read meters and ventilation rates. Reports are produced at one month, six months and twelve months, capturing any issues such as overheating, condensation, controls misuse or cold spots. Lessons learned feed back to the Coordinator and ultimately into industry continuous improvement. On Risk Path C projects the Evaluator may also commission monitoring equipment.',
    deliverables: <String>[
      'One month evaluation report',
      'Six month evaluation report',
      'Twelve month evaluation report',
      'Occupant feedback questionnaire',
      'Issues log and corrective actions list',
    ],
    competence:
        'Level 3 or higher retrofit qualification with specific evaluator training and an independent stance from the installer.',
  ),
];

const pasStages = <PasStage>[
  PasStage(
    order: 1,
    name: 'Initial enquiry and appointment of Coordinator',
    description:
        'A homeowner, landlord or funder enquires about retrofit works. A Retrofit Coordinator is appointed to lead the project and explain the PAS 2035 process to the client.',
    outputs: <String>[
      'Signed coordinator appointment',
      'Initial scope and customer objectives',
      'Project registered with TrustMark',
    ],
  ),
  PasStage(
    order: 2,
    name: 'Whole-house assessment',
    description:
        'A Retrofit Assessor surveys the dwelling, producing an RdSAP energy assessment, a condition survey and an occupancy assessment so the building is fully understood.',
    outputs: <String>[
      'RdSAP report',
      'Condition survey',
      'Occupancy assessment',
      'Photos and floor plans',
    ],
  ),
  PasStage(
    order: 3,
    name: 'Risk assessment and risk path',
    description:
        'The Coordinator reviews the assessment and assigns the project to Risk Path A, B or C, which sets the depth of design work required.',
    outputs: <String>[
      'Risk path decision (A, B or C)',
      'Constraints register',
      'Heritage and traditional construction flags',
    ],
  ),
  PasStage(
    order: 4,
    name: 'Medium-Term Improvement Plan',
    description:
        'The Retrofit Designer produces the MTIP, a 20–30 year roadmap of measures that move the dwelling toward its retrofit target without creating unintended consequences.',
    outputs: <String>[
      'MTIP document',
      'Sequenced package of measures',
      'Target SAP rating and carbon outcome',
    ],
  ),
  PasStage(
    order: 5,
    name: 'Customer brief and works specification',
    description:
        'The selected first package of measures is specified in detail. The customer is briefed on disruption, costs, expected performance and operating responsibilities.',
    outputs: <String>[
      'Detailed measure specifications',
      'Ventilation strategy selection',
      'Moisture risk assessment',
      'Customer agreement to proceed',
    ],
  ),
  PasStage(
    order: 6,
    name: 'Installation',
    description:
        'A certified Retrofit Installer carries out the works to the design, raising any deviations through the Coordinator before changing scope.',
    outputs: <String>[
      'Installed measures on site',
      'Daily site records',
      'Building Regulations notifications',
    ],
  ),
  PasStage(
    order: 7,
    name: 'Commissioning and handover',
    description:
        'Each measure is commissioned to the design parameters and the customer is shown how to operate the new systems safely and efficiently.',
    outputs: <String>[
      'Commissioning certificates',
      'Customer handover pack',
      'Operating and maintenance instructions',
      'Warranties lodged',
    ],
  ),
  PasStage(
    order: 8,
    name: 'Evaluation at 1, 6 and 12 months',
    description:
        'The Retrofit Evaluator returns to the dwelling at three set points to confirm the measures perform as intended and to capture any issues.',
    outputs: <String>[
      '1 month report',
      '6 month report',
      '12 month report',
      'Issues log',
    ],
  ),
  PasStage(
    order: 9,
    name: 'Continuous improvement',
    description:
        'Lessons learned from the evaluation feed back to the Coordinator, designer and installer, and into industry continuous improvement processes.',
    outputs: <String>[
      'Lessons learned summary',
      'Corrective actions completed',
      'Compliance file closed',
    ],
  ),
];

const ventilationStrategies = <VentilationStrategy>[
  VentilationStrategy(
    label: 'A',
    airtightness: '≤ 5 m³/(h·m²) at 50 Pa — airtight',
    approach:
        'Mechanical Ventilation with Heat Recovery (MVHR) or balanced mechanical ventilation. The dwelling is sufficiently airtight that controlled supply and extract is essential, and the heat recovery unit pays back through reduced heat losses. Ducting must be designed, commissioned and balanced.',
  ),
  VentilationStrategy(
    label: 'B',
    airtightness: '5 to 7 m³/(h·m²) at 50 Pa — moderate',
    approach:
        'Continuous Mechanical Extract Ventilation (CMEV) running at trickle rates with boosted extract in wet rooms. Background air enters via trickle vents or designed leakage paths. Suitable for many post-1990 dwellings after fabric upgrades.',
  ),
  VentilationStrategy(
    label: 'C',
    airtightness: '7 to 10 m³/(h·m²) at 50 Pa — leaky',
    approach:
        'Intermittent mechanical extract in wet rooms (kitchen, bathroom, utility) combined with background ventilators (trickle vents) sized to Approved Document F. Typical of dwellings that have had some upgrade work but remain quite leaky overall.',
  ),
  VentilationStrategy(
    label: 'D',
    airtightness: '> 10 m³/(h·m²) at 50 Pa — very leaky',
    approach:
        'Natural ventilation with background ventilators only. Typical of older traditional houses where breathability is important. Care must be taken when upgrading fabric not to push the dwelling into a strategy that no longer matches its airtightness.',
  ),
];

const riskPaths = <RiskPath>[
  RiskPath(
    label: 'A',
    summary:
        'Low risk. Simple, single or limited measures on a relatively modern dwelling with no heritage or unusual construction.',
    requirements: <String>[
      'Standard PAS 2035 assessment',
      'Coordinator-led project file',
      'Designer input proportionate to the measure',
      'Standard installer commissioning and handover',
      'Evaluation at 1, 6 and 12 months',
    ],
  ),
  RiskPath(
    label: 'B',
    summary:
        'Medium risk. Multiple measures, deeper retrofit, or a dwelling with some constraints that need detailed design.',
    requirements: <String>[
      'Full whole-house assessment with extra surveys as needed',
      'Detailed MTIP with sequencing logic',
      'Specific moisture and ventilation strategy design',
      'Designer-led specification of interfaces and junctions',
      'Closer evaluation, including occupant interviews',
    ],
  ),
  RiskPath(
    label: 'C',
    summary:
        'High risk. Traditional, heritage, listed or otherwise non-standard buildings, or projects with complex constraints.',
    requirements: <String>[
      'Full design package by a chartered designer',
      'Hygrothermal modelling where solid walls are insulated',
      'Heritage and conservation officer engagement',
      'Bespoke detailing for every junction',
      'Extended monitoring and evaluation, often with sensors',
      'Independent peer review of the design',
    ],
  ),
];

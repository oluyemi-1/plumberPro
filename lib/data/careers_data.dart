// Career-related reference data for the plumbing-training app.
//
// This module exposes three pieces of structured content:
//   * CareerStage — typical progression points for a UK plumber.
//   * Qualification — the formal certifications that gate certain work.
//   * CareerPath — the specialisations a qualified operative can pursue.
//
// All data is constant and intentionally UK-flavoured (NVQ, Gas Safe,
// OFTEC, WRAS, etc.). Costs and earnings figures are realistic ballpark
// ranges rather than exact quotes.

class CareerStage {
  final String stage;
  final String description;
  final List<String> skills;

  const CareerStage({
    required this.stage,
    required this.description,
    required this.skills,
  });

  String get speakable =>
      '$stage. $description. Key skills. ${skills.join(". ")}';
}

class Qualification {
  final String name;
  final String level;
  final String summary;
  final List<String> requirements;
  final String body;

  const Qualification({
    required this.name,
    required this.level,
    required this.summary,
    required this.requirements,
    required this.body,
  });

  String get speakable =>
      '$name. $level qualification. $summary. Requirements. '
      '${requirements.join(". ")}. $body';
}

class CareerPath {
  final String id;
  final String title;
  final String summary;
  final String narrative;
  final List<String> dayInTheLife;
  final List<String> typicalEarnings;

  const CareerPath({
    required this.id,
    required this.title,
    required this.summary,
    required this.narrative,
    required this.dayInTheLife,
    required this.typicalEarnings,
  });

  String get speakable =>
      '$title. $summary. $narrative. A typical day. '
      '${dayInTheLife.join(". ")}. Typical earnings. '
      '${typicalEarnings.join(". ")}';
}

const careerStages = <CareerStage>[
  CareerStage(
    stage: 'Trainee plumber',
    description:
        'Brand new entrant working under close supervision while studying '
        'a Level 2 plumbing qualification. Tasks are simple and repetitive, '
        'such as fetching tools, cutting copper to length and cleaning out '
        'voids before first fix.',
    skills: [
      'Tool recognition and safe handling',
      'Basic copper cutting, deburring and bending',
      'Reading simple isometric drawings',
      'Site safety and PPE awareness',
    ],
  ),
  CareerStage(
    stage: 'Apprentice (Level 2)',
    description:
        'Formally enrolled on an apprenticeship with day-release at college. '
        'Now allowed to carry out basic first-fix pipework, fit sanitaryware '
        'and assist on cylinder swaps under a qualified plumber.',
    skills: [
      'Capillary and compression jointing',
      'First-fix hot, cold and waste',
      'Soldering with lead-free solder to BS EN 1254',
      'Tightness testing on low-pressure systems',
    ],
  ),
  CareerStage(
    stage: 'Improver',
    description:
        'NVQ Level 2 complete and working towards Level 3. Capable of running '
        'small jobs solo such as tap changes, radiator swaps and minor leak '
        'repairs, with calls back to a senior for sign-off on anything notifiable.',
    skills: [
      'Independent fault-finding on simple S-plan systems',
      'Bathroom and kitchen second-fix',
      'Customer-facing communication',
      'Basic invoicing and parts ordering',
    ],
  ),
  CareerStage(
    stage: 'Time-served plumber',
    description:
        'NVQ Level 3 achieved. A fully qualified domestic plumber able to '
        'design, install, commission and hand over a complete hot, cold and '
        'central heating system to BS 6700 and the Water Regulations.',
    skills: [
      'Unvented hot water (G3) installation and commissioning',
      'Heating system design and balancing',
      'Pressure and soundness testing',
      'Customer handover and documentation',
    ],
  ),
  CareerStage(
    stage: 'Specialist engineer',
    description:
        'Holds additional tickets such as Gas Safe, OFTEC or MCS and works '
        'on regulated appliances. Often the lead engineer on a job, '
        'supervising apprentices and signing off on commissioning paperwork.',
    skills: [
      'Gas appliance servicing to ACS standards',
      'Heat-pump or solar-thermal commissioning',
      'Annual landlord safety inspections (CP12)',
      'Mentoring junior staff',
    ],
  ),
  CareerStage(
    stage: 'Master plumber / supervisor',
    description:
        'Ten or more years on the tools, often running a small firm or '
        'supervising a site team. Spends as much time on quoting, scheduling '
        'and quality control as on physical installation.',
    skills: [
      'Estimating and tendering',
      'Building Regulations Part G, L and P knowledge',
      'Team leadership and toolbox talks',
      'Defect investigation and expert reporting',
    ],
  ),
];

const qualifications = <Qualification>[
  Qualification(
    name: 'NVQ Level 2 Diploma in Plumbing and Heating',
    level: 'Foundation',
    summary:
        'The recognised entry qualification for domestic plumbers in the UK, '
        'usually completed alongside an apprenticeship.',
    requirements: [
      'Two years on-site experience or apprenticeship placement',
      'Portfolio of evidence covering cold water, hot water and central heating',
      'End-point synoptic assessment',
      'GCSE-equivalent Maths and English',
    ],
    body:
        'The Level 2 Diploma covers the core competencies a domestic plumber '
        'needs: cold water supply, hot water (vented), low-temperature hot '
        'water heating, above-ground discharge and sanitation. It is usually '
        'awarded by City and Guilds or BPEC and forms the foundation for '
        'progression to Level 3 and the various specialist tickets.',
  ),
  Qualification(
    name: 'NVQ Level 3 Diploma in Plumbing and Heating',
    level: 'Practising',
    summary:
        'The full domestic plumber qualification, required to be considered '
        '"time served" and to register with most competent person schemes.',
    requirements: [
      'Hold NVQ Level 2 or equivalent',
      'Further on-site portfolio including unvented and complex heating',
      'Practical and written assessments',
      'Successful synoptic end-point assessment',
    ],
    body:
        'Level 3 deepens design and fault-finding ability and adds notifiable '
        'work such as unvented hot water (G3), solar thermal and complex '
        'heating controls. Achieving Level 3 unlocks Gas Safe registration '
        'after the appropriate ACS assessments and is the usual gateway to '
        'self-employment.',
  ),
  Qualification(
    name: 'BPEC Unvented Hot Water (G3)',
    level: 'Specialist',
    summary:
        'A short certification that legally allows the holder to install and '
        'service unvented hot water cylinders under Building Regulation G3.',
    requirements: [
      'Existing Level 2 plumbing qualification or significant experience',
      'One-day course covering theory, discharge pipework and commissioning',
      'Practical and written assessment',
      'Renewal every five years',
    ],
    body:
        'Without G3 it is unlawful to commission an unvented system. The '
        'course covers expansion vessel sizing, pre-charge pressures, '
        'discharge pipework D1 and D2, the tundish requirement and the '
        'three-tier safety arrangement of thermostat, energy cut-out and '
        'temperature relief valve.',
  ),
  Qualification(
    name: 'City and Guilds 6189 / 6035',
    level: 'Foundation',
    summary:
        'College-based diplomas often used as a Level 2 stepping stone for '
        'learners not yet on an apprenticeship.',
    requirements: [
      'Full-time or part-time college enrolment',
      'Workshop assessments at the centre',
      'Functional skills in Maths and English',
    ],
    body:
        'The 6189 Diploma in Plumbing Studies is a classroom-and-workshop '
        'route favoured by school leavers. It carries the same theoretical '
        'weight as the NVQ Level 2 but lacks the on-site portfolio, so '
        'employment usually has to be secured before the qualification is '
        'fully recognised by the industry.',
  ),
  Qualification(
    name: 'Gas Safe registration (ACS)',
    level: 'Specialist',
    summary:
        'The legal requirement to work on natural gas or LPG appliances in '
        'the UK. Operatives are added to the Gas Safe Register after '
        'completing the Accredited Certification Scheme.',
    requirements: [
      'Underpinning plumbing or heating qualification',
      'CCN1 core domestic gas safety',
      'Appliance modules such as CENWAT, CKR1, HTR1, MET1',
      'Five-yearly reassessment',
    ],
    body:
        'ACS is the gatekeeper for gas work. CCN1 covers tightness testing, '
        'flueing, ventilation and unsafe situations. Appliance modules then '
        'add boilers, cookers, fires and meters. Working on gas without '
        'being on the register is a criminal offence under the Gas Safety '
        '(Installation and Use) Regulations.',
  ),
  Qualification(
    name: 'OFTEC oil-firing technician',
    level: 'Specialist',
    summary:
        'Equivalent of Gas Safe for oil-fired heating, including kerosene '
        'boilers and bulk storage tanks.',
    requirements: [
      'Existing plumbing or heating qualification',
      'OFT10-101 servicing and commissioning of oil-fired appliances',
      'OFT10-105E pressure-jet boilers',
      'Re-assessment every five years',
    ],
    body:
        'OFTEC registration is essential for rural properties off the gas '
        'grid. The technician course covers fuel-line installation, tank '
        'siting per OFTEC TI/133, combustion analysis with a flue-gas '
        'analyser, and the regulations around bunded storage.',
  ),
  Qualification(
    name: 'WRAS approved contractor',
    level: 'Practising',
    summary:
        'Demonstrates competence with the Water Supply (Water Fittings) '
        'Regulations 1999 and is required for many commercial water clients.',
    requirements: [
      'Pass the WRAS approved plumber assessment',
      'Annual continuing professional development',
      'Submit work for periodic audit',
    ],
    body:
        'WRAS approval focuses on backflow prevention, fluid categories one '
        'to five, and the correct selection of mechanical or air-gap devices. '
        'Many local authorities and large landlords will only employ WRAS '
        'approved plumbers for new connections.',
  ),
  Qualification(
    name: 'MCS heat-pump or solar accreditation',
    level: 'Specialist',
    summary:
        'The Microgeneration Certification Scheme covers low-carbon '
        'technologies and is required for customers to claim grant funding '
        'such as the Boiler Upgrade Scheme.',
    requirements: [
      'Underpinning heating qualification',
      'Manufacturer training on the specific technology',
      'Heat-loss calculation competence',
      'Quality-assured installation paperwork',
    ],
    body:
        'MCS-accredited installers must perform a room-by-room heat-loss '
        'calculation, design the system to MCS 035 or MIS 3001 and submit '
        'commissioning data to the MCS database. Without MCS the customer '
        'cannot access the Boiler Upgrade Scheme grant of up to seven '
        'thousand five hundred pounds.',
  ),
  Qualification(
    name: 'Water Regulations G3',
    level: 'Specialist',
    summary:
        'A targeted Building Regulations qualification specifically for '
        'unvented hot water — sometimes bundled with BPEC G3 above.',
    requirements: [
      'Existing plumbing competence',
      'Theory of expansion, safety devices and discharge pipework',
      'Practical commissioning assessment',
    ],
    body:
        'G3 of the Building Regulations is the legal mechanism through which '
        'unvented systems are notifiable. Anyone working on, replacing or '
        'commissioning such a cylinder must hold a current G3 ticket and '
        'either notify Building Control directly or work under a competent '
        'person scheme.',
  ),
  Qualification(
    name: 'IGEM commercial gas membership',
    level: 'Specialist',
    summary:
        'For engineers progressing into commercial and industrial gas work '
        'where pipe sizes, pressures and risk profiles are much greater.',
    requirements: [
      'Hold core domestic gas (CCN1) and operate on the register',
      'Commercial CODNCO1 then category-specific tickets such as ICPN1',
      'Membership of the Institution of Gas Engineers and Managers',
    ],
    body:
        'Commercial gas covers boiler houses, plant rooms and industrial '
        'kitchens with pipes up to several hundred millimetres diameter. '
        'IGEM publishes the standards used on these projects, such as '
        'IGE/UP/1 for tightness testing, and membership is a strong career '
        'signal in this sector.',
  ),
  Qualification(
    name: 'Building Regulations Part P (electrical)',
    level: 'Specialist',
    summary:
        'A short certification that allows a plumber to perform minor '
        'electrical work associated with their primary trade, such as wiring '
        'a boiler or replacing a thermostat.',
    requirements: [
      'Short course covering the IET Wiring Regulations basics',
      'Practical assessment of testing and inspection',
    ],
    body:
        'Part P of the Building Regulations governs domestic electrical '
        'work. A plumber with Part P can wire and test a fused spur for a '
        'boiler or pump, fit replacement room thermostats and complete the '
        'minor works certificate without calling in a separate electrician.',
  ),
];

const careerPaths = <CareerPath>[
  CareerPath(
    id: 'domestic',
    title: 'Domestic plumber',
    summary:
        'The classic high-street plumber, working on private homes — leaks, '
        'taps, bathrooms, boilers and emergency call-outs.',
    narrative:
        'Domestic plumbing is the broadest path. Work alternates between '
        'planned installations such as a new bathroom suite and reactive '
        'call-outs such as burst pipes after a frost. Success depends on '
        'breadth of skill, friendly customer service and the ability to '
        'price a job accurately on the doorstep.',
    dayInTheLife: [
      'Eight in the morning, drop in to swap a tap washer for a returning customer.',
      'Mid-morning, first-fix a new shower in a loft conversion, including a thermostatic mixer and dedicated cold supply.',
      'Lunchtime callout, a leaking radiator valve drained down and replaced.',
      'Afternoon, finish a bathroom second-fix and commission a new basin and toilet.',
      'End of day, write up invoices and order parts for tomorrow.',
    ],
    typicalEarnings: [
      'Apprentice or improver: fifteen to twenty-two thousand pounds per year.',
      'Time-served employed: thirty-two to forty thousand pounds per year.',
      'Self-employed established: forty-five to seventy thousand pounds per year before tax.',
    ],
  ),
  CareerPath(
    id: 'heating_engineer',
    title: 'Heating engineer',
    summary:
        'Specialist in central heating, boilers and renewable heat. Usually '
        'Gas Safe and often MCS accredited as well.',
    narrative:
        'Heating engineers focus on the warm side of the trade — boilers, '
        'cylinders, system design and fault diagnosis. Many add air-source '
        'heat pump or solar-thermal accreditation to ride the low-carbon '
        'transition. The role is more diagnostic and analytical than typical '
        'plumbing and rewards strong electrical and controls knowledge.',
    dayInTheLife: [
      'Service a combi boiler, including flue-gas analysis and a strip down of the diverter valve.',
      'Diagnose intermittent lockout on an S-plan, traced to a sticking motorised valve.',
      'Power-flush a heavily sludged radiator circuit and dose with inhibitor.',
      'Survey a property for an air-source heat-pump retrofit including room-by-room heat loss.',
      'Submit MCS commissioning paperwork from the previous installation.',
    ],
    typicalEarnings: [
      'Newly Gas-Safe registered: thirty-five to forty-two thousand pounds per year employed.',
      'Experienced heating engineer: forty-five to fifty-five thousand pounds per year.',
      'MCS-accredited self-employed: sixty thousand pounds upwards before tax.',
    ],
  ),
  CareerPath(
    id: 'bathroom_installer',
    title: 'Bathroom installer',
    summary:
        'A plumbing-led specialism that combines first-fix pipework with '
        'tiling, joinery and decorating to deliver complete bathroom suites.',
    narrative:
        'Bathroom installers often work alone or in pairs, taking a stripped-'
        'out room and turning it into a finished bathroom over a one to two '
        'week project. Strong commercial sense and a network of reliable '
        'tilers, electricians and plasterers are vital because the customer '
        'looks to the installer to coordinate the trade.',
    dayInTheLife: [
      'Strip out the existing suite and dispose of the old cast-iron bath.',
      'First-fix new hot, cold and waste runs to the planned bath, basin and WC positions.',
      'Liaise with the tiler on backing-board and tanking before the wall finishes go on.',
      'Second-fix the suite and shower screen, then commission and test for leaks.',
      'Walk the customer through their new bathroom and obtain final sign-off.',
    ],
    typicalEarnings: [
      'Per project: three to six thousand pounds labour for a standard family bathroom.',
      'Annual self-employed turnover: sixty to ninety thousand pounds before materials and tax.',
    ],
  ),
  CareerPath(
    id: 'commercial',
    title: 'Commercial and industrial plumber',
    summary:
        'Larger-scale work on offices, schools, hospitals and factories. '
        'Pipe sizes are bigger, materials more varied, and projects run for '
        'weeks rather than days.',
    narrative:
        'Commercial plumbing involves steel, cast-iron, press-fit and '
        'large-bore plastic pipework, often installed against tight '
        'programme dates. The plumber works as part of a wider mechanical '
        'team alongside ductwork fitters and controls engineers. Reading '
        'design drawings and clash-checking against other services becomes '
        'a daily task.',
    dayInTheLife: [
      'Attend the morning site briefing and pick up the days drawings.',
      'Press-fit chilled water pipework to thirty-five and forty-two millimetre stainless.',
      'Coordinate with the electrician on a pump-set wiring sequence.',
      'Witness a static pressure test on a riser before sign-off.',
      'Update the drawings with red-line as-built changes.',
    ],
    typicalEarnings: [
      'Improver on a commercial site: thirty-eight to forty-five thousand pounds per year.',
      'Approved commercial plumber on London rates: fifty to sixty thousand pounds per year.',
      'Foreman or charge-hand: sixty-five to seventy-five thousand pounds per year.',
    ],
  ),
  CareerPath(
    id: 'site_supervisor',
    title: 'Site supervisor',
    summary:
        'A management track for experienced plumbers — running the day-to-'
        'day works of a mechanical package on a construction project.',
    narrative:
        'The site supervisor oversees a team of plumbers and apprentices, '
        'manages safety, quality, programme and snagging, and is the daily '
        'point of contact with the main contractor. The role suits people '
        'who enjoy planning, paperwork and people management as much as the '
        'practical trade.',
    dayInTheLife: [
      'Lead a morning toolbox talk on permit-to-work for hot works.',
      'Walk the floors checking that yesterdays installations are clipped to spec.',
      'Issue requests for information when drawings clash with structure.',
      'Sit in on the weekly progress meeting with the main contractor.',
      'Update the lookahead programme and order materials for next week.',
    ],
    typicalEarnings: [
      'Junior site supervisor: forty-five to fifty-five thousand pounds per year.',
      'Senior or contracts-style supervisor: sixty to eighty thousand pounds per year.',
    ],
  ),
  CareerPath(
    id: 'inspector',
    title: 'Inspector or assessor',
    summary:
        'Inspecting installations for water boards, awarding bodies or '
        'building control — a quieter, paperwork-heavy career often taken '
        'later in life.',
    narrative:
        'Inspectors visit completed or in-progress installations and judge '
        'them against the regulations. Examples include WRAS inspectors '
        'auditing approved contractors, NVQ assessors signing off learner '
        'portfolios, and building-control surveyors checking notifiable '
        'work. The role draws on broad practical experience and good '
        'written communication.',
    dayInTheLife: [
      'Drive to a domestic site and witness an unvented commission.',
      'Complete the WRAS audit checklist on a new build connection.',
      'Sit in on a Level 3 candidates synoptic assessment as second marker.',
      'Write up reports and send sign-off paperwork to the awarding body.',
      'Catch up with continuing professional development reading.',
    ],
    typicalEarnings: [
      'Trainee assessor: thirty-five thousand pounds per year.',
      'Established inspector or assessor: forty-five to fifty-five thousand pounds per year.',
    ],
  ),
  CareerPath(
    id: 'sales_engineer',
    title: 'Technical sales engineer',
    summary:
        'A manufacturer-side career — advising specifiers, contractors and '
        'merchants on the right products for a given installation.',
    narrative:
        'Plumbing manufacturers prize sales engineers who genuinely '
        'understand systems, because architects and contractors quickly see '
        'through anyone who is purely a salesperson. The role is a mix of '
        'technical seminars, on-site troubleshooting, CPD presentations and '
        'closing high-value specifications. It usually involves a company '
        'car and significant travel.',
    dayInTheLife: [
      'Deliver a CPD seminar on heat-pump cylinders to a consultancy.',
      'Visit a building site to size an unvented system from the room schedule.',
      'Help a merchant counter-staff member resolve a warranty query.',
      'Demonstrate a new commissioning app to an installer team.',
      'Update the CRM with the days opportunities and quote follow-ups.',
    ],
    typicalEarnings: [
      'Junior technical sales engineer: thirty-eight to forty-five thousand pounds plus car.',
      'Senior or area sales manager: sixty to eighty thousand pounds plus bonus.',
    ],
  ),
  CareerPath(
    id: 'sole_trader',
    title: 'Self-employed sole trader',
    summary:
        'Running your own one-person plumbing business — the most popular '
        'long-term destination for time-served plumbers in the UK.',
    narrative:
        'Going self-employed swaps a steady wage for higher day-rates, more '
        'control and significant administrative overhead. The successful '
        'sole trader spends almost as long quoting, invoicing and chasing '
        'payment as turning spanners. Insurance, public liability cover and '
        'a competent person scheme membership are essential overheads.',
    dayInTheLife: [
      'Six in the morning, load the van and head to the first job.',
      'Two domestic call-outs before lunch, paid by card on the doorstep.',
      'Afternoon site visit to quote a kitchen replumb.',
      'Pop into the merchant for parts on the way home.',
      'Evening, an hour of paperwork: invoices, VAT and tomorrows schedule.',
    ],
    typicalEarnings: [
      'New sole trader: forty to fifty thousand pounds turnover, twenty-five to thirty-five thousand pounds take-home.',
      'Established sole trader: seventy to one hundred thousand pounds turnover, fifty thousand pounds plus take-home.',
    ],
  ),
];

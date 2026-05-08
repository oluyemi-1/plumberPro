import 'lessons_data.dart';

/// Lesson topics covering UK Medical Gas Pipeline Systems (MGPS) under
/// HTM 02-01 and BS EN ISO 7396-1. Aimed at plumbers and pipefitters
/// working towards the MGPS competent person qualification.
const medicalGasesLessonTopics = <LessonTopic>[
  LessonTopic(
    id: 'mgps_overview',
    title: 'Medical gas pipeline systems (MGPS)',
    category: 'Medical gases',
    summary:
        'Scope, gases carried, pipeline pressures and the framework of HTM 02-01.',
    sections: [
      LessonSection(
        'Scope of HTM 02-01',
        'The Health Technical Memorandum HTM 02-01 sets out the design, installation, validation and operational management of medical gas pipeline systems in healthcare premises in England. Part A covers design, installation, validation and verification, while Part B covers operational management. The technical pipeline standard underpinning HTM 02-01 is the harmonised European document BS EN ISO 7396-1, which lists requirements for pipework, source plant, terminal units and alarms. Together they form the legal and technical baseline for any medical gas installation in the UK National Health Service estate.',
      ),
      LessonSection(
        'Gases and pipeline pressures',
        'A typical UK MGPS carries oxygen, medical air at four bar, surgical air at seven bar, medical vacuum, anaesthetic gas scavenging, nitrous oxide, Entonox and carbon dioxide. Distribution pressures are tightly controlled. Oxygen, medical air, nitrous oxide, Entonox and carbon dioxide all run at a nominal four point one bar; surgical air runs at seven bar; medical vacuum is between minus thirty and minus fifty three kilopascals at the terminal; AGSS operates at a low induced negative pressure. Each gas has its own dedicated source, distribution and identification.',
      ),
      LessonSection(
        'Terminal units and gas specific connectors',
        'Patient outlets are gas specific terminal units to BS 5682 with a probe locking mechanism, and equipment connectors are non-interchangeable screw threads to EN ISO 9170-1, commonly known as NIST. The combination of unique mechanical key and unique thread prevents an oxygen probe being inserted into a nitrous oxide outlet, or a four bar device being connected to a seven bar surgical air supply. Every terminal unit must be labelled, gas tested, flow tested and identity verified before commissioning.',
      ),
      LessonSection(
        'Roles and responsibilities',
        'A hospital appoints an Authorised Person for Medical Gas Pipeline Systems, the AP MGPS, who manages day to day operation, permits to work and contractor oversight. A Designated Nurse and a Quality Controller for medical gases are also named. Above these sits a Designated Person at board level who is ultimately accountable. Any work on an MGPS, no matter how small, must be carried out under a permit to work issued by the AP MGPS, and only competent persons holding current qualifications and continuing professional development may be issued with that permit.',
      ),
    ],
  ),
  LessonTopic(
    id: 'mgps_pipework',
    title: 'MGPS pipework and jointing',
    category: 'Medical gases',
    summary:
        'Cleaned copper to BS EN 13348, brazing under nitrogen and identification to BS 1710.',
    sections: [
      LessonSection(
        'Pipework material',
        'Pipework for an MGPS is hard drawn phosphorus deoxidised copper to BS EN 13348, supplied degreased and capped at the factory and labelled medical gas. Standard sizes follow BS EN 1057 and run from twelve millimetre branches up to fifty four and seventy six millimetre risers. The pipe must remain capped until the moment a fitting is presented and must never be substituted with general plumbing copper, which is not certified clean for medical use and may contain residues that ignite in oxygen.',
      ),
      LessonSection(
        'Jointing by silver brazing',
        'Joints are made by silver brazing to BS EN 1044 with a copper phosphorus or silver copper filler rod, and crucially without flux. While brazing, an oxygen free nitrogen purge must flow through the bore of the pipe at one to five litres per minute to displace air. Nitrogen prevents the inside surface from forming black cupric oxide scale, which would otherwise flake off into the gas stream and choke regulators and terminal unit valves. The nitrogen purge is started before any heat is applied and continued until the joint has cooled.',
      ),
      LessonSection(
        'Identification and supports',
        'Pipework is identified using the BS 1710 quartered colour banding scheme. A continuous safety band gives the gas family, with bands of code colour at intervals indicating the specific gas and the direction of flow. Bands are applied at every junction, every terminal unit, every wall and floor penetration, and at intervals of around six metres in plant rooms. Pipe supports are non ferrous or plastic coated to BS EN 12099 distances; copper must not bear directly on bare ferrous brackets that could induce galvanic corrosion.',
      ),
      LessonSection(
        'Cleanliness and segregation',
        'Cleanliness is the cardinal rule of medical gas pipework. Hands must be free of oil and grease, gloves are worn, and tube ends are stored capped. Cuts are made with a clean tube cutter dedicated to MGPS work, never with an oily hacksaw, and the bore is reamed and inspected. Pipework must be segregated from general services in routing and labelling, and oxygen lines must be routed and supported so that fuel gas pipework cannot leak onto them.',
      ),
    ],
  ),
  LessonTopic(
    id: 'mgps_avsu',
    title: 'AVSU and emergency isolation',
    category: 'Medical gases',
    summary:
        'Area Valve Service Units, line and zone valves, alarms and the procedure for emergency shutdown.',
    sections: [
      LessonSection(
        'Purpose of an AVSU',
        'An Area Valve Service Unit is a single point of isolation for one clinical zone, fitted in a wall mounted lockable cabinet outside the area it serves. In an emergency, such as a fire or a serious leak, closing the AVSU isolates that zone in seconds without disturbing the rest of the hospital. AVSUs are required for each gas distributed into a department, and the cabinet contains a quarter turn ball valve, a pressure gauge upstream and downstream, and a connection to the alarm system that signals the valve state and the line pressure.',
      ),
      LessonSection(
        'Locking and labelling',
        'Each AVSU is held closed by a locking mechanism that requires a key, normally held by the AP MGPS or the duty estates officer, although a glass break or breakable security tag is acceptable on cabinets accessible to clinical staff for use in a true emergency. The cabinet door is labelled with the gas name, the area served and a clear instruction not to operate except in an emergency or under permit to work. A logbook records every operation of the valve.',
      ),
      LessonSection(
        'Line and zone valves',
        'Above the AVSU sits a line valve, which isolates a complete riser, and below it a zone valve may further subdivide the area. The hierarchy means a fault in one room can be isolated without losing supply to the whole department. All valves are full bore lever ball valves to a medical specification, with handles permanently attached. Single fault tolerance is a design principle: no single failure of a component should remove gas from a clinical area without warning.',
      ),
      LessonSection(
        'Emergency procedure',
        'In a true emergency the clinical staff in charge agree to isolation with the AP MGPS, alternative supply is arranged through cylinders for ventilated patients, and the valve is closed. The downstream gauge falls and the alarm panel raises an audible and visual alarm. Reinstatement is permitted only after the cause has been rectified, the area has been purged and tested, and the AP MGPS has signed a permit to work for return to service.',
      ),
    ],
  ),
  LessonTopic(
    id: 'mgps_validation',
    title: 'Commissioning and validation',
    category: 'Medical gases',
    summary:
        'Pressure, leak, cross connection, particulate and gas identity tests, with AP MGPS sign off.',
    sections: [
      LessonSection(
        'Pressure and leak tests',
        'Once pipework is installed and identified, the system is brought up to test pressure, typically one and a half times the working pressure, and held for the time set out in HTM 02-01. The first test confirms strength, with no joint failures. A subsequent leak test holds the pipework at working pressure for twenty four hours and the pressure decay must remain within the allowable limit calculated from the pipe volume. Pressure decay is corrected for changes in ambient temperature using a calibrated thermometer.',
      ),
      LessonSection(
        'Cross connection test',
        'Cross connection is the gravest hazard in an MGPS. After leak testing, every gas is independently pressurised in turn and every terminal unit on every other gas is checked for any pressure rise. Even a small movement of pressure indicates that two services are connected somewhere in the building and the system cannot be released for clinical use until the fault is found and rectified. The test is normally repeated by a second competent person to confirm the result.',
      ),
      LessonSection(
        'Particulate, gas identity and flow',
        'After cross connection has been ruled out, every terminal unit is flowed at the design flow to confirm capacity and to wash any debris through a particulate filter, which is then inspected against the specification. A gas identity test confirms that each terminal is delivering the correct gas, normally with a paramagnetic oxygen analyser and a calibrated multi gas analyser, sampling at the patient face. Vacuum systems are checked for vacuum level and aspirator flow at the terminal.',
      ),
      LessonSection(
        'Documentation and handover',
        'The AP MGPS witnesses the tests, signs the test schedules, and issues a Quality Test Certificate. The system is only released to clinical use under a formal permit to work that records the responsible engineer, the AP MGPS, and the date and time of release. Drawings and asset records are updated, the cylinder manifold is set up and labelled, and the clinical lead is briefed. The complete commissioning file is retained as part of the lifetime asset documentation.',
      ),
    ],
  ),
];

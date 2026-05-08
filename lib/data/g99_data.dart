/// Reference data for the G98 / G99 DNO connection process screens.
///
/// G98 covers single-phase generators up to 16 A per phase (typically small
/// PV systems, EV chargers and modest single-phase ASHPs with no export).
/// G99 covers anything above the G98 thresholds: larger single-phase units,
/// any three-phase generator/load that triggers DNO concern, and most heat
/// pumps over roughly 13 A starting current.
class GxxStage {
  final String title;
  final String description;
  final List<String> documents;
  const GxxStage({
    required this.title,
    required this.description,
    required this.documents,
  });

  String get speakable =>
      '$title. $description. Documents needed. ${documents.join(". ")}.';
}

class GxxDecision {
  final String question;
  final String yesPath;
  final String noPath;
  const GxxDecision({
    required this.question,
    required this.yesPath,
    required this.noPath,
  });
}

/// G98 fast-track / connect-and-notify route.
const g98Stages = <GxxStage>[
  GxxStage(
    title: '1. Confirm G98 eligibility',
    description:
        'The unit must be type-tested to EREC G98, single-phase, and not '
        'exceed 16 A per phase total at the connection point. Typical examples '
        'are a small domestic PV inverter or a small ASHP with no export.',
    documents: [
      'Manufacturer G98 type-test certificate',
      'Inverter or ASHP datasheet showing rated current',
      'Site single-line diagram',
    ],
  ),
  GxxStage(
    title: '2. Pre-installation check',
    description:
        'Confirm the existing service fuse rating, earthing arrangement and '
        'main switch capacity can accept the new load or generator without '
        'breaching diversity limits.',
    documents: [
      'Photograph of cut-out and meter tails',
      'EICR or recent installation certificate',
      'Maximum demand calculation',
    ],
  ),
  GxxStage(
    title: '3. Install and commission',
    description:
        'Carry out the install to BS 7671 and the manufacturer instructions. '
        'Commission the inverter or unit and record loss-of-mains, frequency '
        'and voltage protection settings as shipped.',
    documents: [
      'Electrical Installation Certificate',
      'Commissioning record',
      'Photographs of nameplate and MCB / RCD',
    ],
  ),
  GxxStage(
    title: '4. Notify the DNO within 28 days',
    description:
        'Submit the G98 installation document to the local DNO via their '
        'online portal. No prior approval is required, but the notification '
        'must be sent within 28 days of energisation.',
    documents: [
      'Completed ENA G98 installation document',
      'Type-test certificate copy',
      'Schematic of the as-installed system',
    ],
  ),
  GxxStage(
    title: '5. Hand over to the customer',
    description:
        'Provide the customer with the manufacturer manual, commissioning '
        'paperwork and a copy of the G98 notification. Register any MCS or '
        'BUS scheme paperwork if the install qualifies for grants.',
    documents: [
      'Customer handover pack',
      'MCS certificate (if applicable)',
      'Building Control / Gas Safe / NICEIC notification',
    ],
  ),
];

/// G99 application-and-approval route.
const g99Stages = <GxxStage>[
  GxxStage(
    title: '1. Pre-application enquiry',
    description:
        'Contact the DNO with site details, intended kW, phase arrangement '
        'and the manufacturer model. The DNO confirms whether a G99 '
        'application is required and which fast-track tier applies.',
    documents: [
      'Site address and MPAN',
      'Proposed unit datasheet',
      'Sketch of proposed connection point',
    ],
  ),
  GxxStage(
    title: '2. Submit ENA G99-1-1 application form',
    description:
        'Complete the G99-1-1 form with full technical data, schematic and '
        'protection settings. Pay the DNO assessment fee. The clock for the '
        'statutory response time starts when the DNO accepts the form.',
    documents: [
      'ENA G99-1-1 application form',
      'Full single-line diagram',
      'Type-test certificate (Type A, B, C or D as applicable)',
      'Manufacturer protection settings sheet',
    ],
  ),
  GxxStage(
    title: '3. DNO technical assessment',
    description:
        'The DNO models the network impact, looks at fault levels, voltage '
        'rise and reverse-power risk. They may request mitigation such as '
        'export limitation, transformer changes or earthing modifications.',
    documents: [
      'Network study response from DNO',
      'Any export-limitation device datasheet',
      'Revised single-line diagram if mitigations apply',
    ],
  ),
  GxxStage(
    title: '4. Offer of connection',
    description:
        'The DNO issues a formal Connection Offer stating cost, conditions '
        'and any reinforcement works. The customer accepts and pays before '
        'works can commence.',
    documents: [
      'Signed Connection Offer acceptance',
      'Payment receipt',
      'Agreed programme of works',
    ],
  ),
  GxxStage(
    title: '5. Install to agreed design',
    description:
        'Carry out the installation strictly in line with the accepted '
        'design. Any deviation must be re-submitted to the DNO before '
        'energisation.',
    documents: [
      'Electrical Installation Certificate',
      'As-installed schematic',
      'Cable and protection device schedule',
    ],
  ),
  GxxStage(
    title: '6. Commissioning and witness testing',
    description:
        'The DNO usually witnesses commissioning of the loss-of-mains, '
        'voltage and frequency protection. For Type A units a self-declared '
        'commissioning record is often acceptable; Type B and above almost '
        'always require a witnessed test.',
    documents: [
      'Witness test schedule',
      'Protection relay test results',
      'Commissioning record signed by DNO engineer',
    ],
  ),
  GxxStage(
    title: '7. Final certification and registration',
    description:
        'Submit the G99 commissioning confirmation, register the embedded '
        'generator on the DNO database, and lodge MCS / BUS paperwork if '
        'the installation qualifies for the Boiler Upgrade Scheme.',
    documents: [
      'G99 commissioning confirmation',
      'DNO embedded generator registration',
      'MCS certificate (if heat pump or PV)',
      'Building Control completion notice',
    ],
  ),
];

/// Decision tree that walks the user from project description to the correct
/// notification route. Each entry is presented one at a time; a "yes" answer
/// pushes the [yesPath] string onto the trace, "no" pushes [noPath].
const decisionTree = <GxxDecision>[
  GxxDecision(
    question:
        'Is the equipment a generator, energy-storage unit or a heat pump '
        'over about 13 A starting current?',
    yesPath: 'Notification is needed — keep going through the tree.',
    noPath:
        'No DNO notification is required for ordinary loads under 13 A. '
        'Carry out the install to BS 7671 only.',
  ),
  GxxDecision(
    question: 'Is the connection three-phase?',
    yesPath:
        'Three-phase connections always sit outside G98. You will need a '
        'G99 application even for modest sizes.',
    noPath:
        'Single-phase — keep checking the per-phase current limits below.',
  ),
  GxxDecision(
    question:
        'Does the total generation or import current at the connection '
        'point exceed 16 A per phase?',
    yesPath:
        'Above the G98 ceiling. A full G99 application to the DNO is '
        'required before commissioning.',
    noPath:
        'Within the G98 envelope so far. Continue with the inrush check.',
  ),
  GxxDecision(
    question:
        'Is the heat pump rated above roughly 5 kW input, or does the '
        'manufacturer quote a starting current above 16 A?',
    yesPath:
        'Inrush will breach the G98 limit. Lodge a G99 application; the '
        'DNO may permit Type A fast-track.',
    noPath:
        'Inrush is within G98 limits. Use the G98 connect-and-notify route.',
  ),
  GxxDecision(
    question:
        'Will the system export electricity to the grid (PV, battery, '
        'micro-CHP)?',
    yesPath:
        'Export pushes the project firmly into G99 territory above 16 A. '
        'Below 16 A and single-phase, G98 still applies.',
    noPath:
        'No export — keep the answer from the previous question. Many '
        'small ASHPs and EV chargers stay G98.',
  ),
  GxxDecision(
    question: 'Has the DNO already required a G99 application by letter?',
    yesPath:
        'Follow the G99 path regardless of the size — the DNO direction '
        'overrides the default thresholds.',
    noPath:
        'Apply the standard threshold logic above to choose between G98 '
        'and G99.',
  ),
  GxxDecision(
    question:
        'Are you proposing any reinforcement, transformer change or new '
        'service cable as part of the works?',
    yesPath:
        'Always G99 — reinforcement work needs a Connection Offer from '
        'the DNO before commencement.',
    noPath:
        'No reinforcement — the route is decided by the load and export '
        'answers above.',
  ),
];

import 'checklists_data.dart';

const commercialChecklists = <JobChecklist>[
  JobChecklist(
    id: 'comm_commissioning',
    title: 'Commercial commissioning',
    category: 'Commercial',
    summary:
        'A staged commissioning sequence for a typical commercial heating, cold water and DHW installation, witnessed and signed against BSRIA BG 29.',
    sections: [
      ChecklistSection(
        'System fill and chemical clean',
        [
          ChecklistItem(
            'Confirm system is fully installed, insulated and capped before fill',
            hint: 'Open ends or missing valves will lose flush chemicals.',
          ),
          ChecklistItem(
            'Fit and witness flushing bypasses across boilers and plate heat exchangers',
            hint: 'Boilers must be isolated during the dynamic flush.',
          ),
          ChecklistItem(
            'Carry out cold fill and dynamic flush to BSRIA BG 29',
            hint: 'Achieve flushing velocity of at least 1 m/s in every branch.',
          ),
          ChecklistItem(
            'Add cleaner and circulate at the chemical supplier dose and dwell time',
            hint: 'Typically 24 hours hot circulation for a degreasing cleanse.',
          ),
          ChecklistItem(
            'Drain, refill and final flush until water is clear and conductivity stable'),
          ChecklistItem(
            'Dose with inhibitor and biocide to manufacturer concentration',
            hint: 'Take a labelled sample for the O&M file.',
          ),
          ChecklistItem(
            'Take pre-handover water sample and send for independent analysis',
            hint: 'TVC, iron, copper, conductivity, pH.',
          ),
          ChecklistItem(
            'Update flushing certificate and BG 29 record sheet'),
        ],
      ),
      ChecklistSection(
        'Hydraulic pressure test',
        [
          ChecklistItem(
            'Confirm test medium and test pressure with the consultant',
            hint: 'Normally 1.5 x working pressure for at least one hour.',
          ),
          ChecklistItem(
            'Isolate pressure-limited components such as expansion vessels and PRVs',
          ),
          ChecklistItem(
            'Apply test pressure with a calibrated test pump and gauge',
            hint: 'Calibration certificate to be in the witness pack.',
          ),
          ChecklistItem(
            'Hold pressure and inspect every joint with no measurable drop',
          ),
          ChecklistItem(
            'Witness with consultant or clerk of works and sign certificate',
          ),
          ChecklistItem(
            'Release pressure safely back to working pressure',
          ),
          ChecklistItem(
            'Record ambient and water temperatures at start and end of test',
            hint: 'Temperature swings can mask a small leak.',
          ),
        ],
      ),
      ChecklistSection(
        'Boiler / chiller commissioning',
        [
          ChecklistItem('Confirm gas, electrical and flue installations are signed off'),
          ChecklistItem(
            'Verify minimum primary flow rate through each boiler',
            hint: 'Below this the heat exchanger can boil locally.',
          ),
          ChecklistItem(
            'Witness manufacturer commissioning of each boiler / chiller',
            hint: 'Manufacturer engineer present, certificates issued.',
          ),
          ChecklistItem(
            'Set cascade sequencing strategy and lead-boiler rotation',
          ),
          ChecklistItem(
            'Set weather compensation curve and verify response on rig',
          ),
          ChecklistItem(
            'Test all safety interlocks: high limit, low water, flue overheat',
          ),
          ChecklistItem(
            'Check pressurisation unit cut-in, cut-out and low-pressure alarm',
          ),
          ChecklistItem(
            'Log flue gas analysis and ratio at high and low fire',
          ),
        ],
      ),
      ChecklistSection(
        'Booster set commissioning',
        [
          ChecklistItem(
            'Confirm break tank capacity, lid seals, screened overflow and warning pipe',
          ),
          ChecklistItem(
            'Check incoming float / solenoid valve operation and shut-off',
          ),
          ChecklistItem(
            'Verify pump rotation and flexible coupling alignment',
          ),
          ChecklistItem(
            'Set duty pressure and minimum off-pressure on the controller',
          ),
          ChecklistItem(
            'Verify duty / standby / assist sequencing under stepped flow demand',
            hint: 'Use the test rig or open multiple outlets in turn.',
          ),
          ChecklistItem(
            'Test dry-run protection and high-pressure cut-out',
          ),
          ChecklistItem(
            'Confirm BMS volt-free contacts: run, fault, pump-rotation alarm',
          ),
          ChecklistItem('Record run-hour balancing setting in commissioning log'),
        ],
      ),
      ChecklistSection(
        'Calorifier / DHW commissioning',
        [
          ChecklistItem(
            'Confirm safety group: PRV, expansion relief, T&P, tundish',
            hint: 'Tundish visible and discharge route to terminate safely.',
          ),
          ChecklistItem(
            'Set storage temperature to 60 °C and verify on dial and BMS',
          ),
          ChecklistItem(
            'Balance secondary return loops to maintain 55 °C minimum on each leg',
          ),
          ChecklistItem(
            'Time delivery to 50 °C at sentinel outlets within one minute',
          ),
          ChecklistItem(
            'Witness pasteurisation cycle if specified, recording temperatures',
          ),
          ChecklistItem(
            'Set TMV outlet temperatures and record fail-safe shut-off times',
          ),
          ChecklistItem(
            'Issue unvented G3 commissioning certificate',
          ),
        ],
      ),
      ChecklistSection(
        'BMS verification',
        [
          ChecklistItem(
            'Walk the points list with the controls engineer for every plumbing point',
          ),
          ChecklistItem(
            'Verify each sensor reads correctly against a calibrated reference',
          ),
          ChecklistItem(
            'Drive each motorised valve fully open and fully closed from the BMS',
          ),
          ChecklistItem(
            'Confirm pump enable, run-status and fault signalling on every header',
          ),
          ChecklistItem(
            'Test high and low pressure alarms back to the front end',
          ),
          ChecklistItem(
            'Witness sequence of operation against the design specification',
          ),
          ChecklistItem(
            'Sign off the cause-and-effect schedule with the consultant',
          ),
        ],
      ),
      ChecklistSection(
        'Hand-over and O&M docs',
        [
          ChecklistItem(
            'Compile O&M manual: as-installed drawings, data sheets, certificates',
            hint: 'Two hard copies and one electronic copy to BSRIA BG 29.',
          ),
          ChecklistItem(
            'Provide flushing, water-treatment and pressure-test certificates',
          ),
          ChecklistItem(
            'Issue Gas Safe and unvented G3 certificates as relevant',
          ),
          ChecklistItem(
            'Hand over labelled keys and any specialist tools',
          ),
          ChecklistItem(
            'Record final inhibitor concentration and dose chart',
          ),
          ChecklistItem(
            'Programme defects-period revisits at three, six and twelve months',
          ),
          ChecklistItem(
            'Obtain client signature on practical completion certificate',
          ),
        ],
      ),
    ],
  ),
  JobChecklist(
    id: 'comm_l8_monthly',
    title: 'L8 monthly inspection',
    category: 'Commercial',
    summary:
        'Routine monthly water hygiene inspection task list for the named Responsible Person under HSE ACoP L8 and HSG 274 Part 2.',
    sections: [
      ChecklistSection(
        'Cold storage tanks',
        [
          ChecklistItem(
            'Visually inspect tank externally for damage, leaks and insulation integrity',
          ),
          ChecklistItem(
            'Confirm screened overflow, warning pipe and lid seals are intact',
          ),
          ChecklistItem(
            'Record cold water inlet and outlet temperatures',
            hint: 'Outlet should be below 20 °C.',
          ),
          ChecklistItem(
            'Note any sediment, biofilm or vermin ingress for action',
          ),
          ChecklistItem(
            'Confirm float / solenoid valve operating and not leaking by',
          ),
        ],
      ),
      ChecklistSection(
        'Hot water storage',
        [
          ChecklistItem(
            'Record calorifier flow and return temperatures',
            hint: 'Flow at 60 °C, return not below 55 °C.',
          ),
          ChecklistItem(
            'Drain a small sample from the calorifier drain cock and inspect for sludge',
          ),
          ChecklistItem(
            'Visually check insulation, jacket and pipework for damage',
          ),
          ChecklistItem(
            'Confirm secondary circulator running and balanced',
          ),
          ChecklistItem(
            'Record any unvented safety device discharge or weeping',
          ),
        ],
      ),
      ChecklistSection(
        'Outlets',
        [
          ChecklistItem(
            'Run nearest and furthest sentinel hot outlets and time to 50 °C',
          ),
          ChecklistItem(
            'Run nearest and furthest sentinel cold outlets and time to below 20 °C',
          ),
          ChecklistItem(
            'Flush low-use outlets for several minutes and record',
          ),
          ChecklistItem(
            'Inspect spray fittings and tap aerators for limescale and replace as needed',
          ),
          ChecklistItem(
            'Record any newly capped outlets or new dead legs spotted',
          ),
        ],
      ),
      ChecklistSection(
        'Showers and TMVs',
        [
          ChecklistItem(
            'Strip and clean showerheads and hoses on a defined rotation',
            hint: 'Quarterly minimum, more often where biofilm is found.',
          ),
          ChecklistItem(
            'Run shower outlets to flush, recording mixed temperature',
          ),
          ChecklistItem(
            'Carry out monthly TMV mixed temperature check on vulnerable-user mixers',
          ),
          ChecklistItem(
            'Test TMV fail-safe by isolating cold and confirming hot shut-off',
          ),
          ChecklistItem(
            'Record any TMV drift outside set tolerance for service action',
          ),
        ],
      ),
      ChecklistSection(
        'Records and recommendations',
        [
          ChecklistItem(
            'Update the site logbook with all readings, dated and signed',
          ),
          ChecklistItem(
            'Flag any out-of-control readings to the duty-holder same day',
          ),
          ChecklistItem(
            'Raise remedial work orders for defects found this visit',
          ),
          ChecklistItem(
            'Confirm next monthly visit and any additional sampling needed',
          ),
          ChecklistItem(
            'File records to be retained for at least five years',
          ),
        ],
      ),
    ],
  ),
  JobChecklist(
    id: 'comm_handover',
    title: 'Soft Landings hand-over',
    category: 'Commercial',
    summary:
        'A BSRIA Soft Landings aligned hand-over for the plumbing and mechanical package, including aftercare and post-occupancy review.',
    sections: [
      ChecklistSection(
        'Documentation',
        [
          ChecklistItem(
            'Issue O&M manual structured to BSRIA BG 29 and BG 79',
          ),
          ChecklistItem(
            'Provide as-installed drawings, schematics and valve schedules',
          ),
          ChecklistItem(
            'Include all commissioning, flushing and water-sample certificates',
          ),
          ChecklistItem(
            'Hand over the L8 risk assessment, written scheme and asset register',
          ),
          ChecklistItem(
            'Provide manufacturer warranty certificates and start-of-cover dates',
          ),
        ],
      ),
      ChecklistSection(
        'Training',
        [
          ChecklistItem(
            'Train FM team on plant start-up, shut-down and isolation routines',
          ),
          ChecklistItem(
            'Cover normal operating ranges, alarms and first-line fault finding',
          ),
          ChecklistItem(
            'Walk through the L8 written scheme with the named Responsible Person',
          ),
          ChecklistItem(
            'Demonstrate BMS front end navigation and alarm acknowledgement',
          ),
          ChecklistItem(
            'Issue training attendance records into the Soft Landings file',
          ),
        ],
      ),
      ChecklistSection(
        'Demonstrations',
        [
          ChecklistItem(
            'Demonstrate cascade boiler sequence under stepped load',
          ),
          ChecklistItem(
            'Demonstrate booster set duty / standby / assist transitions',
          ),
          ChecklistItem(
            'Demonstrate DHW pasteurisation cycle if installed',
          ),
          ChecklistItem(
            'Demonstrate emergency stop and re-start procedures',
          ),
          ChecklistItem(
            'Demonstrate make-up water isolation and tank emergency response',
          ),
        ],
      ),
      ChecklistSection(
        'Aftercare',
        [
          ChecklistItem(
            'Agree initial aftercare period, typically the first year of occupation',
          ),
          ChecklistItem(
            'Programme aftercare visits at 1, 3, 6 and 12 months',
          ),
          ChecklistItem(
            'Provide a single point of contact for the FM team during aftercare',
          ),
          ChecklistItem(
            'Review BMS trends each visit to retune setpoints and schedules',
          ),
          ChecklistItem(
            'Log all defects and improvement opportunities into the lessons learned register',
          ),
        ],
      ),
      ChecklistSection(
        'BSRIA Soft Landings post-occupancy review',
        [
          ChecklistItem(
            'Carry out structured POE survey with end users at around 9 months',
          ),
          ChecklistItem(
            'Compare measured energy and water use against design targets',
          ),
          ChecklistItem(
            'Review L8 monitoring records for trend issues',
          ),
          ChecklistItem(
            'Hold a Soft Landings review workshop with client, designer and contractor',
          ),
          ChecklistItem(
            'Issue final POE report and capture lessons learned for future projects',
          ),
        ],
      ),
    ],
  ),
];

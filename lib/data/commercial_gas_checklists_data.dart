import 'checklists_data.dart';

const commercialGasChecklists = <JobChecklist>[
  JobChecklist(
    id: 'comm_gas_install',
    title: 'Commercial gas pipework installation',
    category: 'Commercial gas',
    summary:
        'Field checklist for installing and handing over commercial natural gas pipework to IGEM/UP/2, BS 6891 and BS 1710.',
    sections: <ChecklistSection>[
      ChecklistSection(
        'Materials and supports',
        <ChecklistItem>[
          ChecklistItem('Verify steel tube to BS EN 10255 heavy grade for welded or screwed mains'),
          ChecklistItem('Verify copper to BS EN 1057 with brazed joints for branch runs'),
          ChecklistItem(
            'Confirm any press-fit fittings are gas-approved (Geberit Mapress G or Viega Profipress G)',
            hint: 'Check current Kitemark and yellow O-ring colour code',
          ),
          ChecklistItem('Brackets at maximum 2.0 to 3.0 m for 50 mm horizontal steel runs'),
          ChecklistItem('Closer spacing on vertical drops; anchors either side of expansion devices'),
          ChecklistItem('Sleeves through walls and floors with fire-stopping at compartments'),
        ],
      ),
      ChecklistSection(
        'Jointing and isolation',
        <ChecklistItem>[
          ChecklistItem('Threaded joints sealed with approved gas-rated PTFE or Loctite 577'),
          ChecklistItem('Welded joints by coded welder with current procedure qualification record'),
          ChecklistItem('Press-fit joints fully inserted and pressed with calibrated tool', hint: 'Mark each joint after pressing'),
          ChecklistItem('Lever-handle ball valves at meter outlet and each appliance branch'),
          ChecklistItem('Lockable AECVs at plant-room and kitchen entry points'),
          ChecklistItem('Test points fitted upstream and downstream of every regulator'),
        ],
      ),
      ChecklistSection(
        'Identification and bonding',
        <ChecklistItem>[
          ChecklistItem('Pipework painted ochre yellow with GAS lettering and flow arrows to BS 1710'),
          ChecklistItem('Labels on isolation valves indicating area served'),
          ChecklistItem('Main protective bonding 10 mm2 within 600 mm of meter outlet'),
          ChecklistItem('Earth label fitted: Safety Electrical Connection Do Not Remove'),
          ChecklistItem('Plant-room signage at each entrance: Gas Plant Room, No Naked Lights'),
          ChecklistItem('Hazardous-area zoning drawings issued where IGEM/UP/16 zones apply'),
        ],
      ),
      ChecklistSection(
        'Hand-over',
        <ChecklistItem>[
          ChecklistItem('Strength and tightness test passed and recorded'),
          ChecklistItem('System purged through and let through to appliances'),
          ChecklistItem('As-built schematic, valve schedule and risk assessment issued'),
          ChecklistItem('Operative ACS card numbers (COCNGI1, ICPN1, TPCP1) recorded on certificate'),
          ChecklistItem('Client briefed on emergency isolation and dial-before-you-dig'),
        ],
      ),
    ],
  ),
  JobChecklist(
    id: 'comm_gas_tightness_test',
    title: 'IGEM/UP/1 tightness test record',
    category: 'Commercial gas',
    summary:
        'Step-by-step field record for performing strength and tightness tests on commercial LP and MP pipework to IGEM/UP/1 and UP/1A.',
    sections: <ChecklistSection>[
      ChecklistSection(
        'Pre-test preparation',
        <ChecklistItem>[
          ChecklistItem('Notify duty holder and place permit-to-work in force'),
          ChecklistItem('Isolate appliances at AECV and cap or plug as required'),
          ChecklistItem('Confirm test pressure based on MOP and procedure (UP/1 or UP/1A)'),
          ChecklistItem('Calibration certificate for electronic gauge in date', hint: '0.1 mbar resolution at LP'),
          ChecklistItem('Record ambient temperature and barometric pressure at start'),
          ChecklistItem('Connect test pump and gauge at the agreed test point'),
        ],
      ),
      ChecklistSection(
        'Test sequence',
        <ChecklistItem>[
          ChecklistItem('Strength test at 1.5 x MOP using air or nitrogen for new pipework'),
          ChecklistItem('Stabilisation period observed in line with installation volume'),
          ChecklistItem('Let-by test: confirm zero rise on gauge'),
          ChecklistItem('Tightness test at operating pressure (typically 21 mbar at LP) for the prescribed duration'),
          ChecklistItem('Record start pressure, end pressure and any temperature change'),
          ChecklistItem('Compare actual drop against calculated allowable for volume and time'),
        ],
      ),
      ChecklistSection(
        'Failure response',
        <ChecklistItem>[
          ChecklistItem('Do not put system into use if test fails'),
          ChecklistItem('Locate leak with approved LDF or electronic detector'),
          ChecklistItem('Repair joint or component using correct technique'),
          ChecklistItem('Re-purge as needed and repeat full test sequence'),
          ChecklistItem('Update test record with all attempts and final pass'),
        ],
      ),
      ChecklistSection(
        'Certification',
        <ChecklistItem>[
          ChecklistItem('Complete tightness test certificate with installation details'),
          ChecklistItem('Record gauge make, model, serial number and calibration date'),
          ChecklistItem('Sign and stamp with ACS operative reference (TPCP1, COCNGI1)'),
          ChecklistItem('Issue copy to duty holder and retain master in plant log book'),
          ChecklistItem('Update gas safety record on site'),
        ],
      ),
    ],
  ),
  JobChecklist(
    id: 'comm_gas_commission',
    title: 'Commercial gas appliance commissioning (IGEM/UP/4)',
    category: 'Commercial gas',
    summary:
        'Commissioning checklist for commercial gas appliances under IGEM/UP/4, including FGA, interlocks and hand-over.',
    sections: <ChecklistSection>[
      ChecklistSection(
        'Pre-firing checks',
        <ChecklistItem>[
          ChecklistItem('Confirm tightness test passed and certificate available'),
          ChecklistItem('Verify ventilation free area or mechanical airflow proven'),
          ChecklistItem('Check flue continuity, terminal location and clearance'),
          ChecklistItem('Confirm electrical supply, polarity and earth continuity'),
          ChecklistItem('Inspect water-side fill, vent and pressurisation set to 1.5 bar cold'),
          ChecklistItem('Confirm gas inlet working pressure 21 mbar at LP under no-flow'),
        ],
      ),
      ChecklistSection(
        'Light-up and combustion',
        <ChecklistItem>[
          ChecklistItem('Calibrated FGA in date, with fresh probe filter'),
          ChecklistItem('Light boiler at low fire and verify ignition sequence'),
          ChecklistItem('Adjust gas valve to manufacturer setting; ratio controller for modulating units'),
          ChecklistItem('Confirm working pressure under full load remains within tolerance', hint: 'Typically 19 to 21 mbar'),
          ChecklistItem('Combustion at high fire: CO2 8.7 to 9.2 percent natural gas, CO ratio under 0.004'),
          ChecklistItem('Repeat at low fire and record both readings on commissioning sheet'),
        ],
      ),
      ChecklistSection(
        'Safety interlocks',
        <ChecklistItem>[
          ChecklistItem('Test gas-pressure proving system and verify green-light operation'),
          ChecklistItem('Simulate extract failure and confirm gas solenoid closes within seconds'),
          ChecklistItem('Test high-level gas detector at 20 percent LEL test gas'),
          ChecklistItem('Operate emergency stop button at each kitchen exit and at plant-room door'),
          ChecklistItem('Verify BMS alarm raised and reset only by authorised key'),
          ChecklistItem('Check fire-suppression interface drops gas and signals BMS'),
        ],
      ),
      ChecklistSection(
        'Hand-over and records',
        <ChecklistItem>[
          ChecklistItem('Demonstrate normal start, stop and emergency isolation to client'),
          ChecklistItem('Issue Benchmark or manufacturer commissioning sheet signed and dated'),
          ChecklistItem('Complete IGEM/UP/4 commissioning record and gas safety inspection sheet'),
          ChecklistItem('Enter all readings and tests in the plant-room log book'),
          ChecklistItem('Provide O&M manual and confirm service interval to duty holder'),
        ],
      ),
    ],
  ),
];

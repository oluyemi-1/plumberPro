import 'checklists_data.dart';

/// MCS-aligned commissioning checklists for heat pump installs.
const heatPumpChecklists = <JobChecklist>[
  JobChecklist(
    id: 'hp_design_predeploy',
    title: 'Heat pump design and pre-deploy',
    category: 'Heat pump',
    summary:
        'Sign-off pack before the install team starts. Covers MCS design pack, MCS 020 sound and electrical / planning checks.',
    sections: [
      ChecklistSection('Heat loss and emitter design', [
        ChecklistItem('Room-by-room heat loss calculated against the local design OAT',
            hint: 'CIBSE typically -2°C SE England, -3 to -5°C further north.'),
        ChecklistItem('Air change rate per room logged (ACH)',
            hint: '1.0 bedrooms, 1.5 lounge, 2.0 kitchen and bathroom.'),
        ChecklistItem('Design indoor temperatures recorded',
            hint: '21°C lounge, 18°C bedrooms, 22°C bathroom.'),
        ChecklistItem('Emitter schedule produced at the design flow temperature',
            hint: 'Typically 45°C flow, 40°C return, mean water 42.5°C.'),
        ChecklistItem('Existing radiator outputs corrected and any upsize identified',
            hint: 'Output at lower Δt = rating × (Δt / 50)^1.30.'),
      ]),
      ChecklistSection('Hot water', [
        ChecklistItem('Cylinder selected with HP-rated coil surface area',
            hint: 'Typically 3.0 m² minimum coil for a domestic ASHP cylinder.'),
        ChecklistItem('Cylinder volume sized to peak demand'),
        ChecklistItem('Legionella cycle method confirmed (immersion or HP set-point lift)'),
        ChecklistItem('Secondary circulation considered if dead-leg over 12 m'),
      ]),
      ChecklistSection('Sound — MCS 020', [
        ChecklistItem('Outdoor unit sound power level (Lw) confirmed from data plate'),
        ChecklistItem('Distance to nearest neighbour assessment position measured'),
        ChecklistItem('Reflection corrections applied (free field, hard surface, corner)'),
        ChecklistItem('Lp at the assessment position calculated and ≤ 42 dB(A)'),
        ChecklistItem('MCS 020 certificate filed in the design pack'),
      ]),
      ChecklistSection('Electrical and DNO', [
        ChecklistItem('Dedicated circuit, RCBO selected per IET BS 7671'),
        ChecklistItem('Earth fault loop impedance and Zs limit confirmed'),
        ChecklistItem('G98 / G99 notification submitted to DNO if required',
            hint: 'G99 above 16 A per phase or any export connection.'),
        ChecklistItem('Surge protection device fitted (recommended for HP electronics)'),
      ]),
      ChecklistSection('Planning and consent', [
        ChecklistItem('Permitted Development criteria assessed (size, distance, listed)'),
        ChecklistItem('Neighbour communication completed if marginal sound'),
        ChecklistItem('Customer signed acceptance of design pack'),
      ]),
    ],
  ),
  JobChecklist(
    id: 'hp_mechanical_install',
    title: 'Heat pump mechanical installation',
    category: 'Heat pump',
    summary:
        'On-site install — outdoor unit, hydraulic separation, refrigerant integrity (split only), filling, venting and pressure test.',
    sections: [
      ChecklistSection('Outdoor unit', [
        ChecklistItem('Plinth or wall bracket level and rated for unit weight'),
        ChecklistItem('Anti-vibration mounts fitted between unit and base'),
        ChecklistItem('Clearances per manufacturer (front, rear, sides, top)'),
        ChecklistItem('Condensate drain to soakaway or surface water drain, frost-protected',
            hint: 'Never to foul, and never via a long unheated external run.'),
      ]),
      ChecklistSection('Refrigerant pipework (split systems only)', [
        ChecklistItem('Pipework sized to manufacturer length and lift limits'),
        ChecklistItem('Brazing under nitrogen purge to prevent oxide scale'),
        ChecklistItem('Pressure tested with dry nitrogen to manufacturer pressure'),
        ChecklistItem('Vacuum to ≤ 250 microns and held for 30 minutes'),
        ChecklistItem('Refrigerant added to specified weight, recorded on F-gas log'),
        ChecklistItem('Electronic leak detection and bubble solution at each joint'),
      ]),
      ChecklistSection('Hydraulic separation', [
        ChecklistItem('Volumiser, low-loss header or buffer tank fitted as designed'),
        ChecklistItem('Magnetic filter on return',
            hint: 'Protects HP plate exchanger from existing system debris.'),
        ChecklistItem('Secondary pump matched to emitter circuit'),
      ]),
      ChecklistSection('Hydraulic commissioning', [
        ChecklistItem('System filled with treated water'),
        ChecklistItem('Inhibitor dosed at 1 L per 100 L system volume'),
        ChecklistItem('System hydrostatic test at 1.5 × max working pressure for 30 min'),
        ChecklistItem('Air vented at all high points and AAV functional'),
        ChecklistItem('Sealed system pressure set 1.0 to 1.5 bar cold'),
        ChecklistItem('Each radiator balanced via lockshield, ΔT recorded'),
      ]),
    ],
  ),
  JobChecklist(
    id: 'hp_commission_handover',
    title: 'Heat pump commissioning and hand-over',
    category: 'Heat pump',
    summary:
        'Final electrical, controls, performance test, paperwork and customer demonstration.',
    sections: [
      ChecklistSection('Electrical commissioning', [
        ChecklistItem('Polarity, continuity, insulation resistance and Zs measured and recorded'),
        ChecklistItem('RCD trip time within Part P / BS 7671 limits'),
        ChecklistItem('Minor works or installation certificate issued'),
      ]),
      ChecklistSection('Controls and weather compensation', [
        ChecklistItem('Heating curve set to design flow temp at design OAT'),
        ChecklistItem('Room thermostat sited away from drafts and direct heat'),
        ChecklistItem('DHW priority and Legionella schedule configured'),
        ChecklistItem('Smart functions configured, time and date set, schedules saved'),
      ]),
      ChecklistSection('Performance test', [
        ChecklistItem('Heat pump runs for at least 30 minutes under load'),
        ChecklistItem('Flow temperature stable at design ± 2 K'),
        ChecklistItem('System ΔT 4 to 6 K across the heat pump'),
        ChecklistItem('Sound at neighbour boundary measured ≤ 42 dB(A) under normal operation'),
      ]),
      ChecklistSection('Documentation', [
        ChecklistItem('Benchmark commissioning record fully completed'),
        ChecklistItem('MCS commissioning sheet completed and uploaded'),
        ChecklistItem('BUS grant claim raised if applicable'),
        ChecklistItem('Customer hand-over pack including manuals and warranty'),
        ChecklistItem('Customer demonstrated controls, weather compensation and DHW boost'),
      ]),
    ],
  ),
];

/// Medical gases reference data aligned with HTM 02-01 and BS EN ISO 7396-1.
///
/// Each entry summarises the working pressure, test pressure, terminal unit
/// standard, clinical use and key hazards for the most common piped medical
/// gases found in UK hospitals.
class MedicalGas {
  final String name;
  final String formula;
  final int colourArgb;
  final double workingPressureBar;
  final double testPressureBar;
  final String terminalUnit;
  final String use;
  final String hazards;
  const MedicalGas({
    required this.name,
    required this.formula,
    required this.colourArgb,
    required this.workingPressureBar,
    required this.testPressureBar,
    required this.terminalUnit,
    required this.use,
    required this.hazards,
  });

  String get speakable =>
      '$name. Working pressure $workingPressureBar bar. Use. $use. Hazards. $hazards';
}

const medicalGases = <MedicalGas>[
  MedicalGas(
    name: 'Oxygen',
    formula: 'O2',
    colourArgb: 0xFFFFFFFF,
    workingPressureBar: 4.1,
    testPressureBar: 7.0,
    terminalUnit: 'BS 5682 / EN ISO 9170-1',
    use:
        'Life-supporting gas for resuscitation, ventilation, anaesthesia and routine therapy across wards and theatres.',
    hazards:
        'Strongly oxidising. Greatly increases fire intensity in an enriched atmosphere. Keep away from oils, greases and combustibles, and segregate from fuel gases.',
  ),
  MedicalGas(
    name: 'Medical air 4 bar',
    formula: 'Air',
    colourArgb: 0xFFD9D9D9,
    workingPressureBar: 4.1,
    testPressureBar: 7.0,
    terminalUnit: 'BS 5682 / EN ISO 9170-1',
    use:
        'Driving gas for ventilators and nebulisers, and a clean breathing supply where oxygen enrichment is not required.',
    hazards:
        'Pressurised cylinder hazards. Risk of cross connection with oxygen if terminal units or NIST connectors are not correct. Quality must meet BP grade.',
  ),
  MedicalGas(
    name: 'Surgical air 7 bar',
    formula: 'Air 7',
    colourArgb: 0xFFB7B7B7,
    workingPressureBar: 7.0,
    testPressureBar: 10.5,
    terminalUnit: 'BS 5682 / EN ISO 9170-1',
    use:
        'High pressure clean air to drive surgical tools such as orthopaedic saws, drills and dermatomes in theatres.',
    hazards:
        'High stored energy. Never substitute for 4 bar medical air at a patient connection. Tools require dedicated 7 bar terminal units to prevent cross use.',
  ),
  MedicalGas(
    name: 'Vacuum',
    formula: 'Vac',
    colourArgb: 0xFFF7E27A,
    workingPressureBar: -0.4,
    testPressureBar: -0.6,
    terminalUnit: 'BS 5682 / EN ISO 9170-1',
    use:
        'Continuous medical suction for theatres, recovery, wards and ICU. Drains airway secretions, blood and irrigation fluid.',
    hazards:
        'Risk of contaminated aerosol if collection jars overflow. Bacterial filters must be in date and the receiver isolated before service.',
  ),
  MedicalGas(
    name: 'AGSS',
    formula: 'AGSS',
    colourArgb: 0xFFB388EB,
    workingPressureBar: -0.05,
    testPressureBar: -0.1,
    terminalUnit: 'BS 6834 AGSS terminal',
    use:
        'Anaesthetic Gas Scavenging System. Removes waste anaesthetic gases from the breathing system to protect theatre staff.',
    hazards:
        'Must remain at low negative pressure only. Never connect to high vacuum. Discharge to atmosphere away from intakes and openings.',
  ),
  MedicalGas(
    name: 'Nitrous oxide',
    formula: 'N2O',
    colourArgb: 0xFF1976D2,
    workingPressureBar: 4.1,
    testPressureBar: 7.0,
    terminalUnit: 'BS 5682 / EN ISO 9170-1',
    use:
        'Anaesthetic adjunct delivered via the anaesthetic machine. Provides analgesia and reduces volatile agent dose.',
    hazards:
        'Asphyxiant if leaked into a confined space. Chronic exposure harms staff. Risk of misuse and recreational diversion. Cylinders must be secured.',
  ),
  MedicalGas(
    name: 'Entonox',
    formula: '50/50',
    colourArgb: 0xFF2196F3,
    workingPressureBar: 4.1,
    testPressureBar: 7.0,
    terminalUnit: 'BS 5682 / EN ISO 9170-1',
    use:
        'Pre-mixed 50 percent nitrous oxide and 50 percent oxygen analgesia in maternity, A and E and pre-hospital settings.',
    hazards:
        'Phase separation can occur below minus 6 degrees Celsius, leaving cylinders to deliver pure nitrous oxide. Store and transport above this temperature.',
  ),
  MedicalGas(
    name: 'CO2',
    formula: 'CO2',
    colourArgb: 0xFF6E6E6E,
    workingPressureBar: 4.1,
    testPressureBar: 7.0,
    terminalUnit: 'BS 5682 / EN ISO 9170-1',
    use:
        'Insufflation gas for laparoscopic and endoscopic surgery and certain cryotherapy applications.',
    hazards:
        'Asphyxiant in confined spaces. Heavier than air, accumulates at low level. Cylinders contain liquid CO2 and must be stored upright.',
  ),
];

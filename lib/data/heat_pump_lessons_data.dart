import 'lessons_data.dart';

/// Specialist lessons for the heat pump installer module.
const heatPumpLessonTopics = <LessonTopic>[
  LessonTopic(
    id: 'fgas_refrigerants',
    title: 'Refrigerants and F-gas regulations',
    category: 'Heat pump',
    summary:
        'The refrigerants seen on UK domestic heat pumps, their hazards and the F-gas competence required.',
    sections: [
      LessonSection(
        'Why F-gas exists',
        'Fluorinated gases are powerful greenhouse gases. The retained EU F-gas regulation, which the UK has mirrored, controls the placing on the market and the handling of refrigerants by setting a phase-down quota for high global warming potential gases. As a heat pump installer you must understand the rules even if you only fit monobloc units, because servicing or decommissioning a refrigerant circuit, however small, falls under the regulations and requires a competent person.',
      ),
      LessonSection(
        'The refrigerants you will meet',
        'The current mainstream domestic heat pump refrigerant is R32, an A2L mildly flammable gas with a global warming potential of six hundred and seventy five. Increasingly we see R290, propane, an A3 highly flammable gas with a GWP of three. R454B at GWP four hundred and sixty six is appearing on some new units. Older equipment may still hold R410A, with a high GWP of just over two thousand, which is why R410A is no longer sold for new installations. CO2 known as R744 is used in some commercial and DHW-only heat pumps at very high pressures.',
      ),
      LessonSection(
        'A2L and A3 — what changes on site',
        'A2L and A3 refrigerants are flammable. Manufacturer instructions specify minimum room volumes for indoor units, ventilation requirements, and exclusion zones around the outdoor unit where ignition sources must not be present. R290 in particular has tight rules because the lower flammability limit can be reached at relatively small leak quantities. Always read the data plate, check the maximum charge for the room, and follow siting clearances precisely.',
      ),
      LessonSection(
        'Competence requirements',
        'A monobloc heat pump arrives sealed with the refrigerant pre-charged at the factory. If you make no break in the refrigerant pipework you do not need an F-gas Category One certificate. As soon as you join two pieces of refrigerant pipework on site, including any split system or any cassette, you require Category One competence held personally and the company itself must hold an F-gas certificate to handle refrigerant. The City and Guilds 2079 qualification covers the practical assessment of refrigerant brazing, leak testing, evacuation and charging.',
      ),
      LessonSection(
        'Leak checks and records',
        'Equipment containing five tonnes CO2 equivalent or more requires periodic leak checks, recorded on the F-gas log. For domestic R32 systems with around one kilogram of charge, the threshold is rarely reached on a single split, but cascaded systems can. Always test joints with electronic leak detector and bubble solution after any work. Every gram of refrigerant added to a system must be recorded on the log against the equipment serial number.',
      ),
    ],
  ),
  LessonTopic(
    id: 'mcs_design_overview',
    title: 'MCS heat pump design fundamentals',
    category: 'Heat pump',
    summary:
        'How the MCS design pack is built — heat loss, emitter design, sound, and DHW.',
    sections: [
      LessonSection(
        'Why MCS matters',
        'The Microgeneration Certification Scheme is the route by which a heat pump installation can claim the Boiler Upgrade Scheme grant of seven thousand five hundred pounds in England and Wales. To qualify, the installer company must be MCS certified, the design must follow the MCS Installation Standard MIS three thousand and five, and the system must be commissioned to the MCS protocol. Without the MCS certificate the customer loses the grant.',
      ),
      LessonSection(
        'The design pack',
        'A complete MCS design pack contains a room by room heat loss calculation against the design outdoor temperature for the location, a system schematic, an emitter schedule showing the output of every radiator at the design flow temperature, the cylinder selection, the sound assessment under MCS twenty, and a noise certificate where required. The customer signs off the design pack before installation begins, and a copy is uploaded to the MCS database.',
      ),
      LessonSection(
        'Low flow temperature design',
        'Heat pumps deliver the best efficiency at the lowest flow temperature that satisfies the design heat loss. A typical design flow temperature is forty five degrees Celsius with a five Kelvin design temperature drop. At forty five degrees flow and twenty degrees room, mean water to air delta is twenty two and a half Kelvin. A radiator rated at delta fifty Kelvin gives roughly half its rated output at the lower delta T, so radiators are typically up-sized by a factor of one and a half to two and a half compared with a gas boiler design.',
      ),
      LessonSection(
        'Hot water and Legionella',
        'Heat pump hot water cylinders require a larger coil surface area than boiler cylinders to give up sufficient heat at the lower primary temperature. Domestic hot water is typically reheated to fifty degrees on the heat pump primary, with a periodic Legionella cycle to sixty degrees driven by an immersion or by raising the heat pump set point on a schedule. The cylinder must be sized for the household peak demand, often a one hundred and fifty to three hundred litre direct or twin coil unit.',
      ),
    ],
  ),
];

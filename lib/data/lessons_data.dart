/// Structured lesson content used by the lessons screen.
///
/// Each topic has one or more sections with concise plain-English text, the
/// kind of explanation a plumber can listen to through TTS while working.
class LessonSection {
  final String heading;
  final String body;
  const LessonSection(this.heading, this.body);
  String get speakable => '$heading. $body';
}

class LessonTopic {
  final String id;
  final String title;
  final String category;
  final String summary;
  final List<LessonSection> sections;
  const LessonTopic({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.sections,
  });
}

const lessonTopics = <LessonTopic>[
  LessonTopic(
    id: 'cold_water_basics',
    title: 'Cold water supply in a dwelling',
    category: 'Cold water',
    summary:
        'How cold water enters a property, how it is controlled, and the two common distribution layouts.',
    sections: [
      LessonSection(
        'The service pipe and stop valves',
        'Cold water arrives at a property through the water authority main and runs to the boundary stop valve, usually inside a plastic chamber at the edge of the property. From there the service pipe runs underground at a depth of at least seven hundred and fifty millimetres to protect it from frost, into the building where it emerges as the rising main. The first fitting on the rising main is the internal stop valve, which should be easily accessible. A drain off cock is normally fitted immediately above the internal stop valve so the system can be drained down for maintenance.',
      ),
      LessonSection(
        'Direct cold water systems',
        'In a direct system every cold draw off point is fed straight from the rising main, including the kitchen tap, the bath, the basin, the WC cistern and the cold feed to the water heater. Pressure at each tap is therefore mains pressure, typically between two and four bar. The advantage is that all outlets deliver wholesome drinking water. The disadvantage is that when the main is off, no cold water is available and if mains pressure is low, upstairs outlets may run poorly.',
      ),
      LessonSection(
        'Indirect cold water systems',
        'In an indirect system only the kitchen cold tap, and sometimes an outside tap, are fed from the rising main. The rest of the main is carried up to a cold water storage cistern, usually in the loft. From the cistern, gravity feeds the bath, basin, WC and the cold side of a hot water cylinder. Storage provides a short term reserve during mains interruption and reduces fluctuations in pressure, but head pressure on upper floors can be limited, so this layout is less common in modern homes.',
      ),
      LessonSection(
        'Protecting the supply',
        'Every cold water installation must be protected against backflow. Taps discharging over appliances must have the correct air gap, and where a hose could be connected, a double check valve or similar back flow device is required. Pipework in unheated spaces must be lagged, and a cold water storage cistern in a loft must have an insulated jacket, a lid, a screened overflow and a screened vent.',
      ),
    ],
  ),
  LessonTopic(
    id: 'hot_water_systems',
    title: 'Hot water generation',
    category: 'Hot water',
    summary:
        'Combi boilers, vented cylinders and unvented cylinders compared, with safety devices explained.',
    sections: [
      LessonSection(
        'Combi boiler',
        'A combination boiler heats domestic hot water on demand by diverting mains cold water through a plate heat exchanger inside the appliance. When a hot tap is opened a flow switch detects movement, the diverter valve closes off the heating circuit and the burner fires at full rate to heat the water instantaneously. There is no stored hot water, which saves space and avoids cylinder losses, but the flow rate is limited by the boiler output, so running two outlets simultaneously can reduce temperature.',
      ),
      LessonSection(
        'Vented hot water cylinder',
        'A traditional vented cylinder is supplied with cold water from a storage cistern in the loft, and the hot water distribution pipework runs up from the top of the cylinder to a vent pipe that turns back down and over the cold water cistern. This vent pipe protects the system by allowing air and any expanded water to escape safely. The heat source is normally a boiler, supplying a coil inside the cylinder, with an immersion heater as backup.',
      ),
      LessonSection(
        'Unvented cylinder',
        'An unvented cylinder is fed directly from the cold mains and heats to full mains pressure, giving strong performance at every outlet. Because expansion cannot vent to atmosphere, the cylinder must have a dedicated expansion vessel, a pressure reducing valve on the inlet, a temperature and pressure relief valve on the cylinder, a second expansion relief valve and a tundish to make any discharge visible. Installation of an unvented cylinder is notifiable work and must be carried out by a competent person.',
      ),
      LessonSection(
        'Temperature and scald protection',
        'Store hot water at sixty degrees Celsius or above to suppress Legionella, but blend down to a safe temperature at the point of use in baths and showers with a thermostatic mixing valve. A bath tap fed to a vulnerable user should be blended to a maximum of forty three degrees Celsius, and a basin tap to forty one degrees Celsius.',
      ),
    ],
  ),
  LessonTopic(
    id: 'central_heating',
    title: 'Wet central heating',
    category: 'Heating',
    summary:
        'How a boiler, circulator, radiators and controls work together to heat a home.',
    sections: [
      LessonSection(
        'The circulating loop',
        'A wet central heating system is a closed loop of pipework filled with water that is heated by a boiler, pushed around by a circulating pump and given up to the room through radiators. Flow pipe leaves the boiler hot, passes through each radiator, and returns cooler on the return pipe. Modern systems are sealed and pressurised at around one to one and a half bar when cold, with a filling loop to top up, a pressure gauge, an automatic air vent, a pressure relief valve set to three bar, and a sealed expansion vessel to absorb the change in water volume as it heats.',
      ),
      LessonSection(
        'S plan and Y plan controls',
        'An S plan system uses two motorised two port valves, one for heating and one for hot water, controlled independently by a programmer, a room thermostat and a cylinder thermostat. A Y plan system uses a single three port mid position valve that can divert to heating only, hot water only, or both simultaneously. Combi boilers integrate the diverter internally, so only a programmer and a room thermostat are usually fitted externally.',
      ),
      LessonSection(
        'Radiators and valves',
        'Every radiator has a flow valve and a return valve. The return valve is normally a lockshield that sets balancing, while the flow valve can be manual or thermostatic. A thermostatic radiator valve senses air temperature in the room and throttles the flow to maintain a chosen set point. When you commission a system, close all radiators except one, balance it, then repeat to ensure even temperature across the house.',
      ),
      LessonSection(
        'Venting and inhibitor',
        'Fill the system slowly to reduce entrained air, then vent each radiator from the top bleed screw using a square key until clear water flows. Add a corrosion inhibitor to the system water, typically one litre per hundred litres of system volume, and top it up every time a radiator is replaced.',
      ),
    ],
  ),
  LessonTopic(
    id: 'drainage_and_traps',
    title: 'Drainage, waste and traps',
    category: 'Drainage',
    summary:
        'How foul water is carried away, and why every appliance must have a trap.',
    sections: [
      LessonSection(
        'Purpose of a trap',
        'Every waste appliance must have a trap beneath it, a short U shaped pipe that retains a seal of water. The seal blocks foul air and insects from travelling back up the drain into the building. A trap must retain a minimum depth of water seal, usually seventy five millimetres, though shallower traps of thirty eight millimetres are acceptable where an installation cannot accommodate a deeper trap.',
      ),
      LessonSection(
        'Loss of seal',
        'A trap can lose its seal in several ways. Self siphonage occurs when the appliance itself discharges a long slug of water that sucks the seal away behind it. Induced siphonage occurs when another appliance connected upstream discharges and pulls the seal out. Compression or back pressure occurs in the lower part of a soil stack when air is compressed by a large discharge from above. Evaporation can empty a seldom used trap, and capillary action can slowly wick water out across a fibre or rag.',
      ),
      LessonSection(
        'Soil stacks and venting',
        'Foul water and WC discharges pass into a soil and vent pipe that runs up to the roof and terminates at least nine hundred millimetres above any opening window within three metres. The terminal must have a cage to keep out birds. Branch connections must maintain correct falls and must not be made into the boss at an angle that could cause back siphonage. An alternative is an air admittance valve, which opens to admit air but not release odour, permitted where a through vent is impractical.',
      ),
      LessonSection(
        'Rodding and access',
        'Every length of drain should have a rodding point or inspection chamber so blockages can be cleared. Falls on a hundred millimetre foul drain are usually one in forty, and on a larger drain one in eighty. Never lay a drain flatter than this or solids will drop out of suspension.',
      ),
    ],
  ),
  LessonTopic(
    id: 'pipe_materials_joints',
    title: 'Pipe materials and joining',
    category: 'Materials',
    summary:
        'Copper, plastic and the main ways of making a watertight joint.',
    sections: [
      LessonSection(
        'Copper tube',
        'Copper tube is supplied in half hard or annealed form in sizes from fifteen up to fifty four millimetres. It is rigid, clean and well suited to soldered joints, compression fittings and push fit fittings. Cut copper tube with a pipe slice rather than a hacksaw to keep the cut square and then ream the inside of the pipe to remove the burr so the bore is not restricted.',
      ),
      LessonSection(
        'Plastic pipe',
        'Plastic pipes include polybutylene and cross linked polyethylene, both of which are joined with push fit fittings. Push fit fittings must always have a support sleeve inserted into the pipe to keep the bore round under the o ring. Plastic pipe must not be connected within one metre of a boiler, because the water can be too hot, and some manufacturers require a longer metal tail.',
      ),
      LessonSection(
        'Compression joints',
        'A compression fitting uses a brass body, a brass or copper olive and a back nut. Slide the nut, then the olive onto the pipe, insert the pipe fully into the body, and tighten the nut so the olive deforms onto the pipe. One full turn past hand tight is usually enough. Avoid over tightening or you will split the olive. Use a jointing compound suitable for potable water if required by the fitting manufacturer.',
      ),
      LessonSection(
        'Soldering with lead free solder',
        'Capillary fittings are joined by soldering with a lead free alloy. Clean the pipe end and the fitting socket with wire wool until bright, apply a thin film of flux, insert the pipe fully, heat evenly with a gas torch and touch the solder to the joint. When the pipe reaches working temperature the solder is drawn into the capillary gap by surface tension. Wipe the joint while still warm and leave to cool naturally. Do not move the joint while the solder is freezing or you will get a dry joint.',
      ),
    ],
  ),
  LessonTopic(
    id: 'rainwater_systems',
    title: 'Rainwater drainage and harvesting',
    category: 'Rainwater',
    summary:
        'Capturing roof water, sizing gutters and downpipes, soakaways and harvesting for reuse.',
    sections: [
      LessonSection(
        'Why rainwater is collected and drained',
        'Rain falling on a roof must be carried away from the building quickly, or it will saturate walls, fill gutters and find its way into the structure. The first job of the rainwater system is therefore protection of the building. The second job, in modern installations, is responsible disposal: surface water must not be discharged into the foul sewer because it overloads the treatment works in storms. Drainage authorities increasingly require new builds to discharge surface water to a soakaway, to a watercourse, or to a separate surface water sewer, in that order of preference.',
      ),
      LessonSection(
        'Gutters and downpipes',
        'A standard half round gutter at one hundred and twelve millimetres diameter, falling at one in six hundred to a single outlet, will drain about thirty seven square metres of roof at a typical seventy five millimetres per hour design rainfall. Larger roofs need either a deeper gutter, more outlets, or both. Outlets are connected to a downpipe, often sixty eight millimetres round, that carries the water down the wall to either a back inlet gully, a hopper head, or directly into a soakaway. Bracket spacing is a maximum of one metre, and the swan neck offset must clear the eaves cleanly without trapping debris.',
      ),
      LessonSection(
        'Soakaways and surface water sewers',
        'A traditional soakaway is a pit lined with gravel and wrapped in a geotextile membrane, sized to absorb a design storm into the surrounding soil. Modern installations replace the gravel with plastic crate modules, which give the same volume in a smaller footprint. The soakaway must be at least five metres from any building and clear of foundations, neighbouring services and trees. Soils are tested using a BRE three hundred and sixty five percolation test before sizing. In clay or where the water table is high, an overflow to a watercourse may be permitted with the consent of the regulator.',
      ),
      LessonSection(
        'Rainwater harvesting',
        'A harvesting system collects roof runoff into a buried tank for reuse on non potable applications, principally WC flushing, washing machine supply and garden watering. Roof water passes through a leaf filter and a first flush diverter that discards the initial flow, then into the tank through a calmed inlet. A submerged or external pump delivers stored water to the dedicated non potable distribution. Mains top up is provided through an air gap break tank to comply with backflow protection requirements, since a direct cross connection to the wholesome supply is forbidden. All non potable pipework must be clearly labelled and outlets warned to prevent accidental drinking.',
      ),
    ],
  ),
  LessonTopic(
    id: 'unvented_systems',
    title: 'Unvented hot water cylinders',
    category: 'Hot water',
    summary:
        'Working principles, multiple safety devices and discharge requirements for an unvented system.',
    sections: [
      LessonSection(
        'Working principle',
        'An unvented hot water cylinder is connected directly to the cold mains and stores water at full mains pressure, typically dropped to three bar by a pressure reducing valve on the inlet. Because the system is sealed against atmosphere, expansion of the heated water cannot escape the way it does on a vented system. Every component on the inlet group and the cylinder body is therefore selected to control pressure or to protect against over temperature. The pay off for this complexity is excellent flow rate at every outlet at the same pressure, with no need for a cold water cistern.',
      ),
      LessonSection(
        'Safety devices in order',
        'Reading the inlet group from the cold main inwards, you will find a strainer, a pressure reducing valve, a single check valve, a connection to an expansion vessel, an expansion relief valve, a balanced cold tee, then the cylinder cold inlet. On the cylinder itself there is a temperature and pressure relief valve, an energy cut out and the working thermostat. The expansion relief opens first if pressure is exceeded; the temperature and pressure relief opens if either pressure or temperature is exceeded; the energy cut out is a manual reset device that disables the heat source if the working stat fails. Each device protects the next.',
      ),
      LessonSection(
        'Discharge pipework',
        'Both the expansion relief and the temperature and pressure relief discharge into a tundish, which provides a visible air break so any discharge is obvious and cannot be missed. The pipe upstream of the tundish is called D one and is sized by the manufacturer; the pipe downstream is called D two and is sized by the building regulations to prevent steam locking. D two must fall continuously, must terminate where any discharge cannot scald a person, and must not pass within visible distance of a window opening. A common termination is to an external air break or back into the foul stack with a trap, never directly into a foul drain that lacks visibility.',
      ),
      LessonSection(
        'Notifiable installation',
        'Installation, alteration or replacement of an unvented hot water system over fifteen litres is notifiable building control work in England, and may only be carried out by a person registered under a competent persons scheme such as the unvented hot water installer scheme. Each installation must be commissioned, the test record completed, the discharge pipe checked for visible termination, and the user given the manufacturer hand over pack with instructions for periodic checks of the temperature relief and the expansion vessel charge.',
      ),
    ],
  ),
  LessonTopic(
    id: 'underfloor_heating',
    title: 'Underfloor heating',
    category: 'Heating',
    summary:
        'Designing and commissioning a wet underfloor heating manifold and loops.',
    sections: [
      LessonSection(
        'Why low temperature works',
        'Underfloor heating delivers a large heated surface at a low temperature, typically a flow temperature of forty degrees Celsius and a return of thirty degrees, against a screed surface temperature limited to twenty nine degrees over occupied areas. The large emitter area means each square metre of floor only delivers around one hundred watts, which is enough to heat a well insulated room without overheating the surface. The low flow temperature allows a condensing boiler to spend more time in condensing mode, and is a perfect match for a heat pump.',
      ),
      LessonSection(
        'Manifold and blending',
        'A manifold has a flow rail at the top, with one valve and one actuator per loop, and a return rail at the bottom with a flow meter and a balancing lockshield per loop. A blending unit on the inlet mixes hot primary water with cooler return water to drop the high primary temperature down to the underfloor circuit temperature. The blending may be a thermostatic blender or a motorised blender controlled by an electronic head. Each loop is sized so it does not exceed about one hundred metres of sixteen millimetre pipe to keep pressure loss within the pump duty.',
      ),
      LessonSection(
        'Commissioning',
        'A correctly commissioned system is pressure tested at six bar for at least thirty minutes before the screed is poured. After the screed is laid, the system must be brought up to temperature gradually, typically twenty five degrees on day one rising five degrees per day, and held at the design temperature for several days before being cycled. This curing protects the screed from cracking. Each loop is balanced on the flow meter using the manufacturer chart, and air is purged through the dedicated manifold air vent.',
      ),
      LessonSection(
        'Faults and care',
        'Common faults include a sluggish loop caused by trapped air, a stuck actuator that is normally closed by spring and fails to lift when energised, a thermostat reading wrongly because it is mounted in the airflow of a doorway, and a blocked filter in the blending unit. Annual service should include a magnet filter check, a pressure check, and a flow meter walk to confirm balance has not drifted.',
      ),
    ],
  ),
  LessonTopic(
    id: 'pressure_testing',
    title: 'Pressure testing and commissioning',
    category: 'Process',
    summary:
        'How to prove the integrity of a new installation, hold times, and acceptable drops.',
    sections: [
      LessonSection(
        'Why test',
        'Every installation that will be filled with pressurised water must be hydrostatically pressure tested before being commissioned, to prove integrity and to confirm that no joint has been forgotten. Compressed gas or air must never be used in place of water for pressure testing pipework, because the stored energy of compressed gas inside a long pipe is enormous and a failure can be lethal. Water is essentially incompressible, so a leak releases little energy and is easy to find.',
      ),
      LessonSection(
        'Equipment and procedure',
        'A hand operated pressure test pump is connected to a drain off cock or a dedicated test point with a calibrated gauge, after the system has been filled and all air has been purged through the highest vents. The system is brought up to test pressure, normally one and a half times the maximum working pressure, and held for a documented period, typically thirty minutes. Allow a few minutes initial settle before reading because thermal expansion of the test water can mask small drops.',
      ),
      LessonSection(
        'Acceptance and recording',
        'A rigid metal system should hold pressure with no measurable drop. A plastic pipe system is permitted a small drop because the pipe expands slightly under pressure. The result must be recorded against the installation drawing for the file and the customer hand over pack. If a drop is observed, walk every joint with a paper towel to find the leak; if a fitting weeps, do not over tighten, isolate, depressurise, remake the joint, and retest.',
      ),
    ],
  ),
  LessonTopic(
    id: 'regulations_safety',
    title: 'Regulations and safety',
    category: 'Safety',
    summary:
        'Key points of the Water Regulations, gas safe requirements and site safety.',
    sections: [
      LessonSection(
        'Water supply regulations',
        'The Water Supply Water Fittings Regulations set minimum standards for every fitting connected to a public water supply in England and Wales. Key points include the prevention of waste, misuse, undue consumption and contamination of wholesome water. Every notifiable installation must be notified to the water undertaker before work starts. Only approved fittings may be used and each installation must be tested and flushed before use.',
      ),
      LessonSection(
        'Gas safety',
        'Any work on a gas appliance or gas pipework must be carried out by a Gas Safe registered engineer. The engineer must perform a tightness test, a working pressure check, a flue flow test and a spillage test, and must record all readings on the appliance service record. Never attempt to repair a gas leak yourself. Turn off the emergency control, ventilate the area and call the national gas emergency number on zero eight hundred one one one nine nine nine.',
      ),
      LessonSection(
        'Electrical bonding',
        'Metallic incoming services must be cross bonded near the point of entry to the main earth terminal of the dwelling, within six hundred millimetres of the meter. Bonding clamps must carry the permanent label safety electrical connection do not remove. When you replace a section of metal pipe with plastic you may break the bond and you must restore continuity before leaving site.',
      ),
      LessonSection(
        'Personal protective equipment',
        'Always wear safety glasses when cutting, soldering or grinding. Gas torches require a heat mat behind the joint and a fire watch of at least half an hour after leaving. Keep a powder extinguisher within reach. When working in roof spaces use a crawl board, and never rely on the ceiling to take your weight.',
      ),
    ],
  ),
];

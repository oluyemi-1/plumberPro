import 'lessons_data.dart';

/// Lesson topics covering backflow prevention under the UK Water Supply
/// (Water Fittings) Regulations. Fluid categories, devices and the practical
/// installation rules a plumber needs on site.
const backflowLessonTopics = <LessonTopic>[
  LessonTopic(
    id: 'fluid_categories',
    title: 'Fluid categories 1 to 5',
    category: 'Backflow',
    summary:
        'How the Water Regulations classify the risk of a fitting contaminating the wholesome supply.',
    sections: [
      LessonSection(
        'Category 1 — wholesome water',
        'Fluid Category 1 is wholesome water supplied directly from the water undertaker, fit for drinking and meeting all the chemical and microbiological limits set in the Drinking Water Regulations. It is the reference point against which every other category is judged. Category 1 water is found at the rising main, the kitchen drinking tap, and the cold inlet to most appliances before any heating, storage or chemical addition has taken place. All fittings in contact with Category 1 water must be approved for potable use. Materials such as lead, brass with high lead content, or unsuitable plastics that taint or leach are forbidden. Backflow protection is not strictly required to keep Category 1 separate from Category 1, but every downstream category must be isolated from this point.',
      ),
      LessonSection(
        'Category 2 — aesthetic change',
        'Fluid Category 2 covers water whose aesthetic quality has been impaired but which is not a health risk. The classic example is wholesome water that has been heated, so its taste, smell or appearance have changed without anything else being added. The hot tap at a kitchen sink, the outlet of an unvented or vented cylinder, and water held briefly in a domestic mixer are all Category 2. Because the only change is aesthetic, the protection required is light. A single check valve, sometimes built into the appliance or the mixer cartridge, prevents the warmer Category 2 water from drifting back into the cold Category 1 line and giving downstream users the impression of contamination.',
      ),
      LessonSection(
        'Category 3 — slight health risk',
        'Fluid Category 3 is water that presents a slight risk to health, typically because it has been used in a domestic appliance, contains a chemical additive at a low concentration, or has been in contact with surfaces a person may have touched. Common examples are central heating water dosed with corrosion inhibitor, water in a wash basin, water in a bath, and the cold feed to a domestic dishwasher or washing machine. Protection at the slight risk level uses a double check valve, an air gap of type AUK3 to a domestic appliance, or an equivalent device. The system relies on two independent barriers between the appliance and the wholesome supply.',
      ),
      LessonSection(
        'Category 4 — significant health risk',
        'Fluid Category 4 is water that contains a substance significantly hazardous to health, such as toxic chemicals, pesticides, or environmental organisms in concentrations that could cause illness. Typical Category 4 fittings include commercial dishwashers and washing machines, mini photo labs, primary heating circuits with high concentrations of inhibitor or anti freeze, and outside hose union taps in domestic premises. Protection rises sharply at this level. Acceptable devices are an air gap of type AB or AD, a Reduced Pressure Zone valve, or a verifiable double check valve specifically rated for Category 4. A simple non testable double check valve is no longer enough.',
      ),
      LessonSection(
        'Category 5 — serious health risk',
        'Fluid Category 5 is the most dangerous classification, covering water that contains pathogens, faecal matter, or other agents capable of causing serious harm. Examples are WC pans, urinals, bidets without an upstand, agricultural and irrigation systems, mortuary equipment, and most healthcare and industrial process water. The only acceptable protection is a physical air gap of type AA, AB, AD, AG, AUK1 or other listed Category 5 device, or in some commercial cases a tank fed entirely through a Type AB break tank. Mechanical valves alone are never acceptable on a Category 5 outlet because failure of one valve must not allow contaminated water back into the wholesome supply.',
      ),
    ],
  ),
  LessonTopic(
    id: 'air_gaps_devices',
    title: 'Air gaps and back-flow devices',
    category: 'Backflow',
    summary:
        'The lettered family of air gaps plus mechanical devices: SCV, DCV and RPZ.',
    sections: [
      LessonSection(
        'Type AA, AB, AD and AG air gaps',
        'An air gap is a physical, unobstructed vertical distance between the lowest point of a water inlet and the spillover level of the receiving vessel. Type AA is an unrestricted air gap to a tank that is open to atmosphere, suitable for Category 5. Type AB is the same idea but the receiver has a weir overflow that limits the maximum water level, also Category 5 and the most common break tank arrangement on commercial sites. Type AD is a gap with an injector, used in industrial process equipment. Type AG is a fixed minimum air gap inside an appliance such as a WC cistern, where the float valve outlet sits above the overflow weir.',
      ),
      LessonSection(
        'AUK1, AUK2 and AUK3',
        'The AUK family describes the air gaps you find at domestic taps and appliances. AUK1 is the air gap inside a WC cistern between the float valve outlet and the critical water level, providing Category 5 protection. AUK2 is the gap at a domestic tap above the spillover of a basin, sink or bath, where the spout sits a fixed minimum above the rim. AUK2 covers Category 3 only, which is why a domestic kitchen tap is not allowed to have a flexible hose or pull out spray that could fall below the rim. AUK3 is a deeper gap, used for higher risks at non domestic appliances and for hose union taps inside a building.',
      ),
      LessonSection(
        'Single and double check valves',
        'A single check valve, often abbreviated SCV, contains one spring loaded disc that closes when flow tries to reverse. It is a Category 2 device. A double check valve, DCV, is two single check valves in series in a single body and provides Category 3 protection. Both are mechanical and inexpensive but neither is testable in service. The most common DCV in domestic use is fitted on an outside tap, on the inlet to a hose union, on the cold supply to a washing machine, and as a built in feature of many filling loops on sealed heating systems.',
      ),
      LessonSection(
        'Reduced pressure zone valve',
        'A Reduced Pressure Zone valve, or RPZ, is a verifiable backflow device for Category 4 risks. It contains two independent check valves separated by a relief chamber that opens to atmosphere if either check fails or if pressure differential drops. The relief discharge must be piped to a tundish that is visible and that drains to a safe point. RPZ installation is notifiable to the water undertaker, the device must be installed by a competent person, and it must be tested annually by an approved tester who logs the result. Common applications include commercial dishwashers, laboratory benches, vehicle wash systems, and many fire sprinkler take offs.',
      ),
    ],
  ),
  LessonTopic(
    id: 'backflow_practice',
    title: 'Backflow protection in practice',
    category: 'Backflow',
    summary:
        'Pairing devices to outlets, inspections, and the most common installation errors.',
    sections: [
      LessonSection(
        'Pairing the right device to the outlet',
        'On every job, work top down: identify the fluid category at the outlet, then select a device that protects to at least that category. A garden tap inside a domestic dwelling is Category 4 and must have a verifiable DCV, often integrated into a hose union tap or fitted as a separate fitting on the rising main. A washing machine in a domestic kitchen is Category 3 and an SCV in the appliance plus the AUK2 gap at the standpipe is enough. A commercial dishwasher is Category 4 and must have a Type AB break tank or an RPZ. A WC fill is Category 5 and the AUK1 air gap inside the cistern is the only protection used.',
      ),
      LessonSection(
        'Testing and inspection schedules',
        'Mechanical devices must be inspected to confirm they are accessible, isolated by upstream stop valves, drained at the test cocks, and visually clean. RPZ devices have a strict legal regime: an annual test by an approved tester, with a written record sent to the water undertaker. Domestic DCVs do not have a fixed legal interval but should be inspected at every service of the host appliance, and replaced if the spring shows weakness. Air gaps should be checked for any modification that may have reduced the gap, for example a longer flexible hose installed by the householder, a raised rim on a sink, or an obstruction below the spout that lifts the spillover.',
      ),
      LessonSection(
        'Common installation errors',
        'The errors that come up most often on inspection are easy to spot once you know to look. A commercial dishwasher fed straight off the mains with no break tank or RPZ. A garden tap on a copper tail with no DCV in line. A flexible spray hose on a kitchen tap that can pull below the sink rim and lose its AUK2 gap. A tundish piped into a foul stack with no air break, so the tundish itself becomes a back flow path. A filling loop left permanently connected to a heating system, with the inhibitor dosed central heating water sitting against a single check valve. In every case the fix is to identify the category at the outlet and step the protection up.',
      ),
    ],
  ),
];

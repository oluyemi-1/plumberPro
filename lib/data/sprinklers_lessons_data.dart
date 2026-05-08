import 'lessons_data.dart';

/// Lesson topics for UK domestic and residential fire sprinkler systems
/// designed to BS 9251:2021. Commercial sprinklers (BS EN 12845) and rising
/// mains (BS 9990) are referenced for context only.
const sprinklersLessonTopics = <LessonTopic>[
  LessonTopic(
    id: 'sprinklers_overview',
    title: 'Domestic and residential sprinkler systems',
    category: 'Sprinklers',
    summary:
        'Why life safety sprinklers are fitted, the codes that apply, and how the hazard categories step up from a small dwelling to a care home.',
    sections: [
      LessonSection(
        'Why fit sprinklers',
        'A residential fire sprinkler is a life safety device. It is designed to control a fire in the room of origin so that occupants have time to escape and the fire service has time to arrive. Statistics from the National Fire Chiefs Council show fatal house fires are extremely rare in dwellings protected by a working sprinkler. The system is automatic, so it works when the alarm panel is unattended and even when the occupants are asleep. Sprinklers are increasingly required in new build flats over eleven metres tall, in new care homes, and in some local authority residential schemes.',
      ),
      LessonSection(
        'BS 9251 versus BS EN 12845',
        'BS 9251:2021 is the British Standard for fire sprinkler systems in residential and domestic premises. It is the reference document for houses, flats, sheltered housing and care homes. BS EN 12845 is the European Standard for commercial and industrial sprinklers and applies to offices, warehouses and factories, with much higher water demands. BS 9990 covers wet and dry rising mains used by the fire service in tall buildings, which is a separate system from automatic sprinklers. As a residential installer you will work almost exclusively to BS 9251, but you must recognise where the building falls outside its scope.',
      ),
      LessonSection(
        'Hazard categories Cat 1 to Cat 4',
        'BS 9251 sets four hazard categories. Category one is a normal single family dwelling with one head assumed to operate at four millimetres per minute over a small area. Category two covers flats up to eighteen metres tall, designed at five millimetres per minute over twelve square metres with four heads operating. Category three covers taller residential, sleeping risks and care environments at seven and a half millimetres per minute over twenty four square metres. Category four is bespoke, used for high dependency nursing where a designer must justify the design with a full risk assessment.',
      ),
      LessonSection(
        'Life safety, not property protection',
        'Be clear with the customer that a residential sprinkler is a life safety system, not a property protection system. It controls the fire so people can leave; it does not guarantee the building or contents will be saved. Property protection sprinklers exist but are designed to a higher specification, often to BS EN 12845 with longer durations and larger water reserves. The cost difference is substantial, so the purpose of the system must be agreed at the survey stage and recorded on the design certificate before any pipework is installed.',
      ),
    ],
  ),
  LessonTopic(
    id: 'sprinklers_design',
    title: 'Sprinkler system design',
    category: 'Sprinklers',
    summary:
        'Coverage rules, head spacing, hydraulic calculation using K factor, and how to size pipework for the most demanding head.',
    sections: [
      LessonSection(
        'Coverage and head spacing',
        'Each sprinkler head has a maximum coverage area defined by its listing, typically twelve square metres for a Cat 2 head and twenty four square metres for a Cat 3 head. Head spacing must keep every part of the room within the coverage radius and within the maximum distance to a wall, normally one and a half to one point eight metres. Heads must clear obstructions such as deep beams and large light fittings; an obstruction within three hundred millimetres below the deflector will distort the spray. Plan the head layout from the room shape outwards so every position satisfies both coverage and obstruction rules.',
      ),
      LessonSection(
        'Pipe layout and the demanding head',
        'A sprinkler installation is laid out as a tree of branch lines fed from a single feed main. Branch lines are run within the ceiling void or in a service zone, with heads dropping or rising as required by the type of head. The hydraulically most demanding head is the head with the longest pipe run from the supply at the highest elevation. Design calculations must demonstrate that this remote head can still deliver its required flow and pressure. Other heads will be over supplied because they are nearer the source, which is acceptable.',
      ),
      LessonSection(
        'Flow and pressure with K factor',
        'A sprinkler head is rated by its K factor, the metric coefficient that links flow and pressure. Flow Q in litres per minute equals K times the square root of pressure P in bar, written Q equals K root P. A K eighty head at one and a half bar therefore delivers eighty times the square root of one and a half, which is roughly ninety eight litres per minute. Cat 2 demand of four heads at this rate gives a system flow around four hundred litres per minute. The supply must deliver this combined flow at the required residual pressure at the most demanding head.',
      ),
      LessonSection(
        'Pipe sizing and pressure margin',
        'Pipework is sized so that friction loss between the supply and the demanding head is small enough to leave the required residual pressure. A simplified BS 9251 approach gives twenty five millimetre CPVC for up to fifty litres per minute, thirty two millimetre for up to one hundred, forty millimetre for up to one hundred and eighty, and fifty millimetre for higher demand. Add the static head from the supply level to the head, the friction loss along the longest run, and the residual pressure required at the head, and confirm the available pressure margin meets or exceeds the total.',
      ),
    ],
  ),
  LessonTopic(
    id: 'sprinklers_supply',
    title: 'Water supplies',
    category: 'Sprinklers',
    summary:
        'BS 9251 supply types one to four, town main checks, pump and tank arrangements, and monitoring requirements.',
    sections: [
      LessonSection(
        'The four supply types',
        'BS 9251 defines four water supply arrangements. Type one is a boosted town main, where a small pump tops up pressure or flow on the incoming supply. Type two is a town main only, used in low demand Cat 1 systems where the main can prove sufficient on its own. Type three combines a town main with a stored water tank and a pump set, used when the main cannot meet flow but storage can make up the shortfall. Type four is a tank and pump set fed independently, used where total reliability is needed and a town main cannot be relied upon during a fire event.',
      ),
      LessonSection(
        'Mains pressure check',
        'Before specifying a Type one or Type two supply, carry out a mains test at the property at peak demand time. Open a flow gauge on the rising main and record both static and residual pressure under a controlled draw at a known flow rate. From this you can plot the supply curve and see whether it crosses the system demand curve at the design point. The water authority will also issue a flow and pressure statement, but the on site test is what proves the supply is suitable. Many marginal mains fail at five oclock on a hot summer evening.',
      ),
      LessonSection(
        'Tank, pump set and dual supply',
        'A dedicated sprinkler tank is sized to deliver the design flow for the design duration with a small safety margin, typically ten per cent. The pump set is normally a duty plus standby arrangement with electric drive, or in higher categories a diesel back up. For Cat 3 sleeping risks, a dual supply is recommended so the system has both a main and an independent tank route to feed the heads. The cistern must be filled by an air gap, must not overflow into a foul or surface water drain, and must include level monitoring.',
      ),
      LessonSection(
        'Monitoring and alarms',
        'BS 9251 requires the sprinkler system to be monitored for faults. The pump must be linked to a control panel that signals power failure, pump running and pump fail. The tank must signal low water level. The flow switch on the alarm valve must signal flow on activation. In Cat 3 and Cat 4 systems these signals are normally routed to a constantly attended location or to an alarm receiving centre. In a single dwelling Cat 1 install the audible alarm gong outside the building is often sufficient, but the customer should still know what each signal means.',
      ),
    ],
  ),
  LessonTopic(
    id: 'sprinklers_install',
    title: 'Installation, testing and maintenance',
    category: 'Sprinklers',
    summary:
        'Pipe materials, anti-freeze, hydrostatic and flow testing, weekly checks, annual service and the BS 9251 certificate.',
    sections: [
      LessonSection(
        'Pipe materials and routing',
        'Domestic sprinkler pipework is normally listed CPVC, listed PEX or copper to BS EN 1057. The materials and the fittings must come from the same listed system, since mixing brands invalidates the listing. Pipework must be supported at the manufacturer specified centres, must not pass through a fire compartment without proper firestopping, and must be hidden in the ceiling void or behind a service zone. CPVC must be kept clear of polystyrene insulation and certain glues, which can soften the pipe over time. Always read the listing sheet before clipping the first length.',
      ),
      LessonSection(
        'Anti-freeze and frost protection',
        'Where sprinkler pipework runs through unheated areas, such as a garage ceiling or a loft, frost protection is essential. The first option is to insulate generously and trace heat the pipe, keeping it within the heated envelope of the building. The second option is a glycol filled anti-freeze loop, but the concentration must be limited because high glycol can affect spray formation, and the loop must be valved off from the wholesome supply with a Type AB air gap. A third option is to redesign the route so it stays within the heated envelope.',
      ),
      LessonSection(
        'Pressure and flow testing',
        'Once installed, the sprinkler pipework is hydrostatically tested at one and a half times maximum working pressure, and never below ten bar, held for at least two hours with no measurable drop. After fill, a flow test is carried out from the most remote test outlet to confirm the design flow is delivered at the required residual pressure. The pump set is run on test, the flow switch is proved, and the alarm valve and motorised gong are exercised. Every reading is recorded against the design calculation for the BS 9251 certificate.',
      ),
      LessonSection(
        'Servicing and the BS 9251 certificate',
        'The customer must be given a BS 9251 design and installation certificate, signed by the competent designer and installer, with all calculations, drawings, and test results in the operation and maintenance file. Weekly checks include a visual inspection of valves, the pressure gauge and the panel. Quarterly checks add a pump run test and a flow switch test from the test valve. Annually a full service is required, including a flow test at the most remote head, an inhibitor or anti-freeze sample where applicable, and a written report left on file for the building owner.',
      ),
    ],
  ),
];

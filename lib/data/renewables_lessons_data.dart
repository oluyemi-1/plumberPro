import 'lessons_data.dart';

/// Lesson topics for the Renewables module: ASHP, GSHP, solar PV and MVHR.
const renewablesLessonTopics = <LessonTopic>[
  LessonTopic(
    id: 'air_source_heat_pump',
    title: 'Air-source heat pumps',
    category: 'Renewables',
    summary:
        'How an ASHP works, sizing principles, installation rules and what COP and SCOP mean in practice.',
    sections: [
      LessonSection(
        'How it works',
        'An air-source heat pump moves heat from outdoor air into a heating circuit using a vapour compression refrigerant cycle. Liquid refrigerant evaporates in the outdoor coil, taking heat from the air even when it feels cold to us. The compressor then squeezes the vapour, which raises its temperature significantly, and the hot vapour gives up its heat to the heating water at the indoor condenser. An expansion valve drops the pressure of the now liquid refrigerant, cooling it ready to absorb heat again. The pump only moves heat, it does not create it, which is why one unit of electricity can produce three or four units of useful heat under good conditions.',
      ),
      LessonSection(
        'Sizing and emitters',
        'Heat pumps work best at low flow temperatures, typically 35 to 45 degrees Celsius rather than the 70 to 80 degrees of a traditional boiler. That means emitters must give up the same heat at a much lower water temperature, so radiators are often upsized by a type or two and underfloor heating is the ideal partner. A whole-house heat loss calculation to BS EN 12831 is mandatory before specifying the unit, taking fabric losses, ventilation losses and a sensible internal design temperature into account. Cylinder reheat capacity must be checked, and a buffer or low loss header is fitted where the pump needs minimum flow that the emitters cannot guarantee.',
      ),
      LessonSection(
        'Installation requirements',
        'Installation must be MCS certified for the customer to claim the Boiler Upgrade Scheme grant, currently 7500 pounds towards an air-source heat pump in England and Wales. Permitted development covers most domestic outdoor units provided the unit is more than one metre from the boundary, no more than 0.6 cubic metres in size and not on a wall facing a road on a designated property. Noise must be assessed under MCS 020, ensuring sound at the neighbour boundary is no more than 42 dB(A). The condensate must drain to a suitable point and be protected against freezing in winter, normally with trace heating or a soakaway filled with limestone.',
      ),
      LessonSection(
        'Coefficient of performance',
        'The Coefficient of Performance, COP, is the ratio of useful heat out to electricity in at one operating point, for example 3.5 means 3.5 kilowatts of heat for 1 kilowatt of electricity. The Seasonal Coefficient of Performance, SCOP, averages performance across a typical UK heating season and is the more honest figure for running cost. SCOP falls as flow temperature rises and as outside air gets colder, so a system designed for 35 degrees will normally deliver an SCOP around 3.8 to 4.2 while one pushed to 55 degrees may struggle to reach 2.8. Customers under the Boiler Upgrade Scheme expect a designed SCOP of at least 2.8 with the design backed by MCS paperwork.',
      ),
    ],
  ),
  LessonTopic(
    id: 'ground_source_heat_pump',
    title: 'Ground-source heat pumps',
    category: 'Renewables',
    summary:
        'Collector loop choices, brine and circulators, ground area sizing and the economics of a GSHP install.',
    sections: [
      LessonSection(
        'Collector loops',
        'A ground-source system uses the earth as a heat source, which is much more stable than the air and typically sits between 8 and 12 degrees Celsius year round in the UK. A horizontal slinky is laid in trenches roughly 1.2 metres deep, with overlapping coils giving a long pipe length per square metre of garden. Vertical boreholes drilled to between 80 and 150 metres are far more compact but need a specialist contractor and add significant cost. Pond loops can be used where a deep stable body of water is available. Pipework is medium density polyethylene, fusion welded and pressure tested before back filling, with a tracer tape for future identification.',
      ),
      LessonSection(
        'Brine and circulator',
        'The collector loop is filled with a brine, normally a 25 to 30 percent mono-propylene glycol mix in water that resists freezing well below the temperatures the ground will ever reach. A dedicated brine circulator, often inside the heat pump itself, drives the flow at typically 0.4 to 0.6 metres per second to give turbulent flow and good heat transfer. The brine is filled and bled through a charging station that uses an open header tank and a pressurising pump to flush out air. After commissioning the loop pressure is set around 1 to 1.5 bar and the freezing point is checked with a refractometer at every annual service.',
      ),
      LessonSection(
        'Sizing and ground area',
        'A heat loss calculation gives the design heat output, and the rule of thumb for a horizontal slinky in average UK soil is that you need 30 to 40 watts of heat extraction per square metre of ground area. So a 6 kW heat pump with a 4 kW ground load needs in the order of 100 to 130 square metres of slinky trench, often two or three trenches each of 30 to 50 metres. Vertical boreholes give roughly 50 watts per metre of borehole, so the same 4 kW load needs around 80 metres of borehole, normally split over two holes. Over-extracting risks freezing the ground locally, so the figures should never be pushed to gain a smaller install.',
      ),
      LessonSection(
        'Costs and economics',
        'Ground-source installs typically cost between 18000 and 35000 pounds depending on whether trenches or boreholes are used. The Boiler Upgrade Scheme grant is currently 7500 pounds for a ground-source unit, the same as an air-source. Running cost is generally 20 to 30 percent lower than an equivalent air-source heat pump because the ground stays warmer than the air in winter, giving a higher SCOP, often above 4.0. Maintenance is light, normally an annual brine check, filter clean and combustion safety not applicable. Customers should be reminded that the heat pump itself sits indoors and needs an electrical supply rated for the unit, plus space around the cylinder for control gear.',
      ),
    ],
  ),
  LessonTopic(
    id: 'solar_pv',
    title: 'Solar photovoltaic systems',
    category: 'Renewables',
    summary:
        'How PV produces DC electricity, the role of the inverter and diversion options for surplus generation.',
    sections: [
      LessonSection(
        'DC versus AC and the inverter',
        'A photovoltaic panel produces direct current, typically around 30 to 40 volts at maximum power, when light strikes the silicon cells and frees electrons across a junction. UK consumer appliances and the grid run on 230 volt 50 hertz alternating current, so an inverter is essential. A grid-tied string inverter takes the DC from a string of panels and synthesises a clean sine wave that matches the grid voltage and frequency, with anti-islanding protection that disconnects within milliseconds if the grid fails. Hybrid inverters add a battery port and can keep critical loads alive during a power cut through an Energy Port. Microinverters and DC optimisers do similar work at the panel level.',
      ),
      LessonSection(
        'Strings and array',
        'A string is a set of panels wired in series, where voltages add together while current stays the same. Strings are then sometimes paralleled to scale up current. Each inverter has a maximum power point tracker, MPPT, that constantly varies the operating point to extract the most power as light and shading change. Panels that are partially shaded throttle the whole string, so optimisers or microinverters are recommended where shade from chimneys or trees is unavoidable. Cable runs use double-insulated DC solar cable rated for outdoor UV exposure, and connectors are MC4 type, crimped not pushed, with a continuity check at install.',
      ),
      LessonSection(
        'Diversion to immersion or battery',
        'A PV diverter, sometimes called a solar iBoost, monitors the consumer unit clamp and feeds any surplus that would otherwise go to the grid into the cylinder immersion heater, modulating power so that nothing is exported. This typically gives 1500 to 2500 kilowatt hours of free hot water a year on a 4 kW PV array. Alternatively, surplus can charge a lithium iron phosphate battery, sized normally between 5 and 15 kilowatt hours for a domestic dwelling, which then discharges in the evening. Any remaining surplus is sold back to the supplier under the Smart Export Guarantee at the rate the supplier publishes, currently between 5 and 15 pence per kilowatt hour.',
      ),
      LessonSection(
        'MCS and notification',
        'Solar PV is electrical work covered by Building Regulations Part P and notifiable to the local authority unless carried out by a registered competent person. For the Smart Export Guarantee and any future grant the install must be Microgeneration Certification Scheme registered, with an MCS certificate uploaded within ten working days. The DNO must be notified through a G98 connection notice within 28 days for arrays up to 16 amps per phase, or via G99 prior approval for larger systems. The plumber on a hybrid project will not commission the inverter but will install the cylinder and the diverter side, and should always isolate at the AC and DC isolator before working downstream.',
      ),
    ],
  ),
  LessonTopic(
    id: 'mvhr',
    title: 'Mechanical ventilation with heat recovery',
    category: 'Renewables',
    summary:
        'Why airtight homes need controlled ventilation and how MVHR recovers heat without losing air quality.',
    sections: [
      LessonSection(
        'Why we ventilate',
        'Building Regulations Approved Document Part F sets the minimum ventilation rates for dwellings, currently around 0.3 air changes an hour as a whole house background rate and a higher boost rate in wet rooms. Modern airtightness standards mean infiltration alone is no longer enough to remove moisture, cooking fumes, VOCs and carbon dioxide, and a poorly ventilated airtight home soon develops condensation and mould. Mechanical ventilation with heat recovery, MVHR, supplies fresh filtered air to habitable rooms while extracting stale air from wet rooms continuously. Without it, a dwelling at 3 cubic metres per hour per square metre or below at 50 pascals quickly becomes uncomfortable and unhealthy for occupants.',
      ),
      LessonSection(
        'Counter-flow heat exchanger',
        'At the heart of an MVHR unit is a counter-flow plate heat exchanger, normally aluminium or polystyrene, where the warm extract stream and the cold supply stream flow past each other on opposite sides of thin plates. Because the streams never mix, no smells or moisture pass across, but up to 90 percent of the sensible heat is transferred from the outgoing air to the incoming air. So on a winter morning at 0 degrees outside and 21 degrees inside, the supply might enter the bedroom at around 18 to 19 degrees, with no boiler input. In summer, a summer bypass routes air around the exchanger so warm extract is not used to heat already warm intake.',
      ),
      LessonSection(
        'Ducting design',
        'Duct routes are designed for low resistance because every pascal of pressure drop costs fan electricity. Rigid galvanised steel or smooth wall plastic runs are preferred over the cheaper semi-rigid radial ducting, which has higher friction losses. Total external static pressure should normally not exceed 100 pascals at design flow. Ducts in unheated voids must be wrapped in 25 millimetres or more of vapour sealed insulation to stop condensation forming on cold supply ducts and dripping into ceilings. Manifold systems with a 75 millimetre semi-rigid drop to each terminal are popular in new build because they balance individual room flows without requiring physical iris dampers in every branch.',
      ),
      LessonSection(
        'Commissioning and balancing',
        'After install the system must be commissioned by measuring the air flow at every supply and extract terminal with a calibrated zero-pressure hood or anemometer. Each terminal is adjusted with its damper until the measured flow rate is within plus or minus 10 percent of the design figure, and total supply must roughly equal total extract so the dwelling is not pressurised or depressurised. Filters are checked, the summer bypass is verified, and the readings are recorded on a Part F commissioning sheet. The customer is shown how to clean the F7 supply and G4 extract filters at six month intervals and replace them annually, and how to recognise the alarm if the unit blocks or fails.',
      ),
    ],
  ),
];

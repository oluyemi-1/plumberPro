import 'lessons_data.dart';

const fuelsLessonTopics = <LessonTopic>[
  LessonTopic(
    id: 'fuel_selection',
    title: 'Choosing a fuel for the dwelling',
    category: 'Fuels',
    summary:
        'Compare mains gas, LPG, oil, electric and biomass on cost, carbon and suitability.',
    sections: [
      LessonSection(
        'Mains gas as the default choice',
        'For most UK dwellings on the gas grid, mains natural gas remains the cheapest fuel per kWh and the simplest to install. Typical unit costs sit around 6 to 8 pence per kWh under the price cap, well below electricity at roughly 24 to 28 pence. Distribution is on demand from the network, so no on-site storage is needed and the meter is owned by the supplier. A standard inlet pressure of 21 mbar at the appliance governor is expected. Where the property already has gas, replacing a like-for-like boiler is usually the most economic and least disruptive upgrade, although new build planning is steering future homes away from fossil heating.',
      ),
      LessonSection(
        'LPG and oil for off-grid properties',
        'Where mains gas is unavailable, propane LPG or kerosene oil are the conventional alternatives. LPG arrives as a bulk tank or cylinder bank with a regulated supply at 37 mbar, while oil is stored in a tank feeding a pressure-jet burner. LPG produces around 0.214 kg CO2 per kWh and oil around 0.247 kg CO2 per kWh, both higher than natural gas at 0.183. Running costs vary with delivery price but oil currently sits between gas and LPG. Both demand on-site storage, separation distances, and routine deliveries, so siting and access for the tanker must be planned at the design stage.',
      ),
      LessonSection(
        'Electric and heat pump options',
        'Direct electric heating has the highest unit cost but the lowest installation cost and zero on-site emissions. Air source heat pumps deliver around 3 kWh of heat per 1 kWh of electricity, which makes their effective unit cost competitive with gas, especially on a heat pump tariff. Carbon intensity falls every year as the grid decarbonises, currently around 0.207 kg CO2 per kWh. Heat pumps require larger emitters, lower flow temperatures of 35 to 50 degrees, and good fabric insulation to perform well. A well-designed heat pump in a properly insulated dwelling is the lowest carbon mainstream choice available today.',
      ),
      LessonSection(
        'Biomass and suitability by location',
        'Biomass pellet or log boilers can suit rural homes with storage space and a clean dry fuel store. They are considered low carbon when sourced sustainably but produce particulates, so urban use is restricted under smoke control orders. Selection in practice is driven by location and fabric: on the gas grid, replace gas; off grid with poor insulation, oil or LPG; off grid with good insulation, a heat pump; rural with a fuel store and demand for high temperatures, biomass. Always confirm permitted development limits, planning constraints, and any RHI or BUS grant scheme rules before specifying.',
      ),
    ],
  ),
  LessonTopic(
    id: 'combustion_basics',
    title: 'Combustion fundamentals',
    category: 'Fuels',
    summary:
        'The fire triangle, products of combustion, calorific values and the stoichiometric ratio.',
    sections: [
      LessonSection(
        'The combustion triangle',
        'Combustion needs three things in the right balance: a fuel, oxygen, and an ignition source. Remove any one and the reaction stops. In a boiler the fuel is metered through an injector, oxygen comes from primary and secondary air around the burner, and ignition is provided by a spark electrode or hot surface igniter. The flame sustains itself once the gas leaving the injector reaches its auto-ignition temperature in the presence of sufficient air. Engineers exploit this triangle when troubleshooting: poor flame can be a fuel issue, an air starvation issue, or an ignition issue, and the analyser readings together with the flame picture point to which leg is at fault.',
      ),
      LessonSection(
        'Products of complete and incomplete combustion',
        'Complete combustion of a hydrocarbon produces carbon dioxide, water vapour and heat, with a small amount of nitrogen oxides from the nitrogen in the air. When oxygen is insufficient or mixing is poor, combustion becomes incomplete and produces carbon monoxide, soot and unburnt hydrocarbons. Carbon monoxide is the silent killer: colourless, odourless, and binding to haemoglobin around 240 times more readily than oxygen. Soot deposits inside the heat exchanger and flue choke airways and accelerate corrosion. The flue gas analyser quantifies this: CO above about 400 ppm or a CO/CO2 ratio above 0.02 indicates a dangerous appliance that must be turned off and reported.',
      ),
      LessonSection(
        'Calorific value, gross and net',
        'Calorific value is the heat released when one cubic metre or kilogram of fuel is fully burned. Natural gas is roughly 38 to 40 MJ per cubic metre gross and around 90 percent of that net. The gross figure includes the latent heat in the water vapour produced; the net figure assumes that water leaves as vapour and its latent heat is lost. UK boiler efficiency is now quoted on the gross calorific value because modern condensing boilers actually recover that latent heat. Knowing both lets the engineer cross-check meter readings, gas rate calculations, and manufacturer heat input figures so that an installation can be commissioned correctly.',
      ),
      LessonSection(
        'Stoichiometric ratio and excess air',
        'Stoichiometric combustion is the chemically perfect mixture where all fuel and all oxygen react with nothing left over. For natural gas this is roughly one volume of gas to ten volumes of air. In practice burners are run with around 15 to 25 percent excess air to guarantee that every fuel molecule meets oxygen, even with imperfect mixing. Too little excess air and CO climbs as combustion goes incomplete; too much and the flue gas dilutes, dropping CO2 and lowering efficiency by carrying more heat up the flue. The sweet spot for a healthy gas appliance is around 9 percent CO2 and 4 to 5 percent O2 in the dry flue gas.',
      ),
    ],
  ),
  LessonTopic(
    id: 'flues_chimneys',
    title: 'Flues and chimneys',
    category: 'Fuels',
    summary:
        'Open, balanced and fan flues, terminal clearances, and inspection requirements.',
    sections: [
      LessonSection(
        'Open versus room-sealed appliances',
        'An open-flued appliance, sometimes called class I when fitted to a chimney, draws combustion air from the room and discharges products up a vertical flue under natural draught. The room must therefore have a permanent ventilator sized to the heat input, typically 5 cm2 per kW above 7 kW for gas. A balanced flue, often class C12 or C13, takes air from outside through a concentric or twin-pipe terminal and returns flue gas through the same terminal. The room is sealed, so spillage of products into the dwelling is far less likely. Modern condensing boilers are almost always room-sealed because the principle is inherently safer for the occupant.',
      ),
      LessonSection(
        'Fan-assisted and class FL flues',
        'A fan-flued appliance uses a fan in the flue path to overcome longer or more complex runs, allowing horizontal terminations away from the appliance and a smaller flue diameter. The boiler will have an air-pressure switch or fan-speed feedback to confirm that the flue is clear before opening the gas valve. Class FL is the modern designation for a manufacturer-specific concentric flue system that must be installed using only its proprietary components. Pipes must not be cut to non-listed lengths, joints must include the supplied seals, and every change of direction counts against the maximum permitted equivalent length quoted in the installation manual.',
      ),
      LessonSection(
        'Terminal clearances under Part J and Approved Document',
        'Building Regulations Approved Document J and BS 5440 set the required clearances around a flue terminal. Typical figures for a fanned balanced flue are 300 mm below an opening window, 600 mm to a facing surface, 300 mm from an internal corner, 75 mm from an eaves overhang, and 300 mm above ground level or a balcony. Distances increase for unflued appliances and for higher heat inputs. Plume management kits can redirect the visible water plume from a condensing boiler away from neighbours. Always verify the manufacturer table because some products specify larger clearances than the regulations and the stricter figure must be used.',
      ),
      LessonSection(
        'Inspection, lining and condensate',
        'Existing brick chimneys serving gas appliances usually need a flexible stainless steel liner of 904 grade, sized to the appliance manufacturer table and sealed at top and bottom with the correct cowl and closure plate. The liner protects masonry from acidic condensate and ensures the correct draught. Inspection involves checking continuity, joint integrity, terminal condition and that the route is unobstructed. On a condensing boiler the condensate trap and pipework must be checked for blockage, frost protection, and a continuous fall to a drain. Any sign of staining around joints or a damp patch on a chimney breast suggests products of combustion are escaping and the appliance must not remain in use.',
      ),
    ],
  ),
  LessonTopic(
    id: 'lpg_oil',
    title: 'LPG and oil installations',
    category: 'Fuels',
    summary:
        'Bulk LPG, cylinders, oil tank bunding, fire valves and ventilation rules.',
    sections: [
      LessonSection(
        'LPG bulk versus cylinders',
        'A bulk LPG installation uses a horizontal or vertical tank of typically 1200 to 2500 litres on a concrete base outside the building. The supplier owns and refills the vessel under a maintenance contract. Cylinder installations use 47 kg propane bottles in a manifolded pair with an automatic changeover valve so the supply continues when one cylinder empties. Bulk tanks must sit at least 3 m from buildings and 1.5 m from a property boundary unless a fire wall is fitted. Cylinders must stand upright on a firm base, in ventilation, away from cellars and drains because LPG is heavier than air and can pool in low spots and ignite explosively.',
      ),
      LessonSection(
        'Oil tank sizing and bunding',
        'Domestic oil tanks are sized on annual consumption, typically 1200 to 2500 litres for a UK home. Single-skin tanks must sit inside a separate masonry or proprietary bund capable of holding 110 percent of the tank capacity to contain a full release. Integrally bunded tanks combine both skins in one moulded unit and are now the default specification. The tank must stand on a non-combustible base larger than the tank footprint and, under OFTEC TI/133, be at least 1.8 m from the dwelling, 1.8 m from a boundary, 760 mm from a non-fire-rated eaves, and 600 mm from screening such as fences. Oil supply lines should be copper or steel with isolation at the tank.',
      ),
      LessonSection(
        'Fire valves and safety controls',
        'A remote-acting fire valve is mandatory on every oil-fired installation. Its sensor sits within 150 mm of the burner so that, in a fire, the fusible head melts and a tensioned cable releases a spring-loaded valve out at the tank or where the line enters the building. This stops fuel feeding the fire. LPG installations rely on flame failure devices in the appliance, an emergency control valve where the supply enters the dwelling, and excess flow valves at the bulk tank. All fittings between the cylinders and the building should be in supplied LPG-rated hose or copper, and joints must be tested with leak detection fluid or an electronic detector at every visit.',
      ),
      LessonSection(
        'Ventilation requirements',
        'Even sealed-room appliances need ventilation around the burner casing for cooling, and any room containing an open-flued LPG or oil appliance needs combustion air. The general rule for oil under OFTEC is 550 mm2 per kW of rated input above 5 kW for an internal appliance in a normal room. LPG appliances follow the same approach as natural gas but with awareness that any leak settles low, so high level vents alone are insufficient. Boiler houses and detached plant rooms always require both high and low level ventilation. Never block a ventilator to reduce draughts: the loss of combustion air will produce CO long before the occupant notices a flame change.',
      ),
    ],
  ),
];

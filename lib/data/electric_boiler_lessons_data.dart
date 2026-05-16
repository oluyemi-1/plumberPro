import 'lessons_data.dart';

/// Lesson topics covering UK electric boilers — an under-served area
/// where most engineers have only a passing familiarity. Used by the
/// lessons screen alongside the gas, oil and renewables topic files.
const electricBoilerLessonTopics = <LessonTopic>[
  LessonTopic(
    id: 'electric_boiler_overview',
    title: 'How an electric boiler actually works',
    category: 'Electric boiler',
    summary:
        'The first principles of an electric boiler — heating element, flow switch, thermostat, expansion — and when one is the right choice for a property.',
    sections: [
      LessonSection(
        'The basic idea',
        'An electric boiler heats water by passing current through an immersion-style element submerged directly in the system flow, in the same way a kettle heats water but built into a small wall-hung enclosure. There is no flame, no flue, no combustion air and no condensate. The unit takes a flow of primary water from the heating circuit, pushes it past the element with an internal pump, and returns it hot to the radiators or to a thermal store. Compared with a gas boiler the parts count is small — element, contactor, thermostat, overheat, pump, expansion vessel, pressure relief and a PCB — and that is where the reliability story comes from.',
      ),
      LessonSection(
        'Where they fit',
        'Electric boilers are most common in flats with no gas supply, in off-grid properties where oil or LPG storage is not wanted, and in retrofits where moving a flue terminal is impossible. They also show up as the back-up heat source in heat pump systems, as the dedicated heat source for a small annexe, and in zero-carbon new build projects looking for a simple regulated-electricity solution. They are rarely the cheapest to run because grid electricity is several times the unit price of natural gas, but they are the cheapest to install — no flue, no gas safe registration, no annual gas safety check.',
      ),
      LessonSection(
        'What the engineer must understand',
        'The two facts every engineer needs in their head before working on an electric boiler are simple. First, every kilowatt of heat output is also one kilowatt of electrical input, so a nine kilowatt boiler draws thirteen amps continuously when firing on a two hundred and thirty volt supply. Sizing the supply is sizing the boiler. Second, an element that runs dry will fail in seconds — every electric boiler must prove water flow and water level before it allows the contactor to close, and the engineer must understand what those proofs look like when they fail.',
      ),
      LessonSection(
        'Why so few engineers know them',
        'Electric boilers fall outside Gas Safe scope so they were historically taught by manufacturers rather than colleges. Most plumbers came up through gas, oil or apprentice routes that never touched them. The result is a market with growing demand — flats, MCS retrofits, off-grid properties — and a shrinking pool of engineers who actually understand the kit. Knowing the kit is therefore commercially valuable, not just technically interesting.',
      ),
    ],
  ),
  LessonTopic(
    id: 'electric_boiler_types',
    title: 'Types of electric boiler',
    category: 'Electric boiler',
    summary:
        'Wet versus dry elements, single versus multi-stage, modulating, flow-boiler versus combined cylinder, and where each pattern is appropriate.',
    sections: [
      LessonSection(
        'Wet element flow boilers',
        'The most common UK domestic pattern is a small wall-hung unit with a single sealed heat exchanger and one or more elements immersed in the system water. Common examples are the Elnur Mattira, the EHC SlimJim and the Heatrae Sadia Amptec. Output is typically four to fifteen kilowatts. They behave almost identically to a gas system boiler from the wet side — flow and return, expansion vessel, PRV, automatic air vent — but the heat source is electrical rather than combustion.',
      ),
      LessonSection(
        'Multi-element staging',
        'A nine kilowatt boiler may contain three three-kilowatt elements rather than one nine-kilowatt element. The control board switches them in sequence as demand grows, which is called staging. This gives finer control of output, spreads load so a single failed element does not kill the boiler completely, and lets the boiler run on a smaller supply when only one or two stages are active. Staging is the simplest form of modulation an electric boiler can offer.',
      ),
      LessonSection(
        'Modulating boilers',
        'A true modulating electric boiler can run any element at a fraction of its rated output using high-frequency switching or relay duty-cycling, often called burst-fire or phase-angle control. This matches output much more precisely to load, which is important when paired with weather compensation, an underfloor heating manifold, or a heat pump back-up role. Modulation also reduces electrical noise and contactor wear because the contactor closes once and lets the electronics do the rest.',
      ),
      LessonSection(
        'Combined boiler-and-cylinder units',
        'Some manufacturers integrate an unvented hot water cylinder directly above or beside the boiler in one chassis. The Heatrae Sadia Electromax and the EHC Comet are common examples. From the outside they look like a tall white floor-standing cabinet that delivers both heating and stored hot water. They are subject to the same G3 unvented requirements as any other unvented cylinder, including a competent person G3 certificate.',
      ),
      LessonSection(
        'Dry-core thermal storage boilers',
        'A separate family of products, often branded as Quantum or Slimjim Pulsar, stores heat in a ceramic or refractory core that is charged overnight on Economy seven, and then released through a fan or water loop during the day. These are not flow boilers — they are storage heaters reshaped as a wet heat source. They suit homes with cheap night-rate electricity and predictable daytime demand. Treat them as their own category, not the same kit as an instant flow boiler.',
      ),
    ],
  ),
  LessonTopic(
    id: 'electric_boiler_sizing',
    title: 'Sizing an electric boiler',
    category: 'Electric boiler',
    summary:
        'Picking the right kilowatt rating, matching it to the electrical supply, and the rules of thumb that separate a good install from a callout-magnet.',
    sections: [
      LessonSection(
        'Start with heat loss, not boiler ranges',
        'Every electric boiler sizing exercise begins with a room-by-room heat loss calculation under CIBSE design outdoor temperatures, exactly the same way a gas system would be sized. You cannot guess from floor area because electric is unforgiving of oversizing — an oversized electric boiler short-cycles, wears the contactors and pump, and runs less efficiently because of standing electrical losses. Aim to size the boiler within ten percent of the calculated peak load, not above it.',
      ),
      LessonSection(
        'Check the electrical supply first',
        'A nine kilowatt boiler needs about forty amps of headroom on a single-phase supply, a twelve kilowatt boiler about fifty-two amps, and anything above that almost always needs a three-phase supply. Before quoting any electric boiler the engineer must contact the DNO or check the customer\'s incoming consumer unit to confirm the supply is rated. In old properties with a sixty amp cut-out the supply is often the constraining factor, not the boiler choice. A supply upgrade can take weeks and cost more than the boiler.',
      ),
      LessonSection(
        'Hot water demand and storage',
        'A flow boiler producing instantaneous hot water through a plate exchanger is unusual on electric, because the kilowatt rating needed to heat a flowing tap is enormous — twenty-four kilowatts plus. Almost all electric boiler installs include a thermal store or unvented cylinder so hot water can be heated slowly. Size the cylinder for the household — typically two hundred litres for a family of four — and the boiler only needs to recover that volume over an hour or two, not deliver it at tap-flow rate.',
      ),
      LessonSection(
        'Underfloor heating and weather compensation',
        'Electric boilers pair well with underfloor heating because the lower flow temperatures, around forty degrees, mean shorter element-on times and reduced standing losses. Weather compensation should be considered standard on any new electric install — it cuts both energy and contactor wear by reducing the gap between flow setpoint and return. The control wiring for compensation is usually a simple zero to ten volt signal that the boiler maps to its output range.',
      ),
    ],
  ),
  LessonTopic(
    id: 'electric_boiler_install',
    title: 'Installing an electric boiler — regs, wiring and water',
    category: 'Electric boiler',
    summary:
        'The Part P, Part L, Part G and BS 7671 obligations specific to electric boilers, plus the wet-side install rules that catch out engineers used to gas.',
    sections: [
      LessonSection(
        'Electrical work is notifiable',
        'Any new dedicated circuit for an electric boiler is notifiable work under Building Regulations Part P in England and Wales. In practice that means a Part P registered electrician must either do the consumer unit and circuit, or a local authority building control notice must be raised. As a plumber you can install the boiler itself if the dedicated circuit is already in place and you only need to terminate the supply at the boiler\'s terminal block, but the design and the certification of the circuit must come from a qualified electrician. BS 7671 applies — RCD or RCBO protection, correctly sized cable, and a means of isolation within sight of the unit.',
      ),
      LessonSection(
        'Part L and SAP implications',
        'Electric boilers have a high SAP carbon factor compared with gas, so a like-for-like swap from gas to electric in a dwelling can fail a new-build SAP calculation under Part L. In retrofit it is usually permissible as a replacement of an existing electric heat source, or where no gas supply exists. If you are quoting an electric boiler into a property with gas already on, document the customer decision in writing and note any Part L implications for resale or EPC.',
      ),
      LessonSection(
        'Wet-side install rules',
        'A modern sealed electric boiler is installed exactly like a gas system boiler on the wet side. Twenty-two millimetre copper or composite flow and return, a filling loop, expansion vessel sized for the system volume, PRV discharge to outside through a tundish where required, automatic bypass valve to protect the pump, and a magnetic system filter on the return. The system must be flushed to BS 7593 before commissioning, dosed with a corrosion inhibitor, and ideally fitted with a TRV on every radiator except one bypass radiator. The element will not tolerate sludge — installs with no filter typically suffer element failure within three years.',
      ),
      LessonSection(
        'Commissioning checklist',
        'Before energising, prove the system is full and pressurised between one and one-point-five bar cold. Confirm the dedicated circuit terminates with the correct cable size into the manufacturer\'s terminals, with earth conductor proven for continuity. Verify the room thermostat or programmer wiring matches the boiler\'s switched-live input. Power on, watch the boiler complete its self-test, and observe one full fire cycle to setpoint and back. Hand the customer the benchmark logbook signed and the manufacturer\'s warranty card returned.',
      ),
    ],
  ),
  LessonTopic(
    id: 'electric_boiler_maintenance',
    title: 'Servicing and maintaining an electric boiler',
    category: 'Electric boiler',
    summary:
        'What an annual service should actually consist of, the parts that wear, and how to extend the life of an element.',
    sections: [
      LessonSection(
        'Why service if there is no combustion',
        'It is a common misconception that an electric boiler does not need servicing. There is no flue, no combustion, and no gas safety check — but the contactors, the pump, the expansion vessel, the inhibitor and the elements all degrade and benefit from an annual look. A boiler that has run for two years on poorly inhibited water can have visible scale on the elements and sludge in the pump housing, and that boiler will fail soon if nothing is done. Manufacturers require the service for warranty cover regardless of fuel.',
      ),
      LessonSection(
        'Annual service tasks',
        'Isolate the supply and prove dead before opening any cover. Check expansion vessel pressure and re-pressurise to the manufacturer figure, usually one bar. Test the PRV by lifting the test lever briefly. Inspect the element terminations for discoloration or corrosion. Drop a small sample of system water and test for inhibitor concentration with a proprietary test strip — top up if low. Open the magnetic filter, wipe the magnet, flush. Test the contactor for clean snap-action and listen for chatter when energised. Operate the boiler through one full firing cycle and confirm flow temperature stabilises at setpoint.',
      ),
      LessonSection(
        'Element replacement',
        'Elements are sacrificial — they will eventually scale, corrode, or burn out. Replacement is usually straightforward, similar in principle to replacing an immersion heater. Isolate, drain to below the element flange, undo the heat-resistant electrical termination, slacken the element by the spanner flat, withdraw, replace the gasket, refit, refill, vent, retest insulation resistance with a calibrated five hundred volt insulation tester to confirm the new element is sound before energising. Always replace with the manufacturer\'s original part — non-OEM elements often have the wrong flange profile or wattage stamp.',
      ),
      LessonSection(
        'Water quality is everything',
        'The single biggest factor in element life is system water quality. Sludge causes localised hot spots and burn-out. Hard limescale insulates the element from the water and forces it to run hotter to deliver the same heat, accelerating failure. A magnetic filter, an annual inhibitor check, and where hard water is the local norm a scale reducer on the cold fill, will more than double the working life of an element. Tell every customer this clearly on commissioning, ideally in writing.',
      ),
    ],
  ),
];

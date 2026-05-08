class CustomerExplainer {
  final String id;
  final String title;
  final String category;
  final String oneLine;
  final String script;

  const CustomerExplainer({
    required this.id,
    required this.title,
    required this.category,
    required this.oneLine,
    required this.script,
  });
}

const customerExplainers = <CustomerExplainer>[
  CustomerExplainer(
    id: 'rad_cold',
    title: 'Why your radiator is cold',
    category: 'Heating',
    oneLine: 'Air at the top, sludge at the bottom — what we are dealing with.',
    script:
        'So here is what is going on with your radiator. Hot water flows in, heats the metal, and the metal warms the room. If the top is cold but the bottom is warm, that usually means a bit of trapped air has worked its way up. Air does not carry heat, so the top stays cool. We just bleed it out with a little key, and it comes back to life. If the bottom is cold and the top is warm, that is the opposite problem — sludge and rust have settled at the base and water cannot flow through. That one needs a flush, and we may suggest a magnetic filter to stop it coming back.',
  ),
  CustomerExplainer(
    id: 'boiler_pressure',
    title: 'Why your boiler keeps losing pressure',
    category: 'Boiler',
    oneLine: 'A simple way to understand pressure drops in your system.',
    script:
        'Your boiler runs at a set pressure, a bit like the pressure in a car tyre. If that pressure keeps dropping, water is escaping somewhere. Most of the time it is one of three things. Either a tiny leak on a radiator, a pinhole on a pipe under the floor, or a worn part in the boiler called the expansion vessel that has lost its cushion of air. We will check the obvious places first, then test the vessel. The fix can be as small as tightening a valve, or as involved as recharging the vessel. Either way we will explain exactly what we find before we touch anything.',
  ),
  CustomerExplainer(
    id: 'power_flush',
    title: 'What a power flush is and when you need one',
    category: 'Heating',
    oneLine: 'A deep clean for the inside of your heating system.',
    script:
        'A power flush is basically a deep clean for the inside of your heating system. Over the years, tiny bits of rust break off the radiators and gather as black sludge at the bottom. That sludge blocks heat, makes the boiler work harder, and shortens its life. We connect a pump to your system, push clean water around at high speed with a special cleaner, and pull all that muck out. You usually do not need this every year — only if radiators are cold at the bottom, the boiler is noisy, or before fitting a new boiler so the warranty stays valid.',
  ),
  CustomerExplainer(
    id: 'magnetic_filter',
    title: 'Why we recommend a magnetic filter',
    category: 'Heating',
    oneLine: 'A small device that catches sludge before it harms the boiler.',
    script:
        'A magnetic filter is a small canister we fit on the pipe coming back into your boiler. Inside is a strong magnet. As the heating water passes through, any tiny iron particles get pulled out and stuck to the magnet, instead of being blasted into the boiler heat exchanger. We come once a year, unscrew the bottom, wipe out the black gunk, and put it back. It is one of the cheapest ways to make a boiler last longer and keep your radiators warm right to the top. Most boiler manufacturers actually require one for the warranty to remain valid.',
  ),
  CustomerExplainer(
    id: 'boiler_f1',
    title: 'Why your boiler shows F1 and what we do about it',
    category: 'Boiler',
    oneLine: 'A low-pressure fault — easy to explain, sometimes more to fix.',
    script:
        'F1 on most boilers means the pressure inside has dropped too low for the boiler to fire safely, so it has stopped itself for protection. The first step is simple: we top the pressure back up using the small filling loop under the boiler, and the fault clears. The bigger question is why it dropped in the first place. We check for any wet patches, look at the radiator valves, and test the expansion vessel. If it keeps happening every few weeks, there is a slow leak somewhere and we will track it down rather than just keep refilling.',
  ),
  CustomerExplainer(
    id: 'combi_no_hot',
    title: 'Why your hot water has gone cold',
    category: 'Hot water',
    oneLine: 'How a combi makes hot water — and what fails first.',
    script:
        'You have a combi boiler, which means it makes hot water on demand the moment you open a tap. There is no tank. Inside the boiler is a small heat exchanger that the cold mains water flows through, and a flame heats it as it passes. If the heating still works but the hot water has gone, the part that usually fails is a little plastic component called the diverter valve, or a sensor that tells the boiler you have asked for hot water. They are common, well-known faults and we carry the parts. We will diagnose properly first so we are not just guessing.',
  ),
  CustomerExplainer(
    id: 'unvented_discharge',
    title: 'Why your unvented cylinder has a discharge pipe outside',
    category: 'Hot water',
    oneLine: 'A safety pipe — required by law, never to be blocked.',
    script:
        'You have an unvented hot water cylinder, which stores hot water under mains pressure. That is great for strong showers, but the water expands as it heats up, and if anything ever went wrong it must have somewhere safe to go. That is the pipe you can see coming out of the wall outside. It is a safety route. If it ever drips or runs, that is the cylinder telling you a valve is letting by, and you should call us. The most important thing is never to block it, paint over it, or have it altered. It is a legal requirement.',
  ),
  CustomerExplainer(
    id: 'trv',
    title: 'What a TRV does and how to use it',
    category: 'Heating',
    oneLine: 'The numbered valve on the radiator — explained.',
    script:
        'The little valve on the side of your radiator with numbers from one to five is called a thermostatic radiator valve, or TRV for short. It is not a tap that you turn off and on — it is a thermostat for that one room. Set it to about three for a normal living temperature, lower in bedrooms, higher in a cold bathroom. Once the room reaches that temperature, the valve quietly closes and stops sending hot water in. You will save a noticeable amount on your gas bill simply by setting unused rooms to one or two instead of full open.',
  ),
  CustomerExplainer(
    id: 'softener',
    title: 'Why we install a softener in hard water areas',
    category: 'Hot water',
    oneLine: 'Limescale damages everything heat touches — here is the fix.',
    script:
        'In this area the water is hard, which simply means it carries dissolved chalk. Every time that water is heated, the chalk comes out of solution and sticks to the inside of the boiler, the kettle, the shower head, and the cylinder. Over a few years that limescale crust acts like a blanket on the heat exchanger and your bills creep up. A water softener swaps the chalk for a tiny amount of sodium before the water reaches your boiler, so nothing scales up. A simple scale reducer is a smaller, lower-cost option that protects the boiler only.',
  ),
  CustomerExplainer(
    id: 'service',
    title: 'What is happening when we service the boiler',
    category: 'Boiler',
    oneLine: 'Why an annual service is more than just a tick in a book.',
    script:
        'A proper boiler service is not just paperwork. We take the front off, vacuum out any dust, check the seals, and read the gas pressure. Then we use an analyser to measure the gases coming out of the flue and make sure the boiler is burning cleanly and safely. We also check the water pressure, the expansion vessel, and the safety controls. If anything is starting to wear, we catch it now while it is cheap rather than in February when it has stopped working. It also keeps your manufacturer warranty valid, which is worth a lot if something major goes wrong.',
  ),
  CustomerExplainer(
    id: 'toilet_running',
    title: 'Why your toilet is running and what has failed',
    category: 'Drainage',
    oneLine: 'The two parts inside the cistern that wear out.',
    script:
        'There are only two main parts inside a toilet cistern. The fill valve, which lets clean water in after a flush, and the flush valve at the bottom, which holds water until you press the handle. If you can hear water trickling all the time, one of those two has failed. Usually the rubber seal at the bottom has gone hard and water is creeping past it down into the pan. It is a common, inexpensive repair and we can normally do it in one visit. Left alone, a running toilet can waste hundreds of litres a day and add a real chunk to your bill.',
  ),
  CustomerExplainer(
    id: 'stop_tap',
    title: 'Why we charge for a seized stop tap',
    category: 'Survey',
    oneLine: 'And why fitting a modern isolation valve is worth it.',
    script:
        'Your main stop tap is the one valve that turns off all the water in the house. The trouble is, most are hidden under the kitchen sink and never touched for years, so the brass inside corrodes and they seize solid. When you ask us to swap a tap, we have to turn the water off first, and a stuck stop tap turns a thirty-minute job into a much bigger one. We will normally suggest fitting a modern lever isolation valve while we are there. After that, future jobs are quicker, you have peace of mind in a leak, and you only have to replace it once.',
  ),
  CustomerExplainer(
    id: 'care_guide',
    title: 'How to look after your boiler',
    category: 'Boiler',
    oneLine: 'A one-minute homeowner guide.',
    script:
        'Looking after a boiler is mostly about three small habits. First, glance at the pressure gauge once a month — if it is sitting between one and one and a half bar when cold, all is well. Second, run the heating for ten minutes once a month even in summer; it keeps the pump and valves from sticking. Third, get an annual service in late summer, before everyone needs theirs in November. If you ever smell gas, hear strange noises, or see water under it, turn it off and call us. That is it. A boiler that gets these three things tends to last fifteen years or more.',
  ),
  CustomerExplainer(
    id: 'bleed_key',
    title: 'What a bleed key does and how to use one safely',
    category: 'Heating',
    oneLine: 'How to bleed a radiator without making a mess.',
    script:
        'A bleed key is a small square key that fits the valve at the top corner of your radiator. Its job is to release any air trapped inside. To use one, turn the heating off and let the radiator cool, hold an old cup or cloth under the valve, and turn the key very slowly anti-clockwise — no more than a quarter turn. You will hear a hiss as air escapes, and once a steady drip of water comes out, close it back up gently. Do not over-tighten it. After bleeding, check the boiler pressure — it may have dropped a little and need a top up.',
  ),
  CustomerExplainer(
    id: 'drain_smell',
    title: 'Why your drains smell',
    category: 'Drainage',
    oneLine: 'Quick householder fix versus needing a plumber.',
    script:
        'A drain smell is almost always one of two things. The simple one is a dry trap — that is the U-bend under a sink or shower that should hold a little water as a seal against sewer gases. If a sink is rarely used, the water evaporates and smells creep up. Just run the tap for thirty seconds and the smell goes. The other cause is a partial blockage further down the line, where waste sits and rots. If running every tap does not clear it within a day, that is when you need us. We can put a camera down and find exactly where the problem is.',
  ),
  CustomerExplainer(
    id: 'leak_not_burst',
    title: 'Why a leak does not always mean a burst pipe',
    category: 'Survey',
    oneLine: 'Reassurance about a damp patch on the ceiling.',
    script:
        'A wet patch on a ceiling sounds dramatic, but most of the time it is not a burst pipe. Far more often it is a slow drip from a compression joint that has loosened over the years, a worn shower seal letting water past tiles, or condensation from a poorly insulated pipe in a cold loft. We will isolate the area, dry it out, and find the actual source before cutting any holes. A genuine burst is loud and obvious — water is everywhere within minutes. A slow stain that grows over weeks is almost always a small fix. So take a breath, and let us have a look.',
  ),
];

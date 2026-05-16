import 'package:flutter/material.dart';

class ToolEntry {
  final String name;
  final String category;
  final String purpose;
  final String howTo;
  final String commonErrors;
  final String safety;
  final IconData icon;
  // Optional photo asset path. When null the category icon is shown instead.
  final String? imagePath;

  const ToolEntry({
    required this.name,
    required this.category,
    required this.purpose,
    required this.howTo,
    required this.commonErrors,
    required this.safety,
    required this.icon,
    this.imagePath,
  });

  String get speakable =>
      '$name. $purpose. How to use. $howTo. Common errors. $commonErrors. Safety. $safety';
}

const toolEntries = <ToolEntry>[
  ToolEntry(
    name: 'Pipe slice (15 mm)',
    category: 'Cutting',
    purpose:
        'A small ratcheting cutter that produces a square cut on 15 mm copper tube in tight spaces.',
    howTo:
        'Slip the slice over the pipe, squeeze gently to engage the wheel, and rotate around the pipe. After each full turn, squeeze a touch tighter until the pipe parts.',
    commonErrors:
        'Tightening too much in one go ovalises the pipe; not enough pressure leaves a long groove without cutting through.',
    safety:
        'Keep fingers clear of the cutting wheel and de-burr the inside of the cut afterwards.',
    icon: Icons.content_cut_rounded,
    imagePath: 'assets/tools/pipe_slice_15mm.png',
  ),
  ToolEntry(
    name: 'Pipe slice (22 mm)',
    category: 'Cutting',
    purpose:
        'A slightly larger automatic slice for square cuts on 22 mm copper tube where a hacksaw will not fit.',
    howTo:
        'Place over the pipe, apply gentle pressure on the spring, and rotate steadily until you feel the cut break through. Re-tension only when the wheel stops biting.',
    commonErrors:
        'Forcing the cut burrs the bore badly; using on stainless or chrome ruins the wheel.',
    safety:
        'Always ream the inside edge after cutting to prevent flow restriction and scoring of seals.',
    icon: Icons.content_cut_rounded,
    imagePath: 'assets/tools/pipe_slice_22mm.png',
  ),
  ToolEntry(
    name: 'Hacksaw and junior hacksaw',
    category: 'Cutting',
    purpose:
        'A hand saw with a fine-toothed blade for cutting copper, plastic and threaded steel where a slice will not fit.',
    howTo:
        'Mark the cut, support the pipe close to the line, and use long even strokes letting the blade do the work. Finish with a file to square the end.',
    commonErrors:
        'Using a worn or coarse blade leaves a ragged edge and cuts off square; pressing too hard snaps the blade.',
    safety:
        'Mind your knuckles on the blade and keep the work clamped — never cut a pipe held in your hand.',
    icon: Icons.handyman_rounded,
    imagePath: 'assets/tools/hacksaw.png',
  ),
  ToolEntry(
    name: 'Reamer',
    category: 'Cutting',
    purpose:
        'Removes the internal burr left after cutting copper or plastic pipe so flow and seals are not compromised.',
    howTo:
        'Insert the conical end into the cut pipe and rotate one or two turns under light pressure. Wipe the swarf away before fitting any joint.',
    commonErrors:
        'Skipping the reaming step leaves a sharp lip that cuts compression olives and push-fit O-rings.',
    safety: 'The fresh cut edge is sharp — wear gloves while reaming.',
    icon: Icons.circle_outlined,
    imagePath: 'assets/tools/reamer.png',
  ),
  ToolEntry(
    name: 'Pipe wrench (Stillson)',
    category: 'Hand',
    purpose:
        'A heavy-duty toothed wrench for gripping and turning round iron and steel pipework.',
    howTo:
        'Adjust the jaw so the pipe sits firmly between the teeth and the back of the jaw. Apply force in the direction the jaws bite. Use two — one to hold, one to turn.',
    commonErrors:
        'Using on plated brass fittings leaves teeth marks; using one wrench alone twists the pipe further down the run.',
    safety:
        'Stand braced — the wrench can suddenly slip when a joint cracks free.',
    icon: Icons.build_rounded,
    imagePath: 'assets/tools/pipe_wrench.png',
  ),
  ToolEntry(
    name: 'Adjustable spanner',
    category: 'Hand',
    purpose:
        'A general-purpose spanner with a sliding jaw for tightening and undoing nuts of various sizes.',
    howTo:
        'Open the jaw, fit it over the nut, and close the worm screw fully so there is no play. Pull towards the fixed jaw, never push against the moving jaw.',
    commonErrors:
        'A loose jaw rounds off the corners of brass nuts; using on a tap back-nut without holding the body twists the pipework.',
    safety:
        'Do not extend the handle with a pipe — choose a bigger spanner instead.',
    icon: Icons.settings_rounded,
    imagePath: 'assets/tools/adjustable_spanner.png',
  ),
  ToolEntry(
    name: 'Basin wrench (cranked spanner)',
    category: 'Hand',
    purpose:
        'A long offset spanner for reaching tap back-nuts up behind a basin or sink where no other tool fits.',
    howTo:
        'Hook the spring-loaded jaw over the back-nut, line the handle up clear of the bowl, and turn. Reverse the head to swap from undoing to tightening.',
    commonErrors:
        'Wrong-way jaw will simply slip; not seating the jaw fully chews the brass.',
    safety:
        'Brace your other hand against the cabinet — these spanners can bite back if they slip.',
    icon: Icons.engineering_rounded,
    imagePath: 'assets/tools/basin_wrench.png',
  ),
  ToolEntry(
    name: 'Compression spanner set',
    category: 'Joining',
    purpose:
        'Open-ended spanners sized to match common compression fittings — typically 15, 22 and 28 mm.',
    howTo:
        'Use one spanner on the body of the fitting and a second on the nut, turning them in opposition. Tighten only until firm, then a small extra nudge.',
    commonErrors:
        'Over-tightening crushes the olive and the joint will weep; under-tightening leaves a slow leak that only shows up after pressure-up.',
    safety:
        'Always hold the body — turning the nut alone twists the pipe and stresses other joints.',
    icon: Icons.build_circle_rounded,
    imagePath: 'assets/tools/compression_spanner.png',
  ),
  ToolEntry(
    name: 'Blow torch / gas torch',
    category: 'Joining',
    purpose:
        'A handheld propane or MAPP torch used to heat copper joints for soldering.',
    howTo:
        'Light the torch, set a steady blue inner cone, and play the flame around the fitting evenly until solder melts on contact. Feed in solder and let capillary action pull it into the joint.',
    commonErrors:
        'Heating the solder rather than the fitting causes a cold joint; over-heating burns the flux black and the joint will leak.',
    safety:
        'Use a heat mat behind the work, keep an extinguisher to hand, and observe a hot-works watch period after.',
    icon: Icons.local_fire_department_rounded,
    imagePath: 'assets/tools/blow_torch.png',
  ),
  ToolEntry(
    name: 'Solder and flux brush',
    category: 'Joining',
    purpose:
        'Lead-free solder wire and a small brush for applying flux paste to clean copper before heating.',
    howTo:
        'Clean the pipe and fitting bright, brush a thin even layer of flux on both, assemble, and heat. Touch solder to the joint mouth and watch it draw fully around.',
    commonErrors:
        'Too much flux causes drips and corrosion later; dirty pipe stops the solder running into the joint.',
    safety:
        'Flux is mildly corrosive — wash hands afterwards and wipe excess off finished joints with a damp cloth.',
    icon: Icons.brush_rounded,
    imagePath: 'assets/tools/solder_and_flux_brush.png',
  ),
  ToolEntry(
    name: 'Heat-resistant mat',
    category: 'Joining',
    purpose:
        'A flame-proof pad placed behind the joint to protect timber, plaster and other surfaces during soldering.',
    howTo:
        'Position the mat directly behind the fitting so the flame, when it inevitably wraps around, hits the mat rather than the building fabric.',
    commonErrors:
        'Using a single small mat in a confined space leaves edges exposed; reusing a charred mat reduces protection.',
    safety:
        'Always do a hot-works check fifteen minutes after finishing — embers can smoulder undetected.',
    icon: Icons.shield_rounded,
    imagePath: 'assets/tools/heat_resistant_mat.png',
  ),
  ToolEntry(
    name: 'Pipe bender (hand spring)',
    category: 'Bending',
    purpose:
        'An internal or external spring that supports the pipe wall while a gentle bend is formed by hand.',
    howTo:
        'Slide the spring over or into the pipe at the bend point, bend gently across your knee, then twist the spring slightly to release.',
    commonErrors:
        'Trying to bend too tight a radius kinks the pipe; failing to lubricate an internal spring makes it stick.',
    safety:
        'Watch for the pipe ends whipping back as it springs — keep your face clear.',
    icon: Icons.sync_alt_rounded,
    imagePath: 'assets/tools/pipe_bender_hand_spring.png',
  ),
  ToolEntry(
    name: 'Pipe bender (lever / machine)',
    category: 'Bending',
    purpose:
        'A floor-standing or hand-held lever bender that produces accurate, repeatable bends in 15, 22 and 28 mm copper.',
    howTo:
        'Mark the centreline of the bend, set the pipe in the correct former, hook the back stop, and pull the lever smoothly to the desired angle on the scale.',
    commonErrors:
        'Using the wrong former oval-flattens the pipe; ignoring the deduction figure means the bend lands in the wrong place.',
    safety:
        'Keep feet clear of the long lever and never stand in line of the swing.',
    icon: Icons.architecture_rounded,
    imagePath: 'assets/tools/pipe_bender_machine.png',
  ),
  ToolEntry(
    name: 'Push-fit insert tool',
    category: 'Joining',
    purpose:
        'A small plastic or metal sleeve insertion tool that supports plastic pipe ends before pushing into a fitting.',
    howTo:
        'Cut the pipe square, ream and chamfer the end, fit the correct insert, mark the insertion depth, and push the pipe fully home until the mark disappears.',
    commonErrors:
        'Forgetting the insert lets the pipe collapse and leak; a partial push leaves the joint short of the O-ring.',
    safety:
        'Always test the joint by pulling firmly — push-fits that are not fully home can blow out under pressure.',
    icon: Icons.input_rounded,
    imagePath: 'assets/tools/push_fit_insert_tool.png',
  ),
  ToolEntry(
    name: 'Disconnecting tongs',
    category: 'Joining',
    purpose:
        'Curved tongs that compress a push-fit collet so the pipe can be released cleanly without damaging the fitting.',
    howTo:
        'Isolate and depressurise the line, slip the tongs around the collet at the joint mouth, squeeze to push the collet in, and pull the pipe straight out.',
    commonErrors:
        'Trying to remove a push-fit by hand chews the collet teeth; pulling without compressing locks it tighter.',
    safety:
        'Always confirm the line is dead — releasing a pressurised push-fit can soak the area or scald.',
    icon: Icons.unfold_less_rounded,
    imagePath: 'assets/tools/disconnecting_tongs.png',
  ),
  ToolEntry(
    name: 'Crimping tool (press-fit)',
    category: 'Joining',
    purpose:
        'A battery-powered jaw tool that permanently crimps press-fit fittings onto copper or stainless tube.',
    howTo:
        'Cut and ream the pipe, mark the insertion depth, fit the press fitting, choose the matching jaw, and run a full crimp cycle until the tool releases.',
    commonErrors:
        'A partial cycle leaves an unsealed joint; using the wrong jaw profile damages the fitting.',
    safety:
        'Keep fingers clear of the closing jaws — they exert several tonnes of force.',
    icon: Icons.compress_rounded,
    imagePath: 'assets/tools/crimping_tool.png',
  ),
  ToolEntry(
    name: 'Pressure test pump',
    category: 'Testing',
    purpose:
        'A hand pump with a gauge used to pressurise a finished pipework system with water to verify it holds.',
    howTo:
        'Cap all open ends, connect the pump to a drain point, fill with water and pump up to the test pressure. Hold and watch the gauge for the specified period.',
    commonErrors:
        'Leaving air in the system gives a false drop; testing above the rated pressure of the weakest fitting causes blow-outs.',
    safety:
        'Stand back from any test cap during pressurisation and depressurise slowly afterwards.',
    icon: Icons.speed_rounded,
    imagePath: 'assets/tools/pressure_test_pump.png',
  ),
  ToolEntry(
    name: 'Manometer',
    category: 'Testing',
    purpose:
        'A U-tube or digital instrument for measuring gas pressure at appliance test points.',
    howTo:
        'Zero the gauge, connect to the test nipple with the appliance off, then turn the appliance on and read the working pressure against the manufacturer specification.',
    commonErrors:
        'Forgetting to zero gives misleading readings; loose connections leak gas during the test.',
    safety:
        'Only Gas Safe registered engineers may take live readings; always leak-test the connection before opening the test point.',
    icon: Icons.show_chart_rounded,
    imagePath: 'assets/tools/manometer.png',
  ),
  ToolEntry(
    name: 'Combustion analyser (FGA)',
    category: 'Testing',
    purpose:
        'A flue gas analyser that measures CO, CO2 and ratio to verify safe and efficient combustion.',
    howTo:
        'Calibrate in fresh air, insert the probe in the flue test point with the boiler running at full and low rate, and record the readings against the bench-test sticker.',
    commonErrors:
        'Probing before the appliance has stabilised gives high CO; ignoring a high ratio masks an unsafe boiler.',
    safety:
        'A high CO reading or ratio above 0.004 means turn the appliance off and investigate — never sign it off.',
    icon: Icons.air_rounded,
    imagePath: 'assets/tools/combustion_analyser.png',
  ),
  ToolEntry(
    name: 'Multi-meter',
    category: 'Testing',
    purpose:
        'An electrical instrument for measuring voltage, continuity and resistance on appliance controls.',
    howTo:
        'Select the correct range, place probes across the component or terminal, and read the value. Use continuity mode for switches and thermistors against a known table.',
    commonErrors:
        'Using the wrong range damages the meter; failing to isolate first risks a shock.',
    safety:
        'Always prove the meter dead-live-dead on a known supply before relying on a zero reading.',
    icon: Icons.electric_bolt_rounded,
    imagePath: 'assets/tools/multi_meter.png',
  ),
  ToolEntry(
    name: 'Gas leak detector',
    category: 'Testing',
    purpose:
        'A leak-detection spray or electronic sniffer used to find escapes on gas joints.',
    howTo:
        'Apply spray liberally to each joint and watch for bubbles, or pass the electronic probe slowly along the joint and listen for the alarm.',
    commonErrors:
        'A weak spray that does not foam misses small leaks; an uncalibrated sniffer alarms on background gas.',
    safety:
        'On any positive find, isolate the supply at the meter and do not relight until the leak is sealed and re-tested.',
    icon: Icons.gas_meter_rounded,
    imagePath: 'assets/tools/gas_leak_detector.png',
  ),
  ToolEntry(
    name: 'Drain rods (set with attachments)',
    category: 'Clearing',
    purpose:
        'Threaded flexible rods with screw-on heads for clearing blockages in underground drains.',
    howTo:
        'Lift the manhole, screw rods together, fit the appropriate head, and feed in turning clockwise so joints do not unscrew. Push and pull rhythmically until flow returns.',
    commonErrors:
        'Turning anti-clockwise unscrews a rod down the drain; over-extending without rotation jams the rods solid.',
    safety:
        'Wear gauntlets and eye protection — drains contain pathogens. Wash thoroughly after use.',
    icon: Icons.linear_scale_rounded,
    imagePath: 'assets/tools/drain_rods.png',
  ),
  ToolEntry(
    name: 'Plunger (sink and WC types)',
    category: 'Clearing',
    purpose:
        'A rubber cup tool for clearing simple blockages by hydraulic pressure pulses.',
    howTo:
        'Cover the cup with water, seal it over the waste outlet, and pump firmly several times keeping the seal. The blockage either pushes through or breaks up.',
    commonErrors:
        'Trying to plunge with no water gives no force; using a sink cup on a WC will not seal the trap.',
    safety:
        'After clearing, run a generous rinse of clean water and disinfect the plunger — splashes are inevitable.',
    icon: Icons.shower_rounded,
    imagePath: 'assets/tools/plunger.png',
  ),
  ToolEntry(
    name: 'Drain auger / snake',
    category: 'Clearing',
    purpose:
        'A flexible cable with a corkscrew end used to clear blockages inside small-bore wastes such as sinks and showers.',
    howTo:
        'Feed the head into the trap or rodding eye, crank the handle clockwise, and advance gently. When you feel resistance, work the cable in and out until it breaks through.',
    commonErrors:
        'Forcing the auger past a sharp bend kinks the cable; rotating the wrong way unwinds the head off in the pipe.',
    safety:
        'Wear gloves and goggles — when the blockage gives way, dirty water can splash out of the trap.',
    icon: Icons.cable_rounded,
    imagePath: 'assets/tools/drain_auger.png',
  ),
  ToolEntry(
    name: 'Wet-vac for power flushing',
    category: 'Clearing',
    purpose:
        'A heavy-duty vacuum used during power flushing to capture dirty water and sludge as it leaves the system.',
    howTo:
        'Connect the discharge hose to a suitable container or directly into the wet-vac inlet, empty the tank between radiators, and wipe down the magnet head.',
    commonErrors:
        'Allowing the tank to overfill stalls the motor; not earthing the unit on a long lead trips the RCD.',
    safety:
        'The waste water is hot and stains badly — protect carpets and never empty into a foul drain that cannot cope.',
    icon: Icons.cleaning_services_rounded,
    imagePath: 'assets/tools/wet_vac.png',
  ),
  ToolEntry(
    name: 'Inspection camera',
    category: 'Testing',
    purpose:
        'A small CCTV head on a flexible rod for visually inspecting drains, voids and behind boilers.',
    howTo:
        'Feed the head in, turn on the LEDs, and watch the screen as you advance. Mark the distance at any point of interest using the cable footage indicator.',
    commonErrors:
        'A dirty lens shows nothing; a kinked rod loses image. Always clean and recoil neatly between jobs.',
    safety:
        'Wash and disinfect the head after every drain use — never lay it down on customer surfaces.',
    icon: Icons.videocam_rounded,
    imagePath: 'assets/tools/inspection_camera.png',
  ),
  ToolEntry(
    name: 'Water meter / flow cup',
    category: 'Measuring',
    purpose:
        'A weir cup or in-line flow meter used to measure delivered flow rate at a tap or shower in litres per minute.',
    howTo:
        'Hold the cup under the open tap, allow it to fill to the marked line, and read the flow rate from the side scale. Check both hot and cold separately.',
    commonErrors:
        'A partial seal under the spout under-reads; misaligned with the spout splashes water everywhere.',
    safety:
        'Take care with hot water — use the cup at a moderate temperature setting where possible.',
    icon: Icons.water_drop_rounded,
    imagePath: 'assets/tools/flow_cup.png',
  ),
  ToolEntry(
    name: 'Pipe locator',
    category: 'Measuring',
    purpose:
        'An electromagnetic device that traces the route of buried metal pipes and cables.',
    howTo:
        'Connect the transmitter to a suitable access point, switch on the receiver, and walk slowly along the suspected run watching the signal rise and fall.',
    commonErrors:
        'Cross-talk from nearby cables gives a false trace; weak battery in the transmitter halves the range.',
    safety:
        'Always assume any unknown service may be live electric — confirm with a CAT scanner before digging.',
    icon: Icons.travel_explore_rounded,
    imagePath: 'assets/tools/pipe_locator.png',
  ),
  ToolEntry(
    name: 'Acoustic leak detector',
    category: 'Testing',
    purpose:
        'A ground microphone or contact probe that listens for the hiss of a pressurised water leak.',
    howTo:
        'Pressurise the suspect line, set the gain low, and walk slowly along the run. Increase gain only when traffic and household noise are minimal.',
    commonErrors:
        'High gain in a noisy environment generates false hot-spots; a heavy hand on the headphones masks the leak signature.',
    safety:
        'Beware of trip hazards while wearing headphones — keep one ear free near roads.',
    icon: Icons.hearing_rounded,
    imagePath: 'assets/tools/acoustic_leak_detector.png',
  ),
  ToolEntry(
    name: 'Thermal camera',
    category: 'Testing',
    purpose:
        'An infrared camera that shows surface temperature, useful for tracing buried hot pipes and finding cold spots in radiators.',
    howTo:
        'Allow the camera to acclimatise, set a sensible temperature span, and scan slowly. Save key images with the customer reference for the report.',
    commonErrors:
        'Reflective surfaces give false low readings; a too-wide span hides the small differences you are looking for.',
    safety:
        'Do not rely on thermal alone for live electrical diagnosis — confirm with proper electrical testing.',
    icon: Icons.thermostat_rounded,
    imagePath: 'assets/tools/thermal_camera.png',
  ),
  ToolEntry(
    name: 'Magnetic filter',
    category: 'Testing',
    purpose:
        'A central-heating system filter containing a strong magnet that captures iron oxide sludge from circulating water.',
    howTo:
        'Service annually by isolating the valves, opening the drain plug into a container, removing the magnet, and wiping the canister clean before reassembling.',
    commonErrors:
        'Forgetting to close the bleed before refilling spills water everywhere; not retorquing the cap leads to weeps.',
    safety:
        'The water is hot and stains carpets badly — use a tray and lay down dust sheets before opening.',
    icon: Icons.filter_alt_rounded,
    imagePath: 'assets/tools/magnetic_filter.png',
  ),
  ToolEntry(
    name: 'PTFE tape',
    category: 'Joining',
    purpose:
        'A thin plastic tape wound onto male threads to provide a seal on parallel and tapered fittings.',
    howTo:
        'Hold the thread with the end pointing away, wrap clockwise four to six turns under tension, and press firmly into the threads before assembling.',
    commonErrors:
        'Wrapping the wrong way unwinds when tightening; too few turns leak, too many split the female fitting.',
    safety:
        'Use the correct tape — gas thread tape is yellow and thicker; do not substitute white water-grade on gas joints.',
    icon: Icons.layers_rounded,
    imagePath: 'assets/tools/ptfe_tape.png',
  ),
  ToolEntry(
    name: 'Hemp and paste',
    category: 'Joining',
    purpose:
        'Traditional sealing system using natural hemp fibres laid into a paste-coated thread for tapered iron fittings.',
    howTo:
        'Smear paste into the male thread, lay a thin band of hemp into the spiral starting at the second turn, smear more paste over, and tighten home.',
    commonErrors:
        'Too much hemp splits the female thread on tightening; too little leaks under pressure.',
    safety:
        'Wash off paste smears before they cure — some types are mildly irritating to skin.',
    icon: Icons.grass_rounded,
    imagePath: 'assets/tools/hemp_and_paste.png',
  ),
  ToolEntry(
    name: 'Spirit level',
    category: 'Measuring',
    purpose:
        'A bubble level used to set radiators, basins and pipework true to horizontal or vertical.',
    howTo:
        'Place on the work, allow the bubble to settle, and read between the lines. For long runs, use a level long enough to span obvious dips.',
    commonErrors:
        'Reading from above an angle gives a false centred bubble; a knocked level no longer reads true and should be rechecked.',
    safety:
        'No specific hazard, but a dropped level can spike a foot — keep it on a strap or in a pouch on ladders.',
    icon: Icons.straighten_rounded,
    imagePath: 'assets/tools/spirit_level.png',
  ),
  ToolEntry(
    name: 'Plumb bob',
    category: 'Measuring',
    purpose:
        'A weighted line that hangs perfectly vertical, used to set risers and align stacks accurately.',
    howTo:
        'Suspend the bob from a fixed point and allow it to settle without swing. Mark the floor directly under the point for a true vertical reference.',
    commonErrors:
        'Reading while the bob is still swinging gives a moving target; draughts ruin accuracy.',
    safety:
        'Take care above head height — a dropped plumb bob hits hard.',
    icon: Icons.vertical_align_center_rounded,
    imagePath: 'assets/tools/plumb_bob.png',
  ),
  ToolEntry(
    name: 'Tape measure',
    category: 'Measuring',
    purpose:
        'A retractable steel tape for measuring pipe runs, hole spacings and component sizes.',
    howTo:
        'Hook the end on the start point, draw out smoothly, and read the dimension at the finish. Lock the blade for repeated marks at the same distance.',
    commonErrors:
        'Reading from a bent or rolled-back end gives a wrong start; letting the tape snap back wears the spring and the hook.',
    safety:
        'The blade has a sharp edge — guide it back with your thumb rather than letting it whip into the case.',
    icon: Icons.straighten_outlined,
    imagePath: 'assets/tools/tape_measure.png',
  ),
  ToolEntry(
    name: 'Stanley knife / utility knife',
    category: 'Cutting',
    purpose:
        'A retractable bladed knife for trimming pipe insulation, lagging and packaging.',
    howTo:
        'Extend only the blade length you need, cut on a firm surface drawing the blade away from your body, and retract immediately when finished.',
    commonErrors:
        'Cutting towards the holding hand causes most workshop injuries; a blunt blade slips and tears insulation.',
    safety:
        'Change the blade often — sharp blades cut where you point them; blunt blades cut where you do not.',
    icon: Icons.crop_rounded,
    imagePath: 'assets/tools/utility_knife.png',
  ),
  ToolEntry(
    name: 'Hole saw set',
    category: 'Power',
    purpose:
        'A set of cylindrical saws driven by a drill for cutting clean round holes through joists, studs and panels for pipe runs.',
    howTo:
        'Fit the correct diameter saw and pilot drill, mark the centre, run the drill at moderate speed, and ease off as the saw breaks through to avoid splintering.',
    commonErrors:
        'Forcing the cut overheats and blunts the teeth; too high a speed burns through timber and ruins steel saws.',
    safety:
        'Always check both sides for cables and pipes before drilling, and clamp the work where possible.',
    icon: Icons.donut_large_rounded,
    imagePath: 'assets/tools/hole_saw_set.png',
  ),
  ToolEntry(
    name: 'SDS drill',
    category: 'Power',
    purpose:
        'A heavy-duty hammer drill used with SDS bits for boring through masonry for pipe routes and fixings.',
    howTo:
        'Select bit, set the mode to rotary-with-hammer for masonry, hold the drill firmly with both hands, and let the tool do the work.',
    commonErrors:
        'Using hammer mode on tile cracks the surface; pushing too hard stalls the motor.',
    safety:
        'Use a CAT scanner first, wear safety glasses and ear protection, and keep loose clothing clear of the chuck.',
    icon: Icons.power_rounded,
    imagePath: 'assets/tools/sds_drill.png',
  ),
  ToolEntry(
    name: 'Screw extractors',
    category: 'Hand',
    purpose:
        'Hardened reverse-thread bits for removing snapped or rounded screws and broken stud ends.',
    howTo:
        'Drill a small pilot into the broken screw, tap the extractor in firmly, and turn anti-clockwise with a tap wrench until the broken piece backs out.',
    commonErrors:
        'A small drill in hardened steel snaps off the extractor itself; over-torquing breaks the extractor in the hole and makes things worse.',
    safety:
        'Wear safety glasses — extractors are very hard and shatter rather than bend if they break.',
    icon: Icons.rotate_left_rounded,
    imagePath: 'assets/tools/screw_extractor.png',
  ),
  ToolEntry(
    name: 'Adjustable hop-up / step ladder',
    category: 'Hand',
    purpose:
        'A small platform or ladder providing safe access for boiler, loft and ceiling-height work.',
    howTo:
        'Set on a level surface, deploy any spreader bars or stabilisers fully, and climb facing the steps keeping three points of contact.',
    commonErrors:
        'Using a folded step on uneven flooring tips it; reaching too far sideways topples the user.',
    safety:
        'Never stand on the top step of a step ladder. Inspect the stiles and feet before each use.',
    icon: Icons.stairs_rounded,
    imagePath: 'assets/tools/step_ladder.png',
  ),
];

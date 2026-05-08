/// Reference data for the heat pump installer module.
///
/// Numbers are taken from CIBSE Domestic Heating Design Guide and the MCS
/// Heat Pump Installation Standard (MIS 3005), simplified for trainee use.
library;

import 'dart:math' as math;

class UValuePreset {
  final String label;
  final double uValue; // W/m²·K
  const UValuePreset(this.label, this.uValue);
}

const wallUValues = <UValuePreset>[
  UValuePreset('Solid brick — uninsulated', 2.1),
  UValuePreset('Cavity wall — uninsulated', 1.6),
  UValuePreset('Cavity wall — insulated', 0.55),
  UValuePreset('Internally insulated solid wall', 0.45),
  UValuePreset('External wall insulation retrofit', 0.30),
  UValuePreset('New build (Part L 2021)', 0.18),
  UValuePreset('PassivHaus', 0.12),
];

const windowUValues = <UValuePreset>[
  UValuePreset('Single glazed', 5.0),
  UValuePreset('Old double (pre-2010)', 2.8),
  UValuePreset('Modern double (Part L)', 1.4),
  UValuePreset('Triple glazed', 0.9),
];

const roofUValues = <UValuePreset>[
  UValuePreset('Uninsulated roof', 2.5),
  UValuePreset('100 mm loft insulation', 0.40),
  UValuePreset('270 mm loft insulation', 0.16),
  UValuePreset('Modern warm roof (Part L 2021)', 0.13),
];

const floorUValues = <UValuePreset>[
  UValuePreset('Suspended timber — uninsulated', 1.0),
  UValuePreset('Suspended timber — insulated', 0.40),
  UValuePreset('Solid concrete — uninsulated', 0.85),
  UValuePreset('Solid concrete — modern (Part L)', 0.18),
];

const doorUValues = <UValuePreset>[
  UValuePreset('Solid timber', 3.0),
  UValuePreset('Modern composite / insulated', 1.4),
];

class RoomTypePreset {
  final String label;
  final double designTemp; // °C
  final double airChangesPerHour;
  const RoomTypePreset(
    this.label, {
    required this.designTemp,
    required this.airChangesPerHour,
  });
}

const roomTypes = <RoomTypePreset>[
  RoomTypePreset('Lounge / living', designTemp: 21, airChangesPerHour: 1.5),
  RoomTypePreset('Dining room', designTemp: 21, airChangesPerHour: 1.5),
  RoomTypePreset('Kitchen', designTemp: 18, airChangesPerHour: 2.0),
  RoomTypePreset('Bedroom', designTemp: 18, airChangesPerHour: 1.0),
  RoomTypePreset('Bathroom / en-suite', designTemp: 22, airChangesPerHour: 2.0),
  RoomTypePreset('Hall / landing', designTemp: 18, airChangesPerHour: 1.5),
  RoomTypePreset('Utility', designTemp: 18, airChangesPerHour: 1.5),
  RoomTypePreset('Study / office', designTemp: 21, airChangesPerHour: 1.0),
  RoomTypePreset('WC', designTemp: 18, airChangesPerHour: 1.5),
];

/// CIBSE design outdoor temperatures by region — used as defaults.
class DesignOAT {
  final String region;
  final double oat;
  const DesignOAT(this.region, this.oat);
}

const designOATs = <DesignOAT>[
  DesignOAT('London / South East', -2),
  DesignOAT('Midlands', -3),
  DesignOAT('North England / Wales', -3.5),
  DesignOAT('Scotland — central belt', -4),
  DesignOAT('Scotland — Highlands', -5),
  DesignOAT('Northern Ireland', -3),
];

/// MCS 020 sound — typical reflection corrections (dB).
class ReflectionPreset {
  final String label;
  final double dB;
  const ReflectionPreset(this.label, this.dB);
}

const reflectionPresets = <ReflectionPreset>[
  ReflectionPreset('Free field (open garden)', 0),
  ReflectionPreset('On a hard surface (1 wall close)', 3),
  ReflectionPreset('In a corner (2 walls)', 6),
  ReflectionPreset('Three reflective surfaces', 9),
];

/// Common refrigerants seen on UK domestic heat pumps.
class Refrigerant {
  final String name;
  final String safetyClass; // e.g. 'A2L', 'A3', 'A1'
  final int gwp;
  final String charge; // typical charge / availability note
  final String note;
  const Refrigerant({
    required this.name,
    required this.safetyClass,
    required this.gwp,
    required this.charge,
    required this.note,
  });
}

const refrigerants = <Refrigerant>[
  Refrigerant(
    name: 'R32',
    safetyClass: 'A2L (mildly flammable)',
    gwp: 675,
    charge: '0.8–1.5 kg in a 5–8 kW domestic ASHP',
    note:
        'Currently the most common refrigerant on UK domestic heat pumps. Lower GWP than R410A, but still subject to F-gas controls and a phase-down.',
  ),
  Refrigerant(
    name: 'R290 (propane)',
    safetyClass: 'A3 (highly flammable)',
    gwp: 3,
    charge: 'Typically below 1 kg per circuit',
    note:
        'Increasingly common on monobloc heat pumps because the GWP is essentially zero. Safety class A3 means strict siting rules and ignition source separation.',
  ),
  Refrigerant(
    name: 'R454B',
    safetyClass: 'A2L',
    gwp: 466,
    charge: 'Similar to R32',
    note:
        'A blend designed as a near drop-in replacement for R410A. Lower GWP than R32, used on some newer heat pumps.',
  ),
  Refrigerant(
    name: 'R744 (CO₂)',
    safetyClass: 'A1 (non-flammable)',
    gwp: 1,
    charge: 'High pressure system, specialised equipment',
    note:
        'Used in some commercial heat pumps and DHW heat pumps. Operates at very high pressures, requires specialist competence.',
  ),
  Refrigerant(
    name: 'R410A',
    safetyClass: 'A1',
    gwp: 2088,
    charge: 'Legacy systems only',
    note:
        'Phased out for new equipment due to high GWP. Encountered on existing systems being serviced or replaced.',
  ),
];

/// Radiator de-rating: convert a heat-output figure quoted at a Δt of 50 K
/// to the actual output at any mean-water-to-air Δt.
///
/// Output[Δt] = Output[Δt 50] × (Δt / 50)^n.  n is the radiator coefficient,
/// typically 1.30 for steel panel radiators.
double radiatorOutputAt({
  required double ratedOutputDt50,
  required double meanWaterTemp,
  required double roomTemp,
  double radiatorExponent = 1.30,
}) {
  final dt = (meanWaterTemp - roomTemp).abs();
  if (dt <= 0) return 0;
  final factor =
      _pow(dt / 50.0, radiatorExponent);
  return ratedOutputDt50 * factor;
}

/// Reverse calculation — given a required output at the new Δt, what rating
/// (at Δt 50 K) is needed?
double radiatorRequiredRatingDt50({
  required double requiredOutputAtNewDt,
  required double meanWaterTemp,
  required double roomTemp,
  double radiatorExponent = 1.30,
}) {
  final dt = (meanWaterTemp - roomTemp).abs();
  if (dt <= 0) return double.infinity;
  final factor = _pow(dt / 50.0, radiatorExponent);
  if (factor <= 0) return double.infinity;
  return requiredOutputAtNewDt / factor;
}

double _pow(double base, double exponent) {
  if (base <= 0) return 0;
  return math.pow(base, exponent).toDouble();
}

/// Domestic heat pump capacity rule of thumb.
class HeatPumpSizingResult {
  final double designHeatLossKw;
  final double dhwAllowanceKw;
  final double recommendedCapacityKw;
  final String capacityBand;
  const HeatPumpSizingResult({
    required this.designHeatLossKw,
    required this.dhwAllowanceKw,
    required this.recommendedCapacityKw,
    required this.capacityBand,
  });
}

HeatPumpSizingResult sizeHeatPump({
  required double heatLossKw,
  required int occupants,
  bool dhwBlend = true,
}) {
  // DHW allowance is typically 0.3 to 0.5 kW per occupant if the cylinder
  // recovers in the daytime, ignored here if heating dominates.
  final dhwAllowance = dhwBlend ? occupants * 0.4 : 0.0;
  final recommended = heatLossKw + dhwAllowance;
  final band = recommended <= 5
      ? '4–5 kW'
      : recommended <= 7
          ? '6–7 kW'
          : recommended <= 10
              ? '8–10 kW'
              : recommended <= 14
                  ? '12–14 kW'
                  : '16 kW or split / cascade';
  return HeatPumpSizingResult(
    designHeatLossKw: heatLossKw,
    dhwAllowanceKw: dhwAllowance,
    recommendedCapacityKw: recommended,
    capacityBand: band,
  );
}

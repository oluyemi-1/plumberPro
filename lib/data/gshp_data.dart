/// Ground-source heat pump collector and HP cylinder sizing models.
///
/// Values are indicative UK domestic figures. Always verify with a thermal
/// response test (TRT) for any borehole installation over 6 kW and follow
/// MCS 022 / MIS 3005 design guidance for slinky horizontal collectors.
library;

class SoilType {
  final String label;
  /// Typical extraction rate in W per metre of slinky horizontal collector pipe.
  final double kwPerMetreSlinky;
  /// W per metre of vertical borehole.
  final double kwPerMetreVertical;
  final String description;

  const SoilType({
    required this.label,
    required this.kwPerMetreSlinky,
    required this.kwPerMetreVertical,
    required this.description,
  });
}

const soilTypes = <SoilType>[
  SoilType(
    label: 'Dry sandy soil',
    kwPerMetreSlinky: 10,
    kwPerMetreVertical: 25,
    description: 'Poor heat capacity, large collector area required.',
  ),
  SoilType(
    label: 'Moist sandy soil',
    kwPerMetreSlinky: 18,
    kwPerMetreVertical: 40,
    description: 'Good extraction; common in UK gardens.',
  ),
  SoilType(
    label: 'Wet clay / peat',
    kwPerMetreSlinky: 22,
    kwPerMetreVertical: 55,
    description: 'Best for ground-source — high water content stores heat.',
  ),
  SoilType(
    label: 'Solid rock (granite)',
    kwPerMetreSlinky: 0,
    kwPerMetreVertical: 65,
    description: 'Boreholes only — slinky impossible.',
  ),
  SoilType(
    label: 'Limestone / chalk',
    kwPerMetreSlinky: 14,
    kwPerMetreVertical: 50,
    description: 'Variable; soak test essential.',
  ),
];

class CollectorSizingResult {
  final double heatPumpKw;
  /// Ground side load — heat extracted from the soil, ~ 75% of HP output at COP 4.
  final double extractionKw;
  final double slinkyTotalLengthM;
  /// Standard 4 turns per metre of trench, 30 m typical max trench length.
  final int slinkyTrenches;
  final double slinkyTrenchLengthM;
  final double verticalBoreholeM;
  final int verticalBoreholeCount;

  const CollectorSizingResult({
    required this.heatPumpKw,
    required this.extractionKw,
    required this.slinkyTotalLengthM,
    required this.slinkyTrenches,
    required this.slinkyTrenchLengthM,
    required this.verticalBoreholeM,
    required this.verticalBoreholeCount,
  });
}

CollectorSizingResult sizeCollector({
  required double heatPumpKw,
  required SoilType soil,
  double cop = 4.0,
  double slinkyTrenchSpacingM = 1.0, // 1 m between trenches
  double slinkyDepthM = 1.2, // standard depth
  double slinkyTurnsPerMetre = 4.0, // typical
  double maxBoreholeM = 100.0, // typical max depth per borehole in domestic
}) {
  // Ground extraction = HP output * (1 - 1/COP) — heat taken from the ground.
  final extraction = heatPumpKw * (1 - 1 / cop);

  final slinkyLen = soil.kwPerMetreSlinky <= 0
      ? 0.0
      : (extraction * 1000) / soil.kwPerMetreSlinky;

  // Standard slinky: each metre of trench has ~ 4 turns of pipe — roughly 10 m
  // of pipe per metre of trench (turns × loop circumference).
  final slinkyTrenchLength = slinkyLen / 10.0;
  final slinkyTrenches = slinkyTrenchLength > 0
      ? (slinkyTrenchLength / 30).ceil() // 30 m typical max trench
      : 0;

  final boreLen = soil.kwPerMetreVertical <= 0
      ? double.infinity
      : (extraction * 1000) / soil.kwPerMetreVertical;
  final bores = boreLen.isFinite ? (boreLen / maxBoreholeM).ceil() : 0;

  return CollectorSizingResult(
    heatPumpKw: heatPumpKw,
    extractionKw: extraction,
    slinkyTotalLengthM: slinkyLen,
    slinkyTrenches: slinkyTrenches,
    slinkyTrenchLengthM: slinkyTrenchLength,
    verticalBoreholeM: boreLen.isFinite ? boreLen : double.nan,
    verticalBoreholeCount: bores,
  );
}

class HpCylinder {
  final int volumeL;
  /// Coil surface area in m² — HP cylinders typically need 3.0+ m² to
  /// allow charging at low primary flow temperatures (50 °C).
  final double coilSurfaceArea;

  const HpCylinder({required this.volumeL, required this.coilSurfaceArea});
}

const recommendedCylinders = <HpCylinder>[
  HpCylinder(volumeL: 150, coilSurfaceArea: 2.7),
  HpCylinder(volumeL: 180, coilSurfaceArea: 3.0),
  HpCylinder(volumeL: 210, coilSurfaceArea: 3.4),
  HpCylinder(volumeL: 250, coilSurfaceArea: 3.8),
  HpCylinder(volumeL: 300, coilSurfaceArea: 4.2),
  HpCylinder(volumeL: 400, coilSurfaceArea: 5.0),
];

class CylinderSizingResult {
  /// Calculated peak hour demand in litres at outlet temperature.
  final double peakDemandLitres;
  final double recommendedLitres;
  final HpCylinder recommendedCylinder;
  /// Minutes to reheat from 20 °C to 50 °C using the available HP capacity.
  final double recoveryMinutes;
  final double dailyEnergyKwh;

  const CylinderSizingResult({
    required this.peakDemandLitres,
    required this.recommendedLitres,
    required this.recommendedCylinder,
    required this.recoveryMinutes,
    required this.dailyEnergyKwh,
  });
}

CylinderSizingResult sizeCylinder({
  required int occupants,
  required double showersPerDay, // total hot showers across the house per day
  required double bathsPerWeek,
  required double hpHeatOutputKw, // available HP capacity for DHW
  double primaryFlowTemp = 50.0, // typical HP DHW primary
  double cylinderTemp = 48.0, // store at 48 °C for HP-only operation
  double coldFeedTemp = 10.0,
}) {
  // Peak demand = 35 L per shower * showersInPeakHour + 100 L per bath
  // Daily total — use the bigger of (occupants * 50 L) and shower/bath demand.
  final dailyShowerL = showersPerDay * 35;
  final dailyBathL = bathsPerWeek * 100 / 7;
  final perOccupant = occupants * 50;
  final dailyTotal = (dailyShowerL + dailyBathL).clamp(perOccupant.toDouble(), 99999);

  // Peak hour demand assumed ~ 60 % of evening shower load + one bath if any.
  final peakDemand = dailyShowerL * 0.6 + 100 * (bathsPerWeek > 0 ? 1 : 0);
  final recommended = peakDemand * 1.2; // 20 % safety margin

  final cylinder = recommendedCylinders.firstWhere(
    (c) => c.volumeL >= recommended,
    orElse: () => recommendedCylinders.last,
  );

  // Energy to heat full cylinder volume from 20 to cylinderTemp.
  final energyKj = cylinder.volumeL * 4.18 * (cylinderTemp - 20);
  final energyKwh = energyKj / 3600;
  final recoveryHours = energyKwh / hpHeatOutputKw;

  return CylinderSizingResult(
    peakDemandLitres: peakDemand,
    recommendedLitres: recommended,
    recommendedCylinder: cylinder,
    recoveryMinutes: recoveryHours * 60,
    dailyEnergyKwh: dailyTotal * 4.18 * (cylinderTemp - coldFeedTemp) / 3600,
  );
}

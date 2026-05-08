import 'dart:convert';
import 'dart:math' as math;

import 'schema_safe.dart';

/// One suggested material line on a template — just description, default
/// quantity, default unit price. Copied into a real `MaterialLine` when the
/// template is used.
class TemplateMaterialLine {
  final String description;
  final double quantity;
  final double unitPriceGbp;

  const TemplateMaterialLine({
    required this.description,
    required this.quantity,
    required this.unitPriceGbp,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPriceGbp,
      };

  factory TemplateMaterialLine.fromJson(Map<String, dynamic> j) =>
      TemplateMaterialLine(
        description: j['description'] as String? ?? '',
        quantity: (j['quantity'] as num?)?.toDouble() ?? 1,
        unitPriceGbp: (j['unitPrice'] as num?)?.toDouble() ?? 0,
      );
}

/// A re-usable starter for common jobs (annual boiler service, leaking tap,
/// power flush, etc.). Tapping "Use" creates a real Job with the description,
/// rate and suggested materials pre-filled.
class JobTemplate {
  final String id;
  final String name;
  final String description;
  final double? defaultHourlyRateGbp;
  final List<TemplateMaterialLine> suggestedMaterials;
  final String defaultNotes;
  final String iconCode; // mapped to a Material icon at render time
  final bool builtIn;

  const JobTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultHourlyRateGbp,
    required this.suggestedMaterials,
    required this.defaultNotes,
    required this.iconCode,
    required this.builtIn,
  });

  factory JobTemplate.create({
    required String name,
    required String description,
    double? defaultHourlyRateGbp,
    List<TemplateMaterialLine> suggestedMaterials = const [],
    String defaultNotes = '',
    String iconCode = 'wrench',
  }) =>
      JobTemplate(
        id: _generateId(),
        name: name.trim(),
        description: description.trim(),
        defaultHourlyRateGbp: defaultHourlyRateGbp,
        suggestedMaterials: suggestedMaterials,
        defaultNotes: defaultNotes,
        iconCode: iconCode,
        builtIn: false,
      );

  JobTemplate copyWith({
    String? name,
    String? description,
    double? defaultHourlyRateGbp,
    bool clearRate = false,
    List<TemplateMaterialLine>? suggestedMaterials,
    String? defaultNotes,
    String? iconCode,
  }) =>
      JobTemplate(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        defaultHourlyRateGbp:
            clearRate ? null : (defaultHourlyRateGbp ?? this.defaultHourlyRateGbp),
        suggestedMaterials: suggestedMaterials ?? this.suggestedMaterials,
        defaultNotes: defaultNotes ?? this.defaultNotes,
        iconCode: iconCode ?? this.iconCode,
        builtIn: builtIn,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'defaultRate': defaultHourlyRateGbp,
        'materials': suggestedMaterials.map((m) => m.toJson()).toList(),
        'notes': defaultNotes,
        'icon': iconCode,
        'builtIn': builtIn,
      };

  factory JobTemplate.fromJson(Map<String, dynamic> j) => JobTemplate(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        defaultHourlyRateGbp: (j['defaultRate'] as num?)?.toDouble(),
        suggestedMaterials: ((j['materials'] as List?) ?? const [])
            .map((e) => TemplateMaterialLine.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ))
            .toList(),
        defaultNotes: j['notes'] as String? ?? '',
        iconCode: j['icon'] as String? ?? 'wrench',
        builtIn: j['builtIn'] as bool? ?? false,
      );
}

String _generateId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final r = math.Random().nextInt(1 << 32);
  return 't-$ts-${r.toRadixString(36)}';
}

/// Pre-loaded templates seeded into a fresh install. Users can edit / delete
/// these and add their own.
List<JobTemplate> defaultBuiltInTemplates() => [
      JobTemplate(
        id: 'tpl-boiler-service',
        name: 'Annual boiler service',
        description:
            'Annual gas boiler service per manufacturer instructions and Gas Safe requirements.',
        defaultHourlyRateGbp: null,
        suggestedMaterials: const [
          TemplateMaterialLine(
            description: 'Service consumables (seals, gaskets)',
            quantity: 1,
            unitPriceGbp: 8.00,
          ),
        ],
        defaultNotes:
            'Pre-service combustion analysis: \nPost-service combustion analysis: \nGas working pressure: \nFlue gas analyser cal date: \nBenchmark log updated: ',
        iconCode: 'flame',
        builtIn: true,
      ),
      JobTemplate(
        id: 'tpl-leaking-tap',
        name: 'Leaking tap repair',
        description:
            'Repair dripping tap — replace washer or ceramic cartridge as required.',
        defaultHourlyRateGbp: null,
        suggestedMaterials: const [
          TemplateMaterialLine(
            description: '1/2" tap washer (assorted)',
            quantity: 1,
            unitPriceGbp: 0.80,
          ),
        ],
        defaultNotes:
            'Tap type: \nWasher / cartridge: \nReseating tool used: yes / no',
        iconCode: 'tap',
        builtIn: true,
      ),
      JobTemplate(
        id: 'tpl-blocked-sink',
        name: 'Blocked sink / basin',
        description:
            'Clear partial or full blockage from waste pipework. Inspect trap and downstream branch.',
        defaultHourlyRateGbp: null,
        suggestedMaterials: const [],
        defaultNotes:
            'Cause of blockage: \nClearance method (plunger / trap removal / rod): \nCustomer advice given: ',
        iconCode: 'drain',
        builtIn: true,
      ),
      JobTemplate(
        id: 'tpl-radiator-replace',
        name: 'Radiator replacement',
        description:
            'Replace existing radiator like-for-like. Drain section, swap, balance and re-vent.',
        defaultHourlyRateGbp: null,
        suggestedMaterials: const [
          TemplateMaterialLine(
            description: 'Radiator (size to confirm on site)',
            quantity: 1,
            unitPriceGbp: 80.00,
          ),
          TemplateMaterialLine(
            description: 'TRV head + lockshield set',
            quantity: 1,
            unitPriceGbp: 22.00,
          ),
          TemplateMaterialLine(
            description: 'Inhibitor top-up',
            quantity: 1,
            unitPriceGbp: 12.00,
          ),
        ],
        defaultNotes:
            'Old rad disposed of: yes / no\nSystem inhibitor topped up: yes / no\nBalanced ΔT: ',
        iconCode: 'radiator',
        builtIn: true,
      ),
      JobTemplate(
        id: 'tpl-power-flush',
        name: 'Power flush',
        description:
            'Power flush central heating system, descale where required, dose with inhibitor.',
        defaultHourlyRateGbp: null,
        suggestedMaterials: const [
          TemplateMaterialLine(
            description: 'System cleaner',
            quantity: 1,
            unitPriceGbp: 14.00,
          ),
          TemplateMaterialLine(
            description: 'Inhibitor',
            quantity: 1,
            unitPriceGbp: 12.00,
          ),
        ],
        defaultNotes:
            'Pre-flush rad temps: \nPost-flush rad temps: \nMagnetic filter fitted: yes / no\nInhibitor strip reading: ',
        iconCode: 'flush',
        builtIn: true,
      ),
      JobTemplate(
        id: 'tpl-bathroom-first-fix',
        name: 'Bathroom rough first-fix',
        description:
            'Hot, cold and waste pipework run for bathroom. Pressure test prior to second fix.',
        defaultHourlyRateGbp: null,
        suggestedMaterials: const [],
        defaultNotes:
            'Pipework material: \nPressure test held at: \nFor inspection by: ',
        iconCode: 'bathroom',
        builtIn: true,
      ),
      JobTemplate(
        id: 'tpl-bathroom-second-fix',
        name: 'Bathroom second fix',
        description:
            'Sanitaryware install, isolation valves, commissioning, snag list.',
        defaultHourlyRateGbp: null,
        suggestedMaterials: const [],
        defaultNotes:
            'Sanitaryware checked: \nIsolation valves accessible: \nSilicone cured: ',
        iconCode: 'bathroom',
        builtIn: true,
      ),
      JobTemplate(
        id: 'tpl-unvented-commission',
        name: 'Unvented cylinder commissioning',
        description:
            'Commission unvented hot water cylinder per Building Regs Part G3 and manufacturer instructions.',
        defaultHourlyRateGbp: null,
        suggestedMaterials: const [],
        defaultNotes:
            'PRV setting: \nExpansion vessel pre-charge: \nT&P relief tested: yes / no\nDischarge route inspected: \nBenchmark G3 commissioned: ',
        iconCode: 'cylinder',
        builtIn: true,
      ),
      JobTemplate(
        id: 'tpl-tightness-test',
        name: 'Gas tightness test (UP/1A)',
        description:
            'Domestic gas installation tightness test per IGEM/UP/1A.',
        defaultHourlyRateGbp: null,
        suggestedMaterials: const [],
        defaultNotes:
            'Pipework volume (L): \nWorking pressure (mbar): \nStabilisation period: \nTest duration: \nAllowable drop (mbar): \nMeasured drop (mbar): \nResult: PASS / FAIL',
        iconCode: 'flame',
        builtIn: true,
      ),
    ];

String encodeTemplates(List<JobTemplate> list) =>
    jsonEncode(list.map((t) => t.toJson()).toList());

List<JobTemplate> decodeTemplates(String? raw) =>
    SchemaSafe.decodeList<JobTemplate>(
      key: 'job_templates_v1',
      raw: raw,
      fromJson: JobTemplate.fromJson,
    );

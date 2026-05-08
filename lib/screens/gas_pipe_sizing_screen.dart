import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../services/tts_service.dart';

class GasPipeSizingScreen extends StatefulWidget {
  const GasPipeSizingScreen({super.key});

  @override
  State<GasPipeSizingScreen> createState() => _GasPipeSizingScreenState();
}

class _GasPipeSizingScreenState extends State<GasPipeSizingScreen> {
  final TextEditingController _lengthCtrl = TextEditingController(text: '25');
  final TextEditingController _demandCtrl = TextEditingController(text: '50');

  static const List<double> _pressureDrops = [1, 2, 5, 10];
  static const List<String> _pressureDropLabels = [
    '1 mbar (low pressure)',
    '2 mbar (medium pressure low end)',
    '5 mbar (commercial typical)',
    '10 mbar (industrial)',
  ];
  int _pressureDropIdx = 2;

  static const List<String> _materials = [
    'Steel',
    'Copper',
    'Stainless press-fit',
  ];
  int _materialIdx = 0;

  static const List<String> _inletPressures = [
    '≤ 75 mbar (LP)',
    '> 75 mbar to 2 bar (MP)',
    '> 2 bar to 7 bar (IP)',
  ];
  int _inletIdx = 0;

  static const List<int> _steelSizes = [
    15, 20, 25, 32, 40, 50, 65, 80, 100, 125, 150,
  ];
  static const List<int> _copperSizes = [
    15, 22, 28, 35, 42, 54, 67, 76, 108,
  ];
  static const List<int> _stainlessSizes = [
    15, 22, 28, 35, 42, 54,
  ];

  double? _internalDiameter;
  int? _recommendedSize;
  String? _materialUnitLabel;
  double? _velocity;
  String? _velocityNote;

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _demandCtrl.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  void _calculate() {
    final L = double.tryParse(_lengthCtrl.text) ?? 0;
    final Q = double.tryParse(_demandCtrl.text) ?? 0;
    final dP = _pressureDrops[_pressureDropIdx];
    if (L <= 0 || Q <= 0) {
      setState(() {
        _internalDiameter = null;
        _recommendedSize = null;
        _materialUnitLabel = null;
        _velocity = null;
        _velocityNote = null;
      });
      return;
    }

    // K factor: simplified IGEM/UP/2 constant for natural gas at LP.
    double k;
    switch (_materialIdx) {
      case 1:
        k = 0.0078; // copper smooth bore, slightly higher
        break;
      case 2:
        k = 0.0080; // stainless press-fit
        break;
      default:
        k = 0.0071; // steel
    }

    // d = ((Q/K)^2 * L / dP)^(1/5)  in mm.
    final inside = math.pow(Q / k, 2) * L / dP;
    final d = math.pow(inside, 1 / 5).toDouble();

    final List<int> table;
    final String unitLabel;
    switch (_materialIdx) {
      case 1:
        table = _copperSizes;
        unitLabel = 'mm OD (copper)';
        break;
      case 2:
        table = _stainlessSizes;
        unitLabel = 'mm OD (stainless press-fit)';
        break;
      default:
        table = _steelSizes;
        unitLabel = 'mm nominal bore (steel)';
    }

    int next = table.last;
    for (final s in table) {
      if (s >= d) {
        next = s;
        break;
      }
    }

    // Velocity: v = Q / (3600 * area_m2), area in m^2 from internal diameter.
    final dForVelocity = next.toDouble();
    final area = math.pi * math.pow(dForVelocity / 1000, 2) / 4;
    final v = Q / 3600 / area;

    String note;
    if (v <= 20) {
      note = 'Velocity within 20 m/s low-pressure target.';
    } else if (v <= 35) {
      note = 'Above 20 m/s — acceptable for medium pressure but check noise.';
    } else {
      note = 'Velocity exceeds typical limits — increase pipe size.';
    }

    setState(() {
      _internalDiameter = d;
      _recommendedSize = next;
      _materialUnitLabel = unitLabel;
      _velocity = v;
      _velocityNote = note;
    });
  }

  Future<void> _speakResult() async {
    if (_internalDiameter == null) return;
    final txt =
        'Required minimum internal diameter ${_internalDiameter!.toStringAsFixed(1)} millimetres. '
        'Recommended next standard size $_recommendedSize $_materialUnitLabel. '
        'Estimated gas velocity ${_velocity!.toStringAsFixed(1)} metres per second. $_velocityNote';
    await TtsService.instance.speak(txt);
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: AppColors.muted.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: AppColors.muted.withValues(alpha: 0.3)),
        ),
      );

  Widget _chipRow({
    required String title,
    required List<String> options,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 4),
          child: Text(title,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: List.generate(options.length, (i) {
            final selected = i == selectedIndex;
            return ChoiceChip(
              label: Text(options[i]),
              selected: selected,
              onSelected: (_) => setState(() => onSelected(i)),
              selectedColor: AppColors.gas.withValues(alpha: 0.25),
              labelStyle: TextStyle(
                color: selected ? AppColors.primaryDark : AppColors.text,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: selected
                      ? AppColors.gas
                      : AppColors.muted.withValues(alpha: 0.3),
                ),
              ),
              backgroundColor: AppColors.cardBg,
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Commercial gas pipe sizing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inputs',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _lengthCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: formatter,
                    decoration:
                        _decoration('Pipe length (m) — effective length'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _demandCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: formatter,
                    decoration:
                        _decoration('Connected gas demand (m³/h)'),
                  ),
                  const SizedBox(height: 14),
                  _chipRow(
                    title: 'Allowable pressure drop',
                    options: _pressureDropLabels,
                    selectedIndex: _pressureDropIdx,
                    onSelected: (i) => _pressureDropIdx = i,
                  ),
                  const SizedBox(height: 10),
                  _chipRow(
                    title: 'Pipe material',
                    options: _materials,
                    selectedIndex: _materialIdx,
                    onSelected: (i) => _materialIdx = i,
                  ),
                  const SizedBox(height: 10),
                  _chipRow(
                    title: 'Inlet pressure',
                    options: _inletPressures,
                    selectedIndex: _inletIdx,
                    onSelected: (i) => _inletIdx = i,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate pipe size'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_internalDiameter != null && _recommendedSize != null)
            Card(
              color: AppColors.cardBg,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            color: AppColors.gas),
                        const SizedBox(width: 8),
                        Text('Result',
                            style:
                                Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _resultRow(
                      'Calculated minimum internal diameter',
                      '${_internalDiameter!.toStringAsFixed(2)} mm',
                    ),
                    _resultRow(
                      'Recommended next standard size',
                      '$_recommendedSize $_materialUnitLabel',
                    ),
                    _resultRow(
                      'Estimated velocity',
                      '${_velocity!.toStringAsFixed(2)} m/s',
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.gas.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_velocityNote ?? '',
                          style:
                              Theme.of(context).textTheme.bodyMedium),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'For multiple branches the cumulative pressure drop must be summed along the longest run. Use the full IGEM/UP/2 method (section by section) when there is more than one tee or where flow splits significantly.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: _speakResult,
                        icon: const Icon(Icons.volume_up),
                        label: const Text('Speak result'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          Card(
            color: AppColors.primary.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Standard reference',
                          style:
                              Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'IGEM/UP/2 — Installation pipework on industrial and commercial premises. The simplified relationship Q = K × √(d⁵ × ΔP / L) gives a starting size; verify with the full procedure for installations above 1 bar or with extensive branches.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

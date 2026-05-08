import 'package:flutter/material.dart';

import '../data/gshp_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class HpCylinderSizingScreen extends StatefulWidget {
  const HpCylinderSizingScreen({super.key});

  @override
  State<HpCylinderSizingScreen> createState() => _HpCylinderSizingScreenState();
}

class _HpCylinderSizingScreenState extends State<HpCylinderSizingScreen> {
  int _occupants = 4;
  double _showers = 4;
  double _baths = 2;
  final TextEditingController _hpKwController =
      TextEditingController(text: '8.0');

  CylinderSizingResult? _result;

  @override
  void initState() {
    super.initState();
    _hpKwController.addListener(_recalc);
    _recalc();
  }

  @override
  void dispose() {
    _hpKwController.removeListener(_recalc);
    _hpKwController.dispose();
    super.dispose();
  }

  double get _hpKw {
    final raw = _hpKwController.text.replaceAll(',', '.').trim();
    final parsed = double.tryParse(raw) ?? 0;
    return parsed.clamp(0.5, 30.0);
  }

  void _recalc() {
    final kw = _hpKw;
    if (kw <= 0) {
      setState(() => _result = null);
      return;
    }
    setState(() {
      _result = sizeCylinder(
        occupants: _occupants,
        showersPerDay: _showers,
        bathsPerWeek: _baths,
        hpHeatOutputKw: kw,
      );
    });
  }

  String _buildSpokenSummary() {
    final r = _result;
    if (r == null) {
      return 'Enter the heat pump output in kilowatts to begin.';
    }
    return 'Cylinder sizing for $_occupants occupants. '
        'Peak demand ${r.peakDemandLitres.toStringAsFixed(0)} litres. '
        'Recommended cylinder ${r.recommendedCylinder.volumeL} litres '
        'with a coil of ${r.recommendedCylinder.coilSurfaceArea} square metres. '
        'Recovery time ${r.recoveryMinutes.toStringAsFixed(0)} minutes. '
        'Daily hot water energy ${r.dailyEnergyKwh.toStringAsFixed(1)} kilowatt hours. '
        'Remember a weekly Legionella pasteurisation cycle to 60 degrees is required.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('HP cylinder sizing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInputCard(theme),
          const SizedBox(height: 14),
          _buildResultCard(theme),
          const SizedBox(height: 14),
          _buildLegionellaCard(theme),
        ],
      ),
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inputs', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _sliderRow(
              theme,
              label: 'Occupants',
              value: _occupants.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              valueLabel: _occupants.toString(),
              onChanged: (v) => setState(() {
                _occupants = v.round();
                _recalc();
              }),
            ),
            _sliderRow(
              theme,
              label: 'Showers per day (total)',
              value: _showers,
              min: 0,
              max: 10,
              divisions: 20,
              valueLabel: _showers.toStringAsFixed(1),
              onChanged: (v) => setState(() {
                _showers = v;
                _recalc();
              }),
            ),
            _sliderRow(
              theme,
              label: 'Baths per week',
              value: _baths,
              min: 0,
              max: 14,
              divisions: 14,
              valueLabel: _baths.toStringAsFixed(0),
              onChanged: (v) => setState(() {
                _baths = v;
                _recalc();
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _hpKwController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'HP heat output for DHW (kW)',
                helperText:
                    'Available capacity for hot-water mode (typical 6 – 12 kW)',
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliderRow(
    ThemeData theme, {
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                valueLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    final r = _result;
    if (r == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Enter the HP heat output to see the cylinder recommendation.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop_outlined,
                    color: AppColors.hotWater),
                const SizedBox(width: 8),
                Text('Cylinder result',
                    style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            _resultRow('Peak hour demand',
                '${r.peakDemandLitres.toStringAsFixed(0)} L'),
            _resultRow('Sizing target (+20 %)',
                '${r.recommendedLitres.toStringAsFixed(0)} L'),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recommended cylinder',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: AppColors.primaryDark)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${r.recommendedCylinder.volumeL} L',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Coil ≥ ${r.recommendedCylinder.coilSurfaceArea} m²',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Heat-pump cylinders need a large surface-area coil so '
                    'they can charge at 50 °C primary flow.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _resultRow('Recovery time (20 → 48 °C)',
                '${r.recoveryMinutes.toStringAsFixed(0)} min',
                accent: AppColors.accent),
            _resultRow('Daily DHW energy',
                '${r.dailyEnergyKwh.toStringAsFixed(1)} kWh'),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () =>
                    TtsService.instance.speak(_buildSpokenSummary()),
                icon: const Icon(Icons.volume_up),
                label: const Text('Speak result'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, {Color? accent}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: accent ?? AppColors.text,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegionellaCard(ThemeData theme) {
    return Card(
      color: AppColors.hotWater.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.hotWater.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.science_outlined, color: AppColors.hotWater),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Legionella cycle',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Storing at 48 °C is efficient for the heat pump but '
                    'L8 / BS 8580 requires a weekly pasteurisation cycle '
                    'raising the full cylinder to ≥ 60 °C — usually via the '
                    'immersion or HP boost programme. Confirm timer schedule '
                    'on commissioning.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

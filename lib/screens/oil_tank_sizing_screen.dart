import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/tts_service.dart';
import '../theme.dart';

class OilTankSizingScreen extends StatefulWidget {
  const OilTankSizingScreen({super.key});

  @override
  State<OilTankSizingScreen> createState() => _OilTankSizingScreenState();
}

class _OilTankSizingScreenState extends State<OilTankSizingScreen> {
  static const _buildingOptions = <String>[
    'Family home',
    'Holiday home',
    'Small commercial',
  ];

  static const _tankOptions = <String>[
    'Single skin + masonry bund',
    'Integrally bunded',
    'Double-skinned',
  ];

  static const _standardSizes = <int>[1200, 1300, 1800, 2500, 3500, 5000, 7500];

  // 1 L kerosene ~ 10.35 kWh net.
  static const double _kwhPerLitre = 10.35;

  double _kwhPerYear = 18000;
  String _building = 'Family home';
  double _refillWeeks = 12;
  String _tankType = 'Integrally bunded';

  late final TextEditingController _kwhCtrl =
      TextEditingController(text: _kwhPerYear.toStringAsFixed(0));

  @override
  void dispose() {
    _kwhCtrl.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  double get _annualLitres => _kwhPerYear / _kwhPerLitre;
  double get _requiredTankL =>
      (_annualLitres / 52) * _refillWeeks * 1.2; // 20% safety
  double get _bundRequiredL => _requiredTankL * 1.10;

  int get _recommendedSize {
    for (final s in _standardSizes) {
      if (s >= _requiredTankL) return s;
    }
    return _standardSizes.last;
  }

  bool get _needsBund => _tankType == 'Single skin + masonry bund';

  String _resultSpeech() {
    final bundLine = _needsBund
        ? 'A masonry bund must hold at least ${_bundRequiredL.toStringAsFixed(0)} litres, which is 110 per cent of tank capacity. '
        : 'Secondary containment is built into the tank, no masonry bund required. ';
    return 'Annual oil use ${_annualLitres.toStringAsFixed(0)} litres of kerosene. '
        'Required tank capacity ${_requiredTankL.toStringAsFixed(0)} litres at ${_refillWeeks.toStringAsFixed(0)} week refill intervals with a twenty per cent safety margin. '
        'Recommended standard size $_recommendedSize litres. '
        '$bundLine'
        'Maintain 1.8 metres clear from the tank to the building, 760 millimetres to the boundary, '
        'fit a fire valve with the sensor at the appliance, and follow OFTEC TI/133.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oil tank sizing'),
        backgroundColor: AppColors.brass,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _intro(theme),
          const SizedBox(height: 12),
          _kwhCard(theme),
          const SizedBox(height: 12),
          _buildingCard(theme),
          const SizedBox(height: 12),
          _refillCard(theme),
          const SizedBox(height: 12),
          _tankCard(theme),
          const SizedBox(height: 16),
          _resultCard(theme),
          const SizedBox(height: 12),
          _tipCard(theme),
        ],
      ),
    );
  }

  Widget _intro(ThemeData theme) {
    return Card(
      color: AppColors.brass.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.oil_barrel, color: AppColors.brass),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Estimate kerosene throughput, required tank size and '
                'masonry bund volume to OFTEC TI/133 and BS 5410.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kwhCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Annual heating demand',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${_kwhPerYear.toStringAsFixed(0)} kWh / year',
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: AppColors.brass)),
            Slider(
              value: _kwhPerYear,
              min: 5000,
              max: 80000,
              divisions: 75,
              activeColor: AppColors.brass,
              label: '${_kwhPerYear.toStringAsFixed(0)} kWh',
              onChanged: (v) => setState(() {
                _kwhPerYear = v;
                _kwhCtrl.text = v.toStringAsFixed(0);
                _kwhCtrl.selection = TextSelection.fromPosition(
                  TextPosition(offset: _kwhCtrl.text.length),
                );
              }),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _kwhCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                labelText: 'Or type exact kWh',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (raw) {
                final v = double.tryParse(raw);
                if (v != null && v >= 5000 && v <= 80000) {
                  setState(() => _kwhPerYear = v);
                }
              },
            ),
            const SizedBox(height: 6),
            Text(
              'Use the EPC heating-demand figure or last 12 months of oil delivery.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildingCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Building type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildingOptions
                  .map((b) => ChoiceChip(
                        label: Text(b),
                        selected: _building == b,
                        selectedColor:
                            AppColors.brass.withValues(alpha: 0.30),
                        onSelected: (_) => setState(() => _building = b),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _refillCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Refill interval', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${_refillWeeks.toStringAsFixed(0)} weeks between deliveries',
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: AppColors.brass)),
            Slider(
              value: _refillWeeks,
              min: 8,
              max: 26,
              divisions: 18,
              activeColor: AppColors.brass,
              label: '${_refillWeeks.toStringAsFixed(0)} weeks',
              onChanged: (v) => setState(() => _refillWeeks = v),
            ),
            Text(
              'Longer intervals need a larger tank but reduce delivery cost.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tankCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tank type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tankOptions
                  .map((t) => ChoiceChip(
                        label: Text(t),
                        selected: _tankType == t,
                        selectedColor:
                            AppColors.brass.withValues(alpha: 0.30),
                        onSelected: (_) => setState(() => _tankType = t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 6),
            Text(
              _needsBund
                  ? 'Single skin requires a separate masonry bund of 110% capacity.'
                  : 'Secondary containment is integral to this tank.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(ThemeData theme) {
    return Card(
      color: AppColors.brass.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, color: AppColors.brass),
                const SizedBox(width: 8),
                Text('Sizing result', style: theme.textTheme.titleLarge),
              ],
            ),
            const Divider(height: 18),
            _row('Annual oil use',
                '${_annualLitres.toStringAsFixed(0)} L kerosene'),
            _row('Required tank capacity',
                '${_requiredTankL.toStringAsFixed(0)} L (incl. 20% safety)'),
            _row('Recommended standard size', '$_recommendedSize L'),
            if (_needsBund)
              _row('Masonry bund volume',
                  '${_bundRequiredL.toStringAsFixed(0)} L (110%)'),
            if (!_needsBund)
              _row('Bund', 'Integral, no masonry bund required'),
            _row('Building',
                '$_building, ${_refillWeeks.toStringAsFixed(0)}-week refill'),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () =>
                    TtsService.instance.speak(_resultSpeech()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brass,
                  foregroundColor: Colors.black87,
                ),
                icon: const Icon(Icons.volume_up),
                label: const Text('Speak result'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipCard(ThemeData theme) {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Site notes (OFTEC TI/133, BS 5410)',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '• Fire valve sensor located at the appliance, remote valve at the tank.\n'
              '• Minimum 1.8 m clear from tank to any building opening or eaves.\n'
              '• Minimum 760 mm from the site boundary; 600 mm from non-fire-rated buildings.\n'
              '• Tank base: level, non-combustible, extending 300 mm beyond the tank on all sides.\n'
              '• Carry out a TI/133 risk assessment to confirm bunding is appropriate.\n'
              '• Notify under the OFTEC Competent Persons Scheme to satisfy Building Regulations.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(k,
                style: const TextStyle(
                    color: AppColors.muted, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 6,
            child: Text(v,
                style: const TextStyle(
                    color: AppColors.text, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

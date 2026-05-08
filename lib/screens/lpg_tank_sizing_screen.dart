import 'package:flutter/material.dart';

import '../services/tts_service.dart';
import '../theme.dart';

class LpgTankSizingScreen extends StatefulWidget {
  const LpgTankSizingScreen({super.key});

  @override
  State<LpgTankSizingScreen> createState() => _LpgTankSizingScreenState();
}

class _LpgTankSizingScreenState extends State<LpgTankSizingScreen> {
  static const _useOptions = <String>[
    'Domestic — central heating',
    'Domestic — heating + DHW',
    'Commercial — light',
    'Commercial — heavy',
  ];
  static const _useHours = <String, double>{
    'Domestic — central heating': 1500,
    'Domestic — heating + DHW': 2200,
    'Commercial — light': 3500,
    'Commercial — heavy': 5500,
  };

  static const _tankOptions = <String>[
    'Above ground 1200 L',
    'Above ground 2000 L',
    'Above ground 4000 L',
    'Underground 2000 L',
  ];
  static const _tankCapacityL = <String, double>{
    'Above ground 1200 L': 1200,
    'Above ground 2000 L': 2000,
    'Above ground 4000 L': 4000,
    'Underground 2000 L': 2000,
  };
  static const _tankVapKgPerH = <String, double>{
    'Above ground 1200 L': 4,
    'Above ground 2000 L': 7,
    'Above ground 4000 L': 12,
    'Underground 2000 L': 7,
  };

  double _kw = 24;
  String _use = 'Domestic — heating + DHW';
  double _refillWeeks = 8;
  String _tank = 'Above ground 2000 L';

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  // 1 L LPG ~ 6.6 kWh net.
  double get _annualKWh => _kw * (_useHours[_use] ?? 2200);
  double get _annualLitres => _annualKWh / 6.6;
  double get _refillsPerYear => 52 / _refillWeeks;
  double get _requiredPerRefill => _annualLitres / _refillsPerYear;
  double get _userTankUsableL => (_tankCapacityL[_tank] ?? 2000) * 0.8;

  String get _recommendedTank {
    final required = _requiredPerRefill;
    final ranked = <String>[
      'Above ground 1200 L',
      'Above ground 2000 L',
      'Above ground 4000 L',
    ];
    for (final t in ranked) {
      final usable = (_tankCapacityL[t] ?? 0) * 0.8;
      if (usable >= required) return t;
    }
    return 'Above ground 4000 L';
  }

  // Peak gas demand in kg/h: 1 kg propane ~ 13.8 kWh.
  double get _peakKgPerHour => _kw / 13.8;
  double get _selectedVap => _tankVapKgPerH[_tank] ?? 7;

  String _resultSpeech() {
    return 'Estimated annual LPG use ${_annualLitres.toStringAsFixed(0)} litres. '
        'Required per refill ${_requiredPerRefill.toStringAsFixed(0)} litres at ${_refillWeeks.toStringAsFixed(0)} week intervals. '
        'Recommended tank, $_recommendedTank. '
        'Selected $_tank gives ${_selectedVap.toStringAsFixed(1)} kilograms per hour vapourisation against a peak demand of ${_peakKgPerHour.toStringAsFixed(1)} kilograms per hour. '
        'Confirm UKLPG Code of Practice 1 separation distances of 3 metres to building openings and 1.5 metres to the site boundary.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('LPG tank sizing'),
        backgroundColor: AppColors.gas,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _intro(theme),
          const SizedBox(height: 12),
          _loadCard(theme),
          const SizedBox(height: 12),
          _useCard(theme),
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
      color: AppColors.gas.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, color: AppColors.gas),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Estimate annual propane use, refill volume and required '
                'vapourisation capacity for a domestic or small commercial '
                'site under UKLPG Code of Practice 1.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total connected appliance load',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${_kw.toStringAsFixed(0)} kW',
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: AppColors.gas)),
            Slider(
              value: _kw,
              min: 5,
              max: 60,
              divisions: 55,
              activeColor: AppColors.gas,
              label: '${_kw.toStringAsFixed(0)} kW',
              onChanged: (v) => setState(() => _kw = v),
            ),
            Text(
              'Sum of boiler, hob and any other LPG appliance running at peak.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _useCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Climate / use', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _useOptions
                  .map((u) => ChoiceChip(
                        label: Text(u),
                        selected: _use == u,
                        selectedColor:
                            AppColors.gas.withValues(alpha: 0.30),
                        onSelected: (_) => setState(() => _use = u),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 6),
            Text(
              'Annual run-time used: ${(_useHours[_use] ?? 0).toStringAsFixed(0)} hours.',
              style: theme.textTheme.bodySmall,
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
            Text('Refill frequency required',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${_refillWeeks.toStringAsFixed(0)} weeks between refills',
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: AppColors.gas)),
            Slider(
              value: _refillWeeks,
              min: 6,
              max: 26,
              divisions: 20,
              activeColor: AppColors.gas,
              label: '${_refillWeeks.toStringAsFixed(0)} weeks',
              onChanged: (v) => setState(() => _refillWeeks = v),
            ),
            Text(
              'Approx ${_refillsPerYear.toStringAsFixed(1)} tanker visits per year.',
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
                        selected: _tank == t,
                        selectedColor:
                            AppColors.gas.withValues(alpha: 0.30),
                        onSelected: (_) => setState(() => _tank = t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 6),
            Text(
              'Selected vapourisation capacity: ${_selectedVap.toStringAsFixed(1)} kg/h continuous.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(ThemeData theme) {
    final peakOk = _selectedVap >= _peakKgPerHour;
    final tankOk = _userTankUsableL >= _requiredPerRefill;
    return Card(
      color: AppColors.gas.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, color: AppColors.gas),
                const SizedBox(width: 8),
                Text('Sizing result', style: theme.textTheme.titleLarge),
              ],
            ),
            const Divider(height: 18),
            _row('Annual LPG use',
                '${_annualLitres.toStringAsFixed(0)} L  (${_annualKWh.toStringAsFixed(0)} kWh)'),
            _row('Required per refill',
                '${_requiredPerRefill.toStringAsFixed(0)} L'),
            _row('Recommended tank', _recommendedTank),
            _row(
              'Selected tank usable (80%)',
              '${_userTankUsableL.toStringAsFixed(0)} L '
                  '${tankOk ? "OK" : "under-sized"}',
            ),
            _row(
              'Peak vapourisation demand',
              '${_peakKgPerHour.toStringAsFixed(1)} kg/h vs '
                  '${_selectedVap.toStringAsFixed(1)} kg/h '
                  '${peakOk ? "OK" : "marginal"}',
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () =>
                    TtsService.instance.speak(_resultSpeech()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gas,
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
            Text('Site notes (UKLPG CoP 1 / BS 5482)',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '• Maintain 3 m clear from any building opening, drain or '
              'ignition source for tanks up to 2500 L.\n'
              '• Maintain 1.5 m to the site boundary.\n'
              '• A 30 minute fire wall allows distances to be measured '
              'around the wall when space is tight.\n'
              '• Plinth must be level, non-combustible and sized for the tank.\n'
              '• Bond the tank shell to earth at the riser and label the ECV.',
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

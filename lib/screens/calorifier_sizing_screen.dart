import 'package:flutter/material.dart';

import '../services/tts_service.dart';
import '../theme.dart';

/// Commercial DHW calorifier sizing.
///
/// Simplification of CIBSE Guide G and BS 6700 / BS EN 806 storage and
/// recovery methods, with HSE L8 / HSG274 reminders for Legionella control.
/// The coil heat-transfer area is approximated using a fixed U value and an
/// indicative LMTD per primary medium.
class CalorifierSizingScreen extends StatefulWidget {
  const CalorifierSizingScreen({super.key});

  @override
  State<CalorifierSizingScreen> createState() =>
      _CalorifierSizingScreenState();
}

enum _Building { hotel, hospital, school, office, careHome, sports }

enum _Primary { mthw, lthw, steam }

class _CalorifierSizingScreenState extends State<CalorifierSizingScreen> {
  _Building _building = _Building.hotel;
  _Primary _primary = _Primary.mthw;
  double _occupants = 80;
  double _showersPerHr = 20;
  double _bathsPerHr = 4;
  double _recoveryMin = 60;
  final TextEditingController _storedTemp =
      TextEditingController(text: '60');
  final TextEditingController _primaryKw =
      TextEditingController(text: '80');

  static const _standardSizes = <int>[500, 750, 1000, 1500, 2000, 3000, 5000];

  @override
  void dispose() {
    _storedTemp.dispose();
    _primaryKw.dispose();
    super.dispose();
  }

  String _labelBuilding(_Building b) {
    switch (b) {
      case _Building.hotel:
        return 'Hotel';
      case _Building.hospital:
        return 'Hospital';
      case _Building.school:
        return 'School';
      case _Building.office:
        return 'Office';
      case _Building.careHome:
        return 'Care home';
      case _Building.sports:
        return 'Sports centre';
    }
  }

  String _labelPrimary(_Primary p) {
    switch (p) {
      case _Primary.mthw:
        return 'MTHW (90/70 °C)';
      case _Primary.lthw:
        return 'LTHW (80/60 °C)';
      case _Primary.steam:
        return 'Steam (low pressure)';
    }
  }

  double get _storedTempC {
    final v = double.tryParse(_storedTemp.text.replaceAll(',', '.').trim());
    return (v ?? 60).clamp(50.0, 80.0);
  }

  double get _primaryAvailableKw {
    final v = double.tryParse(_primaryKw.text.replaceAll(',', '.').trim());
    return (v ?? 80).clamp(5.0, 2000.0);
  }

  double get _peakHourLitres {
    return 35.0 * _showersPerHr + 100.0 * _bathsPerHr + 5.0 * _occupants;
  }

  /// Stored volume = 60% of peak, allowing recovery to meet the remainder.
  double get _storedVolumeL => _peakHourLitres * 0.60;

  int get _roundedStandardL {
    final v = _storedVolumeL;
    for (final s in _standardSizes) {
      if (s >= v) return s;
    }
    return _standardSizes.last;
  }

  /// Recovery duty: heat the stored volume from 10 °C inlet to set-point in
  /// the recovery period.
  double get _recoveryDutyKw {
    final dt = _storedTempC - 10.0;
    final minutes = _recoveryMin.clamp(15.0, 240.0);
    return _storedVolumeL * 4.18 * dt / (minutes * 60.0);
  }

  /// Approx coil surface area, A = Pr / (LMTD x U) with U ~ 1 kW/m².K.
  double get _coilAreaM2 {
    final pr = _recoveryDutyKw;
    final divisor = _primary == _Primary.steam
        ? 40.0
        : (_primary == _Primary.mthw ? 25.0 : 20.0);
    if (pr <= 0) return 0;
    return pr / divisor;
  }

  String _buildSpoken() {
    return 'Calorifier sizing for ${_labelBuilding(_building)}. '
        'Peak hour demand ${_peakHourLitres.toStringAsFixed(0)} litres. '
        'Stored volume ${_storedVolumeL.toStringAsFixed(0)} litres rounded up '
        'to a $_roundedStandardL litre standard vessel. '
        'Recovery duty ${_recoveryDutyKw.toStringAsFixed(1)} kilowatts against '
        '${_primaryAvailableKw.toStringAsFixed(0)} kilowatts available '
        'on ${_labelPrimary(_primary)}. '
        'Coil surface area required ${_coilAreaM2.toStringAsFixed(2)} '
        'square metres. Store at sixty degrees, run an L8 thermal '
        'disinfection cycle and check the unvented safety devices.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Calorifier sizing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Commercial DHW calorifier',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Peak-hour storage method per CIBSE Guide G and BS 6700, '
                    'with primary coil duty derived from your chosen recovery '
                    'period and primary medium.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: 'Building type',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _Building.values
                  .map((b) => ChoiceChip(
                        label: Text(_labelBuilding(b)),
                        selected: _building == b,
                        onSelected: (_) => setState(() => _building = b),
                      ))
                  .toList(),
            ),
          ),
          _sectionCard(
            title: 'Bedrooms / occupants: ${_occupants.toStringAsFixed(0)}',
            child: Slider(
              value: _occupants,
              min: 5,
              max: 500,
              divisions: 99,
              label: _occupants.toStringAsFixed(0),
              onChanged: (v) => setState(() => _occupants = v),
            ),
          ),
          _sectionCard(
            title: 'Showers per peak hour: ${_showersPerHr.toStringAsFixed(0)}',
            child: Slider(
              value: _showersPerHr,
              min: 0,
              max: 100,
              divisions: 100,
              label: _showersPerHr.toStringAsFixed(0),
              onChanged: (v) => setState(() => _showersPerHr = v),
            ),
          ),
          _sectionCard(
            title: 'Baths per peak hour: ${_bathsPerHr.toStringAsFixed(0)}',
            child: Slider(
              value: _bathsPerHr,
              min: 0,
              max: 30,
              divisions: 30,
              label: _bathsPerHr.toStringAsFixed(0),
              onChanged: (v) => setState(() => _bathsPerHr = v),
            ),
          ),
          _sectionCard(
            title: 'Primary medium',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _Primary.values
                  .map((p) => ChoiceChip(
                        label: Text(_labelPrimary(p)),
                        selected: _primary == p,
                        onSelected: (_) => setState(() => _primary = p),
                      ))
                  .toList(),
            ),
          ),
          _sectionCard(
            title: 'Stored DHW temperature',
            child: TextField(
              controller: _storedTemp,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixText: '°C',
                helperText: 'Minimum 60 °C for L8 Legionella control',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          _sectionCard(
            title: 'Recovery period: ${_recoveryMin.toStringAsFixed(0)} min',
            child: Slider(
              value: _recoveryMin,
              min: 30,
              max: 180,
              divisions: 30,
              label: '${_recoveryMin.toStringAsFixed(0)} min',
              onChanged: (v) => setState(() => _recoveryMin = v),
            ),
          ),
          _sectionCard(
            title: 'Primary kW available',
            child: TextField(
              controller: _primaryKw,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixText: 'kW',
                helperText:
                    'Default 80 kW for steam / MTHW. Override for sized plant.',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
          _resultCard(theme),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }

  Widget _resultCard(ThemeData theme) {
    final pr = _recoveryDutyKw;
    final available = _primaryAvailableKw;
    final shortfall = pr - available;
    final ok = shortfall <= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.local_drink, color: AppColors.hotWater),
              const SizedBox(width: 8),
              Text('Sizing result', style: theme.textTheme.titleLarge),
            ]),
            const Divider(height: 18),
            _kv('Building type', _labelBuilding(_building)),
            _kv('Primary medium', _labelPrimary(_primary)),
            _kv('Peak hour DHW demand',
                '${_peakHourLitres.toStringAsFixed(0)} L'),
            _kv('Stored volume (60% of peak)',
                '${_storedVolumeL.toStringAsFixed(0)} L'),
            _kv('Suggested standard vessel',
                '$_roundedStandardL L (round up)'),
            _kv('Recovery duty', '${pr.toStringAsFixed(1)} kW'),
            _kv('Primary kW available',
                '${available.toStringAsFixed(0)} kW '
                    '${ok ? '(OK)' : '(undersized by ${shortfall.toStringAsFixed(0)} kW)'}'),
            _kv('Coil surface area',
                '${_coilAreaM2.toStringAsFixed(2)} m² (U ≈ 1.0 kW/m²·K)'),
            _kv('Working pressure rating',
                'Specify 6 bar minimum (typical commercial)'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.hotWater.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.hotWater.withValues(alpha: 0.4)),
              ),
              child: const Text(
                'L8 / HSG274: store at 60 °C minimum, distribute >= 55 °C with '
                'return >= 50 °C. Run a weekly thermal disinfection cycle to '
                '60 °C throughout the system, log temperatures and inspect for '
                'sludge / scale annually.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton.icon(
                onPressed: () => TtsService.instance.speak(_buildSpoken()),
                icon: const Icon(Icons.record_voice_over),
                label: const Text('Speak result'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => TtsService.instance.stop(),
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 210,
            child: Text(k,
                style: const TextStyle(
                    color: AppColors.muted, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(v,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

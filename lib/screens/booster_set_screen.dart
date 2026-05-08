import 'package:flutter/material.dart';

import '../services/tts_service.dart';
import '../theme.dart';

/// Cold-water booster set sizing for commercial buildings.
///
/// Uses conservative simplifications drawn from BS 8558, BS EN 806-3 and
/// BSRIA BG 2 Heating and Cooling Pipework Sizing Guide for typical UK
/// apartment, office, hotel and mixed-use schemes. The break-tank and Type
/// AA air gap requirement is highlighted in the result card to keep the
/// trainee aware of Cat 5 backflow protection on a stored boosted supply.
class BoosterSetScreen extends StatefulWidget {
  const BoosterSetScreen({super.key});

  @override
  State<BoosterSetScreen> createState() => _BoosterSetScreenState();
}

enum _BuildingKind { apartments, office, hotel, mixed }

enum _SetKind { vsp, hydropneumatic }

class _BoosterSetScreenState extends State<BoosterSetScreen> {
  _BuildingKind _building = _BuildingKind.apartments;
  _SetKind _set = _SetKind.vsp;
  double _units = 60;
  double _storeys = 8;
  double _floorHeight = 3.0;
  final TextEditingController _residual = TextEditingController(text: '15');

  @override
  void dispose() {
    _residual.dispose();
    super.dispose();
  }

  String get _buildingLabel {
    switch (_building) {
      case _BuildingKind.apartments:
        return 'Apartment block';
      case _BuildingKind.office:
        return 'Office';
      case _BuildingKind.hotel:
        return 'Hotel';
      case _BuildingKind.mixed:
        return 'Mixed-use';
    }
  }

  String get _setLabel =>
      _set == _SetKind.vsp ? 'Variable speed (VSP)' : 'Hydropneumatic with vessel';

  double get _qLitresPerSec {
    final n = _units;
    switch (_building) {
      case _BuildingKind.apartments:
        return 0.0035 * n;
      case _BuildingKind.office:
        return 0.003 * n;
      case _BuildingKind.hotel:
        return 0.005 * n;
      case _BuildingKind.mixed:
        return 0.0045 * n;
    }
  }

  double get _residualHead {
    final raw = _residual.text.replaceAll(',', '.').trim();
    final v = double.tryParse(raw) ?? 15;
    return v.clamp(5.0, 50.0);
  }

  double get _staticHead => _storeys * _floorHeight;
  double get _frictionHead => 0.5 * _storeys;
  double get _pumpHead => _staticHead + _frictionHead + _residualHead + 5.0;
  double get _powerInputKw {
    final q = _qLitresPerSec;
    final h = _pumpHead;
    return (q * h * 9.81) / (0.55 * 1000.0);
  }

  /// Approx air-vessel volume for hydropneumatic sets, sized so that a small
  /// set still cycles within 2-4 minutes at full duty: V ~ 25 x Q[l/min].
  double get _vesselLitres {
    final qLpm = _qLitresPerSec * 60.0;
    return 25.0 * qLpm;
  }

  String _buildSpoken() {
    final q = _qLitresPerSec;
    final qLpm = q * 60.0;
    final v = _vesselLitres;
    final config = _set == _SetKind.vsp
        ? 'Twin pump duty/standby with VFD recommended for variable demand.'
        : 'Hydropneumatic set with a ${v.toStringAsFixed(0)} litre pressure vessel.';
    return 'Booster set sizing for a $_buildingLabel of '
        '${_units.toStringAsFixed(0)} units over ${_storeys.toStringAsFixed(0)} storeys. '
        'Peak design flow ${q.toStringAsFixed(2)} litres per second, '
        'or ${qLpm.toStringAsFixed(0)} litres per minute. '
        'Required pump head ${_pumpHead.toStringAsFixed(1)} metres '
        'including ${_residualHead.toStringAsFixed(0)} metres residual at the topmost outlet. '
        'Estimated motor input ${_powerInputKw.toStringAsFixed(2)} kilowatts. '
        '$config '
        'A Category 5 break tank with a Type AA air gap must precede the set.';
  }

  void _speak() {
    TtsService.instance.speak(_buildSpoken());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Booster set sizing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cold-water booster set', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Size a packaged cold-water booster for an apartment block, '
                    'office, hotel or mixed-use scheme. Conservative simplification '
                    'of BS 8558, BS EN 806 and BSRIA BG 2 fixture-unit guidance.',
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
              children: _BuildingKind.values.map((b) {
                return ChoiceChip(
                  label: Text(_labelFor(b)),
                  selected: _building == b,
                  onSelected: (_) => setState(() => _building = b),
                );
              }).toList(),
            ),
          ),
          _sectionCard(
            title: 'Number of dwellings / units: ${_units.toStringAsFixed(0)}',
            child: Slider(
              value: _units,
              min: 1,
              max: 200,
              divisions: 199,
              label: _units.toStringAsFixed(0),
              onChanged: (v) => setState(() => _units = v),
            ),
          ),
          _sectionCard(
            title: 'Storeys above the booster: ${_storeys.toStringAsFixed(0)}',
            child: Slider(
              value: _storeys,
              min: 1,
              max: 30,
              divisions: 29,
              label: _storeys.toStringAsFixed(0),
              onChanged: (v) => setState(() => _storeys = v),
            ),
          ),
          _sectionCard(
            title: 'Floor-to-floor height: ${_floorHeight.toStringAsFixed(2)} m',
            child: Slider(
              value: _floorHeight,
              min: 2.7,
              max: 4.0,
              divisions: 13,
              label: '${_floorHeight.toStringAsFixed(2)} m',
              onChanged: (v) => setState(() => _floorHeight = v),
            ),
          ),
          _sectionCard(
            title: 'Residual head at topmost outlet (m)',
            child: TextField(
              controller: _residual,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixText: 'm head',
                helperText: 'Default 15 m for showers and combination taps',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          _sectionCard(
            title: 'Set type',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _SetKind.values.map((s) {
                return ChoiceChip(
                  label: Text(s == _SetKind.vsp
                      ? 'Variable speed (VSP)'
                      : 'Hydropneumatic with vessel'),
                  selected: _set == s,
                  onSelected: (_) => setState(() => _set = s),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _resultCard(theme),
          const SizedBox(height: 12),
          Card(
            color: AppColors.cardBg,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tips & references', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  const Text(
                    'These per-unit flow factors (apartments 0.0035, offices 0.003, '
                    'hotels 0.005, mixed-use 0.0045 l/s per unit) are conservative '
                    'simplifications. For a real scheme, derive Q from a fixture-unit '
                    'count and IFU/Hunter curve.',
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Standards: BS 8558, BS EN 806-3, BSRIA BG 2 Pipework Sizing Guide, '
                    'WRAS Water Regulations Guide, manufacturer technical data (Grundfos, '
                    'Lowara, Wilo).',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(_BuildingKind b) {
    switch (b) {
      case _BuildingKind.apartments:
        return 'Apartment block';
      case _BuildingKind.office:
        return 'Office';
      case _BuildingKind.hotel:
        return 'Hotel';
      case _BuildingKind.mixed:
        return 'Mixed-use';
    }
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
    final q = _qLitresPerSec;
    final qLpm = q * 60.0;
    final config = _set == _SetKind.vsp
        ? 'Twin-pump duty / standby variable-speed package with VFD on each pump. '
            'Select against a curve giving the duty point at ${_pumpHead.toStringAsFixed(1)} m '
            'and ${q.toStringAsFixed(2)} l/s, with capability across 30 - 110 percent of '
            'design flow at +/- 10 percent head.'
        : 'Hydropneumatic set with a ${_vesselLitres.toStringAsFixed(0)} litre pressure '
            'vessel sized for a 2 - 4 minute cycle at full duty. Pre-charge to '
            'approx 90 percent of cut-in pressure.';

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Sizing result', style: theme.textTheme.titleLarge),
              ],
            ),
            const Divider(height: 18),
            _kv('Building type', _buildingLabel),
            _kv('Set type', _setLabel),
            _kv('Peak design flow',
                '${q.toStringAsFixed(2)} l/s  (${qLpm.toStringAsFixed(0)} l/min)'),
            _kv('Static head', '${_staticHead.toStringAsFixed(1)} m'),
            _kv('Friction head (rule of thumb)',
                '${_frictionHead.toStringAsFixed(1)} m'),
            _kv('Residual head at top outlet',
                '${_residualHead.toStringAsFixed(0)} m'),
            _kv('Total pump head (Hp)', '${_pumpHead.toStringAsFixed(1)} m'),
            _kv('Estimated motor input',
                '${_powerInputKw.toStringAsFixed(2)} kW (eta = 0.55)'),
            if (_set == _SetKind.hydropneumatic)
              _kv('Air vessel volume', '${_vesselLitres.toStringAsFixed(0)} L'),
            const SizedBox(height: 8),
            Text('Configuration', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(config, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              child: const Text(
                'Cat 5 break tank required: a packaged break tank with a Type AA '
                'air gap must precede the booster set on the incoming main. The '
                'pumps draw from the break tank, never directly from the public '
                'supply (Water Supply (Water Fittings) Regulations 1999).',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _speak,
                  icon: const Icon(Icons.record_voice_over),
                  label: const Text('Speak result'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => TtsService.instance.stop(),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ],
            ),
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
            width: 200,
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

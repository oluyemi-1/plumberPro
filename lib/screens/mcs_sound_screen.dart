import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/heat_pump_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

/// MCS 020 sound-pressure level estimator.
///
/// Simplified version of the published MCS 020 procedure suitable for trainee
/// design work. Uses sound power Lw, hemispherical free-field attenuation,
/// reflection corrections and an optional façade reflection at the assessment
/// position to predict Lp at the neighbour. The threshold for compliance
/// without acoustic mitigation is 42 dB(A).
class McsSoundScreen extends StatefulWidget {
  const McsSoundScreen({super.key});

  @override
  State<McsSoundScreen> createState() => _McsSoundScreenState();
}

class _McsSoundScreenState extends State<McsSoundScreen> {
  final _lwCtrl = TextEditingController(text: '60');
  final _distCtrl = TextEditingController(text: '5');
  ReflectionPreset _refl = reflectionPresets[1]; // 1 wall close
  bool _facadeReflection = true;

  @override
  void dispose() {
    _lwCtrl.dispose();
    _distCtrl.dispose();
    super.dispose();
  }

  double get _lw => double.tryParse(_lwCtrl.text) ?? 0;
  double get _distance => double.tryParse(_distCtrl.text) ?? 0;

  /// Hemispherical attenuation per distance — 20·log10(r) + 11 in dB.
  /// Plus reflection from siting and an optional +3 dB for assessment near a
  /// neighbour façade.
  double get _attenuation {
    if (_distance <= 0) return 0;
    return 20 * (math.log(_distance) / math.ln10) + 11;
  }

  double get _lp {
    final base = _lw - _attenuation;
    final reflective = base + _refl.dB + (_facadeReflection ? 3 : 0);
    return reflective;
  }

  bool get _passes => _lp <= 42;

  void _speak() {
    final pass = _passes ? 'passes' : 'does not pass';
    TtsService.instance.speak(
      'Sound power level ${_lw.toStringAsFixed(0)} dB(A). Distance to assessment position ${_distance.toStringAsFixed(1)} metres. Reflections add ${_refl.dB.toStringAsFixed(0)} dB and façade ${(_facadeReflection ? 3 : 0).toString()} dB. Predicted sound pressure ${_lp.toStringAsFixed(1)} dB(A). This $pass the 42 dB(A) MCS 020 threshold.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final pass = _passes;
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCS 020 sound assessment'),
        actions: [
          IconButton(
            tooltip: 'Speak result',
            icon: const Icon(Icons.record_voice_over),
            onPressed: _speak,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: AppColors.coldWater.withValues(alpha: 0.07),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.graphic_eq,
                        color: AppColors.coldWater),
                    const SizedBox(width: 8),
                    Text('What this tool does',
                        style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'Predicts the sound-pressure level at the assessment position from the manufacturer\'s sound power level, distance, and reflection conditions. The MCS 020 limit without acoustic mitigation is 42 dB(A) at the nearest neighbour assessment position.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _section('Outdoor unit'),
          _numberField(
              'Sound power level Lw (dB(A))', _lwCtrl,
              hint: 'From the manufacturer data plate. Typical 5 kW ASHP 55–62.'),
          const SizedBox(height: 6),
          _section('Geometry'),
          _numberField('Distance to assessment position (m)', _distCtrl,
              hint:
                  'Straight-line distance to the nearest neighbour habitable window.'),
          const SizedBox(height: 12),
          _section('Reflection conditions'),
          ...reflectionPresets.map((r) => RadioListTile<ReflectionPreset>(
                value: r,
                groupValue: _refl,
                onChanged: (v) => setState(() => _refl = v ?? _refl),
                title: Text(r.label),
                subtitle: Text('+${r.dB.toStringAsFixed(0)} dB'),
                dense: true,
              )),
          SwitchListTile(
            value: _facadeReflection,
            onChanged: (v) => setState(() => _facadeReflection = v),
            title: const Text('Add 3 dB for façade reflection at assessment'),
            subtitle: const Text(
                'MCS 020 includes a +3 dB allowance for sound reflecting off the neighbour\'s façade.'),
          ),
          const SizedBox(height: 14),
          Card(
            color: pass
                ? Colors.green.withValues(alpha: 0.10)
                : Colors.redAccent.withValues(alpha: 0.10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(
                      pass ? Icons.check_circle : Icons.warning_amber,
                      color: pass ? Colors.green : Colors.redAccent,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        pass
                            ? 'Predicted Lp meets MCS 020 (≤ 42 dB(A))'
                            : 'Predicted Lp exceeds MCS 020 — mitigation required',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text('${_lp.toStringAsFixed(1)} dB(A)',
                      style: TextStyle(
                        color: pass ? Colors.green.shade800 : Colors.red.shade700,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      )),
                  const Divider(height: 20),
                  _row('Lw — sound power level', '${_lw.toStringAsFixed(1)} dB(A)'),
                  _row('Distance attenuation',
                      '${_attenuation.toStringAsFixed(1)} dB'),
                  _row('Reflection (siting)', '+${_refl.dB.toStringAsFixed(0)} dB'),
                  _row('Reflection (façade)',
                      _facadeReflection ? '+3 dB' : '0 dB'),
                  const Divider(),
                  _row('Predicted Lp at assessment',
                      '${_lp.toStringAsFixed(1)} dB(A)',
                      bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!pass)
            Card(
              color: AppColors.gas.withValues(alpha: 0.10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.tips_and_updates,
                          color: AppColors.gas),
                      const SizedBox(width: 8),
                      Text('Mitigation options',
                          style: Theme.of(context).textTheme.titleMedium),
                    ]),
                    const SizedBox(height: 6),
                    const Text(
                        '• Move the unit further from the neighbour assessment point.'),
                    const Text(
                        '• Re-orient the unit so the fan does not face the neighbour.'),
                    const Text(
                        '• Choose a quieter unit with a lower sound power level.'),
                    const Text(
                        '• Add an acoustic enclosure or barrier (calculate the new attenuation).'),
                    const Text(
                        '• Use the MCS Acoustic Calculator full procedure with directivity.'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _section(String s) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 4),
        child: Text(s, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _numberField(String label, TextEditingController c, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          helperText: hint,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _row(String l, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(l)),
          Text(v,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}

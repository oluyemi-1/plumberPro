import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../services/tts_service.dart';

class TightnessTestScreen extends StatefulWidget {
  const TightnessTestScreen({super.key});

  @override
  State<TightnessTestScreen> createState() => _TightnessTestScreenState();
}

class _TightnessTestScreenState extends State<TightnessTestScreen> {
  static const List<String> _categories = [
    'UP/1A — ≤ 35 mbar working pressure, ≤ 1 m³ pipework volume',
    'UP/1 — > 1 m³ or > 35 mbar working pressure',
  ];
  int _categoryIdx = 0;

  static const List<String> _media = [
    'Air',
    'Natural gas',
    'Inert (nitrogen)',
  ];
  int _mediumIdx = 1;

  final TextEditingController _volumeCtrl =
      TextEditingController(text: '200');
  final TextEditingController _testPressureCtrl =
      TextEditingController(text: '21');
  final TextEditingController _stabCtrl = TextEditingController(text: '5');
  final TextEditingController _durationCtrl =
      TextEditingController(text: '10');
  final TextEditingController _allowedDropCtrl =
      TextEditingController(text: '0.25');
  final TextEditingController _measuredDropCtrl =
      TextEditingController(text: '0');

  double? _suggestedDrop;
  double? _leakRate;
  bool? _pass;

  @override
  void dispose() {
    _volumeCtrl.dispose();
    _testPressureCtrl.dispose();
    _stabCtrl.dispose();
    _durationCtrl.dispose();
    _allowedDropCtrl.dispose();
    _measuredDropCtrl.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  void _calculate() {
    final volumeL = double.tryParse(_volumeCtrl.text) ?? 0;
    final testP = double.tryParse(_testPressureCtrl.text) ?? 0;
    final dur = double.tryParse(_durationCtrl.text) ?? 0;
    final allowed = double.tryParse(_allowedDropCtrl.text) ?? 0;
    final measured = double.tryParse(_measuredDropCtrl.text) ?? 0;

    if (volumeL <= 0 || testP <= 0 || dur <= 0) {
      setState(() {
        _suggestedDrop = null;
        _leakRate = null;
        _pass = null;
      });
      return;
    }

    // Suggested allowable drop: 5 / V_L floored at 0.25 mbar.
    final volumeM3 = volumeL / 1000;
    double suggested;
    if (volumeM3 <= 1) {
      suggested = 5 / volumeL;
    } else {
      suggested = 5 / (volumeL * 1.5);
    }
    if (suggested < 0.25) suggested = 0.25;

    // Leak rate (litres/h) = dP * V / (Pwork * t_hours)
    // Working pressure assumed equal to test pressure (mbar).
    final tHours = dur / 60.0;
    final leakRate = (measured * volumeL) / (testP * tHours);

    final pass = measured <= allowed;

    setState(() {
      _suggestedDrop = suggested;
      _leakRate = leakRate;
      _pass = pass;
    });
  }

  Future<void> _speakResult() async {
    if (_suggestedDrop == null) return;
    final cat = _categoryIdx == 0 ? 'UP one A' : 'UP one';
    final passTxt = _pass == null
        ? ''
        : (_pass! ? 'Test result: pass.' : 'Test result: fail.');
    final txt =
        'Procedure $cat. Suggested allowable pressure drop ${_suggestedDrop!.toStringAsFixed(2)} millibar. '
        'Calculated leak rate ${_leakRate!.toStringAsFixed(3)} litres per hour. $passTxt '
        'Remember temperature must stabilise — pressure must not drift more than zero point two five millibar in the last minute of stabilisation.';
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
      appBar: AppBar(title: const Text('Tightness test (IGEM/UP/1)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Test setup',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _chipRow(
                    title: 'Test category',
                    options: _categories,
                    selectedIndex: _categoryIdx,
                    onSelected: (i) {
                      _categoryIdx = i;
                      _stabCtrl.text = i == 0 ? '5' : '30';
                      _durationCtrl.text = i == 0 ? '10' : '30';
                    },
                  ),
                  const SizedBox(height: 10),
                  _chipRow(
                    title: 'Test medium',
                    options: _media,
                    selectedIndex: _mediumIdx,
                    onSelected: (i) => _mediumIdx = i,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _volumeCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: formatter,
                    decoration: _decoration('Pipework volume (litres)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _testPressureCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: formatter,
                    decoration: _decoration('Test pressure (mbar)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _stabCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: formatter,
                    decoration:
                        _decoration('Stabilisation period required (min)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _durationCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: formatter,
                    decoration: _decoration('Test duration (min)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _allowedDropCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: formatter,
                    decoration:
                        _decoration('Allowed pressure drop (mbar) — target'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _measuredDropCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: formatter,
                    decoration:
                        _decoration('Measured pressure drop (mbar)'),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_suggestedDrop != null) _buildResultCard(),
          const SizedBox(height: 14),
          _buildTipCard(),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final passColor =
        _pass == true ? Colors.green.shade700 : AppColors.hotWater;
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Result',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            if (_pass != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: passColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: passColor),
                ),
                child: Text(
                  _pass! ? 'PASS — measured drop within limit' : 'FAIL — exceeds allowed drop',
                  style: TextStyle(
                    color: passColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            _resultRow('Recommended procedure',
                _categoryIdx == 0 ? 'IGEM/UP/1A' : 'IGEM/UP/1'),
            _resultRow('Suggested allowable drop',
                '${_suggestedDrop!.toStringAsFixed(2)} mbar'),
            _resultRow('Calculated leak rate',
                '${_leakRate!.toStringAsFixed(3)} L/h'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gas.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Stabilisation: temperature must stabilise — pressure must not drift more than 0.25 mbar in the last minute of stabilisation before the test starts.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
    );
  }

  Widget _buildTipCard() {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Leak rate conversion',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Leak rate (L/h) = ΔP × V / (P_working × t_hours)\n'
              'Worked example: ΔP = 0.5 mbar, V = 200 L, P = 21 mbar, t = 0.167 h (10 min)\n'
              'Leak rate ≈ (0.5 × 200) / (21 × 0.167) ≈ 28.6 L/h at NTP.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Reference: IGEM/UP/1 and IGEM/UP/1A — Tightness testing and direct purging of small low-pressure industrial and commercial natural gas installations.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
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

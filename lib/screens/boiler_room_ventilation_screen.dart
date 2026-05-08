import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../services/tts_service.dart';

class BoilerRoomVentilationScreen extends StatefulWidget {
  const BoilerRoomVentilationScreen({super.key});

  @override
  State<BoilerRoomVentilationScreen> createState() =>
      _BoilerRoomVentilationScreenState();
}

class _BoilerRoomVentilationScreenState
    extends State<BoilerRoomVentilationScreen> {
  final TextEditingController _kwCtrl = TextEditingController(text: '200');
  final TextEditingController _volumeCtrl =
      TextEditingController(text: '200');

  static const List<String> _flueTypes = [
    'Open flue',
    'Balanced flue / room sealed',
    'Mixed',
  ];
  int _flueIdx = 0;

  static const List<String> _locations = [
    'Below ground',
    'Above ground (typical)',
  ];
  int _locationIdx = 1;

  double? _lowArea;
  double? _highArea;
  double? _minVolume;
  bool? _volumeOk;
  bool _mechanicalAdvised = false;
  String? _louvreNote;

  @override
  void dispose() {
    _kwCtrl.dispose();
    _volumeCtrl.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  void _calculate() {
    final kw = double.tryParse(_kwCtrl.text) ?? 0;
    final vol = double.tryParse(_volumeCtrl.text) ?? 0;
    if (kw <= 0) {
      setState(() {
        _lowArea = null;
        _highArea = null;
        _minVolume = null;
        _volumeOk = null;
        _mechanicalAdvised = false;
        _louvreNote = null;
      });
      return;
    }

    double low;
    double high;

    switch (_flueIdx) {
      case 1: // Balanced flue / room sealed
        low = 0.4 * kw;
        high = 0.4 * kw;
        break;
      case 2: // Mixed — average between open and balanced
        low = (4.0 + 0.4) / 2 * kw;
        high = (2.0 + 0.4) / 2 * kw;
        break;
      default: // Open flue (simplified 4 cm²/kW)
        low = 4.0 * kw;
        high = low * 0.5;
    }

    // Below-ground rooms get +50% on both vents.
    if (_locationIdx == 0) {
      low *= 1.5;
      high *= 1.5;
    }

    // Boiler-room volume check: 4.65 m³ per 30 kW.
    final minVol = (kw / 30) * 4.65;
    final volumeOk = vol >= minVol;

    final mechanical = _locationIdx == 0 || !volumeOk;

    // Louvre conversion at 50% physical free area:
    final louvreCm2 = low * 2; // physical area
    // Choose a sensible aspect: width 600 mm, height = louvreCm2 / 60.
    final widthMm = 600;
    final heightMm = (louvreCm2 / (widthMm / 10)).toStringAsFixed(0);

    setState(() {
      _lowArea = low;
      _highArea = high;
      _minVolume = minVol;
      _volumeOk = volumeOk;
      _mechanicalAdvised = mechanical;
      _louvreNote =
          'Equivalent louvre at 50% free area: $widthMm × $heightMm mm physical.';
    });
  }

  Future<void> _speakResult() async {
    if (_lowArea == null) return;
    final txt =
        'Required low-level free vent area ${_lowArea!.toStringAsFixed(0)} square centimetres. '
        'Required high-level free vent area ${_highArea!.toStringAsFixed(0)} square centimetres. '
        'Minimum boiler-room volume ${_minVolume!.toStringAsFixed(1)} cubic metres. '
        '${_volumeOk == true ? "Volume sufficient." : "Volume insufficient — increase the room or use mechanical ventilation."} '
        '${_mechanicalAdvised ? "Mechanical ventilation is recommended." : "Natural ventilation is acceptable."}';
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
              selectedColor: AppColors.coldWater.withValues(alpha: 0.22),
              labelStyle: TextStyle(
                color: selected ? AppColors.primaryDark : AppColors.text,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: selected
                      ? AppColors.coldWater
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
      appBar: AppBar(title: const Text('Boiler room ventilation (BS 6644)')),
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
                    controller: _kwCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: formatter,
                    decoration: _decoration(
                        'Total appliance net heat input (kW)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _volumeCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: formatter,
                    decoration:
                        _decoration('Boiler room volume (m³)'),
                  ),
                  const SizedBox(height: 12),
                  _chipRow(
                    title: 'Flue type',
                    options: _flueTypes,
                    selectedIndex: _flueIdx,
                    onSelected: (i) => _flueIdx = i,
                  ),
                  const SizedBox(height: 10),
                  _chipRow(
                    title: 'Room location',
                    options: _locations,
                    selectedIndex: _locationIdx,
                    onSelected: (i) => _locationIdx = i,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate ventilation'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_lowArea != null) _buildResultCard(),
          const SizedBox(height: 14),
          _buildTipCard(),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.air, color: AppColors.coldWater),
                const SizedBox(width: 8),
                Text('Result',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 10),
            _resultRow('Low-level free vent area',
                '${_lowArea!.toStringAsFixed(0)} cm²'),
            _resultRow('High-level free vent area',
                '${_highArea!.toStringAsFixed(0)} cm²'),
            _resultRow('Minimum boiler-room volume',
                '${_minVolume!.toStringAsFixed(1)} m³'),
            _resultRow('Volume check',
                _volumeOk == true ? 'OK' : 'Insufficient'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.coldWater.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _louvreNote ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 8),
            if (_mechanicalAdvised)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color:
                          AppColors.accent.withValues(alpha: 0.55)),
                ),
                child: Text(
                  'Mechanical ventilation recommended (below-ground location or insufficient room volume). Provide interlocked supply/extract fans with a low-gas-pressure cut-off as required by BS 6644.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              'Grille free area is typically 50% of the physical area — double the calculated free area when sizing the louvre.',
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
                Icon(Icons.menu_book, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Standard reference',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'BS 6644 — Specification for the installation and maintenance of gas-fired hot water boilers of rated inputs between 70 kW (net) and 1.8 MW (net) for natural gas and LPG. The simplified 4 cm²/kW open-flue rule used here is a defensible starting point; verify with section 8 of BS 6644 for installations with mixed flue types or non-standard layouts.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Minimum room volume rule of thumb: 4.65 m³ per 30 kW for atmospheric appliances (BS 5440 / BS 6644 family).',
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

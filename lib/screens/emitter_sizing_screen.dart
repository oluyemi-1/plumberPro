import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/heat_pump_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

/// Tool that converts a radiator output rated at Δt 50 K to its actual output
/// at the lower flow temperatures used by a heat pump, and offers the reverse
/// calculation to size the radiator needed for a target room load.
class EmitterSizingScreen extends StatefulWidget {
  const EmitterSizingScreen({super.key});

  @override
  State<EmitterSizingScreen> createState() => _EmitterSizingScreenState();
}

class _EmitterSizingScreenState extends State<EmitterSizingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  // Forward direction: known rating, find actual output.
  final _ratedCtrl = TextEditingController(text: '1500');
  double _flow = 45;
  double _ret = 40;
  double _room = 20;
  double _exp = 1.30;

  // Reverse direction: known load, find rating needed.
  final _loadCtrl = TextEditingController(text: '1200');
  double _flowR = 45;
  double _retR = 40;
  double _roomR = 20;
  double _expR = 1.30;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _ratedCtrl.dispose();
    _loadCtrl.dispose();
    super.dispose();
  }

  double get _mwt => (_flow + _ret) / 2;
  double get _mwtR => (_flowR + _retR) / 2;
  double get _dt => _mwt - _room;
  double get _dtR => _mwtR - _roomR;

  double get _actualOutput {
    final rated = double.tryParse(_ratedCtrl.text) ?? 0;
    return radiatorOutputAt(
      ratedOutputDt50: rated,
      meanWaterTemp: _mwt,
      roomTemp: _room,
      radiatorExponent: _exp,
    );
  }

  double get _requiredDt50 {
    final load = double.tryParse(_loadCtrl.text) ?? 0;
    return radiatorRequiredRatingDt50(
      requiredOutputAtNewDt: load,
      meanWaterTemp: _mwtR,
      roomTemp: _roomR,
      radiatorExponent: _expR,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emitter sizing for heat pumps'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.south_west), text: 'De-rate'),
            Tab(icon: Icon(Icons.north_east), text: 'Up-size'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _derate(context),
          _upsize(context),
        ],
      ),
    );
  }

  Widget _derate(BuildContext context) {
    final rated = double.tryParse(_ratedCtrl.text) ?? 0;
    final factor = rated == 0 ? 0 : _actualOutput / rated;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _intro(
          'Convert a radiator output quoted at the standard Δt 50 K to its actual output at heat pump flow temperatures.',
        ),
        _numberField('Manufacturer rating at Δt 50 K (W)', _ratedCtrl,
            onChange: (_) => setState(() {})),
        _tempBlock(
          flow: _flow,
          ret: _ret,
          room: _room,
          exp: _exp,
          onFlow: (v) => setState(() => _flow = v),
          onRet: (v) => setState(() => _ret = v),
          onRoom: (v) => setState(() => _room = v),
          onExp: (v) => setState(() => _exp = v),
        ),
        const SizedBox(height: 12),
        _resultCard(
          context: context,
          title: 'Actual output at the heat pump Δt',
          mainValue: '${_actualOutput.toStringAsFixed(0)} W',
          mainColor: AppColors.accent,
          rows: [
            _ResultRow('Mean water temperature', '${_mwt.toStringAsFixed(1)} °C'),
            _ResultRow('Δt (mean water to room)',
                '${_dt.toStringAsFixed(1)} K'),
            _ResultRow('Output factor',
                '${(factor * 100).toStringAsFixed(0)} %'),
            _ResultRow('Effective heat output',
                '${_actualOutput.toStringAsFixed(0)} W (${(_actualOutput / 1000).toStringAsFixed(2)} kW)'),
          ],
          onSpeak: () => TtsService.instance.speak(
            'Manufacturer rating ${rated.toStringAsFixed(0)} watts at delta T fifty. Actual output at flow ${_flow.toStringAsFixed(0)} return ${_ret.toStringAsFixed(0)} room ${_room.toStringAsFixed(0)} is ${_actualOutput.toStringAsFixed(0)} watts. That is ${(factor * 100).toStringAsFixed(0)} percent of the rated value.',
          ),
        ),
      ],
    );
  }

  Widget _upsize(BuildContext context) {
    final required = _requiredDt50;
    final load = double.tryParse(_loadCtrl.text) ?? 0;
    final factor = load == 0 ? 0 : required / load;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _intro(
          'Given the room\'s heat loss and the heat pump flow temperature, find the rating at Δt 50 K that the radiator must have.',
        ),
        _numberField('Room heat load (W)', _loadCtrl,
            onChange: (_) => setState(() {})),
        _tempBlock(
          flow: _flowR,
          ret: _retR,
          room: _roomR,
          exp: _expR,
          onFlow: (v) => setState(() => _flowR = v),
          onRet: (v) => setState(() => _retR = v),
          onRoom: (v) => setState(() => _roomR = v),
          onExp: (v) => setState(() => _expR = v),
        ),
        const SizedBox(height: 12),
        _resultCard(
          context: context,
          title: 'Radiator rating required at Δt 50 K',
          mainValue: required.isFinite
              ? '${required.toStringAsFixed(0)} W'
              : '—',
          mainColor: AppColors.primary,
          rows: [
            _ResultRow('Mean water temperature',
                '${_mwtR.toStringAsFixed(1)} °C'),
            _ResultRow('Δt at new flow',
                '${_dtR.toStringAsFixed(1)} K'),
            _ResultRow('Up-size factor vs Δt 50 K',
                '${factor.toStringAsFixed(2)}×'),
            _ResultRow(
              'Pick a radiator with this Δt 50 rating',
              required.isFinite
                  ? '≥ ${required.toStringAsFixed(0)} W'
                  : '—',
              highlight: true,
            ),
          ],
          onSpeak: () => TtsService.instance.speak(
            required.isFinite
                ? 'For a load of ${load.toStringAsFixed(0)} watts at flow ${_flowR.toStringAsFixed(0)} room ${_roomR.toStringAsFixed(0)}, you need a radiator rated at least ${required.toStringAsFixed(0)} watts at delta T fifty. That is ${factor.toStringAsFixed(1)} times the load.'
                : 'Increase the flow temperature or check inputs.',
          ),
        ),
      ],
    );
  }

  Widget _intro(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      );

  Widget _numberField(String label, TextEditingController c,
      {required ValueChanged<String> onChange}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChange,
      ),
    );
  }

  Widget _tempBlock({
    required double flow,
    required double ret,
    required double room,
    required double exp,
    required ValueChanged<double> onFlow,
    required ValueChanged<double> onRet,
    required ValueChanged<double> onRoom,
    required ValueChanged<double> onExp,
  }) {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          _slider('Flow temperature', flow, 30, 60, '°C', onFlow),
          _slider('Return temperature', ret, 25, 55, '°C', onRet),
          _slider('Room temperature', room, 16, 24, '°C', onRoom),
          _slider('Radiator exponent (n)', exp, 1.20, 1.40, '', onExp,
              digits: 2, divisions: 20),
        ]),
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    String unit,
    ValueChanged<double> onChanged, {
    int digits = 0,
    int divisions = 30,
  }) {
    return Row(children: [
      SizedBox(
        width: 110,
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
      Expanded(
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: '${value.toStringAsFixed(digits)}$unit',
          onChanged: onChanged,
        ),
      ),
      SizedBox(
        width: 60,
        child: Text('${value.toStringAsFixed(digits)}$unit',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    ]);
  }

  Widget _resultCard({
    required BuildContext context,
    required String title,
    required String mainValue,
    required Color mainColor,
    required List<_ResultRow> rows,
    required VoidCallback onSpeak,
  }) {
    return Card(
      color: mainColor.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(mainValue,
                style: TextStyle(
                  color: mainColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                )),
            const SizedBox(height: 8),
            ...rows.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: Text(r.label)),
                      Text(
                        r.value,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: r.highlight ? mainColor : AppColors.text,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton.icon(
                onPressed: onSpeak,
                icon: const Icon(Icons.record_voice_over),
                label: const Text('Speak result'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => TtsService.instance.stop(),
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
            ])
          ],
        ),
      ),
    );
  }
}

class _ResultRow {
  final String label;
  final String value;
  final bool highlight;
  const _ResultRow(this.label, this.value, {this.highlight = false});
}

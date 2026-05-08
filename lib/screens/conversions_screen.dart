import 'package:flutter/material.dart';

import '../services/tts_service.dart';
import '../theme.dart';

class ConversionsScreen extends StatefulWidget {
  const ConversionsScreen({super.key});

  @override
  State<ConversionsScreen> createState() => _ConversionsScreenState();
}

class _ConversionsScreenState extends State<ConversionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversions'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Length'),
            Tab(text: 'Pressure'),
            Tab(text: 'Flow'),
            Tab(text: 'Power'),
            Tab(text: 'Volume'),
            Tab(text: 'Temperature'),
            Tab(text: 'Mass'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _LengthCard(),
          _PressureCard(),
          _FlowCard(),
          _PowerCard(),
          _VolumeCard(),
          _TemperatureCard(),
          _MassCard(),
        ],
      ),
    );
  }
}

/// Generic linked-fields card. Caller supplies the unit list, conversions
/// (each value -> base) and inverse (base -> each value).
class _LinkedFieldsCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> units;
  final List<String> hints;
  final List<double Function(double v)> toBase;
  final List<double Function(double base)> fromBase;
  final double initialBase;
  final String unitFor;

  const _LinkedFieldsCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.units,
    required this.hints,
    required this.toBase,
    required this.fromBase,
    required this.initialBase,
    required this.unitFor,
  });

  @override
  State<_LinkedFieldsCard> createState() => _LinkedFieldsCardState();
}

class _LinkedFieldsCardState extends State<_LinkedFieldsCard> {
  late final List<TextEditingController> _controllers;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.units.length,
      (_) => TextEditingController(),
    );
    _setFromBase(widget.initialBase);
    for (var i = 0; i < _controllers.length; i++) {
      final idx = i;
      _controllers[i].addListener(() => _onChanged(idx));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged(int idx) {
    if (_updating) return;
    final raw = _controllers[idx].text.trim();
    if (raw.isEmpty) return;
    final v = double.tryParse(raw);
    if (v == null) return;
    final base = widget.toBase[idx](v);
    _setFromBase(base, except: idx);
  }

  String _format(double v) {
    if (v.isNaN || v.isInfinite) return '';
    if (v.abs() >= 1000) return v.toStringAsFixed(1);
    if (v.abs() >= 10) return v.toStringAsFixed(2);
    if (v.abs() >= 1) return v.toStringAsFixed(3);
    if (v == 0) return '0';
    return v.toStringAsPrecision(4);
  }

  void _setFromBase(double base, {int? except}) {
    _updating = true;
    for (var i = 0; i < _controllers.length; i++) {
      if (i == except) continue;
      _controllers[i].text = _format(widget.fromBase[i](base));
    }
    _updating = false;
  }

  Future<void> _speak() async {
    final parts = <String>[];
    for (var i = 0; i < widget.units.length; i++) {
      final t = _controllers[i].text;
      if (t.isEmpty) continue;
      parts.add('$t ${widget.units[i]}');
    }
    if (parts.isEmpty) return;
    await TtsService.instance.speak(
      '${widget.title}. ${widget.unitFor}: ${parts.join(", ")}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: AppColors.cardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(widget.icon, color: widget.iconColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(widget.units.length, (i) {
                  return SizedBox(
                    width: 150,
                    child: TextField(
                      controller: _controllers[i],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: widget.units[i],
                        hintText: widget.hints[i],
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _speak,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Speak result'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LengthCard extends StatelessWidget {
  const _LengthCard();

  @override
  Widget build(BuildContext context) {
    // Base unit: millimetres.
    return _LinkedFieldsCard(
      title: 'Length',
      icon: Icons.straighten,
      iconColor: AppColors.pipeMetal,
      units: const ['mm', 'cm', 'inch', 'ft'],
      hints: const ['1000', '100', '39.37', '3.281'],
      initialBase: 1000,
      unitFor: 'Length',
      toBase: [
        (v) => v,
        (v) => v * 10.0,
        (v) => v * 25.4,
        (v) => v * 304.8,
      ],
      fromBase: [
        (b) => b,
        (b) => b / 10.0,
        (b) => b / 25.4,
        (b) => b / 304.8,
      ],
    );
  }
}

class _PressureCard extends StatelessWidget {
  const _PressureCard();

  @override
  Widget build(BuildContext context) {
    // Base unit: bar.
    return _LinkedFieldsCard(
      title: 'Pressure',
      icon: Icons.speed,
      iconColor: AppColors.coldWater,
      units: const ['bar', 'psi', 'kPa', 'mbar', 'm head'],
      hints: const ['1.0', '14.5', '100', '1000', '10.197'],
      initialBase: 1.0,
      unitFor: 'Pressure',
      toBase: [
        (v) => v,
        (v) => v / 14.5038,
        (v) => v / 100.0,
        (v) => v / 1000.0,
        (v) => v / 10.197,
      ],
      fromBase: [
        (b) => b,
        (b) => b * 14.5038,
        (b) => b * 100.0,
        (b) => b * 1000.0,
        (b) => b * 10.197,
      ],
    );
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard();

  @override
  Widget build(BuildContext context) {
    // Base unit: litres per minute.
    return _LinkedFieldsCard(
      title: 'Flow rate',
      icon: Icons.water_drop,
      iconColor: AppColors.coldWater,
      units: const ['l/min', 'UK gal/min', 'm3/h'],
      hints: const ['10', '2.2', '0.6'],
      initialBase: 10,
      unitFor: 'Flow rate',
      toBase: [
        (v) => v,
        (v) => v * 4.54609,
        (v) => v * 1000.0 / 60.0,
      ],
      fromBase: [
        (b) => b,
        (b) => b / 4.54609,
        (b) => b * 60.0 / 1000.0,
      ],
    );
  }
}

class _PowerCard extends StatelessWidget {
  const _PowerCard();

  @override
  Widget build(BuildContext context) {
    // Base unit: watts.
    return _LinkedFieldsCard(
      title: 'Heat / Power',
      icon: Icons.local_fire_department,
      iconColor: AppColors.hotWater,
      units: const ['W', 'kW', 'BTU/h'],
      hints: const ['1000', '1', '3412'],
      initialBase: 1000,
      unitFor: 'Power',
      toBase: [
        (v) => v,
        (v) => v * 1000.0,
        (v) => v / 3.41214,
      ],
      fromBase: [
        (b) => b,
        (b) => b / 1000.0,
        (b) => b * 3.41214,
      ],
    );
  }
}

class _VolumeCard extends StatelessWidget {
  const _VolumeCard();

  @override
  Widget build(BuildContext context) {
    // Base unit: litres.
    return _LinkedFieldsCard(
      title: 'Volume',
      icon: Icons.inventory_2,
      iconColor: AppColors.brass,
      units: const ['L', 'UK gal', 'm3', 'pint'],
      hints: const ['1', '0.22', '0.001', '1.76'],
      initialBase: 1,
      unitFor: 'Volume',
      toBase: [
        (v) => v,
        (v) => v * 4.54609,
        (v) => v * 1000.0,
        (v) => v * 0.568261,
      ],
      fromBase: [
        (b) => b,
        (b) => b / 4.54609,
        (b) => b / 1000.0,
        (b) => b / 0.568261,
      ],
    );
  }
}

class _TemperatureCard extends StatefulWidget {
  const _TemperatureCard();

  @override
  State<_TemperatureCard> createState() => _TemperatureCardState();
}

class _TemperatureCardState extends State<_TemperatureCard> {
  final _c = TextEditingController(text: '20');
  final _f = TextEditingController();
  final _k = TextEditingController();
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _setFromC(20);
    _c.addListener(() => _onChanged(0));
    _f.addListener(() => _onChanged(1));
    _k.addListener(() => _onChanged(2));
  }

  @override
  void dispose() {
    _c.dispose();
    _f.dispose();
    _k.dispose();
    super.dispose();
  }

  String _fmt(double v) {
    if (v.isNaN || v.isInfinite) return '';
    return v.toStringAsFixed(2);
  }

  void _setFromC(double c, {int except = -1}) {
    _updating = true;
    if (except != 0) _c.text = _fmt(c);
    if (except != 1) _f.text = _fmt(c * 9 / 5 + 32);
    if (except != 2) _k.text = _fmt(c + 273.15);
    _updating = false;
  }

  void _onChanged(int idx) {
    if (_updating) return;
    final src = [_c, _f, _k][idx];
    final raw = src.text.trim();
    if (raw.isEmpty) return;
    final v = double.tryParse(raw);
    if (v == null) return;
    double c;
    switch (idx) {
      case 0:
        c = v;
        break;
      case 1:
        c = (v - 32) * 5 / 9;
        break;
      default:
        c = v - 273.15;
    }
    _setFromC(c, except: idx);
  }

  Future<void> _speak() async {
    await TtsService.instance.speak(
      'Temperature: ${_c.text} Celsius, ${_f.text} Fahrenheit, ${_k.text} Kelvin.',
    );
  }

  Widget _field(String label, TextEditingController ctrl) => SizedBox(
        width: 150,
        child: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: AppColors.cardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.thermostat, color: AppColors.hotWater, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Temperature',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _field('Celsius', _c),
                  _field('Fahrenheit', _f),
                  _field('Kelvin', _k),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _speak,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Speak result'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MassCard extends StatelessWidget {
  const _MassCard();

  @override
  Widget build(BuildContext context) {
    // Base unit: kilograms.
    return _LinkedFieldsCard(
      title: 'Mass',
      icon: Icons.scale,
      iconColor: AppColors.pipeMetal,
      units: const ['kg', 'lb', 'stone', 'oz'],
      hints: const ['1', '2.205', '0.157', '35.27'],
      initialBase: 1,
      unitFor: 'Mass',
      toBase: [
        (v) => v,
        (v) => v * 0.45359237,
        (v) => v * 6.35029318,
        (v) => v * 0.0283495231,
      ],
      fromBase: [
        (b) => b,
        (b) => b / 0.45359237,
        (b) => b / 6.35029318,
        (b) => b / 0.0283495231,
      ],
    );
  }
}

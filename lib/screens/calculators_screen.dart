import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/tts_service.dart';
import '../theme.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calcs = <_CalcTile>[
      _CalcTile(
        title: 'Pipe sizing',
        subtitle: 'Flow velocity from diameter and flow',
        icon: Icons.straighten,
        color: AppColors.coldWater,
        builder: (_) => const PipeSizingScreen(),
      ),
      _CalcTile(
        title: 'Head pressure',
        subtitle: 'Pressure from vertical head',
        icon: Icons.height,
        color: AppColors.primary,
        builder: (_) => const HeadPressureScreen(),
      ),
      _CalcTile(
        title: 'Radiator heat load',
        subtitle: 'Required output in watts and BTU',
        icon: Icons.thermostat,
        color: AppColors.hotWater,
        builder: (_) => const RadiatorHeatLoadScreen(),
      ),
      _CalcTile(
        title: 'System water volume',
        subtitle: 'Estimate total system litres',
        icon: Icons.water_drop,
        color: AppColors.copper,
        builder: (_) => const SystemVolumeScreen(),
      ),
      _CalcTile(
        title: 'Inhibitor dosage',
        subtitle: 'Litres of inhibitor required',
        icon: Icons.science,
        color: AppColors.brass,
        builder: (_) => const InhibitorDosageScreen(),
      ),
      _CalcTile(
        title: 'Fall on a drain',
        subtitle: 'Total fall for a given gradient',
        icon: Icons.trending_down,
        color: AppColors.waste,
        builder: (_) => const DrainFallScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Calculators')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cross = constraints.maxWidth > 900
              ? 3
              : constraints.maxWidth > 560
                  ? 2
                  : 1;
          return GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 148,
            ),
            itemCount: calcs.length,
            itemBuilder: (_, i) => calcs[i],
          );
        },
      ),
    );
  }
}

class _CalcTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
  const _CalcTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: builder));
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared scaffold / helpers
// ---------------------------------------------------------------------------

class _CalcScaffold extends StatelessWidget {
  final String title;
  final List<Widget> inputs;
  final Widget result;
  final String speakText;
  const _CalcScaffold({
    required this.title,
    required this.inputs,
    required this.result,
    required this.speakText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Stop narration',
            icon: const Icon(Icons.stop_circle),
            onPressed: () => TtsService.instance.stop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inputs',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ...inputs,
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          result,
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => TtsService.instance.speak(speakText),
              icon: const Icon(Icons.volume_up),
              label: const Text('Speak result'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

Widget _inputField({
  required TextEditingController controller,
  required String label,
  required String unit,
  required VoidCallback onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        filled: true,
        fillColor: AppColors.cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

Widget _resultCard({
  required String label,
  required String value,
  required String unit,
  Color color = AppColors.primary,
  List<Widget> extras = const [],
  String? warning,
}) {
  return Builder(builder: (context) {
    return Card(
      color: color.withValues(alpha: 0.07),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: color,
                    )),
                const SizedBox(width: 6),
                Text(unit,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.muted,
                        )),
              ],
            ),
            if (extras.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...extras,
            ],
            if (warning != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gas.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gas),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.gas),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(warning,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  });
}

double? _parse(TextEditingController c) {
  final t = c.text.trim();
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

String _fmt(double? v, int dp) {
  if (v == null || v.isNaN || v.isInfinite) return '—';
  return v.toStringAsFixed(dp);
}

// ---------------------------------------------------------------------------
// a. Pipe sizing (flow velocity)
// ---------------------------------------------------------------------------

class PipeSizingScreen extends StatefulWidget {
  const PipeSizingScreen({super.key});

  @override
  State<PipeSizingScreen> createState() => _PipeSizingScreenState();
}

class _PipeSizingScreenState extends State<PipeSizingScreen> {
  final _dia = TextEditingController(text: '15');
  final _flow = TextEditingController(text: '12');

  @override
  void dispose() {
    _dia.dispose();
    _flow.dispose();
    super.dispose();
  }

  double? get _velocity {
    final d = _parse(_dia);
    final q = _parse(_flow);
    if (d == null || q == null || d <= 0) return null;
    final area = math.pi * math.pow(d / 2000, 2);
    return (q / 60000) / area;
  }

  @override
  Widget build(BuildContext context) {
    final v = _velocity;
    String? warn;
    if (v != null) {
      if (v > 2.5) {
        warn =
            'Velocity exceeds 2.5 m/s, too fast for plastic pipe. Size up the pipe.';
      } else if (v > 2.0) {
        warn =
            'Velocity exceeds 2.0 m/s, likely to cause noise in copper. Consider a larger pipe.';
      }
    }
    final speak = v == null
        ? 'Enter a diameter and flow rate.'
        : 'Flow velocity is ${v.toStringAsFixed(2)} metres per second.'
            '${warn != null ? ' Warning. $warn' : ''}';

    return _CalcScaffold(
      title: 'Pipe sizing',
      inputs: [
        _inputField(
          controller: _dia,
          label: 'Internal diameter',
          unit: 'mm',
          onChanged: () => setState(() {}),
        ),
        _inputField(
          controller: _flow,
          label: 'Flow rate',
          unit: 'l/min',
          onChanged: () => setState(() {}),
        ),
      ],
      result: _resultCard(
        label: 'Flow velocity',
        value: _fmt(v, 2),
        unit: 'm/s',
        color: AppColors.coldWater,
        warning: warn,
      ),
      speakText: speak,
    );
  }
}

// ---------------------------------------------------------------------------
// b. Head pressure
// ---------------------------------------------------------------------------

class HeadPressureScreen extends StatefulWidget {
  const HeadPressureScreen({super.key});

  @override
  State<HeadPressureScreen> createState() => _HeadPressureScreenState();
}

class _HeadPressureScreenState extends State<HeadPressureScreen> {
  final _head = TextEditingController(text: '10');

  @override
  void dispose() {
    _head.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _parse(_head);
    double? bar;
    double? kpa;
    double? psi;
    if (h != null && h >= 0) {
      final pPa = 1000 * 9.81 * h;
      bar = pPa / 1e5;
      kpa = pPa / 1000;
      psi = bar * 14.5038;
    }

    final speak = bar == null
        ? 'Enter a head in metres.'
        : 'Head pressure is ${bar.toStringAsFixed(3)} bar, '
            'which is ${kpa!.toStringAsFixed(1)} kilopascals '
            'or ${psi!.toStringAsFixed(1)} pounds per square inch.';

    return _CalcScaffold(
      title: 'Head pressure',
      inputs: [
        _inputField(
          controller: _head,
          label: 'Vertical head',
          unit: 'm',
          onChanged: () => setState(() {}),
        ),
      ],
      result: _resultCard(
        label: 'Static pressure',
        value: _fmt(bar, 3),
        unit: 'bar',
        color: AppColors.primary,
        extras: [
          _kvRow('kPa', _fmt(kpa, 1)),
          _kvRow('psi', _fmt(psi, 2)),
        ],
      ),
      speakText: speak,
    );
  }
}

Widget _kvRow(String k, String v) {
  return Builder(builder: (context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(k,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
          ),
          Text(v, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  });
}

// ---------------------------------------------------------------------------
// c. Radiator heat load
// ---------------------------------------------------------------------------

class RadiatorHeatLoadScreen extends StatefulWidget {
  const RadiatorHeatLoadScreen({super.key});

  @override
  State<RadiatorHeatLoadScreen> createState() => _RadiatorHeatLoadScreenState();
}

class _RadiatorHeatLoadScreenState extends State<RadiatorHeatLoadScreen> {
  final _length = TextEditingController(text: '5');
  final _width = TextEditingController(text: '4');
  final _height = TextEditingController(text: '2.4');

  static const _factors = <String, double>{
    'Living room': 40,
    'Bedroom': 30,
    'Kitchen': 45,
    'Bathroom': 50,
  };

  String _type = 'Living room';

  @override
  void dispose() {
    _length.dispose();
    _width.dispose();
    _height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = _parse(_length);
    final w = _parse(_width);
    final h = _parse(_height);
    double? watts;
    double? btu;
    if (l != null && w != null && h != null && l > 0 && w > 0 && h > 0) {
      final vol = l * w * h;
      watts = vol * _factors[_type]!;
      btu = watts * 3.412;
    }

    final speak = watts == null
        ? 'Enter room dimensions.'
        : 'Required radiator output is '
            '${watts.toStringAsFixed(0)} watts, '
            'about ${btu!.toStringAsFixed(0)} BTU per hour, '
            'for a $_type.';

    return _CalcScaffold(
      title: 'Radiator heat load',
      inputs: [
        _inputField(
          controller: _length,
          label: 'Room length',
          unit: 'm',
          onChanged: () => setState(() {}),
        ),
        _inputField(
          controller: _width,
          label: 'Room width',
          unit: 'm',
          onChanged: () => setState(() {}),
        ),
        _inputField(
          controller: _height,
          label: 'Room height',
          unit: 'm',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: _type,
          decoration: InputDecoration(
            labelText: 'Room type',
            filled: true,
            fillColor: AppColors.cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          items: _factors.keys
              .map((k) => DropdownMenuItem(value: k, child: Text(k)))
              .toList(),
          onChanged: (v) => setState(() => _type = v ?? _type),
        ),
      ],
      result: _resultCard(
        label: 'Required output',
        value: _fmt(watts, 0),
        unit: 'W',
        color: AppColors.hotWater,
        extras: [
          _kvRow('BTU/hr', _fmt(btu, 0)),
          _kvRow('Factor', '${_factors[_type]!.toStringAsFixed(0)} W/m³'),
        ],
      ),
      speakText: speak,
    );
  }
}

// ---------------------------------------------------------------------------
// d. System water volume
// ---------------------------------------------------------------------------

class SystemVolumeScreen extends StatefulWidget {
  const SystemVolumeScreen({super.key});

  @override
  State<SystemVolumeScreen> createState() => _SystemVolumeScreenState();
}

class _SystemVolumeScreenState extends State<SystemVolumeScreen> {
  final _single = TextEditingController(text: '4');
  final _double = TextEditingController(text: '3');
  final _p15 = TextEditingController(text: '20');
  final _p22 = TextEditingController(text: '10');
  final _boiler = TextEditingController(text: '3');

  @override
  void dispose() {
    _single.dispose();
    _double.dispose();
    _p15.dispose();
    _p22.dispose();
    _boiler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _parse(_single) ?? 0;
    final d = _parse(_double) ?? 0;
    final p15 = _parse(_p15) ?? 0;
    final p22 = _parse(_p22) ?? 0;
    final b = _parse(_boiler) ?? 0;
    final rad = s * 2.5 + d * 5;
    final pipe = p15 * 0.145 + p22 * 0.32;
    final total = rad + pipe + b;

    final speak =
        'Total system volume is about ${total.toStringAsFixed(1)} litres. '
        'Radiators hold ${rad.toStringAsFixed(1)} litres, '
        'pipework ${pipe.toStringAsFixed(1)} litres, '
        'boiler ${b.toStringAsFixed(1)} litres.';

    return _CalcScaffold(
      title: 'System water volume',
      inputs: [
        _inputField(
          controller: _single,
          label: 'Single radiators',
          unit: 'count',
          onChanged: () => setState(() {}),
        ),
        _inputField(
          controller: _double,
          label: 'Double radiators',
          unit: 'count',
          onChanged: () => setState(() {}),
        ),
        _inputField(
          controller: _p15,
          label: '15 mm pipe length',
          unit: 'm',
          onChanged: () => setState(() {}),
        ),
        _inputField(
          controller: _p22,
          label: '22 mm pipe length',
          unit: 'm',
          onChanged: () => setState(() {}),
        ),
        _inputField(
          controller: _boiler,
          label: 'Boiler volume',
          unit: 'l',
          onChanged: () => setState(() {}),
        ),
      ],
      result: _resultCard(
        label: 'Total system volume',
        value: total.toStringAsFixed(1),
        unit: 'litres',
        color: AppColors.copper,
        extras: [
          _kvRow('Radiators', '${rad.toStringAsFixed(1)} l'),
          _kvRow('Pipework', '${pipe.toStringAsFixed(1)} l'),
          _kvRow('Boiler', '${b.toStringAsFixed(1)} l'),
        ],
      ),
      speakText: speak,
    );
  }
}

// ---------------------------------------------------------------------------
// e. Inhibitor dosage
// ---------------------------------------------------------------------------

class InhibitorDosageScreen extends StatefulWidget {
  const InhibitorDosageScreen({super.key});

  @override
  State<InhibitorDosageScreen> createState() => _InhibitorDosageScreenState();
}

class _InhibitorDosageScreenState extends State<InhibitorDosageScreen> {
  final _vol = TextEditingController(text: '100');

  @override
  void dispose() {
    _vol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _parse(_vol);
    double? dose;
    if (v != null && v > 0) {
      final raw = v / 100.0;
      dose = (raw * 2).round() / 2.0;
    }
    final speak = dose == null
        ? 'Enter a total system volume.'
        : 'Use ${dose.toStringAsFixed(1)} litres of inhibitor for a '
            '${v!.toStringAsFixed(0)} litre system.';

    return _CalcScaffold(
      title: 'Inhibitor dosage',
      inputs: [
        _inputField(
          controller: _vol,
          label: 'Total system volume',
          unit: 'l',
          onChanged: () => setState(() {}),
        ),
      ],
      result: _resultCard(
        label: 'Inhibitor required',
        value: _fmt(dose, 1),
        unit: 'litres',
        color: AppColors.brass,
        extras: [
          _kvRow('Ratio', '1 l per 100 l'),
          if (dose != null)
            _kvRow('Message', 'Use ${dose.toStringAsFixed(1)} l of inhibitor'),
        ],
      ),
      speakText: speak,
    );
  }
}

// ---------------------------------------------------------------------------
// f. Fall on a drain
// ---------------------------------------------------------------------------

class DrainFallScreen extends StatefulWidget {
  const DrainFallScreen({super.key});

  @override
  State<DrainFallScreen> createState() => _DrainFallScreenState();
}

class _DrainFallScreenState extends State<DrainFallScreen> {
  final _length = TextEditingController(text: '6');

  static const _gradients = <String, int>{
    '1 in 40': 40,
    '1 in 60': 60,
    '1 in 80': 80,
  };

  String _gradient = '1 in 40';

  @override
  void dispose() {
    _length.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = _parse(_length);
    double? fallMm;
    if (l != null && l > 0) {
      final ratio = _gradients[_gradient]!;
      fallMm = (l / ratio) * 1000.0;
    }
    final speak = fallMm == null
        ? 'Enter a drain length.'
        : 'Total fall is ${fallMm.toStringAsFixed(0)} millimetres '
            'over ${l!.toStringAsFixed(1)} metres '
            'at $_gradient. '
            'The outlet end must be this much lower than the inlet end.';

    return _CalcScaffold(
      title: 'Fall on a drain',
      inputs: [
        _inputField(
          controller: _length,
          label: 'Drain length',
          unit: 'm',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: _gradient,
          decoration: InputDecoration(
            labelText: 'Gradient',
            filled: true,
            fillColor: AppColors.cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          items: _gradients.keys
              .map((k) => DropdownMenuItem(value: k, child: Text(k)))
              .toList(),
          onChanged: (v) => setState(() => _gradient = v ?? _gradient),
        ),
      ],
      result: _resultCard(
        label: 'Total fall',
        value: _fmt(fallMm, 0),
        unit: 'mm',
        color: AppColors.waste,
        extras: [
          _kvRow('Gradient', _gradient),
          if (fallMm != null)
            _kvRow('End difference', '${fallMm.toStringAsFixed(0)} mm lower'),
        ],
      ),
      speakText: speak,
    );
  }
}

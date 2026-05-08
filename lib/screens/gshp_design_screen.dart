import 'package:flutter/material.dart';

import '../data/gshp_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

enum _CollectorConfig { slinky, vertical, both }

class GshpDesignScreen extends StatefulWidget {
  const GshpDesignScreen({super.key});

  @override
  State<GshpDesignScreen> createState() => _GshpDesignScreenState();
}

class _GshpDesignScreenState extends State<GshpDesignScreen> {
  final TextEditingController _kwController =
      TextEditingController(text: '8.0');
  late SoilType _soil = soilTypes[1];
  double _cop = 4.0;
  _CollectorConfig _config = _CollectorConfig.slinky;

  CollectorSizingResult? _result;

  @override
  void initState() {
    super.initState();
    _kwController.addListener(_recalc);
    _recalc();
  }

  @override
  void dispose() {
    _kwController.removeListener(_recalc);
    _kwController.dispose();
    super.dispose();
  }

  double get _heatPumpKw {
    final raw = _kwController.text.replaceAll(',', '.').trim();
    final parsed = double.tryParse(raw) ?? 0;
    return parsed.clamp(0.0, 50.0);
  }

  void _recalc() {
    final kw = _heatPumpKw;
    if (kw <= 0) {
      setState(() => _result = null);
      return;
    }
    setState(() {
      _result = sizeCollector(
        heatPumpKw: kw,
        soil: _soil,
        cop: _cop,
      );
    });
  }

  String _buildSpokenSummary() {
    final r = _result;
    if (r == null) return 'Enter a heat pump capacity to begin.';
    final buf = StringBuffer()
      ..writeln('Ground source heat pump collector sizing.')
      ..writeln('Heat pump output ${r.heatPumpKw.toStringAsFixed(1)} kilowatts.')
      ..writeln(
          'Ground extraction load ${r.extractionKw.toStringAsFixed(1)} kilowatts.')
      ..writeln('Soil type ${_soil.label}.');
    if (_config != _CollectorConfig.vertical && _soil.kwPerMetreSlinky > 0) {
      buf.writeln(
          'Slinky pipe ${r.slinkyTotalLengthM.toStringAsFixed(0)} metres in '
          '${r.slinkyTrenches} trenches.');
    }
    if (_config != _CollectorConfig.slinky) {
      if (r.verticalBoreholeM.isFinite) {
        buf.writeln(
            'Vertical boreholes ${r.verticalBoreholeCount}, '
            '${r.verticalBoreholeM.toStringAsFixed(0)} metres total.');
      } else {
        buf.writeln('Boreholes not required for this soil.');
      }
    }
    buf.writeln(
        'Always perform a thermal response test for any borehole over six kilowatts.');
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('GSHP collector design')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInputCard(theme),
          const SizedBox(height: 14),
          _buildResultCard(theme),
          const SizedBox(height: 14),
          _buildTipCard(theme),
        ],
      ),
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inputs', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _kwController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Heat pump capacity (kW)',
                helperText: 'Domestic GSHP typically 6 – 16 kW',
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SoilType>(
              value: _soil,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Soil type',
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: [
                for (final s in soilTypes)
                  DropdownMenuItem<SoilType>(
                    value: s,
                    child: Text(s.label, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _soil = v);
                _recalc();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('COP assumption',
                    style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  _cop.toStringAsFixed(1),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: _cop,
              min: 3.0,
              max: 5.0,
              divisions: 20,
              activeColor: AppColors.primary,
              label: _cop.toStringAsFixed(1),
              onChanged: (v) {
                setState(() => _cop = v);
                _recalc();
              },
            ),
            const SizedBox(height: 8),
            Text('Configuration', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in const {
                  _CollectorConfig.slinky: 'Slinky horizontal',
                  _CollectorConfig.vertical: 'Vertical boreholes',
                  _CollectorConfig.both: 'Both',
                }.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: _config == entry.key,
                    selectedColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    side: BorderSide(
                      color: _config == entry.key
                          ? AppColors.primary
                          : AppColors.muted.withValues(alpha: 0.4),
                    ),
                    labelStyle: TextStyle(
                      color: _config == entry.key
                          ? AppColors.primaryDark
                          : AppColors.text,
                      fontWeight: _config == entry.key
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    onSelected: (_) =>
                        setState(() => _config = entry.key),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    final r = _result;
    if (r == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Enter a heat pump capacity to see the collector sizing.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
        ),
      );
    }

    final showSlinky =
        _config != _CollectorConfig.vertical && _soil.kwPerMetreSlinky > 0;
    final showVertical = _config != _CollectorConfig.slinky;
    final slinkyImpossible = _soil.kwPerMetreSlinky <= 0 &&
        _config != _CollectorConfig.vertical;

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Sizing result', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            _resultRow('Heat pump output',
                '${r.heatPumpKw.toStringAsFixed(1)} kW'),
            _resultRow('Ground-side extraction',
                '${r.extractionKw.toStringAsFixed(2)} kW',
                accent: AppColors.coldWater),
            const Divider(height: 24),
            if (showSlinky) ...[
              Text('Slinky horizontal collector',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: AppColors.primaryDark)),
              const SizedBox(height: 6),
              _resultRow('Pipe length',
                  '${r.slinkyTotalLengthM.toStringAsFixed(0)} m'),
              _resultRow('Trench length total',
                  '${r.slinkyTrenchLengthM.toStringAsFixed(0)} m'),
              _resultRow('Trenches (≤ 30 m each)',
                  r.slinkyTrenches.toString()),
              const SizedBox(height: 12),
            ],
            if (slinkyImpossible) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Slinky not feasible in ${_soil.label.toLowerCase()} — '
                  'use vertical boreholes.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.accent),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (showVertical) ...[
              Text('Vertical boreholes',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: AppColors.primaryDark)),
              const SizedBox(height: 6),
              if (r.verticalBoreholeM.isFinite) ...[
                _resultRow('Total length',
                    '${r.verticalBoreholeM.toStringAsFixed(0)} m'),
                _resultRow('Boreholes (100 m max each)',
                    r.verticalBoreholeCount.toString()),
              ] else
                Text('Borehole values unavailable for this soil.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.muted)),
              const SizedBox(height: 12),
            ],
            const Divider(height: 24),
            Text('Soil notes', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(_soil.description,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.muted)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () =>
                    TtsService.instance.speak(_buildSpokenSummary()),
                icon: const Icon(Icons.volume_up),
                label: const Text('Speak result'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, {Color? accent}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: accent ?? AppColors.text,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(ThemeData theme) {
    return Card(
      color: AppColors.gas.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.gas.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.gas),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Indicative only',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'These figures use generic UK extraction rates. Always '
                    'commission a thermal response test (TRT) for any borehole '
                    'system over 6 kW, and follow MIS 3005 / MCS 022 design '
                    'rules for slinky horizontal collectors.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

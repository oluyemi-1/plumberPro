import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/sprinklers_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class SprinklerDesignScreen extends StatefulWidget {
  const SprinklerDesignScreen({super.key});

  @override
  State<SprinklerDesignScreen> createState() => _SprinklerDesignScreenState();
}

class _SprinklerDesignScreenState extends State<SprinklerDesignScreen> {
  late HazardCategory _hazard = hazardCategories[1];
  double _coverageM2 = 60;
  double _kFactor = 80;
  late SupplyType _supply = supplyTypes[2];
  final TextEditingController _pressureController =
      TextEditingController(text: '1.4');

  @override
  void dispose() {
    _pressureController.dispose();
    super.dispose();
  }

  double get _pressureBar {
    final raw = _pressureController.text.replaceAll(',', '.').trim();
    final parsed = double.tryParse(raw) ?? 0.0;
    return parsed.clamp(0.3, 8.0);
  }

  // Q = K · √P  in l/min
  double get _flowPerHead => _kFactor * math.sqrt(_pressureBar);

  double get _totalDemandLpm =>
      _flowPerHead * _hazard.simultaneousHeads.toDouble();

  double get _requiredTankLitres =>
      _totalDemandLpm * _hazard.durationMin * 1.1;

  double get _requiredMainsFlowLpm => _totalDemandLpm;

  String get _pipeSizeSuggestion {
    final q = _totalDemandLpm;
    if (q <= 50) return '25 mm CPVC / copper';
    if (q <= 100) return '32 mm CPVC / copper';
    if (q <= 180) return '40 mm CPVC / copper';
    return '50 mm CPVC / copper or larger';
  }

  // Static head allowance for a typical 2-storey domestic riser plus a
  // friction allowance for the longest run. Values are indicative only.
  double get _staticHeadBar => 0.6; // ~6 m head between riser base and head
  double get _frictionAllowanceBar => 0.4;
  double get _requiredSupplyPressureBar =>
      _pressureBar + _frictionAllowanceBar + _staticHeadBar;

  String _buildSpoken() {
    final buf = StringBuffer()
      ..writeln('Sprinkler design summary.')
      ..writeln('Hazard category ${_hazard.label}.')
      ..writeln(
          'Density ${_hazard.densityMmMin} millimetres per minute over '
          '${_hazard.assumedAreaM2.toStringAsFixed(0)} square metres, '
          '${_hazard.simultaneousHeads} heads operating.')
      ..writeln('Head K factor $_kFactor at '
          '${_pressureBar.toStringAsFixed(2)} bar.')
      ..writeln(
          'Flow per head ${_flowPerHead.toStringAsFixed(0)} litres per minute.')
      ..writeln(
          'Total demand ${_totalDemandLpm.toStringAsFixed(0)} litres per minute.')
      ..writeln(
          'Tank capacity required ${_requiredTankLitres.toStringAsFixed(0)} litres.')
      ..writeln('Pipe size suggestion: $_pipeSizeSuggestion.')
      ..writeln(
          'Required supply pressure ${_requiredSupplyPressureBar.toStringAsFixed(2)} bar.')
      ..writeln('Reference ${_hazard.reference}.');
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sprinkler system design')),
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

            // Hazard category
            Text('Hazard category', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in hazardCategories)
                  ChoiceChip(
                    label: Text(h.label.split(' — ').first),
                    selected: _hazard == h,
                    selectedColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    side: BorderSide(
                      color: _hazard == h
                          ? AppColors.primary
                          : AppColors.muted.withValues(alpha: 0.4),
                    ),
                    labelStyle: TextStyle(
                      color: _hazard == h
                          ? AppColors.primaryDark
                          : AppColors.text,
                      fontWeight: _hazard == h
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    onSelected: (_) => setState(() => _hazard = h),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _hazard.typicalUse,
              style: theme.textTheme.bodySmall,
            ),

            const SizedBox(height: 16),

            // Coverage area slider
            Row(
              children: [
                Text('Coverage area',
                    style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  '${_coverageM2.toStringAsFixed(0)} m²',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: _coverageM2,
              min: 10,
              max: 200,
              divisions: 38,
              activeColor: AppColors.primary,
              label: '${_coverageM2.toStringAsFixed(0)} m²',
              onChanged: (v) => setState(() => _coverageM2 = v),
            ),

            const SizedBox(height: 8),

            // K factor
            Text('Head K-factor', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final k in const [57.0, 80.0, 115.0])
                  ChoiceChip(
                    label: Text('K${k.toStringAsFixed(0)}'),
                    selected: _kFactor == k,
                    selectedColor:
                        AppColors.coldWater.withValues(alpha: 0.18),
                    side: BorderSide(
                      color: _kFactor == k
                          ? AppColors.coldWater
                          : AppColors.muted.withValues(alpha: 0.4),
                    ),
                    labelStyle: TextStyle(
                      color: _kFactor == k
                          ? AppColors.primaryDark
                          : AppColors.text,
                      fontWeight: _kFactor == k
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    onSelected: (_) => setState(() => _kFactor = k),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Pressure
            TextField(
              controller: _pressureController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              decoration: InputDecoration(
                labelText: 'System pressure at head (bar)',
                helperText:
                    'BS 9251 typical residual at head 1.0 – 2.0 bar',
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),

            // Supply type
            Text('Supply type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in supplyTypes)
                  ChoiceChip(
                    label: Text(s.label.split(' — ').first),
                    selected: _supply == s,
                    selectedColor:
                        AppColors.accent.withValues(alpha: 0.15),
                    side: BorderSide(
                      color: _supply == s
                          ? AppColors.accent
                          : AppColors.muted.withValues(alpha: 0.4),
                    ),
                    labelStyle: TextStyle(
                      color: _supply == s
                          ? AppColors.primaryDark
                          : AppColors.text,
                      fontWeight: _supply == s
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    onSelected: (_) => setState(() => _supply = s),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _supply.description,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme) {
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
                Text('Hydraulic result', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            _resultRow(
              'Density',
              '${_hazard.densityMmMin.toStringAsFixed(1)} mm/min',
            ),
            _resultRow(
              'Assumed area',
              '${_hazard.assumedAreaM2.toStringAsFixed(0)} m²',
            ),
            _resultRow(
              'Heads operating',
              _hazard.simultaneousHeads.toString(),
            ),
            _resultRow(
              'Design duration',
              '${_hazard.durationMin} min',
            ),
            const Divider(height: 24),
            _resultRow(
              'Flow per head Q = K·√P',
              '${_flowPerHead.toStringAsFixed(0)} l/min',
              accent: AppColors.coldWater,
            ),
            _resultRow(
              'Total system demand',
              '${_totalDemandLpm.toStringAsFixed(0)} l/min',
              accent: AppColors.coldWater,
            ),
            _resultRow(
              'Required mains flow',
              '${_requiredMainsFlowLpm.toStringAsFixed(0)} l/min',
            ),
            _resultRow(
              'Tank capacity (incl. 10 %)',
              '${_requiredTankLitres.toStringAsFixed(0)} l',
              accent: AppColors.primary,
            ),
            const Divider(height: 24),
            _resultRow('Pipe size suggestion', _pipeSizeSuggestion),
            _resultRow(
              'Static head allowance',
              '${_staticHeadBar.toStringAsFixed(2)} bar',
            ),
            _resultRow(
              'Friction allowance',
              '${_frictionAllowanceBar.toStringAsFixed(2)} bar',
            ),
            _resultRow(
              'Required supply pressure',
              '${_requiredSupplyPressureBar.toStringAsFixed(2)} bar',
              accent: AppColors.accent,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => TtsService.instance.speak(_buildSpoken()),
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
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
            ),
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
                  Text('Indicative only — BS 9251:2021',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'These figures use the simplified BS 9251:2021 approach for '
                    'a quick check. Final design must be by a competent person '
                    'using a full hydraulic calculation, signed onto the BS 9251 '
                    'design and installation certificate. Commercial premises '
                    'fall under BS EN 12845, not this tool.',
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

import 'package:flutter/material.dart';

import '../data/medical_gases_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

/// Searchable reference screen for piped medical gases to HTM 02-01.
class MedicalGasesReferenceScreen extends StatefulWidget {
  const MedicalGasesReferenceScreen({super.key});

  @override
  State<MedicalGasesReferenceScreen> createState() =>
      _MedicalGasesReferenceScreenState();
}

class _MedicalGasesReferenceScreenState
    extends State<MedicalGasesReferenceScreen> {
  String _query = '';

  List<MedicalGas> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return medicalGases;
    return medicalGases
        .where((g) =>
            g.name.toLowerCase().contains(q) ||
            g.formula.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical gases reference (HTM 02-01)'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by gas name or formula',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Text(
              '${results.length} of ${medicalGases.length} gases',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No matching gases'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _GasCard(gas: results[i], onTap: () => _open(results[i])),
                  ),
          ),
        ],
      ),
    );
  }

  void _open(MedicalGas gas) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MedicalGasDetailScreen(gas: gas),
      ),
    );
  }
}

class _GasCard extends StatelessWidget {
  final MedicalGas gas;
  final VoidCallback onTap;
  const _GasCard({required this.gas, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colour = Color(gas.colourArgb);
    final luminance = colour.computeLuminance();
    final fg = luminance > 0.6 ? AppColors.text : Colors.white;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colour,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  gas.formula,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            gas.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${gas.workingPressureBar} bar',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gas.use,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicalGasDetailScreen extends StatelessWidget {
  final MedicalGas gas;
  const _MedicalGasDetailScreen({required this.gas});

  @override
  Widget build(BuildContext context) {
    final colour = Color(gas.colourArgb);
    final luminance = colour.computeLuminance();
    final fg = luminance > 0.6 ? AppColors.text : Colors.white;
    return Scaffold(
      appBar: AppBar(title: Text(gas.name)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: colour,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      gas.formula,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gas.name,
                            style:
                                Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Cylinder colour code',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PropertyTile(
            icon: Icons.speed,
            label: 'Working pressure',
            value: '${gas.workingPressureBar} bar',
          ),
          _PropertyTile(
            icon: Icons.compress,
            label: 'Test pressure',
            value: '${gas.testPressureBar} bar',
          ),
          _PropertyTile(
            icon: Icons.power,
            label: 'Terminal unit standard',
            value: gas.terminalUnit,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            heading: 'Clinical use',
            body: gas.use,
            colour: AppColors.primary,
          ),
          const SizedBox(height: 10),
          _SectionCard(
            heading: 'Hazards',
            body: gas.hazards,
            colour: AppColors.accent,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => TtsService.instance.speak(gas.speakable),
                  icon: const Icon(Icons.record_voice_over),
                  label: const Text('Speak'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => TtsService.instance.stop(),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PropertyTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _PropertyTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label,
            style: Theme.of(context).textTheme.bodySmall),
        subtitle: Text(value,
            style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String heading;
  final String body;
  final Color colour;
  const _SectionCard({
    required this.heading,
    required this.body,
    required this.colour,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colour.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                heading,
                style: TextStyle(
                  color: colour,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

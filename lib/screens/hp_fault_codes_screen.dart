import 'package:flutter/material.dart';

import '../data/hp_fault_codes_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class HpFaultCodesScreen extends StatefulWidget {
  const HpFaultCodesScreen({super.key});

  @override
  State<HpFaultCodesScreen> createState() => _HpFaultCodesScreenState();
}

class _HpFaultCodesScreenState extends State<HpFaultCodesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _brandFilter = 'All';
  String _severityFilter = 'All';

  static const List<String> _severityOptions = <String>[
    'All',
    'Lockout',
    'Warning',
    'Service required',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FaultEntry> _filteredEntries() {
    final entries = <_FaultEntry>[];
    for (final brand in hpBrands) {
      if (_brandFilter != 'All' && brand.name != _brandFilter) continue;
      for (final code in brand.codes) {
        if (_severityFilter != 'All' && code.severity != _severityFilter) {
          continue;
        }
        if (_query.isNotEmpty) {
          final q = _query.toLowerCase();
          final matchesCode = code.code.toLowerCase().contains(q);
          final matchesDesc = code.description.toLowerCase().contains(q);
          if (!matchesCode && !matchesDesc) continue;
        }
        entries.add(_FaultEntry(brand: brand, code: code));
      }
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries();
    final brands = <String>['All', ...hpBrands.map((b) => b.name)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heat pump fault codes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: 'Search code or description',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.muted.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          _FilterRow(
            label: 'Brand',
            options: brands,
            selected: _brandFilter,
            onSelected: (v) => setState(() => _brandFilter = v),
          ),
          _FilterRow(
            label: 'Severity',
            options: _severityOptions,
            selected: _severityFilter,
            onSelected: (v) => setState(() => _severityFilter = v),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No fault codes match the current filters.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _FaultCard(entry: entry);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FaultEntry {
  final HpBrand brand;
  final HpFaultCode code;
  const _FaultEntry({required this.brand, required this.code});
}

class _FilterRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final opt = options[i];
                final isSel = opt == selected;
                return ChoiceChip(
                  label: Text(opt),
                  selected: isSel,
                  onSelected: (_) => onSelected(opt),
                  selectedColor: AppColors.primary.withValues(alpha: 0.18),
                  labelStyle: TextStyle(
                    color: isSel ? AppColors.primaryDark : AppColors.text,
                    fontWeight:
                        isSel ? FontWeight.w600 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSel
                        ? AppColors.primary
                        : AppColors.muted.withValues(alpha: 0.3),
                  ),
                  backgroundColor: AppColors.surface,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Color _severityColor(String severity) {
  switch (severity) {
    case 'Lockout':
      return AppColors.hotWater;
    case 'Warning':
      return AppColors.accent;
    case 'Service required':
      return AppColors.coldWater;
    default:
      return AppColors.muted;
  }
}

class _FaultCard extends StatelessWidget {
  final _FaultEntry entry;
  const _FaultCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final sevColor = _severityColor(entry.code.severity);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _FaultDetailScreen(entry: entry),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      entry.code.code,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Badge(
                          label: entry.brand.name,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 6),
                        _Badge(
                          label: entry.code.severity,
                          color: sevColor,
                          filled: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.code.description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  const _Badge({
    required this.label,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: filled ? Colors.white : color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _FaultDetailScreen extends StatelessWidget {
  final _FaultEntry entry;
  const _FaultDetailScreen({required this.entry});

  @override
  Widget build(BuildContext context) {
    final sevColor = _severityColor(entry.code.severity);
    final code = entry.code;
    return Scaffold(
      appBar: AppBar(
        title: Text('${entry.brand.name}  ${code.code}'),
        actions: [
          IconButton(
            tooltip: 'Read whole card',
            icon: const Icon(Icons.record_voice_over),
            onPressed: () {
              TtsService.instance.speak(code.speakable);
            },
          ),
          IconButton(
            tooltip: 'Stop',
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: () {
              TtsService.instance.stop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  code.code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Badge(
                      label: entry.brand.name,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 6),
                    _Badge(
                      label: code.severity,
                      color: sevColor,
                      filled: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.muted.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              entry.brand.marketNote,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SpeakSection(
            title: 'Description',
            body: code.description,
            spoken: 'Description. ${code.description}',
            icon: Icons.info_outline,
          ),
          _SpeakSection(
            title: 'Likely causes',
            body: code.likelyCauses,
            spoken: 'Likely causes. ${code.likelyCauses}',
            icon: Icons.help_outline,
          ),
          _SpeakSection(
            title: 'Diagnostic steps',
            body: code.diagnosticSteps,
            spoken: 'Diagnostic steps. ${code.diagnosticSteps}',
            icon: Icons.search,
          ),
          _SpeakSection(
            title: 'Fix',
            body: code.fixSteps,
            spoken: 'Fix. ${code.fixSteps}',
            icon: Icons.build_outlined,
          ),
          _SpeakSection(
            title: 'Safety note',
            body: code.safetyNote,
            spoken: 'Safety. ${code.safetyNote}',
            icon: Icons.shield_outlined,
            tint: AppColors.hotWater,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SpeakSection extends StatelessWidget {
  final String title;
  final String body;
  final String spoken;
  final IconData icon;
  final Color? tint;

  const _SpeakSection({
    required this.title,
    required this.body,
    required this.spoken,
    required this.icon,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final accent = tint ?? AppColors.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.volume_up, size: 18),
                  label: const Text('Speak'),
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: () => TtsService.instance.speak(spoken),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                body,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

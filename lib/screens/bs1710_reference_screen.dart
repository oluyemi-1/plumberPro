import 'package:flutter/material.dart';

import '../data/bs1710_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class Bs1710ReferenceScreen extends StatefulWidget {
  const Bs1710ReferenceScreen({super.key});

  @override
  State<Bs1710ReferenceScreen> createState() => _Bs1710ReferenceScreenState();
}

class _Bs1710ReferenceScreenState extends State<Bs1710ReferenceScreen> {
  static const _filters = <String>[
    'All',
    'Water',
    'Heating',
    'Cooling',
    'Steam / condensate',
    'Fuel',
    'Drainage',
  ];

  String _filter = 'All';
  String _query = '';

  List<PipeColourCode> get _filtered {
    return pipeColourCodes.where((p) {
      final matchesCat = _filter == 'All' || p.category == _filter;
      final q = _query.trim().toLowerCase();
      final matchesQ = q.isEmpty ||
          p.service.toLowerCase().contains(q) ||
          p.label.toLowerCase().contains(q);
      return matchesCat && matchesQ;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('BS 1710 pipe identification'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Search by service, e.g. LTHW or drinking',
                hintStyle: const TextStyle(color: AppColors.muted),
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                return Center(
                  child: ChoiceChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.accent,
                    backgroundColor: AppColors.cardBg,
                    labelStyle: TextStyle(
                      color: _filter == f ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text('No matches',
                        style: TextStyle(color: AppColors.muted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final p = results[i];
                      return Card(
                        color: AppColors.cardBg,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => _Bs1710DetailScreen(code: p),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PipeStrip(code: p, height: 32),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    12, 10, 12, 12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(p.service,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.text)),
                                    const SizedBox(height: 2),
                                    Text(p.label,
                                        style: const TextStyle(
                                            color: AppColors.muted)),
                                    const SizedBox(height: 4),
                                    Text(p.category,
                                        style: const TextStyle(
                                            color: AppColors.accent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Bs1710DetailScreen extends StatelessWidget {
  final PipeColourCode code;
  const _Bs1710DetailScreen({required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(code.service),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: PipeStrip(code: code, height: 72),
            ),
            const SizedBox(height: 16),
            Text(code.service,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text)),
            const SizedBox(height: 4),
            Text(code.label,
                style: const TextStyle(
                    fontSize: 16, color: AppColors.muted)),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(code.category,
                  style: const TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
            const Text('Details',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 6),
            Text(code.details,
                style: const TextStyle(color: AppColors.text, height: 1.4)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  await TtsService.instance.stop();
                  await TtsService.instance.speak(code.speakable);
                },
                icon: const Icon(Icons.record_voice_over),
                label: const Text('Speak'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PipeStrip extends StatelessWidget {
  final PipeColourCode code;
  final double height;

  const PipeStrip({
    super.key,
    required this.code,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _PipeStripPainter(code: code),
    );
  }
}

class _PipeStripPainter extends CustomPainter {
  final PipeColourCode code;
  _PipeStripPainter({required this.code});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = Color(code.basicARGB);
    canvas.drawRect(Offset.zero & size, basePaint);

    if (code.codeBands.isEmpty) return;

    // Centre the bands across the strip with proportional widths.
    final bandWidth = size.width / (code.codeBands.length + 2);
    final start = (size.width - bandWidth * code.codeBands.length) / 2;

    for (var i = 0; i < code.codeBands.length; i++) {
      final paint = Paint()..color = Color(code.codeBands[i]);
      final rect = Rect.fromLTWH(
        start + i * bandWidth,
        0,
        bandWidth,
        size.height,
      );
      canvas.drawRect(rect, paint);
    }

    // Pipe edge shading for depth.
    final shadow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.22),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, shadow);
  }

  @override
  bool shouldRepaint(covariant _PipeStripPainter old) => old.code != code;
}

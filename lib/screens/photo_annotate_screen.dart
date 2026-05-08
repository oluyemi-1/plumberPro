import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../services/diagnostics_service.dart';

/// Pure-data stroke drawn over a photo. Each stroke is one continuous pen
/// path; a stroke ends when the user lifts their finger.
class _DrawnStroke {
  final List<Offset> points;
  final Color color;
  final double width;
  _DrawnStroke({required this.color, required this.width})
      : points = <Offset>[];
}

/// Result returned to the caller — path of the saved annotated PNG inside
/// the temp directory. The caller is expected to copy it into permanent
/// storage (typically via `JobLogService.addPhoto`).
class PhotoAnnotateResult {
  final String path;
  const PhotoAnnotateResult(this.path);
}

/// Annotate a photo with pen strokes before saving. Three pen colours
/// (red / yellow / cyan, all high-contrast against most plumbing photos)
/// and two stroke widths. Undo last, clear all, save as PNG.
class PhotoAnnotateScreen extends StatefulWidget {
  /// File path of the source image to annotate.
  final String sourcePath;
  const PhotoAnnotateScreen({super.key, required this.sourcePath});

  @override
  State<PhotoAnnotateScreen> createState() => _PhotoAnnotateScreenState();
}

class _PhotoAnnotateScreenState extends State<PhotoAnnotateScreen> {
  static const _colors = <Color>[
    Color(0xFFFF1744), // red
    Color(0xFFFFEA00), // yellow
    Color(0xFF00E5FF), // cyan
  ];
  static const _widths = <double>[3.0, 7.0];

  final _boundaryKey = GlobalKey();
  final List<_DrawnStroke> _strokes = [];
  Color _color = _colors.first;
  double _width = _widths.first;
  bool _saving = false;

  void _onPanStart(DragStartDetails d) {
    setState(() {
      _strokes.add(_DrawnStroke(color: _color, width: _width)
        ..points.add(d.localPosition));
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.last.points.add(d.localPosition));
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  void _clearAll() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.clear());
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final ctx = _boundaryKey.currentContext;
      if (ctx == null) {
        throw StateError('Annotation boundary not laid out');
      }
      final ro = ctx.findRenderObject();
      if (ro is! RenderRepaintBoundary) {
        throw StateError('Annotation boundary not a RepaintBoundary');
      }
      final image = await ro.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw StateError('PNG encode failed');
      final bytes = byteData.buffer.asUint8List();

      final tmp = await getTemporaryDirectory();
      final out = File(
          '${tmp.path}/annotated_${DateTime.now().millisecondsSinceEpoch}.png');
      await out.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      Navigator.pop(context, PhotoAnnotateResult(out.path));
    } catch (e, st) {
      DiagnosticsService.instance.error(
        'PhotoAnnotateScreen',
        'Could not save annotated photo.',
        '$e\n$st',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save annotated photo.')),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Annotate'),
        actions: [
          IconButton(
            tooltip: 'Undo',
            icon: const Icon(Icons.undo),
            onPressed: _strokes.isEmpty ? null : _undo,
          ),
          IconButton(
            tooltip: 'Clear all',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _strokes.isEmpty ? null : _clearAll,
          ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              child: RepaintBoundary(
                key: _boundaryKey,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // The photo. BoxFit.contain keeps aspect ratio and
                    // gives the user obvious bounds to draw inside.
                    Center(
                      child: Image.file(
                        File(widget.sourcePath),
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _AnnotationPainter(strokes: _strokes),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _ToolBar(
            colors: _colors,
            widths: _widths,
            color: _color,
            width: _width,
            onColor: (c) => setState(() => _color = c),
            onWidth: (w) => setState(() => _width = w),
          ),
        ],
      ),
    );
  }
}

class _AnnotationPainter extends CustomPainter {
  final List<_DrawnStroke> strokes;
  _AnnotationPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      if (s.points.isEmpty) continue;
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (s.points.length == 1) {
        canvas.drawCircle(
            s.points.first, s.width / 2, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
      for (var i = 1; i < s.points.length; i++) {
        path.lineTo(s.points[i].dx, s.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnnotationPainter oldDelegate) =>
      !identical(oldDelegate.strokes, strokes) ||
      oldDelegate.strokes.length != strokes.length ||
      (strokes.isNotEmpty &&
          strokes.last.points.length !=
              (oldDelegate.strokes.isEmpty
                  ? 0
                  : oldDelegate.strokes.last.points.length));
}

class _ToolBar extends StatelessWidget {
  final List<Color> colors;
  final List<double> widths;
  final Color color;
  final double width;
  final ValueChanged<Color> onColor;
  final ValueChanged<double> onWidth;
  const _ToolBar({
    required this.colors,
    required this.widths,
    required this.color,
    required this.width,
    required this.onColor,
    required this.onWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              for (final c in colors)
                _ColorDot(
                  color: c,
                  selected: c.toARGB32() == color.toARGB32(),
                  onTap: () => onColor(c),
                ),
            ]),
            Row(children: [
              for (final w in widths)
                _WidthChip(
                  width: w,
                  selected: w == width,
                  color: color,
                  onTap: () => onWidth(w),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.white : Colors.white24,
              width: selected ? 3 : 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _WidthChip extends StatelessWidget {
  final double width;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _WidthChip({
    required this.width,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 56,
          height: 36,
          decoration: BoxDecoration(
            color:
                selected ? Colors.white24 : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? Colors.white : Colors.white24,
              width: selected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 28,
            height: width,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(width),
            ),
          ),
        ),
      ),
    );
  }
}


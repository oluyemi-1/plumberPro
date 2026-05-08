import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ai_tutor_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import 'settings_screen.dart';

/// Take or pick a photo and have Claude diagnose what's shown — boiler
/// fault codes, fittings, leaks, gauges, data plates etc.
class PhotoDiagnosisScreen extends StatefulWidget {
  const PhotoDiagnosisScreen({super.key});

  @override
  State<PhotoDiagnosisScreen> createState() => _PhotoDiagnosisScreenState();
}

class _PhotoDiagnosisScreenState extends State<PhotoDiagnosisScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _promptCtrl = TextEditingController();

  Uint8List? _imageBytes;
  String? _mediaType;
  String? _result;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    AiTutorService.instance.ensureLoaded();
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    setState(() => _error = null);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1568,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      // Default to JPEG. Flutter's image_picker on mobile produces JPEG by default.
      String media = 'image/jpeg';
      final lower = picked.path.toLowerCase();
      if (lower.endsWith('.png')) {
        media = 'image/png';
      } else if (lower.endsWith('.webp')) {
        media = 'image/webp';
      } else if (lower.endsWith('.gif')) {
        media = 'image/gif';
      }
      setState(() {
        _imageBytes = bytes;
        _mediaType = media;
        _result = null;
      });
    } catch (e) {
      setState(() => _error = 'Could not load image: $e');
    }
  }

  Future<void> _analyse() async {
    final bytes = _imageBytes;
    if (bytes == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    final out = await AiTutorService.instance.analyseImage(
      imageBytes: bytes,
      mediaType: _mediaType ?? 'image/jpeg',
      prompt: _promptCtrl.text,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = out;
      _error = AiTutorService.instance.lastError;
    });
    if (out != null) {
      // Speak just the headlines for brevity — full text is on screen.
      final firstSection = _firstSentence(out);
      if (firstSection.isNotEmpty) {
        TtsService.instance.speak(firstSection);
      }
    }
  }

  String _firstSentence(String text) {
    final lines = text.split('\n');
    for (final l in lines) {
      final s = l.trim();
      if (s.isEmpty) continue;
      // Skip the headline itself (e.g. "WHAT I SEE")
      if (s == s.toUpperCase() && s.length < 25) continue;
      return s;
    }
    return text;
  }

  void _clear() {
    setState(() {
      _imageBytes = null;
      _mediaType = null;
      _result = null;
      _error = null;
      _promptCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo fault diagnosis'),
        actions: [
          IconButton(
            tooltip: 'Stop narration',
            icon: const Icon(Icons.stop_circle),
            onPressed: () => TtsService.instance.stop(),
          ),
          if (_imageBytes != null || _result != null)
            IconButton(
              tooltip: 'Reset',
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clear,
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: AiTutorService.instance,
        builder: (context, _) {
          final svc = AiTutorService.instance;
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              if (!svc.hasKey) _NoKeyCard(),
              if (svc.hasKey) _IntroCard(),
              const SizedBox(height: 12),
              _PickerRow(
                onCamera: () => _pick(ImageSource.camera),
                onGallery: () => _pick(ImageSource.gallery),
                enabled: svc.hasKey && !_busy,
              ),
              const SizedBox(height: 14),
              if (_imageBytes != null) ...[
                _ImagePreview(bytes: _imageBytes!),
                const SizedBox(height: 12),
                TextField(
                  controller: _promptCtrl,
                  enabled: !_busy,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Optional question',
                    hintText:
                        'e.g. "What does this fault code mean?" or "Is this a safe install?"',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _busy || !svc.hasKey ? null : _analyse,
                        icon: _busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_busy ? 'Analysing…' : 'Analyse photo'),
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.redAccent)),
                    ),
                  ]),
                ),
              ],
              if (_result != null) ...[
                const SizedBox(height: 14),
                _DiagnosisResult(text: _result!),
              ],
              const SizedBox(height: 24),
              _PrivacyNote(),
            ],
          );
        },
      ),
    );
  }
}

class _NoKeyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.gas.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.key, color: AppColors.gas),
              const SizedBox(width: 8),
              Text('Add an Anthropic API key to use photo diagnosis',
                  style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 6),
            const Text(
              'Photo diagnosis sends your image to api.anthropic.com for analysis. Set your key in Settings → AI tutor first.',
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(children: [
            Icon(Icons.camera_alt, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Photo fault diagnosis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ]),
          SizedBox(height: 6),
          Text(
            'Take or pick a photo of a boiler display, a fitting, a leak, a gauge, a flue terminal — anything you want diagnosed. The AI replies in UK plumbing language with What I See, Likely Cause, Next Steps and a Safety Note.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final bool enabled;
  const _PickerRow({
    required this.onCamera,
    required this.onGallery,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled ? onCamera : null,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take photo'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled ? onGallery : null,
            icon: const Icon(Icons.photo_library),
            label: const Text('From gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final Uint8List bytes;
  const _ImagePreview({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320),
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}

class _DiagnosisResult extends StatelessWidget {
  final String text;
  const _DiagnosisResult({required this.text});

  static const _sections = ['WHAT I SEE', 'LIKELY CAUSE', 'NEXT STEPS', 'SAFETY NOTE'];

  Map<String, String> _parse(String raw) {
    final out = <String, String>{};
    var current = '';
    final buffer = StringBuffer();
    for (final line in raw.split('\n')) {
      final t = line.trim();
      final hit = _sections.firstWhere(
        (s) => t.toUpperCase() == s,
        orElse: () => '',
      );
      if (hit.isNotEmpty) {
        if (current.isNotEmpty) {
          out[current] = buffer.toString().trim();
          buffer.clear();
        }
        current = hit;
      } else {
        buffer.writeln(line);
      }
    }
    if (current.isNotEmpty) {
      out[current] = buffer.toString().trim();
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parse(text);
    if (parsed.isEmpty) {
      // Fallback: show as a single block.
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Diagnosis',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              SelectableText(text,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => TtsService.instance.speak(text),
                icon: const Icon(Icons.volume_up),
                label: const Text('Speak'),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: _sections.where(parsed.containsKey).map((title) {
        final body = parsed[title] ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            color: title == 'SAFETY NOTE'
                ? AppColors.gas.withValues(alpha: 0.10)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(_iconFor(title), color: _colorFor(title)),
                    const SizedBox(width: 6),
                    Text(_titleCase(title),
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Speak this section',
                      icon: const Icon(Icons.volume_up, size: 20),
                      onPressed: () =>
                          TtsService.instance.speak('$title. $body'),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  SelectableText(body,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconFor(String s) {
    switch (s) {
      case 'WHAT I SEE':
        return Icons.visibility;
      case 'LIKELY CAUSE':
        return Icons.troubleshoot;
      case 'NEXT STEPS':
        return Icons.checklist;
      case 'SAFETY NOTE':
        return Icons.warning_amber;
      default:
        return Icons.info_outline;
    }
  }

  Color _colorFor(String s) {
    switch (s) {
      case 'SAFETY NOTE':
        return AppColors.gas;
      case 'LIKELY CAUSE':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  String _titleCase(String s) {
    return s
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty
            ? ''
            : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class _PrivacyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.privacy_tip,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text('Privacy',
                  style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 4),
            const Text(
              'Photos are sent directly to api.anthropic.com from this device for analysis only. The image is not stored on Anthropic servers beyond what their standard message API retains. Avoid uploading any image that contains personal data or sensitive customer information.',
            ),
          ],
        ),
      ),
    );
  }
}

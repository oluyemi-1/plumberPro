import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/signature_pad.dart';

/// Result returned from a successful signature capture: the rendered PNG
/// bytes, the typed signer name, and when it was signed.
class SignatureCapture {
  final Uint8List bytes;
  final String name;
  final DateTime signedAt;

  const SignatureCapture({
    required this.bytes,
    required this.name,
    required this.signedAt,
  });
}

/// Full-screen sheet for capturing a customer signature on the device.
/// Returns a [SignatureCapture] on done, or null if cancelled.
class SignatureCaptureScreen extends StatefulWidget {
  final String prefillName;
  const SignatureCaptureScreen({super.key, this.prefillName = ''});

  @override
  State<SignatureCaptureScreen> createState() =>
      _SignatureCaptureScreenState();
}

class _SignatureCaptureScreenState extends State<SignatureCaptureScreen> {
  final _pad = SignaturePadController();
  late final TextEditingController _name;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.prefillName);
  }

  @override
  void dispose() {
    _name.dispose();
    _pad.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    if (_pad.isEmpty) {
      _toast('Sign in the white area before saving.');
      return;
    }
    if (_name.text.trim().isEmpty) {
      _toast('Type the customer\'s name.');
      return;
    }
    setState(() => _busy = true);
    final bytes = await _pad.toPngBytes();
    if (!mounted) return;
    if (bytes == null) {
      setState(() => _busy = false);
      _toast('Could not capture signature — please try again.');
      return;
    }
    Navigator.pop(
      context,
      SignatureCapture(
        bytes: bytes,
        name: _name.text.trim(),
        signedAt: DateTime.now(),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer signature'),
        actions: [
          AnimatedBuilder(
            animation: _pad,
            builder: (_, __) => TextButton(
              onPressed: _pad.isEmpty ? null : _pad.clear,
              child: const Text('Clear'),
            ),
          ),
          TextButton(
            onPressed: _busy ? null : _save,
            child: const Text('Done'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Customer name (printed)',
                  hintText: 'e.g. Mr A. Smith',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'I confirm the work described overleaf was carried out to my satisfaction.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: Colors.black26, width: 1.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: SignaturePad(controller: _pad),
                        ),
                        Positioned(
                          left: 18,
                          bottom: 14,
                          right: 18,
                          child: AnimatedBuilder(
                            animation: _pad,
                            builder: (_, __) => _pad.isEmpty
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Divider(color: Colors.black26),
                                      Text('Sign here',
                                          style: TextStyle(
                                            color: Colors.black38,
                                            fontStyle: FontStyle.italic,
                                          )),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _busy ? null : _save,
                icon: const Icon(Icons.check),
                label: const Text('Save signature'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size.fromHeight(0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

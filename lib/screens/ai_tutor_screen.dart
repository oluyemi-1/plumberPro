import 'package:flutter/material.dart';

import '../services/ai_tutor_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import 'settings_screen.dart';

/// Chat-style screen powered by the Anthropic Messages API. Speaks the
/// assistant response via [TtsService] when narration is enabled.
class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final _input = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focus = FocusNode();

  static const _starterPrompts = <String>[
    'Why does my boiler keep losing pressure?',
    'How do I size a heat pump for a 4-bed house?',
    'Explain MCS 020 sound assessment in plain English.',
    'What does fault code F22 mean on a Vaillant ecoTEC?',
    'When do I need an unvented G3 ticket?',
    'How does a Y-plan differ from an S-plan?',
    'What is the bund rule for an oil tank?',
    'How do I do an IGEM/UP/1 tightness test on a 0.5 m³ system?',
  ];

  @override
  void initState() {
    super.initState();
    AiTutorService.instance.ensureLoaded();
  }

  @override
  void dispose() {
    _input.dispose();
    _scrollCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send([String? overrideText]) async {
    final text = (overrideText ?? _input.text).trim();
    if (text.isEmpty) return;
    _input.clear();
    _focus.unfocus();
    final ok = await AiTutorService.instance.sendMessage(text);
    if (!mounted) return;
    if (ok) {
      // Speak the latest assistant message.
      final last = AiTutorService.instance.messages.last;
      if (last.role == 'assistant') {
        TtsService.instance.speak(last.content);
      }
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI plumbing tutor'),
        actions: [
          AnimatedBuilder(
            animation: AiTutorService.instance,
            builder: (_, __) {
              final cacheHits = AiTutorService.instance.cacheHits;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Tooltip(
                    message:
                        '$cacheHits cached replies — caching cuts cost ~90%',
                    child: Chip(
                      label: Text('Cache: $cacheHits'),
                      labelStyle: const TextStyle(fontSize: 11),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Stop narration',
            icon: const Icon(Icons.stop_circle),
            onPressed: () => TtsService.instance.stop(),
          ),
          IconButton(
            tooltip: 'Clear chat',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => AiTutorService.instance.clearChat(),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: AiTutorService.instance,
          builder: (context, _) {
            final svc = AiTutorService.instance;
            return Column(
              children: [
                if (!svc.hasKey) _NoKeyBanner(),
                Expanded(
                  child: svc.messages.isEmpty
                      ? _StarterScreen(
                          prompts: _starterPrompts,
                          onTap: _send,
                        )
                      : ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(12),
                          itemCount: svc.messages.length + (svc.busy ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i == svc.messages.length && svc.busy) {
                              return const _TypingBubble();
                            }
                            return _MessageBubble(
                                message: svc.messages[i]);
                          },
                        ),
                ),
                if (svc.lastError != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        const Icon(Icons.warning_amber,
                            color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(svc.lastError!,
                              style: const TextStyle(
                                  color: Colors.redAccent)),
                        ),
                      ]),
                    ),
                  ),
                _InputBar(
                  controller: _input,
                  focusNode: _focus,
                  busy: svc.busy,
                  enabled: svc.hasKey,
                  onSend: () => _send(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NoKeyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      color: AppColors.gas.withValues(alpha: 0.12),
      child: Row(
        children: [
          const Icon(Icons.key, color: AppColors.gas),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add your Anthropic API key to start chatting.',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.text),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stored locally only. Never shared. ~£0.001 per quick exchange on Haiku.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings),
            label: const Text('Set key'),
          ),
        ],
      ),
    );
  }
}

class _StarterScreen extends StatelessWidget {
  final List<String> prompts;
  final void Function(String) onTap;
  const _StarterScreen({required this.prompts, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
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
                Icon(Icons.auto_awesome, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Ask anything about UK plumbing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ]),
              SizedBox(height: 6),
              Text(
                'I will answer in plain English using UK terminology, regulations and realistic figures. Tap a starter below or type your own question.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Try a starter',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        ...prompts.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Card(
                child: InkWell(
                  onTap: () => onTap(p),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      const Icon(Icons.bolt, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(p)),
                      const Icon(Icons.arrow_forward, size: 18),
                    ]),
                  ),
                ),
              ),
            )),
        const SizedBox(height: 16),
        Card(
          color: AppColors.cardBg,
          child: Padding(
            padding: const EdgeInsets.all(14),
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
                  'Your API key and chat are sent directly to api.anthropic.com from this device. No third-party server is used. The chat is not saved between launches — clear it any time with the bin icon.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AiMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final align =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isUser
        ? AppColors.primary
        : AppColors.surface;
    final fg = isUser ? Colors.white : AppColors.text;
    final border = isUser ? Colors.transparent : Colors.black12;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isUser ? 14 : 2),
                bottomRight: Radius.circular(isUser ? 2 : 14),
              ),
              border: Border.all(color: border),
            ),
            child: SelectableText(
              message.content,
              style: TextStyle(color: fg, height: 1.4),
            ),
          ),
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        TtsService.instance.speak(message.content),
                    icon: const Icon(Icons.volume_up, size: 16),
                    label: const Text('Speak'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('Thinking…'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool busy;
  final bool enabled;
  final VoidCallback onSend;
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.busy,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled && !busy,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: enabled
                    ? 'Ask the tutor anything UK-plumbing related…'
                    : 'Add an API key in Settings to start chatting',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            width: 48,
            child: ElevatedButton(
              onPressed: enabled && !busy ? onSend : null,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }
}

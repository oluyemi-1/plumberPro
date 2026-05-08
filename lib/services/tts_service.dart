import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton TTS service used across the app for narrated simulations,
/// lessons and troubleshooting walkthroughs.
class TtsService extends ChangeNotifier {
  TtsService._internal();
  static final TtsService instance = TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialised = false;
  bool _isSpeaking = false;
  bool _enabled = true;
  double _rate = 0.48;
  double _pitch = 1.0;
  final double _volume = 1.0;
  String _language = 'en-GB';
  String? _voiceName;
  String? _voiceLocale;
  String? _currentUtterance;
  Completer<void>? _speakCompleter;
  List<TtsVoice> _voices = const [];

  bool get isSpeaking => _isSpeaking;
  bool get enabled => _enabled;
  double get rate => _rate;
  double get pitch => _pitch;
  double get volume => _volume;
  String get language => _language;
  String? get voiceName => _voiceName;
  String? get voiceLocale => _voiceLocale;
  String? get currentUtterance => _currentUtterance;
  List<TtsVoice> get voices => _voices;

  static const _kPrefRate = 'tts_rate';
  static const _kPrefPitch = 'tts_pitch';
  static const _kPrefEnabled = 'tts_enabled';
  static const _kPrefLanguage = 'tts_language';
  static const _kPrefVoiceName = 'tts_voice_name';
  static const _kPrefVoiceLocale = 'tts_voice_locale';

  /// Idempotent initialisation — safe to call multiple times. Loads saved
  /// preferences, sets the language/voice, and registers handlers.
  Future<void> ensureInitialised() async {
    if (_initialised) return;
    _initialised = true;
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_kPrefEnabled) ?? true;
    _rate = prefs.getDouble(_kPrefRate) ?? 0.48;
    _pitch = prefs.getDouble(_kPrefPitch) ?? 1.0;
    _language = prefs.getString(_kPrefLanguage) ?? 'en-GB';
    _voiceName = prefs.getString(_kPrefVoiceName);
    _voiceLocale = prefs.getString(_kPrefVoiceLocale);

    try {
      await _tts.setLanguage(_language);
      await _tts.setSpeechRate(_rate);
      await _tts.setPitch(_pitch);
      await _tts.setVolume(_volume);
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {}

    _tts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });
    _tts.setCompletionHandler(_onSpeakDone);
    _tts.setCancelHandler(_onSpeakDone);
    _tts.setErrorHandler((_) => _onSpeakDone());

    await _refreshVoices();

    if (_voiceName != null && _voiceLocale != null) {
      try {
        await _tts.setVoice({'name': _voiceName!, 'locale': _voiceLocale!});
      } catch (_) {}
    }
    notifyListeners();
  }

  void _onSpeakDone() {
    _isSpeaking = false;
    _currentUtterance = null;
    if (_speakCompleter != null && !(_speakCompleter!.isCompleted)) {
      _speakCompleter!.complete();
    }
    _speakCompleter = null;
    notifyListeners();
  }

  Future<void> _refreshVoices() async {
    try {
      final raw = await _tts.getVoices;
      if (raw is List) {
        _voices = raw
            .whereType<Map>()
            .map((m) => TtsVoice(
                  name: (m['name'] ?? '').toString(),
                  locale: (m['locale'] ?? '').toString(),
                ))
            .where((v) => v.name.isNotEmpty && v.locale.isNotEmpty)
            .toList();
      }
    } catch (_) {
      _voices = const [];
    }
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    if (!value) {
      await stop();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefEnabled, value);
    notifyListeners();
  }

  Future<void> setRate(double value) async {
    _rate = value.clamp(0.1, 1.0);
    try {
      await _tts.setSpeechRate(_rate);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kPrefRate, _rate);
    notifyListeners();
  }

  Future<void> setPitch(double value) async {
    _pitch = value.clamp(0.5, 2.0);
    try {
      await _tts.setPitch(_pitch);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kPrefPitch, _pitch);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _language = code;
    try {
      await _tts.setLanguage(code);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefLanguage, code);
    notifyListeners();
  }

  Future<void> setVoice(TtsVoice voice) async {
    _voiceName = voice.name;
    _voiceLocale = voice.locale;
    try {
      await _tts.setVoice({'name': voice.name, 'locale': voice.locale});
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefVoiceName, voice.name);
    await prefs.setString(_kPrefVoiceLocale, voice.locale);
    notifyListeners();
  }

  Future<void> clearVoice() async {
    _voiceName = null;
    _voiceLocale = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefVoiceName);
    await prefs.remove(_kPrefVoiceLocale);
    notifyListeners();
  }

  Future<void> refreshVoices() async {
    await _refreshVoices();
    notifyListeners();
  }

  Future<void> speak(String text, {bool queue = false}) async {
    if (!_initialised) await ensureInitialised();
    if (!_enabled || text.trim().isEmpty) return;
    if (!queue) {
      await stop();
    }
    _currentUtterance = text;
    notifyListeners();
    try {
      _speakCompleter = Completer<void>();
      await _tts.speak(text);
      await _speakCompleter?.future;
    } catch (_) {
      _onSpeakDone();
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _onSpeakDone();
  }
}

class TtsVoice {
  final String name;
  final String locale;
  const TtsVoice({required this.name, required this.locale});

  bool get isUk => locale.toLowerCase().startsWith('en-gb') ||
      locale.toLowerCase() == 'en_gb';
  bool get isEnglish => locale.toLowerCase().startsWith('en');

  @override
  bool operator ==(Object other) =>
      other is TtsVoice && other.name == name && other.locale == locale;

  @override
  int get hashCode => Object.hash(name, locale);
}

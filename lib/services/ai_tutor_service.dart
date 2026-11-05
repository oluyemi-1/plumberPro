import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'pro_entitlement.dart';
import 'purchase_proof.dart';

/// Singleton client for the Anthropic Messages API. Drives the AI tutor chat
/// and photo diagnosis and exposes message state for the UI.
///
/// Three routes, in priority order:
///   • The user's own key, stored locally and sent direct to api.anthropic.com.
///   • The PipeSmart proxy (production builds): included with Pro, metered per
///     subscription by the server, no key on the device.
///   • A build-time demo key for closed test tracks.
class AiMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime when;
  const AiMessage({
    required this.role,
    required this.content,
    required this.when,
  });
}

/// Server-issued proof that this device's Pro subscription may use the
/// included AI allowance, plus the latest counters the server reported.
class AiEntitlement {
  final String token;
  final DateTime expiresAt;
  final int? limit;
  final int? used;
  final DateTime? resetsAt;

  const AiEntitlement({
    required this.token,
    required this.expiresAt,
    this.limit,
    this.used,
    this.resetsAt,
  });

  int? get remaining {
    if (limit == null || used == null) return null;
    final left = limit! - used!;
    return left < 0 ? 0 : left;
  }

  AiEntitlement withUsage({int? limit, int? used, DateTime? resetsAt}) =>
      AiEntitlement(
        token: token,
        expiresAt: expiresAt,
        limit: limit ?? this.limit,
        used: used ?? this.used,
        resetsAt: resetsAt ?? this.resetsAt,
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'expires_at': expiresAt.toIso8601String(),
        'limit': limit,
        'used': used,
        'resets_at': resetsAt?.toIso8601String(),
      };

  static AiEntitlement fromJson(Map<String, dynamic> m) => AiEntitlement(
        token: m['token'] as String,
        expiresAt: DateTime.parse(m['expires_at'] as String),
        limit: m['limit'] as int?,
        used: m['used'] as int?,
        resetsAt: m['resets_at'] == null
            ? null
            : DateTime.tryParse(m['resets_at'] as String),
      );
}

class AiTutorService extends ChangeNotifier {
  AiTutorService._();
  static final AiTutorService instance = AiTutorService._();

  static const _kKey = 'anthropic_api_key';
  static const _kModel = 'anthropic_model';
  static const _kCachedHits = 'anthropic_cache_hits';
  static const _kEntitlement = 'ai_entitlement_v1';
  static const _proRequiredMessage =
      'The AI tutor is included with PipeSmart Pro. Subscribe to start asking questions.';
  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _apiVersion = '2023-06-01';

  /// Compile-time fallback key set via:
  ///   flutter build apk --dart-define=ANTHROPIC_API_KEY=sk-ant-…
  ///
  /// Empty by default. Use only for closed test tracks (Internal / Closed
  /// testing on Google Play). Anyone who installs the test build can extract
  /// this key, so always:
  ///   • Use a dedicated demo key — never your main key
  ///   • Set a workspace spend cap in console.anthropic.com
  ///   • Rotate the key after each test cycle
  static const _bakedInKey = String.fromEnvironment('ANTHROPIC_API_KEY');

  /// Optional proxy server URL set via:
  ///   --dart-define=PROXY_URL=https://your-worker.workers.dev
  /// When set, the app routes every AI call through this server instead of
  /// hitting api.anthropic.com directly. The Anthropic key lives only on
  /// that server, so it cannot be extracted from a public build. Used for
  /// production / public-launch builds. See server/ for the proxy code.
  static const _proxyUrl = String.fromEnvironment('PROXY_URL');

  /// The shared app key that proves a request came from a real PipeSmart
  /// build. Must match the APP_SHARED_KEY secret on the proxy server.
  ///   --dart-define=PROXY_APP_KEY=`<value>`
  static const _proxyAppKey = String.fromEnvironment('PROXY_APP_KEY');

  /// Default model — fast and inexpensive, good enough for in-app tutoring.
  static const _defaultModel = 'claude-haiku-5-5';

  /// The model the included Pro allowance uses. The proxy only forwards this
  /// one; the picker in Settings applies to the user's own key.
  static const proxyModel = 'claude-haiku-5-5';

  /// How many recent messages are sent with each request. Older turns stay
  /// visible in the chat but are not resent, which bounds the cost per turn.
  static const historyWindow = 20;

  // Alternatives the user can pick in Settings when using their own key.
  static const availableModels = <AiModelOption>[
    AiModelOption(
      id: 'claude-haiku-5-5',
      label: 'Haiku 5.5 — fast & cheap',
      description: 'Best for everyday plumbing Q&A. Lowest cost.',
    ),
    AiModelOption(
      id: 'claude-sonnet-5-5',
      label: 'Sonnet 5.5 — balanced',
      description: 'Better reasoning for complex design / regs questions.',
    ),
    AiModelOption(
      id: 'claude-opus-5-5',
      label: 'Opus 5.5 — best reasoning',
      description: 'Highest cost. Save for the toughest synoptic questions.',
    ),
  ];

  String? _apiKey;
  String _model = _defaultModel;
  bool _loaded = false;
  bool _busy = false;
  String? _lastError;
  int _cacheHits = 0;
  final List<AiMessage> _messages = [];
  AiEntitlement? _entitlement;

  String? get apiKey => _apiKey;

  /// True when the user has saved their own key (overrides any baked-in one).
  bool get hasUserKey => (_apiKey ?? '').isNotEmpty;

  /// True when the build was compiled with `--dart-define=ANTHROPIC_API_KEY=…`.
  bool get hasBakedInKey => _bakedInKey.isNotEmpty;

  /// True when the build was compiled with `--dart-define=PROXY_URL=…` and
  /// `--dart-define=PROXY_APP_KEY=…` — production builds route through the
  /// server-side proxy so the Anthropic key never ships in the APK.
  bool get hasProxy => _proxyUrl.isNotEmpty && _proxyAppKey.isNotEmpty;

  /// The key actually used for API calls — user-saved if present, else
  /// the build-time baked key, else null. (Proxy mode does not use this.)
  String? get effectiveApiKey {
    if (hasUserKey) return _apiKey;
    if (hasBakedInKey) return _bakedInKey;
    return null;
  }

  /// True when the app can talk to Anthropic — either through the proxy or
  /// with a key (user / baked-in).
  bool get hasKey => hasProxy || effectiveApiKey != null;

  /// True when the only available route is the proxy and this device has no
  /// active Pro: the UI should offer the paywall instead of a key field.
  bool get needsPro => usingProxy && !ProEntitlement.instance.isPro;

  /// Questions left this month on the included allowance, once the server
  /// has reported it. Null when not on the proxy or not yet known.
  int? get questionsRemaining => usingProxy ? _entitlement?.remaining : null;
  int? get questionsLimit => usingProxy ? _entitlement?.limit : null;
  DateTime? get allowanceResetsAt =>
      usingProxy ? _entitlement?.resetsAt : null;

  /// Selects how the next request will be routed.
  ///   • If the user supplied their own key, use it (direct to Anthropic).
  ///   • Else if a proxy is configured, route via the proxy.
  ///   • Else if a baked-in demo key is set, use it (direct).
  ///   • Else: no AI.
  ///
  /// User key takes priority because power users often want to bring their
  /// own quota / billing.
  bool get usingProxy => !hasUserKey && hasProxy;

  /// True when the call will use the baked-in key because no other route
  /// is available.
  bool get usingBakedInKey =>
      !hasUserKey && !hasProxy && hasBakedInKey;

  /// A proxy route: `/messages` mirrors the upstream API, `/entitlement`
  /// exchanges the stored purchase proof for a metered entitlement token.
  Uri _proxyUri(String path) {
    final base = _proxyUrl.endsWith('/')
        ? _proxyUrl.substring(0, _proxyUrl.length - 1)
        : _proxyUrl;
    return Uri.parse('$base$path');
  }

  Map<String, String> _proxyHeaders(String entitlement) => {
        'x-app-key': _proxyAppKey,
        'x-entitlement': entitlement,
        'anthropic-version': _apiVersion,
        'content-type': 'application/json',
      };

  Map<String, String> _directHeaders() => {
        'x-api-key': effectiveApiKey!,
        'anthropic-version': _apiVersion,
        'content-type': 'application/json',
      };

  /// Model for the next request: the proxy only serves [proxyModel].
  String get requestModel => usingProxy ? proxyModel : _model;

  String get model => _model;
  bool get busy => _busy;
  String? get lastError => _lastError;
  int get cacheHits => _cacheHits;
  List<AiMessage> get messages => List.unmodifiable(_messages);

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_kKey);
    final storedModel = prefs.getString(_kModel);
    // Retired model ids (e.g. Haiku 4.5) fall back to the default.
    _model = availableModels.any((m) => m.id == storedModel)
        ? storedModel!
        : _defaultModel;
    _cacheHits = prefs.getInt(_kCachedHits) ?? 0;
    final rawEnt = prefs.getString(_kEntitlement);
    if (rawEnt != null) {
      try {
        _entitlement =
            AiEntitlement.fromJson(jsonDecode(rawEnt) as Map<String, dynamic>);
      } catch (_) {
        _entitlement = null;
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    final trimmed = key.trim();
    _apiKey = trimmed.isEmpty ? null : trimmed;
    final prefs = await SharedPreferences.getInstance();
    if (_apiKey == null) {
      await prefs.remove(_kKey);
    } else {
      await prefs.setString(_kKey, _apiKey!);
    }
    notifyListeners();
  }

  Future<void> setModel(String id) async {
    _model = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kModel, id);
    notifyListeners();
  }

  /// Re-read all settings from disk after a restore.
  Future<void> reload() async {
    _apiKey = null;
    _model = _defaultModel;
    _cacheHits = 0;
    _entitlement = null;
    _loaded = false;
    _messages.clear();
    await ensureLoaded();
  }

  Future<void> clearChat() async {
    _messages.clear();
    _lastError = null;
    notifyListeners();
  }

  /// Sends a user message and appends the assistant response.
  /// Returns true on success, false otherwise. The error (if any) is stored
  /// in [lastError].
  Future<bool> sendMessage(String text) async {
    if (!hasKey) {
      _lastError = 'No API key set. Add one in Settings → AI tutor.';
      notifyListeners();
      return false;
    }
    if (needsPro) {
      _lastError = _proRequiredMessage;
      notifyListeners();
      return false;
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    _messages.add(AiMessage(
      role: 'user',
      content: trimmed,
      when: DateTime.now(),
    ));
    _busy = true;
    _lastError = null;
    notifyListeners();

    try {
      final body = {
        'model': requestModel,
        'max_tokens': 1024,
        // System sent as an array so we can attach a cache_control block.
        // The system prompt is large and constant — caching it cuts cost.
        'system': [
          {
            'type': 'text',
            'text': _systemPrompt,
            'cache_control': {'type': 'ephemeral'},
          },
        ],
        'messages': requestWindow(_messages)
            .map((m) => {
                  'role': m.role,
                  'content': m.content,
                })
            .toList(),
      };
      final res = await _post(body);
      if (res == null || res.statusCode != 200) {
        _busy = false;
        if (res != null) _lastError = _friendlyError(res.statusCode, res.body);
        // Roll back the user message so the chat reflects the failure.
        if (_messages.isNotEmpty && _messages.last.role == 'user') {
          _messages.removeLast();
        }
        notifyListeners();
        return false;
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final usage = json['usage'] as Map<String, dynamic>?;
      final cacheRead = usage?['cache_read_input_tokens'] as int?;
      if (cacheRead != null && cacheRead > 0) {
        _cacheHits += 1;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_kCachedHits, _cacheHits);
      }
      final content = (json['content'] as List?) ?? const [];
      final buffer = StringBuffer();
      for (final block in content) {
        if (block is Map && block['type'] == 'text') {
          buffer.write(block['text'] ?? '');
        }
      }
      final answer = buffer.toString().trim();
      _messages.add(AiMessage(
        role: 'assistant',
        content: answer.isEmpty ? _emptyAnswer(json) : answer,
        when: DateTime.now(),
      ));
      _busy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _busy = false;
      _lastError = 'Network error: $e';
      if (_messages.isNotEmpty && _messages.last.role == 'user') {
        _messages.removeLast();
      }
      notifyListeners();
      return false;
    }
  }

  /// One-shot multimodal call: send an image plus an optional prompt and
  /// return the assistant text. Does not append to chat history — kept
  /// separate from the tutor chat.
  Future<String?> analyseImage({
    required Uint8List imageBytes,
    String mediaType = 'image/jpeg',
    String? prompt,
  }) async {
    if (!hasKey) {
      _lastError = 'No API key set. Add one in Settings → AI tutor.';
      notifyListeners();
      return null;
    }
    if (needsPro) {
      _lastError = _proRequiredMessage;
      notifyListeners();
      return null;
    }
    if (imageBytes.isEmpty) {
      _lastError = 'No image to analyse.';
      notifyListeners();
      return null;
    }
    _busy = true;
    _lastError = null;
    notifyListeners();
    try {
      final base64Image = base64Encode(imageBytes);
      final body = {
        'model': requestModel,
        'max_tokens': 1024,
        'system': [
          {
            'type': 'text',
            'text': _diagnosisSystemPrompt,
            'cache_control': {'type': 'ephemeral'},
          },
        ],
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': mediaType,
                  'data': base64Image,
                },
              },
              {
                'type': 'text',
                'text': (prompt == null || prompt.trim().isEmpty)
                    ? 'Identify what is shown and provide UK plumbing diagnosis using the required structure.'
                    : prompt.trim(),
              },
            ],
          },
        ],
      };
      final res = await _post(body);
      if (res == null || res.statusCode != 200) {
        _busy = false;
        if (res != null) _lastError = _friendlyError(res.statusCode, res.body);
        notifyListeners();
        return null;
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final usage = json['usage'] as Map<String, dynamic>?;
      final cacheRead = usage?['cache_read_input_tokens'] as int?;
      if (cacheRead != null && cacheRead > 0) {
        _cacheHits += 1;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_kCachedHits, _cacheHits);
      }
      final content = (json['content'] as List?) ?? const [];
      final buffer = StringBuffer();
      for (final block in content) {
        if (block is Map && block['type'] == 'text') {
          buffer.write(block['text'] ?? '');
        }
      }
      _busy = false;
      notifyListeners();
      final answer = buffer.toString().trim();
      return answer.isEmpty ? _emptyAnswer(json) : answer;
    } catch (e) {
      _busy = false;
      _lastError = 'Network error: $e';
      notifyListeners();
      return null;
    }
  }

  /// The recent slice of [all] to send upstream: at most [max] messages,
  /// trimmed so the slice starts with a user turn as the API requires.
  static List<AiMessage> requestWindow(List<AiMessage> all,
      {int max = historyWindow}) {
    var window = all.length > max ? all.sublist(all.length - max) : all;
    while (window.isNotEmpty && window.first.role != 'user') {
      window = window.sublist(1);
    }
    return window;
  }

  /// Fallback text when the model returned no text block.
  static String _emptyAnswer(Map<String, dynamic> json) =>
      json['stop_reason'] == 'refusal'
          ? 'The assistant declined to answer that. Try rephrasing your question.'
          : 'No response — please try again.';

  /// Sends one Messages API request over the active route. In proxy mode
  /// this attaches the entitlement token, refreshes it once if the server
  /// rejects it, and records the allowance counters the server returns.
  /// Returns null when no request could be made; [lastError] explains why.
  Future<http.Response?> _post(Map<String, dynamic> body) async {
    final encoded = jsonEncode(body);
    if (!usingProxy) {
      return http.post(Uri.parse(_endpoint),
          headers: _directHeaders(), body: encoded);
    }
    var ent = await _ensureEntitlement();
    if (ent == null) return null;
    var res = await http.post(_proxyUri('/messages'),
        headers: _proxyHeaders(ent.token), body: encoded);
    if (res.statusCode == 401 &&
        _proxyError(res.body).startsWith('entitlement')) {
      ent = await _ensureEntitlement(force: true);
      if (ent == null) return null;
      res = await http.post(_proxyUri('/messages'),
          headers: _proxyHeaders(ent.token), body: encoded);
    }
    if (res.statusCode == 200) await _recordAllowance(res.headers);
    return res;
  }

  /// Returns a usable entitlement, fetching a fresh one from the proxy when
  /// none is cached, the cached one is close to expiry, or [force] is set.
  /// Sets [lastError] and returns null when the device is not entitled.
  Future<AiEntitlement?> _ensureEntitlement({bool force = false}) async {
    final now = DateTime.now();
    final cached = _entitlement;
    if (!force &&
        cached != null &&
        cached.expiresAt.isAfter(now.add(const Duration(hours: 1)))) {
      return cached;
    }
    if (!ProEntitlement.instance.isPro) {
      _lastError = _proRequiredMessage;
      return null;
    }
    final proof = await PurchaseProof.load();
    if (proof == null) {
      _lastError =
          'Your subscription could not be found on this device. Use Restore purchases in Settings, then try again.';
      return null;
    }
    try {
      final res = await http.post(
        _proxyUri('/entitlement'),
        headers: {
          'x-app-key': _proxyAppKey,
          'content-type': 'application/json',
        },
        body: jsonEncode({'platform': proof.platform, 'token': proof.token}),
      );
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        final ent = AiEntitlement(
          token: j['entitlement'] as String,
          expiresAt: DateTime.parse(j['expires_at'] as String),
          limit: j['limit'] as int?,
          used: j['used'] as int?,
          resetsAt: DateTime.tryParse(j['resets_at'] as String? ?? ''),
        );
        await _saveEntitlement(ent);
        return ent;
      }
      if (res.statusCode == 403) {
        await _saveEntitlement(null);
        _lastError =
            'No active PipeSmart Pro subscription was found. If you have just subscribed, wait a minute and try again, or use Restore purchases.';
        return null;
      }
      _lastError = _friendlyError(res.statusCode, res.body);
    } catch (e) {
      _lastError = 'Network error: $e';
    }
    // The server could not answer. A cached token that is still valid is
    // better than failing outright — unless it was just rejected.
    if (!force && cached != null && cached.expiresAt.isAfter(now)) {
      _lastError = null;
      return cached;
    }
    return null;
  }

  Future<void> _saveEntitlement(AiEntitlement? ent) async {
    _entitlement = ent;
    final prefs = await SharedPreferences.getInstance();
    if (ent == null) {
      await prefs.remove(_kEntitlement);
    } else {
      await prefs.setString(_kEntitlement, jsonEncode(ent.toJson()));
    }
  }

  /// Keeps the allowance counters in step with the x-allowance-* headers the
  /// proxy adds to every successful completion.
  Future<void> _recordAllowance(Map<String, String> headers) async {
    final ent = _entitlement;
    final limit = int.tryParse(headers['x-allowance-limit'] ?? '');
    final used = int.tryParse(headers['x-allowance-used'] ?? '');
    if (ent == null || limit == null || used == null) return;
    await _saveEntitlement(ent.withUsage(
      limit: limit,
      used: used,
      resetsAt: DateTime.tryParse(headers['x-allowance-resets'] ?? ''),
    ));
  }

  /// The `error` code in a proxy JSON error body, or '' if there is none.
  static String _proxyError(String body) {
    try {
      final j = jsonDecode(body);
      return j is Map ? (j['error'] as String? ?? '') : '';
    } catch (_) {
      return '';
    }
  }

  String _exhaustedMessage(String body) {
    int? limit;
    DateTime? resets;
    try {
      final j = jsonDecode(body) as Map<String, dynamic>;
      limit = j['limit'] as int?;
      resets = DateTime.tryParse(j['resets_at'] as String? ?? '');
    } catch (_) {}
    final ent = _entitlement;
    if (ent != null) {
      _entitlement = ent.withUsage(limit: limit, used: limit, resetsAt: resets);
    }
    final n = limit ?? ent?.limit;
    final local = resets?.toLocal();
    final when = local == null
        ? 'at the start of next month'
        : 'on ${local.day}/${local.month}/${local.year}';
    return n == null
        ? 'You have used all of your AI questions for this month. Your allowance resets $when.'
        : 'You have used all $n AI questions for this month. Your allowance resets $when.';
  }

  String _friendlyError(int code, String body) {
    if (usingProxy) {
      switch (_proxyError(body)) {
        case 'allowance_exhausted':
          return _exhaustedMessage(body);
        case 'invalid_app_key':
          return 'This version of PipeSmart is no longer authorised for the AI tutor. Please update the app.';
        case 'disabled':
        case 'store_unavailable':
        case 'store_not_configured':
          return 'The AI tutor is temporarily unavailable. Please try again later.';
        case 'rate_limited':
          return 'Too many requests. Wait a moment and try again.';
      }
    }
    if (code == 401) return 'API key rejected. Check the key in Settings.';
    if (code == 403) return 'API key does not have permission for this model.';
    if (code == 404) return 'Model not found. Try selecting a different one.';
    if (code == 429) {
      return 'Rate limited. You have hit the request rate or daily token cap.';
    }
    if (code == 529) return 'Anthropic service overloaded. Try again shortly.';
    if (code >= 500) return 'Anthropic service error ($code). Try again shortly.';
    String snippet = body;
    if (snippet.length > 200) snippet = '${snippet.substring(0, 200)}…';
    return 'API error $code. $snippet';
  }

  /// The default system prompt. Marked for prompt caching because it is large
  /// and identical on every request — caching is around 90% cheaper after the
  /// first hit and reduces latency.
  static const _systemPrompt = '''
You are an expert UK plumbing tutor inside the PipeSmart training app. You answer questions from trainees and qualified plumbers about domestic plumbing, heating, gas, heat pumps, commercial plumbing, commercial gas, LPG and oil, medical gases, and fire sprinklers.

Use UK terminology and units throughout: stopcock, lockshield, cistern, MDPE, immersion, tundish, IGEM/UP, BS EN 12056, BS 6700, BS 8558, BS 9251, HTM 02-01, RIDDOR, Building Regs Parts G, L, J, P, BUS grant, MCS, MIS 3005, OFTEC, UKLPG, F-gas Cat I, ACoP L8, HSG 274. Use litres, bar, kPa, mm, °C, K, W and kWh.

Style:
- Clear plain English. Short paragraphs.
- Use a bullet list for procedures.
- Quote realistic figures (e.g. 1 to 1.5 bar cold for a sealed system, 60 °C cylinder, MCS 020 limit 42 dB(A), 110% bund rule, 750 mm minimum service pipe depth).
- Cite the standard or regulation that applies when relevant.
- End with a one-line safety note when the work is notifiable or dangerous.

Constraints:
- Never give specific gas burner pressures, bypasses or workarounds that suggest the user can carry out gas work without Gas Safe registration.
- Never recommend bypassing a safety device.
- If asked about a non-plumbing topic, politely steer back to plumbing.

You are talking to a working plumber. Match an experienced time-served plumber's tone — friendly, competent, brisk.
''';

  /// System prompt for one-shot photo diagnosis. Cached by the API for
  /// cost-efficiency.
  static const _diagnosisSystemPrompt = '''
You are a UK plumbing fault-diagnosis expert. The user has supplied a photograph that may show a boiler display, a fault code, a fitting, a leak, a gauge, a pipework arrangement, an appliance data plate, a flue terminal, an oil tank, an LPG cylinder, a soil stack, a sprinkler head or a tool.

Your reply MUST follow this exact structure, using these section headings on their own lines:

WHAT I SEE
A short paragraph describing what is visible. Read any visible text, codes, gauge needles, model numbers and serial plates carefully and quote them verbatim.

LIKELY CAUSE
Interpret what is shown in UK plumbing terms. If a fault code, look it up against the visible manufacturer if you can identify it. If a leak, name the most likely failure mode. If a gauge reading, say whether it is in normal range with realistic UK figures.

NEXT STEPS
A numbered list of 3 to 6 specific actions a competent plumber should take, in order, written in the imperative.

SAFETY NOTE
One short paragraph noting if the work is Gas Safe notifiable, electrical Part P, F-gas, water-regs G3 unvented, OFTEC oil, sprinkler BS 9251, or otherwise restricted to a competent person. Mention any immediate hazard (CO, water damage, scald, electrical, gas leak, refrigerant) that may apply.

Use UK terminology and units throughout: stopcock, lockshield, cistern, MDPE, immersion, tundish, IGEM/UP/1, BS 6644, BS 6173, BS 9251, HTM 02-01, ACoP L8, Building Regs Parts G/L/J/P, BUS grant, MCS, MIS 3005, OFTEC, UKLPG, F-gas Cat I. Use litres, bar, kPa, mm, °C and kW.

Constraints:
- If the image is unclear, glare-affected, blurry, or shows something unrelated to plumbing/heating/gas/sprinklers/medical-gas, say so plainly under WHAT I SEE and ask the user for a clearer photo. Do not invent fault codes you cannot read.
- Never give specific gas burner pressures, bypasses or workarounds that suggest the user can carry out gas work without Gas Safe registration.
- Never recommend bypassing a safety device.
- Never claim to identify a person's face or other personal data in the image — if a person is visible, ignore them and focus on the plumbing/heating equipment.

Tone: brisk, competent, friendly — the way an experienced time-served UK plumber would talk to an apprentice on site.
''';
}

class AiModelOption {
  final String id;
  final String label;
  final String description;
  const AiModelOption({
    required this.id,
    required this.label,
    required this.description,
  });
}

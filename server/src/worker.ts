/**
 * Plumber Pro AI proxy — Cloudflare Worker.
 *
 * The Anthropic API key lives only here, on the server side. The mobile app
 * sends Messages API requests to this worker with a shared app-key header,
 * the worker validates and rate-limits per IP, then forwards upstream.
 *
 * Required Cloudflare config:
 *
 *   1. Bind a KV namespace named RATE_LIMIT_KV (used for per-IP rate
 *      counters).
 *   2. Set two secrets via `wrangler secret put`:
 *        ANTHROPIC_API_KEY  — your sk-ant-… Claude API key
 *        APP_SHARED_KEY     — a long random string the app must send in
 *                             the x-app-key header. Bake the same value
 *                             into the app build via
 *                             --dart-define=PROXY_APP_KEY=…
 *
 * After `wrangler deploy`, point the app at the worker URL via
 *   --dart-define=PROXY_URL=https://<your-subdomain>.workers.dev
 */

export interface Env {
  ANTHROPIC_API_KEY: string;
  APP_SHARED_KEY: string;
  RATE_LIMIT_KV: KVNamespace;
  /** Optional override; default 30 req/min/IP. */
  RATE_LIMIT_PER_MIN?: string;
  /** Optional comma-separated list of allowed model ids. */
  ALLOWED_MODELS?: string;
}

const ANTHROPIC_URL = 'https://api.anthropic.com/v1/messages';
const ANTHROPIC_VERSION = '2023-06-01';

// Default model allow-list. The app currently exposes Haiku 4.5, Sonnet 4.6
// and Opus 4.7. Override via the ALLOWED_MODELS env var if you want to lock
// the proxy to one specific model and reduce abuse vectors.
const DEFAULT_ALLOWED = [
  'claude-haiku-4-5-20251001',
  'claude-haiku-4-5',
  'claude-sonnet-4-6',
  'claude-opus-4-7',
];

export default {
  async fetch(
    request: Request,
    env: Env,
    ctx: ExecutionContext,
  ): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === '/health') {
      return new Response('ok', { status: 200 });
    }
    if (url.pathname !== '/messages') {
      return json({ error: 'not_found' }, 404);
    }
    if (request.method !== 'POST') {
      return json({ error: 'method_not_allowed' }, 405);
    }

    // App-key gate. Not security-by-itself, but combined with rate limiting
    // it stops casual scraping. Rotate APP_SHARED_KEY whenever you ship a
    // new build of the app.
    const appKey = request.headers.get('x-app-key');
    if (!env.APP_SHARED_KEY || appKey !== env.APP_SHARED_KEY) {
      return json({ error: 'invalid_app_key' }, 401);
    }

    // Per-IP rate limit using a 1-minute KV bucket.
    const ip = request.headers.get('cf-connecting-ip') ?? 'unknown';
    const limit = parseInt(env.RATE_LIMIT_PER_MIN ?? '30', 10);
    const minute = Math.floor(Date.now() / 60000);
    const rlKey = `rl:${ip}:${minute}`;
    const current = parseInt((await env.RATE_LIMIT_KV.get(rlKey)) ?? '0', 10);
    if (current >= limit) {
      return json(
        {
          error: 'rate_limited',
          message: `Too many requests — limit is ${limit} per minute per IP. Try again shortly.`,
        },
        429,
      );
    }
    ctx.waitUntil(
      env.RATE_LIMIT_KV.put(rlKey, String(current + 1), {
        expirationTtl: 70,
      }),
    );

    // Read + minimally validate the body before spending Anthropic tokens.
    let bodyText: string;
    try {
      bodyText = await request.text();
    } catch (_) {
      return json({ error: 'invalid_body' }, 400);
    }
    let body: any;
    try {
      body = JSON.parse(bodyText);
    } catch (_) {
      return json({ error: 'invalid_json' }, 400);
    }
    if (
      typeof body !== 'object' ||
      body === null ||
      typeof body.model !== 'string' ||
      !Array.isArray(body.messages)
    ) {
      return json({ error: 'invalid_request' }, 400);
    }
    const allowed = (env.ALLOWED_MODELS ?? DEFAULT_ALLOWED.join(','))
      .split(',')
      .map((s) => s.trim())
      .filter((s) => s.length > 0);
    if (allowed.length > 0 && !allowed.includes(body.model)) {
      return json(
        {
          error: 'model_not_allowed',
          message: `Model "${body.model}" is not enabled on this proxy.`,
          allowed,
        },
        400,
      );
    }
    if (typeof body.max_tokens !== 'number' || body.max_tokens > 4096) {
      // Cap max_tokens server-side to limit cost-per-request.
      body.max_tokens = Math.min(
        typeof body.max_tokens === 'number' ? body.max_tokens : 1024,
        4096,
      );
    }

    // Forward.
    const upstream = await fetch(ANTHROPIC_URL, {
      method: 'POST',
      headers: {
        'x-api-key': env.ANTHROPIC_API_KEY,
        'anthropic-version': ANTHROPIC_VERSION,
        'content-type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    // Pipe the response body back. Anthropic returns JSON for non-streaming
    // requests; we don't currently use streaming from the app.
    const respHeaders = new Headers();
    respHeaders.set(
      'content-type',
      upstream.headers.get('content-type') ?? 'application/json',
    );
    return new Response(upstream.body, {
      status: upstream.status,
      headers: respHeaders,
    });
  },
};

function json(payload: unknown, status: number): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}

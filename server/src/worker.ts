/**
 * PipeSmart AI proxy — Cloudflare Worker.
 *
 * The Anthropic API key lives only here. The app proves it is a real
 * PipeSmart build with a shared app key, proves it has an active Pro
 * subscription with an entitlement token (issued by /entitlement after a
 * store check), and the Worker meters a monthly question allowance per
 * subscription before forwarding to Anthropic.
 *
 *   POST /entitlement  { platform: "android"|"ios"|"code", token }
 *                      -> { entitlement, expires_at, plan, limit, used, remaining, resets_at }
 *   POST /messages     Anthropic Messages API body, plus x-entitlement header
 *                      -> upstream response, plus x-allowance-* headers
 *   GET  /health       -> "ok"
 *
 * Setup, secrets and deployment: see README.md.
 */
import { verifyApple, verifyCode, verifyPlay, Verified } from './stores.ts';
import {
  Entitlement,
  monthKey,
  nextMonthStart,
  signEntitlement,
  verifyEntitlement,
} from './token.ts';

export interface Env {
  // Secrets (wrangler secret put …)
  ANTHROPIC_API_KEY: string;
  APP_SHARED_KEY: string;
  /** Random string used to sign entitlement tokens. Rotating it logs every device out of the allowance until it re-verifies. */
  ENTITLEMENT_SECRET: string;
  /** Full JSON key file of the Play service account with "View financial data" on the app. */
  PLAY_SERVICE_ACCOUNT_JSON?: string;
  /** Contents of the App Store In-App Purchase .p8 key, plus its ids. */
  APPLE_IAP_KEY_P8?: string;
  APPLE_KEY_ID?: string;
  APPLE_ISSUER_ID?: string;
  /** Same HMAC secret as RedemptionService in the app. Optional; omit to refuse licence codes. */
  REDEMPTION_SECRET?: string;

  // Bindings and vars (wrangler.toml)
  RATE_LIMIT_KV: KVNamespace;
  ANDROID_PACKAGE_NAME: string;
  IOS_BUNDLE_ID: string;
  /** Questions per subscription per UTC month. Default 300. */
  MONTHLY_QUESTIONS?: string;
  /** Default 30 req/min/IP. */
  RATE_LIMIT_PER_MIN?: string;
  /** Comma-separated model ids. Default: Haiku only. */
  ALLOWED_MODELS?: string;
  /** Set to "1" to refuse every call (kill switch). */
  DISABLED?: string;
}

const ANTHROPIC_URL = 'https://api.anthropic.com/v1/messages';
const ANTHROPIC_VERSION = '2023-06-01';
const DEFAULT_ALLOWED = ['claude-haiku-5-5'];
const DEFAULT_MONTHLY_QUESTIONS = 300;
const MAX_TOKENS_CAP = 4096;
/** Photo diagnosis sends a base64 image; anything larger than this is not a legitimate request. */
const MAX_BODY_BYTES = 2_000_000;
/** Entitlements are re-checked against the store at least this often. */
const ENTITLEMENT_TTL_SEC = 7 * 24 * 3600;
/** Usage counters outlive their month by a few days for debugging, then expire. */
const QUOTA_TTL_SEC = 40 * 24 * 3600;

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === '/health') {
      return new Response('ok', { status: 200 });
    }
    if (env.DISABLED === '1') {
      return json({ error: 'disabled', message: 'The AI tutor is temporarily unavailable.' }, 503);
    }
    if (request.method !== 'POST') {
      return json({ error: 'method_not_allowed' }, 405);
    }

    // App-key gate. Not security by itself, but combined with rate limiting
    // and the entitlement check it stops casual scraping. Rotate
    // APP_SHARED_KEY whenever you ship a new build of the app.
    const appKey = request.headers.get('x-app-key');
    if (!env.APP_SHARED_KEY || appKey !== env.APP_SHARED_KEY) {
      return json({ error: 'invalid_app_key' }, 401);
    }

    const limited = await rateLimit(request, env, ctx);
    if (limited) return limited;

    if (url.pathname === '/entitlement') return handleEntitlement(request, env);
    if (url.pathname === '/messages') return handleMessages(request, env, ctx);
    return json({ error: 'not_found' }, 404);
  },
};

/** Per-IP rate limit using a 1-minute KV bucket. Returns a 429 response when exceeded. */
async function rateLimit(request: Request, env: Env, ctx: ExecutionContext): Promise<Response | null> {
  const ip = request.headers.get('cf-connecting-ip') ?? 'unknown';
  const limit = parseInt(env.RATE_LIMIT_PER_MIN ?? '30', 10);
  const minute = Math.floor(Date.now() / 60000);
  const key = `rl:${ip}:${minute}`;
  const current = parseInt((await env.RATE_LIMIT_KV.get(key)) ?? '0', 10);
  if (current >= limit) {
    return json(
      {
        error: 'rate_limited',
        message: `Too many requests — limit is ${limit} per minute per IP. Try again shortly.`,
      },
      429,
    );
  }
  ctx.waitUntil(env.RATE_LIMIT_KV.put(key, String(current + 1), { expirationTtl: 70 }));
  return null;
}

// ---------------------------------------------------------------------------
// /entitlement
// ---------------------------------------------------------------------------

async function handleEntitlement(request: Request, env: Env): Promise<Response> {
  let body: any;
  try {
    body = await request.json();
  } catch (_) {
    return json({ error: 'invalid_json' }, 400);
  }
  const platform = body?.platform;
  const proof = body?.token;
  if (typeof proof !== 'string' || proof.length === 0 || proof.length > 4096) {
    return json({ error: 'invalid_request' }, 400);
  }

  let verified: Verified | null;
  try {
    if (platform === 'android') {
      if (!env.PLAY_SERVICE_ACCOUNT_JSON) return json({ error: 'store_not_configured' }, 503);
      verified = await verifyPlay({
        serviceAccountJson: env.PLAY_SERVICE_ACCOUNT_JSON,
        packageName: env.ANDROID_PACKAGE_NAME,
        purchaseToken: proof,
        kv: env.RATE_LIMIT_KV,
      });
    } else if (platform === 'ios') {
      if (!env.APPLE_IAP_KEY_P8 || !env.APPLE_KEY_ID || !env.APPLE_ISSUER_ID) {
        return json({ error: 'store_not_configured' }, 503);
      }
      verified = await verifyApple({
        p8: env.APPLE_IAP_KEY_P8,
        keyId: env.APPLE_KEY_ID,
        issuerId: env.APPLE_ISSUER_ID,
        bundleId: env.IOS_BUNDLE_ID,
        transactionId: proof,
      });
    } else if (platform === 'code') {
      if (!env.REDEMPTION_SECRET) return json({ error: 'store_not_configured' }, 503);
      verified = await verifyCode({ secret: env.REDEMPTION_SECRET, code: proof });
    } else {
      return json({ error: 'invalid_request' }, 400);
    }
  } catch (e) {
    // Credential or transport problem on our side — never report this to the
    // user as "not subscribed".
    console.error('store verification failed', platform, String(e));
    return json({ error: 'store_unavailable' }, 503);
  }

  if (!verified) {
    return json(
      {
        error: 'not_entitled',
        message: 'No active PipeSmart Pro subscription was found for this purchase.',
      },
      403,
    );
  }

  const now = Math.floor(Date.now() / 1000);
  const exp = Math.min(now + ENTITLEMENT_TTL_SEC, Math.floor(verified.expiresAt / 1000));
  const ent: Entitlement = { sub: verified.sub, plan: verified.plan, exp, iat: now };
  const token = await signEntitlement(env.ENTITLEMENT_SECRET, ent);
  const allowance = await readAllowance(env, verified.sub);
  return json({
    entitlement: token,
    expires_at: new Date(exp * 1000).toISOString(),
    plan: verified.plan,
    ...allowance,
  });
}

// ---------------------------------------------------------------------------
// /messages
// ---------------------------------------------------------------------------

async function handleMessages(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
  const entHeader = request.headers.get('x-entitlement');
  if (!entHeader) return json({ error: 'entitlement_required' }, 401);
  const ent = await verifyEntitlement(env.ENTITLEMENT_SECRET, entHeader);
  if (!ent) return json({ error: 'entitlement_invalid' }, 401);

  const limit = monthlyLimit(env);
  const key = quotaKey(ent.sub);
  const used = parseInt((await env.RATE_LIMIT_KV.get(key)) ?? '0', 10);
  if (used >= limit) {
    return json(
      {
        error: 'allowance_exhausted',
        message: `You have used all ${limit} AI questions for this month.`,
        limit,
        used,
        resets_at: nextMonthStart(),
      },
      402,
    );
  }

  // Read + minimally validate the body before spending Anthropic tokens.
  let bodyText: string;
  try {
    bodyText = await request.text();
  } catch (_) {
    return json({ error: 'invalid_body' }, 400);
  }
  if (bodyText.length > MAX_BODY_BYTES) {
    return json({ error: 'payload_too_large' }, 413);
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
  if (typeof body.max_tokens !== 'number' || body.max_tokens > MAX_TOKENS_CAP) {
    // Cap max_tokens server-side to limit cost-per-request.
    body.max_tokens = Math.min(
      typeof body.max_tokens === 'number' ? body.max_tokens : 1024,
      MAX_TOKENS_CAP,
    );
  }
  // Streaming would let a client hold a connection open past the counter check.
  delete body.stream;

  const upstream = await fetch(ANTHROPIC_URL, {
    method: 'POST',
    headers: {
      'x-api-key': env.ANTHROPIC_API_KEY,
      'anthropic-version': ANTHROPIC_VERSION,
      'content-type': 'application/json',
    },
    body: JSON.stringify(body),
  });

  const headers = new Headers({
    'content-type': upstream.headers.get('content-type') ?? 'application/json',
  });
  if (upstream.ok) {
    // One successful completion = one question. KV is eventually consistent,
    // so a burst can slightly overshoot the limit; that is acceptable for a
    // soft allowance.
    const nowUsed = used + 1;
    ctx.waitUntil(env.RATE_LIMIT_KV.put(key, String(nowUsed), { expirationTtl: QUOTA_TTL_SEC }));
    headers.set('x-allowance-limit', String(limit));
    headers.set('x-allowance-used', String(nowUsed));
    headers.set('x-allowance-remaining', String(Math.max(0, limit - nowUsed)));
    headers.set('x-allowance-resets', nextMonthStart());
  }
  return new Response(upstream.body, { status: upstream.status, headers });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function monthlyLimit(env: Env): number {
  const n = parseInt(env.MONTHLY_QUESTIONS ?? '', 10);
  return Number.isFinite(n) && n > 0 ? n : DEFAULT_MONTHLY_QUESTIONS;
}

function quotaKey(sub: string): string {
  return `q:${sub}:${monthKey()}`;
}

async function readAllowance(env: Env, sub: string) {
  const limit = monthlyLimit(env);
  const used = parseInt((await env.RATE_LIMIT_KV.get(quotaKey(sub))) ?? '0', 10);
  return { limit, used, remaining: Math.max(0, limit - used), resets_at: nextMonthStart() };
}

function json(payload: unknown, status: number = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}

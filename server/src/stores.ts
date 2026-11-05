/**
 * Store-side subscription verification.
 *
 * Each verifier takes the proof the app holds (Play purchase token, App Store
 * transaction id, or a redeemed licence code) and returns a Verified record
 * when it belongs to an active PipeSmart Pro subscription, or null when it
 * does not. Transport or credential failures throw so the caller can answer
 * "try again later" instead of "not subscribed".
 */
import { b64url, b64urlDecode, b64urlJson, hmacSha256, sha256Hex } from './token.ts';

export interface Verified {
  /** Stable id for metering: the same subscription keeps the same id across renewals. */
  sub: string;
  /** Store product id, or the code tier for licence codes. */
  plan: string;
  /** Unix ms. Number.MAX_SAFE_INTEGER when the server cannot know the expiry. */
  expiresAt: number;
}

const enc = new TextEncoder();
const dec = new TextDecoder();

function pemToDer(pem: string): ArrayBuffer {
  const b64 = pem.replace(/-----[A-Z ]+-----/g, '').replace(/\s+/g, '');
  const bin = atob(b64);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out.buffer;
}

async function signJwt(
  header: Record<string, unknown>,
  claims: Record<string, unknown>,
  key: CryptoKey,
  algorithm: Parameters<SubtleCrypto['sign']>[0],
): Promise<string> {
  const input = `${b64urlJson(header)}.${b64urlJson(claims)}`;
  const sig = await crypto.subtle.sign(algorithm, key, enc.encode(input));
  return `${input}.${b64url(sig)}`;
}

function jwsPayload<T>(jws: string): T {
  return JSON.parse(dec.decode(b64urlDecode(jws.split('.')[1] ?? ''))) as T;
}

// ---------------------------------------------------------------------------
// Google Play
// ---------------------------------------------------------------------------

interface ServiceAccount {
  client_email: string;
  private_key: string;
}

const PLAY_TOKEN_CACHE_KEY = 'play:access_token';

/** OAuth2 access token for the Android Publisher API, cached in KV until shortly before expiry. */
async function playAccessToken(serviceAccountJson: string, kv: KVNamespace): Promise<string> {
  const cached = await kv.get(PLAY_TOKEN_CACHE_KEY);
  if (cached) return cached;
  const sa = JSON.parse(serviceAccountJson) as ServiceAccount;
  const key = await crypto.subtle.importKey(
    'pkcs8',
    pemToDer(sa.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const now = Math.floor(Date.now() / 1000);
  const assertion = await signJwt(
    { alg: 'RS256', typ: 'JWT' },
    {
      iss: sa.client_email,
      scope: 'https://www.googleapis.com/auth/androidpublisher',
      aud: 'https://oauth2.googleapis.com/token',
      iat: now,
      exp: now + 3600,
    },
    key,
    'RSASSA-PKCS1-v1_5',
  );
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  if (!res.ok) throw new Error(`google oauth ${res.status}`);
  const data = (await res.json()) as { access_token: string; expires_in: number };
  await kv.put(PLAY_TOKEN_CACHE_KEY, data.access_token, {
    expirationTtl: Math.max(60, (data.expires_in ?? 3600) - 300),
  });
  return data.access_token;
}

// CANCELED means auto-renew is off but access continues until expiryTime.
const PLAY_ACTIVE_STATES = new Set([
  'SUBSCRIPTION_STATE_ACTIVE',
  'SUBSCRIPTION_STATE_IN_GRACE_PERIOD',
  'SUBSCRIPTION_STATE_CANCELED',
]);

export async function verifyPlay(opts: {
  serviceAccountJson: string;
  packageName: string;
  purchaseToken: string;
  kv: KVNamespace;
}): Promise<Verified | null> {
  const accessToken = await playAccessToken(opts.serviceAccountJson, opts.kv);
  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/` +
    `${encodeURIComponent(opts.packageName)}/purchases/subscriptionsv2/tokens/` +
    `${encodeURIComponent(opts.purchaseToken)}`;
  const res = await fetch(url, { headers: { authorization: `Bearer ${accessToken}` } });
  // Unknown or malformed token: not a subscription of ours.
  if (res.status === 404 || res.status === 400) return null;
  if (!res.ok) throw new Error(`play ${res.status}`);
  const data = (await res.json()) as {
    subscriptionState?: string;
    lineItems?: { productId: string; expiryTime: string }[];
  };
  if (!PLAY_ACTIVE_STATES.has(data.subscriptionState ?? '')) return null;
  const now = Date.now();
  let best: { productId: string; expiry: number } | null = null;
  for (const item of data.lineItems ?? []) {
    const expiry = Date.parse(item.expiryTime);
    if (expiry > now && (!best || expiry > best.expiry)) {
      best = { productId: item.productId, expiry };
    }
  }
  if (!best) return null;
  return {
    sub: `and:${(await sha256Hex(opts.purchaseToken)).slice(0, 32)}`,
    plan: best.productId,
    expiresAt: best.expiry,
  };
}

// ---------------------------------------------------------------------------
// Apple App Store
// ---------------------------------------------------------------------------

const APPLE_HOSTS = [
  'https://api.storekit.itunes.apple.com',
  // Sandbox / TestFlight purchases only exist in the sandbox environment.
  'https://api.storekit-sandbox.itunes.apple.com',
];

// 1 = active, 4 = billing grace period. 2 expired, 3 billing retry, 5 revoked.
const APPLE_ACTIVE_STATUSES = new Set([1, 4]);

async function appleJwt(opts: {
  p8: string;
  keyId: string;
  issuerId: string;
  bundleId: string;
}): Promise<string> {
  const key = await crypto.subtle.importKey(
    'pkcs8',
    pemToDer(opts.p8),
    { name: 'ECDSA', namedCurve: 'P-256' },
    false,
    ['sign'],
  );
  const now = Math.floor(Date.now() / 1000);
  return signJwt(
    { alg: 'ES256', kid: opts.keyId, typ: 'JWT' },
    { iss: opts.issuerId, iat: now, exp: now + 1800, aud: 'appstoreconnect-v1', bid: opts.bundleId },
    key,
    { name: 'ECDSA', hash: 'SHA-256' },
  );
}

export async function verifyApple(opts: {
  p8: string;
  keyId: string;
  issuerId: string;
  bundleId: string;
  transactionId: string;
}): Promise<Verified | null> {
  if (!/^\d{1,40}$/.test(opts.transactionId)) return null;
  const jwt = await appleJwt(opts);
  for (const host of APPLE_HOSTS) {
    const res = await fetch(`${host}/inApps/v1/subscriptions/${opts.transactionId}`, {
      headers: { authorization: `Bearer ${jwt}` },
    });
    if (res.status === 404) continue; // Not in this environment; try the next.
    if (!res.ok) throw new Error(`apple ${res.status}`);
    const data = (await res.json()) as {
      bundleId?: string;
      data?: {
        lastTransactions?: { status: number; signedTransactionInfo: string }[];
      }[];
    };
    if (data.bundleId !== opts.bundleId) return null;
    const now = Date.now();
    let best: Verified | null = null;
    for (const group of data.data ?? []) {
      for (const tx of group.lastTransactions ?? []) {
        if (!APPLE_ACTIVE_STATUSES.has(tx.status)) continue;
        const info = jwsPayload<{
          productId: string;
          expiresDate?: number;
          originalTransactionId: string;
        }>(tx.signedTransactionInfo);
        const expiry = info.expiresDate ?? 0;
        if (expiry > now && (!best || expiry > best.expiresAt)) {
          best = {
            sub: `ios:${info.originalTransactionId}`,
            plan: info.productId,
            expiresAt: expiry,
          };
        }
      }
    }
    return best;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Redemption codes (institutional / direct-sale licences)
// ---------------------------------------------------------------------------

/**
 * Mirrors RedemptionService in the app: PSMART-XXXX-XXXX-XXXX-XXXX (lifetime,
 * 8 hex nonce + 8 hex HMAC) or PSMART-TT-XXXX-XXXX-XXXX-XXXX (tiered, 2 hex
 * months + 8 nonce + 8 HMAC over tier||nonce). The redemption clock starts on
 * the device, so the server cannot know a tiered code's expiry; it issues
 * short-lived entitlements for as long as the app still reports Pro.
 */
export async function verifyCode(opts: { secret: string; code: string }): Promise<Verified | null> {
  const body = opts.code
    .trim()
    .toUpperCase()
    .replace(/ /g, '')
    .replace(/PSMART-/g, '')
    .replace(/-/g, '');
  if (!/^[0-9A-F]{16}$|^[0-9A-F]{18}$/.test(body)) return null;
  const tiered = body.length === 18;
  const payload = tiered ? body.slice(0, 10) : body.slice(0, 8);
  const sig = tiered ? body.slice(10) : body.slice(8);
  const mac = await hmacSha256(opts.secret, payload);
  const expected = [...new Uint8Array(mac)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
    .toUpperCase()
    .slice(0, 8);
  if (expected !== sig) return null;
  const months = tiered ? parseInt(body.slice(0, 2), 16) : 0;
  return {
    sub: `code:${(await sha256Hex(body)).slice(0, 32)}`,
    plan: tiered ? `code-${months}m` : 'code-lifetime',
    expiresAt: Number.MAX_SAFE_INTEGER,
  };
}

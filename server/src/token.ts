/**
 * Entitlement tokens and allowance helpers. No dependencies — WebCrypto only.
 *
 * An entitlement is a small HMAC-signed payload the Worker hands to the app
 * after verifying a store subscription. The app presents it on every
 * /messages call so the Worker can meter usage per subscription without
 * user accounts and without re-checking the store each time.
 */

const enc = new TextEncoder();
const dec = new TextDecoder();

export function b64url(bytes: ArrayBuffer | Uint8Array): string {
  const u8 = bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes);
  let s = '';
  for (const b of u8) s += String.fromCharCode(b);
  return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

export function b64urlDecode(s: string): Uint8Array {
  const pad = s.length % 4 === 0 ? '' : '='.repeat(4 - (s.length % 4));
  const bin = atob(s.replace(/-/g, '+').replace(/_/g, '/') + pad);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

export function b64urlJson(value: unknown): string {
  return b64url(enc.encode(JSON.stringify(value)));
}

export async function sha256Hex(text: string): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', enc.encode(text));
  return [...new Uint8Array(digest)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

export async function hmacSha256(secret: string, data: string): Promise<ArrayBuffer> {
  const key = await crypto.subtle.importKey(
    'raw',
    enc.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  return crypto.subtle.sign('HMAC', key, enc.encode(data));
}

export interface Entitlement {
  /** Stable per-subscription id, e.g. "and:<hash>", "ios:<originalTransactionId>", "code:<hash>". */
  sub: string;
  /** Store product id or code tier — informational only. */
  plan: string;
  /** Expiry, unix seconds. */
  exp: number;
  /** Issued at, unix seconds. */
  iat: number;
}

export async function signEntitlement(secret: string, ent: Entitlement): Promise<string> {
  const payload = b64urlJson(ent);
  const sig = await hmacSha256(secret, payload);
  return `${payload}.${b64url(sig)}`;
}

/** Returns the payload when the signature is valid and the token is unexpired, else null. */
export async function verifyEntitlement(
  secret: string,
  token: string,
  nowSec: number = Math.floor(Date.now() / 1000),
): Promise<Entitlement | null> {
  const dot = token.indexOf('.');
  if (dot <= 0 || token.length > 2048) return null;
  const payload = token.slice(0, dot);
  const sig = token.slice(dot + 1);
  let expected: string;
  try {
    expected = b64url(await hmacSha256(secret, payload));
  } catch {
    return null;
  }
  if (!timingSafeEqual(expected, sig)) return null;
  let ent: Entitlement;
  try {
    ent = JSON.parse(dec.decode(b64urlDecode(payload)));
  } catch {
    return null;
  }
  if (typeof ent.sub !== 'string' || typeof ent.exp !== 'number') return null;
  if (ent.exp <= nowSec) return null;
  return ent;
}

function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/** "2026-11" — the UTC month containing `date`. Allowances reset on this boundary. */
export function monthKey(date: Date = new Date()): string {
  return `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, '0')}`;
}

/** ISO timestamp of the first instant of the next UTC month. */
export function nextMonthStart(date: Date = new Date()): string {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth() + 1, 1)).toISOString();
}

import assert from 'node:assert/strict';
import { test } from 'node:test';

import { verifyCode } from '../src/stores.ts';
import {
  monthKey,
  nextMonthStart,
  signEntitlement,
  verifyEntitlement,
} from '../src/token.ts';

const SECRET = 'test-secret';

test('entitlement round-trips and rejects tampering', async () => {
  const now = 1_800_000_000;
  const ent = { sub: 'and:abc', plan: 'pipesmart_pro_1m', exp: now + 60, iat: now };
  const token = await signEntitlement(SECRET, ent);
  assert.deepEqual(await verifyEntitlement(SECRET, token, now), ent);
  assert.equal(await verifyEntitlement('other-secret', token, now), null);
  assert.equal(await verifyEntitlement(SECRET, token.slice(0, -2) + 'AA', now), null);
  const [payload] = token.split('.');
  assert.equal(await verifyEntitlement(SECRET, `${payload}x.${token.split('.')[1]}`, now), null);
});

test('entitlement expires', async () => {
  const now = 1_800_000_000;
  const token = await signEntitlement(SECRET, { sub: 's', plan: 'p', exp: now + 10, iat: now });
  assert.notEqual(await verifyEntitlement(SECRET, token, now + 9), null);
  assert.equal(await verifyEntitlement(SECRET, token, now + 10), null);
});

test('garbage tokens are rejected without throwing', async () => {
  assert.equal(await verifyEntitlement(SECRET, '', 0), null);
  assert.equal(await verifyEntitlement(SECRET, 'nodot', 0), null);
  assert.equal(await verifyEntitlement(SECRET, '.sig', 0), null);
  assert.equal(await verifyEntitlement(SECRET, '!!!.???', 0), null);
});

test('month helpers use UTC boundaries', () => {
  const d = new Date(Date.UTC(2026, 10, 30, 23, 59, 59));
  assert.equal(monthKey(d), '2026-11');
  assert.equal(nextMonthStart(d), '2026-12-01T00:00:00.000Z');
  const dec = new Date(Date.UTC(2026, 11, 15));
  assert.equal(nextMonthStart(dec), '2027-01-01T00:00:00.000Z');
});

test('redemption codes verify against the app HMAC scheme', async () => {
  // Build a tiered code the same way tools/generate_codes.dart does.
  const secret = 'code-secret';
  const tier = '0C';
  const nonce = 'DEADBEEF';
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey('raw', enc.encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const mac = new Uint8Array(await crypto.subtle.sign('HMAC', key, enc.encode(tier + nonce)));
  const sig = [...mac].map((b) => b.toString(16).padStart(2, '0')).join('').toUpperCase().slice(0, 8);
  const body = `${tier}${nonce}${sig}`;
  const pretty = `PSMART-${body.slice(0, 2)}-${body.slice(2, 6)}-${body.slice(6, 10)}-${body.slice(10, 14)}-${body.slice(14, 18)}`;

  const ok = await verifyCode({ secret, code: pretty.toLowerCase() });
  assert.ok(ok);
  assert.equal(ok.plan, 'code-12m');
  assert.match(ok.sub, /^code:[0-9a-f]{32}$/);

  assert.equal(await verifyCode({ secret: 'wrong', code: pretty }), null);
  assert.equal(await verifyCode({ secret, code: 'PSMART-0000-0000-0000-0000' }), null);
  assert.equal(await verifyCode({ secret, code: 'not a code' }), null);
});

# PipeSmart AI proxy

A small Cloudflare Worker that sits between the PipeSmart app and the
Anthropic Messages API. The Anthropic API key lives **only** here, and the
Worker meters a monthly question allowance per Pro subscription so the AI
tutor can be included in the subscription without user accounts.

```
[ PipeSmart app ]
   │  POST /entitlement  { platform, token }        x-app-key
   │  POST /messages     (Messages API body)        x-app-key, x-entitlement
   ▼
[ Cloudflare Worker (this) ]
   │  - app-key gate + per-IP rate limit (KV)
   │  - /entitlement: verifies the purchase with Google Play / App Store /
   │    the licence-code HMAC, returns a signed entitlement token
   │  - /messages: checks the token, checks the monthly counter (KV),
   │    caps max_tokens, allow-lists models, forwards, counts one question
   ▼
[ api.anthropic.com ]
```

## Endpoints

| Route | Purpose |
|---|---|
| `GET /health` | Returns `ok`. |
| `POST /entitlement` | Body `{ "platform": "android" \| "ios" \| "code", "token": "<purchase token / transaction id / licence code>" }`. Returns `{ entitlement, expires_at, plan, limit, used, remaining, resets_at }`, or `403 not_entitled`, or `503 store_unavailable` when the store could not be reached. |
| `POST /messages` | Anthropic Messages API body plus `x-entitlement` header. Forwards upstream and adds `x-allowance-limit`, `x-allowance-used`, `x-allowance-remaining`, `x-allowance-resets` headers. Returns `401 entitlement_invalid` (app should refresh) or `402 allowance_exhausted`. |

Entitlement tokens last at most 7 days, so a cancelled subscription loses the
allowance within a week. Counters reset on the first of each UTC month.

## Prerequisites

- A free Cloudflare account
- Node.js 20+ (`npm test` uses Node's built-in TypeScript support, 22.6+)
- An Anthropic API key
- Google Play: a service account JSON key with "View financial data" on the
  app (Play Console → Users and permissions)
- App Store: an In-App Purchase key (.p8) with its Key ID and Issuer ID
  (App Store Connect → Users and Access → Integrations → In-App Purchase)

## One-time setup

```bash
cd server
npm install
npx wrangler login
```

### Create the KV namespace

```bash
npx wrangler kv namespace create RATE_LIMIT_KV
```

Copy the printed `id` into `wrangler.toml`, replacing
`REPLACE_WITH_KV_NAMESPACE_ID`. The namespace holds rate-limit buckets,
monthly question counters and the cached Google OAuth token.

### Set the secrets

```bash
npx wrangler secret put ANTHROPIC_API_KEY          # paste sk-ant-…
npx wrangler secret put APP_SHARED_KEY             # long random string, baked into the app build
npx wrangler secret put ENTITLEMENT_SECRET         # long random string, signs entitlement tokens
npx wrangler secret put PLAY_SERVICE_ACCOUNT_JSON < /path/to/service-account.json
npx wrangler secret put APPLE_IAP_KEY_P8 < /path/to/SubscriptionKey_XXXXXXXXXX.p8
npx wrangler secret put APPLE_KEY_ID               # e.g. XXXXXXXXXX
npx wrangler secret put APPLE_ISSUER_ID            # UUID from the In-App Purchase keys page
npx wrangler secret put REDEMPTION_SECRET          # same value as RedemptionService._secret in the app (optional)
```

Random strings:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64url'))"
```

### Deploy

```bash
npm run typecheck && npm test
npx wrangler deploy
curl https://plumber-pro-proxy.<subdomain>.workers.dev/health   # -> ok
```

## Pointing the app at the proxy

```bash
flutter build appbundle --release \
  --dart-define=PROXY_URL=https://plumber-pro-proxy.<subdomain>.workers.dev \
  --dart-define=PROXY_APP_KEY=<the APP_SHARED_KEY value>
```

In this mode the app asks the Worker for an entitlement using the purchase
proof it stored when Pro was granted (Play purchase token, App Store
transaction id, or licence code), then sends every tutor and photo-diagnosis
request with that token. Users who paste their own Anthropic key bypass the
proxy entirely and are not metered.

## Tuning (`wrangler.toml` `[vars]`)

- `MONTHLY_QUESTIONS` — questions per subscription per month. Default 300.
- `ALLOWED_MODELS` — comma-separated. Default `claude-haiku-5-5`; the app
  always requests this model when on the proxy.
- `RATE_LIMIT_PER_MIN` — per-IP request limit. Default 30.
- `DISABLED` — set to `"1"` to refuse every call (kill switch). Deploy to apply.
- Anthropic spend cap: Console → Settings → Limits. Last line of defence.

## Rotating credentials

- `APP_SHARED_KEY` leaked: `wrangler secret put APP_SHARED_KEY`, ship a new
  app build. Old builds get `401 invalid_app_key` until updated.
- `ENTITLEMENT_SECRET` rotated: every device re-verifies with the store on
  its next request. No app build needed.
- Store credentials: re-run the matching `secret put`.

## Local development

```bash
npx wrangler dev
npm test        # token signing, month maths, licence-code HMAC
```

Put local values in `server/.dev.vars` (gitignored), e.g.
`ANTHROPIC_API_KEY`, `APP_SHARED_KEY`, `ENTITLEMENT_SECRET`, and point a
debug build at `http://10.0.2.2:8787` (Android emulator alias for the host).

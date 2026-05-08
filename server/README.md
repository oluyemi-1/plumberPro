# Plumber Pro AI proxy

A small Cloudflare Worker that proxies Anthropic Messages API calls for the
Plumber Pro mobile app. The Anthropic API key lives **only** here on the
server — never in the public app build.

## Why a proxy is required for public launch

A `--dart-define`-baked key is fine for **closed** Google Play tracks, but
once the app is on the production track anyone can install the APK and
extract the key. A proxy keeps the key on the server and gates each call:

```
[ Plumber Pro app ]
        │  POST /messages
        │  x-app-key: <shared secret>
        ▼
[ Cloudflare Worker (this) ]
        │  - validates app-key
        │  - rate-limits per IP (KV)
        │  - caps max_tokens
        │  - allow-lists models
        ▼
[ api.anthropic.com ]
```

## What this Worker does

- Single endpoint `POST /messages` that mirrors the Anthropic Messages API
- App-key gate (`x-app-key` header) so the URL alone is not enough
- Per-IP rate limit (default 30 req/min) using a Cloudflare KV namespace
- Server-side `max_tokens` cap of 4096 (cheaper, harder to weaponise)
- Server-side model allow-list — the proxy only forwards to your approved
  Claude model ids
- Returns the upstream Anthropic response unchanged (status, body)

## Prerequisites

- A free Cloudflare account (https://dash.cloudflare.com)
- Node.js 18+ on your laptop
- An Anthropic API key on the account that will pay for usage

## One-time setup

```bash
cd server
npm install
npx wrangler login
```

`wrangler login` opens a browser tab to authorise. Sign in to Cloudflare,
authorise, return to the terminal.

### Create the rate-limit KV namespace

```bash
npx wrangler kv:namespace create RATE_LIMIT_KV
```

Wrangler prints something like:

```
[[kv_namespaces]]
binding = "RATE_LIMIT_KV"
id = "abc123def456…"
```

Copy that `id` value into `wrangler.toml` (replacing
`REPLACE_WITH_KV_NAMESPACE_ID`).

### Set the secrets

```bash
npx wrangler secret put ANTHROPIC_API_KEY
# (paste your sk-ant-… key when prompted)

npx wrangler secret put APP_SHARED_KEY
# (paste a long random string; keep it safe — you will bake the same
#  value into the Plumber Pro app build below)
```

A good `APP_SHARED_KEY` is a 32-character random string, e.g. the output of:
```bash
node -e "console.log(require('crypto').randomBytes(24).toString('base64url'))"
```

### Deploy

```bash
npx wrangler deploy
```

Wrangler prints the live URL, something like:
```
https://plumber-pro-proxy.<your-subdomain>.workers.dev
```

Quick sanity check:
```bash
curl https://plumber-pro-proxy.<subdomain>.workers.dev/health
# -> ok
```

## Pointing the Plumber Pro app at the proxy

Build the production APK / iOS archive with two `--dart-define` flags:

```bash
flutter build appbundle --release \
  --dart-define=PROXY_URL=https://plumber-pro-proxy.<your-subdomain>.workers.dev \
  --dart-define=PROXY_APP_KEY=<the same APP_SHARED_KEY value>
```

The app will route every AI call through the proxy. Users do not need to
provide their own Anthropic API key; if they do, the app prefers the user's
own key (sent direct to Anthropic) over the proxy.

## Cost & quotas

- Cloudflare Workers free tier: 100,000 requests / day
- KV reads: free under 100,000 / day
- Anthropic charges per token — see https://www.anthropic.com/pricing

The Worker itself essentially costs nothing for app-launch volumes. The
Anthropic bill is the only meaningful cost.

## Tuning

- **Rate limit**: `RATE_LIMIT_PER_MIN` env var. Lower it to harden against
  abuse; raise it if your real users complain. Set via `wrangler.toml`
  `[vars]` block or `wrangler secret put`.
- **Allowed models**: `ALLOWED_MODELS` env var, comma-separated. Default is
  Haiku 4.5 / Sonnet 4.6 / Opus 4.7.
- **Spend cap**: set a workspace-level monthly cap in
  https://console.anthropic.com/ → Settings → Limits. Recommended even with
  the proxy in place — last line of defence.

## Rotating credentials

If the `APP_SHARED_KEY` ever leaks (or you suspect it has):

```bash
npx wrangler secret put APP_SHARED_KEY
# (new value)
```

…then ship a new app build with the new value baked in. Old builds will
get a 401 on every call until the user updates.

## Local development

```bash
npx wrangler dev
```

Worker runs on `http://localhost:8787`. You can point a debug build of the
app at it via `--dart-define=PROXY_URL=http://10.0.2.2:8787` (Android
emulator alias for the host machine) and the same `PROXY_APP_KEY` you set
locally in `.dev.vars`:

```
# server/.dev.vars
ANTHROPIC_API_KEY=sk-ant-…
APP_SHARED_KEY=local-dev-key
```

`.dev.vars` is gitignored.

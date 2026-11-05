# PipeSmart server — Cloudflare Worker

Anthropic + ElevenLabs proxy for PipeSmart. Keeps the Claude API key
(`/messages`) and the ElevenLabs TTS key (`/tts`, natural narration audio)
server-side so the Flutter app never ships them, and meters the AI tutor
allowance per Pro subscription (`/entitlement`). TypeScript on Cloudflare
Workers (wrangler).

## Stack
- TypeScript ^5.5, `@cloudflare/workers-types`, wrangler ^3. Config in `wrangler.toml`.
- Source in `src/`: `worker.ts` (routing, rate limit, metering), `stores.ts`
  (Google Play / App Store / licence-code verification), `token.ts`
  (HMAC entitlement tokens, month helpers). Tests in `test/` run on Node's
  built-in TypeScript support — imports use explicit `.ts` extensions.
- No npm dependencies beyond dev tooling — WebCrypto only.

## Conventions
- Secrets live in Worker secrets (`ANTHROPIC_API_KEY`, `APP_SHARED_KEY`,
  `ENTITLEMENT_SECRET`, `PLAY_SERVICE_ACCOUNT_JSON`, `APPLE_IAP_KEY_P8`,
  `APPLE_KEY_ID`, `APPLE_ISSUER_ID`, `REDEMPTION_SECRET`, `ELEVENLABS_API_KEY`)
  — never hardcode them, never log them.
- `/messages` requires a valid `x-entitlement`; never add a bypass. A store
  or credential failure must surface as `503 store_unavailable`, not as
  "not subscribed".
- `/tts` audio is cached in the `AUDIO_CACHE` R2 bucket keyed by model/voice/sha256(text) — each unique line costs ElevenLabs credits once ever; don't bypass the cache.
- Validate and constrain requests before forwarding to Anthropic (model, max_tokens, size) to avoid abuse of the proxy.
- Keep it a thin pass-through; business logic belongs in the app.
- When changing models/params, check current Claude model IDs — don't guess.
  The app's `AiTutorService.proxyModel` must stay inside `ALLOWED_MODELS`.

## Commands (run from server/)
- Typecheck: `npm run typecheck` (tsc --noEmit)
- Test: `npm test` (node --test)
- Dev: `npm run dev` (wrangler dev)
- Deploy: `npm run deploy` (wrangler deploy) — ask before deploying.

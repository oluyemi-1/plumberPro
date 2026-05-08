# Plumber Pro

A practical training app for UK plumbers — domestic, heat pump, commercial,
commercial gas, LPG/oil, medical gas and fire sprinkler tracks. Animated
narrated simulations, lessons, quizzes, scenarios, calculators and an
optional AI tutor.

## Building for production / public launch (recommended)

For the production track on Google Play (and the App Store), do **not**
embed an Anthropic API key in the build — extract it would take an attacker
about a minute. Instead route AI calls through the Cloudflare Worker proxy
in `server/`:

1. Deploy the proxy — see [`server/README.md`](server/README.md) for the
   step-by-step instructions (about 5 minutes; free tier covers 100k
   requests/day). You'll come away with a worker URL and a long random
   `APP_SHARED_KEY` string.
2. Build the public release with both flags:
   ```bash
   flutter build appbundle --release \
     --dart-define=PROXY_URL=https://plumber-pro-proxy.<your-subdomain>.workers.dev \
     --dart-define=PROXY_APP_KEY=<the same APP_SHARED_KEY value>
   ```
3. Upload the `.aab` to **Production** track on Play Console.

In this configuration:
- The Anthropic key never ships in the APK. It lives on the proxy server.
- The proxy gates each request with the shared app key, rate-limits per IP,
  caps `max_tokens`, and only forwards approved Claude model ids.
- Settings shows a **"Server proxy"** chip on the AI tutor card. Users do
  not need to provide their own key.
- Power users can still paste their own Anthropic key in Settings —
  that's preferred over the proxy and goes direct to api.anthropic.com.

To rotate credentials after a leak: update the `APP_SHARED_KEY` secret on
the worker and ship a new app build with the new value baked in.

## Building for the Google Play test track with an embedded API key

For closed-testing demos you can bake a Claude API key into the build so
testers don't have to set one up themselves. Use `--dart-define` rather than
a `.env` file — the value is compiled into the Dart code as a `const` at
build time, so it never sits in your source tree or git history.

### Build the demo APK

```bash
flutter build apk --release \
  --dart-define=ANTHROPIC_API_KEY=sk-ant-api03-YOURKEYHERE
```

Or for a Play-ready bundle:

```bash
flutter build appbundle --release \
  --dart-define=ANTHROPIC_API_KEY=sk-ant-api03-YOURKEYHERE
```

Upload the result to **Google Play Console → Internal testing** or **Closed
testing**. Add testers by email — only invited testers can install.

### What the app does at runtime

- If a build was compiled with the flag, the AI tutor uses the baked-in key
  automatically. The Settings screen shows the chip "Build-in key" and warns
  that the build is for closed testing only.
- A user can still paste **their own** API key in Settings to override the
  baked-in one. The chip then shows "Your key".
- Builds *without* the flag work exactly as before — the AI tutor asks the
  user to set a key.

### Safety rules for embedded keys

The key in a built APK is **extractable** by anyone with the file. Always:

1. Use a **dedicated demo key** (not your main account key).
2. Set a **workspace spend cap** in https://console.anthropic.com/.
3. Ship only to **closed/internal testing** tracks, never to production.
4. **Rotate** the key after each test cycle.
5. For a real public launch, replace the embedded key with a small **proxy
   server** (Cloudflare Worker / Firebase Function) that holds the key on
   the server side and authenticates requests from the app.

## Running locally during development

```bash
flutter pub get
flutter run --dart-define=ANTHROPIC_API_KEY=sk-ant-api03-YOURKEYHERE
```

Or omit the flag and paste your key into Settings on first launch.

## App icon and splash screen

The app draws its own brand logo on the in-app splash screen using
`lib/widgets/app_logo.dart` — that works without any image assets. To
replace the **native** Android/iOS launcher icon and the OS-level splash
(the brief screen Android shows before Flutter starts), drop two PNGs into
`assets/branding/` and run the generators.

### One-time setup

1. Create the folder:
   ```bash
   mkdir -p assets/branding
   ```
2. Add three PNGs:
   - `assets/branding/icon.png` — 1024 × 1024, opaque, the full app icon
   - `assets/branding/icon_foreground.png` — 1024 × 1024, transparent, just
     the central glyph (centred in the inner ~66% safe-area for adaptive icons)
   - `assets/branding/splash.png` — 512 × 512, transparent, the logo only
3. Generate the launcher icons:
   ```bash
   dart run flutter_launcher_icons
   ```
4. Generate the native splash:
   ```bash
   dart run flutter_native_splash:create
   ```

Both tools update Android `mipmap-*` and iOS `Assets.xcassets` automatically.

The Flutter-side splash (`SplashScreen` widget) takes over once the engine
boots, animates the wordmark in, and routes to onboarding or home.

## Backup & restore (manual cloud sync)

The app ships a manual export/import that covers most "I got a new phone"
scenarios. Open `Settings → Backup & restore`:

- **Export** bundles every shared_preferences key plus every job photo into
  a single `.zip` and opens the system share sheet (email, Drive, AirDrop, etc).
- **Restore** lets the user pick a zip back, shows a summary of what's in it,
  and overwrites local data on confirmation.

The bundle is unencrypted JSON + JPEGs — treat it like a password.

### Optional upgrade path: real-time Firebase sync

For automatic multi-device sync (changes on the phone appear on the tablet
within seconds, no manual zip), add Firebase Auth + Firestore + Storage:

1. Create a Firebase project at https://console.firebase.google.com
2. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. Configure for this app:
   ```bash
   flutterfire configure
   ```
   This adds the platform-specific config files and generates
   `lib/firebase_options.dart`.
4. Add the Firebase packages to `pubspec.yaml`:
   ```yaml
   firebase_core: ^3.6.0
   firebase_auth: ^5.3.1
   cloud_firestore: ^5.4.4
   firebase_storage: ^12.3.2
   google_sign_in: ^6.2.1
   ```
5. Replace `BackupService.exportBackup` with a Firestore push, and add a
   pull-on-startup. Photos go to Firebase Storage with a stored URL.
6. Build a small Sign in with Google flow on the Settings screen.

Until step 6 is done, the manual backup/restore flow is the supported path.

## Privacy & terms

`Settings → Privacy policy` and `Settings → Terms of use` are required by
the Play Store / App Store listing. They live in
`lib/screens/legal_screen.dart` — review and update before public release.

## Tests

```bash
flutter analyze
flutter test
```

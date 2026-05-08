# ProGuard / R8 rules for the release build.
#
# These extend the default Android rules — keep this file lean, only add
# what's strictly needed.

# ── google_mlkit_text_recognition ────────────────────────────────────
# The Flutter wrapper hard-codes references to every script-specific
# recognizer (Chinese, Devanagari, Japanese, Korean) so it can switch on
# them at runtime, but we only ship the Latin recognizer. Tell R8 these
# missing classes are expected, not errors.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

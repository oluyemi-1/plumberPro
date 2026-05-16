import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release-signing credentials. `key.properties` lives at android/key.properties
// and is gitignored. To enable real release signing, copy
// android/key.properties.template → android/key.properties and fill it in.
// If the file is absent — OR its `storeFile` path does not resolve on the
// current machine (e.g. a Windows path on macOS) — we fall back to the debug
// key, which is fine for `flutter run` and `--release` on your own devices
// but cannot be uploaded to the Play Store.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    val storeFilePath = keystoreProperties["storeFile"] as? String
    storeFilePath != null && File(storeFilePath).exists()
} else {
    false
}

android {
    namespace = "com.karitec.pipesmart"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Required by flutter_local_notifications for time-zone-aware
        // scheduling on minSdk < 26.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.karitec.pipesmart"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Only sign with the release keystore when one is present;
            // otherwise fall back to debug so local release builds still
            // work. The Play Store will reject debug-signed APKs / AABs.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Add our custom rules on top of the default optimised ones
            // so R8 stops failing on the unreferenced ML Kit script
            // recognizers (see proguard-rules.pro for details).
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

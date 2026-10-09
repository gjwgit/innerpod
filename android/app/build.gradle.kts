import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// 20261010 gjw Whether this machine can sign a release at all. A CI runner
// cannot, and must still be able to build DEBUG for the screenshots job.

val hasUploadKey = keystorePropertiesFile.exists()

android {
    namespace = "com.togaware.innerpod"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.togaware.innerpod"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // oidcRedirectScheme is required by oidc_android, which declares no
        // default for it, so the manifest merger fails without it.
        manifestPlaceholders.putAll(mapOf(
            "appAuthRedirectScheme" to "com.togaware.innerpod",
            "oidcRedirectScheme" to "com.togaware.innerpod"
        ))
    }

    // 20261010 gjw Created ONLY when key.properties is there. Gradle
    // evaluates this block during CONFIGURATION, for every task, so casting a
    // missing property here broke `assembleDebug` too, and with it the
    // Android screenshots job. The guard below keeps the loud failure for a
    // release build, and nowhere else. Same fix as radiopod.

    signingConfigs {
        if (hasUploadKey) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

// 20261010 gjw Refuse a RELEASE build with no upload key, and only then.
// Checked against the task graph rather than at configuration, so a debug
// build and the integration_test run in .github/workflows/screenshots.yaml
// work on a machine that has no keystore.

if (!hasUploadKey) {
    gradle.taskGraph.whenReady {
        if (allTasks.any { it.name.contains("Release") }) {
            throw GradleException(
                "android/key.properties is missing, so a release build " +
                    "cannot be signed with the upload key.",
            )
        }
    }
}


kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

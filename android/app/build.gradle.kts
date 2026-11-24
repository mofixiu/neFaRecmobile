plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.nefarec"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications uses java.time APIs on older Android.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.nefarec"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // The equipment model is memory-mapped straight from the APK.
    androidResources {
        noCompress += listOf("tflite")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // On-device text recognition with the model bundled in the APK (no download, works offline).
    implementation("com.google.mlkit:text-recognition:16.0.1")
    // On-device body pose for the squat form check (bundled model).
    implementation("com.google.mlkit:pose-detection-accurate:18.0.0-beta5")
    implementation("androidx.exifinterface:exifinterface:1.4.1")
    // Runs neFaRec's own equipment classifier (TensorFlow Lite).
    implementation("com.google.ai.edge.litert:litert:1.4.2")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

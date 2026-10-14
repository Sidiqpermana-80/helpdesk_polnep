plugins {
    id("com.android.application")

    // Konfigurasi Firebase.
    id("com.google.gms.google-services")

    // Plugin Flutter.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.helpdesk_polnep"

    // Gunakan SDK minimal 36, atau versi Flutter jika lebih tinggi.
    compileSdk = maxOf(flutter.compileSdkVersion, 36)

    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Dibutuhkan oleh flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.helpdesk_polnep"

        // Gunakan minimal Android API 24.
        minSdk = maxOf(flutter.minSdkVersion, 24)

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
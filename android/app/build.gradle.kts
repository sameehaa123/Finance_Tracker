plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.sameeha.ai_poweredfinancetracker"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.sameeha.ai_poweredfinancetracker"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

flutter {
    source = "../.."
}

// Kotlin DSL style
apply(plugin = "com.google.gms.google-services")

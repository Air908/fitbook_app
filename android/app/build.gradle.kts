plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin must come after Android/Kotlin
}

android {
    namespace = "com.example.fitbook"
    compileSdk = 35 // ✅ Recommend using latest stable version

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.fitbook"
        minSdk = 21 // ✅ Minimum compatible with flutter_local_notifications
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ Required for flutter_local_notifications
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // ✅ Replace with release signing later
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // ✅ Desugaring dependency
}

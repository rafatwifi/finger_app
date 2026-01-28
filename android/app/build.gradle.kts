plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.finger_app"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.finger_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // توحيد Java و Kotlin على JVM 17
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    // AppCompat (مطلوب لبعض الـ plugins)
    implementation("androidx.appcompat:appcompat:1.6.1")

    // Material Components (إجباري لـ UCrop)
    implementation("com.google.android.material:material:1.11.0")
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.smartmaid.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.smartmaid.app"
        // Android 5.0+
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // دعم العربية والـ RTL
        resConfigs("ar", "en")
    }

    signingConfigs {
        create("release") {
            storeFile = file("release-keystore.jks")
            storePassword = "smartmaid2024"
            keyAlias = "smartmaid"
            keyPassword = "smartmaid2024"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")

            // Optimization
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isDebuggable = true
        }
    }

    bundle {
        language {
            enableSplit = false // لا تقسّم اللغات — نحتاج العربية دائماً
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }

    // دعم Multidex
    defaultConfig {
        multiDexEnabled = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}

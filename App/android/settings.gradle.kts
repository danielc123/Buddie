pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localProperties = file("local.properties")
        if (localProperties.exists()) {
            localProperties.inputStream().use { properties.load(it) }
        }
        var flutterSdkPath = properties.getProperty("flutter.sdk")
        if (flutterSdkPath == null) {
            // Find Flutter SDK relative to project root.
            var file = settings.rootDir
            while (file != null) {
                val sdk = File(file, "flutter")
                if (sdk.exists()) {
                    flutterSdkPath = sdk.absolutePath
                    break
                }
                file = file.parentFile
            }
        }
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.8.2" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")

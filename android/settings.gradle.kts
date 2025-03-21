pluginManagement {
    def flutterSdkPath = {
        val properties = java.util.Properties()
        file("local.properties").withInputStream { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
            ?: throw GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
        return@withInputStream flutterSdkPath
    }
    settings.ext.flutterSdkPath = flutterSdkPath()

    includeBuild("${settings.ext.flutterSdkPath}/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

include(":app")

// This is needed to include Flutter
val localPropertiesFile = rootProject.file("local.properties")
val properties = java.util.Properties()
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { properties.load(it) }
}
val flutterSdkPath = properties.getProperty("flutter.sdk")
if (flutterSdkPath != null) {
    apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle")
}

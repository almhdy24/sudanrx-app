pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
    plugins {
        id("dev.flutter.flutter-gradle-plugin") version "1.0.0"
    }
}

include(":app")

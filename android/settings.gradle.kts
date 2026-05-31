include(":app")

val flutterSdkPath = System.getenv("FLUTTER_HOME") ?: {
    val properties = java.util.Properties()
    file("local.properties").inputStream().use { properties.load(it) }
    properties.getProperty("flutter.sdk")
}()
if (flutterSdkPath != null) {
    apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle")
}

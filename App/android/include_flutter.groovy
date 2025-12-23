def flutterProjectRoot = rootProject.projectDir.parentFile
def flutterPluginVersion = '1.0.0'
def flutterSdkPath

def localProperties = new File(flutterProjectRoot, 'local.properties')
if (localProperties.exists()) {
    localProperties.withReader('UTF-8') { reader ->
        def prop = new Properties()
        prop.load(reader)
        flutterSdkPath = prop.getProperty('flutter.sdk')
    }
}
if (flutterSdkPath == null) {
    // If flutter.sdk is not specified in local.properties, try to find it.
    // This logic is borrowed from flutter.groovy.
    def flutterRoot = System.env.FLUTTER_ROOT
    if (flutterRoot != null) {
        flutterSdkPath = flutterRoot
    } else {
        try {
            def whichFlutter = 'which flutter'.execute(null, flutterProjectRoot).text.trim()
            def flutterFile = new File(whichFlutter)
            if (flutterFile.exists()) {
                flutterSdkPath = flutterFile.absoluteFile.parentFile.parent
            }
        } catch (ignored) {
            // "which flutter" can fail if Flutter is not on the path.
        }
    }
}

if (flutterSdkPath == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file or add flutter to your path.")
}

apply from: "$flutterSdkPath/packages/flutter_tools/gradle/flutter.groovy"

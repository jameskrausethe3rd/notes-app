allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Fix for verifyReleaseResources
    // ============
    afterEvaluate {
        if (plugins.hasPlugin("com.android.application") || plugins.hasPlugin("com.android.library")) {
            extensions.getByType<com.android.build.gradle.BaseExtension>().apply {
                compileSdkVersion(34)
                buildToolsVersion("34.0.0")
            }
        }

        if (project.hasProperty("android")) {
            extensions.getByType<com.android.build.gradle.BaseExtension>().apply {
                if (namespace == null) {
                    namespace = project.group.toString()
                }
            }
        }
    }
    // ============
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

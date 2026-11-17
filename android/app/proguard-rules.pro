# R8/ProGuard rules for release builds. Flutter, Firebase and the plugins in
# pubspec.yaml ship their own consumer rules; add keep rules here only when a
# release build proves they are needed.

# Keep Crashlytics stack traces readable.
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

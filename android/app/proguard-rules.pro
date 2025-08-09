# Keep Flutter and Firebase classes from obfuscation issues
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn org.conscrypt.**

# Play Core (split install / split compat) for deferred components
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**


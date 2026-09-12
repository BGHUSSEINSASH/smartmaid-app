# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings { <fields>; }
-keepclassmembers class kotlin.Metadata { public <methods>; }

# Riverpod / Dart reflection
-keep class com.google.** { *; }
-keep class androidx.** { *; }

# geolocator
-keep class com.baseflow.geolocator.** { *; }

# speech_to_text
-keep class com.csdcorp.speech_to_text.** { *; }

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# http
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn okhttp3.**
-dontwarn okio.**

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Core
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-keep class com.google.android.play.core.** { *; }

# sqflite
-keep class com.tekartik.sqflite.** { *; }

# shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# uuid
-keep class com.darten.** { *; }

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

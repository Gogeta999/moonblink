## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**
#In app Purchase
-keep class com.amazon.** {*;}
-keep class com.dooboolab.** { *; }
-keep class com.android.vending.billing.**
-dontwarn com.amazon.**
-keepattributes *Annotation*
#flutter-ffmpeg
-keep class com.arthenica.mobileffmpeg.Config {
  native <methods>;
  void log(int, byte[]);
  void statistics(int, float, float, long , int, double, double);
}
#local notification
-keep class com.dexterous.** { *; }
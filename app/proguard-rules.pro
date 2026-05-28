# Keep WebView interface
-keepclasseswithmembers class * {
    public <methods>;
}

# Keep view classes for layout inflation
-keepclasseswithmembers class * extends android.view.View {
    public <init>(android.content.Context, android.util.AttributeSet);
}

# Keep activity classes
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

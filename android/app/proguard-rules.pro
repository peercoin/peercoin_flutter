# Keep Google Tink annotation classes
-keep class com.google.errorprone.annotations.** { *; }
-dontwarn com.google.errorprone.annotations.**

# Keep Checker Framework annotations
-keep class org.checkerframework.checker.nullness.qual.** { *; }
-dontwarn org.checkerframework.checker.nullness.qual.**

# Keep other annotation classes that might be missing
-keep class javax.annotation.** { *; }
-dontwarn javax.annotation.**

# Keep Google Tink classes
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Keep crypto-related classes that might be accessed via reflection
-keep class * implements javax.crypto.** { *; }
-keep class * extends javax.crypto.** { *; }

# Keep Flutter secure storage native classes
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep coinlib and crypto-related native classes
-keep class coinlib.** { *; }
-keep class frosty.** { *; }

# Keep gRPC and protobuf classes
-keep class io.grpc.** { *; }
-keep class com.google.protobuf.** { *; }

# General rules for common issues
-dontwarn java.lang.reflect.**
-dontwarn java.beans.**
-dontwarn javax.lang.model.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

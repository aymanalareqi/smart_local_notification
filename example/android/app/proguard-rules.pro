# Smart Local Notification Plugin ProGuard Rules

# Keep all plugin classes
-keep class com.example.smart_local_notification.** { *; }

# Keep notification receivers and services
-keep class * extends android.content.BroadcastReceiver
-keep class * extends android.app.Service

# Keep notification data classes and serializable objects
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep alarm manager and notification manager related classes
-keep class android.app.AlarmManager { *; }
-keep class android.app.NotificationManager { *; }
-keep class androidx.core.app.NotificationCompat { *; }
-keep class androidx.core.app.NotificationManagerCompat { *; }

# Keep audio related classes
-keep class android.media.** { *; }
-keep class androidx.media.** { *; }

# Keep Flutter plugin registration
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

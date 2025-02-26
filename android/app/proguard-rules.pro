# Keep FlutterLocalNotificationsPlugin classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep the notification handler
-keep class com.example.test.NotificationService { *; }
-keep class com.example.test.notificationTapBackground { *; }

# Keep serialization/deserialization classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
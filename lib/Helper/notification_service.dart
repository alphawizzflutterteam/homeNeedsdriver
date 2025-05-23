import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  BuildContext? context;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android:
          AndroidInitializationSettings("ic_launcher"), //@mipmap/ic_launcher
      /*iOS: DarwinInitializationSettings()*/
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {}
      },
    );

    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage______________");
        if (message.notification != null) {
          // display(message);
          //
          // handleNotification(message.data);
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp___________");
        if (message.notification != null) {
          /* print('_____________${message.notification}______2_________');
          print('_____________${message.notification?.title}_______________');
          print(message.notification!.body);
          print("message.data22 ${message.data}");
          if (message.data['delivery_boy_id'] != null &&
              message.data['delivery_boy_id'] != "") {
           Get.to(FeedbackScreen(
              driverId: message.data['delivery_boy_id'],
              driverName: message.data['delivery_name'],
              parcelId: message.data['parcel_id'],
            ));
          }*/

          // Get.to(FeedbackScreen());
          handleNotification(message.data);

          // HomeScreenState().setSegmentValue(2) ;
        }
      },
    );
  }

  static Future<void> handleNotification(Map<String, dynamic> message) async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      // App was opened from a notification
      // TODO: handle the notification
    } else {
      // App was opened normally
    }
  }

  static void display(RemoteMessage message) async {
    try {
      print("In Notification method");
      // int id = DateTime.now().microsecondsSinceEpoch ~/1000000;
      Random random = Random();
      int id = random.nextInt(1000);
      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
              "default_notification_channel", "HomeNeeds",
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              // sound: RawResourceAndroidNotificationSound('test'),
              icon: '@mipmap/ic_launcher'));
      //print("my id is ${id.toString()}");
      await _flutterLocalNotificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,
          notificationDetails,
          payload: message.data['_id']);
    } on Exception catch (e) {
      print('Error>>>$e');
    }
  }
}

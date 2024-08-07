import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationServices {
  static List<String> extractInnerMessages(String input) {
    RegExp regex = RegExp(r'\[\[(.*?)\]\[(.*?)\]\]');
    Match? match = regex.firstMatch(input);

    if (match != null && match.groupCount == 2) {
      return [match.group(1)!, match.group(2)!];
    } else {
      // Handle the case when the input format doesn't match the expected pattern
      return [];
    }
  }

  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final onNotificationClick = StreamController<List<String>>();

  static void onNotificationTap(NotificationResponse notificationResponse) {
    debugPrint("clicked");
  }

  static Future initialize() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("proctor_logo"),
    );

    notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  static void createNotification(RemoteMessage message) async {
    try {
      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        "pushnotification",
        "pushnotificationchannel",
        importance: Importance.max,
        priority: Priority.high,
      ));
      await notificationsPlugin.show(0, message.notification!.title,
      message.notification!.body, notificationDetails,);
      //notificationsPlugin.runtimeType
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
}

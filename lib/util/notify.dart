import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

void toast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black45,
      textColor: Colors.white,
      fontSize: 12.0);
}

Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {}

Future selectNotification(String payload) async {
  if (payload != null) {
    if (payload.startsWith("https://") || payload.startsWith("http://")) {
      launch(payload);
    } else
      toast(payload);
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

MacOSInitializationSettings initializationSettingsMacOS;

AndroidNotificationDetails androidPlatformChannelSpecifics;

NotificationDetails platformChannelSpecifics;

Future<void> initNotification() async {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );

  initializationSettingsMacOS = MacOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false);

  InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);

  androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.nlog.flutterlocalnotifications.ScheduledNotificationBootReceiver',
      '자가진단 자동화',
      '자동으로 자가진단 설문을 제출합니다.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false);

  platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
}

var notiId = 0;

void noti(String title, String desc, [String payload = ""]) async {
  if (payload == "") payload = desc;
  await flutterLocalNotificationsPlugin
      .show(notiId++, title, desc, platformChannelSpecifics, payload: payload);
}

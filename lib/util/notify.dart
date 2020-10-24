import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    int id, String title, String body, String payload) async {
  //toast(body + "|" + payload);
}

Future selectNotification(String payload) async {
  if (payload != null) {
    //debugPrint('notification payload: ' + payload);
    toast(payload);
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
  requestSoundPermission: false,
  requestBadgePermission: false,
  requestAlertPermission: false,
  onDidReceiveLocalNotification: onDidReceiveLocalNotification,
);
final MacOSInitializationSettings initializationSettingsMacOS =
    MacOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false);
final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS);

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'com.nlog.flutterlocalnotifications.ScheduledNotificationBootReceiver',
        '자가진단 자동화',
        '자동으로 자가진단 설문을 제출합니다.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

void initNotification() async {
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
}

var notiId = 0;

void noti(String title, String desc) async {
  await flutterLocalNotificationsPlugin
      .show(notiId++, title, desc, platformChannelSpecifics, payload: desc);
}

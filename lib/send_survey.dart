import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jaga_jindan/rsa_encrypt.dart';
import 'package:http/http.dart' as http;

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
    debugPrint('notification payload: ' + payload);
    toast(payload);
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
var initializationSettingsIOS = IOSInitializationSettings(
    onDidReceiveLocalNotification: onDidReceiveLocalNotification);
var initializationSettings = InitializationSettings(
    initializationSettingsAndroid, initializationSettingsIOS);
var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'com.nlog.flutterlocalnotifications.ScheduledNotificationBootReceiver',
    '자가진단 자동화',
    '자동으로 자가진단 설문을 제출합니다.',
    importance: Importance.Max,
    priority: Priority.High,
    ticker: 'ticker');
var iOSPlatformChannelSpecifics = IOSNotificationDetails();
var platformChannelSpecifics = NotificationDetails(
    androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

void initNotification() async {
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
}

var notiId = 0;
void noti(String title, String desc) async {
  await flutterLocalNotificationsPlugin
      .show(notiId++, title, desc, platformChannelSpecifics, payload: desc);
}

class JagaJindanData {
  String name, birthday, school, edu, password;
  bool force, agree = false, startup = false, noti = false;

  static JagaJindanData readFromJSON(dynamic json) {
    return new JagaJindanData(
        json["name"] ?? "",
        json["birthday"] ?? "",
        json["school"] ?? "",
        json["edu"] ?? "",
        json["password"] ?? "",
        json["force"] ?? false,
        json["agree"] ?? false,
        json["startup"] ?? false,
        json["noti"] ?? false);
  }

  JagaJindanData(this.name, this.birthday, this.school, this.edu, this.password,
      this.force, this.agree, this.startup, this.noti);

  dynamic toJSON() {
    return {
      "name": this.name,
      "birthday": this.birthday,
      "school": this.school,
      "edu": this.edu,
      "password": this.password,
      "force": this.force,
      "agree": this.agree,
      "startup": this.startup,
      "noti": this.noti
    };
  }
}

void showSurveyResult(bool success, String message, JagaJindanData credentials) {
  if (credentials.noti) noti(success ? "자가진단 제출을 성공하였습니다." : "자가진단 제출을 실패하였습니다.", message);
  else toast(message);
}

void sendSurvey(JagaJindanData credentials) async {
  try {
    String jwt = jsonDecode((await http.post(
            'https://${credentials.edu}hcs.eduro.go.kr/loginwithschool',
            body: jsonEncode({
              'birthday': encrypt(credentials.birthday),
              'name': encrypt(credentials.name),
              'orgcode': credentials.school
            }),
            headers: {'Content-Type': 'application/json'},
            encoding: Encoding.getByName('utf-8')))
        .body)['token'];

    if (!credentials.force) {
      if ((await http.post('https://${credentials.edu}hcs.eduro.go.kr/checkpw',
                  body: jsonEncode({}),
                  headers: {
                'Authorization': jwt,
                'Content-Type': 'application/json'
              }))
              .statusCode !=
          200) {
        showSurveyResult(false, '자가진단 페이지에서 초기 비밀번호를 설정하세요.', credentials);
        return;
      }

      if (jsonDecode((await http.post(
                  'https://${credentials.edu}hcs.eduro.go.kr/secondlogin',
                  body: jsonEncode({
                    'deviceUuid': '',
                    'password': encrypt(credentials.password)
                  }),
                  headers: {
                'Authorization': jwt,
                'Content-Type': 'application/json'
              }))
              .body)['isError'] ==
          true) {
        showSurveyResult(false, '비밀번호를 잘못 입력했습니다.', credentials);
        return;
      }
    }

    var users = jsonDecode((await http.post(
            'https://${credentials.edu}hcs.eduro.go.kr/selectGroupList',
            body: jsonEncode({}),
            headers: {
          'Authorization': jwt,
          'Content-Type': 'application/json'
        }))
        .body);

    jwt = users['groupList'][0]['token'];

    var userNo = int.parse(users['groupList'][0]['userPNo']);
    String org = users['groupList'][0]['orgCode'];

    jwt = jsonDecode((await http.post(
            'https://${credentials.edu}hcs.eduro.go.kr/userrefresh',
            body: jsonEncode({'userPNo': userNo, 'orgCode': org}),
            headers: {
          'Authorization': jwt,
          'Content-Type': 'application/json'
        }))
        .body)['UserInfo']['token'];

    var res = await http.post(
        'https://${credentials.edu}hcs.eduro.go.kr/registerServey',
        body: jsonEncode({
          'rspns01': '1',
          'rspns02': '1',
          'rspns03': null,
          'rspns04': null,
          'rspns05': null,
          'rspns06': null,
          'rspns07': '0',
          'rspns08': '0',
          'rspns09': '0',
          'rspns10': null,
          'rspns11': null,
          'rspns12': null,
          'rspns13': null,
          'rspns14': null,
          'rspns15': null,
          'rspns00': 'Y',
          'deviceUuid': ''
        }),
        headers: {'Authorization': jwt, 'Content-Type': 'application/json'});

    showSurveyResult(true, "자가진단 설문이 ${DateTime.now().toString().substring(0, 19)}에 제출되었습니다.", credentials);
  } catch (e) {
    showSurveyResult(false, "인증 정보를 한번 더 확인해주세요.\n오류가 계속 발생하는 경우 개발자에게 알려주세요.", credentials);
    //toast(e.toString());
  }
}

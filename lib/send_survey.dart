import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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

class JagaJindanData {
  String name, birthday, school, edu, password;
  bool force, agree = false, startup = false;

  static JagaJindanData readFromJSON(dynamic json) {
    return new JagaJindanData(
        json["name"] ?? "",
        json["birthday"] ?? "",
        json["school"] ?? "",
        //json["edu"] ?? "",
        json["password"] ?? "",
        json["force"] ?? false,
        json["agree"] ?? false,
        json["startup"] ?? false);
  }

  JagaJindanData(
      this.name,
      this.birthday,
      this.school,
      /*this.edu, */
      this.password,
      this.force,
      this.agree,
      this.startup);

  dynamic toJSON() {
    return {
      "name": this.name,
      "birthday": this.birthday,
      "school": this.school,
      //"edu": this.edu,
      "password": this.password,
      "force": this.force,
      "agree": this.agree,
      "startup": this.startup
    };
  }
}

void sendSurvey(JagaJindanData credentials) async {
  try {
    String jwt = jsonDecode(
        (await http.post('https://penhcs.eduro.go.kr/loginwithschool',
                body: jsonEncode({
                  'birthday': encrypt(credentials.birthday),
                  'name': encrypt(credentials.name),
                  'orgcode': credentials.school
                }),
                headers: {'Content-Type': 'application/json'},
                encoding: Encoding.getByName('utf-8')))
            .body)['token'];

    if (!credentials.force) {
      if ((await http.post('https://penhcs.eduro.go.kr/checkpw',
                  body: jsonEncode({}),
                  headers: {
                'Authorization': jwt,
                'Content-Type': 'application/json'
              }))
              .statusCode !=
          200) {
        toast('자가진단 페이지에서 초기 비밀번호를 설정하세요.');
        return;
      }

      if (jsonDecode((await http.post('https://penhcs.eduro.go.kr/secondlogin',
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
        toast('비밀번호를 잘못 입력했습니다.');
        return;
      }
    }

    var users = jsonDecode((await http.post(
            'https://penhcs.eduro.go.kr/selectGroupList',
            body: jsonEncode({}),
            headers: {
          'Authorization': jwt,
          'Content-Type': 'application/json'
        }))
        .body);

    jwt = users['groupList'][0]['token'];

    var userNo = int.parse(users['groupList'][0]['userPNo']);
    String org = users['groupList'][0]['orgCode'];

    jwt = jsonDecode((await http.post('https://penhcs.eduro.go.kr/userrefresh',
            body: jsonEncode({'userPNo': userNo, 'orgCode': org}),
            headers: {
          'Authorization': jwt,
          'Content-Type': 'application/json'
        }))
        .body)['UserInfo']['token'];

    var res = await http.post('https://penhcs.eduro.go.kr/registerServey',
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

    toast("자가진단 설문이 ${DateTime.now().toString().substring(0, 19)}에 제출되었습니다.");
  } catch (e) {
    toast("인증 정보를 한번 더 확인해주세요.\n오류가 계속 발생하는 경우 개발자에게 알려주세요.");
  }
}

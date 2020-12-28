import 'dart:async';
import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jaga_jindan/type/JagaJindanData.dart';
import 'package:jaga_jindan/ui/component/JagaJindanForm.dart';
import 'package:jaga_jindan/ui/component/setting.dart';
import 'package:jaga_jindan/util/notify.dart';
import 'package:jaga_jindan/util/school.dart';
import 'package:jaga_jindan/util/sendSurvey.dart';
import 'package:package_info/package_info.dart';

import 'MainPage.dart';

class MainPageState extends State<MainPage> {
  final formKey = GlobalKey<FormState>();
  String edu = "서울특별시", school = "1", selectedSchoolCode = "";
  List<School> schools = [];
  bool flag = false, initBackground = false;
  String appVer, newVer = "불러오는 중";

  TextEditingController searchSchoolController;

  Future<void> initBackgroundService() async {
    if (!initBackground) {
      BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    }
    initBackground = true;
  }

  @override
  Widget build(BuildContext context) {
    this.widget.pageState = this;
    searchSchoolController = TextEditingController();
    initBackgroundService();

    if (!flag) {
      PackageInfo.fromPlatform().then((value) => setState(() {
            appVer = value.version;
          }));

      http
          .get(
              "https://api.github.com/repos/eduro-hcs/jaga_jindan/releases/latest")
          .then((data) {
        try {
          setState(() {
            newVer = jsonDecode(data.body)["tag_name"];
            newVer = newVer.substring(1);
            if (newVer != appVer) {
              noti("새로운 버전이 있습니다.", "현재 버전 : $appVer, 새 버전 : $newVer",
                  "https://github.com/eduro-hcs/jaga_jindan/releases/latest");
            }
          });
        } catch (e) {
          newVer = "(error)";
        }
      });
    }
    flag = true;

    return Scaffold(
        appBar: AppBar(
          title: Text('자가진단 자동 제출'),
        ),
        body: new Padding(
          child: Center(
            child: ListView(shrinkWrap: true, children: [JagaJindanForm(this)]),
          ),
          padding: EdgeInsets.all(20),
        ),
        floatingActionButton: Padding(
            padding: EdgeInsets.only(left: 33),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomLeft,
                  child: FloatingActionButton(
                    onPressed: () async {
                      showCredit(this, appVer, newVer);
                    },
                    child: Icon(Icons.settings),
                    tooltip: "설정 및 정보",
                  ),
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() == true) {
                          sendSurvey(this.widget.data);
                        }
                      },
                      tooltip: '자가진단 제출',
                      child: Icon(Icons.send),
                    )),
              ],
            )));
  }
}

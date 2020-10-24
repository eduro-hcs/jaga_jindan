import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jaga_jindan/ui/component/JagaJindanForm.dart';
import 'package:jaga_jindan/ui/component/setting.dart';
import 'package:jaga_jindan/util/school.dart';

import 'package:jaga_jindan/util/sendSurvey.dart';

import 'MainPage.dart';

class MainPageState extends State<MainPage> {
  final formKey = GlobalKey<FormState>();
  String edu = "서울특별시", school = "1", selectedSchoolCode = "";
  List<School> schools = [];

  TextEditingController searchSchoolController;

  @override
  Widget build(BuildContext context) {
    this.widget.pageState = this;
    searchSchoolController = TextEditingController();

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
                      showCredit(this);
                    },
                    child: Icon(Icons.settings),
                    tooltip: "설정 및 정보",
                  ),
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      onPressed: () {
                        if (formKey.currentState.validate()) {
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

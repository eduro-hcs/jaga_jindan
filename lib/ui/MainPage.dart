import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jaga_jindan/type/JagaJindanData.dart';
import 'package:jaga_jindan/util/internalIO.dart';

import 'package:jaga_jindan/util/sendSurvey.dart';

import 'MainPageState.dart';
import 'component/agree.dart';

class MainPage extends StatefulWidget {
  JagaJindanData data = JagaJindanData(
      "", "", "", "", "", false, false, false, false, false, null);

  TextEditingController nameController = TextEditingController(),
      birthdayController = TextEditingController(),
      schoolController = TextEditingController(),
      eduController = TextEditingController(),
      passwordController = TextEditingController(),
      timeController = TextEditingController();

  MainPageState pageState;

  readJSON() async {
    this.data = JagaJindanData.readFromJSON(await readInternal());
    this.nameController.text = this.data.name;
    this.birthdayController.text = this.data.birthday;
    this.schoolController.text = this.data.school;
    this.eduController.text = this.data.edu;
    this.passwordController.text = this.data.password;

    var tm = this.data.submitTime;
    if (tm != null && tm.minute != null && tm.hour != null)
      this.timeController.text =
          "${tm.hour < 10 ? '0' : ''}${tm.hour}:${tm.minute < 10 ? '0' : ''}${tm.minute}";

    //setBackgroundProcess(this.data);
    backgroundFetchHeadlessTask(FB_TASK_ID);

    //if (this.data.startup) sendSurvey(this.data, true);

    agree(pageState);
    pageState.setState(() {});
  }

  writeJSON() async {
    await writeInternal(this.data.toJSON());
  }

  @override
  MainPageState createState() => MainPageState();
}

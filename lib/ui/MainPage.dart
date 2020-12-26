import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jaga_jindan/type/JagaJindanData.dart';
import 'package:jaga_jindan/util/internalIO.dart';

import 'package:jaga_jindan/util/sendSurvey.dart';

import 'MainPageState.dart';
import 'component/agree.dart';

class MainPage extends StatefulWidget {
  JagaJindanData data =
      JagaJindanData("", "", "", "", "", false, false, false, false);

  TextEditingController nameController = TextEditingController(),
      birthdayController = TextEditingController(),
      schoolController = TextEditingController(),
      eduController = TextEditingController(),
      passwordController = TextEditingController();

  MainPageState pageState;

  readJSON() async {
    this.data = JagaJindanData.readFromJSON(await readInternal());
    this.nameController.text = this.data.name;
    this.birthdayController.text = this.data.birthday;
    this.schoolController.text = this.data.school;
    this.eduController.text = this.data.edu;
    this.passwordController.text = this.data.password;

    if (this.data.startup) sendSurvey(this.data, true);

    agree(pageState);
    await pageState.setState(() {});
  }

  writeJSON() async {
    await writeInternal(this.data.toJSON());
  }

  @override
  MainPageState createState() => MainPageState();
}

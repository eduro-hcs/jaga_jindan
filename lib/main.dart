import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

_write(dynamic json) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/cred.json');
  await file.writeAsString(jsonEncode(json));
}

Future<dynamic> _read() async {
  String text;
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/cred.json');
    text = await file.readAsString();
  } catch (e) {
    text = "{}";
  }
  return jsonDecode(text);
}

class JagaJindanData {
  String name, birthday, school, edu, password;
  bool force, agree = false;

  static JagaJindanData readFromJSON(dynamic json) {
    return new JagaJindanData(
        json["name"] ?? "",
        json["birthday"] ?? "",
        json["school"] ?? "",
        json["edu"] ?? "",
        json["password"] ?? "",
        json["force"] ?? false,
        json["agree"] ?? false);
  }

  JagaJindanData(this.name, this.birthday, this.school, this.edu, this.password,
      this.force, this.agree);

  dynamic toJSON() {
    return {
      "name": this.name,
      "birthday": this.birthday,
      "school": this.school,
      "edu": this.edu,
      "password": this.password,
      "force": this.force,
      "agree": this.agree
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var obj = MainPage();
    obj.readJSON();
    return MaterialApp(
      title: '자가진단',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: obj,
    );
  }
}

class MainPage extends StatefulWidget {
  JagaJindanData data = JagaJindanData("", "", "", "", "", false, false);
  TextEditingController nameController = TextEditingController(),
      birthdayController = TextEditingController(),
      schoolController = TextEditingController(),
      eduController = TextEditingController(),
      passwordController = TextEditingController(),
      forceController = TextEditingController();

  readJSON() async {
    this.data = JagaJindanData.readFromJSON(await _read());
    this.nameController.text = this.data.name;
    this.birthdayController.text = this.data.birthday;
    this.schoolController.text = this.data.school;
    this.eduController.text = this.data.edu;
    this.passwordController.text = this.data.password;
  }

  writeJSON() async {
    await _write(this.data.toJSON());
  }

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _formKey = GlobalKey<FormState>();

  Future<bool> sendSurvey() async {
    Fluttertoast.showToast(
        msg: "자가진단 설문이 ${DateTime.now().toString().substring(0, 19)}에 제출되었습니다.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black45,
        textColor: Colors.white,
        fontSize: 12.0);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자가진단 자동 제출'),
      ),
      body: new Padding(
          child: Center(child: ListView(
              shrinkWrap: true,
              children: [
                Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("인증 정보 입력",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline4
                                    .fontSize)),
                        new Padding(padding: EdgeInsets.only(bottom: 50)),
                        TextFormField(
                          decoration:
                          const InputDecoration(hintText: "이름을 입력하세요."),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "이름을 입력하세요.";
                            }
                            return null;
                          },
                          onChanged: (text) {
                            this.widget.data.name = text;
                            this.widget.writeJSON();
                          },
                          controller: this.widget.nameController,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              hintText: "생년월일을 입력하세요. (YYMMDD)"),
                          validator: (value) {
                            if (value.length != 6) {
                              return "생년월일을 올바르게 입력하세요.";
                            }
                            return null;
                          },
                          onChanged: (text) {
                            this.widget.data.birthday = text;
                            this.widget.writeJSON();
                          },
                          controller: this.widget.birthdayController,
                        ),
                        Row(
                          children: <Widget>[
                            new Flexible(
                                child: new FocusScope(
                                    node: new FocusScopeNode(),
                                    canRequestFocus: false,
                                    child: TextFormField(
                                        decoration: const InputDecoration(
                                            hintText: "학교를 선택하세요.")))),
                            FlatButton(
                              child: Icon(Icons.search),
                              onPressed: () {},
                              minWidth: 0,
                              height: 0,
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.all(3),
                            ),
                          ],
                        ),
                        //Dropdown 교육청 선택 구현
                        Visibility(
                          child: TextFormField(
                            decoration:
                            const InputDecoration(hintText: "비밀번호를 입력하세요."),
                            obscureText: true,
                            validator: (value) {
                              if (value.length != 4) {
                                return "비밀번호 4자리를 입력하세요.";
                              }
                              return null;
                            },
                            onChanged: (text) {
                              this.widget.data.password = text;
                              this.widget.writeJSON();
                            },
                            controller: this.widget.passwordController,
                          ),
                          visible: timeDilation == 1.0,
                        ),
                        CheckboxListTile(
                          title: const Text('비밀번호 없이 설문 제출'),
                          value: timeDilation != 1.0,
                          onChanged: (bool value) {
                            setState(() {
                              if (value) {
                                showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('경고'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text(
                                                '비밀번호 없이 설문을 제출할 수 있습니다.'),
                                            Text(
                                                '위 기능을 사용함으로써 발생하는 모든 책임은 사용자에게 있습니다.'),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text('계속하기'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            this.widget.data.password = "";
                                            this.widget.data.force = true;
                                            this.widget.writeJSON();

                                            setState(() {
                                              timeDilation = 2.0;
                                            });
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('끄기'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                timeDilation = 1.0;
                                this.widget.writeJSON();
                              }
                            });
                          },
                        ),
                      ],
                    )),
              ]),),
        padding: EdgeInsets.all(20),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if (!this.widget.data.agree) {
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('알림'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('이 앱을 사용함으로써 발생하는 모든 민,형사적 책임은 앱 사용자에게 있습니다.'),
                          Text(
                              '코로나19 의심 증상이 있으면 즉시 공식 홈페이지에서 설문 재제출을 하시기 바랍니다.'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      /*
                    CheckboxListTile(
                      title: const Text('창 띄우지 않기'),
                      value: timeDilation != 1.0,
                      onChanged: (bool value) {
                        setState(() {
                          timeDilation = value ? 2.0 : 1.0;
                        });
                      },
                    ),*/
                      FlatButton(
                        child: Text('동의'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          this.widget.data.agree = true;
                          this.widget.writeJSON();

                          this.sendSurvey();
                        },
                      ),
                      FlatButton(
                        child: Text('앱 종료'),
                        onPressed: () {
                          exit(0);
                        },
                      ),
                    ],
                  );
                },
              );
            } else
              this.sendSurvey();
          }
        },
        tooltip: '자가진단 제출',
        child: Icon(Icons.send),
      ),
    );
  }
}

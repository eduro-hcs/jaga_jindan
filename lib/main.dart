import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:jaga_jindan/send_survey.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:jaga_jindan/edu_list.dart';
import 'package:jaga_jindan/school.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:http/http.dart' as http;

void main() {
  timeDilation = 2.0;
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var obj = MainPage();
    obj.readJSON();
    initNotification();
    return MaterialApp(
      title: '자가진단',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: obj,
      darkTheme: ThemeData.dark(),
    );
  }
}

class MainPage extends StatefulWidget {
  JagaJindanData data =
      JagaJindanData("", "", "", "", "", false, false, false, false);
  TextEditingController nameController = TextEditingController(),
      birthdayController = TextEditingController(),
      schoolController = TextEditingController(),
      eduController = TextEditingController(),
      passwordController = TextEditingController(),
      forceController = TextEditingController();

  _MainPageState _state;

  readJSON() async {
    this.data = JagaJindanData.readFromJSON(await _read());
    this.nameController.text = this.data.name;
    this.birthdayController.text = this.data.birthday;
    this.schoolController.text = this.data.school;
    this.eduController.text = this.data.edu;
    this.passwordController.text = this.data.password;

    if (this.data.startup) sendSurvey(this.data);

    await _state.agree();
    await _state.setState(() {});
  }

  writeJSON() async {
    await _write(this.data.toJSON());
  }

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _formKey = GlobalKey<FormState>();
  String _edu = "서울특별시", _school = "1", _select_school_code = "";
  List<School> _schools = [];

  TextEditingController searchSchoolController;

  Future<void> agree() async {
    if (!this.widget.data.agree) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('알림'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('이 앱을 사용함으로써 발생하는 모든 민,형사상 책임은 앱 사용자에게 있습니다.'),
                  Text('코로나19 의심 증상이 있으면 즉시 공식 홈페이지에서 설문 재제출을 하시기 바랍니다.'),
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
                  this.widget.data.agree = true;
                  this.widget.writeJSON();
                  Navigator.of(context).pop();
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
      ).then((value) {
        if (!this.widget.data.agree) exit(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    this.widget._state = this;
    searchSchoolController = TextEditingController();
    return Scaffold(
        appBar: AppBar(
          title: Text('자가진단 자동 제출'),
        ),
        body: new Padding(
          child: Center(
            child: ListView(shrinkWrap: true, children: [
              Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("인증 정보 입력",
                          style: TextStyle(
                              //color: Colors.black,
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
                        keyboardType: TextInputType.number,
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
                                        hintText: "학교를 선택하세요."),
                                    controller: this.widget.schoolController,
                                  ))),
                          FlatButton(
                            child: Icon(Icons.search),
                            onPressed: () {
                              _schools = [];
                              _select_school_code = "";

                              showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(builder:
                                      (context, StateSetter _setState) {
                                    return AlertDialog(
                                      title: Text('학교 검색'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            DropdownButton<String>(
                                              icon: Icon(
                                                  Icons.keyboard_arrow_down),
                                              items: EDU_LIST.entries
                                                  .map<
                                                      DropdownMenuItem<
                                                          String>>((e) =>
                                                      DropdownMenuItem(
                                                          child: Text(e.key),
                                                          value: e.key))
                                                  .toList(),
                                              onChanged: (String value) {
                                                _setState(() {
                                                  _edu = value;
                                                });
                                              },
                                              value: _edu,
                                              iconSize: 24,
                                              elevation: 16,
                                              //style: TextStyle(color: Colors.deepOrange),
                                              underline: Container(
                                                height: 2,
                                                //color: Colors.deepOrange,
                                              ),
                                            ),
                                            DropdownButton<String>(
                                              icon: Icon(
                                                  Icons.keyboard_arrow_down),
                                              items: {
                                                '1': '유치원',
                                                '2': '초등학교',
                                                '3': '중학교',
                                                '4': '고등학교',
                                                '5': '특수학교'
                                              }
                                                  .entries
                                                  .map<
                                                      DropdownMenuItem<
                                                          String>>((e) =>
                                                      DropdownMenuItem(
                                                        child: Text(e.value),
                                                        value: e.key,
                                                      ))
                                                  .toList(),
                                              onChanged: (String value) {
                                                _setState(() {
                                                  _school = value;
                                                });
                                              },
                                              value: _school,
                                              iconSize: 24,
                                              elevation: 16,
                                              //style: TextStyle(color: Colors.deepOrange),
                                              underline: Container(
                                                height: 2,
                                                //color: Colors.deepOrange,
                                              ),
                                            ),
                                            Row(children: <Widget>[
                                              new Flexible(
                                                  child: TextFormField(
                                                decoration:
                                                    const InputDecoration(
                                                        hintText:
                                                            "학교 명을 입력하세요."),
                                                controller:
                                                    searchSchoolController,
                                              )),
                                              FlatButton(
                                                onPressed: () async {
                                                  var tmp = await getSchoolList(
                                                      searchSchoolController
                                                          .text,
                                                      _edu,
                                                      _school);
                                                  //for (var s in tmp) toast(s.code);
                                                  //tmp = [];
                                                  _setState(() {
                                                    _schools = tmp;
                                                    if (tmp.isEmpty) {
                                                      _select_school_code = "";
                                                      toast("검색 결과가 없습니다.");
                                                    } else
                                                      _select_school_code =
                                                          tmp[0].code;
                                                  });
                                                },
                                                child: Icon(Icons.search),
                                                minWidth: 0,
                                                height: 0,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                padding: EdgeInsets.all(3),
                                              )
                                            ]),
                                            Divider(
                                              color: Colors.black38,
                                              height: 50,
                                              thickness: 1,
                                              indent: 0,
                                              endIndent: 0,
                                            ),
                                            //Text("검색 결과")
                                            DropdownButton<String>(
                                              icon: Icon(
                                                  Icons.keyboard_arrow_down),
                                              items: _schools
                                                  .map<
                                                      DropdownMenuItem<
                                                          String>>((school) =>
                                                      DropdownMenuItem(
                                                        child:
                                                            Text(school.name),
                                                        value: school.code,
                                                      ))
                                                  .toList(),
                                              onChanged: (String value) {
                                                _setState(() {
                                                  _select_school_code = value;
                                                });
                                              },
                                              value: _select_school_code,
                                              iconSize: 24,
                                              elevation: 16,
                                              //style: TextStyle(color: Colors.deepOrange),
                                              underline: Container(
                                                height: 2,
                                                //color: Colors.deepOrange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text('선택'),
                                          onPressed: () {
                                            if (_select_school_code.isEmpty) {
                                              toast("학교를 선택해주세요.");
                                              return;
                                            }
                                            widget.data.school =
                                                _select_school_code;
                                            widget.data.edu = URL_LIST[_edu];
                                            widget.writeJSON();
                                            setState(() {
                                              widget.schoolController.text =
                                                  _select_school_code;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('닫기'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  });
                                },
                              );
                            },
                            minWidth: 0,
                            height: 0,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.all(3),
                          ),
                        ],
                      ),
                      //new Navigator; 교육청 선택 구현
                      Visibility(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
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
                        visible: !this.widget.data.force,
                      ),
                      CheckboxListTile(
                        title: const Text('비밀번호 없이 설문 제출'),
                        value: this.widget.data.force,
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
                                          Text('비밀번호 없이 설문을 제출할 수 있습니다.'),
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
                                          this.widget.passwordController.text =
                                              "";

                                          setState(() {
                                            this.widget.data.force = true;
                                            this.widget.writeJSON();
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
                              this.widget.data.force = false;
                              this.widget.writeJSON();
                            }
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('앱 시작 시 자가진단 제출'),
                        value: this.widget.data.startup,
                        onChanged: (bool value) {
                          setState(() {
                            if (value) {
                              showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('알림'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text('앱 시작 시 자가진단 설문을 제출합니다.'),
                                          Text('특정 시각마다 제출하는 기능은 계획 중에 있습니다.'),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('계속하기'),
                                        onPressed: () {
                                          Navigator.of(context).pop();

                                          setState(() {
                                            this.widget.data.startup = true;
                                            this.widget.writeJSON();
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
                              this.widget.data.startup = false;
                              this.widget.writeJSON();
                            }
                          });
                        },
                      ),
                    ],
                  )),
            ]),
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
                      var appVer = (await PackageInfo.fromPlatform()).version,
                          first = false;
                      var newVer = "불러오는 중";

                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                              builder: (context, StateSetter _setState) {
                            if (!first) {
                              http
                                  .get(
                                      "https://api.github.com/repos/eduro-hcs/jaga_jindan/releases/latest")
                                  .then((data) {
                                try {
                                  _setState(() {
                                    newVer = jsonDecode(data.body)["tag_name"];
                                    newVer = newVer.substring(1);
                                  });
                                } catch (e) {
                                  newVer = "(error)";
                                }
                              });
                              first = true;
                            }

                            return AlertDialog(
                              title: Text('설정 및 정보'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    CheckboxListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: const Text('자가진단 결과 알림으로 받기'),
                                        value: this.widget.data.noti,
                                        onChanged: (bool value) {
                                          _setState(() {
                                            this.widget.data.noti = value;
                                            this.widget.writeJSON();
                                          });
                                        }),
                                    Divider(
                                      color: Colors.black38,
                                      height: 50,
                                      thickness: 1,
                                      indent: 0,
                                      endIndent: 0,
                                    ),
                                    Row(children: [
                                      Text("개발자: "),
                                      InkWell(
                                        child: Text(
                                          "엔로그 (nnnlog)",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                        onTap: () => launch(
                                            "https://github.com/nnnlog/"),
                                      )
                                    ]),
                                    Row(children: [
                                      Text("Repository: "),
                                      InkWell(
                                        child: Text(
                                          "jaga_jindan",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                        onTap: () => launch(
                                            "https://github.com/eduro-hcs/jaga_jindan"),
                                      )
                                    ]),
                                    Row(children: [
                                      Text("앱 버전: "),
                                      InkWell(
                                        child: Text(
                                          appVer,
                                          style: TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                        onTap: () => launch(
                                            "https://github.com/eduro-hcs/jaga_jindan/releases/tag/v${appVer}"),
                                      )
                                    ]),
                                    Row(children: [
                                      Text("최신 버전: "),
                                      InkWell(
                                        child: Text(
                                          newVer,
                                          style: TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                        onTap: () => launch(
                                            "https://github.com/eduro-hcs/jaga_jindan/releases/tag/v${newVer}"),
                                      )
                                    ]),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('닫기'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                        },
                      );
                    },
                    child: Icon(Icons.settings),
                    tooltip: "설정 및 정보",
                  ),
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jaga_jindan/ui/MainPageState.dart';
import 'package:jaga_jindan/ui/component/searchSchool.dart';

JagaJindanForm(MainPageState state) {
  return Form(
      key: state.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("인증 정보 입력",
              style: TextStyle(
                  //color: Colors.black,
                  fontSize:
                      Theme.of(state.context).textTheme.headline4.fontSize)),
          new Padding(padding: EdgeInsets.only(bottom: 50)),
          TextFormField(
            decoration: const InputDecoration(hintText: "이름을 입력하세요."),
            validator: (value) {
              if (value.isEmpty) {
                return "이름을 입력하세요.";
              }
              return null;
            },
            onChanged: (text) {
              state.widget.data.name = text;
              state.widget.writeJSON();
            },
            controller: state.widget.nameController,
          ),
          TextFormField(
            onChanged: (text) {
              state.widget.data.birthday = text;
              state.widget.writeJSON();
            },
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(hintText: "생년월일을 입력하세요. (YYMMDD)"),
            validator: (value) {
              if (value.length != 6) {
                return "생년월일을 올바르게 입력하세요.";
              }
              return null;
            },
            controller: state.widget.birthdayController,
          ),
          Row(
            children: <Widget>[
              new Flexible(
                  child: new FocusScope(
                      node: new FocusScopeNode(),
                      canRequestFocus: false,
                      child: TextFormField(
                        decoration:
                            const InputDecoration(hintText: "학교를 선택하세요."),
                        controller: state.widget.schoolController,
                      ))),
              FlatButton(
                child: Icon(Icons.search),
                onPressed: () {
                  searchSchool(state);
                },
                minWidth: 0,
                height: 0,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.all(3),
              ),
            ],
          ),
          //new Navigator; 교육청 선택 구현
          Visibility(
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "비밀번호를 입력하세요."),
              obscureText: true,
              validator: (value) {
                if (value.length != 4) {
                  return "비밀번호 4자리를 입력하세요.";
                }
                return null;
              },
              onChanged: (text) {
                state.widget.data.password = text;
                state.widget.writeJSON();
              },
              controller: state.widget.passwordController,
            )
          ),
          CheckboxListTile(
            title: const Text('앱 시작 시 자가진단 제출'),
            value: state.widget.data.startup,
            onChanged: (bool value) {
              state.setState(() {
                if (value) {
                  showDialog<void>(
                    context: state.context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('알림'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('앱 시작 시 자가진단 설문을 제출합니다.'),
                              Text('특정 시각마다 제출하는 기능은 계획 중 입니다.'),
                              Text('설정에서 "매일 한 번만 자동 제출" 옵션을 활성화하면 매일 한 번만 제출할 수 있습니다.'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('계속하기'),
                            onPressed: () {
                              Navigator.of(context).pop();

                              state.setState(() {
                                state.widget.data.startup = true;
                                state.widget.writeJSON();
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
                  state.widget.data.startup = false;
                  state.widget.writeJSON();
                }
              });
            },
          ),
        ],
      ));
}

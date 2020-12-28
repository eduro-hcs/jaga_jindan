import 'package:flutter/material.dart';
import 'package:jaga_jindan/type/eduList.dart';
import 'package:jaga_jindan/ui/MainPageState.dart';
import 'package:jaga_jindan/util/notify.dart';
import 'package:jaga_jindan/util/school.dart';

searchSchool(MainPageState state) {
  state.schools = [];
  state.selectedSchoolCode = "";

  showDialog<void>(
    context: state.context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, StateSetter _setState) {
        return AlertDialog(
          title: Text('학교 검색'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                DropdownButton<String>(
                  icon: Icon(Icons.keyboard_arrow_down),
                  items: EDU_LIST.entries
                      .map<DropdownMenuItem<String>>((e) =>
                          DropdownMenuItem(child: Text(e.key), value: e.key))
                      .toList(),
                  onChanged: (String value) {
                    if (!(value is String)) return;
                    _setState(() {
                      state.edu = value;
                    });
                  },
                  value: state.edu,
                  iconSize: 24,
                  elevation: 16,
                  //style: TextStyle(color: Colors.deepOrange),
                  underline: Container(
                    height: 2,
                    //color: Colors.deepOrange,
                  ),
                ),
                DropdownButton<String>(
                  icon: Icon(Icons.keyboard_arrow_down),
                  items: {
                    '1': '유치원',
                    '2': '초등학교',
                    '3': '중학교',
                    '4': '고등학교',
                    '5': '특수학교'
                  }
                      .entries
                      .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                            child: Text(e.value),
                            value: e.key,
                          ))
                      .toList(),
                  onChanged: (String value) {
                    if (!(value is String)) return;
                    _setState(() {
                      state.school = value;
                    });
                  },
                  value: state.school,
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
                    decoration: const InputDecoration(hintText: "학교 명을 입력하세요."),
                    controller: state.searchSchoolController,
                  )),
                  FlatButton(
                    onPressed: () async {
                      var tmp = await getSchoolList(
                          state.searchSchoolController.text,
                          state.edu,
                          state.school);

                      //tmp = [];
                      _setState(() {
                        state.schools = tmp;
                        if (tmp.isEmpty) {
                          state.selectedSchoolCode = "";
                          toast("검색 결과가 없습니다.");
                        } else
                          state.selectedSchoolCode = tmp[0].code;
                      });
                    },
                    child: Icon(Icons.search),
                    minWidth: 0,
                    height: 0,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                  icon: Icon(Icons.keyboard_arrow_down),
                  items: state.schools
                      .map<DropdownMenuItem<String>>(
                          (school) => DropdownMenuItem(
                                child: Text(school.name),
                                value: school.code,
                              ))
                      .toList(),
                  onChanged: (String value) {
                    if (!(value is String)) return;
                    _setState(() {
                      state.selectedSchoolCode = value;
                    });
                  },
                  value: state.selectedSchoolCode,
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
                if (state.selectedSchoolCode.isEmpty) {
                  toast("학교를 선택해주세요.");
                  return;
                }
                state.widget.data.school = state.selectedSchoolCode;
                state.widget.data.edu = URL_LIST[state.edu].toString();
                state.widget.writeJSON();
                state.setState(() {
                  state.widget.schoolController.text = state.selectedSchoolCode;
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
}

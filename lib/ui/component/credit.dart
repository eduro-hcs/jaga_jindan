import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jaga_jindan/ui/MainPageState.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

showCredit(MainPageState state) async {
  var appVer = (await PackageInfo.fromPlatform()).version, first = false;
  var newVer = "불러오는 중";

  showDialog<void>(
    context: state.context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, StateSetter _setState) {
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
                    value: state.widget.data.useNotification,
                    onChanged: (bool value) {
                      _setState(() {
                        state.widget.data.useNotification = value;
                        state.widget.writeJSON();
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
                          decoration: TextDecoration.underline),
                    ),
                    onTap: () => launch("https://github.com/nnnlog/"),
                  )
                ]),
                Row(children: [
                  Text("Repository: "),
                  InkWell(
                    child: Text(
                      "jaga_jindan",
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    ),
                    onTap: () =>
                        launch("https://github.com/eduro-hcs/jaga_jindan"),
                  )
                ]),
                Row(children: [
                  Text("앱 버전: "),
                  InkWell(
                    child: Text(
                      appVer,
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
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
                          decoration: TextDecoration.underline),
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
            ),
          ],
        );
      });
    },
  );
}

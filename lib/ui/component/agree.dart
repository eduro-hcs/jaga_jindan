import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jaga_jindan/ui/MainPageState.dart';

Future<void> agree(MainPageState page) async {
  if (!page.widget.data.agree) {
    await showDialog<void>(
      context: page.context,
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
            FlatButton(
              child: Text('동의'),
              onPressed: () {
                page.widget.data.agree = true;
                page.widget.writeJSON();
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
      if (!page.widget.data.agree) exit(0);
    });
  }
}

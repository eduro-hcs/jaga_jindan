import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:jaga_jindan/ui/MainPageState.dart';
import 'package:jaga_jindan/util/sendSurvey.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

showCredit(MainPageState state, String appVer, String newVer) async {
  showDialog<void>(
    context: state.context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, StateSetter _setState) {
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
                      if (!(value is bool)) return;
                      _setState(() {
                        state.widget.data.useNotification = value;
                        state.widget.writeJSON();
                      });
                    }),
                CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('매일 한 번만 자동 제출'),
                    value: state.widget.data.submitLimitation,
                    onChanged: (bool value) {
                      if (!(value is bool)) return;
                      _setState(() {
                        state.widget.data.submitLimitation = value;
                        state.widget.writeJSON();
                      });
                    }),
                CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('자동 제출 활성화'),
                    value: state.widget.data.autoSubmit,
                    onChanged: (bool value) {
                      if (!(value is bool)) return;
                      _setState(() {
                        state.widget.data.autoSubmit = value;
                        var tm = state.widget.data.submitTime =
                            tz.TZDateTime.now(tz.getLocation('Asia/Seoul'));
                        state.widget.timeController.text =
                            "${tm.hour < 10 ? '0' : ''}${tm.hour}:${tm.minute < 10 ? '0' : ''}${tm.minute}";

                        state.widget.writeJSON();
                      });

                      if (value)
                        setBackgroundProcess(state.widget.data);
                      else
                        BackgroundFetch.stop(SURVEY_TASK_ID);
                    }),
                Visibility(
                  child: Row(children: <Widget>[
                    new Flexible(
                        child: new FocusScope(
                            node: new FocusScopeNode(),
                            canRequestFocus: false,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  hintText: "자가진단 자동 제출 시간"),
                              controller: state.widget.timeController,
                            ))),
                    FlatButton(
                      child: Icon(Icons.alarm),
                      onPressed: () async {
                        final TimeOfDay picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              state.widget.data.submitTime),
                        );

                        _setState(() async {
                          var today =
                              tz.TZDateTime.now(tz.getLocation('Asia/Seoul'));

                          var tm = state.widget.data.submitTime =
                              tz.TZDateTime.from(
                                  new tz.TZDateTime(
                                      tz.getLocation('Asia/Seoul'),
                                      today.year,
                                      today.month,
                                      today.day,
                                      picked.hour,
                                      picked.minute),
                                  tz.getLocation('Asia/Seoul'));
                          state.widget.timeController.text =
                              "${tm.hour < 10 ? '0' : ''}${tm.hour}:${tm.minute < 10 ? '0' : ''}${tm.minute}";
                          await state.widget.writeJSON();

                          //setBackgroundProcess(state.widget.data);
                          backgroundFetchHeadlessTask(FB_TASK_ID);
                        });
                      },
                      minWidth: 0,
                      height: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.all(3),
                    ),
                  ]),
                  visible: state.widget.data.autoSubmit,
                ),
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
                        "https://github.com/eduro-hcs/jaga_jindan/releases/tag/v$appVer"),
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
                        "https://github.com/eduro-hcs/jaga_jindan/releases/tag/v$newVer"),
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

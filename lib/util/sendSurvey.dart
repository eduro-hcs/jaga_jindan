import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:http/http.dart' as http;
import 'package:jaga_jindan/type/JagaJindanData.dart';
import 'package:jaga_jindan/util/RSAEncrypt.dart';
import 'package:jaga_jindan/util/internalIO.dart';
import 'package:jaga_jindan/util/notify.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzInit;

const SURVEY_TASK_ID = "com.nlog.jaga_jindan.survey";
const FB_TASK_ID = "com.nlog.jaga_jindan.fb";

void backgroundFetchHeadlessTask(String taskId) async {
  await BackgroundFetch.stop(SURVEY_TASK_ID);

  try {
    await Future.any([
      initNotification(),
      Future.delayed(const Duration(seconds: 5))
    ]);

    tzInit.initializeTimeZones();

    var json = await readInternal();
    if (jsonEncode(json) == "{}") {
      throw new Error();
    }
    JagaJindanData dat = JagaJindanData.readFromJSON(json);

    if (dat != null) {
      if (dat.autoSubmit && taskId == SURVEY_TASK_ID) await sendSurvey(dat, true);
      await setBackgroundProcess(dat);
    }
  } catch (e) {
    noti("오류가 발생했습니다.", e.toString());
  } finally {
    BackgroundFetch.finish(taskId);
    await BackgroundFetch.stop(taskId);
    await BackgroundFetch.scheduleTask(TaskConfig(
        enableHeadless: true,
        startOnBoot: true,
        stopOnTerminate: false,
        forceAlarmManager: true,
        taskId: FB_TASK_ID,
        delay: (10 * 60 * 1000)));
  }
}

Future<void> setBackgroundProcess(JagaJindanData dat) async {
  var tm = dat.submitTime;
  if (tm == null || tm.minute == null || tm.hour == null) return;

  DateTime currTime = tz.TZDateTime.now(tz.getLocation('Asia/Seoul')),
      target = tm.add(Duration());

  if (target.isBefore(currTime)) {
    target = target.add(Duration(days: 1));
  }

  var diff = target.difference(currTime);

  //TODO: Task Id에 목표 시간 넣어서 중복 제출 방지, 현재로썬 최선인듯
  await BackgroundFetch.stop(SURVEY_TASK_ID);
  await BackgroundFetch.scheduleTask(TaskConfig(
      enableHeadless: true,
      startOnBoot: true,
      stopOnTerminate: false,
      forceAlarmManager: true,
      taskId: SURVEY_TASK_ID,
      delay: diff.inMilliseconds));
}

void showSurveyResult(
    bool success, String message, JagaJindanData credentials) {
  if (credentials.useNotification)
    noti(success ? "자가진단 제출을 성공하였습니다." : "자가진단 제출을 실패하였습니다.", message);
  else
    toast(message);
}

Future<void> sendSurvey(JagaJindanData credentials, [bool byAutomatic = false]) async {
  try {
    String jwt = jsonDecode((await http.post(
            'https://${credentials.edu}hcs.eduro.go.kr/v2/findUser',
            body: jsonEncode({
              'birthday': encrypt(credentials.birthday),
              'loginType': 'school',
              'name': encrypt(credentials.name),
              'orgCode': credentials.school,
              'stdntPNo': null
            }),
            headers: {'Content-Type': 'application/json'},
            encoding: Encoding.getByName('utf-8')))
        .body)['token'];

    if ((await http.post(
                'https://${credentials.edu}hcs.eduro.go.kr/v2/hasPassword',
                body: jsonEncode({}),
                headers: {
              'Authorization': jwt,
              'Content-Type': 'application/json'
            }))
            .body !=
        'true') {
      showSurveyResult(false, '자가진단 페이지에서 초기 비밀번호를 설정하세요.', credentials);
      return;
    }

    jwt = (await http.post(
            'https://${credentials.edu}hcs.eduro.go.kr/v2/validatePassword',
            body: jsonEncode(
                {'deviceUuid': '', 'password': encrypt(credentials.password)}),
            headers: {
          'Authorization': jwt,
          'Content-Type': 'application/json'
        }))
        .body;

    if (!jwt.contains('Bearer')) {
      showSurveyResult(false, '비밀번호를 잘못 입력했거나 로그인 시도 횟수를 초과했습니다.', credentials);
      return;
    }
    jwt = jwt.replaceAll('"', "");

    var users = jsonDecode((await http.post(
            'https://${credentials.edu}hcs.eduro.go.kr/v2/selectUserGroup',
            body: jsonEncode({}),
            headers: {
          'Authorization': jwt,
          'Content-Type': 'application/json'
        }))
        .body);

    jwt = users[0]['token'];

    var userNo = int.parse(users[0]['userPNo']);
    String org = users[0]['orgCode'];

    var userInfo = jsonDecode((await http.post(
            'https://${credentials.edu}hcs.eduro.go.kr/v2/getUserInfo',
            body: jsonEncode({'userPNo': userNo, 'orgCode': org}),
            headers: {
          'Authorization': jwt,
          'Content-Type': 'application/json'
        }))
        .body);

    if (userInfo["registerDtm"] != null) {
      var submittedDate = DateTime.parse(userInfo["registerDtm"]);

      if (submittedDate.day == DateTime.now().day &&
          byAutomatic &&
          credentials.submitLimitation) {
        showSurveyResult(false, "이미 제출한 기록이 있어 자동 제출을 취소했습니다.", credentials);
        return;
      }
    }

    jwt = userInfo['token'];

    var res = await http.post(
        'https://${credentials.edu}hcs.eduro.go.kr/registerServey',
        body: jsonEncode({
          'deviceUuid': '',
          'rspns00': 'Y',
          'rspns01': '1',
          'rspns02': '1',
          'rspns03': null,
          'rspns04': null,
          'rspns05': null,
          'rspns06': null,
          'rspns07': null,
          'rspns08': null,
          'rspns09': '0',
          'rspns10': null,
          'rspns11': null,
          'rspns12': null,
          'rspns13': null,
          'rspns14': null,
          'rspns15': null,
          'upperToken': jwt,
          'upperUserNameEncpt': userInfo['userNameEncpt']
        }),
        headers: {'Authorization': jwt, 'Content-Type': 'application/json'});

    showSurveyResult(
        true,
        "자가진단 설문이 ${DateTime.now().toString().substring(0, 19)}에 제출되었습니다.",
        credentials);
  } catch (e, s) {
    showSurveyResult(
        false, "인증 정보를 한번 더 확인해주세요.\n오류가 계속 발생하는 경우 개발자에게 알려주세요.", credentials);
  }
}

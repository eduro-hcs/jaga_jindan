import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'package:jaga_jindan/edu_list.dart';
import 'package:jaga_jindan/send_survey.dart';

class School {
  String name, address, code;

  School(this.name, this.address, this.code);

  @override
  String toString() {
    return "${name}<${address}>($code)";
  }
}

/*
schulCrseScCode: 학교 종류 코드
  1 유치원
  2 초등학교
  3 중학교
  4 고등학교
  5 특수학교
*/
Future<List<School>> getSchoolList(
    String name, String region, String schulCrseScCode) async {
  try {
    var res = jsonDecode((await http.get(
        Uri.https("hcs.eduro.go.kr", "/school", {
          'lctnScCode': EDU_LIST[region],
          'schulCrseScCode': schulCrseScCode,
          'orgName': name,
          'currentPageNo': '1'
        })))
        .body);

    if (res["sizeover"]) toast("검색 결과가 많습니다.\n학교 이름을 정확히 입력해주세요.");
    List<School> ret = [];
    for (var i in res["schulList"]) {
      ret.add(School(i["kraOrgNm"], i["addres"], i["orgCode"]));
    }
    return ret;
  } catch (e) {
    return [];
  }

}

import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'package:jaga_jindan/edu_list.dart';

class School {
  String name, address, code;

  School(this.name, this.address, this.code);
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
  var res = jsonDecode((await http.get(
          Uri.http("hcs.eduro.go.kr", "/school", {
            'lctnScCode': EDU_LIST[region],
            'schulCrseScCode': schulCrseScCode,
            'orgName': name,
            'currentPageNo': '1'
          }),
          headers: {'Content-Type': 'application/json'}))
      .body);

  List<School> ret = [];
  for (var i in res["schulList"]) {
    ret.add(School(i["kraOrgNm"], i["addres"], i["orgCode"]));
  }

  return ret;
}

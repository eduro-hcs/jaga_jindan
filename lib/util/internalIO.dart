import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

writeInternal(dynamic json) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/cred.json');
  await file.writeAsString(jsonEncode(json));
}

Future<dynamic> readInternal() async {
  dynamic json;
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/cred.json');
    json = jsonDecode(await file.readAsString());
  } catch (e) {
    json = {};
  }
  return json;
}

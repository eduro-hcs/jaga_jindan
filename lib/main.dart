import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:jaga_jindan/ui/MainPage.dart';
import 'package:jaga_jindan/util/notify.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  timeDilation = 2.0;
  tz.initializeTimeZones();
  runApp(MyApp());
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
      debugShowCheckedModeBanner: false,
    );
  }
}

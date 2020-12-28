import 'package:timezone/standalone.dart' as tz;

class JagaJindanData {
  String name, birthday, school, edu, password;
  bool agree = false,
      startup = false,
      useNotification = false,
      submitLimitation = false;
  tz.TZDateTime submitTime;

  static JagaJindanData readFromJSON(dynamic json) {
    var tm;
    try {
      tm = tz.TZDateTime.parse(tz.getLocation('Asia/Seoul'), json["submitTime"]);
    } catch (e) {}
    return new JagaJindanData(
        json["name"] ?? "",
        json["birthday"] ?? "",
        json["school"] ?? "",
        json["edu"] ?? "",
        json["password"] ?? "",
        json["agree"] ?? false,
        json["startup"] ?? false,
        json["noti"] ?? false,
        json["submitLimitation"] ?? false,
        tm);
  }

  JagaJindanData(
      this.name,
      this.birthday,
      this.school,
      this.edu,
      this.password,
      this.agree,
      this.startup,
      this.useNotification,
      this.submitLimitation,
      this.submitTime);

  dynamic toJSON() {
    return {
      "name": this.name,
      "birthday": this.birthday,
      "school": this.school,
      "edu": this.edu,
      "password": this.password,
      "agree": this.agree,
      "startup": this.startup,
      "noti": this.useNotification,
      "submitLimitation": this.submitLimitation,
      "submitTime": this.submitTime?.toString()
    };
  }
}

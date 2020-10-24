class JagaJindanData {
  String name, birthday, school, edu, password;
  bool force, agree = false, startup = false, useNotification = false;

  static JagaJindanData readFromJSON(dynamic json) {
    return new JagaJindanData(
        json["name"] ?? "",
        json["birthday"] ?? "",
        json["school"] ?? "",
        json["edu"] ?? "",
        json["password"] ?? "",
        json["force"] ?? false,
        json["agree"] ?? false,
        json["startup"] ?? false,
        json["noti"] ?? false);
  }

  JagaJindanData(this.name, this.birthday, this.school, this.edu, this.password,
      this.force, this.agree, this.startup, this.useNotification);

  dynamic toJSON() {
    return {
      "name": this.name,
      "birthday": this.birthday,
      "school": this.school,
      "edu": this.edu,
      "password": this.password,
      "force": this.force,
      "agree": this.agree,
      "startup": this.startup,
      "noti": this.useNotification
    };
  }
}

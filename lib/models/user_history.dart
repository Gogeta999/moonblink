class UserHistory {
  List<String> data;

  UserHistory({this.data});

  factory UserHistory.fromJson(Map<String, dynamic> json) {
    var dataJson = json['data'];

    List<String> dataList = dataJson.cast<String>();

    return UserHistory(data: dataList);
  }
}

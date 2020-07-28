import 'package:moonblink/models/transaction.dart';

class UserHistory {
  List<Transaction> data;

  UserHistory({this.data});

  factory UserHistory.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataJson = json['data'];

    List<Transaction> dataList =
        dataJson.map((e) => Transaction.fromJson(e)).toList();

    return UserHistory(data: dataList);
  }
}

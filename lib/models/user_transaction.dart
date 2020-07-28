import 'package:moonblink/models/transaction.dart';

class UserTransaction {
  List<Transaction> data;

  UserTransaction({this.data});

  factory UserTransaction.fromJson(Map<String, dynamic> json){
    List<dynamic> dataJson = json['data'];

    List<Transaction> dataList =  dataJson.map((e) => Transaction.fromJson(e)).toList();

    return UserTransaction(data: dataList);
  }
}
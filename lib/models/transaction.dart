///Used by both UserHistory and UserTransaction
class Transaction {
  final String transaction;
  final String date;

  Transaction({this.transaction, this.date});

  Transaction.fromJson(Map<String, dynamic> json)
      : transaction = json['transaction'],
        date = json['date'];
}

import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String description;
  final String currencyCode;
  final int value;
  final int mbCoin;

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        currencyCode = json['currency_code'],
        value = json['value'],
        mbCoin = json['mb_coin'];

  @override
  List<Object> get props => [id];
}

import 'package:equatable/equatable.dart';
import 'package:moonblink/models/payments/product.dart';

class Payment extends Equatable {
  final int id;
  final int userId;
  final String payWith;
  final int status;
  final List<String> transactionImage;
  final String updatedBy;
  final String createdAt;
  final String updatedAt;
  final String note;
  final String description;
  final int transferAmount;
  final Product item;

  Payment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        payWith = json['pay_with'],
        status = json['status'],
        transactionImage =
            json['transaction_image'].map<String>((e) => e.toString()).toList(),
        updatedBy = json['updated_by'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        description = json['description'],
        transferAmount = json['transfer_amount'],
        note = json['note'],
        item = Product.fromJson(json['item']);

  @override
  List<Object> get props => [id];
}

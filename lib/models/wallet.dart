class Wallet {
  final int id;
  final int userId;
  final int value;
  final String createdAt;
  final String updatedAt;

  Wallet({this.id, this.userId, this.value, this.createdAt, this.updatedAt});

  Wallet.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        value = json['value'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'value': value,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  @override
  String toString() => 'id: $id, userId: $userId, value: $value, createdAt: $createdAt, updatedAt: $updatedAt';
}

import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String userName;
  final String createdAt;
  final int updatedAt;
  int reactionCount;
  final String profileImage;
  final String coverImage;
  int isReacted;
  final int type;
  final String bios;
  final String gender;
  final int status;
  final int vip;

  Post.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userName = json['name'],
        createdAt = json['created_at'],
        updatedAt = DateTime.parse(json['updated_at']).millisecondsSinceEpoch,
        reactionCount = json['reaction_count'],
        profileImage = json['profile_image'],
        coverImage = json['cover_image'],
        isReacted = json['is_reacted'],
        type = json['type'],
        bios = json['bios'],
        gender = json['gender'] ?? "",
        status = json['status'],
        vip = json['vip'];

  Post.fromMap(Map<String, dynamic> json)
      : id = json['id'],
        userName = json['name'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        reactionCount = json['reaction_count'],
        profileImage = json['profile_image'],
        coverImage = json['cover_image'],
        isReacted = json['is_reacted'],
        type = json['type'],
        bios = json['bios'],
        gender = json['gender'] ?? "",
        status = json['status'],
        vip = json['vip'];

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': userName,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'reaction_count': reactionCount,
        'profile_image': profileImage,
        'cover_image': coverImage,
        'is_reacted': isReacted,
        'type': type,
        'bios': bios,
        'gender': gender,
        'status': status,
        'vip': vip
      };

  @override
  List<Object> get props =>
      [id, userName, coverImage, profileImage, gender, type];
}

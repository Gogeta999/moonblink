import 'package:equatable/equatable.dart';

class NFPost extends Equatable {
  final int id;
  final int userId;
  final String body;
  final List<Media> media;
  final int status;
  final String createdAt;
  final String updatedAt;
  final int reactionCount;
  final String name;
  final String profile;
  final int isReacted;
  final String bios;
  final String lastComment;
  final String lastCommenterName;
  final String lastCommenterProfileImage;

  NFPost.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        body = json['body'],
        media = json['media'].map<Media>((e) => Media(e.toString())).toList(),
        status = json['status'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        reactionCount = json['reaction_count'],
        name = json['user']['name'],
        profile = json['user']['profile_image'],
        isReacted = json['is_reacted'],
        bios = json['user']['bios'],
        lastComment =
            json['last_comment'] == null ? "" : json['last_comment']['message'],
        lastCommenterName = json['last_comment'] == null
            ? ""
            : json['last_comment']['user']['name'],
        lastCommenterProfileImage = json['last_comment'] == null
            ? ""
            : json['last_comment']['user']['profile_image'];

  ///for sqflite
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'body': body,
        'media': media.join(', '),
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'reaction_count': reactionCount,
        'user_name': name,
        'profile_image': profile,
        'is_reacted': isReacted,
        'bios': bios,
        'last_comment': lastComment,
        'last_commenter_name': lastCommenterName,
        'last_commenter_profile_image': lastCommenterProfileImage
      };

  NFPost.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        userId = map['user_id'],
        body = map['body'],
        media = map['media'].split(', '),
        status = map['status'],
        createdAt = map['created_at'],
        updatedAt = map['updated_at'],
        reactionCount = map['reaction_count'],
        name = map['user_name'],
        profile = map['profile_image'],
        isReacted = map['is_reacted'],
        bios = map['bios'],
        lastComment = map['last_comment'],
        lastCommenterName = map['last_commenter_name'],
        lastCommenterProfileImage = map['last_commenter_profile_image'];

  @override
  List<Object> get props => [id];
}

class Media {
  final String url;
  double height = 300.0;

  Media(this.url);
}

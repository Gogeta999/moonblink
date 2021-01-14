import 'package:equatable/equatable.dart';

class NFComment extends Equatable {
  final int commentId;
  final int postId;
  final int userId;
  final String message;
  final String media;
  //final List<String> media;
  final int parentCommentId;
  final String createdAt;
  final String updatedAt;
  final List<NFReply> reply;
  final String username;
  final String userProfileImage;

  NFComment.fromJson(Map<String, dynamic> json)
    : commentId = json['id'],
      postId = json['post_id'],
      userId = json['user_id'],
      message = json['message'],
      //media = json['media'].map<String>((e) => e.toString()).toList(),
      media = json['media'],
      parentCommentId = json['parent_comment_id'],
      createdAt = json['created_at'],
      updatedAt = json['updated_at'],
      reply = json['reply'].map<NFReply>((e) => NFReply.fromjson(e)).toList(),
      username = json['user']['name'],
      userProfileImage = json['user']['profile_image'];


  @override
  List<Object> get props => [commentId];
}

class NFReply extends Equatable {

  final int commentId;
  final int postId;
  final int userId;
  final String message;
  final String media;
  final int parentCommentId;
  final String createdAt;
  final String updatedAt;
  final String username;
  final String userProfileImage;

  NFReply.fromjson(Map<String, dynamic> json)
    : commentId = json['id'],
      postId = json['post_id'],
      userId = json['user_id'],
      message = json['message'],
      media = json['media'],
      parentCommentId = json['parent_comment_id'],
      createdAt = json['created_at'],
      updatedAt = json['updated_at'],
      username = json['user']['name'],
      userProfileImage = json['user']['profile_image'];


  @override
  List<Object> get props => [commentId];
}
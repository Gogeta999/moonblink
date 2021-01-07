import 'package:equatable/equatable.dart';

class NFComment extends Equatable {
  final int id;
  final int postId;
  final int userId;
  final String message;
  final String media;
  //final List<String> media;
  final int parentCommentId;
  final String createdAt;
  final String updatedAt;
  final String username;
  final String userEmail;
  final int userType;
  final int userStatus;
  final String userProfileImage;

  NFComment.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      postId = json['post_id'],
      userId = json['user_id'],
      message = json['message'],
      //media = json['media'].map<String>((e) => e.toString()).toList(),
      media = json['media'],
      parentCommentId = json['parent_comment_id'],
      createdAt = json['created_at'],
      updatedAt = json['updated_at'],
      username = json['user']['name'],
      userEmail = json['user']['email'],
      userType = json['user']['type'],
      userStatus = json['user']['status'],
      userProfileImage = json['user']['profile_image'];


  @override
  List<Object> get props => [id];
}
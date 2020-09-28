class UserRatingList {
  final List<UserRating> userRatingList;

  UserRatingList({this.userRatingList});

  factory UserRatingList.fromJson(List<dynamic> jsonList) {
    List<UserRating> userRatingList = jsonList.map((e) => UserRating.fromJson(e)).toList();

    return UserRatingList(userRatingList: userRatingList);
  }
}

class UserRating {
  final int id;
  final int bookingId;
  final int ratingUserId;
  final double star;
  final String comment;
  final String createdAt;
  final String updatedAt;
  final String name;
  final String profileImage;

  UserRating.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      bookingId = json['booking_id'],
      ratingUserId = json['rating_user_id'],
      star = double.tryParse(json['star']),
      comment = json['comment'],
      createdAt = json['created_at'],
      updatedAt = json['updated_at'],
      name = json['name'],
      profileImage = json['profile_image'];
}
class BookingStatus {
  final int bookingId;
  final int userId;
  final int booingUserId;
  final int status;
  final int count;
  final String createdAt;
  final String updatedAt;
  final int minutePerSection;
  final int isBlock;

  BookingStatus.fromJson(Map<String, dynamic> json)
    : bookingId = json['booking_id'],
      userId = json['user_id'],
      booingUserId = json['booking_user_id'],
      status = json['status'],
      count = json['count'],
      createdAt = json['created_at'],
      updatedAt = json['updated_at'],
      minutePerSection = json['minute_per_section'],
      isBlock = json['is_block'];
}
class LastBoostOrder {
  final int boostOrderId;
  final int userId;
  final int bookingUserId;
  final String rankFrom;
  final String upToRank;
  final int estimateDay;
  final int estimateHour;
  final int estimateCost;
  final String startTime;
  final String endTime;
  final int status;
  final String createdAt;
  final String updatedAt;

  LastBoostOrder.fromJson(Map<String, dynamic> json)
    : boostOrderId = json['boost_order_id'],
      userId = json['user_id'],
      bookingUserId = json['booking_user_id'],
      rankFrom = json['rank_from'],
      upToRank = json['up_to_rank'],
      estimateDay = json['estimate_day'],
      estimateHour = json['estimate_hour'],
      estimateCost = json['estimate_cost'],
      startTime = json['start_time'],
      endTime = json['end_time'],
      status = json['status'],
      createdAt = json['created_at'],
      updatedAt = json['updated_at'];
}
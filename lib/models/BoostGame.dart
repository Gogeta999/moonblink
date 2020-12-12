class BoostGame {
  final int userId;
  final int gameId;
  final String rankFrom;
  final String upToRank;
  int estimateCost;
  int estimateHour;
  int estimateDay;
  final String message;
  final int isAccept;

  BoostGame.fromJson(Map<String, dynamic> json)
    : userId = json['user_id'],
      gameId = json['game_id'],
      rankFrom = json['rank_from'],
      upToRank = json['up_to_rank'],
      estimateCost = json['estimate_cost'],
      estimateHour = json['estimate_hour'],
      estimateDay = json['estimate_day'],
      message = json['message'],
      isAccept = json['is_accept'];
  
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'game_id': gameId,
    'rank_from': rankFrom,
    'up_to_rank': upToRank,
    'estimate_cost': estimateCost,
    'estimate_hour': estimateHour,
    'estimate_day': estimateDay,
    'message': message,
    'is_accept': isAccept
  };
}
class UserBoostingGamePrice {
  final int id;
  final String name;
  final String type;
  final String gameIcon;
  final String description;
  final List<String> levels;
  final String createdAt;
  final String updatedAt;
  final String gameProfileSample;
  final int isBoostable;
  final List<UserBoostGame> boostOrderPrice;

  UserBoostingGamePrice.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      type = json['type'],
      gameIcon = json['game_icon'],
      description = json['description'],
      levels = json['levels'].map<String>((e) => e.toString()).toList(),
      createdAt = json['created_at'],
      updatedAt = json['updated_at'],
      gameProfileSample = json['game_profile_sample'],
      isBoostable = json['is_boostable'],
      boostOrderPrice = json['boost_order_price'].map<UserBoostGame>((e) => UserBoostGame.fromJson(e)).toList();
}

class UserBoostGame {
  final int id;
  final int userId;
  final int gameId;
  final String rankFrom;
  final String upToRank;
  int estimateCost;
  int estimateHour;
  int estimateDay;
  final int isAccept;

  UserBoostGame.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      userId = json['user_id'],
      gameId = json['game_id'],
      rankFrom = json['rank_from'],
      upToRank = json['up_to_rank'],
      estimateCost = json['estimate_cost'],
      estimateHour = json['estimate_hour'],
      estimateDay = json['estimate_day'],
      isAccept = json['is_accept'];
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'game_id': gameId,
    'rank_from': rankFrom,
    'up_to_rank': upToRank,
    'estimate_cost': estimateCost,
    'estimate_hour': estimateHour,
    'estimate_day': estimateDay,
    'is_accept': isAccept
  };
}
import 'dart:convert';

class GameProfile {
  final int id;
  final int userId;
  final int gameId;
  final String gameName;
  final String playerId;
  final String level;
  final String skillCoverImage;
  final String aboutOrderTaking;
  final int isPlay;
  List<GameMode> gameModeList;
  List<String> gameRankList;
  final String gameProfileSample;
  final String createdAt;
  final String updatedAt;

  GameProfile(
      {this.id,
      this.userId,
      this.gameId,
      this.gameName,
      this.playerId,
      this.level,
      this.skillCoverImage,
      this.aboutOrderTaking,
      this.isPlay,
      this.gameModeList,
      this.gameRankList,
      this.gameProfileSample,
      this.createdAt,
      this.updatedAt});

  GameProfile.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        gameId = json['game_id'],
        gameName = json['game_name'],
        playerId = json['player_id'],
        level = json['level'],
        skillCoverImage = json['skill_cover_image'],
        aboutOrderTaking = json['about_order_taking'],
        isPlay = json['is_play'],
        gameModeList = List.unmodifiable(
            json['types'].map<GameMode>((e) => GameMode.fromJson(e)).toList()),
        gameRankList = json['levels'].map<String>((e) => e.toString()).toList(),
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        gameProfileSample = json['game_profile_sample'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'game_id': gameId,
        'game_name': gameName,
        'player_id': playerId,
        'level': level,
        'skill_cover_image': skillCoverImage,
        'about_order_taking': aboutOrderTaking,
        'is_play': isPlay,
        'types':
            gameModeList.map<Map<String, dynamic>>((e) => e.toJson()).toList(),
        'levels': gameRankList.map<String>((e) => jsonEncode(e)).toList(),
        'game_profile_sample': gameProfileSample,
        'created_at': createdAt,
        'updated_at': updatedAt
      };
}

class GameMode {
  final int id;
  final int gameId;

  ///json name type but it's actually game mode
  final String mode;
  final int price;
  final String createdAt;
  final String updatedAt;
  final int timeInMinute;
  final int defaultPrice;
  final int selected;

  ///this data won't need at booking

  GameMode(
      {this.id,
      this.gameId,
      this.mode,
      this.price,
      this.createdAt,
      this.updatedAt,
      this.timeInMinute,
      this.defaultPrice,
      this.selected});

  GameMode.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        gameId = json['game_id'],
        mode = json['type'],
        price = json['price'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        timeInMinute = json['time_in_minute'],
        defaultPrice = json['default_price'],
        selected = json['selected'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'game_id': gameId,
        'type': mode,
        'price': price,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'time_in_minute': timeInMinute,
        'default_price': defaultPrice,
        'selected': selected
      };
}

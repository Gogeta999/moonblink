import 'package:moonblink/models/game_profile.dart';

class UserPlayGameList {
  final List<UserPlayGame> userPlayGameList;

  UserPlayGameList({this.userPlayGameList});

  factory UserPlayGameList.fromJson(List<dynamic> game) {
    List<UserPlayGame> userPlayGameList =
        game.map((e) => UserPlayGame.fromJson(e)).toList();

    return UserPlayGameList(userPlayGameList: userPlayGameList);
  }

  @override
  String toString() => 'userPlayGameList: ${userPlayGameList[0].name}';
}

class UserPlayGame {
  final int id;
  final String name;
  final String type;
  final String gameIcon;
  final String description;
  final String createdAt;
  final String updatedAt;
  final int isPlay;
  final int isBoostable;
  final GameProfile gameProfile;

  UserPlayGame(
      {this.id,
      this.name,
      this.type,
      this.gameIcon,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.isPlay,
      this.isBoostable,
      this.gameProfile});

  UserPlayGame.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        type = json['type'],
        gameIcon = json['game_icon'],
        description = json['description'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        isPlay = json['is_play'],
        isBoostable = json['is_boostable'],
        gameProfile = GameProfile.fromJson(json['game_profile']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'game_icon': gameIcon,
        'description': description,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'is_play': isPlay,
        'is_boostable': isBoostable,
        'game_profile': gameProfile.toJson()
      };
}

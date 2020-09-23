class GameList {
  final List<Game> gameList;

  GameList({this.gameList});

  factory GameList.fromJson(List<dynamic> game) {
    List<Game> gameList = game.map((e) => Game.fromJson(e)).toList();

    return GameList(gameList: gameList);
  }

  @override
  String toString() => 'gameList: ${gameList[0].gameType}';
}

///GameId and GameTypeId only can get from dev server.
class Game {
  final int gameId;
  final int gameTypeId;
  final String gameType;
  final int price;
  final String icon;

  Game({this.gameId, this.gameTypeId, this.gameType, this.price, this.icon});

  Game.fromJson(Map<String, dynamic> json)
      : gameId = json['game_id'],
        gameTypeId = json['game_type_id'],
        gameType = json['game_type'],
        price = json['price'],
        icon = json['icon'];

  Map<String, dynamic> toJson() => {
        'game_id': gameId,
        'game_type_id': gameTypeId,
        'game_type': gameType,
        'price': price,
        'icon': icon
      };
}

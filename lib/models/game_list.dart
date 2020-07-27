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

class Game {
  final String gameType;
  final String price;

  Game({this.gameType, this.price});

  Game.fromJson(Map<String, dynamic> json)
      : gameType = json['game_type'],
        price = json['price'];

  Map<String, dynamic> toJson() => {
    'game_type': gameType,
    'price': price
  };
}
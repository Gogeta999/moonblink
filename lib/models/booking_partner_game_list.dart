class BookingPartnerGameList {
  final List<_BookingPartnerGame> bookingPartnerGameList;

  BookingPartnerGameList({this.bookingPartnerGameList});

  factory BookingPartnerGameList.fromJson(List<dynamic> game) {
    List<_BookingPartnerGame> list =
        game.map((e) => _BookingPartnerGame.fromJson(e)).toList();

    return BookingPartnerGameList(
        bookingPartnerGameList: List.unmodifiable(list));
  }

  @override
  String toString() => 'gameList: ${bookingPartnerGameList[0].name}';
}

class _BookingPartnerGame {
  final int id;
  final String name;
  final String type;
  final String gameIcon;
  final String description;
  final String levels;
  final String createdAt;
  final String updatedAt;
  final List<_BookingPartnerGameMode> gameModeList;

  _BookingPartnerGame.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        type = json['type'],
        gameIcon = json['game_icon'],
        description = json['description'],
        levels = json['levels'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        gameModeList = List.unmodifiable(json['types']
            .map<_BookingPartnerGameMode>(
                (e) => _BookingPartnerGameMode.fromJson(e))
            .toList());
}

class _BookingPartnerGameMode {
  final int id;
  final int userId;
  final int gameId;
  final int gameTypeId;
  final int bookingPrice;
  final String gameMode;

  _BookingPartnerGameMode.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        gameId = json['game_id'],
        gameTypeId = json['game_type_id'],
        bookingPrice = json['booking_price'],
        gameMode = json['type'];
}

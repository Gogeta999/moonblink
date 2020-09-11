import 'package:moonblink/models/game_list.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class BookingModel extends ViewStateModel {
  int selectedIndex = 0;

  Wallet wallet = Wallet(value: 0);
  List<String> dropdownGameList = [];
  List<String> dropdownGamePrice = [];
  List<String> dropdownGameListAndPrice = [];
  List<Game> gamesList = [];

  Future<bool> booking(int partnerId, int gameType) async {
    //await MoonBlinkRepository.booking(partnerId, gameType);
  }

  Future<void> initData(partnerId) async {
    setBusy();
    try {
      await _getUserWallet();
      await _getGameList(partnerId);
      notifyListeners();
      setIdle();
    } catch (e, s) {
      setIdle();
      setError(e, s);
    }
  }

  ///get user wallet
  Future<void> _getUserWallet() async {
    try {
      Wallet wallet = await MoonBlinkRepository.getUserWallet();
      this.wallet = wallet;
    } catch (e, s) {
      setError(e, s);
    }
  }

  ///get game list
  Future<void> _getGameList(partnerId) async {
    try {
      GameList gameList = await MoonBlinkRepository.getGameList(partnerId);
      gameList.gameList.forEach((game) {
        // dropdownGameList.add(game.gameType);
        // dropdownGamePrice.add(game.price);
        dropdownGameListAndPrice.add('${game.gameType}.${game.price}');
        gamesList.add(game);
      });
      print(gameList);
    } catch (e, s) {
      setError(e, s);
    }
  }
}

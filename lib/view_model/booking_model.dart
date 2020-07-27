import 'package:moonblink/models/game_list.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class BookingModel extends ViewStateModel{
  int selectedIndex = 0;

  Wallet wallet = Wallet();
  //List<String> dropdownGameList = [];
  //List<String> dropdownGamePrice = [];
  List<String> dropdownGameListAndPrice = [];

  Future<bool> booking(int partnerId) async {
    setBusy();
    try{
      await MoonBlinkRepository.booking(partnerId, selectedIndex);
      setIdle();
      return true;
    } catch (e,s){
      setError(e, s);
      return false;
    }
  }

  Future<void> initData() async {
    setBusy();
    List<Future> futures = [_getUserWallet(), _getGameList()];
    try{
      Future.wait(futures);
      setIdle();
    }catch(e,s){
      setIdle();
      setError(e, s);
    }
  }


  ///get user wallet
  Future<void> _getUserWallet() async {
    setBusy();
    try{
      Wallet wallet = await MoonBlinkRepository.getUserWallet();
      this.wallet = wallet;
      setIdle();
    }catch(e,s){
      setIdle();
      setError(e, s);
    }
  }

  ///get game list
  Future<void> _getGameList() async {
    setBusy();
    try{
      GameList gameList = await MoonBlinkRepository.getGameList();
      gameList.gameList.forEach((game){
        //dropdownGameList.add(game.gameType);
        //dropdownGamePrice.add(game.price);
        dropdownGameListAndPrice.add('${game.gameType}.${game.price}');
      });
      print(gameList);
      setIdle();
    }catch(e,s){
      setIdle();
      setError(e, s);
    }
  }
}
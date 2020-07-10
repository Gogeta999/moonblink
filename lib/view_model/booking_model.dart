import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class BookingModel extends ViewStateModel{

  final List<String> dropdownList = ['MOBILE_LEGEND_CLASSIC','MOBILE_LEGEND_RANK','PUBG_CLASSIC','PUBG_RANK'];

  int selectedIndex = 0;

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

}
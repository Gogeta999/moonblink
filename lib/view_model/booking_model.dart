import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class BookingModel extends ViewStateModel{
  
  Future<bool> booking(int partnerId) async {
    setBusy();
    try{
      await MoonBlinkRepository.booking(partnerId);
      setIdle();
      return true;
    } catch (e,s){
      setError(e, s);
      return false;
    }
  }

}
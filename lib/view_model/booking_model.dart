import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class BookingModel extends ViewStateModel{
  
  Future<bool> booking() async {
    setBusy();
    try{
      await MoonBlinkRepository.booking();
      setIdle();
      return true;
    } catch (e,s){
      setError(e, s);
      return false;
    }
  }

}
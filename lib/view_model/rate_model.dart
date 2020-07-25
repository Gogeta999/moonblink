import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class RateModel extends ViewStateModel {
  Future<bool> rate(id, bookingid, stars, comment) async {
    setBusy();
    try {
      await MoonBlinkRepository.rategame(id, bookingid, stars, comment);
      setIdle();
      return true;
    } catch (e, s) {
      setError(e, s);
      return false;
    }
  }
}

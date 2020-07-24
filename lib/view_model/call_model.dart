import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class CallModel extends ViewStateModel {

  Future<bool> call(channel, id) async {
    setBusy();
    try {
      await MoonBlinkRepository.call(channel, id);
      setIdle();
      return true;
    } catch (e, s) {
      setError(e,s);
      return false;
    }
  }
}
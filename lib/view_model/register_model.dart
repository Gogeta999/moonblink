import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class RegisterModel extends ViewStateModel {

  Future<bool> singUp(mail, name, lastname, password) async {
    setBusy();
    try {
      await MoonBlinkRepository.register(mail, name, lastname, password);
      setIdle();
      return true;
    } catch (e, s) {
      setError(e,s);
      return false;
    }
  }
}
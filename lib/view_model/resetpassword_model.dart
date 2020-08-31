import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class ResetPasswordModel extends ViewStateModel {
  Future<bool> resetPassword(String mail, int otp, String password) async {
    setBusy();
    try {
      await MoonBlinkRepository.resetpassword(mail, otp, password);
      setIdle();
      return true;
    } catch (e, s) {
      setError(e, s);
      return false;
    }
  }
}

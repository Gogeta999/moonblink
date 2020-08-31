import 'package:flutter/material.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class ForgetPasswordModel extends ViewStateModel {
  Future<bool> forgetPassword(String mail) async {
    setBusy();
    try {
      await MoonBlinkRepository.forgetpassword(mail);
      setIdle();
      return true;
    } catch (e, s) {
      setError(e, s);
      return false;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/view_model/user_model.dart';
import 'package:oktoast/oktoast.dart';

class OtpModel extends ViewStateModel {
  final UserModel userModel;

  ///Firebase OTP
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _verificationId;
  int _forceResendingToken;
  String _phone;
  OtpModel(this.userModel) : assert(userModel != null);
  Future<bool> getFirebaseOtp(String phone) async {
    setBusy();
    this._phone = phone;
    try {
      ///automatically call when verification is auto completed.
      void verificationCompleted(AuthCredential authCredential) async {
        // AuthResult authResult =
        //     await _firebaseAuth.signInWithCredential(authCredential);
        // if (authResult.user != null) {
        //   await signAsPartner(phone);
        // }
        // await signAsPartner(phone);
        showToast('SMS Arrivals');
      }

      void verificationFailed(AuthException authException) async {
        throw authException;
      }

      void codeSent(String verificationId, [int forceResendingToken]) {
        this._verificationId = verificationId;
        this._forceResendingToken = forceResendingToken;
      }

      await _firebaseAuth.verifyPhoneNumber(
          forceResendingToken: _forceResendingToken,
          phoneNumber: phone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: (verificationId) =>
              print('Code: $verificationId'));
      setIdle();
      return true;
    } catch (e, s) {
      setError(e, s);
      return false;
    }
  }

  Future<bool> signAsPartner(String phone) async {
    setBusy();
    try {
      await MoonBlinkRepository.signAsPartner(phone);
      setIdle();
      return true;
    } catch (e, s) {
      setError(e, s);
      return false;
    }
  }

  Future<bool> signInWithCredential(String smsCode) async {
    setBusy();
    try {
      AuthCredential authCredential = PhoneAuthProvider.getCredential(
          verificationId: _verificationId, smsCode: smsCode);
      AuthResult authResult =
          await _firebaseAuth.signInWithCredential(authCredential);
      if (authResult.user != null) {
        await signAsPartner(_phone);
      }
      setIdle();
      return true;
    } catch (e, s) {
      setError(e, s);
      return false;
    }
  }
}

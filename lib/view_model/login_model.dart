import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/view_model/user_model.dart';

// save user login name to let them get their last name after logout
const String mLoginName = 'mLoginName';
// save token to pass our server
const String token = 'token';
const String mUserType = 'mUserType';
const String mUserId = 'mUserId';
const String mLoginMail = 'mLoginMail';
class LoginModel extends ViewStateModel{
  final UserModel userModel;
  LoginModel(this.userModel) : assert(userModel != null);

  String getLoginName(){
    return StorageManager.sharedPreferences.getString(mLoginName);
  }
  // String getUserId(){
  //   return StorageManager.sharedPreferences.getString(mUserId);
  // }
  // String getMPassword(){
  //   return StorageManager.sharedPreferences.getString(mPassWord);
  // }
  
  Future<bool> login(mail, password) async {
    setBusy();
    try{
      var user = await MoonBlinkRepository.login(mail, password);
      userModel.saveUser(user);
      StorageManager.sharedPreferences
        .setString(token, userModel.user.token);
      StorageManager.sharedPreferences
        .setString(mLoginName, userModel.user.name);
      StorageManager.sharedPreferences.setInt(mUserId, userModel.user.id);
      StorageManager.sharedPreferences.setInt(mUserType, userModel.user.type);
      setIdle();
      return true;
    } catch (e, s){
      setError(e, s);
      return false;
    }
  }

  Future<bool> logout() async {
    if (!userModel.hasUser){
      // avoid from 2 user in same time
      return false;
    }

    setBusy();
    try{
      await MoonBlinkRepository.logout();
      userModel.clearUser();
      setIdle();
      return true;
    } catch(e,s){
      setError(e, s);
      return false;
    }
  }

  Future<bool> uploadStory(story) async {
    setBusy();
    try{
      await MoonBlinkRepository.postStory(story);
      setIdle();
      return true;
    } catch(e, s){
      setError(e, s);
      return false;
    }
  }

  Future<bool> editProfile(cover, profile, nrc, mail, gender, dob, phone, bios, address) async {
    setBusy();
    try{
      var user = await MoonBlinkRepository.setprofle(cover, profile, nrc, mail, gender, dob, phone, bios, address);
      userModel.saveUser(user);
      setIdle();
      return true;
    } catch (e,s){
      setError(e, s);
      return false;
    }
  }

  Future<bool> signAsPartner(otp) async {
    setBusy();
    try{
      await MoonBlinkRepository.signAsPartner(otp);
      setIdle();
      return true;
    } catch (e,s){
      setError(e, s);
      return false;
    }
  }

  Future<bool> getOtpCodeAgain(mail) async {
    setBusy();
    try{
      await MoonBlinkRepository.getOtpCode(mail);
      setIdle();
      return true;
    } catch (e,s){
      setError(e, s);
      return false;
    }
  }
}

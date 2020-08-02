import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class UserWallet {
  factory UserWallet() => _instance;

  static final UserWallet _instance = UserWallet._();

  UserWallet._();

  Wallet _wallet;

  Wallet get wallet => _wallet;

  void dispose() {
    _wallet = null;
  }

  ///call when user buy coins.
  Future<bool> topUp(String productId) async {
    return await _userTopUp(productId);
  }

  ///call when user make payments like booking.
  Future<bool> refresh() async {
    return await _getUserWallet();
  }

  ///private methods

  Future<bool> _getUserWallet() async {
    try {
      _wallet = await MoonBlinkRepository.getUserWallet();
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> _userTopUp(String productId) async {
    try {
      var msg = await MoonBlinkRepository.topUp(productId);
      print(msg);
      await _getUserWallet();
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }
}
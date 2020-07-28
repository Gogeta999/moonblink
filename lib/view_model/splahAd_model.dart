import 'package:moonblink/models/adModel.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class SplashAdsModel extends ViewStateModel {
  SplashAdsModel(this.splashAds);
  SplashAds splashAds;

  initAds() async {
    setBusy();
    try {
      splashAds = await MoonBlinkRepository.showAd();
      setIdle();
    } catch (e, s) {
      setError(e, s);
    }
  }
}

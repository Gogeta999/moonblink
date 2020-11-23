import 'package:moonblink/models/ownprofile.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PartnerOwnProfileModel extends ViewStateModel {
  PartnerOwnProfileModel(this.partnerData);
  OwnProfile partnerData;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  RefreshController get refreshController => _refreshController;

  initData() async {
    setBusy();
    try {
      partnerData = await MoonBlinkRepository.fetchOwnProfile();
      notifyListeners();
      setIdle();
    } catch (e, s) {
      refreshController.refreshFailed();
      setError(e, s);
      return null;
    }
  }
}

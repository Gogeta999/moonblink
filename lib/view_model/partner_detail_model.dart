import 'package:moonblink/models/partner.dart';
// import 'package:moonblink/models/partner_user.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class PartnerDetailModel extends ViewStateModel {
  PartnerDetailModel(this.partnerData, this.partnerId);
  PartnerUser partnerData;
  int partnerId;

  Future<void> initData() async {
    setBusy();
    try {
      partnerData = await MoonBlinkRepository.fetchPartner(partnerId);
      setIdle();
    } catch (e, s) {
      setError(e, s);
    }
  }
}

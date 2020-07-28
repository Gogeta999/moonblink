import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/provider/view_state_list_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';
// import 'package:moonblink/view_model/login_model.dart';

class TransactionModel extends ViewStateListModel {
  @override
  Future<List> loadData() async {
    return await MoonBlinkRepository.getTranscation();
  }
}

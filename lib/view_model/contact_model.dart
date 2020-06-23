import 'package:moonblink/provider/view_state_list_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class ContactModel extends ViewStateListModel{
  
  @override
  Future<List> loadData() async {
    return await MoonBlinkRepository.getFollowingContact();
  }
}
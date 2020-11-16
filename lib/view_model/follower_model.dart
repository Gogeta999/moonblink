import 'package:moonblink/provider/view_state_list_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class FollowersModel extends ViewStateListModel {
  final int id;
  FollowersModel(this.id);
  @override
  Future<List> loadData() async {
    return await MoonBlinkRepository.getFollowerList(id);
  }
}

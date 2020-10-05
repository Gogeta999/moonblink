import 'package:moonblink/models/post.dart';
import 'package:moonblink/provider/view_state_list_refresh_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class HomeModel extends ViewStateRefreshListModel {
  HomeModel({this.type, this.gender});
  List<Post> posts = [];
  int type;
  String gender;

  @override
  Future<List> loadData({int pageNum}) async {
    return await MoonBlinkRepository.fetchPosts(
        pageNum: pageNum, type: type, gender: gender);
  }

  Future<bool> reactProfile(partnerId, reactType) async {
    setBusy();
    try {
      await MoonBlinkRepository.react(partnerId, reactType);
      setIdle();
      return true;
    } catch (e, s) {
      setError(e, s);
      return false;
    }
  }
}

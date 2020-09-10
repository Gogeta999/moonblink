import 'package:moonblink/models/post.dart';
import 'package:moonblink/provider/view_state_list_refresh_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class HomeModel extends ViewStateRefreshListModel {
  HomeModel({this.type, this.gender});
  // var usertoken = StorageManager.sharedPreferences.getString(token);
  // List<Story> _stories;
  List<Post> _posts;
  int type;
  String gender;
  // List<Story> get stories => _stories;
  List<Post> get posts => _posts;
  // @override
  // Future<List<Post>> loadData({int pageNum}) async {
  //   return await MoonBlinkRepository.fetchPosts(pageNum);
  // }

  @override
  Future<List> loadData({int pageNum}) async {
    List<Future> futures = [];
    // if (usertoken != null &&
    //     pageNum == ViewStateRefreshListModel.pageNumFirst) {
    //   futures.add(MoonBlinkRepository.fetchStory());
    // }
    print(type);
    futures.add(MoonBlinkRepository.fetchPosts(pageNum, type, gender));

    var result = await Future.wait(futures);

    // if (usertoken != null &&
    //     pageNum == ViewStateRefreshListModel.pageNumFirst) {
    //   _stories = result[0];
    //   return result[1];
    // } else {
    return result[0];
    // }
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

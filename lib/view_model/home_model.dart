import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/models/story.dart';
import 'package:moonblink/provider/view_state_list_refresh_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/view_model/login_model.dart';

class HomeModel extends ViewStateRefreshListModel {
  // var usertoken = StorageManager.sharedPreferences.getString(token);
  // List<Story> _stories;
  List<Post> _posts;

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
    futures.add(MoonBlinkRepository.fetchPosts(pageNum));

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

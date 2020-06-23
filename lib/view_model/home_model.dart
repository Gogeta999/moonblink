import 'package:moonblink/models/post.dart';
import 'package:moonblink/models/story.dart';
import 'package:moonblink/provider/view_state_list_refresh_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class HomeModel extends ViewStateRefreshListModel{
  List<Story> _stories;
  List<Post> _posts;

  List<Story> get stories => _stories;
  List<Post> get posts => _posts;  
  // @override 
  // Future<List<Post>> loadData({int pageNum}) async {
  //   return await MoonBlinkRepository.fetchPosts(pageNum);
  // } 

  @override 
  Future<List> loadData({int pageNum}) async{
    List<Future> futures = [];

    if (pageNum == ViewStateRefreshListModel.pageNumFirst){
      futures.add(MoonBlinkRepository.fetchStory());
    }
    futures.add(MoonBlinkRepository.fetchPosts(pageNum));

    var result = await Future.wait(futures);
    
    if (pageNum == ViewStateRefreshListModel.pageNumFirst){
      _stories = result[0];
      return result[1];
    } else {
      return result[0];
    }
  }

}

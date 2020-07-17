import 'package:moonblink/models/story.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class StoryModel extends ViewStateModel {
  // List<Story> _storiesList;
  ///fix stories length null error
  List<Story> stories = [];

  // @override
  // Future<List<Story>> loadData({int partnerId}) async {
  //   List<Future> futures = [];
  //   futures.add(MoonBlinkRepository.fetchActiveStory(partnerId));
  //   var result = await Future.wait(futures);
  //   _stories = result[0];
  //   return result;
  // }

  // Future<bool> uploadStory(story) async {
  //   setBusy();
  //   try {
  //     await MoonBlinkRepository.postStory(story);
  //     setIdle();
  //     return true;
  //   } catch (e, s) {
  //     setError(e, s);
  //     return false;
  //   }
  // }
  Future<List<Story>> fetchStory({int partnerId}) async {
    setBusy();
    try {
      List<Story> data = await MoonBlinkRepository.fetchActiveStory(partnerId);
      if (data.isEmpty) {
        stories.clear();
        setEmpty();
      }
      // } else {
      onCompleted(data);
      // _storiesList.clear();
      // _storiesList.addAll(data);
      stories = data;
      setIdle();
      return stories;
      // }
      // return stories;
    } catch (e, s) {
      setError(e, s);
      return null;
    }
  }

  Future<void> dropStory(int storyId) async {
    setBusy();
    try{
      var msg = await MoonBlinkRepository.dropStory(storyId);
      print(msg);
    }catch(err){
      print(err);
    }
    setIdle();
  }

  onCompleted(List<Story> data) {}
}

import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class StoryModel extends ViewStateModel{
  
  Future<bool> uploadStory(story) async {
    setBusy();
    try{
      await MoonBlinkRepository.postStory(story);
      setIdle();
      return true;
    } catch (e,s){
      setError(e, s);
      return false;
    }
  }

}
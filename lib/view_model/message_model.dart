import 'package:moonblink/provider/view_state_list_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class GetmsgModel extends ViewStateListModel{
  int id;
  GetmsgModel(this.id);
  @override
  Future<List> loadData() async {
    return await MoonBlinkRepository.message(id);
  }
}
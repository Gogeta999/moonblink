import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/api/moonblink_dio.dart';
//SimpleBlocObserver
class SimpleBlocObserver extends BlocObserver {

  @override
  void onTransition(Bloc bloc, Transition transition) {
    if (isDev) print(transition);
    super.onTransition(bloc, transition);
  }
}
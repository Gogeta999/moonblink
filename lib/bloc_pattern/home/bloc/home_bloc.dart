import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/moongo_database.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial());

  final refreshController = RefreshController();

  final postsSubject = BehaviorSubject.seeded(<Post>[]);
  final loadingSubject = BehaviorSubject.seeded(false);

  final _typeSubject = BehaviorSubject.seeded(1);
  final _genderSubject = BehaviorSubject.seeded('All');
  final _pageSubject = BehaviorSubject.seeded(1);

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {}

  Future<void> fetchData({int type = 1, String gender = 'All'}) async {
    _typeSubject.add(type);
    _genderSubject.add(gender);
    _pageSubject.add(1);
    final int page = 1;
    print('Compare Gender: $gender');
    MoonGoDB().retrievePosts(5, page, type, gender).then((posts) {
      posts.forEach((element) {
        print('Compare Local: ${element.updatedAt}');
      });
      postsSubject.add(posts);
    });

    try {
      final List<Post> data = await MoonBlinkRepository.fetchPosts(
          pageNum: page, type: type, gender: gender);
      data.forEach((element) {
        print('Compare Remote: ${element.updatedAt}');
      });
      postsSubject.add(data);
    } catch (e) {
      postsSubject.addError(e);
    }
  }

  Future<void> fetchMoreData() async {
    loadingSubject.add(true);
    final int type = await _typeSubject.first;
    final String gender = await _genderSubject.first;
    final int page = await _pageSubject.first;
    final int nextPage = page + 1;
    print('nextPage is: $nextPage');
    final List<Post> previousPosts = await postsSubject.first;

    MoonGoDB().retrievePosts(5, page, type, gender).then((posts) {
      print('Local Fetch More: ${posts.length}');
      print('Local Fetch More: ${posts.first.id}');
      postsSubject.add(previousPosts + posts);
      loadingSubject.add(false);
    });

    // try {
    //   final List<Post> data = await MoonBlinkRepository.fetchPosts(
    //       pageNum: nextPage, type: type, gender: gender);
    //   postsSubject.add(previousPosts + data);
    //   _pageSubject.add(nextPage);
    //   //loadingSubject.add(false);
    // } catch (e) {
    //   //loadingSubject.add(false);
    //   //postsSubject.addError(e);
    // }
  }

  Future<void> refreshData() async {
    final int type = await _typeSubject.first;
    final String gender = await _genderSubject.first;
    final int page = 1;

    print('Compare Gender: $gender');
    MoonGoDB().retrievePosts(5, page, type, gender).then((posts) {
      posts.forEach((element) {
        print('Compare Local: ${element.updatedAt}');
      });
      postsSubject.add(posts);
    });

    try {
      final List<Post> data = await MoonBlinkRepository.fetchPosts(
          pageNum: page, type: type, gender: gender);
      data.forEach((element) {
        print('Compare Remote: ${element.updatedAt}');
      });
      _pageSubject.add(1);
      postsSubject.add(data);
      refreshController.refreshCompleted();
    } catch (e) {
      postsSubject.addError(e);
      refreshController.refreshFailed();
    }
  }
}

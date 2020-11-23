import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/moongo_database.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial());

  final refreshController = RefreshController();

  final postsSubject = BehaviorSubject.seeded(<Post>[])..distinct();

  final _typeSubject = BehaviorSubject.seeded(1);
  final _genderSubject = BehaviorSubject.seeded('All');
  final _pageSubject = BehaviorSubject.seeded(1);

  bool hasReachedMax = false;
  //final hasReachedMaxSubject = BehaviorSubject.seeded(false);

  void dispose() {
    refreshController.dispose();
    postsSubject.close();
    _typeSubject.close();
    _genderSubject.close();
    _pageSubject.close();
    this.close();
  }

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
    MoonGoDB().retrievePosts(kHomePostLimit, page, type, gender).then((posts) {
      posts.forEach((element) {
        print('Compare Local: ${element.updatedAt} ${element.id}');
      });
      postsSubject.add(posts);
    });

    try {
      final List<Post> data = await MoonBlinkRepository.fetchPosts(
          pageNum: page, type: type, gender: gender);
      data.forEach((element) {
        print('Compare Remote: ${element.updatedAt} ${element.id}');
      });
      //hasReachedMaxSubject.add(data.length < kHomePostLimit);
      hasReachedMax = data.length < kHomePostLimit;
      postsSubject.add(data);
    } catch (e) {
      //hasReachedMaxSubject.add(false);
      hasReachedMax = false;
      postsSubject.addError(e);
    }
  }

  Future<void> fetchMoreData() async {
    if (hasReachedMax) return;
    print('Fetching More');
    final int type = await _typeSubject.first;
    final String gender = await _genderSubject.first;
    final int page = await _pageSubject.first;
    final int nextPage = page + 1;
    print('nextPage is: $nextPage');
    final List<Post> previousPosts = await postsSubject.first;

    MoonGoDB()
        .retrievePosts(kHomePostLimit, nextPage, type, gender)
        .then((posts) {
      print('Local Fetch More: ${posts.length}');
      postsSubject.add(previousPosts + posts);
    });

    try {
      final List<Post> data = await MoonBlinkRepository.fetchPosts(
          pageNum: nextPage, type: type, gender: gender);
      postsSubject.add(previousPosts + data);
      _pageSubject.add(nextPage);
      //hasReachedMaxSubject.add(data.length < kHomePostLimit);
      hasReachedMax = data.length < kHomePostLimit;
    } catch (e) {
      hasReachedMax = true;
      //hasReachedMaxSubject.add(true);
    }
  }

  Future<void> refreshData() async {
    final int type = await _typeSubject.first;
    final String gender = await _genderSubject.first;
    final int page = 1;

    try {
      final List<Post> data = await MoonBlinkRepository.fetchPosts(
          pageNum: page, type: type, gender: gender);
      _pageSubject.add(1);
      postsSubject.add(data);
      //hasReachedMaxSubject.add(data.length < kHomePostLimit);
      hasReachedMax = data.length < kHomePostLimit;
      refreshController.refreshCompleted();
    } catch (e) {
      postsSubject.addError(e);
      //hasReachedMaxSubject.add(true);
      hasReachedMax = true;
      refreshController.refreshFailed();
    }
  }

  Future<bool> reactProfile(partnerId, reactType) async {
    try {
      await MoonBlinkRepository.react(partnerId, reactType);
      return true;
    } catch (e, s) {
      showToast(e);
      print(s);
      return false;
    }
  }

  Future<bool> removeItem(
      {@required int index, @required int blockUserId}) async {
    try {
      await MoonBlinkRepository.blockOrUnblock(blockUserId, BLOCK);
      final currentPosts = await postsSubject.first;
      MoonGoDB().deletePost(currentPosts[index].id);
      currentPosts.removeAt(index);
      postsSubject.add(currentPosts);
      return true;
    } catch (e) {
      return false;
    }
  }
}

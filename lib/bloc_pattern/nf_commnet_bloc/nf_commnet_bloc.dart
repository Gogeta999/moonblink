import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/new_feed_models/NFComment.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/subjects.dart';

class NFCommentBloc {
  NFCommentBloc(this.postId) {
    this.scrollController = ScrollController()
      ..addListener(() => this.onScroll());
  }

  final int postId;

  ScrollController scrollController;
  final refreshController = RefreshController();
  final commentController = TextEditingController();
  double scrollThreshold = 400.0;
  Timer _debounce;

  final nfCommentsSubject = BehaviorSubject<List<NFComment>>();
  final postButtonSubject = BehaviorSubject.seeded(false);

  final limit = 10;
  int nextPage = 1;
  bool hasReachedMax = false;

  void dispose() {
    refreshController.dispose();
    _debounce?.cancel();
    nfCommentsSubject.close();
    postButtonSubject.close();
  }

  void onScroll() {
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= scrollThreshold) {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        this.fetchMoreData();
      });
    }
  }

  UrlType getUrlType(String url) {
    bool isRemote = url.substring(0, 4) == 'http';
    List<String> strings = url.split('/');
    bool isImage = strings.last.contains('jpg') ||
        strings.last.contains('png') ||
        strings.last.contains('jpeg');
    bool isVideo = strings.last.contains('mp4');
    if (isRemote && isImage && !isVideo) {
      return UrlType.REMOTE_IMAGE;
    } else if (isRemote && !isImage && isVideo) {
      return UrlType.REMOTE_VIDEO;
    } else if (!isRemote && isImage && !isVideo) {
      return UrlType.LOCAL_IMAGE;
    } else if (!isRemote && !isImage && isVideo) {
      return UrlType.LOCAL_VIDEO;
    } else {
      return UrlType.UNKNOWN;
    }
  }

  void refreshData() {
    nextPage = 1;
    MoonBlinkRepository.getNfPostComments(postId, limit, nextPage).then(
        (value) {
      nfCommentsSubject.add(null);
      Future.delayed(Duration(milliseconds: 50), () {
        nfCommentsSubject.add(value);
        refreshController.refreshCompleted();
        hasReachedMax = value.length < limit;
      });
    }, onError: (e) {
      nfCommentsSubject.addError(e);
      refreshController.refreshFailed();
    });
  }

  void fetchInitialData() {
    nextPage = 1;
    MoonBlinkRepository.getNfPostComments(postId, limit, nextPage).then(
        (value) {
      nfCommentsSubject.add(value);
      nextPage++;
      hasReachedMax = value.length < limit;
    }, onError: (e) => nfCommentsSubject.addError(e));
  }

  void fetchMoreData() {
    if (hasReachedMax) return;
    MoonBlinkRepository.getNfPostComments(postId, limit, nextPage).then(
        (value) {
      nfCommentsSubject.first.then((prev) {
        nfCommentsSubject.add(prev + value);
      });
      nextPage++;
      hasReachedMax = value.length < limit;
    }, onError: (e) => nfCommentsSubject.addError(e));
  }

  void postComment() {
    final message = commentController.text.trim();
    if (message == null || message.isEmpty) return;
    postButtonSubject.add(true);
    MoonBlinkRepository.postComment(postId, message, 1).then((value) {
      this.commentController.clear();
      postButtonSubject.add(false);
      final newComment = NFComment.fromJson({
        'id': value['id'],
        'post_id': value['pos_id'],
        'user_id': value['user_id'],
        'message': message,
        'media': "[]",
        'parent_comment_id': 1,
        'created_at': DateTime.now().toString(),
        'updated_at': DateTime.now().toString(),
        'user': {
          'name': StorageManager.sharedPreferences.get(mLoginName) ?? "",
          'email': StorageManager.sharedPreferences.get(mLoginMail) ?? "",
          'type': StorageManager.sharedPreferences.get(mUserType),
          'status': StorageManager.sharedPreferences.get(mstatus),
          'profile_image': StorageManager.sharedPreferences.get(mUserProfile)
        }
      });
      this.nfCommentsSubject.first.then((prev) {
        prev.add(newComment);
        this.nfCommentsSubject.add(prev);
      }, onError: (e) {
        this.nfCommentsSubject.add([newComment]);
        hasReachedMax = true;
      });
    }, onError: (e) {
      showToast(e.toString());
    });
  }
}

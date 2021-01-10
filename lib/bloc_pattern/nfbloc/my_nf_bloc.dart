import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/new_feed_models/NFPost.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/moongo_database.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/subjects.dart';
import 'package:share/share.dart';

class MyNFBloc {
  MyNFBloc(this.scrollController) {
    this.scrollController.addListener(() => this.onScroll());
  }

  final ScrollController scrollController;
  final refreshController = RefreshController();
  double scrollThreshold = 800.0;
  Timer _debounce;

  final myNfPostsSubject = BehaviorSubject<List<NFPost>>.seeded(null);

  final limit = 10;
  int nextPage = 1;
  bool hasReachedMax = false;

  void dispose() {
    refreshController.dispose();
    _debounce?.cancel();
    myNfPostsSubject.close();
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
    MoonBlinkRepository.getNFPostsById(limit, nextPage).then((value) {
      myNfPostsSubject.add(null);
      Future.delayed(Duration(milliseconds: 50), () {
        myNfPostsSubject.add(value);
        refreshController.refreshCompleted();
        hasReachedMax = value.length < limit;
      });
    }, onError: (e) {
      myNfPostsSubject.addError(e);
      refreshController.refreshFailed();
    });
  }

  void fetchInitialData() {
    nextPage = 1;
    MoonBlinkRepository.getNFPostsById(limit, nextPage).then((value) {
      myNfPostsSubject.add(value);
      nextPage++;
      hasReachedMax = value.length < limit;
    }, onError: (e) => myNfPostsSubject.addError(e));
  }

  void fetchMoreData() {
    if (hasReachedMax) return;
    MoonBlinkRepository.getNFPostsById(limit, nextPage).then((value) {
      myNfPostsSubject.first.then((prev) {
        myNfPostsSubject.add(prev + value);
      });
      nextPage++;
      hasReachedMax = value.length < limit;
    }, onError: (e) => myNfPostsSubject.addError(e));
  }

  Future<bool> onTapDeleteIcon(BuildContext context, int index, int postId) {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Confirm Delete'),
            content: Text('This post will delete permanently'),
            actions: [
              CupertinoButton(
                  child: Text(G.of(context).cancel),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              CupertinoButton(
                  child: Text("Delete"),
                  onPressed: () {
                    MoonBlinkRepository.dropPost(postId).then((_) {
                      showToast("Successfully deleted");
                      MoonGoDB().deleteNFPost(postId);
                      this.myNfPostsSubject.first.then((value) {
                        final List<NFPost> current = List.from(value);
                        current.removeAt(index);
                        this.myNfPostsSubject.add(current);
                      });
                    }, onError: (e) {
                      showToast(e.toString());
                    });
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  void onTapLikeIcon() {
    ///some api call
  }

  void onTapShare(BuildContext context) {
    Share.share(
        'https://play.google.com/store/apps/details?id=com.moonuniverse.moonblink',
        subject: 'Please download our app');
  }
}

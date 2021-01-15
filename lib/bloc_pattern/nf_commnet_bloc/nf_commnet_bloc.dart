import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/new_feed_models/NFComment.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/subjects.dart';

class NFCommentBloc {
  NFCommentBloc(this.postId) {
    this.scrollController = ScrollController()
      ..addListener(() => this.onScroll());
  }

  final int postId;

  ScrollController scrollController;
  Completer<void> refreshCompleter = Completer<void>();
  final commentController = TextEditingController();
  final myId = StorageManager.sharedPreferences.getInt(mUserId);
  double scrollThreshold = 400.0;
  Timer _debounce;

  final nfCommentsSubject = BehaviorSubject<List<NFComment>>.seeded(null);
  final postButtonSubject = BehaviorSubject.seeded(false);
  final replyingSubject = BehaviorSubject<Map<String, dynamic>>.seeded(null);
  final editingSubject = BehaviorSubject<int>.seeded(null);

  final limit = 10;
  int nextPage = 1;
  bool hasReachedMax = false;

  void dispose() {
    _debounce?.cancel();
    nfCommentsSubject.close();
    postButtonSubject.close();
    replyingSubject.close();
    editingSubject.close();
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
        refreshCompleter?.complete();
        refreshCompleter = Completer<void>();
        hasReachedMax = value.length < limit;
      });
    }, onError: (e) {
      nfCommentsSubject.addError(e);
      refreshCompleter?.completeError(e);
      refreshCompleter = Completer<void>();
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

  void postComment(BuildContext context) async {
    final message = commentController.text.trim();
    //if (message == null || message.isEmpty) return;
    final commentId = await editingSubject.first;
    if (commentId != null) {
      postButtonSubject.add(true);
      MoonBlinkRepository.updateComment(postId, commentId, message).then(
          (value) async {
        final currentPage = nextPage;
        nextPage = 1;
        List<NFComment> comments = [];
        while (nextPage < currentPage) {
          try {
            final lastComments = await MoonBlinkRepository.getNfPostComments(
                postId, limit, nextPage);
            comments.addAll(lastComments);
            nextPage++;
            hasReachedMax = lastComments.length < limit;
          } catch (e) {
            nfCommentsSubject.addError(e);
            postButtonSubject.add(false);
            return;
          }
        }
        nfCommentsSubject.add(comments);
        resetCommentController(context);
        postButtonSubject.add(false);
      }, onError: (e) {
        showToast(e.toString());
        postButtonSubject.add(false);
      });
    } else {
      int parentCommentId = -1;
      final replyingMap = await replyingSubject.first;
      if (replyingMap != null)
        parentCommentId = replyingMap['parent_comment_id'];
      postButtonSubject.add(true);
      MoonBlinkRepository.postComment(postId, message, parentCommentId).then(
          (_) async {
        final currentPage = nextPage;
        nextPage = 1;
        List<NFComment> comments = [];
        if (currentPage == 1) {
          try {
            final lastComments = await MoonBlinkRepository.getNfPostComments(
                postId, limit, nextPage);
            comments.addAll(lastComments);
            nextPage++;
            hasReachedMax = lastComments.length < limit;
          } catch (e) {
            nfCommentsSubject.addError(e);
            postButtonSubject.add(false);
            return;
          }
        } else {
          while (nextPage < currentPage) {
            try {
              final lastComments = await MoonBlinkRepository.getNfPostComments(
                  postId, limit, nextPage);
              comments.addAll(lastComments);
              nextPage++;
              hasReachedMax = lastComments.length < limit;
            } catch (e) {
              nfCommentsSubject.addError(e);
              postButtonSubject.add(false);
              return;
            }
          }
        }
        nfCommentsSubject.add(comments);
        resetCommentController(context);
        postButtonSubject.add(false);
      }, onError: (e) {
        showToast(e.toString());
        postButtonSubject.add(false);
      });
    }
  }

  void resetCommentController(BuildContext context) {
    replyingSubject.add(null);
    editingSubject.add(null);
    FocusScope.of(context).unfocus();
    commentController.clear();
  }

  ///Edit action close
  void onTapReply(BuildContext context, String username, int parentCommentId) {
    resetCommentController(context);
    replyingSubject
        .add({'username': username, 'parent_comment_id': parentCommentId});
  }

  void onTapCancelReply(BuildContext context) {
    resetCommentController(context);
  }

  ///Reply action close
  void onTapEdit(BuildContext context, int commentId, String prevMessage) {
    resetCommentController(context);
    editingSubject.add(commentId);
    commentController.text = prevMessage;
  }

  ///Edit and delete action close
  void onTapDelete(BuildContext context, int commentId) {
    resetCommentController(context);
    showCupertinoDialog(
        context: context,
        builder: (context) {
          bool deleting = false;
          return CupertinoAlertDialog(
            title: Text('Delete'),
            content: Text('This comment will be deleted permanently.'),
            actions: [
              CupertinoButton(
                  child: Text(G.of(context).cancel),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              CupertinoButton(
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    if (deleting) return;
                    deleting = true;
                    MoonBlinkRepository.deleteComment(postId, commentId).then(
                        (value) async {
                      final currentPage = nextPage;
                      nextPage = 1;
                      List<NFComment> comments = [];
                      while (nextPage < currentPage) {
                        try {
                          final lastComments =
                              await MoonBlinkRepository.getNfPostComments(
                                  postId, limit, nextPage);
                          comments.addAll(lastComments);
                          nextPage++;
                          hasReachedMax = lastComments.length < limit;
                        } catch (e) {
                          nfCommentsSubject.addError(e);
                          postButtonSubject.add(false);
                          return;
                        }
                      }
                      nfCommentsSubject.add(comments);
                      resetCommentController(context);
                      postButtonSubject.add(false);
                    }, onError: (e) {
                      showToast(e.toString());
                      postButtonSubject.add(false);
                    }).whenComplete(() => Navigator.pop(context));
                  })
            ],
          );
        });
  }
}

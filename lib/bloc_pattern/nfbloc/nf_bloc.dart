import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/new_feed_models/NFPost.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/moongo_database.dart';
import 'package:moonblink/ui/pages/booking_page/booking_page.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/subjects.dart';
import 'package:share/share.dart';

///To-Do Block and Delete feature to work smoothly
class NFBloc {
  NFBloc(this.scrollController) {
    this.scrollController.addListener(() => this.onScroll());
  }

  final ScrollController scrollController;
  Completer<void> refreshCompleter = Completer<void>();
  double scrollThreshold = 800.0;
  Timer _debounce;

  final nfPostsSubject = BehaviorSubject<List<NFPost>>.seeded(null);

  final limit = 20;
  int nextPage = 1;
  bool hasReachedMax = false;

  void dispose() {
    _debounce?.cancel();
    nfPostsSubject.close();
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
    MoonBlinkRepository.getNFPosts(limit, nextPage).then((value) {
      nfPostsSubject.add(null);
      Future.delayed(Duration(milliseconds: 50), () {
        nfPostsSubject.add(value);
        refreshCompleter?.complete();
        refreshCompleter = Completer<void>();
        hasReachedMax = value.length < limit;
      });
    }, onError: (e) {
      nfPostsSubject.addError(e);
      refreshCompleter?.completeError(e);
      refreshCompleter = Completer<void>();
    });
  }

  void fetchInitialData() {
    nextPage = 1;
    MoonGoDB()
        .retrieveNfPosts(limit, nextPage)
        .then((value) => nfPostsSubject.add(value));
    MoonBlinkRepository.getNFPosts(limit, nextPage).then((value) async {
      nfPostsSubject.add(null);
      await Future.delayed(Duration(milliseconds: 50));
      nfPostsSubject.add(value);
      nextPage++;
      hasReachedMax = value.length < limit;
    }, onError: (e) => nfPostsSubject.addError(e));
  }

  void fetchMoreData() {
    if (hasReachedMax) return;
    MoonBlinkRepository.getNFPosts(limit, nextPage).then((value) {
      nfPostsSubject.first.then((prev) {
        nfPostsSubject.add(prev + value);
      });
      nextPage++;
      hasReachedMax = value.length < limit;
    }, onError: (e) {
      hasReachedMax = true;
    });
  }

  void onTapWholeCard(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartnerDetailPage(id),
      ),
    );
  }

  void onTapBlockIcon(BuildContext context, int index, int partnerId) {
    CustomBottomSheet.showUserManageContent(
        buildContext: context,
        onReport: () {
          MoonBlinkRepository.reportUser(partnerId).then((value) {
            showToast(
                'Report success. We will act on this user within 24 hours.');
            Navigator.pop(context);
          }, onError: (e) {
            showToast('$e');
          });
        },
        onBlock: () {
          MoonBlinkRepository.blockOrUnblock(partnerId, BLOCK).then((value) {
            showToast('Successfully block');
            Navigator.pop(context);
            // this.nfPostsSubject.first.then((value) {
            //   value.removeAt(index);
            //   this.nfPostsSubject.add(value);
            //   Navigator.pop(context);
            // });
          }, onError: (e) {
            showToast('$e');
          });
        },
        onDismiss: () => print('Dismissing BottomSheet'));
  }

  void onTapLikeIcon(int postId, int like) {
    MoonBlinkRepository.reactNFPost(postId, like).then((value) {},
        onError: (e) {
      showToast('$e');
    });
  }

  void onTapInstaIcon(
      BuildContext context, int userId, String username, String bios, profile) {
    final myId = StorageManager.sharedPreferences.getInt(mUserId);
    if (userId == myId) {
      showToast(G.of(context).cannotbookself);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookingPage(
            partnerId: userId,
            partnerName: username,
            partnerBios: bios,
            partnerProfile: profile,
          ),
        ),
      );
    }
  }

  void onTapShare(BuildContext context) {
    Share.share(
        'https://play.google.com/store/apps/details?id=com.moonuniverse.moonblink',
        subject: 'Please download our app');
  }
}

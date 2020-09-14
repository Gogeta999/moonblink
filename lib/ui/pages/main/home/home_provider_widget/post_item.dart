import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/ad_post_widget.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/view_model/home_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class PostItemWidget extends StatefulWidget {
  PostItemWidget(this.posts, {this.index}) : super(key: ValueKey(posts.userID));

  final int index;
  final Post posts;

  @override
  _PostItemWidgetState createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget> {
  bool isLiked = false;
  var usertoken = StorageManager.sharedPreferences.getString(token);
  bool isBlocking = false;
  bool isRetying = false;
  // var _coverUrl;
  var _profileUrl;
  @override
  void initState() {
    _profileUrl = widget.posts.profileImage;
    // _coverUrl = widget.posts.coverImage;
    super.initState();
  }

  Widget postprofile(homeModel) {
    return CachedNetworkImage(
      imageUrl: widget.posts.profileImage,
      imageBuilder: (context, imageProvider) => Padding(
        padding: const EdgeInsets.only(top: 12, left: 15),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey
              : Colors.black,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.transparent,
            backgroundImage: imageProvider,
            child: GestureDetector(
              onTap: usertoken == null
                  ? () {
                      showToast(G.of(context).loginFirst);
                    }
                  : () {
                      int detailPageId = widget.posts.userID;
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PartnerDetailPage(detailPageId)))
                          .then((value) async {
                        if (value != null) {
                          setState(() {
                            isBlocking = true;
                          });

                          ///Blocking user
                          await homeModel
                              .removeItem(
                                  index: widget.index,
                                  blockUserId: widget.posts.userID)
                              .then((value) {
                            value
                                ? showToast('Successfully Blocked')
                                : showToast('Error Blocking User');
                          });
                          setState(() {
                            isBlocking = false;
                          });
                        }
                      });
                    },
            ),
          ),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade600,
        child: IconButton(
          onPressed: () {
            setState(() {
              _profileUrl = widget.posts.profileImage;
            });
          },
          icon: Icon(
            Icons.refresh,
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  //Block Button
  Widget blockbtn(homeModel) {
    return IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () => CustomBottomSheet.showUserManageContent(
          buildContext: context,
          onReport: () async {
            ///Reporting user
            try {
              await MoonBlinkRepository.reportUser(widget.posts.userID);

              ///Api call success
              showToast(
                  'Thanks for making our MoonBlink\'s Universe clean and tidy. We will act on this user within 24 hours.');
              Navigator.pop(context);
            } catch (e) {
              showToast('Sorry, $e');
            }
          },
          onBlock: () async {
            ///Blocking user
            await homeModel
                .removeItem(
                    index: widget.index, blockUserId: widget.posts.userID)
                .then((value) {
              value
                  ? showToast('Successfully Blocked')
                  : showToast('Error Blocking User');
            });
            Navigator.pop(context);
          },
          onDismiss: () => print('Dismissing BottomSheet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    HomeModel homeModel = Provider.of<HomeModel>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 2.0,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey
                    : Colors.black,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Stack(
              children: [
                Column(
                  children: <Widget>[
                    /// [user_Profile]
                    Container(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 80.0),
                            child: Text(widget.posts.userName),
                          ),
                          Spacer(),
                          Align(
                              alignment: Alignment.centerRight,
                              child: blockbtn(homeModel)),
                        ],
                      ),
                    ),

                    /// [User_Image]
                    isBlocking
                        ? CupertinoActivityIndicator()
                        : ProviderWidget(
                            model: HomeModel(),
                            builder: (context, reactModel, child) {
                              return Column(
                                children: <Widget>[
                                  InkWell(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              width: 2,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                            bottom: BorderSide(
                                              width: 2,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        constraints: BoxConstraints(
                                            minHeight: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2.5,
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                1.5,
                                            minWidth: double.infinity,
                                            maxWidth: double.infinity),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          imageUrl: widget.posts.coverImage,
                                          placeholder: (context, url) =>
                                              CachedLoader(
                                            containerHeight: 200,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              CachedError(
                                            containerHeight: 200,
                                          ),
                                          // errorWidget: (context, url, error) => Container(
                                          //   color: Colors.grey.shade600,
                                          //   child: IconButton(
                                          //     onPressed: () {
                                          //       print('Reload');
                                          //       setState(() {
                                          //         _coverUrl = widget.posts.coverImage;
                                          //       });
                                          //     },
                                          //     icon: Icon(
                                          //       Icons.refresh,
                                          //       color: Colors.grey.shade300,
                                          //     ),
                                          //   ),
                                          // ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) => ImageView(
                                                    widget.posts.coverImage)));
                                        print('object');
                                      },
                                      onDoubleTap: widget.posts.isReacted == 0
                                          ? () {
                                              reactModel
                                                  .reactProfile(
                                                      widget.posts.userID, 1)
                                                  .then((value) {
                                                if (value) {
                                                  showToast(G
                                                      .of(context)
                                                      .toastlikesuccess);
                                                  setState(() {
                                                    widget.posts.isReacted = 1;
                                                    widget.posts
                                                        .reactionCount += 1;
                                                  });
                                                } else {
                                                  reactModel.showErrorMessage(
                                                      context);
                                                }
                                              });
                                            }
                                          : () {
                                              reactModel
                                                  .reactProfile(
                                                      widget.posts.userID, 0)
                                                  .then((value) {
                                                if (value) {
                                                  showToast(G
                                                      .of(context)
                                                      .toastunlikesuccess);
                                                  setState(() {
                                                    widget.posts.isReacted = 0;
                                                    widget.posts
                                                        .reactionCount -= 1;
                                                  });
                                                } else {
                                                  reactModel.showErrorMessage(
                                                      context);
                                                }
                                              });
                                            }),

                                  /// [User_bottom data]
                                  Container(
                                    height: 30,
                                    width: double.infinity,
                                    margin: EdgeInsets.all(8.0),
                                    child: Stack(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: InkWell(
                                            child: Icon(
                                                widget.posts.isReacted == 0
                                                    ? FontAwesomeIcons.heart
                                                    : FontAwesomeIcons
                                                        .solidHeart,
                                                size: 30,
                                                color:
                                                    widget.posts.isReacted == 0
                                                        ? Theme.of(context)
                                                            .iconTheme
                                                            .color
                                                        : Colors.red[400]),
                                            onTap: widget.posts.isReacted == 0
                                                ? () {
                                                    reactModel
                                                        .reactProfile(
                                                            widget.posts.userID,
                                                            1)
                                                        .then((value) {
                                                      if (value) {
                                                        showToast(G
                                                            .of(context)
                                                            .toastlikesuccess);
                                                        setState(() {
                                                          widget.posts
                                                              .isReacted = 1;
                                                          widget.posts
                                                              .reactionCount += 1;
                                                        });
                                                      } else {
                                                        reactModel
                                                            .showErrorMessage(
                                                                context);
                                                      }
                                                    });
                                                  }
                                                : () {
                                                    reactModel
                                                        .reactProfile(
                                                            widget.posts.userID,
                                                            0)
                                                        .then((value) {
                                                      if (value) {
                                                        showToast(G
                                                            .of(context)
                                                            .toastunlikesuccess);
                                                        setState(() {
                                                          widget.posts
                                                              .isReacted = 0;
                                                          widget.posts
                                                              .reactionCount -= 1;
                                                        });
                                                      } else {
                                                        reactModel
                                                            .showErrorMessage(
                                                                context);
                                                      }
                                                    });
                                                  },
                                          ),
                                        ),
                                        Positioned(
                                            left: 40,
                                            bottom: 5,
                                            child: Text(
                                                '${widget.posts.reactionCount} ${G.of(context).likes}')),
                                        Center(
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                left: 8.0, top: 10, bottom: 5),
                                            // padding:
                                            //     EdgeInsets.symmetric(vertical: 6),
                                            child: Text(
                                              G.of(context).becomePartnerAt +
                                                  //DateFormat.jm().format(DateTime.parse(widget.posts.createdAt)),
                                                  timeAgo.format(
                                                      DateTime.parse(widget
                                                          .posts.createdAt),
                                                      allowFromNow: true),
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            icon: Icon(FontAwesomeIcons.share),
                                            onPressed: () {
                                              final RenderBox box =
                                                  context.findRenderObject();
                                              Share.share(
                                                  'https://play.google.com/store/apps/details?id=com.moonuniverse.moonblink',
                                                  subject:
                                                      'Please download our app',
                                                  sharePositionOrigin:
                                                      box.localToGlobal(
                                                              Offset.zero) &
                                                          box.size);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                          ),

                    /// [bottom date]

                    Divider(
                      height: 5,
                    ),
                  ],
                ),
                postprofile(homeModel),
              ],
            ),
          ),
          Divider(
            height: 10,
          ),
          if (widget.index != 0 && widget.index % 6 == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: AdPostWidget(),
            )
        ],
      ),
    );
  }

  // //For cached network
  // Widget _loader(BuildContext context, String url) {
  //   return Container(
  //       height: 200,
  //       child: Stack(
  //         children: <Widget>[
  //           BlurHash(hash: 'L07-Zwofj[oft7fQj[fQayfQfQfQ'),
  //           Center(
  //             child: const Center(
  //               child: CircularProgressIndicator(
  //                   // valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
  //                   ),
  //             ),
  //           ),
  //         ],
  //       ));
  // }

  // Widget _error(BuildContext context, String url, dynamic error) {
  //   print(error);
  //   return Container(
  //       height: 200,
  //       child: InkWell(child: const Center(child: Icon(Icons.error))));
  // }
}

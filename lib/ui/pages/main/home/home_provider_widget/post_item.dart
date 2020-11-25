import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/ad_post_widget.dart';
import 'package:moonblink/base_widget/blinkIcon_Widget.dart';
import 'package:moonblink/base_widget/gradient.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/bloc_pattern/home/bloc/home_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/ui/pages/booking_page/booking_page.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/home_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class PostItemWidget extends StatefulWidget {
  PostItemWidget(this.posts, {this.index}) : super(key: ValueKey(posts.id));

  final int index;
  final Post posts;

  @override
  _PostItemWidgetState createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget>
    with AutomaticKeepAliveClientMixin {
  bool isLiked = false;
  var usertoken = StorageManager.sharedPreferences.getString(token);
  bool isBlocking = false;
  bool isRetying = false;
  HomeBloc _homeBloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  Widget postprofile() {
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
                      int detailPageId = widget.posts.id;
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
                          await _homeBloc
                              .removeItem(
                                  index: widget.index,
                                  blockUserId: widget.posts.id)
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
      placeholder: (context, url) => Padding(
        padding: const EdgeInsets.only(top: 12, left: 15),
        child: CupertinoActivityIndicator(),
      ),
      errorWidget: (context, url, error) => Padding(
        padding: const EdgeInsets.only(top: 12, left: 15),
        child: Container(
          color: Colors.grey.shade600,
          child: IconButton(
            onPressed: () {
              showToast('Refresh Again');
            },
            icon: Icon(
              Icons.error,
              color: Colors.grey.shade300,
            ),
          ),
        ),
      ),
    );
  }

  //Block Button
  Widget blockbtn() {
    return IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () => CustomBottomSheet.showUserManageContent(
          buildContext: context,
          onReport: () async {
            ///Reporting user
            try {
              await MoonBlinkRepository.reportUser(widget.posts.id);

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
            await _homeBloc
                .removeItem(index: widget.index, blockUserId: widget.posts.id)
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
    super.build(context);
    final ownId = StorageManager.sharedPreferences.getInt(mUserId);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PartnerDetailPage(widget.posts.id),
              ),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              shadowColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.grey,
              elevation: 4,
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
                              child: Text(widget.posts.userName,
                                  style: widget.posts.id == 62
                                      ? TextStyle(
                                          color: Theme.of(context).accentColor)
                                      : null),
                            ),
                            Spacer(),
                            Align(
                                alignment: Alignment.centerRight,
                                child: blockbtn()),
                          ],
                        ),
                      ),

                      /// [User_Image]
                      isBlocking
                          ? CupertinoActivityIndicator()
                          : Column(
                              children: <Widget>[
                                InkWell(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          width: 2,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                        bottom: BorderSide(
                                          width: 2,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    constraints: BoxConstraints(
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
                                          _homeBloc
                                              .reactProfile(widget.posts.id, 1)
                                              .then(
                                            (value) {
                                              if (value) {
                                                showToast(G
                                                    .of(context)
                                                    .toastlikesuccess);
                                                setState(() {
                                                  widget.posts.isReacted = 1;
                                                  widget.posts.reactionCount +=
                                                      1;
                                                });
                                              }
                                              // else {
                                              //   _homeBloc
                                              //       .showErrorMessage(context);
                                              // }
                                            },
                                          );
                                        }
                                      : () {
                                          _homeBloc
                                              .reactProfile(widget.posts.id, 0)
                                              .then(
                                            (value) {
                                              if (value) {
                                                showToast(G
                                                    .of(context)
                                                    .toastunlikesuccess);
                                                setState(
                                                  () {
                                                    widget.posts.isReacted = 0;
                                                    widget.posts
                                                        .reactionCount -= 1;
                                                  },
                                                );
                                              }
                                              // else {
                                              //   reactModel
                                              //       .showErrorMessage(context);
                                              // }
                                            },
                                          );
                                        },
                                ),

                                /// [User_bottom data]
                                Container(
                                  height: 30,
                                  width: double.infinity,
                                  margin: EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: InkWell(
                                          child: Icon(
                                              widget.posts.isReacted == 0
                                                  ? FontAwesomeIcons.heart
                                                  : FontAwesomeIcons.solidHeart,
                                              size: 30,
                                              color: widget.posts.isReacted == 0
                                                  ? Theme.of(context)
                                                      .iconTheme
                                                      .color
                                                  : Colors.red[400]),
                                          onTap: widget.posts.isReacted == 0
                                              ? () {
                                                  _homeBloc
                                                      .reactProfile(
                                                          widget.posts.id, 1)
                                                      .then((value) {
                                                    if (value) {
                                                      showToast(G
                                                          .of(context)
                                                          .toastlikesuccess);
                                                      setState(() {
                                                        widget.posts.isReacted =
                                                            1;
                                                        widget.posts
                                                            .reactionCount += 1;
                                                      });
                                                    }
                                                    // else {
                                                    //   reactModel
                                                    //       .showErrorMessage(
                                                    //           context);
                                                    // }
                                                  });
                                                }
                                              : () {
                                                  _homeBloc
                                                      .reactProfile(
                                                          widget.posts.id, 0)
                                                      .then((value) {
                                                    if (value) {
                                                      showToast(G
                                                          .of(context)
                                                          .toastunlikesuccess);
                                                      setState(() {
                                                        widget.posts.isReacted =
                                                            0;
                                                        widget.posts
                                                            .reactionCount -= 1;
                                                      });
                                                    }
                                                    // else {
                                                    //   reactModel
                                                    //       .showErrorMessage(
                                                    //           context);
                                                    // }
                                                  });
                                                },
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                            '${widget.posts.reactionCount} ${G.of(context).likes}'),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          child: Text(
                                            G.of(context).becomePartnerAt +
                                                //DateFormat.jm().format(DateTime.parse(widget.posts.createdAt)),
                                                timeAgo.format(
                                                    DateTime.parse(
                                                        widget.posts.createdAt),
                                                    allowFromNow: true),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.0),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: InkWell(
                                          
                                          child: Container(
                                            child: BlinkWidget(
                                              children: [
                                                Icon(FontAwesomeIcons.book),
                                                RadiantGradientMask(
                                                  child: Icon(
                                                    FontAwesomeIcons.book,
                                                    // size: 30,
                                                    color: Colors.white,
                                                  ),
                                                  colors: MoreGradientColors
                                                      .instagram,
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: widget.posts.id == ownId
                                              ? () {
                                                  showToast(G
                                                      .of(context)
                                                      .cannotbookself);
                                                }
                                              : () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BookingPage(
                                                        partnerId:
                                                            widget.posts.id,
                                                        partnerName: widget
                                                            .posts.userName,
                                                        partnerBios:
                                                            widget.posts.bios,
                                                        partnerProfile: widget
                                                            .posts.profileImage,
                                                      ),
                                                    ),
                                                  );
                                                },
                                        ),
                                      ),
                                      // ),
                                      Expanded(
                                        flex: 1,
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
                            ),

                      /// [bottom date]
                      Divider(
                        height: 5,
                      ),
                    ],
                  ),
                  postprofile(),
                ],
              ),
            ),
          ),
          Divider(
            height: 10,
          ),
          if (widget.index != 0 && widget.index % 10 == 0)
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

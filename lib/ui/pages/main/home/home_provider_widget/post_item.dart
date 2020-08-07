import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
import 'package:moonblink/view_model/home_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share/share.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330.0,
      child: Column(
        children: <Widget>[
          /// [user_Profile]
          Material(
            child: InkWell(
              onTap: usertoken == null
                  ? () {
                      showToast(S.of(context).loginFirst);
                    }
                  : () {
                      int detailPageId = widget.posts.userID;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PartnerDetailPage(detailPageId)));
                    },
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: Row(
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: widget.posts.profileImage,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 46.0,
                        height: 46.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(widget.posts.userName),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// [User_Image]
          ProviderWidget(
            model: HomeModel(),
            builder: (context, reactModel, child) {
              return Column(
                children: <Widget>[
                  InkWell(
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: widget.posts.coverImage,
                          placeholder: (context, url) => CachedLoader(),
                          errorWidget: (context, url, error) => CachedError(),
                        ),
                      ),
                      onDoubleTap: widget.posts.isReacted == 0
                          ? () {
                              reactModel
                                  .reactProfile(widget.posts.userID, 1)
                                  .then((value) {
                                if (value) {
                                  showToast('Like Successful');
                                  setState(() {
                                    widget.posts.isReacted = 1;
                                    widget.posts.reactionCount += 1;
                                  });
                                } else {
                                  reactModel.showErrorMessage(context);
                                }
                              });
                            }
                          : () {
                              reactModel
                                  .reactProfile(widget.posts.userID, 0)
                                  .then((value) {
                                if (value) {
                                  showToast('Unlike Successful');
                                  setState(() {
                                    widget.posts.isReacted = 0;
                                    widget.posts.reactionCount -= 1;
                                  });
                                } else {
                                  reactModel.showErrorMessage(context);
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
                                    : FontAwesomeIcons.solidHeart,
                                size: 30,
                                color: widget.posts.isReacted == 0
                                    ? Theme.of(context).iconTheme.color
                                    : Colors.red[400]),
                            onTap: widget.posts.isReacted == 0
                                ? () {
                                    reactModel
                                        .reactProfile(widget.posts.userID, 1)
                                        .then((value) {
                                      if (value) {
                                        showToast('Like Successful');
                                        setState(() {
                                          widget.posts.isReacted = 1;
                                          widget.posts.reactionCount += 1;
                                        });
                                      } else {
                                        reactModel.showErrorMessage(context);
                                      }
                                    });
                                  }
                                : () {
                                    reactModel
                                        .reactProfile(widget.posts.userID, 0)
                                        .then((value) {
                                      if (value) {
                                        showToast('Unlike Successful');
                                        setState(() {
                                          widget.posts.isReacted = 0;
                                          widget.posts.reactionCount -= 1;
                                        });
                                      } else {
                                        reactModel.showErrorMessage(context);
                                      }
                                    });
                                  },
                          ),
                        ),
                        Positioned(
                            left: 40,
                            bottom: 5,
                            child: Text('${widget.posts.reactionCount} Likes')),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(FontAwesomeIcons.share),
                            onPressed: () {
                              final RenderBox box = context.findRenderObject();
                              Share.share(
                                  'https://play.google.com/store/apps/details?id=com.moonuniverse.moonblink',
                                  subject: 'Please download our app',
                                  sharePositionOrigin:
                                      box.localToGlobal(Offset.zero) &
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
          Container(
            margin: EdgeInsets.only(left: 8.0, top: 0.5, bottom: 5),
            alignment: Alignment.topLeft,
            child: Text(
              widget.posts.creatdAt,
              style: TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
          ),
          Divider(
            height: 0.5,
          ),
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

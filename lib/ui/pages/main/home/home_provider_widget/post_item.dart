import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:moonblink/base_widget/cachedImage.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/post.dart';
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
      height: 338.0,
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
                    CircleAvatar(
                      radius: 23,
                      backgroundImage: NetworkImage(widget.posts.profileImage),
                      backgroundColor: Colors.grey,
                      onBackgroundImageError: (exception, stackTrace) {
                        print(exception +
                            '--exception\n--stackTrace' +
                            stackTrace);
                      },
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
                  if (widget.posts.isReacted == 0)
                    InkWell(
                      child: Container(
                        // width: 100,
                        // child: Image.network(
                        //   widget.posts.coverImage,
                        //   fit: BoxFit.fitWidth,
                        //   height: 200,
                        // ),
                        height: 200,
                        child: CachedImage(
                          boxFit: BoxFit.cover,
                          imageProvider: NetworkImage(
                            widget.posts.coverImage,
                          ),
                        ),
                      ),
                      onDoubleTap: isLiked
                          ? () {
                              // var formState = Form.of(context);
                              // if (formState.validate()) {
                              reactModel
                                  .reactProfile(widget.posts.userID, 0)
                                  .then((value) {
                                if (value) {
                                  showToast('Unlike Successful');
                                  setState(() {
                                    isLiked = !isLiked;
                                  });
                                } else {
                                  reactModel.showErrorMessage(context);
                                }
                              });
                              // }
                            }
                          : () {
                              reactModel.reactProfile(widget.posts.userID, 1)
                                  // ignore: missing_return
                                  .then((value) {
                                if (value) {
                                  showToast('Like Successful');
                                  setState(() {
                                    isLiked = !isLiked;
                                  });
                                } else if (reactModel.isError) {
                                  // if (reactModel.viewStateError
                                  //     .isUnauthorized) {
                                  //   loginHelper(context);
                                  // } else {
                                  // loginHelper(context);
                                  reactModel.showErrorMessage(context);
                                  // }
                                }
                              });
                            },
                    ),
                  if (widget.posts.isReacted == 1)
                    InkWell(
                        child: Container(
                          // child: Image.network(
                          //   widget.posts.coverImage,
                          //   fit: BoxFit.contain,
                          //   height: 200,
                          // ),
                          height: 200,
                          child: CachedImage(
                            boxFit: BoxFit.contain,
                            imageProvider: NetworkImage(
                              widget.posts.coverImage,
                            ),
                          ),
                        ),
                        onDoubleTap: isLiked
                            ? () {
                                reactModel
                                    .reactProfile(widget.posts.userID, 1)
                                    .then((value) {
                                  if (value) {
                                    showToast('Like Successful');
                                    setState(() {
                                      isLiked = !isLiked;
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
                                      isLiked = !isLiked;
                                    });
                                  } else {
                                    reactModel.showErrorMessage(context);
                                  }
                                });
                              }),

                  /// [User_bottom data]
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        if (widget.posts.isReacted == 0)

                          /// [like animation while user unreacted]
                          InkWell(
                              child: Icon(
                                  isLiked
                                      ? FontAwesomeIcons.solidHeart
                                      : FontAwesomeIcons.heart,
                                  size: 30,
                                  color: isLiked
                                      ? Colors.red[400]
                                      : Theme.of(context).iconTheme.color),
                              onTap: isLiked
                                  ? () {
                                      // var formState = Form.of(context);
                                      // if (formState.validate()) {
                                      reactModel
                                          .reactProfile(widget.posts.userID, 0)
                                          .then((value) {
                                        if (value) {
                                          showToast('Unlike Successful');
                                          setState(() {
                                            isLiked = !isLiked;
                                          });
                                        } else {
                                          reactModel.showErrorMessage(context);
                                        }
                                      });
                                      // }
                                    }
                                  : () {
                                      reactModel
                                          .reactProfile(widget.posts.userID, 1)
                                          // ignore: missing_return
                                          .then((value) {
                                        if (value) {
                                          showToast('Like Successful');
                                          setState(() {
                                            isLiked = !isLiked;
                                          });
                                        } else if (reactModel.isError) {
                                          // if (reactModel.viewStateError
                                          //     .isUnauthorized) {
                                          //   loginHelper(context);
                                          // } else {
                                          // loginHelper(context);
                                          reactModel.showErrorMessage(context);
                                          // }
                                        }
                                      });
                                      // }
                                    }),

                        /// [when user react in this profile]
                        if (widget.posts.isReacted == 1)
                          InkWell(
                              child: Icon(
                                  isLiked
                                      ? FontAwesomeIcons.heart
                                      : FontAwesomeIcons.solidHeart,
                                  size: 30,
                                  color: isLiked
                                      ? Theme.of(context).iconTheme.color
                                      : Colors.red[400]),
                              onTap: isLiked
                                  ? () {
                                      reactModel
                                          .reactProfile(widget.posts.userID, 1)
                                          .then((value) {
                                        if (value) {
                                          showToast('Like Successful');
                                          setState(() {
                                            isLiked = !isLiked;
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
                                            isLiked = !isLiked;
                                          });
                                        } else {
                                          reactModel.showErrorMessage(context);
                                        }
                                      });
                                    }),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.share),
                          onPressed: () {
                            final RenderBox box = context.findRenderObject();
                            Share.share(
                                'https://play.google.com/store/apps/details?id=com.moonuniverse.moonblink',
                                subject: 'Please download our app',
                                sharePositionOrigin:
                                    box.localToGlobal(Offset.zero) & box.size);
                          },
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
}

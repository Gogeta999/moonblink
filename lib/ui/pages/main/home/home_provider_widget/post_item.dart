import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:provider/provider.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
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
      child: Column(
        children: <Widget>[
          Container(
            height: 360.0,
            child: Column(
              children: <Widget>[
                /// [user_Profile]
                Material(
                  child: InkWell(
                    onTap: usertoken == null
                        ? () {
                            showToast('Login First');
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
                      margin: EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            ImageHelper.wrapAssetsLogo('MoonBlink_Cute.png'),
                            height: 40.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text(widget.posts.userName +
                                ' id' +
                                widget.posts.userID.toString()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// [User_Image]
                Container(
                  child: Image.network(
                    widget.posts.profileImage,
                    fit: BoxFit.contain,
                    height: 200,
                  ),
                  // child: Text(posts.profileImage.toString()),
                  // child: Image.asset(ImageHelper.wrapAssetsImage('images.jpg'), fit: BoxFit.cover,
                  // ),
                ),
                // Container(
                //   child: Image.network('http://128.199.254.89/moonblink/api/v1/social/user?limit=5&type=1&page=1'+ posts.profileImage.toString(), fit: BoxFit.cover,),
                // ),
                /// [User_bottom data]
                ProviderWidget(
                    model: HomeModel(),
                    builder: (context, reactModel, child) {
                      return Container(
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
                                      color: isLiked
                                          ? Colors.red[400]
                                          : Theme.of(context).iconTheme.color),
                                  onTap: isLiked
                                      ? () {
                                          // var formState = Form.of(context);
                                          // if (formState.validate()) {
                                          reactModel
                                              .reactProfile(
                                                  widget.posts.userID, 0)
                                              .then((value) {
                                            if (value) {
                                              showToast('Unlike Successful');
                                              setState(() {
                                                isLiked = !isLiked;
                                              });
                                            } else {
                                              reactModel
                                                  .showErrorMessage(context);
                                            }
                                          });
                                          // }
                                        }
                                      : () {
                                          reactModel
                                              .reactProfile(
                                                  widget.posts.userID, 1)
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
                                              reactModel
                                                  .showErrorMessage(context);
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
                                      color: isLiked
                                          ? Theme.of(context).iconTheme.color
                                          : Colors.red[400]),
                                  onTap: isLiked
                                      ? () {
                                          reactModel
                                              .reactProfile(
                                                  widget.posts.userID, 1)
                                              .then((value) {
                                            if (value) {
                                              showToast('Like Successful');
                                              setState(() {
                                                isLiked = !isLiked;
                                              });
                                            } else {
                                              reactModel
                                                  .showErrorMessage(context);
                                            }
                                          });
                                        }
                                      : () {
                                          reactModel
                                              .reactProfile(
                                                  widget.posts.userID, 0)
                                              .then((value) {
                                            if (value) {
                                              showToast('Unlike Successful');
                                              setState(() {
                                                isLiked = !isLiked;
                                              });
                                            } else {
                                              reactModel
                                                  .showErrorMessage(context);
                                            }
                                          });
                                        }),
                            // IconButton(
                            //   icon: Icon(FontAwesomeIcons.comment),
                            //   onPressed: (){
                            //     Navigator.of(context).pushNamed(RouteName.comment);
                            //   }
                            //   )
                            //   ],
                            // ),
                            IconButton(
                              icon: Icon(FontAwesomeIcons.share),
                              onPressed: () {
                                final RenderBox box =
                                    context.findRenderObject();
                                Share.share(
                                    'check out my website https://example.com',
                                    subject: 'Please download our app',
                                    sharePositionOrigin:
                                        box.localToGlobal(Offset.zero) &
                                            box.size);
                              },
                            )
                          ],
                        ),
                      );
                    }),

                /// [bottom date]
                Container(
                  margin: EdgeInsets.only(left: 10.0, top: 0.5),
                  // child: Column(
                  //   children: <Widget>[
                  //     Container(
                  //       margin: EdgeInsets.only(top: 2.0),
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.posts.creatdAt,
                    style: TextStyle(color: Colors.grey, fontSize: 12.0),
                  ),
                  //     )
                  //   ],
                  // ),
                ),
                Divider(
                  height: 0.5,
                ),
                // Container(
                //   height: 0.5,
                //   color: Colors.grey,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void loginHelper(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('You Need to Login'),
          actions: <Widget>[
            FlatButton(onPressed: null, child: Text('Cancel')),
            FlatButton(onPressed: null, child: Text('Login'))
          ],
        );
      },
    );
  }
}

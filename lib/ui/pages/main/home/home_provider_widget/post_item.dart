import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
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
                    onTap: () {
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
                Container(
                  margin: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
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
                                    ? () async {
                                        print('React to React so bool is' +
                                            isLiked.toString() +
                                            'to 0');
                                        var response = await DioUtils().post(
                                            Api.PARTNERDETAIL +
                                                widget.posts.userID.toString() +
                                                '/react',
                                            queryParameters: {'react': '0'});
                                        print(response);
                                        setState(() {
                                          isLiked = !isLiked;
                                        });
                                      }
                                    : () async {
                                        print('UnReact to React so bool is' +
                                            isLiked.toString() +
                                            'to 1');
                                        var response = await DioUtils().post(
                                            Api.PARTNERDETAIL +
                                                widget.posts.userID.toString() +
                                                '/react',
                                            queryParameters: {'react': '1'});
                                        print(response);
                                        setState(() {
                                          isLiked = !isLiked;
                                        });
                                      }),

                          if (widget.posts.isReacted == 1)

                            /// [like animation while user was reacted]
                            InkWell(
                                child: Icon(
                                    isLiked
                                        ? FontAwesomeIcons.heart
                                        : FontAwesomeIcons.solidHeart,
                                    color: isLiked
                                        ? Theme.of(context).iconTheme.color
                                        : Colors.red[400]),
                                onTap: isLiked
                                    ? () async {
                                        print('Unreact to React so bool is' +
                                            isLiked.toString() +
                                            'to 1');
                                        var response = await DioUtils().post(
                                            Api.PARTNERDETAIL +
                                                widget.posts.userID.toString() +
                                                '/react',
                                            queryParameters: {'react': '1'});
                                        print(response);
                                        setState(() {
                                          isLiked = !isLiked;
                                        });
                                      }
                                    : () async {
                                        print('React to unreact so bool is' +
                                            isLiked.toString() +
                                            'to 0');
                                        var response = await DioUtils().post(
                                            Api.PARTNERDETAIL +
                                                widget.posts.userID.toString() +
                                                '/react',
                                            queryParameters: {'react': '0'});
                                        print(response);
                                        setState(() {
                                          isLiked = !isLiked;
                                        });
                                      }),

                          // IconButton(
                          //   icon: Icon(FontAwesomeIcons.comment),
                          //   onPressed: (){
                          //     Navigator.of(context).pushNamed(RouteName.comment);
                          //   }
                          //   )
                        ],
                      ),
                      IconButton(
                        icon: Icon(FontAwesomeIcons.share),
                        onPressed: () {
                          Share.share(
                              'check out my website https://example.com',
                              subject: 'Look what I made!');
                        },
                      )
                    ],
                  ),
                ),

                /// [bottom date]
                Container(
                  margin: EdgeInsets.only(left: 10.0, top: 0.05),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 2.0),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          widget.posts.creatdAt,
                          style: TextStyle(color: Colors.grey, fontSize: 12.0),
                        ),
                      )
                    ],
                  ),
                ),

                Container(
                  height: 0.5,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

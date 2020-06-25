import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';

class PostItemWidget extends StatelessWidget {
  PostItemWidget(this.posts, {this.index})
    : super(key: ValueKey(posts.userID));
  
  final int index;
  final Post posts;
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
                    onTap: (){
                      int detailPageId = posts.userID;
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) => PartnerDetailPage(detailPageId)));
                    },
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Image.asset(ImageHelper.wrapAssetsLogo('MoonBlink_Cute.png'),
                          height: 40.0, 
                          ),
                          Padding(padding: EdgeInsets.only(left:10.0),
                          child: Text(posts.userName + ' id'+posts.userID.toString()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                /// [User_Image]
                Container(
                  child: Image.network(posts.profileImage, fit: BoxFit.contain,height: 200,),
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
                        if(posts.isReacted == 0)
                        /// [like animation while user unreacted] 
                        LikeButton(
                          circleColor: CircleColor(
                            start: Colors.pink, end: Colors.pinkAccent),
                          bubblesColor: BubblesColor(
                            dotPrimaryColor: Colors.pink,
                            dotSecondaryColor: Colors.pinkAccent,
                          ),
                          likeBuilder: (bool isLiked){
                            return Icon(
                              FontAwesomeIcons.heart,
                              color: isLiked ? Colors.pinkAccent : Colors.black,
                              // size: 28, 
                            );
                          },
                          likeCount: posts.reactionCount,
                          countBuilder: (int count, bool isLiked, String text) {
                          var color = isLiked ? Colors.pinkAccent : Colors.grey;
                          Widget result;
                          if (count == 0) {
                          result = Text(''
                            // "love",
                            // style: TextStyle(color: color),
                          );
                          } else
                          result = Text(
                            text,
                            style: TextStyle(color: color),
                          );
                        return result;},
                        ),

                        if(posts.isReacted == 1)
                        /// [like animation while user was reacted] 
                        LikeButton(
                          circleColor: CircleColor(
                            start: Colors.pink, end: Colors.pinkAccent),
                          bubblesColor: BubblesColor(
                            dotPrimaryColor: Colors.pink,
                            dotSecondaryColor: Colors.pinkAccent,
                          ),
                          likeBuilder: (bool isLiked){
                            return Icon(
                              FontAwesomeIcons.heart,
                              color: isLiked ? Colors.black : Colors.pinkAccent,
                              // size: 28, 
                            );
                          },
                          likeCount: posts.reactionCount,
                          countBuilder: (int count, bool isLiked, String text) {
                          var color = isLiked ? Colors.grey : Colors.pinkAccent;
                          Widget result;
                          if (count == 0) {
                          result = Text(''
                            // "love",
                            // style: TextStyle(color: color),
                          );
                          } else
                          result = Text(
                            text,
                            style: TextStyle(color: color),
                          );
                        return result;},
                        ),

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
                          onPressed: (){
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
                        child: Text(posts.creatdAt, style: TextStyle(color: Colors.grey, fontSize: 12.0),
                        ),
                      )
                    ],
                  ),
                ),

                Container(
                height: 0.5,
                color: Colors.grey,),
              ],
            ),
          ),

        ],
      ),
    );
  }

  //TODO:
  likePostRequest() async{
    await DioUtils().post(Api.PARTNERDETAIL+ posts.userID.toString() + '/react');
  }
}
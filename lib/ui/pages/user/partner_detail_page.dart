import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/booking/booking.dart';
import 'package:moonblink/base_widget/userfeed.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/pages/main/chat/chatbox_page.dart';
import 'package:moonblink/ui/pages/main/home/shimmer_indicator.dart';
import 'package:moonblink/view_model/partner_detail_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PartnerDetailPage extends StatefulWidget {
  PartnerDetailPage(this.detailPageId);
  final int detailPageId;
  @override
  _PartnerDetailPageState createState() => _PartnerDetailPageState();
}

class _PartnerDetailPageState extends State<PartnerDetailPage>{

  bool followButtonClicked = false;
  // Following state controll
  bool isFollowIn1 = false;
  PartnerUser partnerData;
  // int detailPageId;
  final RefreshController _refreshController = RefreshController();
  // final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    _refreshController.dispose();
    // _scrollController.dispose();
    super.dispose();
  } 

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<PartnerDetailModel>(
      model: PartnerDetailModel(partnerData, widget.detailPageId),
      onModelReady: (partnerModel){
        partnerModel.initData();
      },
      builder: (context, partnerModel, child){
        if (partnerModel.isBusy) {
              return ViewStateBusyWidget();
        } 
        else if (partnerModel.isError ) {
              return ViewStateErrorWidget(error: partnerModel.viewStateError, onPressed: partnerModel.initData);
        }

        return Scaffold(
          body: SmartRefresher(
              enablePullUp: false,
              controller: _refreshController,   
              header: ShimmerHeader(
                  text: Text("PullToRefresh", 
                  style: TextStyle(color: Colors.grey, fontSize: 22))),

              enablePullDown: false,
              onRefresh: () async {
                // await Future.delayed(Duration(milliseconds: 300));
                partnerModel.initData();
                _refreshController.refreshCompleted();
                partnerModel.showErrorMessage(context);
              },
              child: CustomScrollView(
              slivers: <Widget>[
                // SliverToBoxAdapter(),
                SliverAppBar(
                  /// [showing partner name]
                  title: Text(partnerModel.partnerData.partnerName),
                  pinned: true,
                  expandedHeight: 220,
                  brightness: Theme.of(context).brightness ==
                   Brightness.light ? Brightness.light: Brightness.dark,

                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.more_horiz), 
                      onPressed: (){
                        Navigator.push(context,MaterialPageRoute(
                          builder: (context) => ChatBoxPage(widget.detailPageId)
                          ));
                      })
                  ],
                  /// [background image to show here]
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    // background: Image.network(partnerModel.data.partnerCover),
                    background: Image.network(partnerModel.partnerData.prfoileFromPartner.coverImage, fit: BoxFit.cover),
                  ),
                ),

               SliverToBoxAdapter(
                  child: SizedBox(
                    height: 25,
                  ),
                ),

                SliverToBoxAdapter(      
                /// [user avatar]
                child: Hero(tag: 'UserAvatar', 
                      child: Align(
                        child: ClipOval(
                          child: SizedBox(
                            width: 100.0,
                            height: 100.0,
                            
                            child: Image.network(partnerModel.partnerData.prfoileFromPartner.profileImage, fit: BoxFit.cover,)
                          )
                        ),
                      )),
                ),
                
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 25,
                  ),
                ),

                
                SliverToBoxAdapter(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            ///[Booking Button move to class]
                            BookingButton(),
                            /// [Follow Button] different statement to show different button
                            /// Gonna get little confused, but try to think followbuton is true or false and statement
                            if(partnerModel.partnerData.isFollow == 0)
                            RaisedButton(
                              color: Theme.of(context).primaryColor,
                              highlightColor: Theme.of(context).accentColor,
                              colorBrightness: Theme.of(context).brightness,
                              splashColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                              child: followButtonClicked ?
                                      Text('Following', style: Theme.of(context).accentTextTheme.button) 
                                    : Text('Follow', style: Theme.of(context).accentTextTheme.button),
                              onPressed: followButtonClicked ? () async {
                                print('status is 1 so bool is'+followButtonClicked.toString()+'to 0');
                                await DioUtils().post(Api.PARTNERDETAIL+ partnerModel.partnerData.partnerId.toString()+ '/follow',queryParameters: {
                                'status': '0'
                                },);
                                print('stauts now is 0 and switch to follow button');
                                setState(() {
                                  followButtonClicked = !followButtonClicked;
                                });
                              } : () async {
                                print('status is 0 so bool is'+followButtonClicked.toString()+'to 1');
                                await DioUtils().post(Api.PARTNERDETAIL+ partnerModel.partnerData.partnerId.toString()+ '/follow',queryParameters: {
                                'status': '1'
                                },);
                                print('stauts now is 1 and switch to following button');
                                setState(() {
                                  followButtonClicked = !followButtonClicked;
                                });
                              },),

                            if(partnerModel.partnerData.isFollow == 1)
                            RaisedButton(
                              color: Theme.of(context).primaryColor,
                              highlightColor: Theme.of(context).accentColor,
                              colorBrightness: Theme.of(context).brightness,
                              splashColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                              child: followButtonClicked ?
                                      Text('Follow', style: Theme.of(context).accentTextTheme.button) 
                                    : Text('Following', style: Theme.of(context).accentTextTheme.button),
                              onPressed: followButtonClicked ? () async {
                                print('status is 0 so bool is'+followButtonClicked.toString()+'to 1');
                                await DioUtils().post(Api.PARTNERDETAIL+ partnerModel.partnerData.partnerId.toString()+ '/follow',queryParameters: {
                                'status': '1'
                                },);
                                print('stauts now is 1 and switch to following button');
                                setState(() {
                                  followButtonClicked = !followButtonClicked;
                                });
                              } : () async {
                                print('status is 1 so bool is'+followButtonClicked.toString()+'to 0');
                                await DioUtils().post(Api.PARTNERDETAIL+ partnerModel.partnerData.partnerId.toString()+ '/follow',queryParameters: {
                                'status': '0'
                                },);
                                print('stauts now is 0 and switch to follow button');
                                setState(() {
                                  followButtonClicked = !followButtonClicked;
                                });
                              },),
                           


                          ],
                        ),
                      ),

                    /// [info]
                    SliverToBoxAdapter(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('100 Following',
                            ),
                            Text(
                              '|',
                            ),
                            Text(
                              partnerModel.partnerData.followerCount.toString() + 'Followers'
                            )
                          ],
                        ),
                      ),
                    ),
                    
                    /// [user bio]
                    SliverToBoxAdapter(
                                      child: Padding( 
                      padding: EdgeInsets.all(25),
                      child: Text(partnerModel.partnerData.prfoileFromPartner.bios),
                      ),
                    ),

                    /// [user feed]
                    SliverToBoxAdapter(child: Feed()),

                    /// nothing just test
                    // SliverToBoxAdapter(
                    //   child: UserFeedWidget(),
                    // ),
                    ],

            ),
          ),
        );
      });
  }
}



class FollowButton extends StatelessWidget {
  // FollowButton(this.isFollow, this.model);
  // final isFollow;
  // final PartnerDetailModel model;
  bool isFollow = true;
  // FollowButton(this.isFollow) : assert(isFollow!= null);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
            onTap: isFollow ? (){
              print('0');
              isFollow = !isFollow;
            } : (){
              print('1');
              isFollow = !isFollow;
            },
              child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              // constraints: BoxConstraints(),
              decoration: BoxDecoration(
              color: Colors.red,
              border: Border.all(width: 0.1),
              borderRadius: BorderRadius.all(
                            Radius.circular(15),                    
                                  ),
                                ),
                                height: 30,
                                width: 80,
                                // color: Colors.red,
              child: isFollow ? Text('Follow') : Text('Following'),
                              ),
                            );
    // return RaisedButton(
    //   color: Theme.of(context).primaryColor,
    //   highlightColor: Theme.of(context).accentColor,
    //   splashColor: Colors.grey,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    //   child: isFollow ? Text('Follow') : Text('Following'),
    //   onPressed: isFollow ? (){
    //     print('now is what 0');
    //   } : (){
    //     print('now is what 1');
    //   }
    // );
  }
}


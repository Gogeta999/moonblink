import 'package:flutter/material.dart';

import 'package:moonblink/base_widget/userfeed.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/view_model/partner_ownProfile_model.dart';


class PartnerOwnProfilePage extends StatefulWidget {
  @override
  _PartnerOwnProfilePageState createState() => _PartnerOwnProfilePageState();
}

class _PartnerOwnProfilePageState extends State<PartnerOwnProfilePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  PartnerUser partnerData;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderWidget<PartnerOwnProfileModel>(
      model: PartnerOwnProfileModel(partnerData),
      onModelReady: (partnerModel){
        partnerModel.initData();
      },
      builder: (context, partnerModel, child){
        if(partnerModel.isBusy){
          return ViewStateBusyWidget();
        }
        else if(partnerModel.isError && partnerModel.isEmpty){
          return ViewStateErrorWidget(error: partnerModel.viewStateError, onPressed: partnerModel.initData);
        }
        return Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
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
                          Navigator.of(context).pushNamed(RouteName.updateprofile);
                        })
                    ],
                    /// [background image to show here]
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      // background: Image.asset(ImageHelper.wrapAssetsImage('images.jpg'), fit: BoxFit.cover,),
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

                  /// TODO: [add booking and follow function here]
                  SliverToBoxAdapter(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              RaisedButton(
                                color: Theme.of(context).accentColor,
                                highlightColor: Theme.of(context).highlightColor,
                                colorBrightness: Theme.of(context).brightness,
                                splashColor: Theme.of(context).splashColor,
                                child: Text('Following List', style: Theme.of(context).accentTextTheme.button.copyWith(wordSpacing: 6),),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                                onPressed: (){},
                                ),
                              
                              
                              RaisedButton(
                                color: Theme.of(context).accentColor,
                                highlightColor: Theme.of(context).highlightColor,
                                colorBrightness: Theme.of(context).brightness,
                                splashColor: Theme.of(context).splashColor,
                                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                child: Text('Follower List', style: Theme.of(context).accentTextTheme.button.copyWith(wordSpacing: 6),),
                                onPressed: () async {
                                    // await DioUtils().post(Api.PARTNERDETAIL+ partnerModel.partnerData.partnerId.toString()+ '/follow',queryParameters: {
                                    //   'status': '0',
                                    
                                    // });
                                  },
                                  ),
                              // if(partnerModel.partnerData.isFollow == 0)
                              // RaisedButton(
                              //   color: Theme.of(context).primaryColor,
                              //   highlightColor: Theme.of(context).accentColor,
                              //   colorBrightness: Theme.of(context).brightness,
                              //   splashColor: Colors.grey,
                              //   shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              //   child: Text('Follow'),
                              //   onPressed: () async {
                              //     await DioUtils().post(Api.PARTNERDETAIL+ partnerModel.partnerData.partnerId.toString()+ '/follow', queryParameters: {
                              //       'status': '1',
                              //     });
                              //   },
                              //     ),
                            ],
                          ),
                        ),

                  /// [info]
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(partnerModel.partnerData.followingCount.toString() + 'Following'),
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
      );

      },
    );
  }
}



	

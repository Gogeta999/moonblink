import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moonblink/base_widget/MoonBlink_Box_widget.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/imageview.dart';

import 'package:moonblink/base_widget/userfeed.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/ownprofile.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/partner_ownProfile_model.dart';

class PartnerOwnProfilePage extends StatefulWidget {
  @override
  _PartnerOwnProfilePageState createState() => _PartnerOwnProfilePageState();
}

class _PartnerOwnProfilePageState extends State<PartnerOwnProfilePage>
    with AutomaticKeepAliveClientMixin {
  int usertype = StorageManager.sharedPreferences.getInt(mUserType);
  @override
  bool get wantKeepAlive => true;
  OwnProfile partnerData;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderWidget<PartnerOwnProfileModel>(
      model: PartnerOwnProfileModel(partnerData),
      onModelReady: (partnerModel) {
        partnerModel.initData();
      },
      builder: (context, partnerModel, child) {
        if (partnerModel.isBusy) {
          return ViewStateBusyWidget();
        } else if (partnerModel.isError || partnerModel.isEmpty) {
          return ViewStateErrorWidget(
              error: partnerModel.viewStateError,
              onPressed: partnerModel.initData);
        }
        // var userName = StorageManager.sharedPreferences.getString(mLoginName);
        // int userid = StorageManager.sharedPreferences.getInt(mUserId);
        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.black,
                actions: [
                  AppbarLogo(),
                ],
                leading: IconButton(
                  icon: SvgPicture.asset(
                    back,
                    semanticsLabel: 'back',
                    color: Colors.white,
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                bottom: PreferredSize(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).accentColor,
                          // spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                    ),
                    height: 5,
                  ),
                  preferredSize: Size.fromHeight(8),
                ),
              ),
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 240,
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageView(partnerModel
                                    .partnerData.prfoileFromPartner.coverImage),
                              ),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: partnerModel
                                  .partnerData.prfoileFromPartner.coverImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => CachedLoader(),
                              errorWidget: (context, url, error) =>
                                  CachedError(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 7.5,
                          padding: EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 2, color: Colors.black),
                              bottom: BorderSide(width: 2, color: Colors.black),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: Center(
                                          child: Text(
                                            partnerModel
                                                .partnerData.partnerName,
                                            style: TextStyle(fontSize: 26),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 180, left: 20),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageView(partnerModel
                                .partnerData.prfoileFromPartner.profileImage),
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: partnerModel
                              .partnerData.prfoileFromPartner.profileImage,
                          imageBuilder: (context, item) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 2, color: Colors.black),
                                boxShadow: [
                                  BoxShadow(
                                      // blurRadius: 10,
                                      color: Colors.black,
                                      offset: Offset(0, 5),
                                      spreadRadius: 2)
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundImage: item,
                              ),
                            );
                          },
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 25,
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 20,
                ),
              ),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ///[Booking Button move to class]
                        // BookingButton(),

                        ///[Follow Button]
                        MBButtonWidget(
                          title: G.of(context).updatePartnerProfile,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                RouteName.updateprofile,
                                arguments: partnerModel.partnerData);
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),

                        ///[Followers total]
                        MBBoxWidget(
                          text: G.of(context).follower,
                          followers:
                              partnerModel.partnerData.followerCount.toString(),
                        ),
                      ],
                    ),
                    MBAverageWidget(
                      title: G.of(context).averageRating,
                      averageRating: partnerModel.partnerData.rating,
                    )
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 20,
                ),
              ),

              /// [user bio]
              SliverToBoxAdapter(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 2, color: Colors.black),
                        bottom: BorderSide(width: 2, color: Colors.black),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        partnerModel.partnerData.prfoileFromPartner.bios,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    )),
              ),

              /// [user feed]
              if (usertype != 0)
                SliverToBoxAdapter(
                    child: Feed(
                        partnerModel.partnerData.partnerName,
                        partnerModel.partnerData.partnerId,
                        partnerModel.partnerData.rating)),

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

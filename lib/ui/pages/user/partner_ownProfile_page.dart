import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/imageview.dart';

import 'package:moonblink/base_widget/userfeed.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/partner_ownProfile_model.dart';

class PartnerOwnProfilePage extends StatefulWidget {
  @override
  _PartnerOwnProfilePageState createState() => _PartnerOwnProfilePageState();
}

class _PartnerOwnProfilePageState extends State<PartnerOwnProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  PartnerUser partnerData;
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
        } else if (partnerModel.isError && partnerModel.isEmpty) {
          return ViewStateErrorWidget(
              error: partnerModel.viewStateError,
              onPressed: partnerModel.initData);
        }
        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                /// [showing partner name]
                title: Text(partnerModel.partnerData.partnerName),
                pinned: true,
                expandedHeight: Platform.isAndroid ? 220 : 0,
                brightness: Theme.of(context).brightness == Brightness.light
                    ? Brightness.light
                    : Brightness.dark,

                actions: <Widget>[
                  GestureDetector(
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          G.of(context).updatePartnerProfile,
                        )),
                    onTap: () {
                      Navigator.of(context).pushNamed(RouteName.updateprofile,
                          arguments: partnerModel.partnerData);
                    },
                  )
                ],

                /// [background image to show here]
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  // background: Image.asset(ImageHelper.wrapAssetsImage('images.jpg'), fit: BoxFit.cover,),
                  background: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageView(partnerModel
                                .partnerData.prfoileFromPartner.coverImage),
                          ));
                    },
                    child: CachedNetworkImage(
                      imageUrl: partnerModel
                          .partnerData.prfoileFromPartner.coverImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CachedLoader(),
                      errorWidget: (context, url, error) => CachedError(),
                    ),
                  ),
                ),
              ),

              if (Platform.isIOS)
                SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: GestureDetector(
                      child: CachedNetworkImage(
                        imageUrl: partnerModel
                            .partnerData.prfoileFromPartner.coverImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => CachedLoader(),
                        errorWidget: (context, url, error) => CachedError(),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageView(partnerModel
                                  .partnerData.prfoileFromPartner.coverImage),
                            ));
                      },
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 25,
                ),
              ),

              SliverToBoxAdapter(
                /// [user avatar]
                child: Hero(
                    tag: 'UserAvatar',
                    child: Align(
                      child: ClipOval(
                          child: SizedBox(
                        width: 100.0,
                        height: 100.0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageView(partnerModel
                                      .partnerData
                                      .prfoileFromPartner
                                      .profileImage),
                                ));
                          },
                          child: CachedNetworkImage(
                            imageUrl: partnerModel
                                .partnerData.prfoileFromPartner.profileImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => CachedLoader(),
                            errorWidget: (context, url, error) => CachedError(),
                          ),
                        ),
                      )),
                    )),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 25,
                ),
              ),

              // SliverToBoxAdapter(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: <Widget>[],
              //   ),
              // ),

              /// [info]
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(G.of(context).profiletext +
                          partnerModel.partnerData.followerCount.toString() +
                          G.of(context).profilefollowernow)
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/booking/booking.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/base_widget/userfeed.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/ui/pages/main/home/shimmer_indicator.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/partner_detail_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PartnerDetailPage extends StatefulWidget {
  PartnerDetailPage(this.detailPageId);
  final int detailPageId;
  @override
  _PartnerDetailPageState createState() => _PartnerDetailPageState();
}

class _PartnerDetailPageState extends State<PartnerDetailPage> {
  bool followButtonClicked = false;
  // Following state controll
  // bool isFollowIn1 = false;
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

  userstatus(status) {
    switch (status) {
      case (0):
        return Center(
            child: Text(S.of(context).statusavailable,
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)));
        break;
      case (1):
        return Center(
            child: Text(S.of(context).statusbusy,
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
        break;
      case (2):
        return Center(
            child: Text(S.of(context).statuserror,
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold)));
        break;
      case (3):
        return Center(
            child: Text(S.of(context).statusingame,
                style: TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownId = StorageManager.sharedPreferences.getInt(mUserId);
    return Scaffold(
      body: ProviderWidget<PartnerDetailModel>(
          model: PartnerDetailModel(partnerData, widget.detailPageId),
          onModelReady: (partnerModel) {
            partnerModel.initData();
          },
          builder: (context, partnerModel, child) {
            // int followerCount = partnerModel.partnerData.followerCount;
            if (partnerModel.isBusy) {
              return ViewStateBusyWidget();
            } else if (partnerModel.isError) {
              return ViewStateErrorWidget(
                  error: partnerModel.viewStateError,
                  onPressed: partnerModel.initData);
            }
            return SmartRefresher(
              enablePullUp: false,
              controller: _refreshController,
              header: ShimmerHeader(
                  text: Text(S.of(context).pullDownToRefresh,
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
                    expandedHeight: Platform.isAndroid ? 220 : 0,
                    brightness: Theme.of(context).brightness == Brightness.light
                        ? Brightness.light
                        : Brightness.dark,

                    actions: <Widget>[
                      userstatus(partnerModel.partnerData.status),
                      IconButton(
                          icon: Icon(
                            IconFonts.messageIcon,
                            size: 40,
                          ),
                          onPressed: widget.detailPageId == ownId
                              ? null
                              : () {
                                  Navigator.pushReplacementNamed(
                                      context, RouteName.chatBox,
                                      arguments: widget.detailPageId);
                                }),
                      if (ownId != widget.detailPageId)
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () => CustomBottomSheet.showUserManageContent(
                            buildContext: context,
                            onReport: () async {
                              ///Reporting user
                              try {
                                await MoonBlinkRepository.reportUser(widget.detailPageId);
                                ///Api call success
                                showToast('Thanks for making our MoonBlink\'s Universe clean and tidy. We will act on this user within 24 hours.');
                                Navigator.pop(context);
                              } catch (e) {
                                showToast('Sorry, $e');
                              }
                            },
                            onBlock: () async {
                              ///Blocking user
                              Navigator.pop(context);
                              Navigator.pop(context, widget.detailPageId);//result != null will block
                            },
                            onDismiss: () => print('Dismissing BottomSheet')),
                      )
                    ],

                    /// [background image to show here]
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      // background: Image.network(partnerModel.data.partnerCover),
                      background: GestureDetector(
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
                                      builder: (context) => ImageView(
                                          partnerModel.partnerData
                                              .prfoileFromPartner.profileImage),
                                    ));
                              },
                              child: CachedNetworkImage(
                                imageUrl: partnerModel.partnerData
                                    .prfoileFromPartner.profileImage,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => CachedLoader(),
                                errorWidget: (context, url, error) =>
                                    CachedError(),
                              ),
                            ),
                          )),
                        )),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 20,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ///[Booking Button move to class]
                        BookingButton(),

                        /// [Follow Button] different statement to show different button
                        RaisedButton(
                          color: Theme.of(context).accentColor,
                          highlightColor: Theme.of(context).accentColor,
                          colorBrightness: Theme.of(context).brightness,
                          splashColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: partnerModel.partnerData.isFollow == 0
                              ? Text(S.of(context).follow,
                                  style:
                                      Theme.of(context).accentTextTheme.button)
                              : Text(S.of(context).following,
                                  style:
                                      Theme.of(context).accentTextTheme.button),
                          onPressed: partnerModel.partnerData.isFollow == 0
                              ? () async {
                                  print('status is 0 so bool is' +
                                      followButtonClicked.toString() +
                                      'to false');
                                  await DioUtils().post(
                                    Api.SocialRequest +
                                        partnerModel.partnerData.partnerId
                                            .toString() +
                                        '/follow',
                                    queryParameters: {'status': '1'},
                                  );
                                  print(
                                      'stauts now is 1 and switch to following button');
                                  setState(() {
                                    print(
                                        '${partnerModel.partnerData.followerCount} is plus 1 follower');
                                    partnerModel.partnerData.followerCount += 1;
                                    print(
                                        'so now is ${partnerModel.partnerData.followerCount}');
                                    partnerModel.partnerData.isFollow = 1;
                                  });
                                }
                              : () async {
                                  print('status is 1 so bool is' +
                                      followButtonClicked.toString() +
                                      'to false');
                                  await DioUtils().post(
                                    Api.SocialRequest +
                                        partnerModel.partnerData.partnerId
                                            .toString() +
                                        '/follow',
                                    queryParameters: {'status': '0'},
                                  );
                                  print(
                                      'stauts now is 0 and switch to follow button');
                                  setState(() {
                                    print(
                                        '${partnerModel.partnerData.followerCount} is minus 1 follower');
                                    partnerModel.partnerData.followerCount -= 1;
                                    print(
                                        'so now is ${partnerModel.partnerData.followerCount}');
                                    partnerModel.partnerData.isFollow = 0;
                                  });
                                },
                        ),
                      ],
                    ),
                  ),

                  /// [info]

                  /// [user bio]
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 15, 0, 15),
                      child: Text(
                          partnerModel.partnerData.prfoileFromPartner.bios),
                    ),
                  ),
                  // SliverToBoxAdapter(child: SizedBox(height: 1)),
                  SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Text(partnerModel.partnerData.reactionCount
                                  .toString() +
                              '  ' +
                              S.of(context).likes),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Text(partnerModel.partnerData.followerCount
                                  .toString() +
                              '  ' +
                              S.of(context).follower),
                        ),
                      ],
                    ),
                  ),

                  /// [user feed]
                  SliverToBoxAdapter(
                      child: Feed(
                          partnerModel.partnerData.partnerName,
                          partnerModel.partnerData.partnerId,
                          partnerModel.partnerData.rating)),
                ],
              ),
            );
          }),
    );
  }
}

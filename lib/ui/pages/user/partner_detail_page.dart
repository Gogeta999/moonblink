import 'package:flutter/material.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/booking/booking.dart';
import 'package:moonblink/base_widget/userfeed.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
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
            child: Text("Available",
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)));
        break;
      case (1):
        return Center(
            child: Text("Busy",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
        break;
      case (2):
        return Center(
            child: Text("Connection Error",
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold)));
        break;
      case (3):
        return Center(
            child: Text("In Game",
                style: TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    expandedHeight: 220,
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
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChatBoxPage(widget.detailPageId)));
                          }),
                    ],

                    /// [background image to show here]
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      // background: Image.network(partnerModel.data.partnerCover),
                      background: Image.network(
                          partnerModel
                              .partnerData.prfoileFromPartner.coverImage,
                          fit: BoxFit.cover),
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
                                  child: Image.network(
                                    partnerModel.partnerData.prfoileFromPartner
                                        .profileImage,
                                    fit: BoxFit.cover,
                                  ))),
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Text(partnerModel.partnerData.partnerName +
                                ' have ' +
                                '${partnerModel.partnerData.followerCount}' +
                                ' followers'),
                          )
                        ],
                      ),
                    ),
                  ),

                  /// [user bio]
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text(
                          partnerModel.partnerData.prfoileFromPartner.bios),
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

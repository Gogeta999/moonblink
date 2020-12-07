import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/MoonBlink_Box_widget.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/base_widget/intro/flutter_intro.dart';
import 'package:moonblink/base_widget/userfeed.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/ui/helper/tutorial.dart';
import 'package:moonblink/ui/pages/booking_page/booking_page.dart';
import 'package:moonblink/ui/pages/main/home/shimmer_indicator.dart';
import 'package:moonblink/ui/pages/user/follower_page.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/partner_detail_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final String report = 'assets/icons/report.svg';

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
  Intro intro;

  _PartnerDetailPageState() {
    intro = Intro(
      stepCount: 6,

      /// use defaultTheme, or you can implement widgetBuilder function yourself
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          G.current.tutorialDetail1,
          G.current.tutorialDetail2,
          G.current.tutorialDetail3,
          G.current.tutorialDetail4,
          G.current.tutorialDetail5,
          G.current.tutorialDetail6,
        ],
        buttonTextBuilder: (curr, total) {
          return curr < total - 1 ? 'Next' : 'Finish';
        },
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    Timer(Duration(microseconds: 0), () {
      intro.dispose();
    });
    // _scrollController.dispose();
    super.dispose();
  }

  //Rating Box
  void gameprofiledialog(PartnerUser partnerModel, index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        // title: Text(partnerModel.gameprofile[index].gameName),
        contentPadding: EdgeInsets.zero,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(partnerModel.gameprofile[index].gameName),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageView(
                        partnerModel.gameprofile[index].skillCoverImage),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                ),
                width: MediaQuery.of(context).size.width,
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    partnerModel.gameprofile[index].skillCoverImage,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(G.of(context).rank),
                Text(":"),
                Text(partnerModel.gameprofile[index].level)
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(G.of(context).playerid),
                Text(":"),
                GestureDetector(
                  onTap: () {
                    FlutterClipboard.copy(
                            partnerModel.gameprofile[index].playerId)
                        .then(
                      (value) {
                        showToast(G.of(context).toastcopy);
                        print('copied');
                      },
                    );
                  },
                  child: Text(partnerModel.gameprofile[index].playerId),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
                ),
                child: Text(
                  G.of(context).okay,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  reportuser() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        width: 30,
        height: 30,
        child: IconButton(
          key: intro.keys[5],
          // iconSize: 40,
          //splashRadius: 20,
          icon: SvgPicture.asset(
            report,
            fit: BoxFit.fill,
            color: Theme.of(context).accentColor,
            semanticsLabel: 'report',
          ),
          // iconSize: 18,
          onPressed: () => CustomBottomSheet.showUserManageContent(
              buildContext: context,
              onReport: () async {
                ///Reporting user
                try {
                  await MoonBlinkRepository.reportUser(widget.detailPageId);

                  ///Api call success
                  showToast(G.of(context).toastreport);
                  Navigator.pop(context);
                } catch (e) {
                  showToast('Sorry, $e');
                }
              },
              onBlock: () async {
                ///Blocking user
                Navigator.pop(context);
                Navigator.pop(
                    context, widget.detailPageId); //result != null will block
              },
              onDismiss: () => print('Dismissing BottomSheet')),
        ),
      ),
    );
  }

  userstatus(status) {
    switch (status) {
      case (0):
        return Center(
            child: Text(G.of(context).statusavailable,
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)));
        break;
      case (1):
        return Center(
            child: Text(G.of(context).statusbusy,
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
        break;
      case (2):
        return Center(
            child: Text(G.of(context).statuserror,
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)));
        break;
      case (3):
        return Center(
            child: Text(G.of(context).statusingame,
                style: TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold)));
        break;
    }
  }
  // void followButtonClick(){

  // }
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
            bool showtuto =
                StorageManager.sharedPreferences.getBool(userdetailtuto);
            // if (showtuto) {
            Timer(Duration(microseconds: 0), () {
              intro.start(context);
            });
            // StorageManager.sharedPreferences.setBool(userdetailtuto, false);
            // }
            void followingRequest(bool newValue) async {
              print('status is 0 so bool is' +
                  followButtonClicked.toString() +
                  'to false');
              await DioUtils().post(
                Api.SocialRequest +
                    partnerModel.partnerData.partnerId.toString() +
                    '/follow',
                queryParameters: {'status': '1'},
              );
              print('stauts now is 1 and switch to following button');
              setState(() {
                print(
                    '${partnerModel.partnerData.followerCount} is plus 1 follower');
                partnerModel.partnerData.followerCount += 1;
                print('so now is ${partnerModel.partnerData.followerCount}');
                partnerModel.partnerData.isFollow = 1;
                followButtonClicked = newValue;
              });
            }

            void unFollowRequest(bool newValue) async {
              print('status is 1 so bool is' +
                  followButtonClicked.toString() +
                  'to false');
              await DioUtils().post(
                Api.SocialRequest +
                    partnerModel.partnerData.partnerId.toString() +
                    '/follow',
                queryParameters: {'status': '0'},
              );
              print('stauts now is 0 and switch to follow button');
              setState(() {
                print(
                    '${partnerModel.partnerData.followerCount} is minus 1 follower');
                partnerModel.partnerData.followerCount -= 1;
                print('so now is ${partnerModel.partnerData.followerCount}');
                partnerModel.partnerData.isFollow = 0;
                followButtonClicked = newValue;
              });
            }

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
                  text: Text(G.of(context).pullDownToRefresh,
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
                    leading: IconButton(
                      icon: SvgPicture.asset(
                        back,
                        semanticsLabel: 'back',
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).accentColor
                            : Colors.white,
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
                              offset:
                                  Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        height: 5,
                      ),
                      preferredSize: Size.fromHeight(8),
                    ),
                    backgroundColor: Colors.black,
                    //toolbarHeight: kToolbarHeight - 5,
                    // leading: IconButton(
                    //   icon: Icon(Icons.backspace),
                    //   onPressed: () => Navigator.pop(context),
                    // ),
                    actions: [
                      AppbarLogo(),
                    ],
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
                                        .partnerData
                                        .prfoileFromPartner
                                        .coverImage),
                                  ),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: partnerModel.partnerData
                                      .prfoileFromPartner.coverImage,
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
                                  top:
                                      BorderSide(width: 2, color: Colors.black),
                                  bottom:
                                      BorderSide(width: 2, color: Colors.black),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.4,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    // crossAxisAlignment:
                                    //     CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            child: Center(
                                              child: Text(
                                                partnerModel
                                                    .partnerData.partnerName,
                                                style: TextStyle(fontSize: 26),
                                              ),
                                            ),
                                          ),
                                          if (ownId != widget.detailPageId)
                                            reportuser(),
                                        ],
                                      ),
                                      userstatus(
                                          partnerModel.partnerData.status)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 180, left: 20),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageView(partnerModel
                                    .partnerData
                                    .prfoileFromPartner
                                    .profileImage),
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
                                    border: Border.all(
                                        width: 2, color: Colors.black),
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
                            MB2StateButtonWidget(
                              key: intro.keys[0],
                              active: partnerModel.partnerData.isFollow == 0
                                  ? true
                                  : false,
                              trueText: G.of(context).follow,
                              falseText: G.of(context).following,
                              onChanged: widget.detailPageId == ownId
                                  ? null
                                  : partnerModel.partnerData.isFollow == 0
                                      ? followingRequest
                                      : unFollowRequest,
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            ///[Followers total]
                            MBBoxWidget(
                              key: intro.keys[1],
                              ontap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowerPage(
                                      partnerModel.partnerId,
                                      partnerModel.partnerData.partnerName),
                                ),
                              ),
                              text: G.of(context).follower,
                              followers: partnerModel.partnerData.followerCount
                                  .toString(),
                            ),
                          ],
                        ),
                        MBAverageWidget(
                          key: intro.keys[2],
                          title: G.of(context).averageRating,
                          averageRating: partnerModel.partnerData.rating,
                        )
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ///[Real Button]
                        // BookingButton(),

                        ///StaticButton
                        MBButtonWidget(
                            key: intro.keys[3],
                            title: G.of(context).booking,
                            onTap: widget.detailPageId == ownId
                                ? () {
                                    showToast(G.of(context).cannotbookself);
                                  }
                                : () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => BookingPage(
                                                  partnerId: partnerModel
                                                      .partnerData.partnerId,
                                                  partnerName: partnerModel
                                                      .partnerData.partnerName,
                                                  partnerBios: partnerModel
                                                      .partnerData
                                                      .prfoileFromPartner
                                                      .bios,
                                                  partnerProfile: partnerModel
                                                      .partnerData
                                                      .prfoileFromPartner
                                                      .profileImage,
                                                  // partnerUser:
                                                  //     partnerModel.partnerData,
                                                )));
                                    // Navigator.pushNamed(
                                    //     context, RouteName.booking,
                                    //     arguments: partnerModel.partnerData);
                                  }),

                        MBButtonWidget(
                            key: intro.keys[4],
                            title: G.of(context).tabChat,
                            onTap: widget.detailPageId == ownId
                                ? () {
                                    showToast(G.of(context).cannotchatself);
                                  }
                                : () {
                                    Navigator.pushReplacementNamed(
                                        context, RouteName.chatBox,
                                        arguments: widget.detailPageId);
                                  }),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 20,
                    ),
                  ),
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(horizontal: 30),
                  //     child: MBButtonWidget(
                  //       title: "Game Profile",
                  //       onTap: () {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => PartnerGameProfilePage(
                  //               gameprofile:
                  //                   partnerModel.partnerData.gameprofile,
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),
                  // SliverToBoxAdapter(
                  //   child: SizedBox(
                  //     height: 20,
                  //   ),
                  // ),

                  /// [user bio]
                  // if (partnerModel.partnerData.prfoileFromPartner.bios != "")
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 1, color: Colors.black),
                              bottom: BorderSide(width: 1, color: Colors.black),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              partnerModel.partnerData.prfoileFromPartner.bios,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                        ),

                        ///[game profiles]
                        if (partnerModel.partnerData.gameprofile.isNotEmpty)
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border(
                                // top: BorderSide(width: 2, color: Colors.black),
                                bottom:
                                    BorderSide(width: 1, color: Colors.black),
                              ),
                            ),
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    partnerModel.partnerData.gameprofile.length,
                                // itemCount: 30,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 15),
                                    child: GestureDetector(
                                      onTap: () => gameprofiledialog(
                                          partnerModel.partnerData, index),
                                      child: Column(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: partnerModel.partnerData
                                                .gameprofile[index].gameicon,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    CircleAvatar(
                                              radius: 33,
                                              backgroundColor: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              child: CircleAvatar(
                                                radius: 32,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                backgroundImage: imageProvider,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(partnerModel.partnerData
                                              .gameprofile[index].gameName),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          )
                      ],
                    ),
                  ),

                  /// [user feed]
                  SliverToBoxAdapter(
                      child: Feed(
                          partnerModel.partnerData.partnerName,
                          partnerModel.partnerData.partnerId,
                          partnerModel.partnerData.rating,
                          partnerModel.partnerData
                              .ordertaking) /*Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(G.of(context).history,
                                    style: Theme.of(context).textTheme.button),
                              ),
                              Divider(thickness: 2, color: Colors.black),
                              Expanded(
                                child: PartnerGameHistoryWidget(
                                    partnerModel.partnerData.partnerName,
                                    partnerModel.partnerData.partnerId),
                              ),
                            ],
                          ))*/ /*Feed(
                          partnerModel.partnerData.partnerName,
                          partnerModel.partnerData.partnerId,
                          partnerModel.partnerData.rating)*/
                      ),
                ],
              ),
            );
          }),
    );
  }
}

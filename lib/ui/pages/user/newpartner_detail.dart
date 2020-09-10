import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/MoonBlink_Box_widget.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
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
import 'package:moonblink/ui/helper/encrypt.dart';
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
                    color: Colors.orange, fontWeight: FontWeight.bold)));
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
                    backgroundColor: Colors.black,
                    toolbarHeight: kToolbarHeight - 5,
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
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border(
                                  top:
                                      BorderSide(width: 2, color: Colors.black),
                                  bottom:
                                      BorderSide(width: 2, color: Colors.black),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 80),
                                    child: Text(
                                      partnerModel.partnerData.partnerName,
                                      style: TextStyle(fontSize: 26),
                                    ),
                                  ),
                                  userstatus(partnerModel.partnerData.status)
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
                                      .partnerData
                                      .prfoileFromPartner
                                      .coverImage),
                                ));
                          },
                        ),
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
                              active: partnerModel.partnerData.isFollow == 0
                                  ? true
                                  : false,
                              trueText: G.of(context).follow,
                              falseText: G.of(context).following,
                              onChanged: partnerModel.partnerData.isFollow == 0
                                  ? followingRequest
                                  : unFollowRequest,
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            ///[Followers total]
                            MBBoxWidget(
                              text: G.of(context).follower,
                              followers: partnerModel.partnerData.followerCount
                                  .toString(),
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
                  SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // BookingButton(),
                        MBButtonWidget(
                            title: G.of(context).booking,
                            onTap: widget.detailPageId == ownId
                                ? () {
                                    showToast('Your Can\'t book yourself ');
                                  }
                                : () {
                                    Navigator.pushNamed(
                                        context, RouteName.booking,
                                        arguments: partnerModel.partnerData);
                                  }),
                        // MBButtonWidget(
                        //   title: G.of(context).booking,
                        //   onTap: () {
                        //     showToast('1');
                        //   },
                        // ),
                        MBButtonWidget(
                            title: G.of(context).tabChat,
                            onTap: widget.detailPageId == ownId
                                ? () {
                                    showToast('Your Can\'t chat yourself ');
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

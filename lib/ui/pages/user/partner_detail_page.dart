import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/MoonBlink_Box_widget.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/base_widget/userfeed.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/ui/pages/main/home/shimmer_indicator.dart';
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
  @override
  void dispose() {
    _refreshController.dispose();
    // _scrollController.dispose();
    super.dispose();
  }

  // //Rating Box
  // void rating(bookingid) {
  //   var rate = 5.0;
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return ProviderWidget<RateModel>(
  //         model: RateModel(),
  //         builder: (context, model, child) {
  //           return new AlertDialog(
  //             title: Text(G.of(context).pleaseRatingForThisGame),
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(20.0)),
  //             content: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               mainAxisSize: MainAxisSize.min,
  //               children: <Widget>[
  //                 SmoothStarRating(
  //                   starCount: 5,
  //                   rating: rate,
  //                   color: Theme.of(context).accentColor,
  //                   isReadOnly: false,
  //                   size: 30,
  //                   filledIconData: Icons.star,
  //                   halfFilledIconData: Icons.star_half,
  //                   defaultIconData: Icons.star_border,
  //                   allowHalfRating: true,
  //                   spacing: 2.0,
  //                   //star value
  //                   onRated: (value) {
  //                     print("rating value -> $value");
  //                     setState(() {
  //                       rate = value;
  //                     });
  //                   },
  //                 ),
  //                 SizedBox(
  //                   height: 30,
  //                 ),
  //                 //Comment for Rating
  //                 Container(
  //                     margin: EdgeInsets.fromLTRB(0, 1.5, 0, 1.5),
  //                     padding: EdgeInsets.all(8.0),
  //                     decoration: BoxDecoration(
  //                       border: Border.all(width: 1.5, color: Colors.grey),
  //                       borderRadius: BorderRadius.all(Radius.circular(12.0)),
  //                     ),
  //                     child: TextField(
  //                       controller: comment,
  //                       textInputAction: TextInputAction.done,
  //                       decoration: InputDecoration(
  //                         labelText: G.of(context).labelcomment,
  //                       ),
  //                     ))
  //               ],
  //             ),
  //             //Summit Rating
  //             actions: [
  //               FlatButton(
  //                   child: Text(G.of(context).submit),
  //                   onPressed: () {
  //                     model
  //                         .rate(widget.detailPageId, bookingid, rate,
  //                             comment.text)
  //                         .then((value) => value
  //                             ? Navigator.pop(context)
  //                             : showToast(G.of(context).toastratingfail));
  //                   })
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  reportuser() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        width: 30,
        height: 30,
        child: IconButton(
          // iconSize: 40,
          //splashRadius: 20,
          icon: SvgPicture.asset(
            report,
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
                  showToast(
                      'Thanks for making our MoonBlink\'s Universe clean and tidy. We will act on this user within 24 hours.');
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
                        InkWell(
                          onTap: () => Navigator.pushNamed(
                              context, RouteName.userRating,
                              arguments: partnerModel.partnerId),
                          child: MBAverageWidget(
                            title: G.of(context).averageRating,
                            averageRating: partnerModel.partnerData.rating,
                          ),
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
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 20,
                    ),
                  ),

                  /// [user bio]
                  if (partnerModel.partnerData.prfoileFromPartner.bios != "")
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(width: 2, color: Colors.black),
                                bottom:
                                    BorderSide(width: 2, color: Colors.black),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                partnerModel
                                    .partnerData.prfoileFromPartner.bios,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                          ),
                          Row(
                            children: [],
                          )
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

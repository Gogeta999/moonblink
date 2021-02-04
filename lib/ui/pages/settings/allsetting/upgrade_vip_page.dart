import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/container/cardContainer.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/customDialog_widget.dart';
import 'package:moonblink/base_widget/horizontalPager.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/vip_data.dart';
import 'package:moonblink/models/vipmodel.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class UpgradeVIP extends StatefulWidget {
  @override
  _UpgradeVIPState createState() => _UpgradeVIPState();
}

class _UpgradeVIPState extends State<UpgradeVIP> {
  ///Scroll Controller
  PageController pagecontroller = PageController();
  ScrollController _scrollController = new ScrollController();
  int currentpage = 0;

  ///Remote Data
  int _selectedPlan = 0;
  Wallet _wallet = Wallet(value: 0);
  // bool _enableToBuy = true;

  ///UI
  var error;
  bool _isPageLoading = true;
  bool _isPageError = false;

  List<VIPprice> prices = [];
  VipData uservip;
  String _gender = '';

  @override
  void initState() {
    _initData();
    super.initState();
  }

  void _initData() {
    Future.wait([
      _initUserWallet(),
      _getVippice(),
      _getVIPdata(),
    ], eagerError: true)
        .then((value) {
      setState(() {
        _isPageLoading = false;
      });
    });
  }

  Future<void> _initUserWallet() async {
    MoonBlinkRepository.getUserWallet().then((value) {
      setState(() {
        this._wallet = value;
      });
    }, onError: (e) {
      setState(() {
        this.error = e;
        _isPageError = true;
      });
    });
  }

  Future<void> _getVippice() async {
    MoonBlinkRepository.getVIPList().then((value) {
      setState(() {
        prices = value;
      });
    });
  }

  Future<void> _getVIPdata() async {
    MoonBlinkRepository.getUserVip().then((value) {
      setState(() {
        uservip = value;
      });
      pagecontroller =
          PageController(initialPage: value.vip != 0 ? value.vip - 1 : 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(
        title: Text(G.current.upgradeVipAppBarTitle),
      ),
      body: _isPageLoading || uservip == null
          ? CupertinoActivityIndicator()
          : NestedScrollView(
              controller: _scrollController,
              // shrinkWrap: true,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        ClipPath(
                          clipper: OvalBottomBorderClipper(),
                          child: Container(
                            height: 150,
                            color: Theme.of(context).accentColor,
                            child: Container(),
                          ),
                        ),
                        HorizontalCardPager(
                          initialPage: uservip.vip != 0 ? uservip.vip - 1 : 0,
                          onPageChanged: (page) {
                            setState(() {
                              currentpage = page.toInt();
                            });
                            pagecontroller.jumpToPage(
                              page.round(),
                            );
                          },
                          onSelectedItem: (page) {
                            if (uservip.vip < currentpage + 1) {
                              confirmDialog(
                                  context,
                                  (currentpage + 1),
                                  prices[currentpage].updatecost,
                                  uservip.vipRenew,
                                  prices[currentpage].promotion,
                                  _wallet);
                            } else {
                              showToast("You already bought this");
                            }
                          },
                          items: [
                            ItemContainer(
                              child: itemCard(
                                  'assets/images/vip1.jpg',
                                  prices[0].vip,
                                  prices[0].expiretime,
                                  prices[0].updatecost,
                                  prices[0].promotion,
                                  uservip.vipRenew,
                                  context),
                            ),
                            ItemContainer(
                              child: itemCard(
                                  'assets/images/vip2.jpg',
                                  prices[1].vip,
                                  prices[1].expiretime,
                                  prices[1].updatecost,
                                  prices[1].promotion,
                                  uservip.vipRenew,
                                  context),
                            ),
                            ItemContainer(
                              child: itemCard(
                                  'assets/images/vip3.jpg',
                                  prices[2].vip,
                                  prices[2].expiretime,
                                  prices[2].updatecost,
                                  prices[2].promotion,
                                  uservip.vipRenew,
                                  context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (uservip.vip != 0 && uservip.expiredat != '')
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              G.current.upgradeVipExipiredAtNote1 +
                                  " ${uservip.vip} " +
                                  G.current.upgradeVipExipiredAtNote2 +
                                  timeAgo.format(
                                      DateTime.parse(uservip.expiredat),
                                      allowFromNow: true),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          //TODO: Expired time
                        ],
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 20,
                    ),
                  )
                ];
              },
              body: Container(
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: pagecontroller,
                  children: [
                    VIP1(),
                    VIP2(),
                    VIP3(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Theme.of(context).bottomAppBarColor,
            border: Border(top: BorderSide(width: 2, color: Colors.black))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: _isPageError
              ? Center(child: Text('$error'))
              : _isPageLoading || uservip == null
                  ? CupertinoActivityIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(G.current.youHave + '${_wallet.value} Coins now',
                            style: Theme.of(context).textTheme.subtitle1),
                        () {
                          if (uservip.vipRenew == 1) {
                            return ShadedContainer(
                              ontap: () {
                                confirmDialog(
                                    context,
                                    (currentpage + 1),
                                    prices[currentpage].updatecost,
                                    uservip.vipRenew,
                                    prices[currentpage].promotion,
                                    _wallet);
                              },
                              child: Text(G.current.buyNow),
                            );
                          } else {
                            if (uservip.vip < currentpage + 1) {
                              return ShadedContainer(
                                ontap: () {
                                  confirmDialog(
                                      context,
                                      (currentpage + 1),
                                      prices[currentpage].updatecost,
                                      uservip.vipRenew,
                                      prices[currentpage].promotion,
                                      _wallet);
                                },
                                child: Text(G.current.buyNow),
                              );
                            } else {
                              return Text("");
                            }
                          }
                        }(),
                      ],
                    ),
        ),
      ),
    );
  }
}

class VIP0 extends StatelessWidget {
  const VIP0({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [],
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: Text(
              'VIP 0',
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverGrid.count(
            crossAxisCount: 3,
            children: [
              Icon(IconFonts.vipPhoto),
              Icon(IconFonts.vipVideo),
              Icon(IconFonts.vipGem),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [],
            ),
          ),
        )
      ],
    );
  }
}

class VIP1 extends StatelessWidget {
  const VIP1({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: Text(
              'VIP 1',
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverGrid.count(
            childAspectRatio: 0.85,
            crossAxisCount: 3,
            children: [
              icontext('1 ' + G.current.vipIconPublicText, IconFonts.vipPhoto,
                  color: Colors.green),
              icontext('1 ' + G.current.vipIconFollowerText, IconFonts.vipPhoto,
                  color: Colors.blue),
              icontext(
                  G.current.vipIconAppearText, FontAwesomeIcons.userAstronaut,
                  color: Colors.black,
                  onTap: () =>
                      Navigator.of(context).pushNamed(RouteName.vipDemo)),
              icontext('VIP 1 ' + G.current.vipIconText, IconFonts.vipGem,
                  color: Color.fromRGBO(169, 113, 66, 5)),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [],
            ),
          ),
        )
      ],
    );
  }
}

class VIP2 extends StatelessWidget {
  const VIP2({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: Text(
              'VIP 2',
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverGrid.count(
            childAspectRatio: 0.85,
            crossAxisCount: 3,
            children: [
              icontext('1 ' + G.current.vipIconPublicText, IconFonts.vipPhoto,
                  color: Colors.green),
              icontext('1 ' + G.current.vipIconFollowerText, IconFonts.vipPhoto,
                  color: Colors.blue),
              icontext(G.current.vipIconEnable480p, IconFonts.vipVideo,
                  color: Colors.purple),
              icontext(
                  G.current.vipIconAppearText, FontAwesomeIcons.userAstronaut,
                  color: Colors.black,
                  onTap: () =>
                      Navigator.of(context).pushNamed(RouteName.vipDemo)),
              icontext('VIP 2 ' + G.current.vipIconText, IconFonts.vipGem,
                  color: Colors.grey[300]),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [],
            ),
          ),
        )
      ],
    );
  }
}

class VIP3 extends StatelessWidget {
  const VIP3({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: Text(
              'VIP 3',
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverGrid.count(
            childAspectRatio: 0.85,
            crossAxisCount: 3,
            children: [
              icontext('3 ' + G.current.vipIconPublicText, IconFonts.vipPhoto,
                  color: Colors.green),
              icontext('3 ' + G.current.vipIconFollowerText, IconFonts.vipPhoto,
                  color: Colors.blue),
              icontext(G.current.vipIconEnable720p, IconFonts.vipVideo,
                  color: Colors.purple),
              icontext(
                  G.current.vipIconAppearText, FontAwesomeIcons.userAstronaut,
                  color: Colors.black,
                  onTap: () =>
                      Navigator.of(context).pushNamed(RouteName.vipDemo)),
              icontext('VIP 3 ' + G.current.vipIconText, IconFonts.vipGem,
                  color: Colors.yellow[700]),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [],
            ),
          ),
        )
      ],
    );
  }
}

Widget icontext(String text, IconData icon, {Color color, Function onTap}) {
  return InkWell(
    onTap: onTap,
    child: Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  // spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(-2, 3), // changes position of shadow
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 35,
              color: color ?? Colors.grey,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.zero,
            child: Text(
              text,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget itemCard(String image, int viplvl, int duration, int cost, int promotion,
    int viprenew, BuildContext context) {
  return Stack(
    children: [
      CardContainer(
        // ontap: () => print("Notes"),
        color: Colors.green,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.asset(
            image,
            fit: BoxFit.fill,
          ),
        ),
      ),
      Positioned(
        top: 20,
        left: 20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "VIP " + viplvl.toString(),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              G.current.duration +
                  ' ' +
                  duration.toString() +
                  ' ' +
                  G.current.boostDays,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
      viprenew == 0
          ? Positioned(
              bottom: 20,
              right: 20,
              child: promotion == 0
                  ? Text(
                      G.current.boostPrice + " " + cost.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    )
                  : Row(
                      children: [
                        Text(
                          G.current.boostPrice + " ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          cost.toString(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              decoration: TextDecoration.lineThrough),
                        ),
                        Text(
                          promotion.toString(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
            )
          : Positioned(
              bottom: 20,
              right: 20,
              child: promotion == 0
                  ? Text(
                      G.current.boostPrice + " " + cost.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    )
                  : Row(
                      children: [
                        Text(
                          G.current.boostPrice + " ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          cost.toString(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              decoration: TextDecoration.lineThrough),
                        ),
                        Text(
                          (cost ~/ 2).toString(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
            ),
    ],
  );
}

void confirmDialog(BuildContext context, int selectedplan, int price,
    int halfnew, int promotion, Wallet wallet) {
  showDialog(
      context: context,
      builder: (_) {
        // return SingleChildScrollView(
        //   child: AlertDialog(
        //     title: Text('Very, very large title', textScaleFactor: 5),
        //     content: Text('Very, very large content', textScaleFactor: 5),
        //     actions: <Widget>[
        //       TextButton(
        //           child: Text('Button 1'),
        //           onPressed: () {
        //             showToast('Ok');
        //           }),
        //       TextButton(
        //           child: Text('Button 2'),
        //           onPressed: () {
        //             showToast('Cancel');
        //           }),
        //     ],
        //   ),
        // );
        return CustomDialog(
          title: '${G.current.upgradeVipImportantNote1}',
          titleTextStyle: TextStyle(
              color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
          simpleContent: '${G.current.upgradeVipImportantNote2}',
          isContentLong: true,
          cancelContent: G.current.cancel,
          cancelColor: Theme.of(context).accentColor,
          confirmButtonColor: Theme.of(context).accentColor,
          confirmContent: G.current.confirm,
          confirmCallback: () {
            upgradeVIP(
                context, selectedplan, price, halfnew, promotion, wallet);
          },
        );
      });
}

upgradeVIP(BuildContext context, int _selectedPlan, int price, int halfnew,
    int promotion, Wallet _wallet) {
  if (_wallet.value <
      (halfnew == 1 ? price ~/ 2 : (promotion == 0 ? price : promotion))) {
    Future.delayed(const Duration(seconds: 2), () => _goToTopUpDialog(context));
    showToast(G.current.boostNoEnoughCoins);
    return;
  }
  print(halfnew);
  print("++++++++++++++++++++++++++++++++");
  MoonBlinkRepository.upgradeVipLevel(_selectedPlan, halfnew)
      .then((value) async {
    try {
      Navigator.pushNamedAndRemoveUntil(
          context, RouteName.main, (route) => false);
    } catch (e) {
      print(e);
    }
  });
}

void _goToTopUpDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) {
        return CustomDialog(
          title: G.current.unverifiedPartnerGoTopUpTitle,
          simpleContent: G.current.unverifiedPartnerGOTopUpContent,
          cancelContent: G.current.cancel,
          cancelColor: Theme.of(context).accentColor,
          confirmButtonColor: Theme.of(context).accentColor,
          confirmContent: G.current.confirm,
          confirmCallback: () {
            Navigator.of(context).pushReplacementNamed(RouteName.wallet);
          },
        );
      });
}

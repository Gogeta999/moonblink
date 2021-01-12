import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/container/cardContainer.dart';
import 'package:moonblink/base_widget/horizontalPager.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/models/vipmodel.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/moonblink_repository.dart';

class UpgradeVIP extends StatefulWidget {
  final Map<String, dynamic> data;
  UpgradeVIP({this.data});

  @override
  _UpgradeVIPState createState() => _UpgradeVIPState();
}

class _UpgradeVIPState extends State<UpgradeVIP> {
  ///Scroll Controller
  PageController pagecontroller = PageController();
  ScrollController _scrollController = new ScrollController();

  ///Remote Data
  int _selectedPlan = 0;
  Wallet _wallet = Wallet(value: 0);
  int partnerVipLevel = 0;
  // bool _enableToBuy = true;

  ///UI
  var error;
  bool _isPageLoading = true;
  bool _isPageError = false;
  bool _isConfirmLoading = false;

  List<VIPprice> prices = [];

  @override
  void initState() {
    _initData();
    partnerVipLevel = int.tryParse(widget.data['acc_vip_level']);
    pagecontroller = PageController(
        initialPage: partnerVipLevel != 0 ? partnerVipLevel - 1 : 0);
    super.initState();
  }

  void _initData() {
    Future.wait([
      _initUserWallet(),
      _getVippice(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(
        title: Text(G.current.upgradeVipAppBarTitle),
      ),
      body: prices.isEmpty
          ? Container()
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
                          initialPage:
                              partnerVipLevel != 0 ? partnerVipLevel - 1 : 0,
                          onPageChanged: (page) => pagecontroller.jumpToPage(
                            page.round(),
                          ),
                          items: [
                            ItemContainer(
                              child: itemCard('assets/images/vip1.jpg',
                                  prices[0].vip, prices[0].updatecost, context),
                            ),
                            ItemContainer(
                              child: itemCard('assets/images/vip2.jpg',
                                  prices[1].vip, prices[1].updatecost, context),
                            ),
                            ItemContainer(
                              child: itemCard('assets/images/vip3.jpg',
                                  prices[2].vip, prices[2].updatecost, context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                              "Note: Your current vip level is $partnerVipLevel"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
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
                  : _isPageLoading
                      ? CupertinoActivityIndicator()
                      : Text(G.current.youHave + '${_wallet.value} Coins now',
                          style: Theme.of(context).textTheme.subtitle1))),
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
            children: [],
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
            crossAxisCount: 3,
            children: [],
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
            crossAxisCount: 3,
            children: [
              postperday("Allow 1 public post per day", Icons.post_add),
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
            childAspectRatio: 1,
            crossAxisCount: 3,
            children: [
              postperday(
                  "Allow 3 public posts per day", Icons.video_call_rounded),
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

Widget postperday(String text, IconData icon) {
  return Center(
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
            color: Colors.grey,
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
  );
}

Widget itemCard(String image, int viplvl, int cost, BuildContext context) {
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
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              "Price " + cost.toString(),
              style: Theme.of(context).textTheme.headline6,
            )
          ],
        ),
      )
    ],
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/customDialog_widget.dart';
import 'package:moonblink/base_widget/horizontalPager.dart';
import 'package:moonblink/bloc_pattern/chat_list/chat_list_bloc.dart';
import 'package:moonblink/bloc_pattern/user_notification/new/user_new_notification_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/vip_data.dart';
import 'package:moonblink/models/vipmodel.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/services/push_notification_manager.dart';
import 'package:moonblink/services/web_socket_service.dart';
import 'package:moonblink/ui/pages/settings/allsetting/new_upgrade_vip.dart';
import 'package:moonblink/view_model/user_model.dart';
import 'package:oktoast/oktoast.dart';

class UnverifiedPartnerSignUpPage extends StatefulWidget {
  final String phoneNumber;
  UnverifiedPartnerSignUpPage(this.phoneNumber);
  @override
  _UnverifiedPartnerSignUpPageState createState() =>
      _UnverifiedPartnerSignUpPageState();
}

class _UnverifiedPartnerSignUpPageState
    extends State<UnverifiedPartnerSignUpPage> {
  UserModel userModel;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
  final FacebookLogin _facebookLogin = FacebookLogin();
  PageController pagecontroller = PageController();
  ScrollController _scrollController = new ScrollController();
  int currentpage = 0;

  ///Remote Data
  String _gender = '';
  Wallet _wallet = Wallet(value: 0);
  List<VIPprice> prices = [];
  VipData uservip;

  ///UI
  var error;
  bool _isPageLoading = true;
  bool _isPageError = false;
  bool _isConfirmLoading = false;
  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    if (isDev) print('Disposing main app');
    userModel.dispose();
    super.dispose();
  }

  void _initData() {
    Future.wait([
      _initUserWallet(),
      _getVIPdata(),
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

  Future<void> _getVIPdata() async {
    MoonBlinkRepository.getUserVip().then((value) {
      setState(() {
        uservip = value;
      });
      pagecontroller =
          PageController(initialPage: value.vip != 0 ? value.vip - 1 : 0);
    });
  }

  void confirmVIPDialog(int cost, int promotion, int _selectedPlan) {
    showDialog(
        context: context,
        builder: (_) {
          return CustomDialog(
            title:
                '${G.current.unverifiedPartnerPlanConfirmTitle} \'Vip$_selectedPlan\'',
            simpleContent:
                'VIP $_selectedPlan cost ${promotion == 0 ? cost : promotion}. ${G.current.unverifiedPartnerPlanConfirmContent}',
            cancelContent: G.current.cancel,
            cancelColor: Theme.of(context).accentColor,
            confirmButtonColor: Theme.of(context).accentColor,
            confirmContent: G.current.confirm,
            confirmCallback: () {
              _onTapConfirm(cost, promotion, _selectedPlan);
            },
          );
        });
  }

  void _goToTopUpDialog() {
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

  _onTapConfirm(int cost, int promotion, int _selectedPlan) {
    if (_gender == '') {
      showToast('Gender ${G.of(context).cannotblank}');
      return;
    }
    if (promotion == 0 ? _wallet.value < cost : _wallet.value < promotion) {
      Future.delayed(const Duration(seconds: 2), () => _goToTopUpDialog());
      showToast(G.current.boostNoEnoughCoins);
      return;
    }
    setState(() {
      _isConfirmLoading = true;
    });
    MoonBlinkRepository.signAsType5Partner(
            widget.phoneNumber, _selectedPlan, _gender)
        .then((value) async {
      try {
        setState(() {
          _isConfirmLoading = false;
        });
        PushNotificationsManager().dispose();
        WebSocketService().dispose();
        final context =
            locator<NavigationService>().navigatorKey.currentContext;
        BlocProvider.of<UserNewNotificationBloc>(context)
            .add(UserNewNotificationCleared());
        BlocProvider.of<ChatListBloc>(context).chatsSubject.add([]);
        Navigator.of(context)
            .pushNamedAndRemoveUntil(RouteName.splash, (route) => false);
        _facebookLogin.isLoggedIn.then(
            (value) async => value ? await _facebookLogin.logOut() : null);
        _googleSignIn.isSignedIn().then(
            (value) async => value ? await _googleSignIn.signOut() : null);
        DioUtils().initWithoutAuthorization();
        await MoonBlinkRepository.logout();
        userModel.clearUser();
      } catch (e) {
        setState(() {
          _isPageError = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _textStyle = Theme.of(context).textTheme;
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
                              confirmVIPDialog(
                                  prices[currentpage].updatecost,
                                  prices[currentpage].promotion,
                                  currentpage + 1);
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
                  //to add male female choice for normal user
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ShadedContainer(
                          selected: _gender.isNotEmpty && _gender == 'Male'
                              ? true
                              : false,
                          ontap: () {
                            setState(() {
                              _gender = 'Male';
                            });
                          },
                          child: Text(G.of(context).genderMale),
                        ),
                        ShadedContainer(
                          selected: _gender.isNotEmpty && _gender == 'Female'
                              ? true
                              : false,
                          ontap: () {
                            setState(() {
                              _gender = 'Female';
                            });
                          },
                          child: Text(G.of(context).genderFemale),
                        )
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
                        if (uservip.vip < currentpage + 1)
                          ShadedContainer(
                            ontap: () {
                              confirmVIPDialog(
                                  prices[currentpage].updatecost,
                                  prices[currentpage].promotion,
                                  currentpage + 1);
                            },
                            child: Text("Buy Now"),
                          ),
                      ],
                    ),
        ),
      ),
    );
  }
}

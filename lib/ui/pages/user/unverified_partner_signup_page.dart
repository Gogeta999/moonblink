import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/customDialog_widget.dart';
import 'package:moonblink/bloc_pattern/chat_list/chat_list_bloc.dart';
import 'package:moonblink/bloc_pattern/user_notification/new/user_new_notification_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/services/push_notification_manager.dart';
import 'package:moonblink/services/web_socket_service.dart';
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

  ///Remote Data
  int _selectedPlan = 0;
  Wallet _wallet = Wallet(value: 0);

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

  void _initData() {
    Future.wait([_initUserWallet()], eagerError: true).then((value) {
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

  void confirmDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return CustomDialog(
            title:
                '${G.current.unverifiedPartnerPlanConfirmTitle} \'Vip$_selectedPlan\'',
            simpleContent: G.current.unverifiedPartnerPlanConfirmContent,
            cancelContent: G.current.cancel,
            cancelColor: Theme.of(context).accentColor,
            confirmButtonColor: Theme.of(context).accentColor,
            confirmContent: G.current.confirm,
            confirmCallback: () {
              _onTapConfirm();
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

  _onTapConfirm() {
    if (_selectedPlan == 3 && _wallet.value < 800) {
      Future.delayed(const Duration(seconds: 2), () => _goToTopUpDialog());
      showToast(G.current.boostNoEnoughCoins);
      return;
    }
    if (_selectedPlan == 2 && _wallet.value < 500) {
      Future.delayed(const Duration(seconds: 2), () => _goToTopUpDialog());
      showToast(G.current.boostNoEnoughCoins);
      return;
    }
    if (_selectedPlan == 1 && _wallet.value < 300) {
      Future.delayed(const Duration(seconds: 2), () => _goToTopUpDialog());
      showToast(G.current.boostNoEnoughCoins);
      return;
    }
    setState(() {
      _isConfirmLoading = true;
    });
    MoonBlinkRepository.signAsType5Partner(widget.phoneNumber, _selectedPlan)
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
    return SafeArea(
      child: Scaffold(
        appBar: AppbarWidget(
          title: Text(G.current.unverifiedPartnerPlan),
        ),
        backgroundColor: Colors.grey[200],
        body: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: <Widget>[
            SliverList(
                delegate: SliverChildListDelegate.fixed([
              Column(
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(2, 10, 2, 5),
                      child: Card(
                        child: ListTile(
                          isThreeLine: true,
                          title: Text(
                            G.current.unverifiedPartnerVip1Title,
                            style: _textStyle.headline5,
                          ),
                          subtitle: Text(
                            G.current.unverifiedPartnerVip1Subtitle,
                            style: _textStyle.subtitle1,
                          ),
                          trailing: _isConfirmLoading
                              ? CupertinoActivityIndicator()
                              : InkWell(
                                  child: Icon(FontAwesomeIcons.question),
                                  onTap: () => showToast('Show exmaple Layer'),
                                ),
                          onTap: () {
                            setState(() {
                              _selectedPlan = 1;
                            });
                            confirmDialog();
                          },
                          onLongPress: () => showToast('Show exmaple Layer'),
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(2, 5, 2, 5),
                      child: Card(
                        child: ListTile(
                          isThreeLine: true,
                          title: Text(
                            G.current.unverifiedPartnerVip2Title,
                            style: _textStyle.headline6,
                          ),
                          subtitle: Text(
                              G.current.unverifiedPartnerVip2Subtitle,
                              style: _textStyle.subtitle1),
                          trailing: _isConfirmLoading
                              ? CupertinoActivityIndicator()
                              : InkWell(
                                  child: Icon(FontAwesomeIcons.question),
                                  onTap: () => showToast('Show exmaple Layer'),
                                ),
                          onTap: () {
                            setState(() {
                              _selectedPlan = 2;
                            });
                            confirmDialog();
                          },
                          onLongPress: () => showToast('Show exmaple Layer'),
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(2, 5, 2, 5),
                      child: Card(
                        child: ListTile(
                          isThreeLine: true,
                          title: Text(
                            G.current.unverifiedPartnerVip3Title,
                            style: _textStyle.headline5,
                          ),
                          subtitle: Text(
                              G.current.unverifiedPartnerVip3Subtitle,
                              style: _textStyle.subtitle1),
                          trailing: _isConfirmLoading
                              ? CupertinoActivityIndicator()
                              : InkWell(
                                  child: Icon(FontAwesomeIcons.question),
                                  onTap: () => showToast('Show exmaple Layer'),
                                ),
                          onTap: () {
                            setState(() {
                              _selectedPlan = 3;
                            });
                            confirmDialog();
                          },
                          onLongPress: () => showToast('Show exmaple Layer'),
                        ),
                      )),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                    child: Text(
                      G.current.unverifiedPartnerNote,
                      style: _textStyle.headline6,
                    ),
                  )
                ],
              ),
            ]))
          ],
        ),
        bottomNavigationBar: Container(
            width: MediaQuery.of(context).size.width,
            height: 28,
            decoration: BoxDecoration(
                color: Theme.of(context).bottomAppBarColor,
                border: Border(top: BorderSide(width: 2, color: Colors.black))),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _isPageError
                    ? Center(child: Text('$error'))
                    : _isPageLoading
                        ? CupertinoActivityIndicator()
                        : Text(G.current.youHave + '${_wallet.value} Coins now',
                            style: Theme.of(context).textTheme.subtitle1))),
      ),
    );
  }
}

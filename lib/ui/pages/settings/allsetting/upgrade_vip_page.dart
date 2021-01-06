import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/customDialog_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:oktoast/oktoast.dart';

class UpgradeVipPage extends StatefulWidget {
  final Map<String, dynamic> data;
  UpgradeVipPage({this.data});
  @override
  _UpgradeVipPageState createState() => _UpgradeVipPageState();
}

class _UpgradeVipPageState extends State<UpgradeVipPage> {
  ///Remote Data
  int _selectedPlan = 0;
  Wallet _wallet = Wallet(value: 0);
  int _partnerVipLevel = 0;
  // bool _enableToBuy = true;

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

    if (_selectedPlan == 3 && _wallet.value < (widget.data['half_renew'] == 1 ? 800 / 2 : 800)) {
      Future.delayed(const Duration(seconds: 2), () => _goToTopUpDialog());
      showToast(G.current.boostNoEnoughCoins);
      return;
    }
    if (_selectedPlan == 2 && _wallet.value < (widget.data['half_renew'] == 1 ? 500 / 2 : 500)) {
      Future.delayed(const Duration(seconds: 2), () => _goToTopUpDialog());
      showToast(G.current.boostNoEnoughCoins);
      return;
    }
    if (_selectedPlan == 1 && _wallet.value < (widget.data['half_renew'] == 1 ? 300 / 2 : 300)) {
      Future.delayed(const Duration(seconds: 2), () => _goToTopUpDialog());
      showToast(G.current.boostNoEnoughCoins);
      return;
    }
    setState(() {
      _isConfirmLoading = true;
    });
    MoonBlinkRepository.upgradeVipLevel(_selectedPlan, widget.data['half_renew']).then((value) async {
      try {
        setState(() {
          _isConfirmLoading = false;
        });
        Navigator.pushNamedAndRemoveUntil(
            context, RouteName.main, (route) => false);
      } catch (e) {
        setState(() {
          _isPageError = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _partnerVipLevel = int.tryParse(widget.data['acc_vip_level']);
    final _textStyle = Theme.of(context).textTheme;
    return SafeArea(
          child: Scaffold(
        appBar: AppbarWidget(
          title: Text(G.current.upgradeVipAppBarTitle),
        ),
        body:
            CustomScrollView(physics: ClampingScrollPhysics(), slivers: <Widget>[
          SliverList(
              delegate: SliverChildListDelegate.fixed([
            Column(children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(2, 10, 2, 5),
                  child: Card(
                    child: ListTile(
                      isThreeLine: true,
                      title: Text(
                        widget.data['half_renew'] == 1 ? 'Vip 1 Cost 150 Coins' : G.current.unverifiedPartnerVip1Title,
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
                        if (_selectedPlan > _partnerVipLevel) {
                          confirmDialog();
                        }
                        if (_selectedPlan <= _partnerVipLevel) {
                          showToast(G.current.upgradeVipAlreadyOwnToast);
                        }
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
                        widget.data['half_renew'] == 1 ? 'Vip 2 Cost 250 Coins' : G.current.unverifiedPartnerVip2Title,
                        style: _textStyle.headline6,
                      ),
                      subtitle: Text(G.current.unverifiedPartnerVip2Subtitle,
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
                        if (_selectedPlan > _partnerVipLevel) {
                          confirmDialog();
                        }
                        if (_selectedPlan <= _partnerVipLevel) {
                          showToast(G.current.upgradeVipAlreadyOwnToast);
                        }
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
                        widget.data['half_renew'] == 1 ? 'Vip 3 Cost 400 Coins' : G.current.unverifiedPartnerVip3Title,
                        style: _textStyle.headline5,
                      ),
                      subtitle: Text(G.current.unverifiedPartnerVip3Subtitle,
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
                        if (_selectedPlan > _partnerVipLevel) {
                          confirmDialog();
                        }
                        if (_selectedPlan <= _partnerVipLevel) {
                          showToast(G.current.upgradeVipAlreadyOwnToast);
                        }
                      },
                      onLongPress: () => showToast('Show exmaple Layer'),
                    ),
                  )),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                child: _partnerVipLevel != 0
                    ? Text(
                        G.current.upgradeVipCurrentLevel +
                            _partnerVipLevel.toString() +
                            '\n${G.current.unverifiedPartnerNote}',
                        style: _textStyle.headline6,
                      )
                    : Text(
                        '${G.current.unverifiedPartnerNote}',
                        style: _textStyle.headline6,
                      ),
              )
            ]),
          ])),
        ]),
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
      ),
    );
  }
}
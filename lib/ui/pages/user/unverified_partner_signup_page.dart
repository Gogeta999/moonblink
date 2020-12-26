import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/customDialog_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:oktoast/oktoast.dart';

class UnverifiedPartnerSignUpPage extends StatefulWidget {
  @override
  _UnverifiedPartnerSignUpPageState createState() =>
      _UnverifiedPartnerSignUpPageState();
}

class _UnverifiedPartnerSignUpPageState
    extends State<UnverifiedPartnerSignUpPage> {
  ///Remote Data
  int _selectedPlanPrice = 0;
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
            title: G.current.unverifiedPartnerPlanConfirmTitle,
            simpleContent: G.current.unverifiedPartnerPlanConfirmContent,
            cancelContent: G.current.cancel,
            cancelColor: Theme.of(context).accentColor,
            confirmButtonColor: Theme.of(context).accentColor,
            confirmContent: G.current.confirm,
            confirmCallback: () {
              // showToast('Write Function Here');
              _onTapConfirm();
            },
          );
        });
  }

  _onTapConfirm() {
    if (_wallet.value < _selectedPlanPrice) {
      showToast(G.current.boostNoEnoughCoins);
      return;
    }
    setState(() {
      _isConfirmLoading = true;
    });
    showToast('Success');
    //TODO: Change Real Code Here
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isConfirmLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppbarWidget(
          title: Text(G.current.unverifiedPartnerPlan),
        ),
        backgroundColor: Colors.grey[200],
        body: Column(
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(2, 10, 2, 5),
                child: Card(
                  child: ListTile(
                    isThreeLine: true,
                    title: Text(G.current.unverifiedPartnerVip1Title),
                    subtitle: Text(G.current.unverifiedPartnerVip1Subtitle),
                    trailing: _isConfirmLoading
                        ? CupertinoActivityIndicator()
                        : Icon(Icons.chevron_right),
                    onTap: () => confirmDialog(),
                    onLongPress: () => showToast('Show exmaple Layer'),
                  ),
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(2, 5, 2, 5),
                child: Card(
                  child: ListTile(
                    isThreeLine: true,
                    title: Text(G.current.unverifiedPartnerVip2Title),
                    subtitle: Text(G.current.unverifiedPartnerVip2Subtitle),
                    trailing: _isConfirmLoading
                        ? CupertinoActivityIndicator()
                        : Icon(Icons.chevron_right),
                    onTap: () => confirmDialog(),
                    onLongPress: () => showToast('Show exmaple Layer'),
                  ),
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(2, 5, 2, 5),
                child: Card(
                  child: ListTile(
                    isThreeLine: true,
                    title: Text(G.current.unverifiedPartnerVip3Title),
                    subtitle: Text(G.current.unverifiedPartnerVip3Subtitle),
                    trailing: _isConfirmLoading
                        ? CupertinoActivityIndicator()
                        : Icon(Icons.chevron_right),
                    onTap: () => confirmDialog(),
                    onLongPress: () => showToast('Show exmaple Layer'),
                  ),
                )),
            Padding(
              padding: EdgeInsets.fromLTRB(2, 30, 2, 0),
              child: Text('Write Some Note Here To Tell User'),
            )
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

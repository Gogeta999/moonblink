import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';

class SignInOutAgree extends StatefulWidget {
  final bool isSignIn;
  final bool signin;

  const SignInOutAgree({Key key, this.isSignIn = false, this.signin = false})
      : super(key: key);

  @override
  _SignInOutAgreeState createState() => _SignInOutAgreeState();
}

class _SignInOutAgreeState extends State<SignInOutAgree> {
  final TapGestureRecognizer _termsAndConditions = TapGestureRecognizer();

  final TapGestureRecognizer _starndardEULA = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _termsAndConditions.onTap =
        () => navigate(RouteName.termsAndConditionsPage);
    _starndardEULA.onTap = () => navigate(RouteName.licenseAgreement);
  }

  void navigate(String routeName) {
    Navigator.pushNamed(context, routeName, arguments: false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text.rich(
        TextSpan(
            text: G.of(context).bySigning,
            style: TextStyle(color: widget.signin ? null : Colors.white),
            children: [
              TextSpan(
                  text: G.of(context).termAndConditions,
                  recognizer: _termsAndConditions,
                  style: TextStyle(color: Theme.of(context).accentColor)),
              TextSpan(text: G.of(context).and),
              TextSpan(
                text: G.of(context).licenseagreement,
                recognizer: _starndardEULA,
                style: TextStyle(color: Theme.of(context).accentColor),
              )
            ]),
        textAlign: TextAlign.center,
      ),
    );
  }
}

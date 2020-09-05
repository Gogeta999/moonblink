import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/MoonBlink_LOGO_widget.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_button_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/view_model/register_model.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _mailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  // final _lastnameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool male = false;
  bool female = false;

  @override
  void dispose() {
    _mailCtrl.dispose();
    _nameCtrl.dispose();
    // _lastnameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.black,
            floating: true,
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MoonBlinkLogo(),
                  ProviderWidget<RegisterModel>(
                      model: RegisterModel(),
                      builder: (context, model, child) => Form(
                            onWillPop: () async {
                              return !model.isBusy;
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Column(
                                // crossAxisAlignment:
                                //     CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  LoginTextField(
                                    label: G.of(context).signUpMail,
                                    icon: Icons.mail_outline,
                                    controller: _mailCtrl,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  LoginTextField(
                                    label: G.of(context).signUpName,
                                    icon: Icons.person_outline,
                                    controller: _nameCtrl,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  // LoginTextField(
                                  //   label: G.of(context).signUpLastName,
                                  //   icon: Icons.person_outline,
                                  //   controller: _lastnameCtrl,
                                  //   textInputAction: TextInputAction.next,
                                  // ),
                                  LoginTextField(
                                    label: G.of(context).signUpPassword,
                                    icon: Icons.lock_outline,
                                    obscureText: true,
                                    controller: _passwordCtrl,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  LoginTextField(
                                    label: "Re-Enter Password",
                                    icon: Icons.lock_open,
                                    obscureText: true,
                                    controller: _passwordCtrl,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ShadedContainer(
                                        selected: male,
                                        ontap: () {
                                          setState(() {
                                            male = !male;
                                            female = false;
                                          });
                                        },
                                        child: Text(
                                          "Male",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      ShadedContainer(
                                        selected: female,
                                        ontap: () {
                                          setState(() {
                                            female = !female;
                                            male = false;
                                          });
                                        },
                                        child: Text(
                                          "Female",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  RegisterButton(_mailCtrl, _nameCtrl,
                                      _passwordCtrl, model)
                                ],
                              ),
                            ),
                          )),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SignInOutAgree(
        isSignIn: false,
        signin: false,
      ),
    );
  }
}

class RegisterButton extends StatelessWidget {
  final mailCtrl;
  final nameCtrl;
  // final lastnameCtrl;
  final passwordCtrl;
  final RegisterModel model;

  RegisterButton(this.mailCtrl, this.nameCtrl, this.passwordCtrl, this.model);
  @override
  Widget build(BuildContext context) {
    return LoginButtonWidget(
      color: Theme.of(context).accentColor,
      child: model.isBusy
          ? ButtonProgressIndicator()
          : Text(
              G.of(context).signUp,
              style: Theme.of(context)
                  .accentTextTheme
                  .headline6
                  .copyWith(wordSpacing: 6),
            ),
      onPressed: model.isBusy
          ? null
          : () {
              if (Form.of(context).validate()) {
                model
                    .singUp(mailCtrl.text, nameCtrl.text, passwordCtrl.text)
                    .then((value) {
                  if (value) {
                    Navigator.of(context).pop(mailCtrl.text);
                  } else {
                    model.showErrorMessage(context);
                  }
                });
              }
            },
    );
  }
}

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

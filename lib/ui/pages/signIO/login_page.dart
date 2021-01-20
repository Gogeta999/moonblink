import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/MoonBlink_LOGO_widget.dart';
import 'package:moonblink/base_widget/curvepanel.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/forgetpassword.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_button_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/signupwidget.dart';
import 'package:moonblink/base_widget/thirdLogin.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/ui/helper/agreement.dart';
import 'package:moonblink/ui/helper/gameProfileSetUp.dart';
import 'package:moonblink/ui/helper/tutorial.dart';
import 'package:moonblink/ui/pages/user/update_partner_profile_page.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:provider/provider.dart';
import 'package:moonblink/base_widget/moonblink_captcha.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pwdFocus = FocusNode();
  @override
  void dispose() {
    _mailController.dispose();
    _passwordController.dispose();
    _pwdFocus.unfocus();
    _pwdFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: ProviderWidget<LoginModel>(
              model: LoginModel(Provider.of(context)),
              onModelReady: (model) {
                _mailController.text = model.getLoginMail();
              },
              builder: (context, model, child) {
                return Form(
                  onWillPop: () async {
                    return !model.isBusy;
                  },
                  child: child,
                );
              },
              child: Stack(
                children: <Widget>[
                  SecCurvePanel(),
                  FirstCurvePanel(),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          MoonBlinkLogo(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              LoginTextField(
                                label: G.of(context).loginMail,
                                icon: Icons.perm_identity,
                                controller: _mailController,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (text) {
                                  FocusScope.of(context)
                                      .requestFocus(_pwdFocus);
                                },
                              ),
                              LoginTextField(
                                controller: _passwordController,
                                label: G.of(context).loginPassword,
                                icon: Icons.lock_outline,
                                obscureText: true,
                                focusNode: _pwdFocus,
                                textInputAction: TextInputAction.done,
                              ),
                              MBCaptcha(),
                              // RaisedButton(
                              //   child: Text('Test'),
                              //   onPressed: () => Navigator.of(context)
                              //       .push(MaterialPageRoute(builder: (context) {
                              //     return MBCaptcha();
                              //   })),
                              // )
                              // ThirdLogin(),
                            ],
                          ),
                          LoginButton(_mailController, _passwordController),
                          Container(),
                          Column(
                            children: [
                              ThirdLogin(),
                              SignUpWidget(_mailController),
                              ForgetPassword(_mailController),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  // ChatTile(
                  //     username: "hello",
                  //     lastmsg: "Last Message",
                  //     image: NetworkImage(
                  //         "https://pbs.twimg.com/media/EeS3_XkWoAA0fct.png"),
                  //     time: "1.20")
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: SignInOutAgree(
        isSignIn: false,
        signin: true,
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final mailController;
  final passwordController;
  LoginButton(this.mailController, this.passwordController);

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<LoginModel>(context);
    var theme = Theme.of(context);
    return LoginButtonWidget(
      color: theme.accentColor,
      // brightness == Brightness.dark
      //     ? theme.accentColor
      //     : Colors.white,
      child: model.isBusy
          ? ButtonProgressIndicator()
          : Text(
              G.of(context).toSignIn,
              style: Theme.of(context)
                  .accentTextTheme
                  .headline6
                  .copyWith(wordSpacing: 6),
            ),
      onPressed: model.isBusy
          ? null
          : () {
              var formState = Form.of(context);
              if (formState.validate()) {
                model
                    .login(
                        mailController.text, passwordController.text, 'email')
                    .then((value) {
                  if (value) {
                    int gameprofile =
                        StorageManager.sharedPreferences.getInt(mgameprofile);
                    int type =
                        StorageManager.sharedPreferences.getInt(mUserType);

                    Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteName.main, (route) => false);

                    ///important to change here
                    if (type == 5 &&
                        (StorageManager.sharedPreferences.getBool(firsttuto) ??
                            true)) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UpdatePartnerProfilePage(),
                        ),
                      );
                    }
                    tutorialOn();
                    if (gameprofile == 0 && type != 0) {
                      gameProfileSetUp();
                    }
                  } else {
                    model.showErrorMessage(context);
                  }
                });
              }
            },
    );
  }
}

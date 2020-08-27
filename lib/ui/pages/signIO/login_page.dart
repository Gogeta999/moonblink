import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/MoonBlink_LOGO_widget.dart';
import 'package:moonblink/base_widget/TopCurvePanel_widget.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/LoginFormContainer_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_button_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/base_widget/thirdLogin.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

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
          SliverAppBar(
            floating: true,
          ),
          SliverToBoxAdapter(
            child: Stack(
              children: <Widget>[
                TopCurvePanel(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      MoonBlinkLogo(),
                      LoginFormContainer(
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
                          child: Column(
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
                              LoginButton(_mailController, _passwordController),
                              ThirdLogin(),
                              SignUpWidget(_mailController),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(child: SignInOutAgree(isSignIn: true))
        ],
      ),
    );
  }
}

class SignInOutAgree extends StatefulWidget {
  final bool isSignIn;

  const SignInOutAgree({Key key, this.isSignIn = false}) : super(key: key);

  @override
  _SignInOutAgreeState createState() => _SignInOutAgreeState();
}

class _SignInOutAgreeState extends State<SignInOutAgree> {
  final TapGestureRecognizer _termsAndConditions = TapGestureRecognizer();

  final TapGestureRecognizer _starndardEULA = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _termsAndConditions.onTap = () => navigate(RouteName.termsAndConditionsPage);
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
          TextSpan(text: 'By Signing ${widget.isSignIn ? 'in' : 'up'}, you agree to ', children: [
        TextSpan(
            text: 'Terms and Conditions',
            recognizer: _termsAndConditions,
            style: TextStyle(color: Theme.of(context).accentColor)),
        TextSpan(text: ' and '),
        TextSpan(
          text: 'End-User License Agreement.',
          recognizer: _starndardEULA,
          style: TextStyle(color: Theme.of(context).accentColor),
        )
      ]),
        textAlign: TextAlign.center,
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
    return LoginButtonWidget(
      child: model.isBusy
          ? ButtonProgressIndicator()
          : Text(
              G.of(context).signIn,
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
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteName.main, (route) => false);
                    ScopedModel.of<ChatModel>(context).disconnect();
                    ScopedModel.of<ChatModel>(context, rebuildOnChange: false)
                        .init();
                  } else {
                    model.showErrorMessage(context);
                  }
                });
              }
            },
    );
  }
}

class SignUpWidget extends StatefulWidget {
  final nameController;

  SignUpWidget(this.nameController);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  TapGestureRecognizer _recognizerRegister;

  @override
  void initState() {
    _recognizerRegister = TapGestureRecognizer()
      ..onTap = () async {
        // Fill Register UserName Into logn name widget
        widget.nameController.text =
            await Navigator.of(context).pushNamed(RouteName.register);
      };
    super.initState();
  }

  @override
  void dispose() {
    _recognizerRegister.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Text.rich(TextSpan(text: G.of(context).noAccount + '. ', children: [
        TextSpan(
            text: G.of(context).toSignUp,
            recognizer: _recognizerRegister,
            style: TextStyle(color: Theme.of(context).accentColor))
      ])),
    );
  }
}

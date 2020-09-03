import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/MoonBlink_LOGO_widget.dart';
import 'package:moonblink/base_widget/chattile.dart';
import 'package:moonblink/base_widget/curvepanel.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_button_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/base_widget/thirdLogin.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/ui/pages/signIO/newregisterpage.dart';
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
          // SliverAppBar(
          //   floating: true,
          // ),
          SliverToBoxAdapter(
            child: ProviderWidget<LoginModel>(
              model: LoginModel(Provider.of(context)),
              onModelReady: (model) {
                _mailController.text = model.getLoginName();
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
                      padding: EdgeInsets.symmetric(horizontal: 65),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          MoonBlinkLogo(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              LoginTextField(
                                label: "Enter Mail",
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
                                label: "Enter password",
                                icon: Icons.lock_outline,
                                obscureText: true,
                                focusNode: _pwdFocus,
                                textInputAction: TextInputAction.done,
                              ),

                              // ThirdLogin(),
                            ],
                          ),
                          LoginButton(_mailController, _passwordController),
                          Container(),
                          Column(
                            children: [
                              ThirdLogin(),
                              SignUpWidget(_mailController),
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
              "Sign In",
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
      child: Text.rich(TextSpan(text: "hello" + '. ', children: [
        TextSpan(
            text: "SignUp",
            recognizer: _recognizerRegister,
            style: TextStyle(color: Theme.of(context).accentColor))
      ])),
    );
  }
}

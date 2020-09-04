import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/MoonBlink_LOGO_widget.dart';
import 'package:moonblink/base_widget/TopCurvePanel_widget.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/LoginFormContainer_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_button_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/view_model/resetpassword_model.dart';

class ResetPasswordPage extends StatefulWidget {
  ResetPasswordPage({this.mail});
  final mail;
  @override
  _ResetPasswordPage createState() => _ResetPasswordPage();
}

class _ResetPasswordPage extends State<ResetPasswordPage> {
  var _mailController = TextEditingController();
  var _otpCodeController = TextEditingController();
  var _passwController = TextEditingController();
  @override
  void initState() {
    super.initState();
    setState(() {
      _mailController = TextEditingController(text: widget.mail);
    });
  }

  @override
  void dispose() {
    _mailController.dispose();
    _otpCodeController.dispose();
    _passwController.dispose();
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
                      Container(
                        height: 3,
                      ),
                      LoginFormContainer(
                        child: ProviderWidget<ResetPasswordModel>(
                            model: ResetPasswordModel(),
                            builder: (context, model, child) {
                              return Form(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    LoginTextField(
                                      label: G.of(context).labelphno,
                                      icon: FontAwesomeIcons.mailBulk,
                                      controller: _mailController,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    LoginTextField(
                                      label: "Please Enter OTP",
                                      icon: FontAwesomeIcons.sms,
                                      controller: _otpCodeController,
                                      keyboardType: TextInputType.phone,
                                    ),
                                    LoginTextField(
                                      label: "Please Enter New Password",
                                      icon: Icons.lock_outline,
                                      controller: _passwController,
                                      obscureText: true,
                                    ),
                                    ResetPassword(model, _mailController,
                                        _otpCodeController, _passwController),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ResetPassword extends StatelessWidget {
  ResetPassword(this.model, this.mail, this.otp, this.password);
  final model;
  final mail;
  final otp;
  final password;
  @override
  Widget build(BuildContext context) {
    // var model = Provider.of<ResetPasswordModel>(context);
    return LoginButtonWidget(
      child: model.isBusy
          ? ButtonProgressIndicator()
          : Text(
              "Reset Password",
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
                /*model.signAsPartner(otpController.text).then((value) */
                model
                    .resetPassword(
                        mail.text, int.parse(otp.text), password.text)
                    .then((value) {
                  if (value) {
                    Navigator.of(context).pop(mail.text);
                  } else {
                    model.showErrorMessage(context);
                  }
                });
              }
            },
    );
  }
}

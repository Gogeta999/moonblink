import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/MoonBlink_LOGO_widget.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
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
                  Container(
                    height: 3,
                  ),
                  ProviderWidget<ResetPasswordModel>(
                      model: ResetPasswordModel(),
                      builder: (context, model, child) {
                        return Form(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 30,
                                ),
                                LoginTextField(
                                  label: G.of(context).labelphno,
                                  icon: FontAwesomeIcons.mailBulk,
                                  controller: _mailController,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                LoginTextField(
                                  label: G.of(context).labelotp,
                                  icon: FontAwesomeIcons.sms,
                                  controller: _otpCodeController,
                                  keyboardType: TextInputType.phone,
                                ),
                                LoginTextField(
                                  label: G.of(context).newpassword,
                                  icon: Icons.lock_outline,
                                  controller: _passwController,
                                  obscureText: true,
                                ),
                                SizedBox(height: 30),
                                ResetPassword(model, _mailController,
                                    _otpCodeController, _passwController),
                              ],
                            ),
                          ),
                        );
                      }),
                ],
              ),
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
      color: Theme.of(context).accentColor,
      child: model.isBusy
          ? ButtonProgressIndicator()
          : Text(
              G.of(context).resetpassword,
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

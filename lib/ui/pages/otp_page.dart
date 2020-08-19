import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/MoonBlink_LOGO_widget.dart';
import 'package:moonblink/base_widget/TopCurvePanel_widget.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/LoginFormContainer_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_button_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/otp_field_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/view_model/otp_model.dart';
import 'package:provider/provider.dart';

class OtpPage extends StatefulWidget {
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  @override
  void initState() {
    super.initState();
  }

  final _phoneController = TextEditingController(text: '+959');
  final _otpCodeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpCodeController.dispose();
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
                      Container(
                        child: Text(
                          S.of(context).otpWelcomePartner,
                          style: Theme.of(context)
                              .accentTextTheme
                              .headline6
                              .copyWith(wordSpacing: 6),
                        ),
                      ),
                      LoginFormContainer(
                        child: ProviderWidget<OtpModel>(
                          model: OtpModel(Provider.of(context)),
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
                                label: S.of(context).labelphno,
                                icon: FontAwesomeIcons.phone,
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                              OtpTextField(
                                _phoneController,
                                label: S.of(context).labelotp,
                                icon: FontAwesomeIcons.sms,
                                controller: _otpCodeController,
                                keyboardType: TextInputType.number,
                              ),
                              // ResendTokenButton(phone: _phoneController.text)
                              // ,
                              // SizedBox( height: 30),
                              SignAsPartnerButton(_otpCodeController),
                            ],
                          ),
                        ),
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

class SignAsPartnerButton extends StatelessWidget {
  SignAsPartnerButton(this.otpController);
  final otpController;
  @override
  Widget build(BuildContext context) {
    var model = Provider.of<OtpModel>(context);
    return LoginButtonWidget(
      child: model.isBusy
          ? ButtonProgressIndicator()
          : Text(
              S.of(context).otpSignAsPartnerButton,
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
                model.signInWithCredential(otpController.text).then((value) {
                  if (value) {
                    Navigator.of(context).pushNamed(RouteName.setprofile);
                  } else {
                    model.showErrorMessage(context);
                  }
                });
              }
            },
    );
  }
}

class ResendTokenButton extends StatelessWidget {
  final String phone;

  const ResendTokenButton({Key key, this.phone}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var model = Provider.of<OtpModel>(context);
    return LoginButtonWidget(
      child: model.isBusy
          ? ButtonProgressIndicator()
          : Text(
              'Resend Token Testing',
              style: Theme.of(context)
                  .accentTextTheme
                  .headline6
                  .copyWith(wordSpacing: 6),
            ),
      onPressed: model.isBusy
          ? null
          : () {
              model.getFirebaseOtp(phone: phone, retry: true);
            },
    );
  }
}

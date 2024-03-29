import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/container/titleContainer.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/LoginFormContainer_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_button_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/otp_field_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/ui/pages/user/unverified_partner_signup_page.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/otp_model.dart';
import 'package:provider/provider.dart';

class Type5PartnerOtpPage extends StatefulWidget {
  @override
  _Type5PartnerOtpPageState createState() => _Type5PartnerOtpPageState();
}

class _Type5PartnerOtpPageState extends State<Type5PartnerOtpPage> {
  final String _spPhoneNumber =
      StorageManager.sharedPreferences.getString(spPhoneNumber);
  final _phoneController = TextEditingController(text: '+959');
  final _otpCodeController = TextEditingController();
  @override
  void initState() {
    _initPhoneController();
    super.initState();
  }

  void _initPhoneController() {
    if (_spPhoneNumber == '') {
      setState(() {
        _phoneController.text = '+959';
      });
    }
    if (_spPhoneNumber != '') {
      setState(() {
        _phoneController.text = _spPhoneNumber;
      });
    }
  }

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
            backgroundColor: Colors.black,
            actions: [
              AppbarLogo(),
            ],
          ),
          SliverToBoxAdapter(
            child: Stack(
              children: <Widget>[
                Container(
                  color: Colors.black,
                  height: 200,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 150),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(50.0)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                  child: TitleContainer(
                    height: 100,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Center(
                      child: Text(
                        G.of(context).otpWelcomePartner,
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 130),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          LoginFormContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                LoginTextField(
                                  label: G.of(context).labelphno,
                                  icon: FontAwesomeIcons.phone,
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                ),
                                OtpTextField(
                                  _phoneController,
                                  label: G.of(context).labelotp,
                                  icon: FontAwesomeIcons.sms,
                                  controller: _otpCodeController,
                                  keyboardType: TextInputType.number,
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                          SignAsPartnerButton(
                            otpController: _otpCodeController,
                            phoneController: _phoneController,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SignAsPartnerButton extends StatelessWidget {
  SignAsPartnerButton({this.otpController, this.phoneController});
  final otpController;
  final phoneController;
  @override
  Widget build(BuildContext context) {
    var model = Provider.of<OtpModel>(context);
    return ShadedContainer(
      color: Theme.of(context).accentColor,
      child: model.isBusy
          ? ButtonProgressIndicator()
          : Text(
              G.of(context).otpSignAsPartnerButton,
              style: Theme.of(context)
                  .accentTextTheme
                  .headline6
                  .copyWith(wordSpacing: 6),
            ),
      ontap: model.isBusy
          ? null
          : () {
              var formState = Form.of(context);
              if (formState.validate()) {
                // model.signAsPartner(otpController.text).then((value)
                model.signInWithCredential(otpController.text).then(
                  (value) {
                    if (value) {
                      StorageManager.sharedPreferences
                          .setString(spPhoneNumber, phoneController.text);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UnverifiedPartnerSignUpPage(
                              phoneController.text)));
                    } else {
                      model.showErrorMessage(context);
                    }
                  },
                );
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

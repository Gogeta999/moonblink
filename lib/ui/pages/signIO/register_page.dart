import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/MoonBlink_LOGO_widget.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/LoginFormContainer_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_button_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/otp_field_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/ui/helper/agreement.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/otp_model.dart';
import 'package:moonblink/view_model/register_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _mailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  // final _lastnameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _rePasswordCtrl = TextEditingController();
  final String _spPhoneNumber =
      StorageManager.sharedPreferences.getString(spPhoneNumber);
  final _phoneController = TextEditingController(text: '+959');
  final _otpCodeController = TextEditingController();
  final _otpModel = OtpModel();
  bool male = false;
  bool female = false;

  @override
  void initState() {
    _initPhoneController();
    super.initState();
  }

  @override
  void dispose() {
    _mailCtrl.dispose();
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _rePasswordCtrl.dispose();
    _phoneController.dispose();
    _otpCodeController.dispose();
    super.dispose();
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
                                    label: G.current.signUpReEnterPassword,
                                    icon: Icons.lock_open,
                                    obscureText: true,
                                    controller: _rePasswordCtrl,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  SizedBox(height: 5),
                                  ProviderWidget<OtpModel>(
                                    model: _otpModel,
                                    builder: (context, model, child) {
                                      return Form(
                                        onWillPop: () async {
                                          return !model.isBusy;
                                        },
                                        child: child,
                                      );
                                    },
                                    child: Column(
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
                                  SizedBox(
                                    height: 40,
                                  ),
                                  RegisterButton(
                                      _mailCtrl,
                                      _nameCtrl,
                                      _passwordCtrl,
                                      _rePasswordCtrl,
                                      _phoneController,
                                      _otpCodeController,
                                      model,
                                      _otpModel)
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
  final TextEditingController mailCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController rePasswordCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController otpCtrl;
  final RegisterModel model;
  final OtpModel otpModel;

  RegisterButton(
      this.mailCtrl,
      this.nameCtrl,
      this.passwordCtrl,
      this.rePasswordCtrl,
      this.phoneCtrl,
      this.otpCtrl,
      this.model,
      this.otpModel);
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
              var formState = Form.of(context);
              if (formState.validate()) {
                // model.signAsPartner(otpController.text).then((value)
                otpModel.signInWithCredential(otpCtrl.text).then(
                  (value) {
                    if (value) {
                      ///Validation error fix
                      if (passwordCtrl.text == rePasswordCtrl.text) {
                        model
                            .singUp(
                                mailCtrl.text, nameCtrl.text, passwordCtrl.text)
                            .then((value) {
                          if (value) {
                            Navigator.of(context).pop(mailCtrl.text);
                          } else {
                            model.showErrorMessage(context);
                          }
                        });
                      } else if (passwordCtrl.text != rePasswordCtrl.text) {
                        showToast('Please enter same password');
                      }
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

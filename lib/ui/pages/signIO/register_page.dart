import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/MoonBlink_LOGO_widget.dart';
import 'package:moonblink/base_widget/TopCurvePanel_widget.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/LoginFormContainer_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_button_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/view_model/register_model.dart';




class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _mailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _lastnameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose(){
    _mailCtrl.dispose();
    _nameCtrl.dispose();
    _lastnameCtrl.dispose();
    _passwordCtrl.dispose();
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
                      ProviderWidget<RegisterModel>(
                        model: RegisterModel(),
                        builder: (context, model, child) => 
                        Form(
                          onWillPop: () async {
                            return !model.isBusy;
                          },
                        child: LoginFormContainer(
                          child: Column(
                            crossAxisAlignment: 
                            CrossAxisAlignment.stretch,
                            children: <Widget>[
                              LoginTextField(
                                label: S.of(context).signUpMail,
                                icon: Icons.mail_outline,
                                controller: _mailCtrl,
                                textInputAction: TextInputAction.next,
                              ),
                              LoginTextField(
                                label: S.of(context).signUpName,
                                icon: Icons.person_outline,
                                controller: _nameCtrl,
                                textInputAction: TextInputAction.next,
                              ),
                              LoginTextField(
                                label: S.of(context).signUpLastName,
                                icon: Icons.person_outline,
                                controller: _lastnameCtrl,
                                textInputAction: TextInputAction.next,
                              ),
                              LoginTextField(
                                label: S.of(context).signUpPassword,
                                icon: Icons.lock_outline,
                                obscureText: true,
                                controller: _passwordCtrl,
                                textInputAction: TextInputAction.done,
                              ),
                              
                              RegisterButton(
                                _mailCtrl,
                                _nameCtrl,
                                _lastnameCtrl,
                                _passwordCtrl,
                                model)
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 25),
                              //   child: ConstrainedBox(
                              //     constraints: BoxConstraints.expand(height: 55.0),
                              //     child: RaisedButton(
                              //       color: Theme.of(context).primaryColor,
                              //       textColor: Theme.of(context).buttonColor,
                              //       child: Text('Login'),
                              //       onPressed: (){
                              //         signup(_mailCtrl.text, _nameCtrl.text, _last_nameCtrl.text, _passwordCtrl.text);
                              //       }), 
                              //   ),
                              // )                                
                            ],
                          ),
                        ),

                        )),
                      
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

class RegisterButton extends StatelessWidget {
  final mailCtrl;
  final nameCtrl;
  final lastnameCtrl;
  final passwordCtrl;
  final RegisterModel model;

  RegisterButton(this.mailCtrl, this.nameCtrl, this.lastnameCtrl, this.passwordCtrl, this.model);
  @override
  Widget build(BuildContext context) {
      return LoginButtonWidget(
      child: model.isBusy
          ? ButtonProgressIndicator()
          : Text(
              S.of(context).signUp,
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
                    .singUp(mailCtrl.text, nameCtrl.text, lastnameCtrl.text, passwordCtrl.text)
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






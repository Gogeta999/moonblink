import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/ui/pages/signIO/resetpassword_page.dart';
import 'package:moonblink/view_model/forgetpassword_model.dart';
import 'package:oktoast/oktoast.dart';

class ForgetPassword extends StatelessWidget {
  ForgetPassword(this.mail);
  final mail;

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ForgetPasswordModel>(
        model: ForgetPasswordModel(),
        builder: (context, model, child) {
          return Center(
            child: GestureDetector(
              onTap: model.isBusy
                  ? null
                  : () {
                      if (mail.text == '') {
                        showToast("Please enter mail");
                      } else {
                        model.forgetPassword(mail.text).then((value) {
                          if (value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ResetPasswordPage(mail: mail.text),
                              ),
                            );
                          } else {
                            model.showErrorMessage(context);
                          }
                        });
                      }
                    },
              child: Text.rich(TextSpan(
                  text: G.of(context).forgetPassword,
                  style: TextStyle(color: Theme.of(context).accentColor))),
            ),
          );
        });
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text.rich(TextSpan(text: S.of(context).noAccount+ '. ', children: [
//         TextSpan(
//             text: S.of(context).toSignUp,
//             recognizer: _recognizerRegister,
//             style: TextStyle(color: Theme.of(context).accentColor))
//       ])),
//     );
//   }
// }

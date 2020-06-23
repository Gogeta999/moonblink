import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:provider/provider.dart';


/// OtpTextField
class OtpTextField extends StatefulWidget {
  final mailController;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String> onFieldSubmitted;
  final TextInputType keyboardType;

  OtpTextField(this.mailController,{
    this.label,
    this.icon,
    this.controller,
    this.obscureText: false,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.keyboardType
  });

  @override
  _OtpTextFieldState createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  TextEditingController controller;

  /// obscureNotifier
  ValueNotifier<bool> obscureNotifier;

  @override
  void initState() {
    controller = widget.controller ?? TextEditingController();
    obscureNotifier = ValueNotifier(widget.obscureText);
    super.initState();
  }

  @override
  void dispose() {
    obscureNotifier.dispose();
    // 默认没有传入controller,需要内部释放
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ValueListenableBuilder(
        valueListenable: obscureNotifier,
        builder: (context, value, child) => TextFormField(
          controller: controller,
          obscureText: value,
          // validator: (text) {
          //   var validator = widget.validator ?? (_) => null;
          //   return text.trim().length > 0
          //       ? validator(text)
          //       : S.of(context).fieldNotEmpty;
          // },
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          keyboardType: widget.keyboardType,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon, color: theme.accentColor, size: 22),
            hintText: widget.label,
            hintStyle: TextStyle(fontSize: 16),
            suffix: GetOtpWordsWidget(widget.mailController),
          ),
        ),
      ),
    );
  }
}

class GetOtpWordsWidget extends StatelessWidget {
  final mailController;
  GetOtpWordsWidget(this.mailController);
  @override
  Widget build(BuildContext context) {
    var model = Provider.of<LoginModel>(context);
    return Container(
      child: model.isBusy
      ? ButtonProgressIndicator()
      : InkWell(
        child: Text("Get Otp Code",
                    style: TextStyle(color: Colors.blue),),
        onTap: model.isBusy
        ? null : (){
          var formState = Form.of(context);
          if (formState.validate()){
            model
                .getOtpCodeAgain(mailController.text)
                .then((value) {
                  if (value) {
                    print('success');
                  } else {
                    model.showErrorMessage(context);
                  }
                });
          }
        }       
        ),
      );
  }
}
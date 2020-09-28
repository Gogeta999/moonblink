import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/view_model/otp_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

/// OtpTextField
class OtpTextField extends StatefulWidget {
  final phoneController; // pass phone number to firebase
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String> onFieldSubmitted;
  final TextInputType keyboardType;

  OtpTextField(this.phoneController,
      {this.label,
      this.icon,
      this.controller,
      this.validator,
      this.focusNode,
      this.textInputAction,
      this.onFieldSubmitted,
      this.keyboardType});

  @override
  _OtpTextFieldState createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  //Input otp for sign as partner
  TextEditingController controller;

  @override
  void initState() {
    controller = widget.controller ?? TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
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
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        controller: controller,
        obscureText: false,
        textAlign: TextAlign.center,
        focusNode: widget.focusNode,
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        onFieldSubmitted: widget.onFieldSubmitted,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon, color: Colors.white, size: 22),
          hintText: widget.label,
          hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: theme.accentColor),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
          suffix: OtpCountDownWidget(
            color: theme.accentColor,
            phoneNumber: widget.phoneController,
          ),
        ),
      ),
    );
  }
}

class OtpCountDownWidget extends StatefulWidget {
  final phoneNumber;
  final color;
  final Function onTimerFinish;
  OtpCountDownWidget({this.phoneNumber, this.color, this.onTimerFinish})
      : super();

  @override
  State<StatefulWidget> createState() => TimerCountDownWidgetState();
}

class TimerCountDownWidgetState extends State<OtpCountDownWidget> {
  Timer _timer;
  int _countdownTime = 0;

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<OtpModel>(context);
    return ButtonTheme(
      minWidth: 16,
      height: 30,
      child: RaisedButton(
        padding: const EdgeInsets.all(5),
        onPressed: () {
          if (_countdownTime == 0) {
            setState(() {
              _countdownTime = 60;
            });
            //Start Count
            startCountdownTimer();
            var formState = Form.of(context);
            if (formState.validate()) {
              print(
                  '------------------------------------------\n=\n${widget.phoneNumber.text}');
              model
                  //getOtpCodeAgain(phoneController.text)
                  .getFirebaseOtp(phone: widget.phoneNumber.text)
                  .then((value) {
                if (value) {
                  print('success');
                  showToast('Please wait, we are sending SMS to you');
                } else {
                  model.showErrorMessage(context);
                }
              });
            }
          }
        },
        color: widget.color,
        child: Text(
          _countdownTime > 0 ? '$_countdownTime' : 'Get Otp',
          style: Theme.of(context)
              .accentTextTheme
              .headline6
              .copyWith(wordSpacing: 3),
        ),
      ),
    );
  }

  void startCountdownTimer() {
    _timer = Timer.periodic(
        Duration(seconds: 1),
        (Timer timer) => {
              setState(() {
                if (_countdownTime < 1) {
                  //widget.onTimerFinish();
                  _timer.cancel();
                } else {
                  _countdownTime = _countdownTime - 1;
                }
              })
            });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }
}

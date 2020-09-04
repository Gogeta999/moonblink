import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';

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
      child: Text.rich(
        TextSpan(text: G.of(context).noAccount + '. ', children: [
          TextSpan(
              text: G.of(context).toSignUp,
              recognizer: _recognizerRegister,
              style: TextStyle(color: Theme.of(context).accentColor)),
          TextSpan(text: G.of(context).or)
        ]),
      ),
    );
  }
}

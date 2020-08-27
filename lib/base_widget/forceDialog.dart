import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';

import 'package:moonblink/global/router_manager.dart';

class ForceUpdateDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ForceLoginDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return forceLoginDialog() async {
    // showDialog(
    //   barrierDismissible: false,
    //   context: locator<NavigationService>()
    //       .navigatorKey
    //       .currentState
    //       .overlay
    //       .context,
    //   builder: (context) {
    return CupertinoAlertDialog(
      title: Text(G.of(context).forceLoginTitle),
      content: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(G.of(context).forceLoginContent),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(G.of(context).confirm),
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(RouteName.login, (route) => false);
          },
        )
      ],
    );
    //     },
    //   );
    // }
  }
}

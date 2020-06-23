import 'package:flutter/material.dart';
import 'package:moonblink/global/resources_manager.dart';

class AppbarLogo extends StatelessWidget {
  const AppbarLogo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Image.asset(
          ImageHelper.wrapAssetsLogo('appbar.jpg'),
          height: 50,
          width: 100,
          fit: BoxFit.contain,
          color: theme.brightness == Brightness.dark
            ? theme.accentColor
            : Colors.white,
          colorBlendMode: BlendMode.srcIn,
      );
  }
}
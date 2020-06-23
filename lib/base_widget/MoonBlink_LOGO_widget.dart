import 'package:flutter/material.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/view_model/theme_model.dart';
import 'package:provider/provider.dart';

class MoonBlinkLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return InkWell(
          onTap: () {
            themeModel.switchRandomTheme();
          },
          child: child,
        );
      },
      child: Hero(
        tag: 'MoonBlinkLogo',
        child: Image.asset(
          ImageHelper.wrapAssetsLogo('MoonBlink_logo.png'),
          width: 130,
          height: 100,
          fit: BoxFit.fitWidth,
          color: theme.brightness == Brightness.dark
              ? theme.accentColor
              : Colors.white,
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
    );
  }
}

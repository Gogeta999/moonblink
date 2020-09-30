import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/customDialog_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/navigation_service.dart';

void gameProfileSetUp() async {
  showDialog(
      context: locator<NavigationService>()
          .navigatorKey
          .currentState
          .overlay
          .context,
      builder: (_) {
        return CustomDialog(
          title: G.current.pleaseAddGameProfile,
          simpleContent: G.current.pleasegameProfileHelperContent,
          cancelColor: Theme.of(locator<NavigationService>()
                  .navigatorKey
                  .currentState
                  .overlay
                  .context)
              .accentColor,
          confirmButtonColor: Theme.of(locator<NavigationService>()
                  .navigatorKey
                  .currentState
                  .overlay
                  .context)
              .accentColor,
          confirmContent: G.current.confirm,
          confirmCallback: () {
            locator<NavigationService>()
                .navigateTo(RouteName.chooseUserPlayGames);
          },
        );
      });
}

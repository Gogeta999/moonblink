import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/titleContainer.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/view_model/local_model.dart';
import 'package:moonblink/view_model/user_model.dart';
import 'package:provider/provider.dart';

class LanguagePage extends StatefulWidget {
  final bool showNext;
  LanguagePage({this.showNext = true});

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  @override
  Widget build(BuildContext context) {
    var hasUser = StorageManager.localStorage.getItem(mUser);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          AppbarLogo(),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
            child: TitleContainer(
              height: 100,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Text(
                  G.of(context).settingLanguage,
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
          ),
          if (hasUser == null && widget.showNext)
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.81),
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                width: double.infinity,
                child: RaisedButton(
                  color: Theme.of(context).accentColor,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Text(
                    "Next",
                    style: Theme.of(context).accentTextTheme.button,
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RouteName.login, (route) => false);
                  },
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(top: 190),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: LocaleModel.localeValueList.length,
              itemBuilder: (context, index) {
                var model = Provider.of<LocaleModel>(context);
                return RadioListTile(
                  value: index,
                  groupValue: model.localeIndex,
                  onChanged: (index) {
                    model.switchLocale(index);
                  },
                  title: Text(LocaleModel.localeName(index, context)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

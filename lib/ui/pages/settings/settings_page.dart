import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/view_model/local_model.dart';
import 'package:provider/provider.dart';


class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconColor = Theme.of(context).accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings),
      ),

      body: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Material(
                color: Theme.of(context).cardColor,
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        S.of(context).settingLanguage
                        // style: TextStyle(),
                        ),
                      Text(
                        LocaleModel.localeName(
                          Provider.of<LocaleModel>(context).localeIndex,
                          context)
                      ),
                    ],
                  ),
                  leading: Icon(
                    Icons.public,
                    color: iconColor,
                  ),
                  children: <Widget>[
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: LocaleModel.localeValueList.length,
                      itemBuilder: (context, index){
                        var model = Provider.of<LocaleModel>(context);
                        return RadioListTile(
                          value: index,
                          groupValue: model.localeIndex, 
                          onChanged: (index){
                            model.switchLocale(index);
                          },
                          title: Text(LocaleModel.localeName(index, context)),
                          );
                      }),
                  ],
                  ),
              ),
              //
              SizedBox(
                height: 20,
              ),
              Material(
                color: Theme.of(context).cardColor,
                child: ListTile(
                  title: Text(S.of(context).ratingApp),
                  onTap: () async {
                    print(Text('Will launch To review after registering at play and ios store'));
                  //   LaunchReview.launch(
                  //       androidAppId: "",
                  //       iOSAppId: "");
                  // },
                  },
                  leading: Icon(Icons.tag_faces, color: iconColor),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            Material(
              color: Theme.of(context).cardColor,
              child: ListTile(
                title: Text(S.of(context).feedback),
                onTap: () async {
                  print('');
                },
                leading: Icon(Icons.feedback,
                color: iconColor,
                ),
                trailing: Icon(Icons.chevron_right),
              ),
            )
            ],
          ),
        ),
      ),
    );
  }
}
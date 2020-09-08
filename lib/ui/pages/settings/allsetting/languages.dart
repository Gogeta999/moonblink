import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/titleContainer.dart';
import 'package:moonblink/view_model/local_model.dart';
import 'package:provider/provider.dart';

class LanguagePage extends StatefulWidget {
  LanguagePage({Key key}) : super(key: key);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  @override
  Widget build(BuildContext context) {
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
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
            child: TitleContainer(
              height: 100,
              color: Colors.white,
              child: Center(
                  child: Text(
                "Language",
                style: TextStyle(fontSize: 30),
              )),
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
                }),
          ),
        ],
      ),
    );
  }
}

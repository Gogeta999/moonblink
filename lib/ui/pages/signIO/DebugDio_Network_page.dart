import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/user.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/view_model/splahAd_model.dart';

class NetWorkPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PageState();
}

class PageState extends State<NetWorkPage> {
  String channelName;
  bool isOpen = false;
  var resultJson = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Testing Page"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SvgPicture.asset(
            home,
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            // alignment: Alignment.center,
            // padding: EdgeInsets.all(50),
            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            height: 100,
            width: 50,
            decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: Colors.grey),
              // color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.black,
                ),
                IconButton(
                    icon: Icon(
                      FontAwesomeIcons.phoneSlash,
                      color: Colors.red[500],
                    ),
                    onPressed: () {
                      print('Decline');
                    }),
                IconButton(
                    icon: Icon(
                      FontAwesomeIcons.phone,
                      color: Colors.green[300],
                    ),
                    onPressed: () {
                      print('joinChannel');
                    }),
              ],
            ),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: resultJson.length <= 0
                  ? Text("数据加载中...")
                  : Text(
                      resultJson,
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ))
        ],
      ),
    );
  }
}

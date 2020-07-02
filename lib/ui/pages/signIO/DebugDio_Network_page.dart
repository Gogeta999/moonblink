import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/notifications.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/user.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';

class NetWorkPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PageState();
}

class PageState extends State<NetWorkPage> {
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
        title: Text("Dio Demo Page"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MaterialButton(
              color: Colors.pinkAccent,
              child: Text("Get with token request"),
              onPressed: () async {
                var test = await PlatformUtils.getBuildNum();
                print(test.toString());
              }),
          MaterialButton(
              color: Colors.blueAccent,
              child: Text("POST with simple request"),
              onPressed: () {
                loginPost();
              }),
          MaterialButton(
            color: Colors.red,
            child: Text("test Notifications"),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LocalNotifications()));
            },
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.center,
              height: 35,
              width: 80,
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: isOpen ? spinkit : Text('False show this'),
            ),
            onTap: isOpen
                ? () {
                    print('True to False');
                    setState(() {
                      isOpen = !isOpen;
                    });
                  }
                : () {
                    print('False to True');
                    setState(() {
                      isOpen = !isOpen;
                    });
                  },
          ),
          SizedBox(
            height: 30,
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.center,
              height: 35,
              width: 80,
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Text('TestButton'),
            ),
            onTap: () async {
              String key = 'abc';
              var userId = StorageManager.sharedPreferences.getInt(mUserId);
              var response = await DioUtils().get(
                  Api.SimpleRequestApi + '$userId/search',
                  queryParameters: {
                    'name': key,
                  });
              return response.data['data']
                  .map<User>((item) => User.fromJsonMap(item))
                  .toList();
            },
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

  static const spinkit = SpinKitRotatingCircle(
    color: Colors.white,
    size: 50.0,
  );
  doRequest() async {
    var pageNum = 1;
    var response = await DioUtils().get(Api.HOME + '$pageNum');
    this.setState(() {
      resultJson = response.toString();
    });
  }

  loginPost() async {
    // var response = await DioUtils().post(Api.LOGIN, queryParameters: {
    //   "mail": "moon1@gmail.com",
    //   "password": "1234",
    //  });

    var response = await DioUtils().post(Api.PARTNERDETAIL + '16' + '/follow');
    this.setState(() {
      resultJson = response.toString();
    });
  }
}

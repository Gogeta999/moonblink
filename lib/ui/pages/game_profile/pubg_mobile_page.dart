import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:oktoast/oktoast.dart';

class PubgMobile extends StatelessWidget {
  _showMaterialDialog(BuildContext context, TextEditingController controller) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter your game ID', textAlign: TextAlign.center),
            content: CupertinoTextField(
              decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor
              ),
              controller: controller,
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  print(controller.text);
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              )
            ],
          );
        });
  }

  _showCupertinoDialog(BuildContext context, TextEditingController controller) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Enter your game ID\n', textAlign: TextAlign.center),
            content: CupertinoTextField(
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor
              ),
              controller: controller,
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  print(controller.text);
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              )
            ],
          );
        });
  }

  _showCupertinoBottomSheet(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text('Select Level'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    showToast('Bronze');
                    Navigator.pop(context);
                  },
                  child: Text('Bronze',
                      style: Theme.of(context).textTheme.bodyText1)),
              CupertinoActionSheetAction(
                  onPressed: () {
                    showToast('Bronze');
                    Navigator.pop(context);
                  },
                  child: Text('Silver',
                      style: Theme.of(context).textTheme.bodyText1)),
              CupertinoActionSheetAction(
                  onPressed: () {
                    showToast('Bronze');
                    Navigator.pop(context);
                  },
                  child: Text('Gold',
                      style: Theme.of(context).textTheme.bodyText1)),
              CupertinoActionSheetAction(
                  onPressed: () {
                    showToast('Bronze');
                    Navigator.pop(context);
                  },
                  child: Text('Platinum',
                      style: Theme.of(context).textTheme.bodyText1)),
              CupertinoActionSheetAction(
                  onPressed: () {
                    showToast('Bronze');
                    Navigator.pop(context);
                  },
                  child: Text('Diamond',
                      style: Theme.of(context).textTheme.bodyText1)),
              CupertinoActionSheetAction(
                  onPressed: () {
                    showToast('Bronze');
                    Navigator.pop(context);
                  },
                  child: Text('Crown',
                      style: Theme.of(context).textTheme.bodyText1)),
              CupertinoActionSheetAction(
                  onPressed: () {
                    showToast('Bronze');
                    Navigator.pop(context);
                  },
                  child: Text('Ace',
                      style: Theme.of(context).textTheme.bodyText1)),
            ],
            cancelButton: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PUBG Mobile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          Text('Skill description',
              style: Theme.of(context).textTheme.bodyText1),
          SizedBox(height: 20),
          Text('Play PUBG Mobile with users to teach them how to play~',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
              )),
          SizedBox(height: 20),
          Text('Qualification requirements',
              style: Theme.of(context).textTheme.bodyText1),
          SizedBox(height: 20),
          Text(
              '1. Female Rank ≥ Silver, Male\'s Rank ≥ Platinum.\n(The screenshot must clearly show the game ID and rank.)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
          Text(
              '2. Provide great Service, be patient, and good at time and emotional management.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
          SizedBox(height: 20),
          Divider(
            thickness: 1,
          ),
          SizedBox(height: 20),
          Text('Fill in skill level',
              style: Theme.of(context).textTheme.bodyText1),
          SizedBox(height: 20),
          InkResponse(
            onTap: () {
              TextEditingController _controller = TextEditingController();
              if (Platform.isAndroid) {
                _showMaterialDialog(context, _controller);
              } else if (Platform.isIOS) {
                _showCupertinoDialog(context, _controller);
              } else {
                showToast('This platform is not supported.');
              }
            },
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text('Game ID'),
                ),
                Icon(Icons.arrow_forward_ios, size: 14)
              ],
            ),
          ),
          SizedBox(height: 20),
          InkResponse(
            onTap: () {
              if (Platform.isAndroid) {
                _showCupertinoBottomSheet(context);
              } else if (Platform.isIOS) {
                _showCupertinoBottomSheet(context);
              } else {
                showToast('This platform is not supported.');
              }
            },
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text('Level'),
                ),
                Icon(Icons.arrow_forward_ios, size: 14)
              ],
            ),
          ),
          SizedBox(height: 20),
          Divider(thickness: 1),
          SizedBox(height: 20),
          Text('Upload skill cover',
              style: Theme.of(context).textTheme.bodyText1),
          SizedBox(height: 20),
          Text('The screenshot must clearly show the game ID and rank.',
              style: TextStyle(color: Colors.deepOrangeAccent)),
          SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: Image.asset(
                  'assets/logos/MoonBlink_logo.png',
                  height: 70,
                ),
              ),
              Expanded(
                  child: Icon(
                Icons.add_box,
                size: 150,
                color: Colors.grey,
              ))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text('Sample Photo',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
              Text('Upload Cover',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
            ],
          ),
          SizedBox(height: 20),
          Divider(thickness: 1),
          SizedBox(height: 20),
          Text('Record skill audio',
              style: Theme.of(context).textTheme.bodyText1),
          SizedBox(height: 20),
          Text('No porn, abusive or illegal contents are allowed in the audio.',
              style: TextStyle(color: Colors.deepOrangeAccent)),
          SizedBox(height: 20),
          Text('00:00',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              textAlign: TextAlign.center),
          SizedBox(height: 20),
          Center(
              child: Platform.isAndroid
                  ? RaisedButton(
                      onPressed: () {},
                      padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: MediaQuery.of(context).size.width * 0.2),
                      child: Icon(Icons.mic_none,
                          size: 32,
                          color: Colors.white),
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    )
                  : CupertinoButton(
                      onPressed: () {},
                      padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: MediaQuery.of(context).size.width * 0.2),
                      child: Icon(Icons.mic_none,
                          size: 32,
                          color: Colors.white),
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    )),
          SizedBox(height: 20),
          Text('Click to start recording',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              textAlign: TextAlign.center),
          SizedBox(height: 20),
          Divider(thickness: 1),
          SizedBox(height: 20),
          Text('About order taking',
              style: Theme.of(context).textTheme.bodyText1),
          SizedBox(height: 20),
          Text(
              'Simply introduce your service features, and the time you can take orders.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300))
        ],
      ),
    );
  }
}

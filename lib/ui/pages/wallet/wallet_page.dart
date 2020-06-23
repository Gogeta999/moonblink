import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/global/router_manager.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
      ),

      body: Column(
        children: <Widget>[
          Container(
 
            alignment: Alignment.center,
            // // color: Colors.grey,
            margin: EdgeInsets.all(10),
            height: 125,
            decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: Colors.grey),
              // color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: ListTile(
              leading: Icon(FontAwesomeIcons.coins, color: Theme.of(context).iconTheme.color,),
              title: Text('Coins 100'),
              subtitle: Text('Balance'),
              trailing: FlatButton(
                color: Theme.of(context).accentColor,
                child: Text('Top Up', style: Theme.of(context).accentTextTheme.button),
                onPressed: (){
                  Navigator.of(context).pushNamed(RouteName.topUp);
                }),
            )
          ),
        ],
      ),
    );
  }
}
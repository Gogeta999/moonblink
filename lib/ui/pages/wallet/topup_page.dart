import 'package:flutter/material.dart';

class TopUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balance Top Up'),
      ),
      body: Column(
        children: <Widget>[
          Text('Select the amount'),
          Container(
            height: 125,
            color: Colors.greenAccent,
          )
        ],
      ),
    );
  }
}
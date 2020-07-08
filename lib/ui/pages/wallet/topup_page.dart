import 'package:flutter/material.dart';

List<Widget> topUpContainers = <Widget>[
  TopUpContainer100(),
  TopUpContainer500(),
  TopUpContainer1000(),
];

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
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(onTap: () {}, child: TopUpContainer100()),
              TopUpContainer500(),
              TopUpContainer1000()
            ],
          ),
          Container(
            height: 10,
          ),
          Container(
            // color: Colors.pink,
            decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            width: 380,
            height: 100,
            child: Text('4'),
          )
        ],
      ),
      persistentFooterButtons: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FlatButton(
              color: Theme.of(context).accentColor,
              onPressed: () {},
              child: Text('Top Up')),
        )
      ],
    );
  }
}

class TopUpContainer100 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      height: 80,
      width: 80,
      child: Text('1'),
    );
  }
}

class TopUpContainer500 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      height: 80,
      width: 80,
      child: Text('2'),
    );
  }
}

class TopUpContainer1000 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      height: 80,
      width: 80,
      child: Text('3'),
    );
  }
}

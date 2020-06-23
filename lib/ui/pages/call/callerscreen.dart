import 'package:flutter/material.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/ui/pages/call/endcall.dart';

class CallerScreen extends StatefulWidget {
  @override
  _CallerScreen createState() => _CallerScreen();
}

class _CallerScreen extends State<CallerScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          padding: EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Calling',
                style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.w300,
                    fontSize: 15),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                'Someone',
                style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 20),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                "Waiting to Connect",
                style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.w300,
                    fontSize: 15),
              ),
              SizedBox(
                height: 20.0,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(200.0),
                child: Image.asset(
                  ImageHelper.wrapAssetsImage("busy.gif"),
                  height: 200.0,
                  width: 200.0,
                ),
              ),
              SizedBox(
                height: 200.0,
              ),
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EndScreen(),) 
                );
                },
                elevation: 20.0,
                shape: CircleBorder(side: BorderSide(color: Colors.red)),
                mini: false,
                child: Icon(
                  Icons.call_end,
                  color: Colors.red,
                ),
                backgroundColor: Colors.red[100],
              )
            ],
          ),
        ),
      ),
    );
  }
}
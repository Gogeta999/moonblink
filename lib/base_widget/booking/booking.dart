import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/view_model/booking_model.dart';

class BookingButton extends StatefulWidget {

  @override
  _BookingButtonState createState() => _BookingButtonState();
}

class _BookingButtonState extends State<BookingButton> {

  ///[Partner idle]
  void available(context,model)
  {
    showDialog(
        context: context,
        builder: (context)
        {
          return new AlertDialog(
            title: new Text("Book To Play With"),
            shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            content: Image.asset(ImageHelper.wrapAssetsImage("images.jpg")),
            actions: [
              FlatButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context, 'Cancel');
                }
              ),
              FlatButton(
                child: new Text("Book"),
                onPressed: () {
                  if (model.isError){
                    print("Error Booking");
                  }
                  else{
                  model.booking();
                  waitingoffer(context, model);
                }
                }
              )
            ],
          );
        }
    );
  }
  ///[Partner busy]
  void busy()
  {
    showDialog(
        context: context,
        builder: (BuildContext context)
        {
          return new AlertDialog(
            title: new Text("Player is unavailable to Play with"),
            shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            content: Image.asset(ImageHelper.wrapAssetsImage('busy.gif')),
            actions: [
                FlatButton(
                  child: new Text("Go Back"),
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                  }
              )
            ],
          );
        }
    );
  }
  ///[Request offer]
  void waitingoffer(context, model) 
  {
    showDialog(
        context: context,
        builder: (BuildContext context)
        {
          ///[Animated Waiter]
          final waiter = SpinKitPouringHourglass(
            color: Theme.of(context).accentColor,
            size: 120,
          );
          return new AlertDialog(
            title: new Text("Please wait Partner to Accept"),
            shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            content: Container(width:180, height: 150, child: waiter ),
            actions: [
               FlatButton(
                child: new Text("Cancel"),
                onPressed: () {
                  model.isEmpty;
                  Navigator.pop(context, 'Cancel');
                }
              )
            ],
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return ProviderWidget<BookingModel> (
      model: BookingModel(),
      builder: (context,model, child) {
    return RaisedButton(
      color: Theme.of(context).primaryColor,
      highlightColor: Theme.of(context).accentColor,
      colorBrightness: Theme.of(context).brightness,
      splashColor: Colors.grey,
      child: Text('Book', style: Theme.of(context).accentTextTheme.button),
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0)),
      ///[to add pop up]
      onPressed: (){
        available(context,model);
      },                       
    );
      });
  }
}
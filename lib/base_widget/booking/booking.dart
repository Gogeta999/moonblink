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
  void available(context, BookingModel model) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Book To Play With"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            content: Image.asset(ImageHelper.wrapAssetsImage("images.jpg")),
            actions: <Widget>[
              BookingDropDown(),
              SizedBox(width: 60.0),
              FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                  }),
              FlatButton(
                  child: Text("Book"),
                  onPressed: () {
                    if (model.isError) {
                      print("Error Booking");
                    } else {
                      model.booking().then((value) => value
                          ? {
                              Navigator.pop(context,
                                  'Cancel'), //remove booking dialog and open another
                              waitingoffer(context, model)
                            }
                          : null);
                    }
                    //api call
                  })
            ],
          );
        });
  }

  ///[Partner busy]
  void busy() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text("Player is unavailable to Play with"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            content: Image.asset(ImageHelper.wrapAssetsImage('busy.gif')),
            actions: [
              FlatButton(
                  child: new Text("Go Back"),
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                  })
            ],
          );
        });
  }

  ///[Request offer]
  void waitingoffer(context, BookingModel model) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          ///[Animated Waiter]
          final waiter = SpinKitPouringHourglass(
            color: Theme.of(context).accentColor,
            size: 120,
          );
          return new AlertDialog(
            title: new Text("Please wait Partner to Accept"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            content: Container(width: 180, height: 150, child: waiter),
            actions: [
              FlatButton(
                  child: new Text("Cancel"),
                  onPressed: () {
                    model.isEmpty;
                    Navigator.pop(context, 'Cancel');
                  })
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<BookingModel>(
        model: BookingModel(),
        builder: (context, model, child) {
          return RaisedButton(
            color: Theme.of(context).primaryColor,
            highlightColor: Theme.of(context).accentColor,
            colorBrightness: Theme.of(context).brightness,
            splashColor: Colors.grey,
            child:
                Text('Book', style: Theme.of(context).accentTextTheme.button),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),

            ///[to add pop up]
            onPressed: () {
              available(context, model);
              //testDialog(context, model);
            },
          );
        });
  }
}

class BookingDropDown extends StatefulWidget {
  @override
  _BookingDropDownState createState() => _BookingDropDownState();
}

class _BookingDropDownState extends State<BookingDropDown> {
  String dropdownValue = 'ML';

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: dropdownValue,
        isExpanded: false,
        isDense: true,
        iconEnabledColor: Theme.of(context).primaryColor,
        style: TextStyle(color: Theme.of(context).primaryColor),
        onChanged: (String newValue) {
          setState(() {
            dropdownValue = newValue;
          });
        },
        elevation: 0,
        items: <String>['ML', 'PUBG', 'CoC']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, softWrap: false),
          );
        }).toList(),
      ),
    );
  }
}

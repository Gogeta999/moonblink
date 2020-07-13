import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/view_model/booking_model.dart';
import 'package:moonblink/view_model/partner_detail_model.dart';
import 'package:provider/provider.dart';

class BookingButton extends StatefulWidget {
  @override
  _BookingButtonState createState() => _BookingButtonState();
}

class _BookingButtonState extends State<BookingButton> {
  ///[Partner idle]
  void available(context, BookingModel bookingModel, PartnerDetailModel partnerDetailModel) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Book To Play With"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(ImageHelper.wrapAssetsImage("images.jpg")),
                SizedBox(height: 10.0),
                BookingDropdown(bookingModel: bookingModel),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                  }),
              FlatButton(
                  child: Text("Book"),
                  onPressed: () {
                    if (bookingModel.isError) {
                      print("Error Booking");
                    } else {
                      bookingModel.booking(partnerDetailModel.partnerId).then((value) => value
                          ? {
                              Navigator.pop(context,
                                  'Cancel'), //remove booking dialog and open another
                              waitingoffer(context, bookingModel)
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
    var partnerDetailModel = Provider.of<PartnerDetailModel>(context);
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
              available(context, model, partnerDetailModel);
            },
          );
        });
  }
}

class BookingDropdown extends StatefulWidget {
  final bookingModel;

  const BookingDropdown({Key key, this.bookingModel}) : super(key: key);

  @override
  _BookingDropdownState createState() => _BookingDropdownState();
}

class _BookingDropdownState extends State<BookingDropdown> {

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: widget.bookingModel.dropdownList[widget.bookingModel.selectedIndex],
        isExpanded: false,
        isDense: true,
        iconEnabledColor: Theme.of(context).accentColor,
        style: TextStyle(color: Theme.of(context).accentColor),
        onChanged: (String newValue) {
          setState(() {
            final int selectedIndex = widget.bookingModel.dropdownList.indexOf(newValue);
            print(selectedIndex);
            widget.bookingModel.selectedIndex = selectedIndex;
          });
        },
        elevation: 0,
        items: widget.bookingModel.dropdownList
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


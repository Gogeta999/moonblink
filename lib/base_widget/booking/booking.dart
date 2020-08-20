import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/pages/main/chat/chatbox_page.dart';
import 'package:moonblink/view_model/booking_model.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/partner_detail_model.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';

class BookingButton extends StatefulWidget {
  @override
  _BookingButtonState createState() => _BookingButtonState();
}

class _BookingButtonState extends State<BookingButton> {
  ///[Partner idle]
  void available(context, BookingModel bookingModel,
      PartnerDetailModel partnerDetailModel) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).bookingChooseGameType),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                    height: 220,
                    child: Image.asset(
                      ImageHelper.wrapAssetsImage("bookingWaiting.gif"),
                      fit: BoxFit.cover,
                    )),
                SizedBox(height: 20.0),
                BookingDropdown(bookingModel: bookingModel),
                SizedBox(height: 10.0),
                Row(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.coins,
                      color: Colors.amber[500],
                      size: 16,
                    ),
                    SizedBox(width: 10.0),
                    Text(S.of(context).currentcoin +
                        ': ${bookingModel.wallet.value} ${bookingModel.wallet.value > 1 ? 'coins' : 'coin'}')
                  ],
                ),
              ],
            ),
            contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
            actions: <Widget>[
              FlatButton(
                  child: Text(S.of(context).bookingCancel),
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                  }),
              FlatButton(
                  child: Text(S.of(context).bookingBook),
                  onPressed: () {
                    bookingModel.booking(partnerDetailModel.partnerId).then(
                        (value) => value
                            ? {
                                Navigator.pop(context,
                                    'Cancel'), //remove booking dialog and open another
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatBoxPage(
                                          partnerDetailModel
                                              .partnerData.partnerId),
                                    ))
                              }
                            : showToast(bookingModel.viewStateError.message
                                .toString()));
                  }
                  //api call
                  )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var partnerDetailModel = Provider.of<PartnerDetailModel>(context);
    int userId = StorageManager.sharedPreferences.getInt(mUserId);
    return ProviderWidget<BookingModel>(
        model: BookingModel(),
        onModelReady: (model) async =>
            await model.initData(partnerDetailModel.partnerId),
        builder: (context, model, child) {
          if (model.isBusy) {
            return ViewStateBusyWidget();
          }
          return RaisedButton(
            color: Theme.of(context).accentColor,
            highlightColor: Theme.of(context).accentColor,
            colorBrightness: Theme.of(context).brightness,
            splashColor: Colors.grey,
            child: Text(S.of(context).bookingBook,
                style: Theme.of(context).accentTextTheme.button),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),

            ///[to add pop up]
            onPressed: userId == partnerDetailModel.partnerId || model.isBusy
                ? null
                : () => available(context, model, partnerDetailModel),
          );
        });
  }
}

class BookingDropdown extends StatefulWidget {
  final BookingModel bookingModel;

  const BookingDropdown({Key key, this.bookingModel}) : super(key: key);

  @override
  _BookingDropdownState createState() => _BookingDropdownState();
}

class _BookingDropdownState extends State<BookingDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: widget.bookingModel.dropdownGameListAndPrice.isEmpty
            ? null
            : widget.bookingModel
                .dropdownGameListAndPrice[widget.bookingModel.selectedIndex],
        isExpanded: false,
        isDense: true,
        iconEnabledColor: Theme.of(context).accentColor,
        style: TextStyle(color: Theme.of(context).accentColor),
        onChanged: (String newValue) {
          setState(() {
            final int selectedIndex =
                widget.bookingModel.dropdownGameListAndPrice.indexOf(newValue);
            print(selectedIndex);
            widget.bookingModel.selectedIndex = selectedIndex;
          });
        },
        elevation: 0,
        items: widget.bookingModel.dropdownGameListAndPrice.isEmpty
            ? null
            : widget.bookingModel.dropdownGameListAndPrice
                .map<DropdownMenuItem<String>>((String value) {
                List<String> splitValue = value.split('.');
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(splitValue[0], softWrap: true),
                      Text('    ${splitValue[1]}', softWrap: true)
                    ],
                  ),
                );
              }).toList(),
      ),
    );
  }
}

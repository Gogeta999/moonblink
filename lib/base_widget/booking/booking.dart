import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/view_model/booking_model.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/partner_detail_model.dart';
import 'package:provider/provider.dart';

class BookingButton extends StatefulWidget {
  @override
  _BookingButtonState createState() => _BookingButtonState();
}

class _BookingButtonState extends State<BookingButton> {
  ///[Partner idle]
  /*void available(context, BookingModel bookingModel,
      PartnerDetailModel partnerDetailModel) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(G.of(context).bookingChooseGameType),
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
                    Text(G.of(context).currentcoin +
                        ': ${bookingModel.wallet.value} ${bookingModel.wallet.value > 1 ? 'coins' : 'coin'}')
                  ],
                ),
              ],
            ),
            contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
            actions: <Widget>[
              FlatButton(
                  child: Text(G.of(context).bookingCancel),
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                  }),
              FlatButton(
                  child: Text(G.of(context).bookingBook),
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
  }*/

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
            return CupertinoActivityIndicator();
          }
          return InkResponse(
            onTap: userId == partnerDetailModel.partnerId || model.isBusy
                ? null
                : () => CustomBottomSheet.showBookingSheet(
                    buildContext: context,
                    model: model,
                    partnerId: partnerDetailModel.partnerId),
            child: Container(
              height: 80,
              width: 160,
              child: Center(
                child: Text(G.of(context).bookingRequest,
                    style: Theme.of(context).textTheme.button),
              ),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.black,
                      spreadRadius: 2,
                      // blurRadius: 2,
                      offset: Offset(-8, 7), // changes position of shadow
                    ),
                  ]),
            ),
          );
        });
  }
}
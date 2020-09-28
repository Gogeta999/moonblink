import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class BasicDateField extends StatelessWidget {
  final _dob;
  BasicDateField(this._dob);
  final format = DateFormat("dd-MM-yyyy");
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 15),
      child: DateTimeField(
        validator: (DateTime dateTime) {
          if (dateTime == null) {
            return "Date Time Required";
          }
          return null;
        },
        textInputAction: TextInputAction.next,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
        controller: _dob,
        decoration: InputDecoration(
            prefixIcon: Icon(FontAwesomeIcons.birthdayCake,
                color: Colors.white, size: 22),
            hintText: "Enter Date of Birth",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).accentColor),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
            hintStyle: TextStyle(color: Colors.white, fontSize: 16)),
        format: format,
        onShowPicker: (context, currentValue) {
          return DatePicker.showSimpleDatePicker(
            context,
            initialDate: DateTime(1994),
            firstDate: DateTime(1960),
            lastDate: DateTime(2012),
            dateFormat: "dd-MMMM-yyyy",
            confirmText: "Confirm",
            cancelText: "Cancel",
            locale: DateTimePickerLocale.en_us,
            looping: true,
          );
        },
      ),
    );
  }
}

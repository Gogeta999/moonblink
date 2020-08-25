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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: DateTimeField(
        validator: (DateTime dateTime) {
          if (dateTime == null) {
            return "Date Time Required";
          }
          return null;
        },
        textInputAction: TextInputAction.next,
        controller: _dob,
        decoration: InputDecoration(
            prefixIcon: Icon(FontAwesomeIcons.birthdayCake,
                color: Theme.of(context).accentColor, size: 22),
            hintText: "Enter Dob",
            hintStyle: TextStyle(fontSize: 16)),
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

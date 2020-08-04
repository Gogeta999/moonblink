import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/Datetime.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/LoginFormContainer_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/user.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class SetPartnerProfilePage extends StatefulWidget {
  @override
  _SetPartnerProfilePageState createState() => _SetPartnerProfilePageState();
}

class _SetPartnerProfilePageState extends State<SetPartnerProfilePage> {
  bool finished = false;
  final _picker = ImagePicker();
  String _filePath;
  String _genderController;
  List<String> genderList = ["Male", "Female", "Rather Not Say"];
  final _sexController = TextEditingController();
  //final _phController = TextEditingController();
  final _nrcController = TextEditingController();
  final _biosController = TextEditingController();
  final _addressController = TextEditingController();
  //final _mailController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  void dispose() {
    _sexController.dispose();
    //_phController.dispose();
    //_mailController.dispose();
    _nrcController.dispose();
    _biosController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  File _cover;
  File _profile;
  //pick Cover
  _pickCoverFromGallery() async {
    PickedFile cover = await _picker.getImage(source: ImageSource.gallery);
    File image = File(cover.path);
    File temporaryImage = await _getLocalFile();
    File compressedImage =
    await _compressAndGetFile(image, temporaryImage.absolute.path);
    setState(() {
      _cover = compressedImage;
    });
  }

  //pick profile
  _pickprofileFromGallery() async {
    PickedFile profile = await _picker.getImage(source: ImageSource.gallery);
    File image = File(profile.path);
    File temporaryImage = await _getLocalFile();
    File compressedImage =
    await _compressAndGetFile(image, temporaryImage.absolute.path);
    setState(() {
      _profile = compressedImage;
    });
  }

  // 2. compress file and get file.
  Future<File> _compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    _filePath =
        '$path/' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpeg';
    return File(_filePath);
  }

  //get Space
  get _space {
    return SizedBox(height: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).setPartnerProfile),
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
              child: ProviderWidget<LoginModel>(
                  model: LoginModel(Provider.of(context)),
                  builder: (context, model, child) => Form(
                        onWillPop: () async {
                          showDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                    title: Text(S
                                        .of(context)
                                        .setPartnerFillInformations),
                                  ));
                          return !model.isBusy;
                        },

                        /// [make cover in a simple container, onpress or ontap u can use pickcoverfrom gallery directly]
                        child: Stack(
                          children: <Widget>[
                            GestureDetector(
                              /// [You need to put before OnTap]
                              onTap: () {
                                _pickCoverFromGallery();
                              },
                              child: PartnerCoverWidget(_cover),
                            ),

                            /// [same as profile image too, if null asset local image if u can click at partnerprofilewidget then click F12 to see code template]
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 140.0),
                              child: Container(
                                child: Align(
                                    alignment: Alignment.center,
                                    child: GestureDetector(
                                      /// [You need to put before OnTap]
                                      onTap: () {
                                        _pickprofileFromGallery();
                                      },
                                      child: CircleAvatar(
                                        radius: 75,
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        child: ClipOval(
                                          child: new SizedBox(
                                            width: 150.0,
                                            height: 150.0,
                                            child:
                                                PartnerProfileWidget(_profile),
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: 270,
                                  ),
                                  LoginFormContainer(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          //NRC
                                          LoginTextField(
                                            validator: (value) => value.isEmpty
                                                ? 'Please enter NRC'
                                                : null,
                                            label: "Please enter NRC",
                                            icon: FontAwesomeIcons.idCard,
                                            controller: _nrcController,
                                            textInputAction:
                                                TextInputAction.next,
                                            keyboardType: TextInputType.text,
                                          ),
                                          _space,
                                          //email
                                          /*LoginTextField(
                                            validator: (value) => value.isEmpty
                                                ? 'Please enter email'
                                                : null,
                                            label: "Please enter email",
                                            icon: FontAwesomeIcons.mailBulk,
                                            controller: _mailController,
                                            textInputAction:
                                                TextInputAction.next,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                          ),
                                          _space,*/
                                          DropdownButtonFormField<String>(
                                            decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                    FontAwesomeIcons.genderless,
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                    size: 22),
                                                hintText: "Enter Gender",
                                                hintStyle:
                                                    TextStyle(fontSize: 16)),
                                            value: _genderController,
                                            onChanged: (value) => setState(() =>
                                                _genderController = value),
                                            validator: (value) => value == null
                                                ? 'field required'
                                                : null,
                                            items: genderList
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                          _space,
                                          //date
                                          BasicDateField(_dobController),
                                          _space,
                                          //phone
                                          /*LoginTextField(
                                            validator: (value) => value.isEmpty
                                                ? 'Please enter Phno'
                                                : null,
                                            label: "Please enter Phone",
                                            icon: FontAwesomeIcons.phone,
                                            controller: _phController,
                                            textInputAction:
                                                TextInputAction.next,
                                            keyboardType: TextInputType.phone,
                                          ),
                                          _space,*/
                                          //bios
                                          LoginTextField(
                                            validator: (value) => value.isEmpty
                                                ? 'Please enter Bios'
                                                : null,
                                            label: "Please enter Bios",
                                            icon: FontAwesomeIcons.book,
                                            controller: _biosController,
                                            textInputAction:
                                                TextInputAction.next,
                                            keyboardType: TextInputType.text,
                                          ),
                                          _space,
                                          //address
                                          LoginTextField(
                                            validator: (value) => value.isEmpty
                                                ? 'Please enter Address'
                                                : null,
                                            label: "Please enter Address",
                                            icon: FontAwesomeIcons.addressBook,
                                            controller: _addressController,
                                            textInputAction:
                                                TextInputAction.next,
                                            keyboardType: TextInputType.text,
                                          ),
                                          _space,
                                          RaisedButton(
                                            child: finished
                                                ? ButtonProgressIndicator()
                                                : Text(
                                                    S
                                                        .of(context)
                                                        .setPartnerButton,
                                                    style: Theme.of(context)
                                                        .accentTextTheme
                                                        .button
                                                        .copyWith(
                                                            wordSpacing: 6)),
                                            onPressed: () async {
                                              var userid = StorageManager
                                                  .sharedPreferences
                                                  .getInt(mUserId);
                                              var coverPath = _cover.absolute.path;
                                              var profilePath = _profile.absolute.path;
                                              FormData formData =
                                                  FormData.fromMap({
                                                'cover_image':
                                                    await MultipartFile
                                                        .fromFile(coverPath,
                                                            filename:
                                                                'cover.jpg',
                                                    ),
                                                'profile_image':
                                                    await MultipartFile
                                                        .fromFile(
                                                            profilePath,
                                                            filename:
                                                                'profile.jpg'),
                                                'nrc': _nrcController.text.toString(),
                                                //'mail': _mailController.text.toString(),
                                                'gender': _genderController.toString(),
                                                'dob': _dobController.text.toString(),
                                                //'phone': _phController.text.toString(),
                                                'bios': _biosController.text.toString(),
                                                'address':
                                                    _addressController.text.toString()
                                              });
                                              var response = await DioUtils()
                                                  .postwithData(
                                                      Api.SetProfile +
                                                          '$userid/profile',
                                                      data: formData);
                                              print('PRINTED $response');
                                              model.logout();
                                              Navigator.of(context)
                                                  .pushNamedAndRemoveUntil(
                                                      RouteName.splash,
                                                      (route) => false);
                                              return User.fromJsonMap(
                                                  response.data);
                                            },
                                          ),
                                          // SetProfileButton(
                                          //     _cover,
                                          //     _profile,
                                          //     _nrcController.text,
                                          //     _mailController.text,
                                          //     _genderController,
                                          //     _dobController.text,
                                          //     _phController.text,
                                          //     _biosController.text,
                                          //     _addressController.text),
                                        ]),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )))
        ],
      ),
    );
  }
}

///[Change Image.file (ImagePicker get File format)]
class PartnerCoverWidget extends StatelessWidget {
  PartnerCoverWidget(this.cover);
  final cover;
  @override
  Widget build(BuildContext context) {
    if (this.cover == null) {
      return Image.asset(
        ImageHelper.wrapAssetsImage('defaultBackground.jpg'),
        fit: BoxFit.contain,
      );
    } else {
      return Image.file(
        cover,
        filterQuality: FilterQuality.medium,
        fit: BoxFit.cover,
      );
    }
  }
}

///[Change Image.file (ImagePicker get File format)]
class PartnerProfileWidget extends StatelessWidget {
  PartnerProfileWidget(this.profile);
  final profile;
  @override
  Widget build(BuildContext context) {
    if (this.profile == null) {
      return Image.asset(
        ImageHelper.wrapAssetsLogo('person.png'),
        fit: BoxFit.fill,
      );
    } else {
      return Image.file(
        this.profile,
        fit: BoxFit.fill,
      );
    }
  }
}

// class SetProfileButton extends StatelessWidget {
//   final cover;
//   final profile;
//   final phone;
//   final mail;
//   final address;
//   final nrc;
//   final gender;
//   final dob;
//   final bios;
//   // final LoginModel model;
//   // final cover;

//   SetProfileButton(this.cover, this.profile, this.nrc, this.mail, this.gender,
//       this.dob, this.phone, this.bios, this.address);
//   @override
//   Widget build(BuildContext context) {
//     var model = Provider.of<LoginModel>(context);
//     return LoginButtonWidget(
//       //controller: _btnController,
//       child: model.isBusy
//           ? ButtonProgressIndicator()
//           : Text(S.of(context).setPartnerButton,
//               style: Theme.of(context)
//                   .accentTextTheme
//                   .button
//                   .copyWith(wordSpacing: 6)),
//       onPressed: () async {
//         var userid = StorageManager.sharedPreferences.getInt(mUserId);
//         var coverPath = cover.path;
//         var profilePath = profile.path;
//         FormData formData = FormData.fromMap({
//           'cover_image':
//               await MultipartFile.fromFile(coverPath, filename: 'cover.jpg'),
//           'profile_image': await MultipartFile.fromFile(profilePath,
//               filename: 'profile.jpg'),
//           'nrc': nrc,
//           'mail': mail,
//           'gender': gender,
//           'dob': dob,
//           'phone': phone,
//           'bios': bios,
//           'address': address
//         });
//         var response = await DioUtils()
//             .postwithData(Api.SetProfile + '$userid/profile', data: formData);
//         print(response);
//         model.logout();
//         Navigator.of(context)
//             .pushNamedAndRemoveUntil(RouteName.splash, (route) => false);
//         return User.fromJsonMap(response.data);
//       },
//     );
//   }
// }

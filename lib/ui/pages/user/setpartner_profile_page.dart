import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/container/titleContainer.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/Datetime.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/LoginFormContainer_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/user.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

enum NrcType { front, back }

class SetPartnerProfilePage extends StatefulWidget {
  @override
  _SetPartnerProfilePageState createState() => _SetPartnerProfilePageState();
}

class _SetPartnerProfilePageState extends State<SetPartnerProfilePage> {
  bool finished = false;
  final _picker = ImagePicker();
  final _nrcController = TextEditingController();
  final _biosController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  String _gender = '';

  @override
  void dispose() {
    _nrcController.dispose();
    _biosController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // File _cover;
  // File _profile;
  File _nrcFront;
  File _nrcBack;

  // 2. compress file and get file.
  Future<File> _compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: 70, minWidth: 500, minHeight: 500);

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final filePath =
        '$path/' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpeg';
    return File(filePath);
  }

  _pickNrcFromCamera(NrcType type) async {
    PickedFile pickedFile = await _picker.getImage(source: ImageSource.camera);
    File image = File(pickedFile.path);
    File tempImage = await _getLocalFile();
    File compressedImage =
        await _compressAndGetFile(image, tempImage.absolute.path);
    switch (type) {
      case NrcType.front:
        setState(() {
          _nrcFront = compressedImage;
        });
        return;
      case NrcType.back:
        setState(() {
          _nrcBack = compressedImage;
        });
        return;
      default:
        showToast('Developer\'s error');
    }
  }

  //get Space
  get _space {
    return SizedBox(height: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.black,
              actions: [
                AppbarLogo(),
              ],
            ),
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Container(
                    color: Colors.black,
                    height: 200,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 150),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(50.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                    child: TitleContainer(
                      height: 100,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Center(
                        child: Text(
                          G.of(context).otpWelcomePartner,
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: ProviderWidget<LoginModel>(
                model: LoginModel(Provider.of(context)),
                builder: (context, model, child) => Form(
                  onWillPop: () async {
                    Navigator.pop(context);
                    return false;
                  },

                  /// [make cover in a simple container, onpress or ontap u can use pickcoverfrom gallery directly]
                  child: Column(
                    children: <Widget>[
                      LoginFormContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            //NRC
                            LoginTextField(
                              validator: (value) =>
                                  value.isEmpty ? G.of(context).labelnrc : null,
                              label: G.of(context).labelnrc,
                              icon: FontAwesomeIcons.idCard,
                              controller: _nrcController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                            ),
                            _space,
                            //date
                            BasicDateField(_dobController),
                            _space,
                            //bios
                            LoginTextField(
                              validator: (value) => value.isEmpty
                                  ? G.of(context).labelbios
                                  : null,
                              label: G.of(context).labelbios,
                              icon: FontAwesomeIcons.book,
                              controller: _biosController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                            ),
                            _space,
                            //address
                            LoginTextField(
                              validator: (value) => value.isEmpty
                                  ? G.of(context).labeladdress
                                  : null,
                              label: G.of(context).labeladdress,
                              icon: FontAwesomeIcons.addressBook,
                              controller: _addressController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                            ),
                            _space,

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ShadedContainer(
                                  selected:
                                      _gender.isNotEmpty && _gender == 'Male'
                                          ? true
                                          : false,
                                  ontap: () {
                                    setState(() {
                                      _gender = 'Male';
                                    });
                                  },
                                  child: Text(G.of(context).genderMale),
                                ),
                                ShadedContainer(
                                  selected:
                                      _gender.isNotEmpty && _gender == 'Female'
                                          ? true
                                          : false,
                                  ontap: () {
                                    setState(() {
                                      _gender = 'Female';
                                    });
                                  },
                                  child: Text(G.of(context).genderFemale),
                                )
                              ],
                            ),
                            _space,
                          ],
                        ),
                      ),
                      //NRC
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: [
                                Expanded(
                                  child: InkResponse(
                                    onTap: () => _showSelectImageOptions(
                                        context, NrcType.front),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          height: 140,
                                          child: _nrcFront == null
                                              ? Icon(
                                                  FontAwesomeIcons.addressCard,
                                                  size: 100,
                                                  color: Theme.of(context)
                                                      .accentColor)
                                              : Image.file(
                                                  _nrcFront,
                                                  fit: BoxFit.fill,
                                                ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(G.of(context).labelnrcfront,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkResponse(
                                    onTap: () => _showSelectImageOptions(
                                        context, NrcType.back),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          height: 140,
                                          child: _nrcBack == null
                                              ? Icon(
                                                  FontAwesomeIcons
                                                      .solidAddressCard,
                                                  size: 100,
                                                  color: Theme.of(context)
                                                      .accentColor)
                                              : Image.file(
                                                  _nrcBack,
                                                  fit: BoxFit.fill,
                                                ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(G.of(context).labelnrcback,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      ShadedContainer(
                        color: Theme.of(context).accentColor,
                        selected: false,
                        child: finished
                            ? ButtonProgressIndicator()
                            : Text(G.of(context).setPartnerButton,
                                style: Theme.of(context)
                                    .accentTextTheme
                                    .button
                                    .copyWith(wordSpacing: 6)),
                        ontap: () => _onTapUploadProfile(model),
                      ),
                      _space,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onTapUploadProfile(LoginModel model) async {
    // if (_cover == null || _profile == null) {
    //   showToast(G.of(context).toastimagenull);
    //   return false;
    // } else
    if (_nrcFront == null || _nrcBack == null) {
      showToast(G.of(context).toastnrcnull);
      return false;
    } else if (_gender.isEmpty) {
      showToast('Gender ${G.of(context).cannotblank}');
      return false;
    } else if (_nrcController == null ||
        _dobController == null ||
        _addressController == null) {
      showToast(G.of(context).toastlackfield);
      return false;
    } else {
      setState(() {
        finished = !finished;
      });
      var userid = StorageManager.sharedPreferences.getInt(mUserId);
      // var coverPath = _cover.absolute.path;
      // var profilePath = _profile.absolute.path;
      FormData formData = FormData.fromMap({
        // 'cover_image': await MultipartFile.fromFile(
        //   coverPath,
        //   filename: 'cover.jpg',
        // ),
        // 'profile_image': await MultipartFile.fromFile(
        //     profilePath,
        //     filename: 'profile.jpg'),
        'nrc_front_image': await MultipartFile.fromFile(_nrcFront.absolute.path,
            filename: 'nrc_front_image.jpg'),
        'nrc_back_image': await MultipartFile.fromFile(_nrcBack.absolute.path,
            filename: 'nrc_back_image.jpg'),
        'nrc': _nrcController.text.toString(),
        'gender': _gender,
        'dob': _dobController.text.toString(),
        'bios': _biosController.text.toString(),
        'address': _addressController.text.toString()
      });

      var response =
          await DioUtils().postwithData(Api.SetProfile + '$userid/profile',
              data: formData,
              options: Options(
                sendTimeout: 25 * 1000,
                receiveTimeout: 25 * 1000,
              ));
      print('PRINTED $response');
      print("+++++++++++++++++++++++++++++++++++++");
      setState(() {
        finished = !finished;
      });
      print("----------------------------------------------------");
      model.logout();
      Navigator.of(context)
          .pushNamedAndRemoveUntil(RouteName.splash, (route) => false);
      return User.fromJsonMap(response.data);
    }
  }

  _showSelectImageOptions(BuildContext context, NrcType type) {
    return showCupertinoDialog(
      context: context,
      builder: (builder) => CupertinoAlertDialog(
        content: Text(G.of(context).pickimage),
        actions: <Widget>[
          CupertinoButton(
              child: Text(G.of(context).imagePickerGallery),
              onPressed: () {
                CustomBottomSheet.show(
                    buildContext: context,
                    limit: 1,
                    body: G.of(context).picknrc,
                    onPressed: (File file) {
                      setState(() {
                        type == NrcType.front
                            ? _nrcFront = file
                            : _nrcBack = file;
                      });
                    },
                    buttonText: G.of(context).select,
                    popAfterBtnPressed: true,
                    requestType: RequestType.image,
                    minWidth: 500,
                    minHeight: 500,
                    willCrop: false,
                    compressQuality: 70);
                Navigator.pop(context);
              }),
          CupertinoButton(
            child: Text(G.of(context).imagePickerCamera),
            onPressed: () => _pickNrcFromCamera(type),
          ),
          CupertinoButton(
            child: Text(G.of(context).cancel),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}

///[Change Image.file (ImagePicker get File format)]
// class PartnerCoverWidget extends StatelessWidget {
//   PartnerCoverWidget(this.cover);
//   final cover;
//   @override
//   Widget build(BuildContext context) {
//     if (this.cover == null) {
//       return Image.asset(
//         ImageHelper.wrapAssetsImage('defaultBackground.jpg'),
//         fit: BoxFit.cover,
//       );
//     } else {
//       return Image.file(
//         cover,
//         filterQuality: FilterQuality.high,
//         fit: BoxFit.cover,
//       );
//     }
//   }
// }
//
// ///[Change Image.file (ImagePicker get File format)]
// class PartnerProfileWidget extends StatelessWidget {
//   PartnerProfileWidget(this.profile);
//   final profile;
//   @override
//   Widget build(BuildContext context) {
//     if (this.profile == null) {
//       return Image.asset(
//         ImageHelper.wrapAssetsImage('MoonBlinkProfile.jpg'),
//         fit: BoxFit.fill,
//       );
//     } else {
//       return Image.file(
//         this.profile,
//         fit: BoxFit.fill,
//       );
//     }
//   }
// }

// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:moonblink/api/moonblink_api.dart';
// import 'package:moonblink/api/moonblink_dio.dart';
// import 'package:moonblink/base_widget/Datetime.dart';
// import 'package:moonblink/base_widget/indicator/button_indicator.dart';
// import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
// import 'package:moonblink/base_widget/sign_IO_widgets/LoginFormContainer_widget.dart';
// import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
// import 'package:moonblink/generated/l10n.dart';
// import 'package:moonblink/global/resources_manager.dart';
// import 'package:moonblink/global/router_manager.dart';
// import 'package:moonblink/global/storage_manager.dart';
// import 'package:moonblink/models/user.dart';
// import 'package:moonblink/provider/provider_widget.dart';
// import 'package:moonblink/view_model/login_model.dart';
// import 'package:oktoast/oktoast.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:provider/provider.dart';

// enum NrcType { front, back }

// class SetPartnerProfilePage extends StatefulWidget {
//   @override
//   _SetPartnerProfilePageState createState() => _SetPartnerProfilePageState();
// }

// class _SetPartnerProfilePageState extends State<SetPartnerProfilePage> {
//   bool finished = false;
//   final _picker = ImagePicker();
//   String _filePath;
//   String _genderController;
//   List<String> genderList = ["Male", "Female"];
//   //final _phController = TextEditingController();
//   final _nrcController = TextEditingController();
//   final _biosController = TextEditingController();
//   final _addressController = TextEditingController();
//   //final _mailController = TextEditingController();
//   final _dobController = TextEditingController();

//   @override
//   void dispose() {
//     _nrcController.dispose();
//     _biosController.dispose();
//     _addressController.dispose();
//     _dobController.dispose();
//     super.dispose();
//   }

//   File _cover;
//   File _profile;
//   File _nrcFront;
//   File _nrcBack;
//   // //pick Cover
//   // _pickCoverFromGallery() async {
//   //   PickedFile cover = await _picker.getImage(source: ImageSource.gallery);
//   //   File image = File(cover.path);
//   //   File temporaryImage = await _getLocalFile();
//   //   File compressedImage =
//   //       await _compressAndGetFile(image, temporaryImage.absolute.path);
//   //   setState(() {
//   //     _cover = compressedImage;
//   //   });
//   // }

//   // //pick profile
//   // _pickprofileFromGallery() async {
//   //   PickedFile profile = await _picker.getImage(source: ImageSource.gallery);
//   //   File image = File(profile.path);
//   //   File temporaryImage = await _getLocalFile();
//   //   File compressedImage =
//   //       await _compressAndGetFile(image, temporaryImage.absolute.path);
//   //   setState(() {
//   //     _profile = compressedImage;
//   //   });
//   // }

//   _pickNrcFromGallery(NrcType type) async {
//     PickedFile pickedFile = await _picker.getImage(source: ImageSource.camera);
//     File image = File(pickedFile.path);
//     switch (type) {
//       case NrcType.front:
//         setState(() {
//           _nrcFront = image;
//         });
//         return;
//       case NrcType.back:
//         setState(() {
//           _nrcBack = image;
//         });
//         return;
//       default:
//         showToast('Developer\'s error');
//     }
//   }

//   //get Space
//   get _space {
//     return SizedBox(height: 20);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(G.of(context).setPartnerProfile),
//       ),
//       body: CustomScrollView(
//         physics: ClampingScrollPhysics(),
//         slivers: <Widget>[
//           SliverToBoxAdapter(
//               child: ProviderWidget<LoginModel>(
//                   model: LoginModel(Provider.of(context)),
//                   builder: (context, model, child) => Form(
//                         onWillPop: () async {
//                           /*showDialog(
//                               context: context,
//                               builder: (context) => CupertinoAlertDialog(
//                                     title: Text(S
//                                         .of(context)
//                                         .setPartnerFillInformations),
//                                   ));
//                           return !model.isBusy;*/
//                           Navigator.pop(context);
//                           return false;
//                         },

//                         /// [make cover in a simple container, onpress or ontap u can use pickcoverfrom gallery directly]
//                         child: Stack(
//                           children: <Widget>[
//                             GestureDetector(
//                               /// [You need to put before OnTap]
//                               onTap: () {
//                                 // _pickCoverFromGallery();
//                                 CustomBottomSheet.show(
//                                     requestType: RequestType.image,
//                                     popAfterBtnPressed: true,
//                                     buttonText: G.of(context).choose,
//                                     buildContext: context,
//                                     limit: 1,
//                                     onPressed: (File file) {
//                                       setState(() {
//                                         _cover = file;
//                                       });
//                                     },
//                                     body: G.of(context).partnercover);
//                               },
//                               child: AspectRatio(
//                                   aspectRatio: 100 / 100,
//                                   child: PartnerCoverWidget(_cover)),
//                             ),

//                             /// [same as profile image too, if null asset local image if u can click at partnerprofilewidget then click F12 to see code template]
//                             Padding(
//                               padding: const EdgeInsets.only(
//                                   left: 20.0, right: 20.0, top: 140.0),
//                               child: Container(
//                                 child: Align(
//                                     alignment: Alignment.center,
//                                     child: GestureDetector(
//                                       /// [You need to put before OnTap]
//                                       onTap: () {
//                                         CustomBottomSheet.show(

//                                             ///profile is small
//                                             popAfterBtnPressed: true,
//                                             requestType: RequestType.image,
//                                             minWidth: 480,
//                                             minHeight: 480,
//                                             buttonText: G.of(context).choose,
//                                             buildContext: context,
//                                             limit: 1,
//                                             onPressed: (File file) {
//                                               setState(() {
//                                                 _profile = file;
//                                               });
//                                             },
//                                             body: G.of(context).partnerprofile);
//                                       },
//                                       child: CircleAvatar(
//                                         radius: 75,
//                                         backgroundColor:
//                                             Theme.of(context).primaryColor,
//                                         child: ClipOval(
//                                           child: new SizedBox(
//                                             width: 150.0,
//                                             height: 150.0,
//                                             child:
//                                                 PartnerProfileWidget(_profile),
//                                           ),
//                                         ),
//                                       ),
//                                     )),
//                               ),
//                             ),

//                             Container(
//                               padding: EdgeInsets.symmetric(vertical: 20),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: <Widget>[
//                                   SizedBox(
//                                     height: 270,
//                                   ),
//                                   LoginFormContainer(
//                                     child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.stretch,
//                                         children: <Widget>[
//                                           //NRC
//                                           LoginTextField(
//                                             validator: (value) => value.isEmpty
//                                                 ? G.of(context).labelnrc
//                                                 : null,
//                                             label: G.of(context).labelnrc,
//                                             icon: FontAwesomeIcons.idCard,
//                                             controller: _nrcController,
//                                             textInputAction:
//                                                 TextInputAction.next,
//                                             keyboardType: TextInputType.text,
//                                           ),
//                                           _space,
//                                           DropdownButtonFormField<String>(
//                                             decoration: InputDecoration(
//                                                 prefixIcon: Icon(
//                                                     FontAwesomeIcons.genderless,
//                                                     color: Theme.of(context)
//                                                         .accentColor,
//                                                     size: 22),
//                                                 hintText:
//                                                     G.of(context).labelgender,
//                                                 hintStyle:
//                                                     TextStyle(fontSize: 16)),
//                                             value: _genderController,
//                                             onChanged: (value) => setState(() =>
//                                                 _genderController = value),
//                                             validator: (value) => value == null
//                                                 ? G.of(context).validator
//                                                 : null,
//                                             items: genderList
//                                                 .map<DropdownMenuItem<String>>(
//                                                     (String value) {
//                                               return DropdownMenuItem<String>(
//                                                 value: value,
//                                                 child: Text(value),
//                                               );
//                                             }).toList(),
//                                           ),
//                                           _space,
//                                           //date
//                                           BasicDateField(_dobController),
//                                           _space,
//                                           //bios
//                                           LoginTextField(
//                                             validator: (value) => value.isEmpty
//                                                 ? G.of(context).labelbios
//                                                 : null,
//                                             label: G.of(context).labelbios,
//                                             icon: FontAwesomeIcons.book,
//                                             controller: _biosController,
//                                             textInputAction:
//                                                 TextInputAction.next,
//                                             keyboardType: TextInputType.text,
//                                           ),
//                                           _space,
//                                           //address
//                                           LoginTextField(
//                                             validator: (value) => value.isEmpty
//                                                 ? G.of(context).labeladdress
//                                                 : null,
//                                             label: G.of(context).labeladdress,
//                                             icon: FontAwesomeIcons.addressBook,
//                                             controller: _addressController,
//                                             textInputAction:
//                                                 TextInputAction.next,
//                                             keyboardType: TextInputType.text,
//                                           ),
//                                           _space,
//                                           //NRC
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: <Widget>[
//                                               Expanded(
//                                                 child: InkResponse(
//                                                   onTap: () =>
//                                                       _pickNrcFromGallery(
//                                                           NrcType.front),
//                                                   child: Column(
//                                                     children: <Widget>[
//                                                       Container(
//                                                         height: 120,
//                                                         child: _nrcFront == null
//                                                             ? Icon(
//                                                                 FontAwesomeIcons
//                                                                     .addressCard,
//                                                                 size: 120,
//                                                                 color: Theme.of(
//                                                                         context)
//                                                                     .accentColor)
//                                                             : Image.file(
//                                                                 _nrcFront),
//                                                       ),
//                                                       SizedBox(height: 5),
//                                                       Text(
//                                                           G
//                                                               .of(context)
//                                                               .labelnrcfront,
//                                                           style:
//                                                               Theme.of(context)
//                                                                   .textTheme
//                                                                   .bodyText1),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: 10,
//                                               ),
//                                               Expanded(
//                                                 child: InkResponse(
//                                                   onTap: () =>
//                                                       _pickNrcFromGallery(
//                                                           NrcType.back),
//                                                   child: Column(
//                                                     children: <Widget>[
//                                                       Container(
//                                                         height: 120,
//                                                         child: _nrcBack == null
//                                                             ? Icon(
//                                                                 FontAwesomeIcons
//                                                                     .solidAddressCard,
//                                                                 size: 120,
//                                                                 color: Theme.of(
//                                                                         context)
//                                                                     .accentColor)
//                                                             : Image.file(
//                                                                 _nrcBack),
//                                                       ),
//                                                       SizedBox(height: 5),
//                                                       Text(
//                                                           G
//                                                               .of(context)
//                                                               .labelnrcback,
//                                                           style:
//                                                               Theme.of(context)
//                                                                   .textTheme
//                                                                   .bodyText1),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               )
//                                             ],
//                                           ),
//                                           _space,
//                                           RaisedButton(
//                                             child: finished
//                                                 ? ButtonProgressIndicator()
//                                                 : Text(
//                                                     G
//                                                         .of(context)
//                                                         .setPartnerButton,
//                                                     style: Theme.of(context)
//                                                         .accentTextTheme
//                                                         .button
//                                                         .copyWith(
//                                                             wordSpacing: 6)),
//                                             onPressed: () async {
//                                               if (_cover == null ||
//                                                   _profile == null) {
//                                                 showToast(G
//                                                     .of(context)
//                                                     .toastimagenull);
//                                                 return false;
//                                               } else if (_nrcFront == null ||
//                                                   _nrcBack == null) {
//                                                 showToast(
//                                                     G.of(context).toastnrcnull);
//                                                 return false;
//                                               } else if (_nrcController ==
//                                                       null ||
//                                                   _genderController == null ||
//                                                   _dobController == null ||
//                                                   _addressController == null) {
//                                                 showToast(G
//                                                     .of(context)
//                                                     .toastlackfield);
//                                                 return false;
//                                               } else {
//                                                 setState(() {
//                                                   finished = !finished;
//                                                 });
//                                                 var userid = StorageManager
//                                                     .sharedPreferences
//                                                     .getInt(mUserId);
//                                                 var coverPath =
//                                                     _cover.absolute.path;
//                                                 var profilePath =
//                                                     _profile.absolute.path;
//                                                 FormData formData =
//                                                     FormData.fromMap({
//                                                   'cover_image':
//                                                       await MultipartFile
//                                                           .fromFile(
//                                                     coverPath,
//                                                     filename: 'cover.jpg',
//                                                   ),
//                                                   'profile_image':
//                                                       await MultipartFile
//                                                           .fromFile(profilePath,
//                                                               filename:
//                                                                   'profile.jpg'),
//                                                   'nrc_front_image':
//                                                       await MultipartFile.fromFile(
//                                                           _nrcFront
//                                                               .absolute.path,
//                                                           filename:
//                                                               'nrc_front_image.jpg'),
//                                                   'nrc_back_image':
//                                                       await MultipartFile.fromFile(
//                                                           _nrcBack
//                                                               .absolute.path,
//                                                           filename:
//                                                               'nrc_back_image.jpg'),
//                                                   'nrc': _nrcController.text
//                                                       .toString(),
//                                                   //'mail': _mailController.text.toString(),
//                                                   'gender': _genderController
//                                                       .toString(),
//                                                   'dob': _dobController.text
//                                                       .toString(),
//                                                   //'phone': _phController.text.toString(),
//                                                   'bios': _biosController.text
//                                                       .toString(),
//                                                   'address': _addressController
//                                                       .text
//                                                       .toString()
//                                                 });

//                                                 var response = await DioUtils()
//                                                     .postwithData(
//                                                         Api.SetProfile +
//                                                             '$userid/profile',
//                                                         data: formData,
//                                                         options: Options(
//                                                           sendTimeout:
//                                                               25 * 1000,
//                                                           receiveTimeout:
//                                                               25 * 1000,
//                                                         ));
//                                                 print('PRINTED $response');
//                                                 print(
//                                                     "+++++++++++++++++++++++++++++++++++++");
//                                                 setState(() {
//                                                   finished = !finished;
//                                                 });
//                                                 print(
//                                                     "----------------------------------------------------");
//                                                 model.logout();
//                                                 Navigator.of(context)
//                                                     .pushNamedAndRemoveUntil(
//                                                         RouteName.splash,
//                                                         (route) => false);
//                                                 return User.fromJsonMap(
//                                                     response.data);
//                                               }
//                                             },
//                                           ),
//                                         ]),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                       )))
//         ],
//       ),
//     );
//   }
// }

// ///[Change Image.file (ImagePicker get File format)]
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

// // class SetProfileButton extends StatelessWidget {
// //   final cover;
// //   final profile;
// //   final phone;
// //   final mail;
// //   final address;
// //   final nrc;
// //   final gender;
// //   final dob;
// //   final bios;
// //   // final LoginModel model;
// //   // final cover;

// //   SetProfileButton(this.cover, this.profile, this.nrc, this.mail, this.gender,
// //       this.dob, this.phone, this.bios, this.address);
// //   @override
// //   Widget build(BuildContext context) {
// //     var model = Provider.of<LoginModel>(context);
// //     return LoginButtonWidget(
// //       //controller: _btnController,
// //       child: model.isBusy
// //           ? ButtonProgressIndicator()
// //           : Text(G.of(context).setPartnerButton,
// //               style: Theme.of(context)
// //                   .accentTextTheme
// //                   .button
// //                   .copyWith(wordSpacing: 6)),
// //       onPressed: () async {
// //         var userid = StorageManager.sharedPreferences.getInt(mUserId);
// //         var coverPath = cover.path;
// //         var profilePath = profile.path;
// //         FormData formData = FormData.fromMap({
// //           'cover_image':
// //               await MultipartFile.fromFile(coverPath, filename: 'cover.jpg'),
// //           'profile_image': await MultipartFile.fromFile(profilePath,
// //               filename: 'profile.jpg'),
// //           'nrc': nrc,
// //           'mail': mail,
// //           'gender': gender,
// //           'dob': dob,
// //           'phone': phone,
// //           'bios': bios,
// //           'address': address
// //         });
// //         var response = await DioUtils()
// //             .postwithData(Api.SetProfile + '$userid/profile', data: formData);
// //         print(response);
// //         model.logout();
// //         Navigator.of(context)
// //             .pushNamedAndRemoveUntil(RouteName.splash, (route) => false);
// //         return User.fromJsonMap(response.data);
// //       },
// //     );
// //   }
// // }

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/LoginFormContainer_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/models/user.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/partner_ownProfile_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:moonblink/global/router_manager.dart';

class UpdatePartnerProfilePage extends StatefulWidget {
  final PartnerUser partnerUser;
  UpdatePartnerProfilePage({Key key, @required this.partnerUser})
      : super(key: key);
  // final String cover;
  // final String profile;

  @override
  _UpdatePartnerProfilePageState createState() =>
      _UpdatePartnerProfilePageState();
}

class _UpdatePartnerProfilePageState extends State<UpdatePartnerProfilePage> {
  final _nameController = TextEditingController();
  final _biosController = TextEditingController();
  final _picker = ImagePicker();
  String _filePath;
  PartnerUser partnerData;
  @override
  void initState() {
    super.initState();
    _nameController.value = _nameController.value.copyWith(
      text: widget.partnerUser.partnerName,
    );
    _biosController.value = _biosController.value
        .copyWith(text: widget.partnerUser.prfoileFromPartner.bios);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _biosController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<PartnerOwnProfileModel>(
        model: PartnerOwnProfileModel(partnerData),
        onModelReady: (partnerModel) {
          partnerModel.initData();
        },
        builder: (context, partnermodel, child) {
          if (partnermodel.isBusy) {
            return ViewStateBusyWidget();
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).updatePartnerProfile),
            ),
            body: CustomScrollView(
              physics: ClampingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: ProviderWidget<LoginModel>(
                    model: LoginModel(Provider.of(context)),
                    builder: (context, model, child) => Form(
                        onWillPop: () async {
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
                                child: AspectRatio(
                                  aspectRatio: 100 / 60,
                                  child:
                                      PartnerCoverWidget(_cover, partnermodel),
                                )),

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
                                            child: PartnerProfileWidget(
                                                _profile, partnermodel),
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
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        //Name
                                        LoginTextField(
                                          validator: (value) => value.isEmpty
                                              ? 'Please enter your name'
                                              : null,
                                          label: "Please enter your Name",
                                          icon: Icons.person,
                                          controller: _nameController,
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.text,
                                        ),
                                        //bios
                                        LoginTextField(
                                          validator: (value) => value.isEmpty
                                              ? 'Please enter Bios'
                                              : null,
                                          label: "Please enter Bios",
                                          icon: FontAwesomeIcons.book,
                                          controller: _biosController,
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.text,
                                        ),
                                        // _space,
                                        FlatButton(
                                          child: Text("Update"),
                                          color: Theme.of(context).buttonColor,
                                          onPressed: () async {
                                            if (_cover == null ||
                                                _profile == null) {
                                              showToast(
                                                  'You need to choose cover and profile images');
                                              return false;
                                            }
                                            var userid = StorageManager
                                                .sharedPreferences
                                                .getInt(mUserId);
                                            var coverPath = _cover.path;
                                            var profilePath = _profile.path;
                                            FormData formData =
                                                FormData.fromMap({
                                              'cover_image':
                                                  await MultipartFile.fromFile(
                                                      coverPath,
                                                      filename: 'cover.jpg'),
                                              'profile_image':
                                                  await MultipartFile.fromFile(
                                                      profilePath,
                                                      filename: 'profile.jpg'),
                                              'name': _nameController.text,
                                              'bios': _biosController.text
                                                  .toString(),
                                            });
                                            var response = await DioUtils()
                                                .postwithData(
                                                    Api.SetProfile +
                                                        '$userid/profile',
                                                    data: formData);
                                            print(response);
                                            Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                                    RouteName.main,
                                                    (route) => false);
                                            return User.fromJsonMap(
                                                response.data);
                                          },
                                        )
                                        // UpdateProfileButton(
                                        //   cover: _cover,
                                        //   profile: _profile,
                                        //   bios: _biosController.text,
                                        // )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
                  ),
                )
              ],
            ),
          );
        });
  }
}

///[Change Image.file (ImagePicker get File format)]
class PartnerCoverWidget extends StatelessWidget {
  PartnerCoverWidget(this.cover, this.partnermodel);
  final cover;
  final partnermodel;
  @override
  Widget build(BuildContext context) {
    if (this.cover == null) {
      return Image.network(
        partnermodel.partnerData.prfoileFromPartner.coverImage,
        fit: BoxFit.cover,
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
  PartnerProfileWidget(this.profile, this.partnermodel);
  final profile;
  final partnermodel;
  @override
  Widget build(BuildContext context) {
    if (this.profile == null) {
      return Image.network(
        partnermodel.partnerData.prfoileFromPartner.profileImage,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        this.profile,
        fit: BoxFit.cover,
      );
    }
  }
}

// class UpdateProfileButton extends StatelessWidget {
//   final cover;
//   final profile;
//   final bios;
//   // final LoginModel model;
//   // final cover;

//   UpdateProfileButton({this.cover, this.profile, this.bios});
//   @override
//   Widget build(BuildContext context) {
//     var model = Provider.of<LoginModel>(context);
//     return LoginButtonWidget(
//       //controller: _btnController,
//       child: model.isBusy
//           ? ButtonProgressIndicator()
//           : Text(S.of(context).updatePartnerButton,
//               style: Theme.of(context)
//                   .accentTextTheme
//                   .button
//                   .copyWith(wordSpacing: 6)),
//       onPressed: model.isBusy
//           ? null
//           : () async {
//               var userid = StorageManager.sharedPreferences.getInt(mUserId);
//               var coverPath = cover.path;
//               var profilePath = profile.path;
//               FormData formData = FormData.fromMap({
//                 'cover_image': await MultipartFile.fromFile(coverPath,
//                     filename: 'cover.jpg'),
//                 'profile_image': await MultipartFile.fromFile(profilePath,
//                     filename: 'profile.jpg'),
//                 // 'nrc': nrc,
//                 // 'mail': mail,
//                 // 'gender': gender.toString(),
//                 // 'dob': dob,
//                 // 'phone': phone,
//                 'bios': bios.toString(),
//                 // 'address': address
//               });
//               var response = await DioUtils().postwithData(
//                   Api.SetProfile + '$userid/profile',
//                   data: formData);
//               print(response);
//               Navigator.of(context).pop();
//               return User.fromJsonMap(response.data);
//             },
//     );
//   }
// }

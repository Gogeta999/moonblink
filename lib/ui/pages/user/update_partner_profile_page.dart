import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/LoginFormContainer_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_button_widget.dart';
import 'package:moonblink/base_widget/sign_IO_widgets/login_field_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/user.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:provider/provider.dart';

class UpdatePartnerProfilePage extends StatefulWidget {
  // final String cover;
  // final String profile;

  // UpdatePartnerProfilePage ({this.cover, this.profile});
  @override
  _UpdatePartnerProfilePageState createState() =>
      _UpdatePartnerProfilePageState();
}

class _UpdatePartnerProfilePageState extends State<UpdatePartnerProfilePage> {
  final _biosController = TextEditingController();
  final _picker = ImagePicker();
  @override
  void dispose() {
    _biosController.dispose();
    super.dispose();
  }

  File _cover;
  File _profile;
  //pick Cover
  _pickCoverFromGallery() async {
    var cover = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      _cover = File(cover.path);
    });
  }

  //pick profile
  _pickprofileFromGallery() async {
    var profile = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      _profile = File(profile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                                      child: PartnerProfileWidget(_profile),
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
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
                                  UpdateProfileButton(
                                    cover: _cover,
                                    profile: _profile,
                                    bios: _biosController.text,
                                  )
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
        ImageHelper.wrapAssetsImage('images.jpg'),
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
  PartnerProfileWidget(this.profile);
  final profile;
  @override
  Widget build(BuildContext context) {
    if (this.profile == null) {
      return Image.asset(
        ImageHelper.wrapAssetsImage('images.jpg'),
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

class UpdateProfileButton extends StatelessWidget {
  final cover;
  final profile;
  final bios;
  // final LoginModel model;
  // final cover;

  UpdateProfileButton({this.cover, this.profile, this.bios});
  @override
  Widget build(BuildContext context) {
    var model = Provider.of<LoginModel>(context);
    return LoginButtonWidget(
      //controller: _btnController,
      child: model.isBusy
          ? ButtonProgressIndicator()
          : Text(S.of(context).updatePartnerButton,
              style: Theme.of(context)
                  .accentTextTheme
                  .button
                  .copyWith(wordSpacing: 6)),
      onPressed: model.isBusy
          ? null
          : () async {
              var userid = StorageManager.sharedPreferences.getInt(mUserId);
              var coverPath = cover.path;
              var profilePath = profile.path;
              FormData formData = FormData.fromMap({
                'cover_image': await MultipartFile.fromFile(coverPath,
                    filename: 'cover.jpg'),
                'profile_image': await MultipartFile.fromFile(profilePath,
                    filename: 'profile.jpg'),
                // 'nrc': nrc,
                // 'mail': mail,
                // 'gender': gender.toString(),
                // 'dob': dob,
                // 'phone': phone,
                'bios': bios.toString(),
                // 'address': address
              });
              var response = await DioUtils().postwithData(
                  Api.SetProfile + '$userid/profile',
                  data: formData);
              print(response);
              Navigator.of(context).pop();
              return User.fromJsonMap(response.data);
            },
    );
  }
}

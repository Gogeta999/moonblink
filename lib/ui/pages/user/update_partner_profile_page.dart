import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/photo_bottom_sheet.dart';
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
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:moonblink/global/router_manager.dart';

class UpdatePartnerProfilePage extends StatefulWidget {
  final PartnerUser partnerUser;
  UpdatePartnerProfilePage({Key key, @required this.partnerUser})
      : super(key: key);

  @override
  _UpdatePartnerProfilePageState createState() =>
      _UpdatePartnerProfilePageState();
}

class _UpdatePartnerProfilePageState extends State<UpdatePartnerProfilePage> {
  final _nameController = TextEditingController();
  final _biosController = TextEditingController();
  final _mlIdController = TextEditingController();
  final _pubgIdController = TextEditingController();
  PartnerUser partnerData;
  File _cover;
  File _profile;
  bool finish = false;

  //Get File from Cached
  Future getCachedFile() async {
    var cachedCoverFile = await DefaultCacheManager()
        .getFileFromCache(widget.partnerUser.prfoileFromPartner.coverImage);
    var cachedProfileFile = await DefaultCacheManager().getFileFromCache(
      widget.partnerUser.prfoileFromPartner.profileImage,
    );
    setState(() {
      _profile = cachedProfileFile.file;
      _cover = cachedCoverFile.file;
    });
  }

  @override
  void initState() {
    super.initState();
    getCachedFile();
    _nameController.value = _nameController.value.copyWith(
      text: widget.partnerUser.partnerName,
    );
    _biosController.value = _biosController.value
        .copyWith(text: widget.partnerUser.prfoileFromPartner.bios);
    _mlIdController.value =
        _mlIdController.value.copyWith(text: widget.partnerUser.mlplayerid);
    _pubgIdController.value =
        _pubgIdController.value.copyWith(text: widget.partnerUser.pubgplayerid);
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
              body:
                  CustomScrollView(physics: ClampingScrollPhysics(), slivers: <
                      Widget>[
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
                                CustomBottomSheet.show(
                                    requestType: RequestType.image,
                                    popAfterBtnPressed: true,
                                    buttonText: S.of(context).choose,
                                    buildContext: context,
                                    limit: 1,
                                    onPressed: (File file) {
                                      setState(() {
                                        _cover = file;
                                      });
                                    },
                                    body: S.of(context).partnercover);
                              },
                              child: AspectRatio(
                                aspectRatio: 100 / 60,
                                child: PartnerCoverWidget(
                                    _cover,
                                    partnermodel,
                                    widget.partnerUser.prfoileFromPartner
                                        .coverImage),
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
                                      CustomBottomSheet.show(

                                          ///profile is small
                                          popAfterBtnPressed: true,
                                          requestType: RequestType.image,
                                          minWidth: 480,
                                          minHeight: 480,
                                          buttonText: S.of(context).choose,
                                          buildContext: context,
                                          limit: 1,
                                          onPressed: (File file) {
                                            setState(() {
                                              _profile = file;
                                            });
                                          },
                                          body: S.of(context).partnerprofile);
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
                                              _profile,
                                              partnermodel,
                                              widget
                                                  .partnerUser
                                                  .prfoileFromPartner
                                                  .profileImage),
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
                                            ? S.of(context).labelname
                                            : null,
                                        label: S.of(context).labelname,
                                        icon: Icons.person,
                                        controller: _nameController,
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.text,
                                      ),
                                      //bios
                                      LoginTextField(
                                        label: S.of(context).labelbios,
                                        icon: FontAwesomeIcons.book,
                                        controller: _biosController,
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.text,
                                      ),
                                      //ML id
                                      LoginTextField(
                                        label: S.of(context).labelmlid,
                                        icon: FontAwesomeIcons.gamepad,
                                        controller: _mlIdController,
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.number,
                                      ),
                                      //bios
                                      LoginTextField(
                                        label: S.of(context).labelpubgid,
                                        icon: FontAwesomeIcons.gamepad,
                                        controller: _pubgIdController,
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.number,
                                      ),
                                      // _space,
                                      FlatButton(
                                        child: finish
                                            ? ButtonProgressIndicator()
                                            : Text(S
                                                .of(context)
                                                .updatePartnerButton),
                                        color: Theme.of(context).buttonColor,
                                        onPressed: () async {
                                          if (_cover == null ||
                                              _profile == null) {
                                            showToast(
                                                S.of(context).toastimagenull);
                                            return false;
                                          }
                                          setState(() {
                                            finish = !finish;
                                          });
                                          var userid = StorageManager
                                              .sharedPreferences
                                              .getInt(mUserId);
                                          var coverPath = _cover.path;
                                          var profilePath = _profile.path;
                                          FormData formData = FormData.fromMap({
                                            'cover_image':
                                                await MultipartFile.fromFile(
                                                    coverPath,
                                                    filename: 'cover.jpg'),
                                            'profile_image':
                                                await MultipartFile.fromFile(
                                                    profilePath,
                                                    filename: 'profile.jpg'),
                                            'name': _nameController.text,
                                            'bios':
                                                _biosController.text.toString(),
                                            'ml_player_id':
                                                _mlIdController.text.toString(),
                                            'pubg_player_id': _pubgIdController
                                                .text
                                                .toString()
                                          });
                                          var response = await DioUtils()
                                              .postwithData(
                                                  Api.SetProfile +
                                                      '$userid/profile',
                                                  data: formData);
                                          print(response);
                                          setState(() {
                                            finish = !finish;
                                          });
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
                ))
              ]));
        });
  }
}

///[Change Image.file (ImagePicker get File format)]
class PartnerCoverWidget extends StatelessWidget {
  PartnerCoverWidget(this.cover, this.partnermodel, this.coverFile);
  final cover;
  final partnermodel;
  final coverFile;

  @override
  Widget build(BuildContext context) {
    if (this.cover == null) {
      // return Image.network(
      //   partnermodel.partnerData.prfoileFromPartner.coverImage,
      //   fit: BoxFit.cover,
      // );
      return Image.file(
        coverFile,
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
  PartnerProfileWidget(this.profile, this.partnermodel, this.profileFile);
  final profile;
  final partnermodel;
  final profileFile;
  @override
  Widget build(BuildContext context) {
    if (this.profile == null) {
      // return Image.network(
      //   partnermodel.partnerData.prfoileFromPartner.profileImage,
      //   fit: BoxFit.cover,
      // );
      return Image.file(
        profileFile,
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

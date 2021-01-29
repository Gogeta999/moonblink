import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/base_widget/nfpost_player.dart';
import 'package:moonblink/base_widget/videotrimmer/trimmer_view.dart';
import 'package:moonblink/base_widget/vip_renew_dialog.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/vip_data.dart';
import 'package:moonblink/services/ad_manager.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/compress_utils.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/utils/crop_utils.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/subjects.dart';
import 'package:video_trimmer/video_trimmer.dart';

///Emulators are always treated as test devices
const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['game', 'entertainment'],
  nonPersonalizedAds: true,
);

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _followerOptions = ['Public', 'Followers'];
  final _postTitleController = TextEditingController();
  final int myId = StorageManager.sharedPreferences.getInt(mUserId);
  final String myEmail = StorageManager.sharedPreferences.getString(mLoginMail);
  final maxImageLimit = 8;
  final maxVideoLimit = 1;
  final String public = 'Public';
  final String followers = 'Followers';
  final maxNameLength = 15;

  final _postOptionsSubject = BehaviorSubject.seeded('Public');
  final _mediaSubject = BehaviorSubject<List<File>>.seeded(null);
  final _videoSubject = BehaviorSubject<File>.seeded(null);
  //final _thumbnailSubject = BehaviorSubject<Uint8List>.seeded(null);
  final _adCountSubject = BehaviorSubject<int>.seeded(0);
  final _postByAdButtonSubject = BehaviorSubject.seeded(false);
  final _postByCoinsButtonSubject = BehaviorSubject.seeded(false);
  final _postByFreeButtonSubject = BehaviorSubject.seeded(false);
  final _startWatchingButtonSubject = BehaviorSubject.seeded(false);
  final _selectedPhotoIndexSubject = BehaviorSubject<int>.seeded(-1);
  final _vipDataSubject = BehaviorSubject<VipData>.seeded(null);
  bool _uploading = false;

  @override
  void initState() {
    MoonBlinkRepository.getUserVip().then((value) {
      _vipDataSubject.add(value);
      if (value.vip == 0 && value.vipRenew == 1) {
        showCupertinoDialog(
            context: context, builder: (context) => VipRenewDialog());
      }
    }, onError: (e) {
      print(e.toString());
    });
    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event,
        {String rewardType, int rewardAmount}) async {
      if (isDev) print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.rewarded) {
        this._adCountSubject.first.then((value) {
          this._adCountSubject.add(value + 1);
          StorageManager.sharedPreferences.setInt('$myId$myEmail', value + 1);
        });
        this._postByAdButtonSubject.add(false);
        this._startWatchingButtonSubject.add(false);
      }
      if (event == RewardedVideoAdEvent.loaded) {
        RewardedVideoAd.instance.show();
      }
      if (event == RewardedVideoAdEvent.failedToLoad) {
        showToast('Failed to load Ad');
        this._postByAdButtonSubject.add(false);
        this._startWatchingButtonSubject.add(false);
      }
      if (event == RewardedVideoAdEvent.closed) {
        this._postByAdButtonSubject.add(false);
        this._startWatchingButtonSubject.add(false);
      }
      if (event == RewardedVideoAdEvent.leftApplication) {
        this._postByAdButtonSubject.add(false);
        this._startWatchingButtonSubject.add(false);
      }
      if (event == RewardedVideoAdEvent.completed) {
        this._postByAdButtonSubject.add(false);
        this._startWatchingButtonSubject.add(false);
      }
    };
    final int myAdCount =
        StorageManager.sharedPreferences.getInt('$myId$myEmail') ?? null;
    if (myAdCount == null) {
      StorageManager.sharedPreferences.setInt('$myId$myEmail', 0);
      this._adCountSubject.add(0);
    } else {
      this._adCountSubject.add(myAdCount);
    }
    super.initState();
  }

  @override
  void dispose() {
    _postOptionsSubject.close();
    _mediaSubject.close();
    _videoSubject.close();
    //_thumbnailSubject.close();
    _adCountSubject.close();
    _postByAdButtonSubject.close();
    _postByCoinsButtonSubject.close();
    _postByFreeButtonSubject.close();
    _startWatchingButtonSubject.close();
    _selectedPhotoIndexSubject.close();
    _vipDataSubject.close();
    RewardedVideoAd.instance.listener = null;
    super.dispose();
  }

  _showSelectImageOptions() {
    return showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (builder) => CupertinoAlertDialog(
        content: Text(G.of(context).pickimage),
        actions: <Widget>[
          ///Gallery
          CupertinoButton(
              child: Text(G.of(context).imagePickerGallery),
              onPressed: () {
                CustomBottomSheet.show(
                    buildContext: context,
                    limit: maxImageLimit,
                    body: 'Max - $maxImageLimit',
                    onPressed: (List<File> files) async {
                      List<File> currentFile = await this._mediaSubject.first;
                      if (currentFile == null || currentFile.isEmpty) {
                        currentFile = List.from(files);
                      } else {
                        currentFile.addAll(files);
                      }
                      if (currentFile.length > maxImageLimit) {
                        int x = currentFile.length - maxImageLimit;
                        currentFile.removeRange(0, x);
                      }
                      this._videoSubject.add(null);
                      this._mediaSubject.add(currentFile);
                      this._selectedPhotoIndexSubject.add(-1);
                    },
                    buttonText: G.of(context).select,
                    popAfterBtnPressed: true,
                    requestType: RequestType.image,
                    willCrop: false,
                    compressQuality: NORMAL_COMPRESS_QUALITY);
                Navigator.pop(context);
              }),

          ///Camera
          CupertinoButton(
              child: Text(G.of(context).imagePickerCamera),
              onPressed: () async {
                Navigator.pop(context);
                PickedFile pickedFile =
                    await ImagePicker().getImage(source: ImageSource.camera);
                File compressedImage = await CompressUtils.compressAndGetFile(
                    File(pickedFile.path), NORMAL_COMPRESS_QUALITY, 1080, 1080);
                List<File> currentFile = await this._mediaSubject.first;
                if (currentFile == null || currentFile.isEmpty) {
                  currentFile = List.from([compressedImage]);
                } else {
                  currentFile.add(compressedImage);
                }
                if (currentFile.length > maxImageLimit) {
                  int x = currentFile.length - maxImageLimit;
                  currentFile.removeRange(0, x);
                }
                this._videoSubject.add(null);
                this._mediaSubject.add(currentFile);
                this._selectedPhotoIndexSubject.add(-1);
              }),
          CupertinoButton(
            child: Text(G.of(context).cancel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  _showSelectVideoOptions() async {
    final vipLevel = await _vipDataSubject.first;
    if (vipLevel == null) return;
    return showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (builder) => CupertinoAlertDialog(
        content: Text(G.current.feedCreatePagePickVideoFrom),
        actions: <Widget>[
          ///Gallery
          CupertinoButton(
              child: Text(G.of(context).imagePickerGallery),
              onPressed: () {
                CustomBottomSheet.show(
                    buildContext: context,
                    limit: maxVideoLimit,
                    body: 'Max - $maxVideoLimit',
                    onPressed: (File video) async {
                      this._selectedPhotoIndexSubject.add(-1);
                      this._mediaSubject.add(null);
                      this._videoSubject.add(null);
                      await Future.delayed(Duration(milliseconds: 500));
                      this._videoSubject.add(video);
                    },
                    buttonText: G.of(context).select,
                    popAfterBtnPressed: true,
                    requestType: RequestType.video,
                    willCrop: false,
                    vipLevel: vipLevel.vip,
                    compressQuality: NORMAL_COMPRESS_QUALITY);
                Navigator.pop(context);
              }),

          ///Camera
          CupertinoButton(
              child: Text(G.of(context).imagePickerCamera),
              onPressed: () async {
                Navigator.pop(context);
                PickedFile pickedFile =
                    await ImagePicker().getVideo(source: ImageSource.camera);
                final _trimmer = Trimmer();
                File video = File(pickedFile.path);
                if (video != null) {
                  await _trimmer.loadVideo(videoFile: video);
                  File trimmedVideo = await Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return TrimmerView(_trimmer, vipLevel.vip);
                  }));
                  // Uint8List thumbnail = await VideoCompress.getByteThumbnail(
                  //     trimmedVideo.path,
                  //     position: 1);
                  if (trimmedVideo != null) {
                    this._selectedPhotoIndexSubject.add(-1);
                    this._mediaSubject.add(null);
                    this._videoSubject.add(null);
                    await Future.delayed(Duration(milliseconds: 500));
                    this._videoSubject.add(trimmedVideo);
                  }
                }
              }),
          CupertinoButton(
            child: Text(G.of(context).cancel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  _postByFree() async {
    if (_uploading) return;
    String body = this._postTitleController.text.trim();
    List<File> media = await this._mediaSubject.first;
    File video = await this._videoSubject.first;
    int type = 1;
    int status = _getStatus(await this._postOptionsSubject.first);
    final vip = await this._vipDataSubject.first;
    if (status == 0 && vip.publicPost <= 0) {
      showToast(G.current.feedCreatePageNoToastForFreePublic);
      return;
    }
    if (status == 1 && vip.onlyFollowerPost <= 0) {
      showToast(G.current.feedCreatePageNoToastForFreeFollower);
      return;
    }
    if ((media == null || media.isEmpty) && video == null) {
      showToast(G.current.feedCreatePagePickRequired);
      return;
    }
    this._postByFreeButtonSubject.add(true);
    _uploading = true;
    MoonBlinkRepository.uploadPost(media, video, type, status, 0,
            body: body ?? '')
        .then((_) {
      showToast(G.current.toastsuccess);
      _uploading = false;
      try {
        Navigator.pop(context);
      } catch (e) {
        if (isDev) print(e.toString());
      }
      this._postByFreeButtonSubject?.add(false);
    },
            onError: (e) => {
                  showToast(e.toString()),
                  print(e.toString()),
                  _uploading = false,
                  this._postByFreeButtonSubject?.add(false)
                });
  }

  _postByAd() async {
    if (_uploading) return;
    int myAdCount = await this._adCountSubject.first;
    int leftAd = 10 - myAdCount;
    if (myAdCount >= 10) {
      String body = this._postTitleController.text.trim();
      List<File> media = await this._mediaSubject.first;
      File video = await this._videoSubject.first;
      int type = 1;
      int status = _getStatus(await this._postOptionsSubject.first);
      if ((media == null || media.isEmpty) && video == null) {
        showToast(G.current.feedCreatePagePickRequired);
        return;
      }
      this._postByAdButtonSubject.add(true);
      _uploading = true;
      MoonBlinkRepository.uploadPost(media, video, type, status, 1,
              body: body ?? '')
          .then((_) {
        showToast(G.current.toastsuccess);
        myAdCount -= 10;
        this._adCountSubject?.add(myAdCount);
        StorageManager.sharedPreferences.setInt('$myId$myEmail', myAdCount);
        _uploading = false;
        try {
          Navigator.pop(context);
        } catch (e) {
          if (isDev) print(e.toSting());
        }
        this._postByAdButtonSubject?.add(false);
      },
              onError: (e) => {
                    showToast(e.toString()),
                    _uploading = false,
                    this._postByAdButtonSubject?.add(false)
                  });
    } else {
      showCupertinoDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(G.current.feedCreatePagePostByAds),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(G.current.feedCreatePagePostUNeed +
                    ' $leftAd ' +
                    G.current.feedCreatePagePostMoreAds),
              ),
              actions: [
                StreamBuilder<bool>(
                    initialData: false,
                    stream: this._postByAdButtonSubject,
                    builder: (context, snapshot) {
                      if (snapshot.data) {
                        return CupertinoButton(
                          child: CupertinoActivityIndicator(),
                          onPressed: () {},
                        );
                      }
                      return CupertinoButton(
                        child: Text(G.current.feedCreatePagePostStartWatching),
                        onPressed: () async {
                          if (_uploading) return;
                          this._postByAdButtonSubject.add(true);
                          this._startWatchingButtonSubject.add(true);
                          await RewardedVideoAd.instance.load(
                              adUnitId: AdManager.rewardedAdId,
                              targetingInfo: targetingInfo);
                          Navigator.pop(context);
                        },
                      );
                    })
              ],
            );
          });
    }
  }

  _postByCoins() async {
    if (_uploading) return;
    showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (dialogContext) {
          return StreamBuilder<VipData>(
              initialData: null,
              stream: this._vipDataSubject,
              builder: (_, snapshot) {
                if (snapshot.data == null) {
                  return Text("Service Unavailable");
                }
                return CupertinoAlertDialog(
                  title: Text(
                      'Cost per post - ${snapshot.data.costPerPost} coins'),
                  content: Container(
                      margin: const EdgeInsets.all(8.0),
                      child: Text(
                          'You have ${snapshot.data.walletValue} ${snapshot.data.walletValue > 1 ? "coins" : "coin"} for now.')),
                  actions: [
                    CupertinoButton(
                      child: Text(G.current.cancel),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                    ),
                    CupertinoButton(
                      child: Text('Post Now'),
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        String body = this._postTitleController.text.trim();
                        List<File> media = await this._mediaSubject.first;
                        File video = await this._videoSubject.first;
                        int type = 1;
                        int status =
                            _getStatus(await this._postOptionsSubject.first);
                        if ((media == null || media.isEmpty) && video == null) {
                          showToast(G.current.feedCreatePagePickRequired);
                          return;
                        }
                        this._postByCoinsButtonSubject.add(true);
                        _uploading = true;
                        MoonBlinkRepository.uploadPost(
                                media, video, type, status, 0,
                                body: body ?? '')
                            .then((_) {
                          showToast(G.current.toastsuccess);
                          _uploading = false;
                          try {
                            Navigator.pop(context);
                          } catch (e) {
                            if (isDev) print(e.toString());
                          }
                          this._postByCoinsButtonSubject?.add(false);
                        },
                                onError: (e) => {
                                      showToast(e.toString()),
                                      _uploading = false,
                                      this._postByCoinsButtonSubject?.add(false)
                                    });
                      },
                    )
                  ],
                );
              });
        });
  }

  int _getStatus(String option) {
    switch (option) {
      case 'Public':
        return 0;
      case 'Followers':
        return 1;
    }
    return -1;
  }

  Widget get _showIndicator => CupertinoButton.filled(
      padding: EdgeInsets.zero,
      child: CupertinoActivityIndicator(),
      onPressed: () {});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppbarWidget(
          title: Text(G.current.feedCreatePagePost),
        ),
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 15),
                          child: StorageManager.sharedPreferences
                                      .getString(mUserProfile) ==
                                  null
                              ? Icon(Icons.error)
                              : CachedNetworkImage(
                                  imageUrl: StorageManager.sharedPreferences
                                      .getString(mUserProfile),
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                          radius: 26,
                                          backgroundImage: imageProvider),
                                  placeholder: (context, url) =>
                                      CupertinoActivityIndicator(),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            () {
                              String name = StorageManager.sharedPreferences
                                  .getString(mLoginName);
                              if (name.length > maxNameLength) {
                                return Text(
                                    name.substring(0, maxNameLength) + '...');
                              } else {
                                return Text(name);
                              }
                            }(),
                            StreamBuilder<String>(
                                initialData: null,
                                stream: this._postOptionsSubject,
                                builder: (context, snapshot) {
                                  if (snapshot.data == null) {
                                    return Container();
                                  }
                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: snapshot.data,
                                      icon: Icon(Icons.expand_more,
                                          color: Theme.of(context).accentColor),
                                      onChanged: (String value) {
                                        this._postOptionsSubject.add(value);
                                      },
                                      dropdownColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      selectedItemBuilder: (context) {
                                        return this
                                            ._followerOptions
                                            .map<Widget>((String item) {
                                          return Center(child: Text(item));
                                        }).toList();
                                      },
                                      items: this
                                          ._followerOptions
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        ///Ad Count
                        // StreamBuilder<int>(
                        //   initialData: null,
                        //   stream: this._adCountSubject,
                        //   builder: (context, snapshot) {
                        //     int data = snapshot.data ?? 0;
                        //     return Text(
                        //         '$data ${data > 1 ? "Ads" : "Ad"} Watched');
                        //   },
                        // ),
                        // SizedBox(height: 5),
                        StreamBuilder<VipData>(
                            initialData: null,
                            stream: this._vipDataSubject,
                            builder: (context, snapshot) {
                              if (snapshot.data == null) return Container();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(G.current.feedCreatePageFreePublicPost +
                                      ' ${snapshot.data.publicPost} ' +
                                      G.current.feedCreatePageFreeLeft),
                                  Text(G.current
                                          .feedCreatePageFreeFollowerPost +
                                      ' ${snapshot.data.onlyFollowerPost} ' +
                                      G.current.feedCreatePageFreeLeft)
                                ],
                              );
                            })
                        // GestureDetector(
                        //     onTap: () async {
                        //       this._startWatchingButtonSubject.add(true);
                        //       await RewardedVideoAd.instance.load(
                        //           adUnitId: AdManager.rewardedAdId,
                        //           targetingInfo: targetingInfo);
                        //     },
                        //     child: StreamBuilder<bool>(
                        //         initialData: false,
                        //         stream: this._startWatchingButtonSubject,
                        //         builder: (context, snapshot) {
                        //           if (snapshot.data)
                        //             return CupertinoActivityIndicator();
                        //           return Text('Start Watching',
                        //               style: TextStyle(
                        //                   color:
                        //                       Theme.of(context).accentColor));
                        //         })),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 5),
                Container(
                  alignment: Alignment.centerLeft,
                  child: StreamBuilder<String>(
                    initialData: null,
                    stream: this._postOptionsSubject,
                    builder: (context, snapshot1) {
                      if (snapshot1.data == null) {
                        return Container();
                      }
                      return StreamBuilder<VipData>(
                        initialData: null,
                        stream: this._vipDataSubject,
                        builder: (context, snapshot2) {
                          if (snapshot2.data == null) {
                            return Container();
                          }
                          if (snapshot1.data == 'Public') {
                            return Text(G.current.feedCreatePageAllWillSee);
                          }
                          return Text('${snapshot2.data.followerCount} ' +
                              G.current.feedCreatePageFollowersWillSee);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                CupertinoTextField(
                  minLines: 2,
                  maxLines: 3,
                  placeholder: G.current.feedCreatePageWriteTitle,
                  controller: this._postTitleController,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).accentColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clearButtonMode: OverlayVisibilityMode.editing,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Text(G.current.feedCreatePageAddPhotos),
                            onPressed: () {
                              _showSelectImageOptions();
                            }),
                        StreamBuilder<VipData>(
                          initialData: null,
                          stream: this._vipDataSubject,
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return Container();
                            }
                            if (snapshot.data.vip <= 1) {
                              return Container();
                            }
                            return Row(
                              children: [
                                SizedBox(width: 10),
                                CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child:
                                        Text(G.current.feedCreatePageAddVideo),
                                    onPressed: () {
                                      _showSelectVideoOptions();
                                    }),
                              ],
                            );
                          },
                        )
                      ],
                    ),
                    StreamBuilder<File>(
                      initialData: null,
                      stream: this._videoSubject,
                      builder: (context, videoSnapshot) {
                        return StreamBuilder<List<File>>(
                            initialData: null,
                            stream: this._mediaSubject,
                            builder: (context, mediaSnapshot) {
                              if ((mediaSnapshot.data == null ||
                                      mediaSnapshot.data.isEmpty) &&
                                  videoSnapshot.data == null) {
                                return Container();
                              }
                              if (videoSnapshot.hasData) {
                                return CupertinoButton(
                                    child: Text(
                                        G.current.feedCreatePageRemoveVideo),
                                    onPressed: () {
                                      this._videoSubject.add(null);
                                    });
                              }
                              if (mediaSnapshot.hasData &&
                                  mediaSnapshot.data.isNotEmpty) {
                                return StreamBuilder<int>(
                                  initialData: -1,
                                  stream: this._selectedPhotoIndexSubject,
                                  builder: (context, selectedSnapshot) {
                                    if (selectedSnapshot.data == null ||
                                        selectedSnapshot.data == -1) {
                                      return CupertinoButton(
                                        child: Text(G.current
                                            .feedCreatePageRemoveAllPhotos),
                                        onPressed: () {
                                          this._mediaSubject.add([]);
                                        },
                                      );
                                    }
                                    return Row(
                                      children: [
                                        CupertinoButton(
                                          child: Text(
                                              G.current.feedCreatePageCrop),
                                          onPressed: () {
                                            this
                                                ._mediaSubject
                                                .first
                                                .then((photos) async {
                                              final beforeCrop =
                                                  photos[selectedSnapshot.data];
                                              final afterCrop =
                                                  await CropUtils.cropImage(
                                                      beforeCrop);
                                              photos[selectedSnapshot.data] =
                                                  afterCrop ?? beforeCrop;
                                              this._mediaSubject.add(photos);
                                            });
                                          },
                                        ),
                                        CupertinoButton(
                                          child: Text(
                                              G.current.feedCreatePageRemove),
                                          onPressed: () {
                                            this
                                                ._mediaSubject
                                                .first
                                                .then((photos) {
                                              photos.removeAt(
                                                  selectedSnapshot.data);
                                              this
                                                  ._selectedPhotoIndexSubject
                                                  .add(-1);
                                              this._mediaSubject.add(photos);
                                            });
                                          },
                                        )
                                      ],
                                    );
                                  },
                                );
                              }
                              return Container();
                            });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<List<File>>(
                        initialData: null,
                        stream: this._mediaSubject,
                        builder: (context, snapshot) {
                          if (snapshot.data == null || snapshot.data.isEmpty) {
                            return Container();
                          }
                          return Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: snapshot.data.length >= 3
                                          ? 3
                                          : snapshot.data.length),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return StreamBuilder<int>(
                                    initialData: -1,
                                    stream: this._selectedPhotoIndexSubject,
                                    builder: (context, snapshot2) {
                                      int selectedIndex = snapshot2.data;
                                      return GestureDetector(
                                          onTap: () {
                                            this
                                                ._selectedPhotoIndexSubject
                                                .first
                                                .then((value) {
                                              this
                                                  ._selectedPhotoIndexSubject
                                                  .add(value == index
                                                      ? -1
                                                      : index);
                                            });
                                          },
                                          child: Image.file(
                                            snapshot.data[index],
                                            width: double.infinity,
                                            height: double.infinity,
                                            color: index == selectedIndex
                                                ? Colors.white54
                                                : Colors.transparent,
                                            colorBlendMode: BlendMode.lighten,
                                            fit: BoxFit.cover,
                                          ));
                                    });
                              },
                            ),
                          );
                        },
                      ),
                      StreamBuilder<File>(
                        initialData: null,
                        stream: this._videoSubject,
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Container();
                          }
                          return Expanded(
                            child: LocalPlayer(file: snapshot.data),
                          );
                        },
                      ),
                      // StreamBuilder<Uint8List>(
                      //   initialData: null,
                      //   stream: this._thumbnailSubject,
                      //   builder: (context, snapshot) {
                      //     if (snapshot.data == null) {
                      //       return Container();
                      //     }
                      //     return Expanded(
                      //       child: CupertinoButton(
                      //         padding: EdgeInsets.zero,
                      //         onPressed: () async {
                      //           final file = await this._videoSubject.first;
                      //           Navigator.push(
                      //               context,
                      //               CupertinoPageRoute(
                      //                   builder: (context) =>
                      //                       Preview(file.path)));
                      //         },
                      //         child: Image.memory(
                      //           snapshot.data,
                      //           width: double.infinity,
                      //           height: double.infinity,
                      //           cacheHeight:
                      //               (MediaQuery.of(context).size.height * 0.3)
                      //                   .toInt(),
                      //           cacheWidth:
                      //               (MediaQuery.of(context).size.width * 0.3)
                      //                   .toInt(),
                      //           fit: BoxFit.cover,
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     CupertinoButton(
                //         padding: EdgeInsets.zero,
                //         child: Text('Add a Video'),
                //         onPressed: () {
                //           _showSelectVideoOptions();
                //         }),
                //     StreamBuilder<File>(
                //         stream: this._videoSubject,
                //         builder: (context, snapshot) {
                //           if (snapshot.data == null) {
                //             return Container();
                //           }
                //           return CupertinoButton(
                //               child: Text('Remove video'),
                //               onPressed: () {
                //                 this._videoSubject.add(null);
                //                 this._thumbnailSubject.add(null);
                //               });
                //         }),
                //   ],
                // ),
                SizedBox(height: 10),
                StreamBuilder<VipData>(
                    initialData: null,
                    stream: this._vipDataSubject,
                    builder: (context, vipSnapshot) {
                      if (vipSnapshot.data == null) {
                        return Row(
                          children: [
                            Expanded(child: _showIndicator),
                          ],
                        );
                      }
                      if (vipSnapshot.data.postUpload == 1) {
                        return Row(
                          children: [
                            ///Post by watching ads button
                            // Expanded(
                            //     child: Padding(
                            //   padding: EdgeInsets.only(bottom: 5),
                            //   child: StreamBuilder<bool>(
                            //       initialData: false,
                            //       stream: this._postByAdButtonSubject,
                            //       builder: (context, snapshot) {
                            //         if (snapshot.data) {
                            //           return _showIndicator;
                            //         }
                            //         return CupertinoButton.filled(
                            //             padding: EdgeInsets.zero,
                            //             child: Text(
                            //               G.current.feedCreatePagePostByAds,
                            //               style: Theme.of(context)
                            //                   .textTheme
                            //                   .button,
                            //             ),
                            //             onPressed: () => this._postByAd());
                            //       }),
                            // )),
                            // SizedBox(width: 5),
                            Expanded(
                              child: StreamBuilder<String>(
                                initialData: null,
                                stream: this._postOptionsSubject,
                                builder: (context, optionsSnapshot) {
                                  if (optionsSnapshot.data == null ||
                                      optionsSnapshot.data.isEmpty) {
                                    return _showIndicator;
                                  }
                                  if (optionsSnapshot.data == public &&
                                      vipSnapshot.data.publicPost > 0) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 5),
                                      child: StreamBuilder<bool>(
                                          initialData: false,
                                          stream: this._postByFreeButtonSubject,
                                          builder: (context, snapshot) {
                                            if (snapshot.data) {
                                              return _showIndicator;
                                            }
                                            return CupertinoButton.filled(
                                                padding: EdgeInsets.zero,
                                                child: Text(
                                                  G.current
                                                      .feedCreatePageFreeToPost,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .button,
                                                ),
                                                onPressed: () {
                                                  this._postByFree();
                                                });
                                          }),
                                    );
                                  }
                                  if (optionsSnapshot.data == followers &&
                                      vipSnapshot.data.onlyFollowerPost > 0) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 5),
                                      child: StreamBuilder<bool>(
                                          initialData: false,
                                          stream: this._postByFreeButtonSubject,
                                          builder: (context, snapshot) {
                                            if (snapshot.data) {
                                              return _showIndicator;
                                            }
                                            return CupertinoButton.filled(
                                                padding: EdgeInsets.zero,
                                                child: Text(
                                                  G.current
                                                      .feedCreatePageFreeToPost,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .button,
                                                ),
                                                onPressed: () {
                                                  this._postByFree();
                                                });
                                          }),
                                    );
                                  }
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: StreamBuilder<bool>(
                                        initialData: false,
                                        stream: this._postByCoinsButtonSubject,
                                        builder: (context, snapshot) {
                                          if (snapshot.data) {
                                            return _showIndicator;
                                          }
                                          return CupertinoButton.filled(
                                              padding: EdgeInsets.zero,
                                              child: Text(
                                                G.current
                                                    .feedCreatePagePostByCoins,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .button,
                                              ),
                                              onPressed: () =>
                                                  this._postByCoins());
                                        }),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                      return CupertinoButton.filled(
                          child: Text(
                            G.current.feedCreatePageCantPostNow,
                            style: Theme.of(context).textTheme.button,
                          ),
                          disabledColor: Colors.redAccent[700],
                          onPressed: null);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

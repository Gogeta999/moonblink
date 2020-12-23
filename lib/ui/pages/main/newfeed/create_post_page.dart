import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/services/ad_manager.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/compress_utils.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/subjects.dart';

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
  final _followerOptions = ['Private', 'Public', 'Followers'];
  final _postTitleController = TextEditingController();
  final int myId = StorageManager.sharedPreferences.getInt(mUserId);
  final String myEmail = StorageManager.sharedPreferences.getString(mLoginMail);

  // ignore: close_sinks
  final _postOptionsSubject = BehaviorSubject.seeded('Public');
  final _photosSubject = BehaviorSubject<List<File>>.seeded(null);
  final _adCountSubject = BehaviorSubject<int>.seeded(0);
  final _postByAdButtonSubject = BehaviorSubject.seeded(false);
  final _postByCoinsButtonSubject = BehaviorSubject.seeded(false);
  final _startWatchingButtonSubject = BehaviorSubject.seeded(false);
  final _selectedPhotoIndexSubject = BehaviorSubject<int>.seeded(-1);

  @override
  void initState() {
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
    this._postOptionsSubject.close();
    this._photosSubject.close();
    this._adCountSubject.close();
    this._postByAdButtonSubject.close();
    this._postByCoinsButtonSubject.close();
    this._startWatchingButtonSubject.close();
    this._selectedPhotoIndexSubject.close();
    RewardedVideoAd.instance.listener = null;
    super.dispose();
  }

  _showSelectImageOptions() {
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
                    limit: 3,
                    body: G.of(context).picknrc,
                    onPressed: (List<File> files) {
                      this._photosSubject.add(files);
                      this._selectedPhotoIndexSubject.add(-1);
                    },
                    buttonText: G.of(context).select,
                    popAfterBtnPressed: true,
                    requestType: RequestType.image,
                    minWidth: 600,
                    minHeight: 800,
                    willCrop: true,
                    compressQuality: NORMAL_COMPRESS_QUALITY);
                Navigator.pop(context);
              }),
          CupertinoButton(
              child: Text(G.of(context).imagePickerCamera),
              onPressed: () async {
                PickedFile pickedFile =
                    await ImagePicker().getImage(source: ImageSource.camera);
                this._photosSubject.add([
                  await CompressUtils.compressAndGetFile(
                      File(pickedFile.path), NORMAL_COMPRESS_QUALITY, 600, 800)
                ]);
                this._selectedPhotoIndexSubject.add(-1);
                Navigator.pop(context);
              }),
          CupertinoButton(
            child: Text(G.of(context).cancel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  _postByAd() async {
    int myAdCount = await this._adCountSubject.first;
    int leftAd = 10 - myAdCount;
    if (myAdCount >= 10) {
      String body = this._postTitleController.text.trim();
      List<File> media = await this._photosSubject.first;
      int type = 1;
      int status = _getStatus(await this._postOptionsSubject.first);
      if (body.isEmpty && media == null) {
        showToast('Require title or photo');
        return;
      }
      this._postByAdButtonSubject.add(true);
      MoonBlinkRepository.uploadPost(media.first, type, status,
              body: body ?? '')
          .then((_) {
        showToast('Upload Success');
        myAdCount -= 10;
        this._adCountSubject.add(myAdCount);
        StorageManager.sharedPreferences.setInt('$myId$myEmail', myAdCount);
        Navigator.pop(context);
        this._postByAdButtonSubject.add(false);
      },
              onError: (e) => {
                    showToast(e.toString()),
                    this._postByAdButtonSubject.add(false)
                  });
    } else {
      showCupertinoDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Post by watching Ads'),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('You need $leftAd more Ads need to watch.'),
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
                        child: Text('Start Watching'),
                        onPressed: () async {
                          this._postByAdButtonSubject.add(true);
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
    String body = this._postTitleController.text.trim();
    List<File> media = await this._photosSubject.first;
    int type = 1;
    int status = _getStatus(await this._postOptionsSubject.first);
    if (body.isEmpty && media == null) {
      showToast('Require title or photo');
      return;
    }
    this._postByCoinsButtonSubject.add(true);
    MoonBlinkRepository.uploadPost(media.first, type, status, body: body ?? '')
        .then((_) {
      showToast('Upload Success');
      Navigator.pop(context);
      this._postByCoinsButtonSubject.add(false);
    },
            onError: (e) => {
                  showToast(e.toString()),
                  this._postByCoinsButtonSubject.add(false)
                });
  }

  int _getStatus(String option) {
    switch (option) {
      case 'Private':
        return 0;
      case 'Public':
        return 1;
      case 'Followers':
        return 2;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppbarWidget(
          title: Text('Create Post'),
        ),
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: StorageManager.sharedPreferences
                        .getString(mUserProfile),
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 26, backgroundImage: imageProvider),
                    placeholder: (context, url) => CupertinoActivityIndicator(),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(StorageManager.sharedPreferences
                          .getString(mLoginName)),
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
                                icon: Icon(Icons.expand_more),
                                onChanged: (String value) {
                                  this._postOptionsSubject.add(value);
                                },
                                dropdownColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                selectedItemBuilder: (context) {
                                  return this
                                      ._followerOptions
                                      .map<Widget>((String item) {
                                    return Center(
                                        child: Text(item,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor)));
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
                  trailing: Column(
                    children: [
                      StreamBuilder<int>(
                        initialData: null,
                        stream: this._adCountSubject,
                        builder: (context, snapshot) {
                          return Text(
                              '${snapshot.data} ${snapshot.data > 1 ? "Ads" : "Ad"} Watched');
                        },
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                          onTap: () async {
                            this._startWatchingButtonSubject.add(true);
                            await RewardedVideoAd.instance.load(
                                adUnitId: AdManager.rewardedAdId,
                                targetingInfo: targetingInfo);
                          },
                          child: StreamBuilder<bool>(
                              initialData: false,
                              stream: this._startWatchingButtonSubject,
                              builder: (context, snapshot) {
                                if (snapshot.data)
                                  return CupertinoActivityIndicator();
                                return Text('Start Watching',
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor));
                              })),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                CupertinoTextField(
                  minLines: 3,
                  maxLines: 3,
                  placeholder: 'Write your post\'s title here',
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
                    CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Add Photos'),
                        onPressed: () {
                          _showSelectImageOptions();
                        }),
                    StreamBuilder<List<File>>(
                      initialData: null,
                      stream: this._photosSubject,
                      builder: (context, snapshot) {
                        if (snapshot.data == null || snapshot.data.isEmpty) {
                          return Container();
                        }
                        return StreamBuilder<int>(
                          initialData: -1,
                          stream: this._selectedPhotoIndexSubject,
                          builder: (context, snapshot2) {
                            if (snapshot2.data == null || snapshot2.data == -1) {
                              return CupertinoButton(
                                child: Text('Remove All Photos'),
                                onPressed: () {
                                  this._photosSubject.add([]);
                                },
                              );
                            }
                            return Row(
                              children: [
                                CupertinoButton(
                                  child: Text('Crop'),
                                  onPressed: () {},
                                ),
                                CupertinoButton(
                                  child: Text('Remove'),
                                  onPressed: () {
                                    this._photosSubject.first.then((photos) {
                                      photos.removeAt(snapshot2.data);
                                      this._selectedPhotoIndexSubject.add(-1);
                                      this._photosSubject.add(photos);
                                    });
                                  },
                                )
                              ],
                            );
                          },
                        );
                      }
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Expanded(
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: StreamBuilder<List<File>>(
                      initialData: null,
                      stream: this._photosSubject,
                      builder: (context, snapshot) {
                        if (snapshot.data == null || snapshot.data.isEmpty) {
                          return Container();
                        }
                        return GridView.builder(
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
                                            .add(value == index ? -1 : index);
                                      });
                                    },
                                    child: Image.file(
                                      snapshot.data[index],
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: index == selectedIndex
                                          ? Colors.white30
                                          : Colors.transparent,
                                      colorBlendMode: BlendMode.lighten,
                                      fit: BoxFit.fill,
                                    ),
                                  );
                                });
                          },
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: StreamBuilder<bool>(
                            initialData: false,
                            stream: this._postByAdButtonSubject,
                            builder: (context, snapshot) {
                              if (snapshot.data) {
                                return CupertinoButton.filled(
                                    padding: EdgeInsets.zero,
                                    child: CupertinoActivityIndicator(),
                                    onPressed: () {});
                              }
                              return CupertinoButton.filled(
                                  padding: EdgeInsets.zero,
                                  child: Text('Post by watching Ads'),
                                  onPressed: () => this._postByAd());
                            })),
                    SizedBox(width: 5),
                    Expanded(
                        child: StreamBuilder<bool>(
                            initialData: false,
                            stream: this._postByCoinsButtonSubject,
                            builder: (context, snapshot) {
                              if (snapshot.data) {
                                return CupertinoButton.filled(
                                  padding: EdgeInsets.zero,
                                  child: CupertinoActivityIndicator(),
                                  onPressed: () {},
                                );
                              }
                              return CupertinoButton.filled(
                                  padding: EdgeInsets.zero,
                                  child: Text('Post by using Coins'),
                                  onPressed: () => this._postByCoins());
                            }))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
import 'package:moonblink/utils/compress_utils.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
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
  final _followerOptions = ['Public', 'Follower'];
  final _postTitleController = TextEditingController();

  // ignore: close_sinks
  final _followerOptionsSubject = BehaviorSubject.seeded('Public');
  final _photoSubject = BehaviorSubject<File>.seeded(null);
  final _adCountSubject = BehaviorSubject<int>.seeded(0);
  final _postByAdButtonSubject = BehaviorSubject.seeded(false);
  final _postByCoinsButtonSubject = BehaviorSubject.seeded(false);

  @override
  void initState() {
    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event,
        {String rewardType, int rewardAmount}) async {
      if (isDev) print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.rewarded) {
        /// Do Some Api Call
        await Future.delayed(Duration(milliseconds: 2000));
        this._postByAdButtonSubject.add(false);
      }
      if (event == RewardedVideoAdEvent.loaded) {
        RewardedVideoAd.instance.show();
      }
      if (event == RewardedVideoAdEvent.failedToLoad) {
        this._postByAdButtonSubject.add(false);
      }
      if (event == RewardedVideoAdEvent.closed) {
        this._postByAdButtonSubject.add(false);
      }
      if (event == RewardedVideoAdEvent.leftApplication) {
        this._postByAdButtonSubject.add(false);
      }
      if (event == RewardedVideoAdEvent.completed) {
        this._postByAdButtonSubject.add(false);
      }
    };
    super.initState();
  }

  @override
  void dispose() {
    this._followerOptionsSubject.close();
    this._photoSubject.close();
    this._adCountSubject.close();
    this._postByAdButtonSubject.close();
    this._postByCoinsButtonSubject.close();
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
                    limit: 1,
                    body: G.of(context).picknrc,
                    onPressed: (File file) {
                      this._photoSubject.add(file);
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
                this._photoSubject.add(await CompressUtils.compressAndGetFile(
                    File(pickedFile.path), NORMAL_COMPRESS_QUALITY, 600, 800));
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
    int adCount = 10 - await this._adCountSubject.first;
    showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Post by watching Ads'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('You need $adCount more Ads need to watch.'),
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

  _postByCoins() async {}

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
                    placeholder: (context, url) =>
                        CupertinoActivityIndicator(),
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
                          stream: this._followerOptionsSubject,
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return Container();
                            }
                            return DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: snapshot.data,
                                icon: Icon(Icons.expand_more),
                                onChanged: (String value) {
                                  this._followerOptionsSubject.add(value);
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
                  trailing: StreamBuilder<int>(
                    initialData: null,
                    stream: this._adCountSubject,
                    builder: (context, snapshot) {
                      return Text(
                          '${snapshot.data} ${snapshot.data > 1 ? "Ads" : "Ad"} Watched',
                          style: TextStyle(
                              color: Theme.of(context).accentColor));
                    },
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
                Container(
                  alignment: Alignment.centerLeft,
                  child: CupertinoButton(
                      child: Text('Add a Photo'),
                      onPressed: () {
                        _showSelectImageOptions();
                      }),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: StreamBuilder<File>(
                      initialData: null,
                      stream: this._photoSubject,
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return Container();
                        }
                        return Image.file(
                          snapshot.data,
                          width: double.infinity,
                          fit: BoxFit.fill,
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

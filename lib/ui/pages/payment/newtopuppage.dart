import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/payments/paymentMethod.dart';
import 'package:moonblink/models/payments/product.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/utils/compress_utils.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/subjects.dart';

class Newtopuppage extends StatefulWidget {
  final List<Product> product;
  final PaymentMethod method;

  const Newtopuppage({Key key, this.product, this.method}) : super(key: key);
  @override
  _NewtopuppageState createState() => _NewtopuppageState();
}

class _NewtopuppageState extends State<Newtopuppage> {
  Product selectedProduct;
  final _transactionImagesSubject = BehaviorSubject<List<File>>.seeded([]);
  final _submitSubject = BehaviorSubject.seeded(false);
  final maxImageLimit = 1;
  final _transferAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _submitSubject.close();
    _transactionImagesSubject.close();
    _transferAmountController.dispose();
    _descriptionController.dispose();
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
                    body: G.current.paymentTopUpSelectScreenshot,
                    onPressed: (List<File> files) async {
                      this._transactionImagesSubject.add([files.first]);
                      // final currentFiles =
                      //     await this._transactionImagesSubject.first;
                      // currentFiles.addAll(files);
                      // if (currentFiles.length > maxImageLimit) {
                      //   int x = currentFiles.length - maxImageLimit;
                      //   currentFiles.removeRange(0, x);
                      // }
                      // this._transactionImagesSubject.add(currentFiles);
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
                this._transactionImagesSubject.add([compressedImage]);
                // final currentFiles = await this._transactionImagesSubject.first;
                // currentFiles.add(compressedImage);
                // if (currentFiles.length > maxImageLimit) {
                //   int x = currentFiles.length - maxImageLimit;
                //   currentFiles.removeRange(0, x);
                // }
                // this._transactionImagesSubject.add(currentFiles);
              }),
          CupertinoButton(
            child: Text(G.of(context).cancel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget availablePlatformItem() {
    return Card(
      elevation: 10.0,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0)),
                ),
                child: Text(
                  widget.method.title,
                  textAlign: TextAlign.start,
                  // style: TextStyle(color: textColor),
                )),
            SizedBox(height: 5),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => FullScreenImageView(
                                assetsName: widget.method.image)));
                  },
                  child: Image.asset(
                    widget.method.smallimage,
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.12,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: widget.method.method,
                      style: Theme.of(context).textTheme.subtitle1,
                      children: [
                        TextSpan(
                          recognizer: widget.method.recognizer,
                          text: widget.method.id,
                          style: TextStyle(
                              letterSpacing: 0.3,
                              color: Theme.of(context).accentColor,
                              fontSize: 15.0),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  _topup() async {
    final screenshots = await _transactionImagesSubject.first;
    if (screenshots == null || screenshots.isEmpty) {
      showToast(G.current.paymentTopUpRequireScreenshot);
      return;
    }
    if (selectedProduct == null) {
      showToast(G.current.paymentTopUpRequireScreenshot);
      return;
    }
    _submitSubject.add(true);
    MoonBlinkRepository.postPayment(
            selectedProduct.id,
            screenshots,
            _transferAmountController.text ?? "",
            _descriptionController.text ?? "")
        .then((value) {
      _submitSubject.add(false);
      Navigator.pop(context);
      showToast(G.current.toastsuccess);
    }, onError: (e) {
      _submitSubject.add(false);
      showToast('$e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(G.current.topup),
            backgroundColor: Colors.black,
            bottom: PreferredSize(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).accentColor,
                      // spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                height: 10,
              ),
              preferredSize: Size.fromHeight(5),
            ),
            leading: IconButton(
                icon: SvgPicture.asset(
                  back,
                  semanticsLabel: 'back',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).accentColor
                      : Colors.white,
                  width: 30,
                  height: 30,
                ),
                onPressed: () => Navigator.pop(context)),
            actions: [
              StreamBuilder<bool>(
                  initialData: false,
                  stream: _submitSubject,
                  builder: (context, snapshot) {
                    if (snapshot.data) {
                      return CupertinoButton(
                        onPressed: () {},
                        child: CupertinoActivityIndicator(),
                      );
                    }
                    return TextButton(
                      onPressed: () {
                        _topup();
                      },
                      child: Text(G.current.submit),
                    );
                  })
            ],
          ),
          body: Container(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 5),
                //Method
                availablePlatformItem(),
                //Text('Upload your transfer Photo & Description'),
                //Dropdown to choose product
                DropdownButtonHideUnderline(
                  child: DropdownButton<Product>(
                    dropdownColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Colors.black,
                    isExpanded: true,
                    value: selectedProduct,
                    hint: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(G.current.paymentTopUpSelectProduct),
                    ),
                    onChanged: (Product value) {
                      setState(() {
                        selectedProduct = value;
                      });
                    },
                    items: widget.product.map((Product product) {
                      return DropdownMenuItem<Product>(
                        value: product,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            product.name,
                            // style: TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Divider(indent: 5, endIndent: 5, thickness: 2),
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: Row(
                      children: [
                        ///ScreenShot
                        Expanded(
                          child: StreamBuilder<List<File>>(
                            initialData: null,
                            stream: _transactionImagesSubject,
                            builder: (context, snapshot) {
                              if (snapshot.data == null ||
                                  snapshot.data.isEmpty) {
                                return Text(
                                  G.current.paymentTopUpScreenshotAppearLayer,
                                  textAlign: TextAlign.center,
                                );
                              }
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          fullscreenDialog: true,
                                          builder: (_) => FullScreenImageView(
                                              image: snapshot.data.first)));
                                },
                                child: Image.file(
                                  snapshot.data.first,
                                  fit: BoxFit.fill,
                                  height: double.infinity,
                                ),
                              );
                              // return GridView.builder(
                              //   shrinkWrap: true,
                              //   physics: ClampingScrollPhysics(),
                              //   gridDelegate:
                              //       SliverGridDelegateWithFixedCrossAxisCount(
                              //           crossAxisCount: maxImageLimit),
                              //   itemCount: snapshot.data.length,
                              //   itemBuilder: (context, index) {
                              //     return InkWell(
                              //       onTap: () {
                              //         Navigator.push(
                              //             context,
                              //             CupertinoPageRoute(
                              //                 fullscreenDialog: true,
                              //                 builder: (_) =>
                              //                     FullScreenImageView(
                              //                         image: snapshot
                              //                             .data[index])));
                              //       },
                              //       child: Image.file(
                              //         snapshot.data[index],
                              //         fit: BoxFit.fill,
                              //         height: double.infinity,
                              //       ),
                              //     );
                              //   },
                              // );
                            },
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      fullscreenDialog: true,
                                      builder: (_) => FullScreenImageView(
                                          assetsName: widget.method.sample)));
                            },
                            child: Image.asset(
                              widget.method.sample,
                              fit: BoxFit.fill,
                              height: double.infinity,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Add a screenshot
                    InkWell(
                      borderRadius: BorderRadius.circular(15.0),
                      onTap: () {
                        _showSelectImageOptions();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).accentColor),
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Text(G.current.paymentTopUpAddScreenshots,
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 16.0)),
                      ),
                    ),

                    /// Remove a screenshot
                    StreamBuilder<List<File>>(
                        initialData: [],
                        stream: _transactionImagesSubject,
                        builder: (context, snapshot) {
                          if (snapshot.data.isEmpty) {
                            return Container();
                          }
                          return InkWell(
                            borderRadius: BorderRadius.circular(15.0),
                            onTap: () {
                              _transactionImagesSubject.add([]);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).accentColor),
                                  borderRadius: BorderRadius.circular(15.0)),
                              child: Text(
                                  G.current.paymentTopUpRemoveScreenshots,
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 16.0)),
                            ),
                          );
                        }),
                  ],
                ),
                SizedBox(height: 10),
                if (selectedProduct == null
                    ? false
                    : (selectedProduct.name == customProduct))
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: CupertinoTextField(
                              placeholder: G.current.paymentTopUpTransferAmount,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              clearButtonMode: OverlayVisibilityMode.editing,
                              controller: _transferAmountController,
                              style: Theme.of(context).textTheme.subtitle1,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).accentColor),
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            flex: 6,
                            child: CupertinoTextField(
                              placeholder: G.current.paymentTopUpDescription,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              clearButtonMode: OverlayVisibilityMode.editing,
                              controller: _descriptionController,
                              style: Theme.of(context).textTheme.subtitle1,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).accentColor),
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                            ),
                          ),
                          InkResponse(
                            onTap: () {
                              showToast(G.current.paymentTopUpQuestionExplain);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: Icon(
                                Icons.help_outline_rounded,
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10)
                    ],
                  ),
                Divider(indent: 5, endIndent: 5, thickness: 2),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

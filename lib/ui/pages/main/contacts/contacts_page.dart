import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/contacttemple/contactcontainer.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/models/contact.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/utils/status_bar_utils.dart';
import 'package:moonblink/view_model/contact_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  // with AutomaticKeepAliveClientMixin {
  // @override
  // bool get wantKeepAlive => true;
  List<String> alphabetList = [];
  Map<String, int> strMap = {};
  List<Contact> contacts = [];
  List<String> strList = [];
  Contact contact;
  List<Widget> items = [];
  List<String> alphabet = [];
  // ignore: unused_field
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController searchController = TextEditingController();
  String _currentAlphabet = "";
  int count = 0;

  ContactModel _contactModel;
  bool isBlocking = false;

  @override
  initState() {
    _contactModel = ContactModel();
    super.initState();
  }

  // initList(List<String> strlist, List<Contact> contactslist) {
  //   // print(strlist.toString());
  //   items = [];
  //   List<String> tempList = strlist;
  //   tempList.sort();
  //   tempList.sort((a, b) {
  //     if (a.codeUnitAt(0) < 65 ||
  //         a.codeUnitAt(0) > 122 &&
  //             b.codeUnitAt(0) >= 65 &&
  //             b.codeUnitAt(0) <= 122) {
  //       return 1;
  //     } else if (b.codeUnitAt(0) < 65 ||
  //         b.codeUnitAt(0) > 122 &&
  //             a.codeUnitAt(0) >= 65 &&
  //             a.codeUnitAt(0) <= 122) {
  //       return -1;
  //     }
  //     return a.compareTo(b);
  //   });
  //   // _currentAlphabet = tempList[0];
  //   // alphabetList.add(tempList[0]);
  //   for (var i = 0; i < tempList.length; i++) {
  //     var currentStr = tempList[i][0];
  //     strMap[currentStr] = i;
  //     if (_currentAlphabet != currentStr) {
  //       alphabetList.add(currentStr);
  //     }
  //     Contact contact = contactslist[i];
  //     count += 1;
  //     Widget tile = contactTile(contact);
  //     items.add(tile);

  //     if (_currentAlphabet != currentStr) {
  //       item = ItemCount(items, count);
  //       print("Item Count");
  //       // print(item.contactitems.length);
  //       // print(item.count);
  //       itemcount.add(item);
  //       count = 0;
  //       items = [];
  //       _currentAlphabet = currentStr;
  //     }
  //   }
  //   print(alphabetList.toString());
  //   print(itemcount[0].contactitems.length);
  // }

  ///[Tiles]
  filterList() {
    List<Contact> users = List();
    users.addAll(contacts);
    users.forEach(
      (user) {
        // items.add(contactTile(user));
        strList.add(user.contactUser.contactUserName.toUpperCase()[0]);
      },
    );
  }

  // contactTile(user) {
  //   return isBlocking
  //       ? CupertinoActivityIndicator()
  //       :
  //       // ListTile(
  //       //     leading: CachedNetworkImage(
  //       //       imageUrl: user.contactUser.contactUserProfile,
  //       //       imageBuilder: (context, imageProvider) => CircleAvatar(
  //       //         radius: 28,
  //       //         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  //       //         backgroundImage: imageProvider,
  //       //       ),
  //       //       placeholder: (context, url) => CircleAvatar(
  //       //         radius: 28,
  //       //         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  //       //         // backgroundImage: ,
  //       //       ),
  //       //       errorWidget: (context, url, error) => Icon(Icons.error),
  //       //     ),
  //       //     // leading: CircleAvatar(
  //       //     //   radius: 28,
  //       //     //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  //       //     //   backgroundImage:
  //       //     //       NetworkImage(user.contactUser.contactUserProfile),
  //       //     // ),
  //       //     title: Text(user.contactUser.contactUserName),
  //       //     onTap: () {
  //       //       int detailPageId = user.contactUser.contactUserId;
  //       //       // int index = users.indexOf(user);
  //       //       // print(index);
  //       //       Navigator.push(
  //       //           context,
  //       //           MaterialPageRoute(
  //       //               builder: (context) =>
  //       //                   PartnerDetailPage(detailPageId))).then(
  //       //         (value) async {
  //       //           if (value != null) {
  //       //             setState(() {
  //       //               isBlocking = true;
  //       //             });

  //       //             ///Block Uesrs
  //       //             try {
  //       //               await MoonBlinkRepository.blockOrUnblock(value, BLOCK);
  //       //               await _contactModel.initData();
  //       //               setState(() {
  //       //                 isBlocking = false;
  //       //               });
  //       //             } catch (e) {
  //       //               print(e.toString());
  //       //               setState(() {
  //       //                 isBlocking = false;
  //       //               });
  //       //             }
  //       //           }
  //       //         },
  //       //       );
  //       //     },
  //       //   );
  // }

  @override
  Widget build(BuildContext context) {
    // super.build(context);

    return Scaffold(
      ///[Appbar]
      appBar: AppbarWidget(),
      body: ProviderWidget<ContactModel>(
        model: _contactModel,
        onModelReady: (model) => model.initData(),
        builder: (context, contactModel, child) {
          if (contactModel.isBusy &&
              Theme.of(context).brightness == Brightness.light) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        ImageHelper.wrapAssetsImage('bookingWaiting.gif'),
                      ),
                      fit: BoxFit.fill)),
            );
          }
          if (contactModel.isBusy &&
              Theme.of(context).brightness == Brightness.dark) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        ImageHelper.wrapAssetsImage('moonblinkWaitingDark.gif'),
                      ),
                      fit: BoxFit.fill)),
            );
          }
          if (contactModel.isError && contactModel.list.isEmpty) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: StatusBarUtils.systemUiOverlayStyle(context),
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: Theme.of(context).brightness == Brightness.light
                            ? AssetImage(ImageHelper.wrapAssetsImage(
                                'noFollowingDay.png'))
                            : AssetImage(ImageHelper.wrapAssetsImage(
                                'noFollowingDark.jpg')),
                        fit: BoxFit.cover)),
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 200,
                      child: CupertinoButton(
                        color: Colors.transparent,
                        child: Text(
                          "${contactModel.viewStateError.errorMessage}",
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 20),
                        ),
                        onPressed: contactModel.initData,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // print(contactModel.list.length);
          // print(model.list);
          contacts.clear();
          // items.clear();
          for (var i = 0; i < contactModel.list.length; i++) {
            contact = contactModel.list[i];
            contacts.add(contact);
          }
          // print(contacts);
          // contacts.sort((a, b) => a.contactUser.contactUserName
          //     .toLowerCase()
          //     .compareTo(b.contactUser.contactUserName.toLowerCase()));
          // filterList();
          if (contactModel.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: ViewStateEmptyWidget(onPressed: contactModel.initData),
              ),
            );
          return CustomScrollView(
            slivers: [
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              //     child: RoundedContainer(
              //       height: 50,
              //       color: Theme.of(context).scaffoldBackgroundColor,
              //       child: Container(
              //         padding: EdgeInsets.only(top: 10),
              //         child: ListView.builder(
              //           scrollDirection: Axis.horizontal,
              //           itemBuilder: (context, index) {
              //             return Text("A");
              //           },
              //           itemCount: contacts.length,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ContactContainer(contacts[index]);
                  },
                  childCount: contacts.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// AlphabetListScrollView(
//   strList: alphabetList,
//   highlightTextStyle: TextStyle(
//     color: Theme.of(context).accentColor,
//   ),
//   showPreview: true,
//   itemBuilder: (context, index) {
//     // return Text("Hello");
//     return ListView.builder(
//       itemBuilder: (context, newindex) {
//         return itemcount[index].contactitems[newindex];
//       },
//       itemCount: itemcount[index].contactitems.length,
//     );
//   },
//   indexedHeight: (i) {
//     // return 80;
//     return (itemcount[i].count * 80).toDouble();
//   },
// ),

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/contacttemple/contactcontainer.dart';
import 'package:moonblink/base_widget/container/roundedContainer.dart';
import 'package:moonblink/generated/l10n.dart';
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
  // Map<String, int> strMap = {};
  List<Contact> contacts = [];
  List<double> scrollindex = [];
  List<String> strList = [];
  Contact contact;
  List<Widget> items = [];
  List<String> alphabet = [];
  // ignore: unused_field
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController searchController = TextEditingController();
  String _currentAlphabet = "";
  int count = -1;
  double itemExtent = 415;
  ScrollController listController = ScrollController();
  double _listPosition = 0;

  ContactModel _contactModel;
  bool isBlocking = false;
  _listListener() {
    setState(() {
      _listPosition = listController.position.pixels;
    });
  }

  @override
  initState() {
    _contactModel = ContactModel();
    listController.addListener(_listListener);
    super.initState();
  }

  titlebox(String title, double index) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: () {
            if (itemExtent * (index) <= _listPosition &&
                itemExtent * (index + 1) > _listPosition) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: MoreGradientColors.jShine,
              );
            } else {
              return null;
            }
          }()),
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      child: GestureDetector(
        onTap: () {
          listController.animateTo(
            itemExtent * (index),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
        child: Center(child: Text(title)),
      ),
    );
  }

  initList(List<String> strlist) {
    // print(strlist.toString());
    items = [];
    List<String> tempList = strlist;
    // tempList.sort();
    tempList.sort((a, b) {
      if (a.codeUnitAt(0) < 65 ||
          a.codeUnitAt(0) > 122 &&
              b.codeUnitAt(0) >= 65 &&
              b.codeUnitAt(0) <= 122) {
        return 1;
      } else if (b.codeUnitAt(0) < 65 ||
          b.codeUnitAt(0) > 122 &&
              a.codeUnitAt(0) >= 65 &&
              a.codeUnitAt(0) <= 122) {
        return -1;
      }
      return a.compareTo(b);
    });
    // _currentAlphabet = tempList[0];
    // alphabetList.add(tempList[0]);
    for (var i = 0; i < tempList.length; i++) {
      var currentStr = tempList[i][0];
      // print(currentStr.codeUnitAt(0));
      // strMap[currentStr] = i;
      count += 1;
      if (currentStr.codeUnitAt(0) < 65 || currentStr.codeUnitAt(0) > 122) {
        currentStr = '#';
        if (_currentAlphabet != currentStr) {
          alphabetList.add("#");
          scrollindex.add(count.toDouble());
        }
        _currentAlphabet = "#";
      } else if (_currentAlphabet != currentStr) {
        alphabetList.add(currentStr);
        scrollindex.add(count.toDouble());
        _currentAlphabet = currentStr;
      }
    }
    count = -1;
    // print(alphabetList.toString());
    // print(scrollindex.toString());
  }

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

  @override
  Widget build(BuildContext context) {
    // super.build(context);

    return Scaffold(
      ///[Appbar]
      appBar: AppbarWidget(
        leadingText: G.current.tabFollowing,
        leadingCallback: () {},
      ),
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
          strList.clear();
          alphabetList.clear();
          scrollindex.clear();
          // items.clear();
          for (var i = 0; i < contactModel.list.length; i++) {
            contact = contactModel.list[i];
            contacts.add(contact);
            strList.add(contact.contactUser.contactUserName.toUpperCase()[0]);
          }
          // print(contacts);
          // contacts.sort((a, b) => a.contactUser.contactUserName
          //     .toLowerCase()
          //     .compareTo(b.contactUser.contactUserName.toLowerCase()));
          // filterList();
          initList(strList);
          if (contactModel.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: ViewStateEmptyWidget(onPressed: contactModel.initData),
              ),
            );
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: RoundedContainer(
                  height: 50,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 0, minHeight: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return titlebox(
                            alphabetList[index], scrollindex[index]);
                      },
                      itemCount: alphabetList.length,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  shrinkWrap: true,
                  controller: listController,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ContactContainer(contacts[index]);
                        },
                        childCount: contacts.length,
                      ),
                    ),
                  ],
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moonblink/base_widget/appbarlogo.dart';
import 'package:moonblink/base_widget/azlist.dart';
import 'package:moonblink/base_widget/skeleton.dart';
import 'package:moonblink/models/contact.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/pages/main/home/home_provider_widget/post_skeleton.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
import 'package:moonblink/utils/status_bar_utils.dart';
import 'package:moonblink/view_model/contact_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<String> strList = [];
  Contact contact;
  List<Widget> items = [];
  // ignore: unused_field
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController searchController = TextEditingController();

  ///[Tiles]
  filterList() {
    List<Contact> users = List();
    users.addAll(contacts);
    items = [];
    strList = [];
    if (searchController.text.isNotEmpty) {
      users.retainWhere((user) => user.contactUser.contactUserName
          .toLowerCase()
          .contains(searchController.text.toLowerCase()));
    }
    users.forEach((user) {
      items.add(Column(children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              backgroundImage: NetworkImage(user.contactUser.contactUserProfile),
            ),
            title: Text(user.contactUser.contactUserName),
            // subtitle: Text(user.contactUser.contactUserProfile),
            onTap: () {
              int detailPageId = user.contactUser.contactUserId;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PartnerDetailPage(detailPageId)));
            },
          ),
        ),
        Divider(
          color: Colors.grey,
        )
      ]));
      strList.add(user.contactUser.contactUserName.toUpperCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        ///[Appbar]
        appBar: AppBar(title: AppbarLogo()),
        body: ProviderWidget<ContactModel>(
            model: ContactModel(),
            onModelReady: (model) => model.initData(),
            builder: (context, contactModel, child) {
              if(contactModel.isBusy) {
                return SkeletonList(builder: (context, index) => PostSkeletonItem());
              }
              if (contactModel.isError && contactModel.list.isEmpty) {
                return AnnotatedRegion<SystemUiOverlayStyle>(
                    value: StatusBarUtils.systemUiOverlayStyle(context),
                    child: ViewStateErrorWidget(
                        error: contactModel.viewStateError,
                        onPressed: contactModel.initData));
              }
              print(contactModel.list.length);
              // print(model.list);
              for (var i = 0; i < contactModel.list.length; i++) {
                contact = contactModel.list[i];
                contacts.add(contact);
              }
              // print(contacts);
              contacts.sort((a, b) => a.contactUser.contactUserName
                  .toLowerCase()
                  .compareTo(b.contactUser.contactUserName.toLowerCase()));
              filterList();
              // print(strList.length);
              if (contactModel.isEmpty)
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: ViewStateEmptyWidget(onPressed: contactModel.initData),
                ));
              return AlphabetListScrollView(
                strList: strList,
                highlightTextStyle: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
                showPreview: true,
                itemBuilder: (context, index) {
                  return items[index];
                },
                indexedHeight: (i) {
                  return 100;
                },
              );
            }));
  }
}

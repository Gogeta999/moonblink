import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/azlist.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/models/contact.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
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
        Card(
          // color: Theme.of(context).cardColor,
          child: ListTile(
            leading: CachedNetworkImage(
              imageUrl: user.contactUser.contactUserProfile,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                // backgroundImage: ,
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            // leading: CircleAvatar(
            //   radius: 28,
            //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            //   backgroundImage:
            //       NetworkImage(user.contactUser.contactUserProfile),
            // ),
            title: Text(user.contactUser.contactUserName),
            onTap: () {
              int detailPageId = user.contactUser.contactUserId;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PartnerDetailPage(detailPageId)));
            },
          ),
        ),
        // Divider(
        //   color: Colors.grey,
        // )
      ]));
      strList.add(user.contactUser.contactUserName.toUpperCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Scaffold(
      ///[Appbar]
      appBar: AppbarWidget(),
      body: ProviderWidget<ContactModel>(
        model: ContactModel(),
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
                          image: AssetImage(
                            ImageHelper.wrapAssetsImage('noFollowing.jpg'),
                          ),
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
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                          onPressed: contactModel.initData,
                        ),
                      ),
                    ],
                  ),
                ));
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
          return Padding(
            padding: EdgeInsets.only(top: 8),
            child: AlphabetListScrollView(
              strList: strList,
              highlightTextStyle: TextStyle(
                color: Theme.of(context).accentColor,
              ),
              showPreview: true,
              itemBuilder: (context, index) {
                return items[index];
              },
              indexedHeight: (i) {
                return 65;
              },
            ),
          );
        },
      ),
    );
  }
}

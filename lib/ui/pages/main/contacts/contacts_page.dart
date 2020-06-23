import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbarlogo.dart';
import 'package:moonblink/base_widget/azlist.dart';
import 'package:moonblink/models/contact.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
import 'package:moonblink/view_model/contact_model.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<String> strList = [];
  Contact contact;
  List<Widget> items = [];
  TextEditingController searchController = TextEditingController();

  ///[Tiles]
  filterList() {
    List<Contact> users = List();
    users.addAll(contacts);
    items = [];
    strList = [];
    if (searchController.text.isNotEmpty) {
      users.retainWhere((user) =>
          user.contactUser.contactUserName
              .toLowerCase()
              .contains(searchController.text.toLowerCase()));
    }
    users.forEach((user) {
        items.add(
            Column(
            children: <Widget>[
            ListTile(
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
                  context, MaterialPageRoute(builder: (context) => PartnerDetailPage(detailPageId)));
              },         
            ),
            Divider(color: Colors.grey,)
            ]
            )
        );
        strList.add(user.contactUser.contactUserName.toUpperCase());       
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///[Appbar]
      appBar: AppBar(title: AppbarLogo()),
      body: ProviderWidget<ContactModel> (
        model: ContactModel(),
        onModelReady: (model) => model.initData(),
        builder: (context, model, child) {
          
          print(model.list.length);
          // print(model.list);
          for (var i = 0; i < model.list.length; i++) {
            contact = model.list[i];
            contacts.add(contact);
          }
          print(contacts);
          contacts
            .sort((a, b) => a.contactUser.contactUserName.toLowerCase().compareTo(b.contactUser.contactUserName.toLowerCase()));
            filterList();
   
          print(strList.length);
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
          }
        )
      );
    }
}



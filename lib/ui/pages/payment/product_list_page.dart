import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/payments/product.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/constants.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppbarWidget(title: Text('Product List')),
        body: Container(
          margin: const EdgeInsets.all(8.0),
          child: FutureBuilder<List<Product>>(
            initialData: [],
            future: MoonBlinkRepository.getProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: CupertinoButton(
                    child: Text('${snapshot.error}\nRetry'),
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                );
              }
              if (snapshot.data.isEmpty) {
                return Center(child: CupertinoActivityIndicator());
              }
              return ListView.builder(
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data[index];
                  if (item.name == customProduct) {
                    return Card(
                      elevation: 10.0,
                      child: ListTile(
                        title: Text('Custom Amount TopUp'),
                        subtitle: Text('Price - base on your topup amount'),
                        onTap: () {
                          Navigator.pushNamed(context, RouteName.topUpPage,
                              arguments: item);
                        },
                      ),
                    );
                  }

                  return Card(
                    elevation: 10.0,
                    child: ListTile(
                      title: Text('MoonBlink Coins - ${item.mbCoin}'),
                      subtitle:
                          Text('Price - ${item.value} ${item.currencyCode}'),
                      onTap: () {
                        Navigator.pushNamed(context, RouteName.topUpPage,
                            arguments: item);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

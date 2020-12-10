import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:moonblink/base_widget/intro/flutter_intro.dart';
import 'package:moonblink/bloc_pattern/boosting_game_detail/bloc/boosting_game_detail_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/BoostGame.dart';
import 'package:moonblink/utils/constants.dart';

class BoostingGameDetailPage extends StatefulWidget {
  final Map data;

  const BoostingGameDetailPage({Key key, this.data}) : super(key: key);

  @override
  _BoostingGameDetailPageState createState() => _BoostingGameDetailPageState();
}

class _BoostingGameDetailPageState extends State<BoostingGameDetailPage> {
  bool tuto;
  Intro intro;
  _BoostingGameDetailPageState() {
    intro = Intro(
      stepCount: 6,
      borderRadius: BorderRadius.circular(15),
      onfinish: () {
        intro.dispose();
        setState(() {
          tuto = false;
        });
      },

      /// use defaultTheme, or you can implement widgetBuilder function yourself
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          G.current.boostDetailTuto1,
          G.current.boostDetailTuto2,
          G.current.boostDetailTuto3,
          G.current.boostDetailTuto4,
          G.current.boostDetailTuto5,
          G.current.boostDetailTuto6,
        ],
        buttonTextBuilder: (curr, total) {
          return curr < total - 1 ? G.current.next : G.current.finish;
        },
      ),
    );
  }
  // ignore: close_sinks
  BoostingGameDetailBloc _bloc;

  @override
  void initState() {
    this._bloc = BoostingGameDetailBloc(widget.data['id']);
    this._bloc.init();

    ///[to test]
    // StorageManager.sharedPreferences.setBool(kNewToBoosting, true);
    super.initState();
  }

  @override
  void dispose() {
    Timer(Duration(microseconds: 0), () {
      intro.dispose();
    });
    this._bloc.dispose();
    super.dispose();
  }

  Widget get _loading => Center(child: CupertinoActivityIndicator());

  Widget _buildCard({Widget child}) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 8,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: child),
    );
  }

  Widget _buildTitleWidget({String title}) {
    return _buildCard(
      child: Column(
        children: <Widget>[
          Text(title,
              style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
          Divider(thickness: 2),
        ],
      ),
    );
  }

  // Widget _buildHeader() {
  //   return _buildCard(
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: StreamBuilder<String>(
  //               initialData: null,
  //               stream: this._bloc.selectedRankTotalSubject,
  //               builder: (context, snapshot) {
  //                 if (snapshot.data == null) {
  //                   return _loading;
  //                 }
  //                 return Container(
  //                   margin: const EdgeInsets.only(left: 12),
  //                   child: Text('${snapshot.data}',
  //                       style: TextStyle(fontSize: 16)),
  //                 );
  //               }),
  //         ),
  //         CupertinoButton(
  //             child: Text('Switch'), onPressed: () => _showGameRankPicker())
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildListItem(int index) {
  //   return Column(
  //     children: [
  //       SizedBox(height: 15),
  //       _buildCard(
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: StreamBuilder<String>(
  //                   initialData: null,
  //                   stream: this._bloc.selectedRankTotalSubject,
  //                   builder: (context, snapshot) {
  //                     if (snapshot.data == null) {
  //                       return _loading;
  //                     }
  //                     return Container(
  //                       margin: const EdgeInsets.only(left: 12),
  //                       child: StreamBuilder<List<ItemData>>(
  //                           initialData: null,
  //                           stream: this._bloc.itemDataSubject,
  //                           builder: (context, snapshot) {
  //                             if (snapshot.data == null) {
  //                               return _loading;
  //                             }
  //                             return Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Text(
  //                                   '${this._bloc.gameList[index]}  To  ${this._bloc.gameList[index + 1]}',
  //                                   style: TextStyle(fontSize: 16),
  //                                 ),
  //                                 SizedBox(height: 10),
  //                                 Text(
  //                                     'Price - ${snapshot.data[index].price} Coins'),
  //                                 SizedBox(height: 5),
  //                                 Text(
  //                                     'Duration - ${snapshot.data[index].days} Days, ${snapshot.data[index].hours} Hours'),
  //                               ],
  //                             );
  //                           }),
  //                     );
  //                   }),
  //             ),
  //             Column(
  //               children: [
  //                 CupertinoButton(
  //                     padding: EdgeInsets.zero,
  //                     child: Text('Edit Price'),
  //                     onPressed: () => _showPriceDialog(index)),
  //                 CupertinoButton(
  //                     padding: EdgeInsets.zero,
  //                     child: Text('Edit Duration'),
  //                     onPressed: () => _showGameRankPicker()),
  //               ],
  //             )
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildListItem(BoostGame item, int index) {
    return Column(
      children: [
        SizedBox(height: 20),
        _buildCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.rankFrom} ' +
                          G.current.boostTo +
                          ' ${item.upToRank}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(G.current.boostPrice +
                        '${item.estimateCost}' +
                        G.current.boostCoin),
                    SizedBox(height: 5),
                    Text(G.current.boostDuration +
                        ' - ${item.estimateDay} ${item.estimateDay > 0 ? "days" : "day"}, ${item.estimateHour} ${item.estimateHour > 0 ? "Hours" : "Hour"}'),
                  ],
                ),
              ),
              Column(
                children: [
                  CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(G.current.boostEditPrice),
                      onPressed: () => _showPriceDialog(index)),
                  CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(G.current.boostEditDuration),
                      onPressed: () => _showDurationPicker(index)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('${widget.data['game_name']}'),
          leading: IconButton(
              icon: Icon(CupertinoIcons.back),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            Container(
              key: intro.keys[5],
              child: CupertinoButton(
                child: Text(G.current.submit),
                onPressed: () {
                  this._bloc.submit();
                },
              ),
            )
          ],
          bottom: PreferredSize(
              child: Container(
                height: 10,
                color: Theme.of(context).accentColor,
              ),
              preferredSize: Size.fromHeight(10)),
        ),
        body: StreamBuilder<List<BoostGame>>(
            initialData: null,
            stream: this._bloc.gameListSubject,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return _loading;
              }
              // tuto = StorageManager.sharedPreferences.getBool(kNewToBoosting);
              print(tuto);
              if (tuto == null) {
                Timer(Duration(microseconds: 0), () {
                  intro.start(context);
                });
                StorageManager.sharedPreferences.setBool(kNewToBoosting, false);
              }
              return Column(
                children: [
                  _buildTitleWidget(title: G.current.boostFillYourThings),
                  Card(
                    margin: EdgeInsets.zero,
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    elevation: 8,
                    child: ListTile(
                      onTap: null,
                      title: Text(
                        G.current.alarmRatio,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      // key: intro.keys[0],
                      physics: ClampingScrollPhysics(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        BoostGame item = snapshot.data[index];
                        return _buildListItem(item, index);
                      },
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  _showPriceDialog(int index) async {
    final data = await this._bloc.gameListSubject.first;
    final controller =
        TextEditingController(text: data[index].estimateCost.toString());
    await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(G.current.boostEditPrice, textAlign: TextAlign.center),
            content: CupertinoTextField(
              autofocus: true,
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              controller: controller,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              CupertinoButton(
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  final current = List<BoostGame>.from(
                      await this._bloc.gameListSubject.first);
                  current[index].estimateCost =
                      int.tryParse(controller.text) ?? 0;
                  this._bloc.gameListSubject.add(current);
                  Navigator.pop(context);
                },
                child: Text(G.of(context).submit),
              )
            ],
          );
        });
  }

  _showDurationPicker(int index) async {
    final data = await this._bloc.gameListSubject.first;
    final days = data[index].estimateDay;
    final hours = data[index].estimateHour;
    Picker(
        selecteds: [days, hours],
        backgroundColor: Theme.of(context).backgroundColor,
        height: MediaQuery.of(context).size.height * 0.3,
        title: Text(G.current.boostDuration),
        selectedTextStyle: TextStyle(color: Theme.of(context).accentColor),
        adapter: PickerDataAdapter<String>(pickerdata: [
          List.generate(
              1000, (index) => '$index ${index > 0 ? "days" : "day"}'),
          List.generate(24, (index) => '$index ${index > 0 ? "hours" : "hour"}')
        ], isArray: true),
        delimiter: [
          PickerDelimiter(
              child: Container(
                  width: 30.0,
                  alignment: Alignment.center,
                  color: Theme.of(context).backgroundColor,
                  child: Text(' : ',
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold))))
        ],
        onCancel: () {
          debugPrint('Cancelling');
        },
        onConfirm: (picker, ints) {
          final newData = List<BoostGame>.from(data);
          newData[index].estimateDay = ints.first;
          newData[index].estimateHour = ints.last;
          this._bloc.gameListSubject.add(newData);
        }).showModal(this.context);
  }
}

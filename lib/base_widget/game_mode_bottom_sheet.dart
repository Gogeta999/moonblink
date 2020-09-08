import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/game_profile.dart';

class GameModeBottomSheet extends StatefulWidget {
  final List<GameMode> gameModeList;
  final List<int> selectedGameModeIndex;
  final Function(List<int> newSelectedGameModeIndex) onDone;

  const GameModeBottomSheet(
      {Key key,
      @required this.gameModeList,
      this.onDone,
      this.selectedGameModeIndex})
      : super(key: key);

  @override
  _GameModeBottomSheet createState() => _GameModeBottomSheet();
}

class _GameModeBottomSheet extends State<GameModeBottomSheet> {
  TextStyle _textStyle;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textStyle = Theme.of(context).textTheme.bodyText1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(G.of(context).cancel, style: _textStyle),
              ),
              FlatButton(
                onPressed: () {
                  widget.selectedGameModeIndex.sort((a, b) => a > b ? 1 : 0);
                  widget.onDone(widget.selectedGameModeIndex);
                  Navigator.pop(context);
                },
                child: Text('Done', style: _textStyle),
              ),
            ],
          ),
        ),
        Text('Select Game Modes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 20.0),
        Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4),
          child: ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: widget.gameModeList.length,
            itemBuilder: (context, index) {
              GameMode item = widget.gameModeList[index];
              bool isSelected = widget.selectedGameModeIndex.contains(item.id);
              return ListTile(
                title: Text(item.mode),
                onTap: () => onTapGameModeListTile(item.id, index, isSelected),
                trailing: Icon(
                  Icons.check,
                  color: isSelected
                      ? Theme.of(context).accentColor
                      : Colors.transparent,
                ),
                selected: isSelected,
              );
            },
          ),
        )
      ],
    );
  }

  onTapGameModeListTile(int id, int index, bool isSelected) {
    if (isSelected) {
      setState(() {
        widget.selectedGameModeIndex.remove(id);
        widget.gameModeList[index].selected = 0;
      });
    } else {
      setState(() {
        widget.selectedGameModeIndex.add(id);
        widget.gameModeList[index].selected = 1;
      });
    }
  }
}

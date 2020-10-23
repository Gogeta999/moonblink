import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';

class SystemDialog extends StatefulWidget {
  final String title;
  final String simpleContent;
  final String row1Content;
  final Widget row2Content;
  final String confirmContent;
  final Color confirmTextColor;
  final bool isCancel; //Having Cancel button or not,Default is true
  final Color confirmButtonColor;
  final Color cancelColor;
  final String cancelContent;
  final bool outsideDismiss; //点击弹窗外部，关闭弹窗，默认为true true：可以关闭 false：不可以关闭
  final Function confirmCallback; //点击确定按钮回调
  final Function dismissCallback; //弹窗关闭回调

  final String image;
  final String imageHintText;

  const SystemDialog(
      {Key key,
      this.title,
      this.simpleContent,
      this.row1Content,
      this.row2Content,
      this.confirmContent,
      this.confirmTextColor,
      this.isCancel = true,
      this.confirmButtonColor,
      this.cancelColor,
      this.cancelContent,
      this.outsideDismiss = true,
      this.confirmCallback,
      this.dismissCallback,
      this.image,
      this.imageHintText})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SystemDialogState();
  }
}

class _SystemDialogState extends State<SystemDialog> {
  _confirmDialog() {
    _dismissDialog();
    if (widget.confirmCallback != null) {
      widget.confirmCallback();
    }
  }

  _dismissDialog() {
    if (widget.dismissCallback != null) {
      widget.dismissCallback();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final theme = Theme.of(context).textTheme;

    Column _columnText = Column(
      children: <Widget>[
        SizedBox(height: widget.title == null ? 0 : 16.0),
        Expanded(
            flex: 1,
            child: Text(widget.title == null ? '' : widget.title,
                style: theme.headline5)),
        if (widget.simpleContent != null)
          Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Text(
                    widget.simpleContent == null ? '' : widget.simpleContent,
                    style: theme.bodyText2),
              ),
              flex: 2),
        // SizedBox(height: 1.0, child: Container(color: Colors.grey)),
        Divider(
          height: 1,
        ),
        Expanded(
            child: Container(
              child: FlatButton(
                onPressed: _confirmDialog,
                child: Text(
                    widget.confirmContent == null
                        ? G.current.confirm
                        : widget.confirmContent,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: widget.confirmButtonColor == null
                          ? Color(0xFFFFFFFF)
                          : widget.confirmButtonColor,
                    )),
              ),
            ),
            flex: 1),
        Divider(
          height: 1,
        ),
        Expanded(
            child: widget.isCancel
                ? Container(
                    child: RawMaterialButton(
                      child: Text(
                          widget.cancelContent == null
                              ? G.current.cancel
                              : widget.cancelContent,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: widget.cancelColor == null
                                ? Color(0xFFFFFFFF)
                                : widget.confirmButtonColor,
                          )),
                      onPressed: _dismissDialog,
                    ),
                  )
                : Text(''),
            flex: widget.isCancel ? 1 : 0),
      ],
    );

    Column _columnImage = Column(
      children: <Widget>[
        SizedBox(
          height: widget.imageHintText == null ? 35.0 : 23.0,
        ),
        Image(
            image: AssetImage(widget.image == null ? '' : widget.image),
            width: width - 170,
            height: 230),
        SizedBox(height: 10.0),
        Text(widget.imageHintText == null ? "" : widget.imageHintText,
            style: TextStyle(fontSize: 16.0)),
      ],
    );

    return WillPopScope(
        child: GestureDetector(
          onTap: () => {widget.outsideDismiss ? _dismissDialog() : null},
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                width: widget.image == null ? width - 100.0 : width - 150.0,
                height: 300.0,
                alignment: Alignment.center,
                child: widget.image == null ? _columnText : _columnImage,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ),
        ),
        onWillPop: () async {
          return widget.outsideDismiss;
        });
  }
}

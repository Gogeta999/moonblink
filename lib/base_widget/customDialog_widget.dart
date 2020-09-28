import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  final String title;
  final String simpleContent;
  final String row1Content;
  final Widget row2Content;
  final String confirmContent;
  final Color confirmTextColor;
  final bool isCancel; //Having Cancel button or not,Default is true
  final Color confirmButtonColor;
  final Color cancelColor;
  final bool outsideDismiss; //点击弹窗外部，关闭弹窗，默认为true true：可以关闭 false：不可以关闭
  final Function confirmCallback; //点击确定按钮回调
  final Function dismissCallback; //弹窗关闭回调

  final String image;
  final String imageHintText;

  const CustomDialog(
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
      this.outsideDismiss = true,
      this.confirmCallback,
      this.dismissCallback,
      this.image,
      this.imageHintText})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CustomDialogState();
  }
}

class _CustomDialogState extends State<CustomDialog> {
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

    Column _columnText = Column(
      children: <Widget>[
        SizedBox(height: widget.title == null ? 0 : 16.0),
        Text(widget.title == null ? '' : widget.title,
            style: TextStyle(fontSize: 16.0)),
        // SizedBox(height: 1.0, child: Container(color: Colors.grey)),
        if (widget.simpleContent != null)
          Expanded(
              child: Center(
                child: Text(
                    widget.simpleContent == null ? '' : widget.simpleContent,
                    style: TextStyle(fontSize: 14.0)),
              ),
              flex: 1),
        if (widget.row1Content != null)
          Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(widget.row1Content == null ? '' : widget.row1Content,
                      style: TextStyle(fontSize: 14.0)),
                  widget.row2Content == null ? '' : widget.row2Content,
                ],
              ),
              flex: 1),

        SizedBox(height: 1.0, child: Container(color: Colors.grey)),
        Container(
            height: 45,
            child: Row(
              children: <Widget>[
                Expanded(
                    child: widget.isCancel
                        ? Container(
                            decoration: BoxDecoration(
                                color: widget.cancelColor == null
                                    ? Color(0xFFFFFFFF)
                                    : widget.cancelColor,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12.0))),
                            child: FlatButton(
                              child: Text('Cancel',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: widget.cancelColor == null
                                        ? Colors.black87
                                        : Color(0xFFFFFFFF),
                                  )),
                              onPressed: _dismissDialog,
                              splashColor: widget.cancelColor == null
                                  ? Color(0xFFFFFFFF)
                                  : widget.cancelColor,
                              highlightColor: widget.cancelColor == null
                                  ? Color(0xFFFFFFFF)
                                  : widget.cancelColor,
                            ),
                          )
                        : Text(''),
                    flex: widget.isCancel ? 1 : 0),
                SizedBox(
                    width: widget.isCancel ? 1.0 : 0,
                    child: Container(color: Colors.grey)),
                Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: widget.confirmButtonColor == null
                              ? Color(0xFFFFFFFF)
                              : widget.confirmButtonColor,
                          borderRadius: widget.isCancel
                              ? BorderRadius.only(
                                  bottomRight: Radius.circular(12.0))
                              : BorderRadius.only(
                                  bottomLeft: Radius.circular(12.0),
                                  bottomRight: Radius.circular(12.0))),
                      child: FlatButton(
                        onPressed: _confirmDialog,
                        child: Text(
                            widget.confirmContent == null
                                ? '确定'
                                : widget.confirmContent,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: widget.confirmButtonColor == null
                                  ? (widget.confirmTextColor == null
                                      ? Colors.black87
                                      : widget.confirmTextColor)
                                  : Color(0xFFFFFFFF),
                            )),
                        splashColor: widget.confirmButtonColor == null
                            ? Color(0xFFFFFFFF)
                            : widget.confirmButtonColor,
                        highlightColor: widget.confirmButtonColor == null
                            ? Color(0xFFFFFFFF)
                            : widget.confirmButtonColor,
                      ),
                    ),
                    flex: 1),
              ],
            ))
      ],
    );

    Column _columnImage = Column(
      children: <Widget>[
        SizedBox(
          height: widget.imageHintText == null ? 35.0 : 23.0,
        ),
        Image(
            image: AssetImage(widget.image == null ? '' : widget.image),
            width: 72.0,
            height: 72.0),
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
                height: 150.0,
                alignment: Alignment.center,
                child: widget.image == null ? _columnText : _columnImage,
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
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

// Copyright (c) 2020 Ricky Wen
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/base_widget/customnavigationbar/src/animation/beacon_painter.dart';
import 'package:moonblink/base_widget/customnavigationbar/src/custom_navigation_bar_item.dart';
import 'util/default_style.dart';
import 'dart:math' as math;

class CustomNavigationBar extends StatefulWidget {
  ///
  /// create a [CustomNavigationBar]
  ///
  const CustomNavigationBar(
      {Key key,
      @required this.items,
      this.selectedColor,
      this.unSelectedColor,
      this.onTap,
      this.currentIndex = 0,
      this.iconSize = 24.0,
      this.scaleFactor = 0.2,
      this.elevation = 8.0,
      this.borderRadius = Radius.zero,
      this.backgroundColor = Colors.white,
      this.strokeColor = Colors.blueAccent,
      this.bubbleCurve = Curves.linear,
      this.scaleCurve = Curves.linear,
      this.isFloating = false})
      : assert(items != null),
        assert(scaleFactor <= 0.5, 'Scale factor must smaller than 0.5'),
        assert(scaleFactor > 0, 'Scale factor must bigger than 0'),
        assert(0 <= currentIndex && currentIndex < items.length),
        super(key: key);

  ///
  /// scale factor for the icon scale animation effect.
  /// default is 0.2.
  final double scaleFactor;

  ///
  /// boolean that control if navigation bar perform floating.
  /// default is false
  ///
  final bool isFloating;

  ///
  /// Border radius for naviagtion bar
  ///
  final Radius borderRadius;

  /// The z-coordinate of this [CustomNavigationBar].
  ///
  /// If null, defaults to `8.0`.
  final double elevation;

  ///
  /// Item data in [CustomNavigationBarItem]
  ///
  final List<CustomNavigationBarItem> items;

  ///
  /// [Color] when [CustomNavigationBarItem] is selected.
  ///
  /// default color is [blueAccent].
  final Color selectedColor;

  ///
  /// [Color] when [CustomNavigationBarItem] is not selected.
  ///
  /// default color is [grey[600]].
  final Color unSelectedColor;

  ///
  /// callback function when item tapped
  ///
  final Function(int) onTap;

  ///
  /// current index of navigation bar.
  ///
  final int currentIndex;

  ///
  /// size of icon.
  /// also represent the max radius of bubble effect animation.
  final double iconSize;

  ///
  /// Background color of [CustomNavigationBar]
  ///
  final Color backgroundColor;

  ///
  /// stroke color.
  /// default is [Colors.blueAccent].
  final Color strokeColor;

  ///
  /// animation curve of bubble effect
  ///
  final Curve bubbleCurve;

  ///
  /// animation curve of scale effect
  ///
  final Curve scaleCurve;

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar>
    with TickerProviderStateMixin {
  List<double> _radiuses;
  List<double> _sizes;
  AnimationController _controller;
  AnimationController _scaleController;

  double _bubbleRadius = 0.0;
  double _maxRadius;

  @override
  void initState() {
    super.initState();
    _bubbleRadius = 0.0;
    _radiuses = List<double>.generate(widget.items.length, (index) {
      return _bubbleRadius;
    });

    _sizes = List<double>.generate(widget.items.length, (index) {
      return 0.0;
    });
    _maxRadius = widget.iconSize;
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _startAnimation(widget.currentIndex);
      _startScale(widget.currentIndex);
    }
  }

  void _startAnimation(int index) {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    CurvedAnimation _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.bubbleCurve,
    );
    Tween<double>(begin: 0.0, end: 1.0).animate(_curvedAnimation)
      ..addListener(() {
        setState(() {
          _radiuses[index] = _maxRadius * _curvedAnimation.value;
        });
      });
    _controller.forward();
  }

  void _startScale(int index) {
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _scaleController.reverse();
        }
      });
    CurvedAnimation _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: widget.scaleCurve,
      reverseCurve: widget.scaleCurve.flipped,
    );

    Tween<double>(begin: 0.0, end: 1.0).animate(_scaleAnimation)
      ..addListener(() {
        setState(() {
          _sizes[index] = _scaleAnimation.value * widget.scaleFactor;
        });
      });
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding =
        math.max(MediaQuery.of(context).padding.bottom, 0.0);
    return Padding(
      padding: widget.isFloating
          ? EdgeInsets.only(
              left: 16, right: 16, top: 0, bottom: additionalBottomPadding)
          : EdgeInsets.zero,
      child: Material(
        elevation: widget.elevation,
        borderRadius: BorderRadius.vertical(
          top: widget.borderRadius,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: widget.borderRadius,
            ),
          ),
          height: DefaultCustomNavigationBarStyle.defaultHeight +
              (widget.isFloating ? 0.0 : additionalBottomPadding),
          width: MediaQuery.of(context).size.width,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  for (var i = 0; i < widget.items.length; i++)
                    CustomPaint(
                      painter: BeaconPainter(
                        color: widget.strokeColor,
                        beaconRadius: _radiuses[i],
                        maxRadius: _maxRadius,
                      ),
                      child: _CustomNavigationBarTile(
                        iconSize: widget.iconSize,
                        scale: _sizes[i],
                        onPressed: () {
                          widget.onTap(i);
                        },
                        selected: i == widget.currentIndex,
                        item: widget.items[i],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomNavigationBarTile extends StatelessWidget {
  const _CustomNavigationBarTile({
    Key key,
    this.onPressed,
    this.selected,
    this.item,
    this.scale,
    this.iconSize,
  }) : super(key: key);

  final VoidCallback onPressed;

  final bool selected;

  final CustomNavigationBarItem item;

  final double scale;

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.0 + scale,
      child: GestureDetector(
        child: SvgPicture.asset(
          selected ? item.selectedIcon : item.icon,
          color: selected
              ? Theme.of(context).accentColor
              : Theme.of(context).iconTheme.color,
          // semanticsLabel: 'home',
          fit: BoxFit.fill,
          width: selected ? 30 : 25,
          height: selected ? 45 : 25,
        ),
        onTap: onPressed,
        onDoubleTap: item.doubletap,
      ),
    );
  }
}

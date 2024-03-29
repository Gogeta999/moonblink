/*
 *  Copyright 2020 Chaobin Wu <chaobinwu89@gmail.com>
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

import 'package:flutter/cupertino.dart';

import '../convex_bar.dart';
import '../convex_interface.dart';
import '../convex_items.dart';
import 'fixed_circle_tab_style.dart';
import 'fixed_tab_style.dart';
import 'flip_tab_style.dart';
import 'react_circle_tab_style.dart';
import 'react_tab_style.dart';
import 'textin_tab_style.dart';
import 'titled_tab_style.dart';

/// Factory method to return the [DelegateBuilder] for each [TabStyle].
DelegateBuilder supportedStyle(
  TabStyle style, {
  @required List<TabItem> items,
  Color color,
  Color activeColor,
  Color backgroundColor,
  Curve curve,
  Function onDoubleTap,
}) {
  assert(items != null && items.isNotEmpty, 'items should not be empty');
  assert(
      ((style == TabStyle.fixed || style == TabStyle.fixedCircle) &&
              items.length.isOdd) ||
          (style != TabStyle.fixed && style != TabStyle.fixedCircle),
      'item count should be an odd number when using fixed/fixedCircle');
  DelegateBuilder builder;
  switch (style) {
    case TabStyle.fixed:
      builder = FixedTabStyle(
        items: items,
        color: color,
        activeColor: activeColor,
        convexIndex: items.length ~/ 2,
      );
      break;
    case TabStyle.fixedCircle:
      builder = FixedCircleTabStyle(
        onDoubleTap: onDoubleTap,
        items: items,
        color: color,
        activeColor: activeColor,
        backgroundColor: backgroundColor,
        convexIndex: items.length ~/ 2,
      );
      break;
    case TabStyle.react:
      builder = ReactTabStyle(
        items: items,
        color: color,
        activeColor: activeColor,
        curve: curve,
      );
      break;
    case TabStyle.reactCircle:
      builder = ReactCircleTabStyle(
        items: items,
        color: color,
        activeColor: activeColor,
        backgroundColor: backgroundColor,
        curve: curve,
      );
      break;
    case TabStyle.textIn:
      assert(items.every((it) => it.title != null && it.title.isNotEmpty),
          'title is necessary for TabStyle.textIn');
      builder = TextInTabStyle(
        items: items,
        color: color,
        activeColor: activeColor,
        curve: curve,
      );
      break;
    case TabStyle.titled:
      assert(items.every((it) => it.title != null && it.title.isNotEmpty),
          'title is necessary for TabStyle.titled');
      builder = TitledTabStyle(
        items: items,
        color: color,
        activeColor: activeColor,
        curve: curve,
        backgroundColor: backgroundColor,
      );
      break;
    case TabStyle.flip:
      builder = FlipTabStyle(
        items: items,
        color: color,
        activeColor: activeColor,
        curve: curve,
      );
      break;
    default:
      builder = ReactCircleTabStyle(
        items: items,
        color: color,
        activeColor: activeColor,
        backgroundColor: backgroundColor,
        curve: curve,
      );
      break;
  }
  return builder;
}

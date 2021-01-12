// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/generated/l10n.dart';

class VipDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(
        title: Text(G.current.vipDemo),
      ),
      body: Scrollbar(
        child: ListView(
          restorationId: 'list_demo_list_view',
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Center(
              child: Text(
                G.current.vipDemo3Title,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            for (int index = 1; index < 8; index++)
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Card(
                  child: ListTile(
                    leading: ExcludeSemantics(
                      child: CircleAvatar(child: Text('$index')),
                    ),
                    title: Text(
                      G.current.vipDemo3Body,
                    ),
                    subtitle: Text(''),
                  ),
                ),
              ),
            Center(
              child: Text(
                G.current.vipDemo2Title,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            for (int index = 8; index < 15; index++)
              Card(
                child: ListTile(
                  leading: ExcludeSemantics(
                    child: CircleAvatar(child: Text('$index')),
                  ),
                  title: Text(
                    G.current.vipDemo2Body,
                  ),
                  subtitle: Text(''),
                ),
              ),
            Center(
              child: Text(
                G.current.vipDemo1Title,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            for (int index = 15; index < 22; index++)
              Card(
                child: ListTile(
                  leading: ExcludeSemantics(
                    child: CircleAvatar(child: Text('$index')),
                  ),
                  title: Text(
                    G.current.vipDemo1Body,
                  ),
                  subtitle: Text(''),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

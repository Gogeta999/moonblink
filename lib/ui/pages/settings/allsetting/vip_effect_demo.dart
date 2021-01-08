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
            for (int index = 1; index < 8; index++)
              Card(
                child: ListTile(
                  leading: ExcludeSemantics(
                    child: CircleAvatar(child: Text('$index')),
                  ),
                  title: Text('VIP 3'),
                  subtitle: Text(''),
                ),
              ),
            for (int index = 8; index < 15; index++)
              Card(
                child: ListTile(
                  leading: ExcludeSemantics(
                    child: CircleAvatar(child: Text('$index')),
                  ),
                  title: Text('VIP 2'),
                  subtitle: Text(''),
                ),
              ),
            for (int index = 15; index < 22; index++)
              Card(
                child: ListTile(
                  leading: ExcludeSemantics(
                    child: CircleAvatar(child: Text('$index')),
                  ),
                  title: Text('VIP 1'),
                  subtitle: Text(''),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

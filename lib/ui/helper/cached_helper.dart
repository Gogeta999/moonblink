import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:oktoast/oktoast.dart';

// Widget _loader(BuildContext context, String url) {
//   return Container(
//       height: 200,
//       child: Stack(
//         children: <Widget>[
//           BlurHash(hash: 'L07-Zwofj[oft7fQj[fQayfQfQfQ'),
//           Center(
//             child: const Center(
//               child: CircularProgressIndicator(
//                   // valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
//                   ),
//             ),
//           ),
//         ],
//       ));
// }

class CachedLoader extends StatelessWidget {
  final double containerHeight;
  final double containerWidth;
  const CachedLoader({this.containerHeight, this.containerWidth});
  @override
  Widget build(BuildContext context) {
    return Container(
        height: containerHeight,
        child: Stack(
          children: <Widget>[
            BlurHash(hash: 'L07-Zwofj[oft7fQj[fQayfQfQfQ'),
            Center(
              child: const Center(
                child: CircularProgressIndicator(
                    // valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
              ),
            ),
          ],
        ));
  }
}

class CachedError extends StatelessWidget {
  final double containerHeight;
  final double containerWidth;
  final double iconSize;
  const CachedError(
      {this.containerHeight, this.containerWidth, this.iconSize = 10});
  @override
  Widget build(BuildContext context) {
    return Container(
        height: containerHeight,
        child: InkWell(
          child: const Center(
              child: Icon(
            Icons.refresh,
            size: 30,
          )),
          onTap: () {
            print('Refresh now');
            showToast('Something Wrong');
          },
        ));
  }
}

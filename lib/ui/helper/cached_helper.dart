import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
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
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        child: InkWell(
          child: const Center(child: Icon(Icons.error)),
          // onTap: () {
          //   print('');
          // },
        ));
  }
}

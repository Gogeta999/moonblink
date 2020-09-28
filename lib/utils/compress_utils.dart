import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class CompressUtils {
  // 2. compress file and get file.
  static Future<File> compressAndGetFile(File file, int compressQuality, int minWidth, int minHeight) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        await _getLocalFile().then((value) => value.path, onError: (e) => print(e.toString())),
        quality: compressQuality,
        minWidth: minWidth,
        minHeight: minHeight);

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  static Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final filePath =
        '$path/' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpeg';
    return File(filePath);
  }
}
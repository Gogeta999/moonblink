import 'package:encrypt/encrypt.dart' as encryptLib;
import 'package:moonblink/api/moonblink_dio.dart';

encrypt(int id) {
  // List confuseList = [
  //   '7',
  //   'm',
  //   '8',
  //   'o',
  //   '2',
  //   'o',
  //   '2',
  //   'n',
  //   '8',
  //   'g',
  //   '4',
  //   'o'
  // ];
  // confuseList.insert(3, id);
  // print(id.split(''));
  // List secondList = id.split('');
  // confuseList.insert(3, secondList[0]);
  // confuseList.insert(6, secondList[1]);
  // confuseList.insert(9, secondList[2]);

  final inputText = id.toString();
  final key = encryptLib.Key.fromUtf8('32lengthSecretKeyFormoongoAESsys');
  final iv = encryptLib.IV.fromUtf8('16IVforMoonGo782');

  final encrypter =
      encryptLib.Encrypter(encryptLib.AES(key, mode: encryptLib.AESMode.cbc));

  final encrypted = encrypter.encrypt(inputText, iv: iv);
  final decrypted = encrypter.decrypt(encrypted, iv: iv);

  if (isDev) print('Encrypted Code:' + encrypted.base64);
  if (isDev) print('Decrypted Code: ' + decrypted);
  if (isDev) print('Compare the layer of multiple 4: ' + id.toString());
  return encrypted.base64;
}

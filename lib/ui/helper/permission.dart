import 'package:permission_handler/permission_handler.dart';

Future<void> permission(context) async {
  await Permission.notification.request();
  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.storage.request();
}

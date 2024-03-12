
import 'package:permission_handler/permission_handler.dart';

import 'const/strings.dart';

checkPermission() async {
    final resp = await [Permission.camera, Permission.microphone].request();
    final cameraPermission = resp[Permission.camera];
    final microphonePermission = resp[Permission.microphone];

    if (cameraPermission != PermissionStatus.granted ||
        microphonePermission != PermissionStatus.granted) {
      throw Strings.PERMISSION_DENIED;
    }
  }
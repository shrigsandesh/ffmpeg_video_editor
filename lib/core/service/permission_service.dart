import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> storagePermission() async {
  final DeviceInfoPlugin info =
      DeviceInfoPlugin(); // import 'package:device_info_plus/device_info_plus.dart';
  final AndroidDeviceInfo androidInfo = await info.androidInfo;
  debugPrint('releaseVersion : ${androidInfo.version.release}');
  final int androidVersion = int.parse(androidInfo.version.release);
  bool havePermission = false;

  // Here you can use android api level
  // like android api level 33 = android 13
  // This way you can also find out how to request storage permission

  if (androidVersion >= 13) {
    final request = await [
      Permission.videos,
      Permission.photos,
    ].request();

    havePermission =
        request.values.every((status) => status == PermissionStatus.granted);
  } else {
    final status = await Permission.storage.request();
    havePermission = status.isGranted;
  }

  if (!havePermission) {
    // if no permission then open app-setting
    await openAppSettings();
  }

  return havePermission;
}

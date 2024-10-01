import 'dart:developer';

import 'package:flutter/services.dart';

Future<double> getVideoFps(String videoPath) async {
  const platform = MethodChannel('com.example.ffmpeg_video_editor/fps');
  try {
    final fps = await platform.invokeMethod('getFps', {'filePath': videoPath});
    return fps;
  } on PlatformException catch (e) {
    log("Failed to get FPS: '${e.message}'.");
    return 0;
  }
}

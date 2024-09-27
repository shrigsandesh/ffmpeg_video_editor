import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static Future<void> applyFilter(
      {required Function(String) onSuccess, String? inputPath}) async {
    // String inputFile = 'assets/sample.mp4';
    String inputFile = inputPath ?? await copyAssetToCache('assets/sample.mp4');

    final tempDir = await getTemporaryDirectory();
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final directory = Directory("${tempDir.path}/videos/$uniqueId/")
      ..create(recursive: true);
    final outputPath = "${directory.path}output.mp4";
    String ffmpegCommand =
        '-i $inputFile -vf "hue=s=0" $outputPath'; // Apply grayscale filter

    FFmpegKit.executeAsync(
      ffmpegCommand,
    ).then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        onSuccess(outputPath);
      } else if (ReturnCode.isCancel(returnCode)) {
        // CANCEL
      } else {
        // ERROR
        log("unable to apply filter");
        log("${await session.getOutput()}");
      }
    });
  }

  static Future<String> copyAssetToCache(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${(await getTemporaryDirectory()).path}sample.mp4');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  static Future<File?> selectVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      // User canceled the picker
      return null;
    }
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
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

  static Future<String> trimVideo(
      String inputPath, double startTrim, double endTrim) async {
    // Convert startTrim and endTrim into HH:MM:SS format (FFmpeg's required time format)
    String start = formatTime(startTrim.toInt());
    String end = formatTime(endTrim.toInt());

    final tempDir = await getTemporaryDirectory();
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final directory = Directory("${tempDir.path}/videos/$uniqueId/")
      ..create(recursive: true);
    final outputPath = "${directory.path}output.mp4";

    // FFmpeg command to trim the video from startTrim to endTrim
    String command = '-i $inputPath -ss $start -to $end -c copy $outputPath';

    // Execute the FFmpeg command
    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        log("Video trimmed successfully.");
      } else if (ReturnCode.isCancel(returnCode)) {
        log("FFmpeg operation cancelled.");
      } else {
        log("Error trimming video: $returnCode");
      }
    });
    return outputPath;
  }

  static Future<String> removeSectionFromVideo(
      {required String inputVideoPath,
      required double startA,
      required double endB}) async {
    // Get the directory to save the output video
    final tempDir = await getTemporaryDirectory();
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final directory = Directory("${tempDir.path}/videos/$uniqueId/")
      ..create(recursive: true);
    final beforePath = '${directory.path}before_A.mp4';
    final afterPath = '${directory.path}after_B.mp4';
    final outputPath = '${directory.path}final_output.mp4';
    void logStrings(String name, String text) {
      log("mylog: $name:   $text");
    }

    logStrings("beforePath", beforePath);
    logStrings("afterpath", afterPath);
    logStrings("outuptpath", outputPath);

    // Step 1: Extract part of the video before point A
    final beforeCommand =
        '-i "$inputVideoPath" -ss 0 -t $startA -c copy $beforePath';
    logStrings("beforeCommand", beforeCommand);
    await FFmpegKit.execute(beforeCommand).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        log('Segment before point A extracted successfully');
      } else {
        log('Error extracting before segment: ${await session.getAllLogsAsString()}');
      }
    });

    // Step 2: Extract part of the video after point B
    final afterCommand = '-i "$inputVideoPath" -ss $endB -c copy $afterPath';
    await FFmpegKit.execute(afterCommand).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        log('Segment after point B extracted successfully');
      } else {
        log('Error extracting after segment: ${await session.getAllLogsAsString()}');
      }
    });
    logStrings("afterCommand", afterCommand);

    // Step 3: Create a file list for concatenation
    final concatFile = File('${directory.path}concat_list.txt');
    log('Before Path Exists: ${File(beforePath).existsSync()}');
    log('After Path Exists: ${File(afterPath).existsSync()}');

    // Write both file paths into the concat file
    concatFile.writeAsStringSync("file '$beforePath'\nfile '$afterPath'\n");

    // Verify the content of the file list
    String writtenFiles = await concatFile.readAsString();
    log('Contents of concat_list.txt:\n$writtenFiles');

    // Step 4: Concatenate the two segments using the list
    // final concatCommand = '-f concat -i "${concatFile.path}" -c copy $outputPath';

    final concatCommand =
        '-f concat -safe 0 -i "${concatFile.path}" -c copy $outputPath';
    logStrings("concatcommand", concatCommand);

    await FFmpegKit.execute(concatCommand).then((session) async {
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogsAsString();

      if (ReturnCode.isSuccess(returnCode)) {
        log('Video segments joined successfully: $outputPath');
      } else {
        log('Error joining video segments: $logs');
      }
    });

    // Check if the final output video is created
    if (File(outputPath).existsSync()) {
      log('Final output video created successfully: $outputPath');
    } else {
      log('Final output video not created');
    }
    return outputPath;
  }

  static String formatTime(int timeInSeconds) {
    final hours = (timeInSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((timeInSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeInSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static Future<void> _printErrorLogs(FFmpegSession session) async {
    // Retrieve the session logs
    final logs = await session.getLogs();

    // Print each log entry (including error logs)
    for (var logs in logs) {
      log('FFmpeg Log: ${logs.getMessage()}');
    }

    // Retrieve and print statistics (optional)
    final statistics = await session.getStatistics();
    log('FFmpeg Statistics: ${statistics.toString()}');
  }

  static Future<String?> getVideoFPS(String videoPath) async {
    final command = '-i $videoPath -f null -';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      // Command executed successfully
      final output = await session.getOutput();
      // Parse the output to find the FPS
      final fpsRegex = RegExp(r'(\d+(\.\d+)?)\s*fps');

      if (output != null) {
        final match = fpsRegex.firstMatch(output);
        if (match != null) {
          final fps = match.group(1);
          log('FPS: $fps');
          return fps;
        }
      } else {
        log('FPS not found in the output.');
      }
    } else {
      log('Error executing FFmpeg command: $returnCode');
    }
    return null;
  }

  static Future<String> zoomVideo(String inputFilePath, int startFrame) async {
    log(startFrame.toString());
    final tempDir = await getTemporaryDirectory();
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final directory = Directory("${tempDir.path}/videos/$uniqueId/")
      ..create(recursive: true);
    final outputPath = "${directory.path}output.mp4";

    String command =
        '-i "$inputFilePath" -vf "scale=2*iw:-1,crop=iw/2:ih/2" "$outputPath"';
    final result = await FFmpegKit.execute(command);

    // Check the result
    final returnCode = await result.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      log("Zoom applied successfully and saved to $outputPath");
    } else {
      log("Error occurred: ${await result.getOutput()}");
    }
    return outputPath;
  }
}

Future<String> getOutputFilePath() async {
  final tempDir = await getTemporaryDirectory();
  final uniqueId = DateTime.now().millisecondsSinceEpoch;

  final directory = Directory("${tempDir.path}/videos/$uniqueId/")
    ..create(recursive: true);
  final outputPath = "${directory.path}output.mp4";
  return outputPath;
}

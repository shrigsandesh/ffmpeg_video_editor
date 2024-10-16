import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_video_editor/core/service/ffmpeg_service2.dart';
import 'package:ffmpeg_video_editor/core/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Detects the video orientation using FFmpeg metadata.
Future<bool> isLandScapeVideo(String videoPath) async {
  log(videoPath);
  final session = await FFprobeKit.getMediaInformation(videoPath);
  final mediaInfo = session.getMediaInformation();

  if (mediaInfo == null) {
    log('Failed to retrieve media information.');
    return false;
  }

  final rotationTag =
      mediaInfo.getStreams().first.getAllProperties()?['side_data_list'];

  if (rotationTag == null) {
    return true;
  } else {
    return false;
  }
}

/// Rotates the video to portrait if it’s in landscape mode.
Future<void> rotateToLandscape(
    String inputPath, void Function(String) output) async {
  String outputPath = await getOutputFilePath();

  final command =
      "-i $inputPath -vf 'scale=1080:1920, pad=1080:1920:(ow-iw)/2:(oh-ih)/2' $outputPath";
  // "-i $inputPath -vcodec h264 -s 1080x1920 -aspect 9:16 $outputPath";
  final session = await FFmpegKit.execute(command);
  final returnCode = await session.getReturnCode();

  if (!ReturnCode.isSuccess(returnCode)) {
    log('Failed to rotate video.');
  }
  if (ReturnCode.isSuccess(returnCode)) {
    log('rotation successful');
    output(outputPath);
  }
}

/// Joins multiple videos into one in landscape orientation.
Future<String?> joinVideos(List<File> videoPaths) async {
  FFmpegService fFmpegService = FFmpegService();

  // Step 1: Rotate all videos to landscape and store new paths
  final outputPath = await getOutputFilePath();
  final List<String> landscapePaths = [];
  for (var video in videoPaths) {
    await rotateToLandscape(
      video.path,
      (filePath) {
        landscapePaths.add(filePath);
      },
    );
  }

  final String inputFilePath =
      p.join((await getTemporaryDirectory()).path, 'input_list.txt');
  final inputFile = File(inputFilePath);

  // Write the file paths to the input list.
  final inputString = landscapePaths.map((file) => "file '$file'").join('\n');
  log(inputString);
  await inputFile.writeAsString(inputString);

  // Step 3: Use FFmpeg to join the videos
  final command =
      "-f concat -safe 0 -i '${inputFile.path}' -c copy $outputPath";
  fFmpegService.runFFmpegCommand(command, onSuccess: (msg) {
    log(msg);
    return outputPath;
  }, onFailure: (failure) {
    return null;
  });
  return outputPath;
}

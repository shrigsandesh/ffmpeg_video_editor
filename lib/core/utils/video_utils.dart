import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:ffmpeg_video_editor/core/service/ffmpeg_service.dart';
import 'package:ffmpeg_video_editor/core/utils/ffmpeg_commands.dart';
import 'package:ffmpeg_video_editor/core/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<String> trimVideo(
    String inputPath, double startTrim, double endTrim) async {
  // Convert startTrim and endTrim into HH:MM:SS format (FFmpeg's required time format)
  String start = formatTime(startTrim.toInt());
  String end = formatTime(endTrim.toInt());

  final outputPath = await getOutputFilePath();

  // FFmpeg command to trim the video from startTrim to endTrim
  String command = trimCommand(
      inputVideoPath: inputPath,
      outputVideoPath: outputPath,
      start: start,
      end: end);

  // Execute the FFmpeg command
  await FFmpegKit.execute(command).then((session) async {
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      log("Video trimmed successfully.");
    } else {
      log("Error trimming video: $returnCode");
    }
  });
  return outputPath;
}

Future<String> removeSectionFromVideo({
  required String inputVideoPath,
  required double startA,
  required double endB,
}) async {
  // Get the directory to save the output video
  final tempDir = await getTemporaryDirectory();
  final uniqueId = DateTime.now().millisecondsSinceEpoch;
  final directory = Directory("${tempDir.path}/videos/$uniqueId/")
    ..create(recursive: true);
  final beforePath = '${directory.path}before_A.mp4';
  final afterPath = '${directory.path}after_B.mp4';
  final outputPath = '${directory.path}final_output.mp4';

  // Get the duration of the input video
  double videoDuration = await FFMPEGService().getVideoDuration(inputVideoPath);

  // Flag to track if we need to concatenate parts
  bool hasBeforeSegment = startA > 0;
  bool hasAfterSegment = endB < videoDuration;

  // Step 1: Extract part of the video before point A, if applicable
  if (hasBeforeSegment) {
    final beforeCommand =
        '-i "$inputVideoPath" -ss 0 -t $startA -c copy $beforePath';

    await FFmpegKit.execute(beforeCommand).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        log('Segment before point A extracted successfully');
      } else {
        log('Error extracting before segment: ${await session.getAllLogsAsString()}');
      }
    });
  } else {
    log('No segment before point A to extract (A starts at 0 seconds)');
  }

  // Step 2: Extract part of the video after point B, if applicable
  if (hasAfterSegment) {
    final afterCommand = '-i "$inputVideoPath" -ss $endB -c copy $afterPath';
    await FFmpegKit.execute(afterCommand).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        log('Segment after point B extracted successfully');
      } else {
        log('Error extracting after segment: ${await session.getAllLogsAsString()}');
      }
    });
  } else {
    log('No segment after point B to extract (B ends at video duration)');
  }

  // Step 3: Create a file list for concatenation
  final concatFile = File('${directory.path}concat_list.txt');

  // Write file paths into the concat file based on the presence of segments
  if (hasBeforeSegment && hasAfterSegment) {
    concatFile.writeAsStringSync("file '$beforePath'\nfile '$afterPath'\n");
  } else if (hasBeforeSegment) {
    concatFile.writeAsStringSync("file '$beforePath'\n");
  } else if (hasAfterSegment) {
    concatFile.writeAsStringSync("file '$afterPath'\n");
  } else {
    log('No segments to concatenate');
    return ''; // Return empty if there's nothing to concatenate
  }

  // Verify the content of the file list
  String writtenFiles = await concatFile.readAsString();
  log('Contents of concat_list.txt:\n$writtenFiles');

  // Step 4: Concatenate the two segments using the list if there are multiple parts
  final concatCommand =
      '-f concat -safe 0 -i "${concatFile.path}" -c copy $outputPath';

  await FFmpegKit.execute(concatCommand).then((session) async {
    final returnCode = await session.getReturnCode();
    final logs = await session.getAllLogsAsString();

    if (ReturnCode.isSuccess(returnCode)) {
      log('Video segments joined successfully: $outputPath');
    } else {
      log('Error joining video segments: $logs');
    }
  });
  if (concatFile.existsSync()) {
    await deleteTemporaryFile(concatFile.path);
  }

  // Check if the final output video is created
  if (File(outputPath).existsSync()) {
    log('Final output video created successfully: $outputPath');
  } else {
    log('Final output video not created');
  }
  return outputPath;
}

Future<void> addSubtitlesToVideo(String videoPath) async {
  File subtitle = await loadSrtFromAssets('assets/subtitles.srt');
  String subtitlePath = subtitle.path;
  String outputPath = await getOutputFilePath();
  final command = '-i "$videoPath" -vf subtitles="$subtitlePath" "$outputPath"';

  // Execute the ffmpeg command
  await FFmpegKit.execute(command).then((session) async {
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      log('Subtitles added successfully');
    } else {
      log('Error adding subtitles');
    }
  });
}

Future<File?> joinVideos(List<File> videoFiles) async {
  if (videoFiles.isEmpty) {
    throw ArgumentError('No video files provided.');
  }

  // Step 1: Prepare temporary directory for scaled videos
  final tempDir = await getTemporaryDirectory();
  final scaledVideos = <File>[];

  // Step 2: Scale each video and store in temporary directory
  for (var i = 0; i < videoFiles.length; i++) {
    final inputPath = videoFiles[i].path;
    final scaledVideoPath = p.join(tempDir.path, 'scaled_video_$i.mp4');
    if (inputPath.endsWith('.jpg') || inputPath.endsWith('.png')) {
      final String command =
          '-loop 1 -i $inputPath -t 1 -vf "scale=720:1080" -pix_fmt yuv420p -preset ultrafast $scaledVideoPath';
      await FFMPEGService().runSyncFFmpegCommand(command);
    } else {
      final String scaleCommand =
          '-i $inputPath -vf "scale=720:1280:force_original_aspect_ratio=decrease,pad=720:1280:-1:-1:color=black" -preset ultrafast $scaledVideoPath';

      await FFMPEGService().runSyncFFmpegCommand(scaleCommand);
    }

    final scaledVideo = File(scaledVideoPath);
    if (await scaledVideo.exists()) {
      scaledVideos.add(scaledVideo);
    } else {
      log("Failed to scale video: $inputPath");
      continue;
    }
  }

  // Step 3: Create input list for FFmpeg
  final String inputListPath = p.join(tempDir.path, 'input_list.txt');
  final inputListFile = File(inputListPath);
  final inputString =
      scaledVideos.map((file) => "file '${file.path}'").join('\n');
  await inputListFile.writeAsString(inputString);

  log("Input list:\n$inputString");
  log(scaledVideos.toList().toString());

  // Step 4: Join scaled videos
  final String outputPath = await getOutputFilePath();
  final String ffmpegCommand = joinCommand(
    inputfilesPath: inputListFile.path,
    outputVideoPath: outputPath,
  );

  await FFMPEGService().runSyncFFmpegCommand(ffmpegCommand);

  // Step 5: Verify and return the final output video
  final outputFile = File(outputPath);
  if (await outputFile.exists()) {
    return outputFile;
  } else {
    log("Something went wrong during video joining.");
    return null;
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:photo_manager/photo_manager.dart';

Future<void> applyFilter(
    {required Function(String) onSuccess, required String inputPath}) async {
  final outputPath = await getOutputFilePath();
  String ffmpegCommand =
      '-i $inputPath -vf "hue=s=0" $outputPath'; // Apply grayscale filter

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
    }
  });
}

Future<String> copyAssetToCache(String assetPath) async {
  final byteData = await rootBundle.load(assetPath);
  final file = File('${(await getTemporaryDirectory()).path}sample.mp4');
  await file.writeAsBytes(byteData.buffer.asUint8List());
  return file.path;
}

Future<List<File>?> selectVideo() async {
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.video, allowMultiple: true);

  if (result != null) {
    final paths = result.files.map((e) => e.path).toList();
    final files = List.generate(paths.length, (index) => File(paths[index]!));
    return files;
  } else {
    // User canceled the picker
    return null;
  }
}

Future<String> trimVideo(
    String inputPath, double startTrim, double endTrim) async {
  // Convert startTrim and endTrim into HH:MM:SS format (FFmpeg's required time format)
  String start = formatTime(startTrim.toInt());
  String end = formatTime(endTrim.toInt());

  final outputPath = await getOutputFilePath();

  // FFmpeg command to trim the video from startTrim to endTrim
  String command = '-i $inputPath -ss $start -to $end -c copy $outputPath';

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
  double videoDuration = await _getVideoDuration(inputVideoPath);

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

  // Check if the final output video is created
  if (File(outputPath).existsSync()) {
    log('Final output video created successfully: $outputPath');
  } else {
    log('Final output video not created');
  }
  return outputPath;
}

// Helper function to get the duration of the video
Future<double> _getVideoDuration(String videoPath) async {
  final session = await FFprobeKit.getMediaInformation(videoPath);
  final info = session.getMediaInformation();
  if (info != null) {
    final durationStr = info.getDuration();
    return double.parse(durationStr ?? '0');
  }
  return 0;
}

String formatTime(int timeInSeconds) {
  final hours = (timeInSeconds ~/ 3600).toString().padLeft(2, '0');
  final minutes = ((timeInSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final seconds = (timeInSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

Future<String?> getVideoFPS(String videoPath) async {
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

Future<String> zoomVideo(String inputFilePath, int startFrame) async {
  final outputPath = await getOutputFilePath();

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

Future<String> getOutputFilePath() async {
  final tempDir = await getTemporaryDirectory();
  final uniqueId = DateTime.now().millisecondsSinceEpoch;

  final directory = Directory("${tempDir.path}/videos/$uniqueId/")
    ..create(recursive: true);
  final outputPath = "${directory.path}output.mp4";
  return outputPath;
}

Future<File> loadSrtFromAssets(String assetPath) async {
  // Load the .srt file as a string
  final bytes = await rootBundle.load(assetPath);
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/subtitles.srt');
  await tempFile.writeAsBytes(bytes.buffer.asUint8List());
  return tempFile;
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

  // Get a temporary directory for storing the output file.
  final Directory tempDir = await getTemporaryDirectory();
  final String outputPath = p.join(tempDir.path, 'output_video.mp4');

  // Create a file list in the format required by ffmpeg.
  final String inputFilePath = p.join(tempDir.path, 'input_list.txt');
  final inputFile = File(inputFilePath);

  // Write the file paths to the input list.
  final inputString =
      videoFiles.map((file) => "file '${file.path}'").join('\n');
  await inputFile.writeAsString(inputString);

  // ffmpeg command to join the video files.
  final String ffmpegCommand =
      "-f concat -safe 0 -i ${inputFile.path} -c copy $outputPath";

  // Execute the ffmpeg command.
  await FFmpegKit.execute(ffmpegCommand);

  // Check if the output file was created.
  final outputFile = File(outputPath);
  if (await outputFile.exists()) {
    return outputFile;
  } else {
    return null; // Return null if something went wrong.
  }
}

Future<String?> mergeVideos(List<AssetEntity> pickedVideos) async {
  List<String> videoPaths = [];
  for (AssetEntity video in pickedVideos) {
    // Retrieve the File for each video
    File? videoFile = await video.file;
    if (videoFile != null) {
      videoPaths.add(videoFile.path); // Add the file path to the list
    }
  }
  String outputPath = await getOutputFilePath();
  String concatCommand = "concat:${videoPaths.join('|')}";
  String command = "-i \"$concatCommand\" -c copy $outputPath";

  await FFmpegKit.execute(command).then((session) async {
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      log('Merge successful');
      return outputPath;
    } else {
      log('Merge failed');
      return null;
    }
  });
  return null;
}

Future<List<File>> getVideoFiles(List<AssetEntity> pickedVideos) async {
  List<File> files = [];
  for (AssetEntity video in pickedVideos) {
    // Retrieve the File for each video
    File? videoFile = await video.file;
    if (videoFile != null) {
      files.add(videoFile); // Add the file to the list
    }
  }
  return files;
}

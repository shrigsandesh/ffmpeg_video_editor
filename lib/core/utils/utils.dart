import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

String formatTime(int timeInSeconds) {
  final minutes = ((timeInSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final seconds = (timeInSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

Future<String> getOutputFilePath() async {
  try {
    final tempDir = await getTemporaryDirectory();
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final directoryPath = "${tempDir.path}/videos/$uniqueId/";

    // Delete existing directory if it exists
    await _deleteIfExists(directoryPath);

    // Create the new directory
    final directory = await Directory(directoryPath).create(recursive: true);

    return "${directory.path}output.mp4";
  } catch (e) {
    log("Error creating temporary path for video: $e");
    return ''; // Return empty string in case of failure
  }
}

Future<void> _deleteIfExists(String path) async {
  final dir = Directory(path);
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
}

Future<File> loadSrtFromAssets(String assetPath) async {
  // Load the .srt file as a string
  final bytes = await rootBundle.load(assetPath);
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/subtitles.srt');
  await tempFile.writeAsBytes(bytes.buffer.asUint8List());
  return tempFile;
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

Future<void> deleteTemporaryFile(String filePath) async {
  try {
    await File(filePath).delete();
    // Delete the entire directory
    await Directory(filePath).delete(recursive: true);
  } catch (_) {}
}

Future<String> getFontPath() async {
  final directory = await getApplicationDocumentsDirectory();
  final fontFile = File('${directory.path}/Roboto-Regular.ttf');

  // Copy the font from assets to the file system if it doesn't exist.
  if (!fontFile.existsSync()) {
    final byteData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    await fontFile.writeAsBytes(byteData.buffer.asUint8List());
  }
  return fontFile.path;
}

Future<String> getWatermarkPath() async {
  final directory = await getApplicationDocumentsDirectory();
  final watermarkFile = File('${directory.path}/watermark.png');

  // Copy the image from assets to the file system if it doesn't exist.
  if (!watermarkFile.existsSync()) {
    final byteData = await rootBundle.load('assets/images/logo.png');
    await watermarkFile.writeAsBytes(byteData.buffer.asUint8List());
  }
  return watermarkFile.path;
}

Future<List<File>> generateThumbnails(
    int videoDurationInSec, String videoPath) async {
  List<File> thumbnails = [];
  for (int i = 0; i < videoDurationInSec; i++) {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: "${(await getTemporaryDirectory()).path}/sample$i.png",
      imageFormat: ImageFormat.PNG,
      quality: 100,
      maxWidth: 50, // Thumbnail width size
      timeMs: i * 1000, // Generate at every second
    );

    if (thumbnailPath != null) {
      thumbnails.add(File(thumbnailPath)); // Add thumbnail file to list
    }
  }
  return thumbnails;
}

String formatter(Duration duration) => [
      duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
      duration.inSeconds.remainder(60).toString().padLeft(2, '0')
    ].join(":");

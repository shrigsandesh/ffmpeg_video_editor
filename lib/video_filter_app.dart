// import 'dart:developer';
// import 'dart:io';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:video_player/video_player.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:path_provider/path_provider.dart';

// class VideoFilterApp extends StatefulWidget {
//   const VideoFilterApp({super.key});

//   @override
//   State<VideoFilterApp> createState() => _VideoFilterAppState();
// }

// class _VideoFilterAppState extends State<VideoFilterApp> {
//   VideoPlayerController? _controller;
//   String? _filteredVideoPath;

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   Future<String> copyAssetToCache(String assetPath) async {
//     final byteData = await rootBundle.load(assetPath);
//     final file = File('${(await getTemporaryDirectory()).path}sample.mp4');
//     await file.writeAsBytes(byteData.buffer.asUint8List());
//     return file.path;
//   }

//   Future<void> _loadVideo() async {
//     // Load a video from assets or gallery
//     String videoPath = 'assets/sample.mp4'; // Replace with your video path

//     _controller = VideoPlayerController.asset(videoPath);
//     await _controller?.initialize();
//     setState(() {});
//     _controller?.play();
//   }

//   Future<void> _applyFilter() async {
//     // String inputFile = 'assets/sample.mp4';
//     String inputFile = await copyAssetToCache('assets/sample.mp4');

//     final tempDir = await getTemporaryDirectory();
//     final uniqueId = DateTime.now().millisecondsSinceEpoch;
//     final directory = Directory("${tempDir.path}/videos/$uniqueId/")
//       ..create(recursive: true);
//     final outputPath = "${directory.path}output.mp4";
//     String ffmpegCommand =
//         '-i $inputFile -vf "hue=s=0" $outputPath'; // Apply grayscale filter

//     FFmpegKit.execute(ffmpegCommand).then((session) async {
//       final returnCode = await session.getReturnCode();
//       final state =
//           FFmpegKitConfig.sessionStateToString(await session.getState());
//       if (ReturnCode.isSuccess(returnCode)) {
//         // SUCCESS
//         _filteredVideoPath = outputPath;
//         _playFilteredVideo();

//         setState(() {});
//       } else if (ReturnCode.isCancel(returnCode)) {
//         // CANCEL
//         log("cancel message");
//       } else {
//         // ERROR
//         log("unable to apply filter $state");
//         log("${await session.getOutput()}");
//       }
//     });
//   }

//   Future<void> _playFilteredVideo() async {
//     _controller?.dispose();
//     _controller = VideoPlayerController.file(File(_filteredVideoPath!));
//     await _controller?.initialize();
//     setState(() {});
//     _controller?.play();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('FFmpeg Filter App')),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           _controller != null && _controller!.value.isInitialized
//               ? AspectRatio(
//                   aspectRatio: _controller!.value.aspectRatio,
//                   child: VideoPlayer(_controller!),
//                 )
//               : const Text('No video loaded'),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _loadVideo,
//             child: const Text('Load Video'),
//           ),
//           ElevatedButton(
//             onPressed: _applyFilter,
//             child: const Text('Apply Grayscale Filter'),
//           ),
//         ],
//       ),
//       floatingActionButton: _controller != null
//           ? FloatingActionButton(
//               onPressed: () {
//                 setState(() {
//                   _controller!.value.isPlaying
//                       ? _controller?.pause()
//                       : _controller?.play();
//                 });
//               },
//               child: Icon(_controller!.value.isPlaying
//                   ? Icons.pause
//                   : Icons.play_arrow),
//             )
//           : null,
//     );
//   }
// }

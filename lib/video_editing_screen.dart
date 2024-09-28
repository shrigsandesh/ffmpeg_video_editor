import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_video_editor/service/ffmpeg_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

class VideoEditingScreen extends StatefulWidget {
  const VideoEditingScreen({super.key, required this.path});

  final String path;

  @override
  State<VideoEditingScreen> createState() => _VideoEditingScreenState();
}

class _VideoEditingScreenState extends State<VideoEditingScreen> {
  VideoPlayerController? _controller;
  late final VideoEditorController _editorController =
      VideoEditorController.file(
    File(widget.path),
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 60),
  );

  // ignore: unused_field
  String? _filteredVideoPath;
  bool isFiltering = false;
  double progress = 0.0;
  @override
  void initState() {
    super.initState();
    _loadVideo();
    _editorController.initialize().then((_) => setState(() {}));
  }

  double getFFmpegProgress(int time) {
    log(_controller!.value.position.inMilliseconds.toString());
    final double progressValue =
        time / _controller!.value.position.inMilliseconds;
    return progressValue.clamp(0.0, 1.0);
  }

  Future<void> _applyFilter() async {
    setState(() {
      isFiltering = true;
    });
    String inputFile = widget.path;

    final tempDir = await getTemporaryDirectory();
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final directory = Directory("${tempDir.path}/videos/$uniqueId/")
      ..create(recursive: true);
    final outputPath = "${directory.path}output.mp4";
    String ffmpegCommand = '-i $inputFile -vf "hue=s=0" $outputPath';

    await FFMPEGService().runFFmpegCommand(
      ffmpegCommand,
      onProgress: (stats) {
        if (context.mounted) {
          setState(() {
            progress =
                (stats.getTime() / _controller!.value.duration.inMilliseconds) *
                    100;
            log("Stat get time: ${stats.getTime()}");
          });
          log("FFMPEG Trimming Progress: $progress");
        }
      },
      onError: (e, s) {
        setState(() {
          isFiltering = false;
          progress = 0.0;
        });
        log("here is error");
      },
      onCompleted: (code) async {
        // final videoMetaData = await get<MediaMetaService>()
        //     .extractVideoMetaData(widget.file.path);
        setState(() {
          isFiltering = false;
          progress = 0.0;
        });
        _playFilteredVideo(outputPath);

        if (!mounted) return;
      },
    );
  }

  Future<void> _loadVideo() async {
    _controller = VideoPlayerController.file(File(widget.path));
    await _controller?.initialize();
    setState(() {});
    _controller?.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: const Text(
          "Editor video",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _controller != null
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * .66,
                  child: VideoPlayer(
                    _controller!,
                  ),
                )
              : const Center(child: Text("Error playing video")),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: TrimSlider(
              controller: _editorController,
              height: 60,
              horizontalMargin: 20,
              child: TrimTimeline(
                controller: _editorController,
                padding: const EdgeInsets.only(top: 10),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isFiltering
              ? LinearPercentIndicator(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  lineHeight: 45,
                  alignment: MainAxisAlignment.center,
                  percent: progress / 100,
                  center: Text(
                    "Applying filter.. ${progress.truncate()}%",
                  ),
                  barRadius: const Radius.circular(32),
                  backgroundColor: Colors.blue,
                  linearGradient: const LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.green,
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () async {
                          _applyFilter();
                        },
                        child: const Icon(
                          Icons.tune,
                          color: Colors.white,
                        ))
                  ],
                ),
        ),
      ),
    );
  }

  void _playFilteredVideo(String path) async {
    _controller?.dispose();
    _filteredVideoPath = path;
    setState(() {});
    _controller = VideoPlayerController.file(File(path));
    await _controller?.initialize();

    _controller?.play();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _editorController.dispose();
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_video_editor/core/service/ffmpeg_service.dart';
import 'package:ffmpeg_video_editor/core/utils/utils.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/editing_options.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/export_loading.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/trimmer_timeline.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

class VideoEditingScreen extends StatefulWidget {
  const VideoEditingScreen({super.key, required this.path});

  final String path;

  @override
  State<VideoEditingScreen> createState() => _VideoEditingScreenState();
}

class _VideoEditingScreenState extends State<VideoEditingScreen> {
  VideoEditorController? _editorController;

  bool isFiltering = false;
  double progress = 0.0;
  late String _currentVideoPath;

  String _videoSize = '';
  @override
  void initState() {
    super.initState();
    _currentVideoPath = widget.path;
    _loadVideo();
  }

  double getFFmpegProgress(int time) {
    final double progressValue =
        time / _editorController!.video.value.position.inMilliseconds;
    return progressValue.clamp(0.0, 1.0);
  }

  Future<void> _applyFilter() async {
    setState(() {
      isFiltering = true;
    });
    String inputFile = _currentVideoPath;

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
            progress = (stats.getTime() /
                    _editorController!.video.value.duration.inMilliseconds) *
                100;
          });
        }
      },
      onError: (e, s) {
        setState(() {
          isFiltering = false;
          progress = 0.0;
        });
        log("Unable to apply filter");
      },
      onCompleted: (code) async {
        setState(() {
          isFiltering = false;
          progress = 0.0;
          _currentVideoPath = outputPath;
        });
        _playFilteredVideo(outputPath);
      },
    );
  }

  Future<void> _loadVideo() async {
    _editorController = VideoEditorController.file(
      File(_currentVideoPath),
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 60),
    );
    await _editorController?.initialize().then((_) => setState(() {}));

    _editorController?.video.play();
    _getVideoSize(_currentVideoPath);
  }

  Future<void> _getVideoSize(String path) async {
    // Create a File instance and get its size
    final file = File(path);
    final sizeInBytes = await file.length();

    // Convert bytes to a readable format (e.g., MB)
    setState(() {
      _videoSize =
          '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB'; // Convert bytes to MB
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Edit video",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _editorController?.video.value.isInitialized == true
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .66,
                        child: AspectRatio(
                          aspectRatio:
                              _editorController!.video.value.aspectRatio,
                          child: VideoPlayer(
                            _editorController!.video,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        "Size: $_videoSize",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (!isFiltering)
                      IconButton.outlined(
                        onPressed: () {
                          _editorController!.video.value.isPlaying
                              ? _editorController?.video.pause()
                              : _editorController?.video.play();
                        },
                        icon: Icon(_editorController!.video.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow),
                        color: Colors.white,
                      ),
                    isFiltering
                        ? ExportLoading(progress: progress)
                        : const SizedBox.shrink()
                  ],
                )
              : const Center(child: Text("Error playing video")),
          if (_editorController != null)
            TrimmerTimeline(controller: _editorController!),
        ],
      ),
      bottomSheet: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: EditingOptions(
              onfilter: _applyFilter,
              onTrimAndSave: () async {
                _editorController?.video.pause();
                final startTrim = _editorController!.minTrim *
                    _editorController!.video.value.duration.inSeconds;
                final endTrim = _editorController!.maxTrim *
                    _editorController!.video.value.duration.inSeconds;
                var outputPath = await Utils.trimVideo(
                    _currentVideoPath, startTrim, endTrim);
                setState(() {
                  _currentVideoPath = outputPath;
                });
                _playFilteredVideo(outputPath);
                _editorController?.video.play();
              },
              onDeleteSection: () async {
                _editorController?.video.pause();
                final startTrim = _editorController!.minTrim *
                    _editorController!.video.value.duration.inSeconds;
                final endTrim = _editorController!.maxTrim *
                    _editorController!.video.value.duration.inSeconds;

                var outputPath = await Utils.removeSectionFromVideo(
                    inputVideoPath: _currentVideoPath,
                    startA: startTrim,
                    endB: endTrim);
                setState(() {
                  _currentVideoPath = outputPath;
                });

                _playFilteredVideo(outputPath);
              }),
        ),
      ),
    );
  }

  void _playFilteredVideo(String path) async {
    if (_editorController != null) _editorController!.dispose();
    _editorController = VideoEditorController.file(File(path),
        minDuration: const Duration(seconds: 0),
        maxDuration: const Duration(seconds: 60))
      ..initialize().then((_) {
        setState(() {});
      });
    _getVideoSize(_currentVideoPath);

    _editorController?.video.play();
  }

  @override
  void dispose() {
    super.dispose();
    _editorController?.dispose();
  }
}

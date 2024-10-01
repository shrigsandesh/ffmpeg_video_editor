import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_video_editor/core/service/ffmpeg_service.dart';
import 'package:ffmpeg_video_editor/core/utils/utils.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/editing_options.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/export_loading.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/rotate_widget.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/trimmer_timeline.dart';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

class VideoEditingScreen extends StatefulWidget {
  const VideoEditingScreen({super.key, required this.path});
  final String path;

  @override
  State<VideoEditingScreen> createState() => _VideoEditingScreenState();
}

class _VideoEditingScreenState extends State<VideoEditingScreen> {
  late VideoEditorController _editorController;
  late String _currentVideoPath;
  String _videoSize = '';
  bool isProcessing = false;
  double progress = 0.0;
  String fps = '';

  @override
  void initState() {
    super.initState();
    _currentVideoPath = widget.path;
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    _editorController = VideoEditorController.file(
      File(_currentVideoPath),
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 60),
    );
    await _editorController.initialize();
    setState(() {});
    _editorController.video.play();
    _getVideoSize();
    fps = await getVideoFPS(_currentVideoPath) ?? "Err";
    setState(() {});
  }

  Future<void> _getVideoSize() async {
    final sizeInBytes = await File(_currentVideoPath).length();
    setState(() {
      _videoSize = '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    });
  }

  Future<void> _runFFmpegCommand(String command,
      {required String outputPath}) async {
    setState(() => isProcessing = true);
    await FFMPEGService().runFFmpegCommand(
      command,
      onProgress: (stats) {
        if (mounted) {
          setState(() {
            progress = (stats.getTime() /
                    _editorController.video.value.duration.inMilliseconds) *
                100;
          });
        }
      },
      onError: (e, s) {
        log(e.toString());
        log(s.toString());
        setState(() {
          isProcessing = false;
          progress = 0.0;
        });
      },
      onCompleted: (_) {
        setState(() {
          isProcessing = false;
          progress = 0.0;
          _currentVideoPath = outputPath;
        });
        _playVideo(outputPath);
      },
    );
  }

  Future<void> _playVideo(String path) async {
    _editorController.dispose();
    _editorController = VideoEditorController.file(
      File(path),
      minDuration: const Duration(seconds: 0),
      maxDuration: const Duration(seconds: 60),
    );
    await _editorController.initialize();
    setState(() {});
    _getVideoSize();
    _editorController.video.play();
  }

  Future<void> _applyFilter() async {
    final outputPath = await getOutputFilePath();
    final ffmpegCommand = '-i $_currentVideoPath -vf "hue=s=0" $outputPath';
    await _runFFmpegCommand(ffmpegCommand, outputPath: outputPath);
  }

  Future<void> _trimAndSave() async {
    _editorController.video.pause();
    final startTrim = _editorController.minTrim *
        _editorController.video.value.duration.inSeconds;
    final endTrim = _editorController.maxTrim *
        _editorController.video.value.duration.inSeconds;
    final outputPath = await trimVideo(_currentVideoPath, startTrim, endTrim);

    setState(() => _currentVideoPath = outputPath);
    _playVideo(outputPath);
  }

  Future<void> _deleteSection() async {
    _editorController.video.pause();
    final startTrim = _editorController.minTrim *
        _editorController.video.value.duration.inSeconds;
    final endTrim = _editorController.maxTrim *
        _editorController.video.value.duration.inSeconds;
    final outputPath = await removeSectionFromVideo(
      inputVideoPath: _currentVideoPath,
      startA: startTrim,
      endB: endTrim,
    );

    setState(() => _currentVideoPath = outputPath);
    _playVideo(outputPath);
  }

  Future<void> _zoomIntoVideo() async {
    if (isProcessing) return;
    final outputPath = await getOutputFilePath();
    final ffmpegCommand =
        '-i $_currentVideoPath -vf "scale=2*iw:-1,crop=iw/2:ih/2" $outputPath';
    await _runFFmpegCommand(ffmpegCommand, outputPath: outputPath);
  }

  Future<void> _onRotate({bool toLeft = true}) async {
    if (isProcessing) return;
    final outputPath = await getOutputFilePath();
    final transpose = toLeft ? "transpose=2" : "transpose=1";
    final ffmpegCommand = '-i $_currentVideoPath -vf "$transpose" $outputPath';
    await _runFFmpegCommand(ffmpegCommand, outputPath: outputPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Edit Video", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          if (_editorController.video.value.isInitialized) ...[
            RotateWidget(
              onRotateLeft: _onRotate,
              onRotateRight: () => _onRotate(toLeft: false),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * .5,
                    child: AspectRatio(
                      aspectRatio: _editorController.video.value.aspectRatio,
                      child: VideoPlayer(_editorController.video),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    "Size: $_videoSize\n fps: $fps",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!isProcessing)
                  IconButton.outlined(
                    onPressed: () {
                      _editorController.video.value.isPlaying
                          ? _editorController.video.pause()
                          : _editorController.video.play();
                    },
                    icon: Icon(_editorController.video.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    color: Colors.white,
                  ),
                if (isProcessing) ExportLoading(progress: progress),
              ],
            ),
            TrimmerTimeline(controller: _editorController),
          ] else
            const Center(
              child: Text("Error playing video",
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(8.0),
        child: EditingOptions(
          onfilter: _applyFilter,
          onTrimAndSave: _trimAndSave,
          onDeleteSection: _deleteSection,
          onZoom: _zoomIntoVideo,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _editorController.dispose();
    super.dispose();
  }
}

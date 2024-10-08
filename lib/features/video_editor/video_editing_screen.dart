import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_video_editor/core/service/ffmpeg_service.dart';
import 'package:ffmpeg_video_editor/core/utils/utils.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/editing_options.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/export_loading.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/rotate_widget.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/trimmer_timeline.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

class VideoEditingScreen extends StatefulWidget {
  const VideoEditingScreen(
      {super.key, required this.pickedVideos, required this.filePath});

  final List<AssetEntity> pickedVideos;
  final String filePath;

  @override
  State<VideoEditingScreen> createState() => _VideoEditingScreenState();
}

class _VideoEditingScreenState extends State<VideoEditingScreen> {
  VideoEditorController? _editorController;
  late String _currentVideoPath;
  String _videoSize = '';
  bool isProcessing = false;
  double progress = 0.0;
  String fps = '';

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    _currentVideoPath = widget.filePath;
    _editorController = VideoEditorController.file(
      File(_currentVideoPath),
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 60),
    );
    await _editorController?.initialize();
    setState(() {});
    _editorController?.video.play();
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
      {required String outputPath, bool play = true}) async {
    setState(() => isProcessing = true);
    await FFMPEGService().runFFmpegCommand(
      command,
      onProgress: (stats) {
        if (mounted) {
          setState(() {
            progress = (stats.getTime() /
                    _editorController!.video.value.duration.inMilliseconds) *
                100;
          });
        }
      },
      onError: (e, s) {
        log(e.toString());
        log(s.toString());
        const snackBar = SnackBar(
          content: Text('Error processing video!'),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          isProcessing = false;
          progress = 0.0;
        });
      },
      onCompleted: (_) {
        setState(() {
          isProcessing = false;
          progress = 0.0;
          if (play) {
            _currentVideoPath = outputPath;
          }
        });
        if (play == true) {
          _playVideo(outputPath);
        }
      },
    );
  }

  Future<void> _playVideo(String path) async {
    _editorController?.dispose();
    _editorController = VideoEditorController.file(
      File(path),
      minDuration: const Duration(seconds: 0),
      maxDuration: const Duration(seconds: 60),
    );
    await _editorController?.initialize();
    setState(() {});
    _getVideoSize();
    _editorController?.video.play();
  }

  Future<void> _applyFilter() async {
    final outputPath = await getOutputFilePath();
    final ffmpegCommand = '-i $_currentVideoPath -vf "hue=s=0" $outputPath';
    await _runFFmpegCommand(ffmpegCommand, outputPath: outputPath);
  }

  Future<void> _trimAndSave() async {
    _editorController?.video.pause();
    final startTrim = _editorController!.minTrim *
        _editorController!.video.value.duration.inSeconds;
    final endTrim = _editorController!.maxTrim *
        _editorController!.video.value.duration.inSeconds;
    final outputPath = await trimVideo(_currentVideoPath, startTrim, endTrim);

    setState(() => _currentVideoPath = outputPath);
    _playVideo(outputPath);
  }

  Future<void> _deleteSection() async {
    _editorController?.video.pause();
    final startTrim = _editorController!.minTrim *
        _editorController!.video.value.duration.inSeconds;
    final endTrim = _editorController!.maxTrim *
        _editorController!.video.value.duration.inSeconds;
    final tempDir = await getTemporaryDirectory();
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final directory = Directory("${tempDir.path}/videos/$uniqueId/")
      ..create(recursive: true);
    final beforePath = '${directory.path}before_A.mp4';
    final afterPath = '${directory.path}after_B.mp4';
    final outputPath = '${directory.path}final_output.mp4';

    double videoDuration = await _getVideoDuration(_currentVideoPath);
    bool hasBeforeSegment = startTrim > 0;
    bool hasAfterSegment = endTrim < videoDuration;
    if (hasBeforeSegment) {
      final beforeCommand =
          '-i "$_currentVideoPath" -ss 0 -t $startTrim -c copy $beforePath';
      await _runFFmpegCommand(beforeCommand,
          outputPath: outputPath, play: false);
    } else {
      log('No segment before point A to extract (A starts at 0 seconds)');
    }
    if (hasAfterSegment) {
      final afterCommand =
          '-i "$_currentVideoPath" -ss $endTrim -c copy $afterPath';
      await _runFFmpegCommand(afterCommand,
          outputPath: outputPath, play: false);
    } else {
      log('No segment after point B to extract (B ends at video duration)');
    }

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
    }

    // Verify the content of the file list
    String writtenFiles = await concatFile.readAsString();
    log('Contents of concat_list.txt:\n$writtenFiles');
    final concatCommand =
        '-f concat -safe 0 -i "${concatFile.path}" -c copy $outputPath';
    await _runFFmpegCommand(concatCommand, outputPath: outputPath);

    // final outputPath = await removeSectionFromVideo(
    //   inputVideoPath: _currentVideoPath,
    //   startA: startTrim,
    //   endB: endTrim,
    // );

    // setState(() => _currentVideoPath = outputPath);
    // _playVideo(outputPath);
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
    final ffmpegCommand =
        '-i $_currentVideoPath -vf "$transpose" -c:a copy $outputPath';
    await _runFFmpegCommand(ffmpegCommand, outputPath: outputPath);
  }

  Future<double> _getVideoDuration(String videoPath) async {
    final session = await FFprobeKit.getMediaInformation(videoPath);
    final info = session.getMediaInformation();
    if (info != null) {
      final durationStr = info.getDuration();
      return double.parse(durationStr ?? '0');
    }
    return 0;
  }

  Future<void> _addSubtitlesToVideo() async {
    try {
      File subtitle = await loadSrtFromAssets('assets/subtitles.srt');
      String subtitlePath = subtitle.path;
      if (await subtitle.exists()) {
        log("file exists");
      } else {
        log("no subtitle found");
      }

      String outputPath = await getOutputFilePath();
      final command =
          '-i $_currentVideoPath -vf subtitles=$subtitlePath" $outputPath -report';
      log(command);
      await _runFFmpegCommand(command, outputPath: outputPath);
    } catch (e) {
      log(e.toString());
    }
  }

  double _getCorrectDimension(VideoPlayerController controller,
      {bool isWidth = false}) {
    final size = controller.value.size;
    return isWidth
        ? (size.width > size.height ? size.width : size.height)
        : (size.width > size.height ? size.height : size.width);
  }

// Helper method to check if the video is in landscape mode
  bool _isLandscape(VideoPlayerController controller) {
    final size = controller.value.size;
    return size.width > size.height;
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
          if (_editorController?.video.value.isInitialized ?? false) ...[
            RotateWidget(
              onRotateLeft: _onRotate,
              onRotateRight: () => _onRotate(toLeft: false),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.height / 1.1,
                  child: FittedBox(
                    child: SizedBox(
                      height: _getCorrectDimension(_editorController!.video),
                      width: _getCorrectDimension(_editorController!.video,
                          isWidth: true),
                      child: Transform.rotate(
                        angle: _isLandscape(_editorController!.video)
                            ? 0
                            : 90 * 3.1415926535 / 180,
                        child: VideoPlayer(_editorController!.video),
                      ),
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
                      _editorController!.video.value.isPlaying
                          ? _editorController!.video.pause()
                          : _editorController!.video.play();
                    },
                    icon: Icon(_editorController!.video.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    color: Colors.white,
                  ),
                if (isProcessing) ExportLoading(progress: progress),
              ],
            ),
            TrimmerTimeline(controller: _editorController!),
          ] else
            const Center(child: CircularProgressIndicator()

                // Text("Error playing video",
                //     style: TextStyle(color: Colors.white)),
                ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
                onPressed: _pickAudio, child: const Text('Add audio')),
            EditingOptions(
              onfilter: _applyFilter,
              onTrimAndSave: _trimAndSave,
              onDeleteSection: _deleteSection,
              onZoom: _zoomIntoVideo,
              onAddSubitles: _addSubtitlesToVideo,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _editorController?.dispose();
    super.dispose();
  }

  void _pickAudio() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      File file = File(result.files.single.path!);
      log(file.path);
      String? updatedPath =
          await trimAudioToFitVideo(_currentVideoPath, file.path);
      log(updatedPath.toString());
      if (updatedPath != null) {
        setState(() {
          _currentVideoPath = updatedPath;
        });
      }

      _playVideo(_currentVideoPath);
    } else {
      // User canceled the picker
    }
  }
}

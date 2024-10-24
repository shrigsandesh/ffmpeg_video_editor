import 'dart:developer';
import 'dart:io';
import 'package:ffmpeg_video_editor/core/service/ffmpeg_service.dart';
import 'package:ffmpeg_video_editor/core/utils/ffmpeg_commands.dart';
import 'package:ffmpeg_video_editor/core/utils/utils.dart';
import 'package:ffmpeg_video_editor/core/utils/video_utils.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/audio_picker.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/editing_options.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/export_loading.dart';
import 'package:ffmpeg_video_editor/features/video_editor/widgets/popuup_menu.dart';
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
  // String _videoSize = '';
  bool isProcessing = false;
  double progress = 0.0;
  String fps = '';
  bool isAudioSelected = false;
  String fileName = '';
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _initializeAndPlayVideo(String videoPath) async {
    // Initialize the video editor controller with the provided video path
    _editorController = VideoEditorController.file(
      File(videoPath),
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 60),
    );

    // Wait for the controller to initialize
    await _editorController?.initialize().then((_) {
      // Force the aspect ratio and orientation based on the metadata
      setState(() {
        _editorController?.video.play();
      });
    });
  }

  Future<void> _loadVideo() async {
    _currentVideoPath = widget.filePath;
    await _initializeAndPlayVideo(_currentVideoPath);
  }

  Future<void> _replayVideo(String path) async {
    // Dispose of the existing controller if it exists
    _editorController?.dispose();
    await _initializeAndPlayVideo(path);
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
          _replayVideo(outputPath);
        }
      },
      showDetailslogs: true,
    );
  }

  Future<void> _applyFilter() async {
    final outputPath = await getOutputFilePath();
    final ffmpegCommand = grayscaleCommand(
        inputVideoPath: _currentVideoPath, outputVideoPath: outputPath);
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
    _replayVideo(outputPath);
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

    double videoDuration =
        await FFMPEGService().getVideoDuration(_currentVideoPath);
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
  }

  Future<void> _zoomIntoVideo() async {
    if (isProcessing) return;
    final outputPath = await getOutputFilePath();
    final ffmpegCommand =
        '-i $_currentVideoPath -vf "scale=2*iw:-1,crop=iw/2:ih/2" $outputPath';
    await _runFFmpegCommand(ffmpegCommand, outputPath: outputPath);
  }

  void isProcesing(bool isVideoProcessing) {
    setState(() {
      isProcessing = isVideoProcessing;
    });
  }

  @override
  Widget build(BuildContext context) {
    log(widget.filePath.toString());
    return Scaffold(
      backgroundColor: const Color(0xff1A1D21),
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            const Text("Create Sizzle", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          if (_editorController?.video.value.isInitialized ?? false) ...[
            Stack(
              children: [
                Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: AspectRatio(
                      aspectRatio: _editorController!.video.value.aspectRatio,
                      child: VideoPlayer(_editorController!.video),
                    ),
                  ),
                ),
                if (isProcessing)
                  Align(
                      alignment: Alignment.center,
                      child: ExportLoading(progress: progress)),
              ],
            ),
          ] else
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomSheet: Container(
        color: const Color(0xff1A1D21),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_editorController?.initialized == true)
              TrimmerTimeline(controller: _editorController!),
            AudioPicker(
              isAudioSelected: isAudioSelected,
              onTap: _pickAudio,
              fileName: fileName,
              onRemove: _removeAudio,
            ),
            const SizedBox(height: 20),
            EditingOptions(
              key: _buttonKey,
              onfilter: _applyFilter,
              onTrimAndSave: _trimAndSave,
              onDeleteSection: _deleteSection,
              onZoom: _zoomIntoVideo,
              onAddSubitles: () {},
              onFlip: _flipVideo,
              onSpeedChange: _onSpeedChange,
              onAdjust: _onAdjust,
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

      String outputVideoPath = await getOutputFilePath();

      // FFmpeg command to trim audio and combine it with the video
      String command =
          '-i $_currentVideoPath -i ${file.path} -c:v copy -map 0:v -map 1:a -shortest $outputVideoPath';
      await _runFFmpegCommand(command, outputPath: outputVideoPath).then((_) {
        setState(() {
          isAudioSelected = true;
          fileName = result.files.single.name;
        });
      });
    }
  }

  void _removeAudio() async {
    String outputVideoPath = await getOutputFilePath();
    // FFmpeg command to trim audio and combine it with the video
    String command = '-i $_currentVideoPath  -c:v copy -an $outputVideoPath';
    await _runFFmpegCommand(command, outputPath: outputVideoPath).then((_) {
      setState(() {
        isAudioSelected = false;
      });
    });
  }

  void _flipVideo() async {
    String outputVideoPath = await getOutputFilePath();

    // FFmpeg command to trim audio and combine it with the video
    String command =
        '-i $_currentVideoPath -vf hflip -c:a copy $outputVideoPath';
    await _runFFmpegCommand(command, outputPath: outputVideoPath);
  }

  void _onSpeedChange() {
    showPopupMenu(
      context,
      _buttonKey,
      (speed) async {
        isProcesing(true);
        double videoSpeed = double.tryParse(speed) ?? 1;
        if (videoSpeed == 1) return;
        String outputVideoPath = await getOutputFilePath();
        String command =
            '-i $_currentVideoPath -filter_complex "[0:v]setpts=1/$speed*PTS[v];[0:a]atempo=$speed[a]" -map "[v]" -map "[a]" $outputVideoPath';
        await _runFFmpegCommand(command, outputPath: outputVideoPath);
      },
    );
  }

  void _onAdjust() async {
    final outputPath = await getOutputFilePath();
    // Directory tempDir = await getTemporaryDirectory();

    // File tempVideo = File("${tempDir.path}output1.mp4")
    //   ..createSync(recursive: true);
    // final outputPath = tempVideo.path;
    log("herererereresfsfsfsdfsdf");
    final command =
        '-i $_currentVideoPath - "scale=720:1280:force_original_aspect_ratio=decrease,pad=720:1280:-1:-1:color=black" $outputPath';
    await _runFFmpegCommand(command, outputPath: outputPath);
  }
}

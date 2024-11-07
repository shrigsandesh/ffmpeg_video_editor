import 'dart:developer';
// import 'package:ffmpeg_video_editor/core/utils/join_videos.dart';
import 'package:ffmpeg_video_editor/core/utils/utils.dart';
import 'package:ffmpeg_video_editor/core/utils/video_utils.dart';
import 'package:ffmpeg_video_editor/features/custom_video_picker/cubit/video_picker_cubit.dart';
import 'package:ffmpeg_video_editor/features/custom_video_picker/widgets/video_thumbnail.dart';
import 'package:ffmpeg_video_editor/features/video_editor/video_editing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

const _thumbnailSize = 60.0;
const _buttonRadius = 12.0;
const _containerMargin = 8.0;

class VideoPickerBottomSheet extends StatefulWidget {
  const VideoPickerBottomSheet({super.key});

  @override
  State<VideoPickerBottomSheet> createState() => _VideoPickerBottomSheetState();
}

class _VideoPickerBottomSheetState extends State<VideoPickerBottomSheet> {
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  void dispose() {
    isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPickerCubit, VideoPickerState>(
      builder: (context, state) => Container(
        color: Colors.black,
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.pickedVideos.isNotEmpty)
              _SelectedVideosList(
                pickedVideos: state.pickedVideos,
              ),
            ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, isLoading, _) => _SelectedButton(
                count: state.totalSelected,
                isLoading: isLoading,
                onPressed: () {
                  _handleVideoSelection(context, state);
                  if (mounted) {
                    context.read<VideoPickerCubit>().clearSelected();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleVideoSelection(
      BuildContext context, VideoPickerState state) async {
    if (state.totalSelected == 0) {
      _showSnackbar(context, 'Select video first!');
      return;
    }
//1730288925816

    isLoading.value = true;
    try {
      var videoPaths = await getVideoFiles(state.pickedVideos);

      var file = await joinVideos(videoPaths);
      log("updated file: ${file?.path}");

      if (file != null && context.mounted) {
        _navigateToEditingScreen(context, file.path, state.pickedVideos);
      }
    } catch (e, stackTrace) {
      log(stackTrace.toString());
    } finally {
      isLoading.value = false;
      setState(() {});
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToEditingScreen(
      BuildContext context, String file, List<AssetEntity> pickedVideos) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoEditingScreen(
          filePath: file,
          pickedVideos: pickedVideos,
        ),
      ),
    );
  }
}

class _SelectedVideosList extends StatelessWidget {
  const _SelectedVideosList({required this.pickedVideos});

  final List<AssetEntity> pickedVideos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pickedVideos.length,
        itemBuilder: (context, index) {
          final video = pickedVideos[index];

          return _SelectedVideoThumbnail(
            key: ValueKey(video.id),
            video: video,
            onTap: () => context.read<VideoPickerCubit>().removeSelected(video),
          );
        },
      ),
    );
  }
}

class _SelectedVideoThumbnail extends StatelessWidget {
  const _SelectedVideoThumbnail({
    super.key,
    required this.video,
    required this.onTap,
  });

  final AssetEntity video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_containerMargin),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          VideoThumbnailWidget(
            thumbnailData: video.thumbnailData,
            size: _thumbnailSize,
            radius: 8,
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              color: Colors.grey,
              child: InkWell(
                onTap: onTap,
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedButton extends StatelessWidget {
  const _SelectedButton({
    required this.count,
    required this.onPressed,
    required this.isLoading,
  });

  final int count;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(_containerMargin),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              )
            : Text(
                "Selected($count)",
                style: const TextStyle(color: Colors.white),
              ),
      ),
    );
  }
}

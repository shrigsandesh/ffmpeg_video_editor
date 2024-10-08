import 'package:ffmpeg_video_editor/core/di/dependency_injection.dart';
import 'package:ffmpeg_video_editor/core/utils/utils.dart';
import 'package:ffmpeg_video_editor/features/custom_video_picker/cubit/video_picker_cubit.dart';
import 'package:ffmpeg_video_editor/features/custom_video_picker/widgets/video_picker_bottom_sheet.dart';
import 'package:ffmpeg_video_editor/features/custom_video_picker/widgets/video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoPickerPage extends StatelessWidget {
  const VideoPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<VideoPickerCubit>()..loadVideos(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            "Videos",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const _VideoPickerBody(),
        bottomSheet: const VideoPickerBottomSheet(),
      ),
    );
  }
}

class _VideoPickerBody extends StatelessWidget {
  const _VideoPickerBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPickerCubit, VideoPickerState>(
      buildWhen: (previous, current) =>
          previous.videoFiles.length != current.videoFiles.length,
      builder: (context, state) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: state.videoFiles.length,
          itemBuilder: (context, index) {
            final video = state.videoFiles[index];

            return Stack(
              fit: StackFit.expand,
              children: [
                VideoThumbnail(thumbnailData: video.thumbnailData),
                BlocBuilder<VideoPickerCubit, VideoPickerState>(
                  builder: (context, state) {
                    final isSelected = state.pickedVideos
                        .contains(video); // Check if video is selected
                    final selectionIndex = state.pickedVideos.indexOf(video);

                    return Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                            onTap: () {
                              if (!isSelected) {
                                context
                                    .read<VideoPickerCubit>()
                                    .addPickedVideo(video);
                              } else {
                                context
                                    .read<VideoPickerCubit>()
                                    .removeSelected(video);
                              }
                            },
                            child: isSelected
                                ? CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      // Display the order number (1-based index)
                                      (selectionIndex + 1).toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    isSelected
                                        ? Icons.check
                                        : Icons.circle_outlined,
                                    color: Colors.white,
                                  )));
                  },
                ),
                Positioned(
                    bottom: 2,
                    right: 2,
                    child: Text(
                      formatTime(video.duration),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ))
              ],
            );
          },
        );
      },
    );
  }
}

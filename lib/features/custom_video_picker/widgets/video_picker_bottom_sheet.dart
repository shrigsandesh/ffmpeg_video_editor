import 'package:ffmpeg_video_editor/features/custom_video_picker/cubit/video_picker_cubit.dart';
import 'package:ffmpeg_video_editor/features/custom_video_picker/widgets/video_thumbnail.dart';
import 'package:ffmpeg_video_editor/features/video_editor/video_editing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

class VideoPickerBottomSheet extends StatelessWidget {
  const VideoPickerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPickerCubit, VideoPickerState>(
      builder: (context, state) {
        return Container(
          color: Colors.black,
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.pickedVideos.isNotEmpty)
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.pickedVideos.length,
                    itemBuilder: (context, index) => _SelectedVideoThumbnail(
                      key: ValueKey(state.pickedVideos[index].id),
                      video: state.pickedVideos[index],
                      onTap: () => context
                          .read<VideoPickerCubit>()
                          .removeSelected(state.pickedVideos[index]),
                    ),
                  ),
                ),
              _SelectedButton(
                count: state.totalSelected,
                onPressed: () {
                  if (state.totalSelected == 0) {
                    const snackBar = SnackBar(
                      content: Text('Select video first!'),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VideoEditingScreen(
                      pickedVideos: state.pickedVideos,
                    ),
                  ));
                  // navigate to next page
                },
              )
            ],
          ),
        );
      },
    );
  }
}

class _SelectedVideoThumbnail extends StatelessWidget {
  const _SelectedVideoThumbnail(
      {super.key, required this.video, required this.onTap});

  final AssetEntity video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          VideoThumbnail(
            thumbnailData: video.thumbnailData,
            size: 60.0,
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
              ))
        ],
      ),
    );
  }
}

class _SelectedButton extends StatelessWidget {
  const _SelectedButton({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          onPressed: onPressed,
          child: Text(
            "Selected($count)",
            style: const TextStyle(color: Colors.white),
          )),
    );
  }
}

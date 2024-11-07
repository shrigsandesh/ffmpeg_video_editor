import 'package:ffmpeg_video_editor/core/di/dependency_injection.dart';
import 'package:ffmpeg_video_editor/core/utils/utils.dart';
import 'package:ffmpeg_video_editor/features/custom_video_picker/cubit/video_picker_cubit.dart';
import 'package:ffmpeg_video_editor/features/custom_video_picker/widgets/video_picker_bottom_sheet.dart';
import 'package:ffmpeg_video_editor/features/custom_video_picker/widgets/video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

class VideoPickerPage extends StatefulWidget {
  const VideoPickerPage({super.key});

  @override
  State<VideoPickerPage> createState() => _VideoPickerPageState();
}

class _VideoPickerPageState extends State<VideoPickerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => get<VideoPickerCubit>()..loadVideos(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            "Videos",
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(
                text: 'All',
              ),
              Tab(
                text: 'Videos',
              ),
              Tab(
                text: 'Photos',
              )
            ],
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        body: BlocBuilder<VideoPickerCubit, VideoPickerState>(
          buildWhen: (previous, current) =>
              previous.allFiles.length != current.allFiles.length,
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return TabBarView(controller: _tabController, children: [
              _VideoPickerBody(
                fileList: state.allFiles,
              ),
              _VideoPickerBody(
                fileList: state.videoFiles,
              ),
              _VideoPickerBody(
                fileList: state.imageFiles,
              ),
            ]);
          },
        ),
        bottomSheet: const VideoPickerBottomSheet(),
      ),
    );
  }
}

class _VideoPickerBody extends StatelessWidget {
  const _VideoPickerBody({required this.fileList});

  final List<AssetEntity> fileList;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: fileList.length,
      itemBuilder: (context, index) {
        final video = fileList[index];

        return Stack(
          fit: StackFit.expand,
          children: [
            VideoThumbnailWidget(thumbnailData: video.thumbnailData),
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
            if (video.duration > 0)
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
  }
}

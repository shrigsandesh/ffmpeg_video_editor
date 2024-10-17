import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:photo_manager/photo_manager.dart';
part 'video_picker_cubit.freezed.dart';
part 'video_picker_state.dart';

@injectable
class VideoPickerCubit extends Cubit<VideoPickerState> {
  VideoPickerCubit() : super(const VideoPickerState());

  Future<void> loadVideos() async {
    // Get the list of albums
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();

    // Get assets from the first album
    List<AssetEntity> assets =
        await albums[0].getAssetListRange(start: 0, end: 1000);

    // Filter videos
    List<AssetEntity> videos =
        assets.where((asset) => asset.type == AssetType.video).toList();
    // Filter videos
    List<AssetEntity> images =
        assets.where((asset) => asset.type == AssetType.image).toList();

    emit(state.copyWith(
      allFiles: assets,
      videoFiles: videos,
      imageFiles: images,
    ));
  }

  void addPickedVideo(AssetEntity video) {
    if (state.pickedVideos.contains(video)) {
      return;
    }
    emit(
      state.copyWith(
        pickedVideos: [
          ...state.pickedVideos,
          ...[video]
        ],
      ),
    );
  }

  void removeSelected(AssetEntity pickedVideo) {
    emit(
      state.copyWith(
        pickedVideos: state.pickedVideos
            .where((item) => item.id != pickedVideo.id)
            .toList(),
      ),
    );
  }
}

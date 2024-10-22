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
    emit(state.copyWith(isLoading: true));
    // Get the list of albums
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();

    // Get assets from the first album
    int assetCount = await albums[0].assetCountAsync;
    List<AssetEntity> assets =
        await albums[0].getAssetListRange(start: 0, end: assetCount);

    // Filter videos
    List<AssetEntity> videos =
        assets.where((asset) => asset.type == AssetType.video).toList();
    // Filter videos
    List<AssetEntity> images =
        assets.where((asset) => asset.type == AssetType.image).toList();

    emit(state.copyWith(
      isLoading: false,
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

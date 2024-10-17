part of 'video_picker_cubit.dart';

@freezed
class VideoPickerState with _$VideoPickerState {
  const VideoPickerState._();
  const factory VideoPickerState({
    @Default([]) List<AssetEntity> allFiles,
    @Default([]) List<AssetEntity> videoFiles,
    @Default([]) List<AssetEntity> pickedVideos,
    @Default([]) List<AssetEntity> imageFiles,
  }) = _VideoPickerState;

  int get totalSelected => pickedVideos.length;
}

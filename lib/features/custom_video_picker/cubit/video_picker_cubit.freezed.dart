// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_picker_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VideoPickerState {
  List<AssetEntity> get videoFiles => throw _privateConstructorUsedError;
  List<AssetEntity> get pickedVideos => throw _privateConstructorUsedError;

  /// Create a copy of VideoPickerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoPickerStateCopyWith<VideoPickerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoPickerStateCopyWith<$Res> {
  factory $VideoPickerStateCopyWith(
          VideoPickerState value, $Res Function(VideoPickerState) then) =
      _$VideoPickerStateCopyWithImpl<$Res, VideoPickerState>;
  @useResult
  $Res call({List<AssetEntity> videoFiles, List<AssetEntity> pickedVideos});
}

/// @nodoc
class _$VideoPickerStateCopyWithImpl<$Res, $Val extends VideoPickerState>
    implements $VideoPickerStateCopyWith<$Res> {
  _$VideoPickerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoPickerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoFiles = null,
    Object? pickedVideos = null,
  }) {
    return _then(_value.copyWith(
      videoFiles: null == videoFiles
          ? _value.videoFiles
          : videoFiles // ignore: cast_nullable_to_non_nullable
              as List<AssetEntity>,
      pickedVideos: null == pickedVideos
          ? _value.pickedVideos
          : pickedVideos // ignore: cast_nullable_to_non_nullable
              as List<AssetEntity>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoPickerStateImplCopyWith<$Res>
    implements $VideoPickerStateCopyWith<$Res> {
  factory _$$VideoPickerStateImplCopyWith(_$VideoPickerStateImpl value,
          $Res Function(_$VideoPickerStateImpl) then) =
      __$$VideoPickerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<AssetEntity> videoFiles, List<AssetEntity> pickedVideos});
}

/// @nodoc
class __$$VideoPickerStateImplCopyWithImpl<$Res>
    extends _$VideoPickerStateCopyWithImpl<$Res, _$VideoPickerStateImpl>
    implements _$$VideoPickerStateImplCopyWith<$Res> {
  __$$VideoPickerStateImplCopyWithImpl(_$VideoPickerStateImpl _value,
      $Res Function(_$VideoPickerStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoPickerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoFiles = null,
    Object? pickedVideos = null,
  }) {
    return _then(_$VideoPickerStateImpl(
      videoFiles: null == videoFiles
          ? _value._videoFiles
          : videoFiles // ignore: cast_nullable_to_non_nullable
              as List<AssetEntity>,
      pickedVideos: null == pickedVideos
          ? _value._pickedVideos
          : pickedVideos // ignore: cast_nullable_to_non_nullable
              as List<AssetEntity>,
    ));
  }
}

/// @nodoc

class _$VideoPickerStateImpl extends _VideoPickerState {
  const _$VideoPickerStateImpl(
      {final List<AssetEntity> videoFiles = const [],
      final List<AssetEntity> pickedVideos = const []})
      : _videoFiles = videoFiles,
        _pickedVideos = pickedVideos,
        super._();

  final List<AssetEntity> _videoFiles;
  @override
  @JsonKey()
  List<AssetEntity> get videoFiles {
    if (_videoFiles is EqualUnmodifiableListView) return _videoFiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_videoFiles);
  }

  final List<AssetEntity> _pickedVideos;
  @override
  @JsonKey()
  List<AssetEntity> get pickedVideos {
    if (_pickedVideos is EqualUnmodifiableListView) return _pickedVideos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pickedVideos);
  }

  @override
  String toString() {
    return 'VideoPickerState(videoFiles: $videoFiles, pickedVideos: $pickedVideos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoPickerStateImpl &&
            const DeepCollectionEquality()
                .equals(other._videoFiles, _videoFiles) &&
            const DeepCollectionEquality()
                .equals(other._pickedVideos, _pickedVideos));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_videoFiles),
      const DeepCollectionEquality().hash(_pickedVideos));

  /// Create a copy of VideoPickerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoPickerStateImplCopyWith<_$VideoPickerStateImpl> get copyWith =>
      __$$VideoPickerStateImplCopyWithImpl<_$VideoPickerStateImpl>(
          this, _$identity);
}

abstract class _VideoPickerState extends VideoPickerState {
  const factory _VideoPickerState(
      {final List<AssetEntity> videoFiles,
      final List<AssetEntity> pickedVideos}) = _$VideoPickerStateImpl;
  const _VideoPickerState._() : super._();

  @override
  List<AssetEntity> get videoFiles;
  @override
  List<AssetEntity> get pickedVideos;

  /// Create a copy of VideoPickerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoPickerStateImplCopyWith<_$VideoPickerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

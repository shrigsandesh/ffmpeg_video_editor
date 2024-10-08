// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/custom_video_picker/cubit/video_picker_cubit.dart'
    as _i754;
import '../service/ffmpeg_service.dart' as _i334;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i754.VideoPickerCubit>(() => _i754.VideoPickerCubit());
    gh.lazySingleton<_i334.FFMPEGService>(() => _i334.FFMPEGService());
    return this;
  }
}

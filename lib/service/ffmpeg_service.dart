import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:flutter/material.dart';

class FFMPEGService {
  Future<void> dispose() async {
    final executions = await FFmpegKit.listSessions();
    if (executions.isNotEmpty) await FFmpegKit.cancel();
  }

  Future<FFmpegSession> runFFmpegCommand(
    String command, {
    required void Function(ReturnCode? returnCode) onCompleted,
    void Function(Object, StackTrace)? onError,
    void Function(Statistics)? onProgress,
  }) {
    debugPrint('FFmpeg start process with command = $command');
    return FFmpegKit.executeAsync(
      command,
      (session) async {
        final state =
            FFmpegKitConfig.sessionStateToString(await session.getState());
        final code = await session.getReturnCode();

        if (ReturnCode.isSuccess(code)) {
          onCompleted(code);
        } else {
          if (onError != null) {
            onError(
              Exception(
                  'FFmpeg process exited with state $state and return code $code.\n${await session.getOutput()}'),
              StackTrace.current,
            );
          }
          return;
        }
      },
      null,
      onProgress,
    );
  }

  Future<double> getVideoDuration(String videoPath) async {
    final info = await FFprobeKit.getMediaInformation(videoPath);
    final output = info.getMediaInformation();
    final durStr = output?.getDuration();
    if (durStr == null) {
      return 0.0;
    } else {
      return double.parse(durStr);
    }
  }
}

import 'dart:developer';

import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/log.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/statistics.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
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
    bool showDetailslogs = false,
  }) {
    debugPrint('FFmpeg start process with command = $command');

    return FFmpegKit.executeAsync(
      command,
      (session) async {
        final state =
            FFmpegKitConfig.sessionStateToString(await session.getState());
        final code = await session.getReturnCode();

        /// Handles the logs and errors for the FFmpeg session.
        if (showDetailslogs) {
          // Retrieve logs and statistics for debugging.
          await handleLogs(session);
          await handleStatistics(session);
        }

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

  Future<void> runSyncFFmpegCommand(String command) async {
    debugPrint('FFmpeg start process with command = $command');
    await FFmpegKit.execute(
      command,
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

  Future<void> handleLogs(FFmpegSession session) async {
    List<Log> logs = await session.getLogs();
    for (var l in logs) {
      log('FFmpeg Log: ${l.getLevel()} - ${l.getMessage()}');
    }
  }

  /// Fetch and print statistics from the FFmpeg session.
  Future<void> handleStatistics(FFmpegSession session) async {
    List<Statistics>? stats = await session.getStatistics();
    for (var stat in stats) {
      log('FFmpeg Stats - Time: ${stat.getTime()}, Bitrate: ${stat.getBitrate()}, Size: ${stat.getSize()}');
    }
  }
}

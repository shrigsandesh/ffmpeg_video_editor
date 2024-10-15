import 'dart:developer';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';

class FFmpegService {
  /// Runs an FFmpeg command and logs the output and errors.
  Future<void> runFFmpegCommand(
    String command, {
    required Function(String message) onSuccess,
    required Function(String error) onFailure,
  }) async {
    try {
      log('Executing FFmpeg command: $command');

      // Run the FFmpeg command and get the session.
      FFmpegSession session = await FFmpegKit.execute(command);

      // Retrieve logs and statistics for debugging.
      await handleLogs(session);
      await handleStatistics(session);

      // Check the return code to determine success or failure.
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        final output = await session.getOutput() ?? "";
        log(output);
        onSuccess(output);
      } else {
        final error = 'FFmpeg command failed with code: $returnCode';
        final failStackTrace = await session.getFailStackTrace();
        onFailure('$error\nStackTrace: $failStackTrace');
      }
    } catch (e, stacktrace) {
      onFailure('Exception occurred: $e\nStacktrace: $stacktrace');
    }
  }

  /// Handles the logs and errors for the FFmpeg session.
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

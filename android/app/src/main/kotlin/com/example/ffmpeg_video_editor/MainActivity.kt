package com.example.ffmpeg_video_editor

import io.flutter.embedding.android.FlutterActivity
import android.media.MediaMetadataRetriever
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.MediaExtractor
import android.media.MediaFormat

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.ffmpeg_video_editor/fps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getFps") {
                val filePath = call.argument<String>("filePath")
                val fps = getFpsFromVideo(filePath!!)
                result.success(fps)
            } else {
                result.notImplemented()
            }
        }
    }

   private fun getFpsFromVideo(filePath: String): Float {
    val extractor = MediaExtractor()
    extractor.setDataSource(filePath)
    val format = extractor.getTrackFormat(0)
    val fps = format.getInteger(MediaFormat.KEY_FRAME_RATE)
    extractor.release()
    return fps.toFloat()
}

}

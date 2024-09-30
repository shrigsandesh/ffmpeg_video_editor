import 'package:ffmpeg_video_editor/core/di/dependency_injection.dart';
import 'package:ffmpeg_video_editor/core/utils/utils.dart';
import 'package:ffmpeg_video_editor/features/video_editor/video_editing_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const FFmpegVideoEditorApp());
}

class FFmpegVideoEditorApp extends StatelessWidget {
  const FFmpegVideoEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Video editor",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: const Icon(
          Icons.video_camera_back_outlined,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red, Colors.yellow],
              ),
            ),
            child: InkWell(
              onTap: () => _selectVideoFile(context),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  Text(
                    "Add new project",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectVideoFile(BuildContext context) async {
    final result = await Utils.selectVideo();
    if (result is File) {
      if (!context.mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoEditingScreen(
              path: result.path,
            ),
          ));
    }
  }
}

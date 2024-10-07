import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoThumbnail extends StatelessWidget {
  const VideoThumbnail(
      {super.key, required this.thumbnailData, this.size, this.radius});

  final Future<Uint8List?> thumbnailData;

  final double? size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: thumbnailData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return ClipRRect(
            borderRadius: radius != null
                ? BorderRadius.circular(radius!)
                : BorderRadius.zero,
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              height: size,
              width: size,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

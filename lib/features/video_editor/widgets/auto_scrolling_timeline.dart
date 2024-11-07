import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_video_editor/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';

class AutoScrollingThumbnails extends StatefulWidget {
  final List<File> imagePaths;
  final double imageWidth;
  final double imageHeight;
  final Duration scrollDuration;
  final Duration scrollInterval;
  final VideoEditorController controller;

  const AutoScrollingThumbnails({
    super.key,
    required this.imagePaths,
    this.imageWidth = 200,
    this.imageHeight = 200,
    this.scrollDuration = const Duration(milliseconds: 500),
    this.scrollInterval = const Duration(seconds: 2),
    required this.controller,
  });

  @override
  State<AutoScrollingThumbnails> createState() =>
      _AutoScrollingThumbnailsState();
}

class _AutoScrollingThumbnailsState extends State<AutoScrollingThumbnails> {
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  bool _isScrolling = false;
  late double screenWidth;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Initialize scroll position after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToStart();
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToStart() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(0);
  }

  void _startAutoScroll() {
    if (_isScrolling) return;

    setState(() => _isScrolling = true);

    _scrollTimer = Timer.periodic(widget.scrollInterval, (timer) {
      if (!_scrollController.hasClients) return;

      final currentPosition = _scrollController.offset;
      final maxScroll = _scrollController.position.maxScrollExtent;

      if (currentPosition >= maxScroll) {
        _stopAutoScroll();
        return;
      }

      _scrollController.animateTo(
        currentPosition + widget.imageWidth,
        duration: widget.scrollDuration,
        curve: Curves.linear,
      );
    });
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    setState(() => _isScrolling = false);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            widget.controller,
            widget.controller.video,
          ]),
          builder: (_, __) {
            final int duration = widget.controller.videoDuration.inSeconds;
            final double pos = widget.controller.trimPosition * duration;
            const TextStyle textStyle = TextStyle(color: Colors.white);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${formatter(Duration(seconds: pos.isNaN ? 0 : pos.toInt()))} / ${formatter(Duration(seconds: duration.isNaN ? 0 : duration))}",
                      style: textStyle,
                    ),
                    IconButton(
                      onPressed: () {
                        if (widget.controller.video.value.isPlaying) {
                          widget.controller.video.pause();
                          _stopAutoScroll();
                        } else {
                          widget.controller.video.play();
                          _startAutoScroll();
                        }
                      },
                      icon: Icon(
                        widget.controller.video.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: widget.controller.isTrimming ? 1 : 0,
                      duration: kThemeAnimationDuration,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          formatter(widget.controller.startTrim),
                          style: textStyle,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          formatter(widget.controller.endTrim),
                          style: textStyle,
                        ),
                      ]),
                    ),
                  ]),
            );
          },
        ),
        SizedBox(
          height: widget.imageHeight,
          child: ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount:
                widget.imagePaths.length + 1, // Add 1 for the initial space
            itemBuilder: (context, index) {
              if (index == 0) {
                // First item is blank space equal to half screen width
                return SizedBox(width: screenWidth / 2);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Image.file(
                  widget.imagePaths[index - 1],
                  width: widget.imageWidth,
                  height: widget.imageHeight,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

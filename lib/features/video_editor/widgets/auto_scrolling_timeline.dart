import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_video_editor/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_editor/video_editor.dart';

class AutoScrollingThumbnails extends StatefulWidget {
  final List<File> imagePaths;
  final double imageWidth;
  final double imageHeight;
  final Duration scrollDuration;
  final Duration scrollInterval;
  final VideoEditorController controller;
  final VoidCallback onAddSound;
  final bool isAudioSelected;
  final String selectedAudioFileName;

  const AutoScrollingThumbnails({
    super.key,
    required this.imagePaths,
    this.imageWidth = 200,
    this.imageHeight = 200,
    this.scrollDuration = const Duration(milliseconds: 500),
    this.scrollInterval = const Duration(seconds: 2),
    required this.controller,
    required this.onAddSound,
    required this.isAudioSelected,
    required this.selectedAudioFileName,
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
  double _scrollOffset = 0;
  double _maxScrollExtent = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollOffset);

    // Initialize scroll position after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToStart();
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.removeListener(_updateScrollOffset);
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
    final stepSize =
        widget.imageWidth * (widget.scrollDuration.inMilliseconds / 1000);

    _scrollTimer = Timer.periodic(widget.scrollInterval, (timer) {
      if (!_scrollController.hasClients) return;

      var currentPosition = _scrollController.offset;
      final maxScroll = _scrollController.position.maxScrollExtent;

      if (currentPosition >= maxScroll) {
        if (widget.controller.isPlaying) {
          _scrollToStart();
          setState(() {
            currentPosition = _scrollController.initialScrollOffset;
          });
        } else {
          _stopAutoScroll();
          return;
        }
      }

      _scrollController.animateTo(
        currentPosition + stepSize,
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
    double limit = _maxScrollExtent * 0.88;

    // If the scroll offset exceeds 80%, cap it at 80%
    double scrollPosition = _scrollOffset > limit ? limit : _scrollOffset;

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
        Stack(
          alignment: Alignment.topCenter,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: widget.imageHeight,
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.imagePaths.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 1.0),
                            child: Image.file(
                              widget.imagePaths[index],
                              width: widget.imageWidth,
                              height: widget.imageHeight,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      _AudioSelector(
                        controller: _scrollController,
                        itemCount: widget.imagePaths.length + 2,
                        width: widget.imageWidth,
                      ),
                      Positioned.fill(
                        top: 8,
                        left: MediaQuery.of(context).size.width / 2 +
                            (widget.isAudioSelected ? 20 : scrollPosition),
                        child: InkWell(
                          onTap: widget.onAddSound,
                          child: widget.isAudioSelected
                              ? Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/MusicNotesSimple.svg',
                                      height: 24,
                                      width: 24,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      widget.selectedAudioFileName,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/MusicNotesSimple.svg',
                                      height: 16,
                                      width: 16,
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'Add sound',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              color: Colors.white,
              width: 2,
              height: 175,
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _updateScrollOffset() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _maxScrollExtent = _scrollController.position.maxScrollExtent;
    });
  }
}

class _AudioSelector extends StatelessWidget {
  const _AudioSelector(
      {required this.controller, required this.itemCount, required this.width});

  final ScrollController controller;
  final int itemCount;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 40,
        color: const Color(0xff1A1D21),
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
            ),
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: (itemCount - 2) * width + 16,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                  color: const Color(0xff1A1D21)),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
            ),
          ],
        ));
  }
}

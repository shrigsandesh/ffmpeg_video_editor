import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';

class TrimmerTimeline extends StatelessWidget {
  const TrimmerTimeline({super.key, required this.controller});
  final VideoEditorController controller;
  final double height = 60;
  final TextStyle textStyle = const TextStyle(color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: Listenable.merge([
            controller,
            controller.video,
          ]),
          builder: (_, __) {
            final int duration = controller.videoDuration.inSeconds;
            final double pos = controller.trimPosition * duration;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text(
                  formatter(Duration(seconds: pos.isNaN ? 0 : pos.toInt())),
                  style: textStyle,
                ),
                const Expanded(child: SizedBox()),
                AnimatedOpacity(
                  opacity: controller.isTrimming ? 1 : 0,
                  duration: kThemeAnimationDuration,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      formatter(controller.startTrim),
                      style: textStyle,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formatter(controller.endTrim),
                      style: textStyle,
                    ),
                  ]),
                ),
              ]),
            );
          },
        ),
        Container(
          height: height,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(vertical: height / 4),
          child: Stack(
            children: [
              Positioned.fill(
                child: TrimSlider(
                  controller: controller,
                  height: height,
                  horizontalMargin: height / 4,
                ),
              ),
              // TrimTimeline(
              //     controller: controller,
              //     padding: const EdgeInsets.only(top: 10),
              //     textStyle: textStyle),
            ],
          ),
        ),
      ],
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");
}

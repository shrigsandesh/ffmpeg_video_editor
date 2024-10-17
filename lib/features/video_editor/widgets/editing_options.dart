import 'package:ffmpeg_video_editor/features/video_editor/widgets/editing_icon.dart';
import 'package:flutter/material.dart';

class EditingOptions extends StatelessWidget {
  const EditingOptions(
      {super.key,
      required this.onfilter,
      required this.onTrimAndSave,
      required this.onDeleteSection,
      required this.onZoom,
      required this.onAddSubitles,
      required this.onFlip});
  final VoidCallback onfilter;
  final VoidCallback onTrimAndSave;
  final VoidCallback onDeleteSection;
  final VoidCallback onZoom;
  final VoidCallback onAddSubitles;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        EditingIcon(
            onEdit: onDeleteSection,
            assetPath: 'assets/Scissors.svg',
            label: "Cut"),
        EditingIcon(
            // onEdit: onTrimAndSave,
            onEdit: () {},
            assetPath: 'assets/MusicNotesSimple.svg',
            label: "Sound"),
        EditingIcon(
            // onEdit: onDeleteSection,
            onEdit: () {},
            assetPath: 'assets/ClockCountdown.svg',
            label: "Speed"),
        EditingIcon(
            onEdit: onFlip,
            assetPath: 'assets/FlipHorizontal.svg',
            label: "Mirror"),
        EditingIcon(
            // onEdit: onZoom,
            onEdit: () {},
            assetPath: 'assets/FadersHorizontal.svg',
            label: "Adjust"),
        EditingIcon(
            // onEdit: onZoom,
            onEdit: () {},
            assetPath: 'assets/Spiral.svg',
            label: "Blur"),
      ],
    );
  }
}

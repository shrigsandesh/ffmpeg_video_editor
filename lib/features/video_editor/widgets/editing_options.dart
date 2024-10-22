import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EditingOptions extends StatelessWidget {
  const EditingOptions(
      {super.key,
      required this.onfilter,
      required this.onTrimAndSave,
      required this.onDeleteSection,
      required this.onZoom,
      required this.onAddSubitles,
      required this.onFlip,
      required this.onSpeedChange,
      required this.onAdjust});
  final VoidCallback onfilter;
  final VoidCallback onTrimAndSave;
  final VoidCallback onDeleteSection;
  final VoidCallback onZoom;
  final VoidCallback onAddSubitles;
  final VoidCallback onFlip;
  final VoidCallback onSpeedChange;
  final VoidCallback onAdjust;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        _EditingIcon(
            onEdit: onDeleteSection,
            assetPath: 'assets/Scissors.svg',
            label: "Cut"),
        _EditingIcon(
            // onEdit: onTrimAndSave,
            onEdit: () {},
            assetPath: 'assets/MusicNotesSimple.svg',
            label: "Sound"),
        _EditingIcon(
            onEdit: onSpeedChange,
            assetPath: 'assets/ClockCountdown.svg',
            label: "Speed"),
        _EditingIcon(
            onEdit: onFlip,
            assetPath: 'assets/FlipHorizontal.svg',
            label: "Mirror"),
        _EditingIcon(
            onEdit: onAdjust,
            assetPath: 'assets/FadersHorizontal.svg',
            label: "Adjust"),
        _EditingIcon(
            // onEdit: onZoom,
            onEdit: () {},
            assetPath: 'assets/Spiral.svg',
            label: "Blur"),
      ],
    );
  }
}

class _EditingIcon extends StatelessWidget {
  const _EditingIcon(
      {required this.onEdit, required this.assetPath, required this.label});

  final VoidCallback onEdit;
  final String assetPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            assetPath,
            height: 24,
            width: 24,
          ),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

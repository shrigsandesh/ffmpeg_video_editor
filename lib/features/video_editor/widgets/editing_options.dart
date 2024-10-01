import 'package:ffmpeg_video_editor/features/video_editor/widgets/editing_icon.dart';
import 'package:flutter/material.dart';

class EditingOptions extends StatelessWidget {
  const EditingOptions(
      {super.key,
      required this.onfilter,
      required this.onTrimAndSave,
      required this.onDeleteSection,
      required this.onZoom});
  final VoidCallback onfilter;
  final VoidCallback onTrimAndSave;
  final VoidCallback onDeleteSection;
  final VoidCallback onZoom;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        EditingIcon(
            onEdit: onfilter, editingIcon: Icons.tune, label: "B/W filter"),
        EditingIcon(
            onEdit: onTrimAndSave,
            editingIcon: Icons.cut,
            label: "Trim and Save"),
        EditingIcon(
            onEdit: onDeleteSection,
            editingIcon: Icons.delete,
            label: "Delete selected section"),
        EditingIcon(
            onEdit: onZoom, editingIcon: Icons.zoom_in, label: "Zoom(2X)"),
      ],
    );
  }
}

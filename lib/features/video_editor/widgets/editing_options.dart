import 'package:ffmpeg_video_editor/features/video_editor/widgets/editing_icon.dart';
import 'package:flutter/material.dart';

class EditingOptions extends StatelessWidget {
  const EditingOptions(
      {super.key,
      required this.onfilter,
      required this.onTrimAndSave,
      required this.onDeleteSection,
      required this.onZoom,
      required this.onAddSubitles});
  final VoidCallback onfilter;
  final VoidCallback onTrimAndSave;
  final VoidCallback onDeleteSection;
  final VoidCallback onZoom;
  final VoidCallback onAddSubitles;

  @override
  Widget build(BuildContext context) {
    return Wrap(
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
        // EditingIcon(
        //     onEdit: onAddSubitles, editingIcon: Icons.add, label: "Subtitle"),
      ],
    );
  }
}

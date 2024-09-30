import 'package:flutter/material.dart';

class EditingIcon extends StatelessWidget {
  const EditingIcon(
      {super.key,
      required this.onEdit,
      required this.editingIcon,
      required this.label});

  final VoidCallback onEdit;
  final IconData editingIcon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onEdit,
          child: Icon(
            editingIcon,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

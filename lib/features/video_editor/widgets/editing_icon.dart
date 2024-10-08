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
    return InkWell(
      onTap: onEdit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            editingIcon,
            color: Colors.white,
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

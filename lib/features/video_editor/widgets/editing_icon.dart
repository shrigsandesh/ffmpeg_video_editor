import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EditingIcon extends StatelessWidget {
  const EditingIcon(
      {super.key,
      required this.onEdit,
      required this.assetPath,
      required this.label});

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

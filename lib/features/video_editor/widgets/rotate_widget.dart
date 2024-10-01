import 'package:flutter/material.dart';

class RotateWidget extends StatelessWidget {
  const RotateWidget(
      {super.key, required this.onRotateLeft, required this.onRotateRight});

  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: onRotateLeft,
            icon: const Icon(
              Icons.rotate_left,
              color: Colors.white,
            )),
        IconButton(
            onPressed: onRotateRight,
            icon: const Icon(
              Icons.rotate_right,
              color: Colors.white,
            ))
      ],
    );
  }
}

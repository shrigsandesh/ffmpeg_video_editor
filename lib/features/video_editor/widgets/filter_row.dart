import 'package:flutter/material.dart';

//TODO: complete filters options ui
class FilterRow extends StatelessWidget {
  const FilterRow({super.key, required this.videoPath});

  final String videoPath;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilterOptionIcon(onTap: () {}, label: "B/w"),
        FilterOptionIcon(onTap: () {}, label: "B/w"),
        FilterOptionIcon(onTap: () {}, label: "B/w"),
        FilterOptionIcon(onTap: () {}, label: "B/w"),
      ],
    );
  }
}

class FilterOptionIcon extends StatelessWidget {
  const FilterOptionIcon({super.key, required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(onPressed: onTap, icon: const Icon(Icons.circle_outlined)),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        )
      ],
    );
  }
}

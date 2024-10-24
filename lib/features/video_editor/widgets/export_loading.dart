import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ExportLoading extends StatelessWidget {
  const ExportLoading({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 40,
      percent: (progress / 100) > 1 ? 1.0 : (progress / 100),
      center: Text(
        "${progress.truncate()}%",
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      linearGradient: const LinearGradient(
        colors: [
          Colors.red,
          Colors.orange,
        ],
      ),
      footer: const Text(
        "Processing..",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

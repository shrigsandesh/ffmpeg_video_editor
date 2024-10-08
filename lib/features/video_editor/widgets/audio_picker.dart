import 'package:flutter/material.dart';

class AudioPicker extends StatelessWidget {
  const AudioPicker(
      {super.key,
      required this.isAudioSelected,
      this.fileName,
      required this.onTap});

  final bool isAudioSelected;
  final String? fileName;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.white),
          borderRadius: BorderRadius.circular(9),
          color: isAudioSelected ? Colors.blue : Colors.transparent,
        ),
        child: isAudioSelected
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.music_note,
                    color: Colors.white,
                  ),
                  Text(
                    fileName!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              )
            : const Center(
                child: Text(
                  "Pick Audio File",
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}

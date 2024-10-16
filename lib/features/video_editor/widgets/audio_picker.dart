import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AudioPicker extends StatelessWidget {
  const AudioPicker(
      {super.key,
      required this.isAudioSelected,
      this.fileName,
      required this.onTap,
      required this.onRemove});

  final bool isAudioSelected;
  final String? fileName;

  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.white),
          borderRadius: BorderRadius.circular(9),
          color: isAudioSelected ? Colors.blue : Colors.transparent,
        ),
        child: isAudioSelected
            ? Row(
                children: [
                  SvgPicture.asset(
                    'assets/MusicNotesSimple.svg',
                    height: 24,
                    width: 24,
                  ),
                  Text(
                    fileName!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: onRemove,
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  Text(
                    "Pick Audio File",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}

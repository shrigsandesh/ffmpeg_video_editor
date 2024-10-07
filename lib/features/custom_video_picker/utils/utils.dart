String formatTime(int seconds) {
  final int minutes = seconds ~/ 60;
  final int remainingSeconds = seconds % 60;

  // Format minutes and seconds to always show two digits
  final String formattedMinutes = minutes.toString().padLeft(2, '0');
  final String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

  return '$formattedMinutes:$formattedSeconds';
}

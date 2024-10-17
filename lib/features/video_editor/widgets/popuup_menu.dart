import 'package:flutter/material.dart';

void showPopupMenu(
  BuildContext context,
  GlobalKey buttonKey,
  void Function(String) onSelected,
) {
  // Safely access the RenderBox using `findRenderObject()`.
  final renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) {
    debugPrint('Error: RenderBox not found.');
    return;
  }

  // Calculate button position and size.
  final buttonPosition = renderBox.localToGlobal(Offset.zero);
  final buttonSize = renderBox.size;

  late OverlayEntry overlayEntry; // Declare first
  // Create the overlay entry.
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      left: buttonPosition.dx,
      top: buttonPosition.dy - (buttonSize.height * 3), // Adjust as needed.
      child: Material(
        color: Colors.transparent,
        child: _PopupMenu(
          onSelected: (value) {
            onSelected(value);
            overlayEntry.remove(); // Close the menu.
          },
        ),
      ),
    ),
  );

  // Insert the overlay entry into the Overlay.
  Overlay.of(context).insert(overlayEntry);
}

class _PopupMenu extends StatelessWidget {
  final void Function(String) onSelected;

  const _PopupMenu({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuItem(title: "1.25", onSelected: onSelected),
          _MenuItem(title: "1.5", onSelected: onSelected),
          _MenuItem(title: "2", onSelected: onSelected),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final void Function(String) onSelected;

  const _MenuItem({
    required this.title,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(title),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

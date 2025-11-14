import 'package:flutter/material.dart';

class FocusPopup extends StatelessWidget {
  final bool isVisible;
  final String selectedFocus;
  final ValueChanged<String> onFocusSelected;
  final VoidCallback onClose;

  const FocusPopup({
    super.key,
    required this.isVisible,
    required this.selectedFocus,
    required this.onFocusSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> focusOptions = [
      {'name': 'A', 'icon': Icons.auto_awesome},
      {'name': 'M', 'icon': Icons.touch_app},
      {'name': 'C', 'icon': Icons.center_focus_strong},
      {'name': 'T', 'icon': Icons.track_changes},
    ];

    const double popupAlpha = 0.7;
    const double itemAlpha = 0.3;

    return Positioned(
      bottom: 215,
      left: 0,
      right: 0,
      child: Visibility(
        visible: isVisible,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(popupAlpha),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  const Center(
                    child: Text(
                      'Focus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: onClose,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: focusOptions.map((option) {
                  final isSelected = selectedFocus == option['name'];
                  return GestureDetector(
                    onTap: () => onFocusSelected(option['name']),
                    child: Container(
                      width: 70,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : Colors.black.withOpacity(itemAlpha),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          option['icon'] as IconData,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RatioPopup extends StatelessWidget {
  final bool isVisible;
  final String selectedRatio;
  final ValueChanged<String> onRatioSelected;

  const RatioPopup({
    super.key,
    required this.isVisible,
    required this.selectedRatio,
    required this.onRatioSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Visibility(
        visible: isVisible,
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['1:1', '4:3', '16:9', 'Full'].map((ratio) {
                  final isSelected = selectedRatio == ratio;
                  return GestureDetector(
                    onTap: () => onRatioSelected(ratio),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        ratio,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

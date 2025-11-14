import 'package:flutter/material.dart';

class TimerPopup extends StatelessWidget {
  final bool isVisible;
  final String selectedTimer;
  final ValueChanged<String> onTimerSelected;

  const TimerPopup({
    super.key,
    required this.isVisible,
    required this.selectedTimer,
    required this.onTimerSelected,
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
          color: Colors.black.withOpacity(0.85),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['OFF', '3s', '5s', '10s'].map((timer) {
                  final isSelected = selectedTimer == timer;
                  return GestureDetector(
                    onTap: () => onTimerSelected(timer),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        timer,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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

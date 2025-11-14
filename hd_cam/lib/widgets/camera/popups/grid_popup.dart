import 'package:flutter/material.dart';

class GridPopup extends StatelessWidget {
  final bool isVisible;
  final String selectedGrid;
  final ValueChanged<String> onGridSelected;
  final VoidCallback onClose;

  const GridPopup({
    super.key,
    required this.isVisible,
    required this.selectedGrid,
    required this.onGridSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> gridOptions = [
      'None',
      '3x3',
      'Phi 3x3',
      '4x2',
      'Cross',
      'GR.1',
      'GR.2',
      'GR.3',
      'GR.4',
      'Diagonal',
      'Triangle.1',
      'Triangle.2',
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
            color: Colors.black.withValues(alpha: popupAlpha),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  const Center(
                    child: Text(
                      'Grid',
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                ),
                itemCount: gridOptions.length,
                itemBuilder: (context, index) {
                  final option = gridOptions[index];
                  final isSelected = selectedGrid == option;

                  return GestureDetector(
                    onTap: () => onGridSelected(option),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : Colors.black.withValues(alpha: itemAlpha),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          option,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

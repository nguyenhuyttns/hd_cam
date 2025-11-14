import 'package:flutter/material.dart';

class FilterPopup extends StatelessWidget {
  final bool isVisible;
  final String selectedCategory;
  final int selectedFilterIndex;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<int> onFilterSelected;

  const FilterPopup({
    super.key,
    required this.isVisible,
    required this.selectedCategory,
    required this.selectedFilterIndex,
    required this.onCategoryChanged,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['Popular', 'Adventure', 'Blue Shadow', 'Retro'];
    final filterIcons = [
      {'icon': Icons.hdr_strong, 'label': 'AMP'},
      {'icon': Icons.wb_sunny, 'label': 'WB'},
      {'icon': Icons.zoom_in, 'label': '1x'},
      {'icon': Icons.wb_sunny_outlined, 'label': '☀'},
      {'icon': Icons.filter_vintage, 'label': '🥞'},
    ];

    return Positioned(
      bottom: 194, // THAY ĐỔI TỪ 202 → 140 (lui xuống 62px)
      left: 0,
      right: 0,
      child: Visibility(
        visible: isVisible,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final isSelected = category == selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => onCategoryChanged(category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.25)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filterIcons.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == selectedFilterIndex;
                    final filter = filterIcons[index];

                    return GestureDetector(
                      onTap: () => onFilterSelected(index),
                      child: Container(
                        width: 65,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.orange.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: Colors.orange, width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: filter['label'] == '🥞'
                                    ? const Text(
                                        '🥞',
                                        style: TextStyle(fontSize: 24),
                                      )
                                    : Icon(
                                        filter['icon'] as IconData,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              filter['label'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

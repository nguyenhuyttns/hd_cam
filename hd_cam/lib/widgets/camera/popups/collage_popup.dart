import 'package:flutter/material.dart';

class CollagePopup extends StatelessWidget {
  final bool isVisible;
  final String selectedLayout;
  final ValueChanged<String> onLayoutSelected;
  final VoidCallback onClose;

  const CollagePopup({
    super.key,
    required this.isVisible,
    required this.selectedLayout,
    required this.onLayoutSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  const Center(
                    child: Text(
                      'Collage',
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
              _buildCollageGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollageGrid() {
    final layouts = [
      {'id': 'layout1', 'rows': 2, 'cols': 2, 'pattern': '2x2'},
      {'id': 'layout2', 'rows': 2, 'cols': 2, 'pattern': '1+2'},
      {'id': 'layout3', 'rows': 2, 'cols': 2, 'pattern': '2+1'},
      {'id': 'layout4', 'rows': 2, 'cols': 2, 'pattern': '3grid'},
      {'id': 'layout5', 'rows': 2, 'cols': 2, 'pattern': 'vertical'},
      {'id': 'layout6', 'rows': 2, 'cols': 2, 'pattern': 'horizontal'},
      {'id': 'layout7', 'rows': 2, 'cols': 2, 'pattern': '3x3'},
      {'id': 'layout8', 'rows': 2, 'cols': 2, 'pattern': '4grid'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: layouts.length,
      itemBuilder: (context, index) {
        final layout = layouts[index];
        final isSelected = layout['id'] == selectedLayout;

        return GestureDetector(
          onTap: () => onLayoutSelected(layout['id'] as String),
          child: _buildCollageLayout(
            pattern: layout['pattern'] as String,
            isSelected: isSelected,
          ),
        );
      },
    );
  }

  Widget _buildCollageLayout({
    required String pattern,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.5),
          width: isSelected ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: _buildLayoutPattern(pattern),
      ),
    );
  }

  Widget _buildLayoutPattern(String pattern) {
    switch (pattern) {
      case '2x2':
        return _build2x2Layout();
      case '1+2':
        return _build1Plus2Layout();
      case '2+1':
        return _build2Plus1Layout();
      case '3grid':
        return _build3GridLayout();
      case 'vertical':
        return _buildVerticalLayout();
      case 'horizontal':
        return _buildHorizontalLayout();
      case '3x3':
        return _build3x3Layout();
      case '4grid':
        return _build4GridLayout();
      default:
        return _build2x2Layout();
    }
  }

  // Layout 1: 2x2 Grid
  Widget _build2x2Layout() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCell()),
              _buildDivider(vertical: true),
              Expanded(child: _buildCell()),
            ],
          ),
        ),
        _buildDivider(vertical: false),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCell()),
              _buildDivider(vertical: true),
              Expanded(child: _buildCell()),
            ],
          ),
        ),
      ],
    );
  }

  // Layout 2: 1 top + 2 bottom
  Widget _build1Plus2Layout() {
    return Column(
      children: [
        Expanded(flex: 2, child: _buildCell()),
        _buildDivider(vertical: false),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(child: _buildCell()),
              _buildDivider(vertical: true),
              Expanded(child: _buildCell()),
            ],
          ),
        ),
      ],
    );
  }

  // Layout 3: 2 top + 1 bottom
  Widget _build2Plus1Layout() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(child: _buildCell()),
              _buildDivider(vertical: true),
              Expanded(child: _buildCell()),
            ],
          ),
        ),
        _buildDivider(vertical: false),
        Expanded(flex: 2, child: _buildCell()),
      ],
    );
  }

  // Layout 4: 3 Grid (1 left + 2 right)
  Widget _build3GridLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildCell()),
        _buildDivider(vertical: true),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(child: _buildCell()),
              _buildDivider(vertical: false),
              Expanded(child: _buildCell()),
            ],
          ),
        ),
      ],
    );
  }

  // Layout 5: Vertical 3 panels
  Widget _buildVerticalLayout() {
    return Row(
      children: [
        Expanded(child: _buildCell()),
        _buildDivider(vertical: true),
        Expanded(child: _buildCell()),
        _buildDivider(vertical: true),
        Expanded(child: _buildCell()),
      ],
    );
  }

  // Layout 6: Horizontal 3 panels
  Widget _buildHorizontalLayout() {
    return Column(
      children: [
        Expanded(child: _buildCell()),
        _buildDivider(vertical: false),
        Expanded(child: _buildCell()),
        _buildDivider(vertical: false),
        Expanded(child: _buildCell()),
      ],
    );
  }

  // Layout 7: 3x3 Grid
  Widget _build3x3Layout() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCell()),
              _buildDivider(vertical: true),
              Expanded(child: _buildCell()),
              _buildDivider(vertical: true),
              Expanded(child: _buildCell()),
            ],
          ),
        ),
        _buildDivider(vertical: false),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCell()),
              _buildDivider(vertical: true),
              Expanded(child: _buildCell()),
              _buildDivider(vertical: true),
              Expanded(child: _buildCell()),
            ],
          ),
        ),
        _buildDivider(vertical: false),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCell()),
              _buildDivider(vertical: true),
              Expanded(child: _buildCell()),
              _buildDivider(vertical: true),
              Expanded(child: _buildCell()),
            ],
          ),
        ),
      ],
    );
  }

  // Layout 8: 4 Grid with center cross
  Widget _build4GridLayout() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCell()),
              _buildDivider(vertical: true),
              Expanded(child: _buildCell()),
            ],
          ),
        ),
        _buildDivider(vertical: false),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCell()),
              _buildDivider(vertical: true),
              Expanded(child: _buildCell()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCell() {
    return Container(color: Colors.grey[800]);
  }

  Widget _buildDivider({required bool vertical}) {
    return Container(
      width: vertical ? 2 : double.infinity,
      height: vertical ? double.infinity : 2,
      color: Colors.white.withOpacity(0.3),
    );
  }
}

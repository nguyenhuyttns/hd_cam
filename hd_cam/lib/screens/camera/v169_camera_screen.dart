import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/colors.dart';

class V169CameraScreen extends StatefulWidget {
  const V169CameraScreen({super.key});

  @override
  State<V169CameraScreen> createState() => _V169CameraScreenState();
}

class _V169CameraScreenState extends State<V169CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isLoading = true;
  String _error = '';
  int _currentCameraIndex = 0;

  // UI State - Top Controls
  bool _showTopControls = true;
  bool _showBottomControls = true;
  
  // UI State - Popups (chỉ 1 popup hiển thị tại 1 thời điểm)
  bool _showRatioPopup = false;
  bool _showTimerPopup = false;
  bool _showFilterPopup = false;
  bool _showMorePopup = false;
  bool _showGridPopup = false;
  
  // UI State - Settings
  bool _isFlashOn = false;
  String _selectedRatio = "Full";
  String _selectedTimer = "OFF";
  String _selectedFilter = "None";
  String _selectedGrid = "None";
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        setState(() {
          _error = 'Camera permission denied';
          _isLoading = false;
        });
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _error = 'No cameras available';
          _isLoading = false;
        });
        return;
      }

      await _setupCamera(_currentCameraIndex);
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to setup camera: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          _buildCameraPreview(),
          
          // Top Controls - Positioned like Android layout
          _buildTopControls(),
          
          // Popups - Positioned overlays (chỉ hiển thị 1 tại 1 thời điểm)
          _buildRatioPopup(),
          _buildTimerPopup(), 
          _buildFilterPopup(),
          _buildMorePopup(),
          _buildGridPopup(),
          
          // Loading/Error overlay
          if (_isLoading || _error.isNotEmpty) _buildStatusOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Positioned.fill(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showTopControls,
        child: SafeArea(
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
            child: Row(
              children: [
                // Back Button - tương ứng ivBack trong Android
                Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(left: 24, top: 9, bottom: 12),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                
                // Expanded space để center các controls
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Ratio Button - tương ứng tvRatio trong Android
                      GestureDetector(
                        onTap: () {
                          _hideAllPopups();
                          setState(() {
                            _showRatioPopup = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedRatio,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      
                      // Flash Button - tương ứng ivFlash trong Android
                      IconButton(
                        onPressed: _toggleFlash,
                        icon: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      
                      // Timer Button - tương ứng ivTimer trong Android
                      IconButton(
                        onPressed: () {
                          _hideAllPopups();
                          setState(() {
                            _showTimerPopup = true;
                          });
                        },
                        icon: const Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      
                      // Filter Button - tương ứng ivFilter trong Android
                      IconButton(
                        onPressed: () {
                          _hideAllPopups();
                          setState(() {
                            _showFilterPopup = true;
                          });
                        },
                        icon: const Icon(
                          Icons.filter,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // More Button - tương ứng ivMore trong Android
                Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(right: 24),
                  child: IconButton(
                    onPressed: () {
                      _hideAllPopups();
                      setState(() {
                        _showMorePopup = true;
                      });
                    },
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatioPopup() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showRatioPopup,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 60), // Dưới top controls
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Aspect Ratio",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['1:1', '4:3', '16:9', 'Full'].map((ratio) {
                    final isSelected = _selectedRatio == ratio;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRatio = ratio;
                          _showRatioPopup = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.white,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          ratio,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildTimerPopup() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showTimerPopup,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Timer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['OFF', '3s', '5s', '10s'].map((timer) {
                    final isSelected = _selectedTimer == timer;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimer = timer;
                          _showTimerPopup = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.white,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          timer,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildFilterPopup() {
    return Positioned(
      bottom: 100, // Positioned at bottom như Android
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showFilterPopup,
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
          ),
          child: Column(
            children: [
              const Text(
                "Filters",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Filter categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Popular', 'Adventure', 'Blue Shadow', 'Retro'].map((category) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              // Filter items placeholder
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(8),
                        border: index == 0 ? Border.all(color: AppColors.primary, width: 2) : null,
                      ),
                      child: Center(
                        child: Text(
                          'F${index + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
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

  Widget _buildMorePopup() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showMorePopup,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 60), // Dưới top controls
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "More Options",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                // Hiển thị ngang như Ratio và Timer
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildMoreMenuItem(Icons.hd, "Resolution"),
                    _buildMoreMenuItem(Icons.grid_on, "Grid"),
                    _buildMoreMenuItem(Icons.center_focus_strong, "Focus"),
                    _buildMoreMenuItem(Icons.exposure, "Exposure"),
                    _buildMoreMenuItem(Icons.view_comfy, "Collage"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreMenuItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showMorePopup = false;
        });
        
        // Handle specific menu item actions
        if (label == "Grid") {
          setState(() {
            _showGridPopup = true;
          });
        }
        // Add other menu actions here
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridPopup() {
    // Grid options theo Android: None, 3x3, 4x2, Cross, GR.2, GR.3, GR.4, Diagonal, Triangle.2, Triangle
    final List<String> gridOptions = [
      'None', '3x3', '4x2', 'Cross', 'GR.2', 'GR.3', 'GR.4', 'Diagonal', 'Triangle.2', 'Triangle'
    ];

    return Positioned(
      bottom: 100, // Positioned at bottom như Android layout
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showGridPopup,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10), // layout_marginHorizontal="10dp"
          padding: const EdgeInsets.only(bottom: 18), // paddingBottom="18dp"
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5), // bg_corner_16_soild_black50
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header với title và close button
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: Row(
                  children: [
                    const Spacer(),
                    // Title "Grid" ở giữa
                    const Text(
                      "Grid",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Close button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showGridPopup = false;
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Grid options trong GridView 4 cột như Android
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), // layout_marginHorizontal="18dp"
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // spanCount="4"
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: gridOptions.length,
                  itemBuilder: (context, index) {
                    final gridOption = gridOptions[index];
                    final isSelected = _selectedGrid == gridOption;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGrid = gridOption;
                          _showGridPopup = false;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(2), // layout_margin="2dp"
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.primary 
                              : Colors.black.withValues(alpha: 0.3), // black_30
                          borderRadius: BorderRadius.circular(10), // cardCornerRadius="10dp"
                          border: isSelected 
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            gridOption,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
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

  Widget _buildStatusOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) ...[
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Initializing camera...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ] else if (_error.isNotEmpty) ...[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  _error,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = '';
                      _isLoading = true;
                    });
                    _initializeCamera();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _hideAllPopups() {
    setState(() {
      _showRatioPopup = false;
      _showTimerPopup = false;
      _showFilterPopup = false;
      _showMorePopup = false;
      _showGridPopup = false;
    });
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_isInitialized) return;
    
    // Only allow flash on back camera
    if (_cameras[_currentCameraIndex].lensDirection == CameraLensDirection.front) {
      return;
    }
    
    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }
}

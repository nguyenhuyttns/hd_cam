import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../app/config/colors.dart';
import '../gallery/gallery_screen.dart';
import '../../services/photo_storage_service.dart';
import '../../services/white_balance_service.dart';

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

  // UI State
  bool _showTopControls = true;
  bool _showBottomControls = true;
  bool _hideTopControlsForPopup = false;

  // Popups
  bool _showRatioPopup = false;
  bool _showTimerPopup = false;
  bool _showFilterPopup = false;
  bool _showMorePopup = false;
  bool _showWBPopup = false;
  bool _showGridPopup = false;
  bool _showFocusPopup = false;
  bool _showExposurePopup = false;
  bool _showCollagePopup = false;
  bool _showAmpPopup = false; // AMP popup
  bool _showZoomPopup = false; // Zoom popup
  bool _showBrightnessPopup = false; // Brightness popup

  // Settings
  bool _isFlashOn = false;
  String _selectedRatio = "16:9";
  String _selectedTimer = "OFF";
  String _selectedGrid = "None";
  String _selectedFocus = "A";
  String _selectedCollage = "Layout1";
  double _selectedExposure = 0.0;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 8.0;
  double _currentBrightness = 0.0;
  double _ampValue = 0.5; // 0.0 -> 1.0 (0% -> 100%)
  final WhiteBalanceService _whiteBalanceService = WhiteBalanceService();

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
      _maxZoom = await _controller!.getMaxZoomLevel();
      _minZoom = await _controller!.getMinZoomLevel();
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
      body: GestureDetector(
        onTap: () {
          if (_showMorePopup ||
              _showFilterPopup ||
              _showWBPopup ||
              _showGridPopup ||
              _showFocusPopup ||
              _showExposurePopup ||
              _showCollagePopup ||
              _showAmpPopup ||
              _showZoomPopup ||
              _showBrightnessPopup) {
            setState(() {
              _showMorePopup = false;
              _showFilterPopup = false;
              _showWBPopup = false;
              _showGridPopup = false;
              _showFocusPopup = false;
              _showExposurePopup = false;
              _showCollagePopup = false;
              _showAmpPopup = false;
              _showZoomPopup = false;
              _showBrightnessPopup = false;
            });
          }
        },
        child: Stack(
          children: [
            _buildCameraPreview(),
            _buildTopControls(),
            _buildBottomControlsArea(),
            _buildRatioPopup(),
            _buildTimerPopup(),
            _buildFilterPopup(),
            _buildMorePopup(),
            _buildWBPopup(),
            _buildGridPopup(),
            _buildFocusPopup(),
            _buildExposurePopup(),
            _buildAmpPopup(),
            _buildZoomPopup(),
            _buildBrightnessPopup(),
            _buildCollagePopup(),
            if (_isLoading || _error.isNotEmpty) _buildStatusOverlay(),
          ],
        ),
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

    return Positioned.fill(child: CameraPreview(_controller!));
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showTopControls && !_hideTopControlsForPopup,
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _hideAllPopups();
                            setState(() {
                              _showRatioPopup = true;
                              _hideTopControlsForPopup = true;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _selectedRatio,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleFlash,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              _isFlashOn ? Icons.flash_on : Icons.flash_off,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _hideAllPopups();
                            setState(() {
                              _showTimerPopup = true;
                              _hideTopControlsForPopup = true;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.timer_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _hideAllPopups();
                            setState(() {
                              _showFilterPopup = true;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.filter_vintage_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _hideAllPopups();
                            setState(() {
                              _showMorePopup = true;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControlsArea() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showBottomControls,
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                _buildMiddleControls(),
                const SizedBox(height: 16),
                _buildModeSelector(),
                const SizedBox(height: 20),
                _buildBottomNavigation(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiddleControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              _hideAllPopups();
              setState(() {
                _showAmpPopup = true;
              });
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'AMP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _hideAllPopups();
              setState(() {
                _showWBPopup = true;
              });
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'WB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _hideAllPopups();
              setState(() {
                _showZoomPopup = true;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${_currentZoom.toStringAsFixed(1)}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _hideAllPopups();
              setState(() {
                _showBrightnessPopup = true;
              });
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.wb_sunny_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeButton('Photo', true),
        const SizedBox(width: 32),
        _buildModeButton('Video', false),
      ],
    );
  }

  Widget _buildModeButton(String label, bool isSelected) {
    return Text(
      label,
      style: TextStyle(
        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
        fontSize: 16,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GalleryScreen()),
              );
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          GestureDetector(
            onTap: _takePicture,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5),
              ),
              child: Container(
                margin: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _switchCamera,
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(
                Icons.flip_camera_ios_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
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
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['1:1', '4:3', '16:9', 'Full'].map((ratio) {
                  final isSelected = _selectedRatio == ratio;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRatio = ratio;
                        _showRatioPopup = false;
                        _hideTopControlsForPopup = false;
                      });
                    },
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

  Widget _buildTimerPopup() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showTimerPopup,
        child: Container(
          color: Colors.black.withValues(alpha: 0.85),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['OFF', '3s', '5s', '10s'].map((timer) {
                  final isSelected = _selectedTimer == timer;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimer = timer;
                        _showTimerPopup = false;
                        _hideTopControlsForPopup = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
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

  Widget _buildFilterPopup() {
    return Positioned(
      bottom: 202,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showFilterPopup,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Popular', 'Adventure', 'Blue Shadow', 'Retro']
                      .map((category) {
                        final isSelected = category == 'Popular';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
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
                      })
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final filterIcons = [
                      {'icon': Icons.hdr_strong, 'label': 'AMP'},
                      {'icon': Icons.wb_sunny, 'label': 'WB'},
                      {'icon': Icons.zoom_in, 'label': '1x'},
                      {'icon': Icons.wb_sunny_outlined, 'label': '☀'},
                      {'icon': Icons.filter_vintage, 'label': '🥞'},
                    ];

                    final isSelected = index == 4;
                    final filter = filterIcons[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _showFilterPopup = false;
                        });
                      },
                      child: Container(
                        width: 65,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.orange.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.25),
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
                                color: Colors.grey.withValues(alpha: 0.4),
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

  Widget _buildMorePopup() {
    return Positioned(
      top: 90,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showMorePopup,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMoreOptionItem(
                Icons.grid_on,
                'Grid',
                onTap: () {
                  setState(() {
                    _showMorePopup = false;
                    _showGridPopup = true;
                  });
                },
              ),
              _buildMoreOptionItem(
                Icons.center_focus_strong,
                'Focus',
                onTap: () {
                  setState(() {
                    _showMorePopup = false;
                    _showFocusPopup = true;
                  });
                },
              ),
              _buildMoreOptionItem(
                Icons.exposure,
                'Exposure',
                onTap: () {
                  setState(() {
                    _showMorePopup = false;
                    _showExposurePopup = true;
                  });
                },
              ),
              _buildMoreOptionItem(Icons.hd_outlined, 'Resolution'),
              _buildMoreOptionItem(
                Icons.view_comfy_outlined,
                'Collage',
                onTap: () {
                  setState(() {
                    _showMorePopup = false;
                    _showCollagePopup = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreOptionItem(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            setState(() {
              _showMorePopup = false;
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$label clicked')));
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridPopup() {
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
        visible: _showGridPopup,
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
                      onTap: () {
                        setState(() {
                          _showGridPopup = false;
                        });
                      },
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
                  final isSelected = _selectedGrid == option;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGrid = option;
                        _showGridPopup = false;
                      });
                    },
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

  Widget _buildFocusPopup() {
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
        visible: _showFocusPopup,
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
                      onTap: () {
                        setState(() {
                          _showFocusPopup = false;
                        });
                      },
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
                  final isSelected = _selectedFocus == option['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFocus = option['name'];
                        _showFocusPopup = false;
                      });
                    },
                    child: Container(
                      width: 70,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : Colors.black.withValues(alpha: itemAlpha),
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

  Widget _buildExposurePopup() {
    const double popupAlpha = 0.7;

    return Positioned(
      bottom: 215,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showExposurePopup,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      'Exposure',
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
                      onTap: () {
                        setState(() {
                          _showExposurePopup = false;
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    '-2EV',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Expanded(
                    child: Slider(
                      value: _selectedExposure,
                      min: -2.0,
                      max: 2.0,
                      divisions: 40,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white.withValues(alpha: 0.3),
                      onChanged: (value) {
                        setState(() {
                          _selectedExposure = value;
                        });
                        _controller?.setExposureOffset(value);
                      },
                    ),
                  ),
                  const Text(
                    '+2EV',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // AMP POPUP
  Widget _buildAmpPopup() {
    const double popupAlpha = 0.7;

    return Positioned(
      bottom: 215,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showAmpPopup,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: popupAlpha),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Text(
                '${(_ampValue * 100).round()}%',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: _ampValue,
                  min: 0.0,
                  max: 1.0,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withValues(alpha: 0.3),
                  onChanged: (value) {
                    setState(() {
                      _ampValue = value;
                      // TODO: apply AMP strength to processing if cần
                    });
                  },
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ZOOM POPUP
  Widget _buildZoomPopup() {
    const double popupAlpha = 0.7;

    return Positioned(
      bottom: 215,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showZoomPopup,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: popupAlpha),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Text(
                '${_minZoom.toStringAsFixed(1)}x',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: _currentZoom,
                  min: _minZoom,
                  max: _maxZoom,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withValues(alpha: 0.3),
                  onChanged: (value) async {
                    setState(() {
                      _currentZoom = value;
                    });
                    await _controller?.setZoomLevel(value);
                  },
                ),
              ),
              Text(
                '${_maxZoom.toStringAsFixed(1)}x',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BRIGHTNESS POPUP
  Widget _buildBrightnessPopup() {
    const double popupAlpha = 0.7;

    return Positioned(
      bottom: 215,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showBrightnessPopup,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: popupAlpha),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Text(
                '${(_currentBrightness * 100).round()}%',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: _currentBrightness,
                  min: 0.0,
                  max: 1.0,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withValues(alpha: 0.3),
                  onChanged: (value) async {
                    setState(() {
                      _currentBrightness = value;
                    });
                    await _controller?.setExposureOffset(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollagePopup() {
    // Collage layouts như trong hình
    final List<String> collageLayouts = [
      'Layout1',
      'Layout2',
      'Layout3',
      'Layout4',
      'Layout5',
      'Layout6',
      'Layout7',
    ];

    const double popupAlpha = 0.7;
    const double itemAlpha = 0.3;

    return Positioned(
      bottom: 215,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showCollagePopup,
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
                      onTap: () {
                        setState(() {
                          _showCollagePopup = false;
                        });
                      },
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
                  childAspectRatio: 1.0,
                ),
                itemCount: collageLayouts.length,
                itemBuilder: (context, index) {
                  final layout = collageLayouts[index];
                  final isSelected = _selectedCollage == layout;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCollage = layout;
                        _showCollagePopup = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : Colors.black.withValues(alpha: itemAlpha),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: _buildCollageIcon(index)),
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

  Widget _buildCollageIcon(int index) {
    // Tạo các icon đại diện cho collage layouts
    switch (index) {
      case 0: // Single
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      case 1: // 2 vertical
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      case 2: // 2 horizontal
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      case 3: // 2x2 grid
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 4: // 3 vertical
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 2 ? 2 : 0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        );
      case 5: // 3 horizontal
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: i < 2 ? 2 : 0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        );
      case 6: // 3x3 grid
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: List.generate(3, (row) {
              return Expanded(
                child: Row(
                  children: List.generate(3, (col) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: col < 2 ? 2 : 0,
                          bottom: row < 2 ? 2 : 0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        );
      default:
        return const Icon(Icons.view_comfy, color: Colors.white, size: 24);
    }
  }

  Widget _buildCollageLayoutPreview(String type) {
    switch (type) {
      case 'single':
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      case 'vertical_split':
        return Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        );
      case 'horizontal_split':
        return Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        );
      case 'grid_2x2':
        return GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          padding: const EdgeInsets.all(8),
          children: List.generate(
            4,
            (index) => Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      case 'vertical_3':
        return Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: index == 0 ? 8 : 1,
                  right: index == 2 ? 8 : 1,
                  top: 8,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        );
      case 'horizontal_3':
        return Column(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  top: index == 0 ? 8 : 1,
                  bottom: index == 2 ? 8 : 1,
                  left: 8,
                  right: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        );
      case 'grid_3x3':
        return GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          padding: const EdgeInsets.all(8),
          children: List.generate(
            9,
            (index) => Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildWBPopup() {
    final List<Map<String, dynamic>> wbOptions = [
      {'name': 'Default', 'mode': WhiteBalanceMode.DEFAULT},
      {'name': 'Foggy', 'mode': WhiteBalanceMode.FOGGY},
      {'name': 'Daylight', 'mode': WhiteBalanceMode.DAYLIGHT},
      {'name': 'Spike', 'mode': WhiteBalanceMode.SPIKE},
      {'name': 'Gloom', 'mode': WhiteBalanceMode.GLOAM},
    ];

    return Positioned(
      bottom: 215,
      left: 0,
      right: 0,
      child: Visibility(
        visible: _showWBPopup,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: wbOptions.map((option) {
              final isSelected =
                  _whiteBalanceService.currentMode == option['mode'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _whiteBalanceService.setWhiteBalance(option['mode']);
                    _showWBPopup = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    option['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.orange : Colors.white,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
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
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
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
      _showWBPopup = false;
      _showGridPopup = false;
      _showFocusPopup = false;
      _showExposurePopup = false;
      _showCollagePopup = false;
      _showAmpPopup = false;
      _showZoomPopup = false;
      _showBrightnessPopup = false;
      if (!_showTimerPopup && !_showRatioPopup) {
        _hideTopControlsForPopup = false;
      }
    });
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_isInitialized) return;
    if (_cameras[_currentCameraIndex].lensDirection ==
        CameraLensDirection.front)
      return;

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
      // ignore: avoid_print
      print('Error toggling flash: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_isInitialized) return;

    try {
      final XFile image = await _controller!.takePicture();
      File imageFile = File(image.path);

      if (_whiteBalanceService.currentMode != WhiteBalanceMode.DEFAULT) {
        imageFile = await _whiteBalanceService.applyWhiteBalanceToImage(
          imageFile,
        );
      }

      final fileName = await PhotoStorageService.savePhoto(imageFile);
      await imageFile.delete();

      if (mounted) {
        if (fileName != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo saved: $fileName'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save photo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other camera available')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    });

    await _setupCamera(_currentCameraIndex);
  }

  void _showZoomSlider() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Zoom',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        '${_minZoom.toStringAsFixed(1)}x',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: _currentZoom,
                          min: _minZoom,
                          max: _maxZoom,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withValues(alpha: 0.3),
                          onChanged: (value) async {
                            setModalState(() {
                              _currentZoom = value;
                            });
                            setState(() {
                              _currentZoom = value;
                            });
                            await _controller?.setZoomLevel(value);
                          },
                        ),
                      ),
                      Text(
                        '${_maxZoom.toStringAsFixed(1)}x',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_currentZoom.toStringAsFixed(1)}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showBrightnessSlider() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Brightness',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.brightness_low, color: Colors.white),
                      Expanded(
                        child: Slider(
                          value: _currentBrightness,
                          min: -1.0,
                          max: 1.0,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withValues(alpha: 0.3),
                          onChanged: (value) async {
                            setModalState(() {
                              _currentBrightness = value;
                            });
                            setState(() {
                              _currentBrightness = value;
                            });
                            await _controller?.setExposureOffset(value);
                          },
                        ),
                      ),
                      const Icon(Icons.brightness_high, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentBrightness.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

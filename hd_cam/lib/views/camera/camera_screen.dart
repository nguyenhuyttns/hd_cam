import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import '../../widgets/camera/top_controls.dart';
import '../../widgets/camera/mid_controls.dart';
import '../../widgets/camera/bottom_controls.dart';

class V169CameraScreen extends StatefulWidget {
  const V169CameraScreen({super.key});

  @override
  State<V169CameraScreen> createState() => _V169CameraScreenState();
}

class _V169CameraScreenState extends State<V169CameraScreen> {
  // UI State
  bool _showTopControls = true;
  bool _showMidControls = true;
  bool _showBottomControls = true;
  bool _showRatioPopup = false;
  bool _showTimerPopup = false;
  bool _showToolPopup = false;
  bool _showMorePopup = false;

  // Settings
  String _selectedRatio = "16:9";
  bool _isFlashOn = false;
  String _selectedTimer = "OFF";
  double _currentZoom = 1.0;
  bool _isLoading = false;

  // Camera state
  CameraState? _cameraState;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _hideAllPopups() {
    setState(() {
      _showRatioPopup = false;
      _showTimerPopup = false;
      _showToolPopup = false;
      _showMorePopup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            if (_showRatioPopup ||
                _showTimerPopup ||
                _showToolPopup ||
                _showMorePopup) {
              _hideAllPopups();
            }
          },
          child: Stack(
            children: [
              // Camera Preview
              CameraAwesomeBuilder.awesome(
                saveConfig: SaveConfig.photoAndVideo(
                  initialCaptureMode: CaptureMode.photo,
                ),
                sensorConfig: SensorConfig.single(
                  sensor: Sensor.position(SensorPosition.back),
                  flashMode: _isFlashOn ? FlashMode.on : FlashMode.none,
                ),
                previewFit: CameraPreviewFit.cover,
                enablePhysicalButton: true,
                onMediaTap: (mediaCapture) {
                  debugPrint('=== Photo Captured ===');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📸 Photo saved successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                topActionsBuilder: (state) {
                  _cameraState = state;
                  return const SizedBox.shrink();
                },
                middleContentBuilder: (state) => const SizedBox.shrink(),
                bottomActionsBuilder: (state) => const SizedBox.shrink(),
              ),

              // Top Controls
              TopControls(
                showTopControls: _showTopControls,
                selectedRatio: _selectedRatio,
                isFlashOn: _isFlashOn,
                showRatioPopup: _showRatioPopup,
                showTimerPopup: _showTimerPopup,
                showToolPopup: _showToolPopup,
                showMorePopup: _showMorePopup,
                onBackPressed: () => Navigator.of(context).pop(),
                onRatioPressed: () {
                  setState(() {
                    _hideAllPopups();
                    _showRatioPopup = !_showRatioPopup;
                  });
                },
                onFlashPressed: () {
                  setState(() {
                    _isFlashOn = !_isFlashOn;
                  });
                },
                onTimerPressed: () {
                  setState(() {
                    _hideAllPopups();
                    _showTimerPopup = !_showTimerPopup;
                  });
                },
                onToolPressed: () {
                  setState(() {
                    _hideAllPopups();
                    _showToolPopup = !_showToolPopup;
                  });
                },
                onMorePressed: () {
                  setState(() {
                    _hideAllPopups();
                    _showMorePopup = !_showMorePopup;
                  });
                },
              ),

              // Mid Controls
              MidControls(
                showMidControls: _showMidControls,
                currentZoom: _currentZoom,
                onAmpPressed: () {
                  debugPrint('AMP pressed');
                },
                onWBPressed: () {
                  debugPrint('WB pressed');
                },
                onZoomPressed: () {
                  debugPrint('Zoom pressed');
                },
                onBrightnessPressed: () {
                  debugPrint('Brightness pressed');
                },
              ),

              // Bottom Controls
              BottomControls(
                showBottomControls: _showBottomControls,
                isLoading: _isLoading,
                onGalleryPressed: () {
                  debugPrint('Gallery pressed');
                  // Navigator.push(context, MaterialPageRoute(...));
                },
                onCapturePressed: () {
                  debugPrint('Capture pressed');
                  // Trigger camera capture
                },
                onSwitchCameraPressed: () async {
                  setState(() => _isLoading = true);

                  // Switch camera using CameraAwesome state
                  if (_cameraState != null) {
                    await _cameraState!.switchCameraSensor();
                  }

                  setState(() => _isLoading = false);
                },
              ),

              // Popups
              if (_showRatioPopup) _buildRatioPopup(),
              if (_showTimerPopup) _buildTimerPopup(),
              if (_showToolPopup) _buildToolPopup(),
              if (_showMorePopup) _buildMorePopup(),
            ],
          ),
        ),
      ),
    );
  }

  // Ratio Popup
  Widget _buildRatioPopup() {
    final ratios = ["16:9", "4:3", "1:1", "Full"];

    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ratios.map((ratio) {
              final isSelected = ratio == _selectedRatio;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRatio = ratio;
                    _showRatioPopup = false;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  color: isSelected
                      ? Colors.white.withOpacity(0.15)
                      : Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ratio,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Timer Popup
  Widget _buildTimerPopup() {
    final timers = ["OFF", "3s", "5s", "10s"];

    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: timers.map((timer) {
              final isSelected = timer == _selectedTimer;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimer = timer;
                    _showTimerPopup = false;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  color: isSelected
                      ? Colors.white.withOpacity(0.15)
                      : Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timer,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Tool Popup
  Widget _buildToolPopup() {
    final tools = [
      {"icon": Icons.wb_sunny_outlined, "label": "Brightness"},
      {"icon": Icons.contrast, "label": "Contrast"},
      {"icon": Icons.wb_incandescent_outlined, "label": "White Balance"},
      {"icon": Icons.grid_on, "label": "Grid"},
    ];

    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: tools.map((tool) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _showToolPopup = false;
                  });
                  debugPrint('Selected: ${tool["label"]}');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tool["icon"] as IconData,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        tool["label"] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // More Popup
  Widget _buildMorePopup() {
    final moreOptions = [
      {"icon": Icons.filter_vintage, "label": "Filters"},
      {"icon": Icons.photo_size_select_small, "label": "Collage"},
      {"icon": Icons.settings, "label": "Settings"},
      {"icon": Icons.help_outline, "label": "Help"},
    ];

    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: moreOptions.map((option) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _showMorePopup = false;
                  });
                  debugPrint('Selected: ${option["label"]}');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        option["icon"] as IconData,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        option["label"] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

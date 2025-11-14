import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import '../../widgets/camera/top_controls.dart';
import '../../widgets/camera/mid_controls.dart';
import '../../widgets/camera/bottom_controls.dart';
import '../../widgets/camera/popups/ratio_popup.dart';
import '../../widgets/camera/popups/timer_popup.dart';
import '../../widgets/camera/popups/filter_popup.dart';
import '../../widgets/camera/popups/more_popup.dart';

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
  bool _showFilterPopup = false;
  bool _showMorePopup = false;

  // Settings
  String _selectedRatio = "16:9";
  bool _isFlashOn = false;
  String _selectedTimer = "OFF";
  String _selectedFilterCategory = 'Popular';
  int _selectedFilterIndex = 0;
  double _currentZoom = 1.0;
  bool _isLoading = false;

  // Camera state
  CameraState? _cameraState;

  // Check if any popup is visible
  bool get _hasActivePopup =>
      _showRatioPopup || _showTimerPopup || _showFilterPopup || _showMorePopup;

  // Check if popup that hides top controls is active (ONLY ratio/timer)
  bool get _shouldHideTopControls => _showRatioPopup || _showTimerPopup;

  void _hideAllPopupsExcept(String popup) {
    setState(() {
      _showRatioPopup = popup == 'ratio';
      _showTimerPopup = popup == 'timer';
      _showFilterPopup = popup == 'filter';
      _showMorePopup = popup == 'more';

      // CHỈ ẨN top controls khi mở ratio/timer popup
      if (popup == 'ratio' || popup == 'timer') {
        _showTopControls = false;
      } else {
        // Filter và More popup KHÔNG ẨN top controls
        _showTopControls = true;
      }
    });
  }

  void _hideAllPopups() {
    setState(() {
      _showRatioPopup = false;
      _showTimerPopup = false;
      _showFilterPopup = false;
      _showMorePopup = false;

      // Hiện lại top controls khi đóng popup
      _showTopControls = true;
    });
  }

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
            if (_hasActivePopup) {
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

              // Top Controls - CHỈ ẨN khi có ratio/timer popup
              TopControls(
                showTopControls: _showTopControls && !_shouldHideTopControls,
                selectedRatio: _selectedRatio,
                isFlashOn: _isFlashOn,
                showRatioPopup: _showRatioPopup,
                showTimerPopup: _showTimerPopup,
                showToolPopup: _showFilterPopup,
                showMorePopup: _showMorePopup,
                onBackPressed: () => Navigator.of(context).pop(),
                onRatioPressed: () {
                  _hideAllPopupsExcept('ratio');
                },
                onFlashPressed: () {
                  setState(() {
                    _isFlashOn = !_isFlashOn;
                  });
                },
                onTimerPressed: () {
                  _hideAllPopupsExcept('timer');
                },
                onToolPressed: () {
                  _hideAllPopupsExcept('filter');
                },
                onMorePressed: () {
                  _hideAllPopupsExcept('more');
                },
              ),

              // Mid Controls - GIỮ NGUYÊN CỐ ĐỊNH
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

              // Bottom Controls - GIỮ NGUYÊN CỐ ĐỊNH
              BottomControls(
                showBottomControls: _showBottomControls,
                isLoading: _isLoading,
                onGalleryPressed: () {
                  debugPrint('Gallery pressed');
                },
                onCapturePressed: () {
                  debugPrint('Capture pressed');
                },
                onSwitchCameraPressed: () async {
                  setState(() => _isLoading = true);

                  if (_cameraState != null) {
                    await _cameraState!.switchCameraSensor();
                  }

                  setState(() => _isLoading = false);
                },
              ),

              // Popups - Hiển thị lên trên cùng
              if (_showRatioPopup)
                RatioPopup(
                  isVisible: _showRatioPopup,
                  selectedRatio: _selectedRatio,
                  onRatioSelected: (ratio) {
                    setState(() {
                      _selectedRatio = ratio;
                      _hideAllPopups();
                    });
                  },
                ),

              if (_showTimerPopup)
                TimerPopup(
                  isVisible: _showTimerPopup,
                  selectedTimer: _selectedTimer,
                  onTimerSelected: (timer) {
                    setState(() {
                      _selectedTimer = timer;
                      _hideAllPopups();
                    });
                  },
                ),

              if (_showFilterPopup)
                FilterPopup(
                  isVisible: _showFilterPopup,
                  selectedCategory: _selectedFilterCategory,
                  selectedFilterIndex: _selectedFilterIndex,
                  onCategoryChanged: (category) {
                    setState(() {
                      _selectedFilterCategory = category;
                    });
                  },
                  onFilterSelected: (index) {
                    setState(() {
                      _selectedFilterIndex = index;
                      _hideAllPopups();
                    });
                  },
                ),

              if (_showMorePopup)
                MorePopup(
                  isVisible: _showMorePopup,
                  onGridTap: () {
                    setState(() {
                      _hideAllPopups();
                    });
                  },
                  onFocusTap: () {
                    setState(() {
                      _hideAllPopups();
                    });
                  },
                  onExposureTap: () {
                    setState(() {
                      _hideAllPopups();
                    });
                  },
                  onCollageTap: () {
                    setState(() {
                      _hideAllPopups();
                    });
                  },
                  onClose: () {
                    setState(() {
                      _hideAllPopups();
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

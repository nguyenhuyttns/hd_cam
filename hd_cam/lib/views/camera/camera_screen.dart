import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import '../../widgets/camera/top_controls.dart';
import '../../widgets/camera/mid_controls.dart';
import '../../widgets/camera/bottom_controls.dart';
import '../../widgets/camera/popups/ratio_popup.dart';
import '../../widgets/camera/popups/timer_popup.dart';
import '../../widgets/camera/popups/filter_popup.dart';
import '../../widgets/camera/popups/more_popup.dart';
import '../../widgets/camera/popups/amp_popup.dart';
import '../../widgets/camera/popups/wb_popup.dart';
import '../../widgets/camera/popups/zoom_popup.dart';
import '../../widgets/camera/popups/brightness_popup.dart';
import '../../view_models/camera_view_model.dart';
import '../../widgets/camera/popups/grid_popup.dart';
import '../../widgets/camera/popups/focus_popup.dart';
import '../../widgets/camera/popups/exposure_popup.dart';
import '../../widgets/camera/popups/collage_popup.dart';
import '../gallery/gallery_screen.dart';
import '../../services/photo_storage_service.dart';

class V169CameraScreen extends StatefulWidget {
  const V169CameraScreen({super.key});

  @override
  State<V169CameraScreen> createState() => _V169CameraScreenState();
}

class _V169CameraScreenState extends State<V169CameraScreen>
    with WidgetsBindingObserver {
  final CameraViewModel _vm = CameraViewModel();

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  bool get _hasActivePopup => _vm.hasActivePopup;
  bool get _shouldHideTopControls => _vm.shouldHideTopControls;

  void _hideAllPopupsExcept(String popup) {
    setState(() {
      _vm.hideAllPopupsExcept(popup);
    });
  }

  void _hideAllPopups() {
    setState(() {
      _vm.hideAllPopups();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeCamera();
    _loadLastPhoto();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('❌ No cameras available');
        return;
      }

      await _setupCamera(_currentCameraIndex);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    final camera = _cameras[cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error setting up camera: $e');
    }
  }

  Future<void> _loadLastPhoto() async {
    try {
      final photos = await PhotoStorageService.getAllPhotos();
      if (photos.isNotEmpty && mounted) {
        setState(() {
          _vm.updateLastCapturedPhoto(photos.first.filePath);
        });
      }
    } catch (e) {
      debugPrint('Error loading last photo: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _recordingTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera(_currentCameraIndex);
    }
  }

  // CHỤP ẢNH - ĐƠN GIẢN
  Future<void> _capturePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _vm.isCapturing ||
        _vm.isRecording) {
      return;
    }

    setState(() {
      _vm.setCapturing(true);
    });

    try {
      debugPrint('📷 Taking photo...');
      final XFile image = await _controller!.takePicture();
      debugPrint('📷 Photo captured: ${image.path}');

      // Lưu ảnh
      final imageFile = File(image.path);
      final savedFileName = await PhotoStorageService.savePhoto(imageFile);

      if (savedFileName != null && mounted) {
        debugPrint('✅ Photo saved: $savedFileName');
        await _loadLastPhoto();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📸 Photo saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error capturing photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to capture photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _vm.setCapturing(false);
        });
      }
    }
  }

  // BẮT ĐẦU QUAY VIDEO - ĐƠN GIẢN
  Future<void> _startVideoRecording() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _vm.isRecording ||
        _vm.isCapturing) {
      return;
    }

    try {
      debugPrint('🔴 Starting video recording...');
      await _controller!.startVideoRecording();
      debugPrint('🔴 Recording started');

      if (mounted) {
        setState(() {
          _vm.setRecording(true);
        });
        _startRecordingTimer();
      }
    } catch (e) {
      debugPrint('❌ Error starting video recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to start recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // DỪNG QUAY VIDEO - ĐƠN GIẢN
  Future<void> _stopVideoRecording() async {
    if (_controller == null ||
        !_controller!.value.isRecordingVideo ||
        !_vm.isRecording) {
      return;
    }

    try {
      debugPrint('⏹️ Stopping video recording...');
      final XFile video = await _controller!.stopVideoRecording();
      debugPrint('⏹️ Video saved: ${video.path}');

      // Lưu video
      final videoFile = File(video.path);
      final savedFileName = await PhotoStorageService.saveVideo(videoFile);

      if (savedFileName != null && mounted) {
        debugPrint('✅ Video saved: $savedFileName');
        await _loadLastPhoto();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎥 Video saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error stopping video recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to stop recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _vm.setRecording(false);
        });
        _stopRecordingTimer();
      }
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingSeconds = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _recordingSeconds++;
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _recordingSeconds = 0;
  }

  Future<void> _onCapturePressed() async {
    if (_vm.isVideoMode) {
      if (_vm.isRecording) {
        await _stopVideoRecording();
      } else {
        await _startVideoRecording();
      }
    } else {
      await _capturePhoto();
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() => _vm.isLoading = true);

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _setupCamera(_currentCameraIndex);

    setState(() => _vm.isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        Navigator.pop(context, true);
        return false;
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
              if (_controller != null && _controller!.value.isInitialized)
                Positioned.fill(child: CameraPreview(_controller!))
              else
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

              // Top Controls
              TopControls(
                showTopControls: _vm.showTopControls && !_shouldHideTopControls,
                selectedRatio: _vm.selectedRatio,
                isFlashOn: _vm.isFlashOn,
                showRatioPopup: _vm.showRatioPopup,
                showTimerPopup: _vm.showTimerPopup,
                showToolPopup: _vm.showFilterPopup,
                showMorePopup: _vm.showMorePopup,
                onBackPressed: () {
                  Navigator.of(context).pop(true);
                },
                onRatioPressed: () {
                  _hideAllPopupsExcept('ratio');
                },
                onFlashPressed: () async {
                  if (_controller != null && _controller!.value.isInitialized) {
                    final newFlashMode = _vm.isFlashOn
                        ? FlashMode.off
                        : FlashMode.torch;
                    await _controller!.setFlashMode(newFlashMode);
                    setState(() {
                      _vm.toggleFlash();
                    });
                  }
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

              // Mid Controls
              MidControls(
                showMidControls: _vm.showMidControls,
                currentZoom: _vm.currentZoom,
                onAmpPressed: () {
                  setState(() {
                    if (_vm.showAmpPopup) {
                      _hideAllPopups();
                    } else {
                      _hideAllPopupsExcept('amp');
                    }
                  });
                },
                onWBPressed: () {
                  setState(() {
                    if (_vm.showWbPopup) {
                      _hideAllPopups();
                    } else {
                      _hideAllPopupsExcept('wb');
                    }
                  });
                },
                onZoomPressed: () {
                  setState(() {
                    if (_vm.showZoomPopup) {
                      _hideAllPopups();
                    } else {
                      _hideAllPopupsExcept('zoom');
                    }
                  });
                },
                onBrightnessPressed: () {
                  setState(() {
                    if (_vm.showBrightnessPopup) {
                      _hideAllPopups();
                    } else {
                      _hideAllPopupsExcept('brightness');
                    }
                  });
                },
              ),

              // Bottom Controls
              BottomControls(
                showBottomControls: _vm.showBottomControls,
                isLoading: _vm.isLoading,
                isCapturing: _vm.isCapturing,
                isVideoMode: _vm.isVideoMode,
                isRecording: _vm.isRecording,
                recordingSeconds: _recordingSeconds,
                lastPhotoPath: _vm.lastCapturedPhotoPath,
                onGalleryPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GalleryScreen(),
                    ),
                  );

                  if (result == true) {
                    await _loadLastPhoto();
                  }
                },
                onCapturePressed: _onCapturePressed,
                onSwitchCameraPressed: _switchCamera,
                onPhotoModePressed: () {
                  if (_vm.isRecording) return;
                  setState(() {
                    _vm.setVideoMode(false);
                  });
                  debugPrint('📷 Switched to Photo mode');
                },
                onVideoModePressed: () {
                  if (_vm.isRecording) return;
                  setState(() {
                    _vm.setVideoMode(true);
                  });
                  debugPrint('🎥 Switched to Video mode');
                },
              ),

              // Popups (giữ nguyên tất cả popups của bạn)
              if (_vm.showRatioPopup)
                RatioPopup(
                  isVisible: _vm.showRatioPopup,
                  selectedRatio: _vm.selectedRatio,
                  onRatioSelected: (ratio) {
                    setState(() {
                      _vm.selectRatio(ratio);
                    });
                  },
                ),

              if (_vm.showTimerPopup)
                TimerPopup(
                  isVisible: _vm.showTimerPopup,
                  selectedTimer: _vm.selectedTimer,
                  onTimerSelected: (timer) {
                    setState(() {
                      _vm.selectTimer(timer);
                    });
                  },
                ),

              if (_vm.showFilterPopup)
                FilterPopup(
                  isVisible: _vm.showFilterPopup,
                  selectedCategory: _vm.selectedFilterCategory,
                  selectedFilterIndex: _vm.selectedFilterIndex,
                  onCategoryChanged: (category) {
                    setState(() {
                      _vm.changeFilterCategory(category);
                    });
                  },
                  onFilterSelected: (index) {
                    setState(() {
                      _vm.selectFilter(index);
                    });
                  },
                ),

              if (_vm.showAmpPopup)
                AmpPopup(
                  isVisible: _vm.showAmpPopup,
                  ampValue: _vm.ampValue,
                  onChanged: (v) {
                    setState(() {
                      _vm.setAmp(v);
                    });
                  },
                ),

              if (_vm.showWbPopup)
                WbPopup(
                  isVisible: _vm.showWbPopup,
                  currentMode: _vm.wbMode,
                  onModeChanged: (mode) {
                    setState(() {
                      _vm.selectWbMode(mode);
                    });
                  },
                ),

              if (_vm.showZoomPopup)
                ZoomPopup(
                  isVisible: _vm.showZoomPopup,
                  currentZoom: _vm.currentZoom,
                  minZoom: _vm.minZoom,
                  maxZoom: _vm.maxZoom,
                  onChanged: (z) async {
                    if (_controller != null &&
                        _controller!.value.isInitialized) {
                      await _controller!.setZoomLevel(z);
                      setState(() {
                        _vm.setZoom(z);
                      });
                    }
                  },
                ),

              if (_vm.showBrightnessPopup)
                BrightnessPopup(
                  isVisible: _vm.showBrightnessPopup,
                  brightnessValue: _vm.brightnessValue,
                  onChanged: (b) async {
                    if (_controller != null &&
                        _controller!.value.isInitialized) {
                      // Exposure compensation: -1.0 to 1.0
                      final exposure = (b - 0.5) * 2.0;
                      await _controller!.setExposureOffset(exposure);
                      setState(() {
                        _vm.setBrightness(b);
                      });
                    }
                  },
                ),

              if (_vm.showMorePopup)
                MorePopup(
                  isVisible: _vm.showMorePopup,
                  onGridTap: () {
                    setState(() {
                      _hideAllPopupsExcept('grid');
                    });
                  },
                  onFocusTap: () {
                    setState(() {
                      _hideAllPopupsExcept('focus');
                    });
                  },
                  onExposureTap: () {
                    setState(() {
                      _hideAllPopupsExcept('exposure');
                    });
                  },
                  onCollageTap: () {
                    setState(() {
                      _hideAllPopupsExcept('collage');
                    });
                  },
                  onClose: () {
                    setState(() {
                      _hideAllPopups();
                    });
                  },
                ),

              if (_vm.showGridPopup)
                GridPopup(
                  isVisible: _vm.showGridPopup,
                  selectedGrid: _vm.selectedGrid,
                  onGridSelected: (grid) {
                    setState(() {
                      _vm.selectGrid(grid);
                    });
                  },
                  onClose: () {
                    setState(() {
                      _hideAllPopups();
                    });
                  },
                ),

              if (_vm.showFocusPopup)
                FocusPopup(
                  isVisible: _vm.showFocusPopup,
                  selectedFocus: _vm.selectedFocus,
                  onFocusSelected: (focus) {
                    setState(() {
                      _vm.selectFocus(focus);
                    });
                  },
                  onClose: () {
                    setState(() {
                      _hideAllPopups();
                    });
                  },
                ),

              if (_vm.showExposurePopup)
                ExposurePopup(
                  isVisible: _vm.showExposurePopup,
                  exposureValue: _vm.exposureValue,
                  onChanged: (v) async {
                    if (_controller != null &&
                        _controller!.value.isInitialized) {
                      await _controller!.setExposureOffset(v);
                      setState(() {
                        _vm.setExposure(v);
                      });
                    }
                  },
                  onClose: () {
                    setState(() {
                      _hideAllPopups();
                    });
                  },
                ),

              if (_vm.showCollagePopup)
                CollagePopup(
                  isVisible: _vm.showCollagePopup,
                  selectedLayout: _vm.selectedCollageLayout,
                  onLayoutSelected: (layout) {
                    setState(() {
                      _vm.selectCollageLayout(layout);
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

import 'dart:io';
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

class _V169CameraScreenState extends State<V169CameraScreen> {
  final CameraViewModel _vm = CameraViewModel();

  // Camera state
  CameraState? _cameraState;

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadLastPhoto();
  }

  // Load ảnh cuối cùng từ gallery
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
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  // Hàm chụp ảnh đơn giản
  Future<void> _capturePhoto() async {
    if (_cameraState == null || _vm.isCapturing) return;

    setState(() {
      _vm.setCapturing(true);
    });

    try {
      debugPrint('=== Starting Photo Capture ===');
      
      // Chụp ảnh bằng camerawesome
      await _cameraState!.when(
        onPhotoMode: (photoState) async {
          final captureRequest = await photoState.takePhoto();
          debugPrint('Photo captured: ${captureRequest.runtimeType}');
          
          // Xử lý ảnh vừa chụp
          await _handleCapturedPhoto(captureRequest);
        },
      );
    } catch (e) {
      debugPrint('Error capturing photo: $e');
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

  // Xử lý ảnh vừa chụp
  Future<void> _handleCapturedPhoto(dynamic captureRequest) async {
    try {
      File? imageFile;
      
      // Lấy file ảnh từ capture request
      if (captureRequest is SingleCaptureRequest) {
        final xFile = captureRequest.file;
        if (xFile != null) {
          imageFile = File(xFile.path);
          debugPrint('Image file path: ${imageFile.path}');
        }
      }

      if (imageFile != null && await imageFile.exists()) {
        debugPrint('Image file exists, saving to SharedPreferences...');
        
        // Lưu ảnh vào SharedPreferences
        final savedFileName = await PhotoStorageService.savePhoto(imageFile);
        
        if (savedFileName != null) {
          debugPrint('✅ Photo saved successfully: $savedFileName');
          
          // Cập nhật UI với ảnh mới
          await _loadLastPhoto();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('📸 Photo saved successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          debugPrint('❌ Failed to save photo');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Failed to save photo'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        debugPrint('❌ Image file not found or does not exist');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Failed to capture photo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error handling captured photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        // Trả về true để báo có ảnh mới
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
              CameraAwesomeBuilder.awesome(
                saveConfig: SaveConfig.photoAndVideo(
                  initialCaptureMode: CaptureMode.photo,
                ),
                sensorConfig: SensorConfig.single(
                  sensor: Sensor.position(SensorPosition.back),
                  flashMode: _vm.isFlashOn ? FlashMode.on : FlashMode.none,
                ),
                previewFit: CameraPreviewFit.cover,
                enablePhysicalButton: true,
                onMediaTap: (mediaCapture) async {
                  // Không cần xử lý gì ở đây nữa vì đã xử lý trong _capturePhoto()
                  debugPrint('onMediaTap called - handled in _capturePhoto()');
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
                onFlashPressed: () {
                  setState(() {
                    _vm.toggleFlash();
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
                lastPhotoPath: _vm.lastCapturedPhotoPath,
                onGalleryPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GalleryScreen(),
                    ),
                  );

                  // Reload ảnh cuối sau khi quay về từ gallery
                  if (result == true) {
                    await _loadLastPhoto();
                  }
                },
                onCapturePressed: _capturePhoto,
                onSwitchCameraPressed: () async {
                  setState(() => _vm.isLoading = true);

                  if (_cameraState != null) {
                    await _cameraState!.switchCameraSensor();
                  }

                  setState(() => _vm.isLoading = false);
                },
              ),

              // Popups
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
                  onChanged: (z) {
                    setState(() {
                      _vm.setZoom(z);
                    });
                  },
                ),

              if (_vm.showBrightnessPopup)
                BrightnessPopup(
                  isVisible: _vm.showBrightnessPopup,
                  brightnessValue: _vm.brightnessValue,
                  onChanged: (b) {
                    setState(() {
                      _vm.setBrightness(b);
                    });
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
                  onChanged: (v) {
                    setState(() {
                      _vm.setExposure(v);
                    });
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

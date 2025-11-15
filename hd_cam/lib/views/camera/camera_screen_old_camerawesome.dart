// import 'dart:io';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../widgets/camera/top_controls.dart';
// import '../../widgets/camera/mid_controls.dart';
// import '../../widgets/camera/bottom_controls.dart';
// import '../../widgets/camera/popups/ratio_popup.dart';
// import '../../widgets/camera/popups/timer_popup.dart';
// import '../../widgets/camera/popups/filter_popup.dart';
// import '../../widgets/camera/popups/more_popup.dart';
// import '../../widgets/camera/popups/amp_popup.dart';
// import '../../widgets/camera/popups/wb_popup.dart';
// import '../../widgets/camera/popups/zoom_popup.dart';
// import '../../widgets/camera/popups/brightness_popup.dart';
// import '../../view_models/camera_view_model.dart';
// import '../../widgets/camera/popups/grid_popup.dart';
// import '../../widgets/camera/popups/focus_popup.dart';
// import '../../widgets/camera/popups/exposure_popup.dart';
// import '../../widgets/camera/popups/collage_popup.dart';
// import '../gallery/gallery_screen.dart';
// import '../../services/photo_storage_service.dart';

// class V169CameraScreen extends StatefulWidget {
//   const V169CameraScreen({super.key});

//   @override
//   State<V169CameraScreen> createState() => _V169CameraScreenState();
// }

// class _V169CameraScreenState extends State<V169CameraScreen> {
//   final CameraViewModel _vm = CameraViewModel();

//   // Camera state
//   CameraState? _cameraState;

//   Timer? _recordingTimer;
//   int _recordingSeconds = 0;

//   bool get _hasActivePopup => _vm.hasActivePopup;
//   bool get _shouldHideTopControls => _vm.shouldHideTopControls;

//   void _hideAllPopupsExcept(String popup) {
//     setState(() {
//       _vm.hideAllPopupsExcept(popup);
//     });
//   }

//   void _hideAllPopups() {
//     setState(() {
//       _vm.hideAllPopups();
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     _loadLastPhoto();

//     // Check camera state sau khi init
//     Future.delayed(const Duration(milliseconds: 1000), () {
//       print('🎬 [DEBUG] Camera state after init: ${_cameraState?.runtimeType}');
//       print('🎬 [DEBUG] isVideoMode: ${_vm.isVideoMode}');
//     });
//   }

//   // Load ảnh cuối cùng từ gallery
//   Future<void> _loadLastPhoto() async {
//     try {
//       final photos = await PhotoStorageService.getAllPhotos();
//       if (photos.isNotEmpty && mounted) {
//         setState(() {
//           _vm.updateLastCapturedPhoto(photos.first.filePath);
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading last photo: $e');
//     }
//   }

//   @override
//   void dispose() {
//     SystemChrome.setEnabledSystemUIMode(
//       SystemUiMode.manual,
//       overlays: SystemUiOverlay.values,
//     );
//     _recordingTimer?.cancel();
//     super.dispose();
//   }

//   // Hàm chụp ảnh - đơn giản, chỉ gọi takePhoto
//   Future<void> _capturePhoto() async {
//     if (_cameraState == null || _vm.isCapturing || _vm.isRecording) return;

//     setState(() {
//       _vm.setCapturing(true);
//     });

//     try {
//       debugPrint('=== Starting Photo Capture ===');
//       await _cameraState!.when(
//         onPhotoMode: (photoState) async {
//           final captureRequest = await photoState.takePhoto();
//           debugPrint('Photo captured: ${captureRequest.runtimeType}');
//           await _handleCapturedPhoto(captureRequest);
//         },
//       );
//     } catch (e) {
//       debugPrint('Error capturing photo: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ Failed to capture photo: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _vm.setCapturing(false);
//         });
//       }
//     }
//   }

//   // Xử lý ảnh vừa chụp
//   Future<void> _handleCapturedPhoto(dynamic captureRequest) async {
//     try {
//       File? imageFile;

//       // Lấy file ảnh từ capture request
//       if (captureRequest is SingleCaptureRequest) {
//         final xFile = captureRequest.file;
//         if (xFile != null) {
//           imageFile = File(xFile.path);
//           debugPrint('Image file path: ${imageFile.path}');
//         }
//       }

//       if (imageFile != null && await imageFile.exists()) {
//         debugPrint(
//           'Image file exists, saving to local media storage (Hive)...',
//         );

//         // Lưu ảnh vào bộ nhớ trong app (file + metadata Hive)
//         final savedFileName = await PhotoStorageService.savePhoto(imageFile);

//         if (savedFileName != null) {
//           debugPrint('✅ Photo saved successfully: $savedFileName');

//           // Cập nhật UI với ảnh mới
//           await _loadLastPhoto();

//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('📸 Photo saved successfully!'),
//                 backgroundColor: Colors.green,
//                 duration: Duration(seconds: 2),
//               ),
//             );
//           }
//         } else {
//           debugPrint('❌ Failed to save photo');
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('❌ Failed to save photo'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         }
//       } else {
//         debugPrint('❌ Image file not found or does not exist');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('❌ Failed to capture photo'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error handling captured photo: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   void _startRecordingTimer() {
//     _recordingTimer?.cancel();
//     _recordingSeconds = 0;
//     _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!mounted) return;
//       setState(() {
//         _recordingSeconds++;
//       });
//     });
//   }

//   void _stopRecordingTimer() {
//     _recordingTimer?.cancel();
//     _recordingTimer = null;
//     _recordingSeconds = 0;
//   }

//   Future<void> _startVideoRecording() async {
//     if (_cameraState == null || _vm.isRecording || _vm.isCapturing) return;

//     try {
//       debugPrint('=== Starting Video Recording ===');
//       await _cameraState!.when(
//         onVideoMode: (videoState) async {
//           await videoState.startRecording();
//           debugPrint('🔴 Recording started');
//         },
//       );

//       if (mounted) {
//         setState(() {
//           _vm.setRecording(true);
//         });
//         _startRecordingTimer();
//       }
//     } catch (e) {
//       debugPrint('Error starting video recording: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ Failed to start video recording: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _stopVideoRecording() async {
//     if (_cameraState == null || !_vm.isRecording) return;

//     try {
//       debugPrint('=== Stopping Video Recording ===');
//       await _cameraState!.when(
//         onVideoRecordingMode: (videoRecordingState) async {
//           await videoRecordingState.stopRecording();
//           debugPrint('⏹️ Recording stopped');
//         },
//       );
//     } catch (e) {
//       debugPrint('Error stopping video recording: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ Failed to stop video recording: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _vm.setRecording(false);
//         });
//         _stopRecordingTimer();
//       }
//     }
//   }

//   Future<void> _onCapturePressed() async {
//     if (_vm.isVideoMode) {
//       if (_vm.isRecording) {
//         await _stopVideoRecording();
//       } else {
//         await _startVideoRecording();
//       }
//     } else {
//       await _capturePhoto();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         SystemChrome.setEnabledSystemUIMode(
//           SystemUiMode.manual,
//           overlays: SystemUiOverlay.values,
//         );
//         // Trả về true để báo có ảnh mới
//         Navigator.pop(context, true);
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: GestureDetector(
//           onTap: () {
//             if (_hasActivePopup) {
//               _hideAllPopups();
//             }
//           },
//           child: Stack(
//             children: [
//               // Camera Preview - DÙNG UI MẶC ĐỊNH ĐỂ TEST
//               CameraAwesomeBuilder.awesome(
//                 saveConfig: SaveConfig.photoAndVideo(
//                   initialCaptureMode: CaptureMode.photo,
//                 ),
//                 sensorConfig: SensorConfig.single(
//                   sensor: Sensor.position(SensorPosition.back),
//                   flashMode: _vm.isFlashOn ? FlashMode.on : FlashMode.none,
//                 ),
//                 previewFit: CameraPreviewFit.cover,
//                 enablePhysicalButton: true,
//                 // Để UI mặc định - KHÔNG override bottomActionsBuilder
//                 onMediaCaptureEvent: (event) async {
//                   print(
//                     '📹 [DEBUG] onMediaCaptureEvent: isVideo=${event.isVideo}, status=${event.status}',
//                   );
//                   if (event.isVideo &&
//                       event.status == MediaCaptureStatus.success) {
//                     print('📹 [DEBUG] Processing video capture event...');
//                     await event.captureRequest.when(
//                       single: (single) async {
//                         print('📹 [DEBUG] Single capture request');
//                         final file = single.file;
//                         if (file == null) {
//                           print('❌ [ERROR] single.file is null!');
//                           return;
//                         }
//                         final videoFile = File(file.path);
//                         print('📹 [DEBUG] Video file path: ${file.path}');
//                         if (!await videoFile.exists()) {
//                           print(
//                             '❌ [ERROR] Video file does not exist: ${file.path}',
//                           );
//                           return;
//                         }
//                         debugPrint(
//                           'Saving recorded video to local media storage (Hive): ${videoFile.path}',
//                         );
//                         await PhotoStorageService.saveVideo(videoFile);
//                       },
//                       multiple: (multiple) async {
//                         print('📹 [DEBUG] Multiple capture request');
//                         for (final entry in multiple.fileBySensor.entries) {
//                           final value = entry.value;
//                           if (value == null) {
//                             print(
//                               '❌ [ERROR] multiple file value is null for sensor ${entry.key}',
//                             );
//                             continue;
//                           }
//                           final videoFile = File(value.path);
//                           print(
//                             '📹 [DEBUG] Multiple video file path: ${value.path}',
//                           );
//                           if (!await videoFile.exists()) {
//                             print(
//                               '❌ [ERROR] Multiple video file does not exist: ${value.path}',
//                             );
//                             continue;
//                           }
//                           await PhotoStorageService.saveVideo(videoFile);
//                         }
//                       },
//                     );
//                   }
//                 },
//                 onMediaTap: (mediaCapture) async {
//                   // Không cần xử lý gì ở đây nữa vì đã xử lý trong _capturePhoto()
//                   debugPrint('onMediaTap called - handled in _capturePhoto()');
//                 },
//                 topActionsBuilder: (state) {
//                   final oldState = _cameraState?.runtimeType;
//                   _cameraState = state;
//                   final newState = _cameraState?.runtimeType;
//                   if (oldState != newState) {
//                     print(
//                       '🔄 [DEBUG] topActionsBuilder: Camera state changed from $oldState to $newState',
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//                 // COMMENT TẠM THỜI - để CamerAwesome dùng UI mặc định
//                 // middleContentBuilder: (state) => const SizedBox.shrink(),
//                 // bottomActionsBuilder: (state) => const SizedBox.shrink(),
//               ),

//               // Top Controls - giữ lại để có nút back và các chức năng
//               TopControls(
//                 showTopControls: _vm.showTopControls && !_shouldHideTopControls,
//                 selectedRatio: _vm.selectedRatio,
//                 isFlashOn: _vm.isFlashOn,
//                 showRatioPopup: _vm.showRatioPopup,
//                 showTimerPopup: _vm.showTimerPopup,
//                 showToolPopup: _vm.showFilterPopup,
//                 showMorePopup: _vm.showMorePopup,
//                 onBackPressed: () {
//                   Navigator.of(context).pop(true);
//                 },
//                 onRatioPressed: () {
//                   _hideAllPopupsExcept('ratio');
//                 },
//                 onFlashPressed: () {
//                   setState(() {
//                     _vm.toggleFlash();
//                   });
//                 },
//                 onTimerPressed: () {
//                   _hideAllPopupsExcept('timer');
//                 },
//                 onToolPressed: () {
//                   _hideAllPopupsExcept('filter');
//                 },
//                 onMorePressed: () {
//                   _hideAllPopupsExcept('more');
//                 },
//               ),

//               // Mid Controls
//               MidControls(
//                 showMidControls: _vm.showMidControls,
//                 currentZoom: _vm.currentZoom,
//                 onAmpPressed: () {
//                   setState(() {
//                     if (_vm.showAmpPopup) {
//                       _hideAllPopups();
//                     } else {
//                       _hideAllPopupsExcept('amp');
//                     }
//                   });
//                 },
//                 onWBPressed: () {
//                   setState(() {
//                     if (_vm.showWbPopup) {
//                       _hideAllPopups();
//                     } else {
//                       _hideAllPopupsExcept('wb');
//                     }
//                   });
//                 },
//                 onZoomPressed: () {
//                   setState(() {
//                     if (_vm.showZoomPopup) {
//                       _hideAllPopups();
//                     } else {
//                       _hideAllPopupsExcept('zoom');
//                     }
//                   });
//                 },
//                 onBrightnessPressed: () {
//                   setState(() {
//                     if (_vm.showBrightnessPopup) {
//                       _hideAllPopups();
//                     } else {
//                       _hideAllPopupsExcept('brightness');
//                     }
//                   });
//                 },
//               ),

//               // Bottom Controls
//               BottomControls(
//                 showBottomControls: _vm.showBottomControls,
//                 isLoading: _vm.isLoading,
//                 isCapturing: _vm.isCapturing,
//                 isVideoMode: _vm.isVideoMode,
//                 isRecording: _vm.isRecording,
//                 recordingSeconds: _recordingSeconds,
//                 lastPhotoPath: _vm.lastCapturedPhotoPath,
//                 onGalleryPressed: () async {
//                   final result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const GalleryScreen(),
//                     ),
//                   );

//                   // Reload ảnh cuối sau khi quay về từ gallery
//                   if (result == true) {
//                     await _loadLastPhoto();
//                   }
//                 },
//                 onCapturePressed: _onCapturePressed,
//                 onSwitchCameraPressed: () async {
//                   setState(() => _vm.isLoading = true);

//                   if (_cameraState != null) {
//                     await _cameraState!.switchCameraSensor();
//                   }

//                   setState(() => _vm.isLoading = false);
//                 },
//                 onPhotoModePressed: () async {
//                   if (_vm.isRecording) return;
//                   print('📷 [DEBUG] Switching to Photo mode...');
//                   await CamerawesomePlugin.setCaptureMode(CaptureMode.photo);
//                   await Future.delayed(const Duration(milliseconds: 500));
//                   setState(() {
//                     _vm.setVideoMode(false);
//                   });
//                   await Future.delayed(const Duration(milliseconds: 100));
//                   print(
//                     '📷 [DEBUG] Photo mode set successfully. Camera state: ${_cameraState.runtimeType}',
//                   );
//                 },
//                 onVideoModePressed: () async {
//                   if (_vm.isRecording) return;
//                   print('🎥 [DEBUG] Switching to Video mode...');
//                   print(
//                     '🎥 [DEBUG] Current camera state BEFORE switch: ${_cameraState?.runtimeType}',
//                   );

//                   // Set UI first to show loading/switching state
//                   setState(() {
//                     _vm.setVideoMode(true);
//                     _vm.isLoading = true;
//                   });

//                   // Switch camera to video mode
//                   await CamerawesomePlugin.setCaptureMode(CaptureMode.video);
//                   print('🎥 [DEBUG] setCaptureMode(video) called');

//                   // Đợi camera state cập nhật - đơn giản chỉ đợi
//                   // topActionsBuilder sẽ tự cập nhật _cameraState khi CameraAwesome rebuild
//                   await Future.delayed(const Duration(milliseconds: 1500));

//                   print(
//                     '🎥 [DEBUG] After 1.5s wait, camera state: ${_cameraState?.runtimeType}',
//                   );

//                   setState(() {
//                     _vm.isLoading = false;
//                   });

//                   // Check nếu vẫn chưa chuyển
//                   if (_cameraState != null &&
//                       !_cameraState.runtimeType.toString().contains('Video')) {
//                     print(
//                       '⚠️ [WARNING] Camera state is still: ${_cameraState?.runtimeType}',
//                     );

//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text(
//                             '⚠️ Camera mode switch may take a moment. Please wait before recording.',
//                           ),
//                           backgroundColor: Colors.orange,
//                           duration: Duration(seconds: 3),
//                         ),
//                       );
//                     }
//                   } else {
//                     print(
//                       '🎥 [DEBUG] ✅ Video mode ready! Camera state: ${_cameraState?.runtimeType}',
//                     );
//                   }
//                 },
//               ),

//               // Nút Gallery - thêm tạm để vào xem ảnh/video
//               Positioned(
//                 bottom: 100,
//                 left: 20,
//                 child: GestureDetector(
//                   onTap: () async {
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const GalleryScreen(),
//                       ),
//                     );
//                     await _loadLastPhoto();
//                   },
//                   child: Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.white, width: 2),
//                     ),
//                     child: const Icon(
//                       Icons.photo_library,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                   ),
//                 ),
//               ),

//               // COMMENT TẠM THỜI - Popups
//               /*
//               // Popups
//               if (_vm.showRatioPopup)
//                 RatioPopup(
//                   isVisible: _vm.showRatioPopup,
//                   selectedRatio: _vm.selectedRatio,
//                   onRatioSelected: (ratio) {
//                     setState(() {
//                       _vm.selectRatio(ratio);
//                     });
//                   },
//                 ),

//               if (_vm.showTimerPopup)
//                 TimerPopup(
//                   isVisible: _vm.showTimerPopup,
//                   selectedTimer: _vm.selectedTimer,
//                   onTimerSelected: (timer) {
//                     setState(() {
//                       _vm.selectTimer(timer);
//                     });
//                   },
//                 ),

//               if (_vm.showFilterPopup)
//                 FilterPopup(
//                   isVisible: _vm.showFilterPopup,
//                   selectedCategory: _vm.selectedFilterCategory,
//                   selectedFilterIndex: _vm.selectedFilterIndex,
//                   onCategoryChanged: (category) {
//                     setState(() {
//                       _vm.changeFilterCategory(category);
//                     });
//                   },
//                   onFilterSelected: (index) {
//                     setState(() {
//                       _vm.selectFilter(index);
//                     });
//                   },
//                 ),

//               if (_vm.showAmpPopup)
//                 AmpPopup(
//                   isVisible: _vm.showAmpPopup,
//                   ampValue: _vm.ampValue,
//                   onChanged: (v) {
//                     setState(() {
//                       _vm.setAmp(v);
//                     });
//                   },
//                 ),

//               if (_vm.showWbPopup)
//                 WbPopup(
//                   isVisible: _vm.showWbPopup,
//                   currentMode: _vm.wbMode,
//                   onModeChanged: (mode) {
//                     setState(() {
//                       _vm.selectWbMode(mode);
//                     });
//                   },
//                 ),

//               if (_vm.showZoomPopup)
//                 ZoomPopup(
//                   isVisible: _vm.showZoomPopup,
//                   currentZoom: _vm.currentZoom,
//                   minZoom: _vm.minZoom,
//                   maxZoom: _vm.maxZoom,
//                   onChanged: (z) {
//                     setState(() {
//                       _vm.setZoom(z);
//                     });
//                   },
//                 ),

//               if (_vm.showBrightnessPopup)
//                 BrightnessPopup(
//                   isVisible: _vm.showBrightnessPopup,
//                   brightnessValue: _vm.brightnessValue,
//                   onChanged: (b) {
//                     setState(() {
//                       _vm.setBrightness(b);
//                     });
//                   },
//                 ),

//               if (_vm.showMorePopup)
//                 MorePopup(
//                   isVisible: _vm.showMorePopup,
//                   onGridTap: () {
//                     setState(() {
//                       _hideAllPopupsExcept('grid');
//                     });
//                   },
//                   onFocusTap: () {
//                     setState(() {
//                       _hideAllPopupsExcept('focus');
//                     });
//                   },
//                   onExposureTap: () {
//                     setState(() {
//                       _hideAllPopupsExcept('exposure');
//                     });
//                   },
//                   onCollageTap: () {
//                     setState(() {
//                       _hideAllPopupsExcept('collage');
//                     });
//                   },
//                   onClose: () {
//                     setState(() {
//                       _hideAllPopups();
//                     });
//                   },
//                 ),

//               if (_vm.showGridPopup)
//                 GridPopup(
//                   isVisible: _vm.showGridPopup,
//                   selectedGrid: _vm.selectedGrid,
//                   onGridSelected: (grid) {
//                     setState(() {
//                       _vm.selectGrid(grid);
//                     });
//                   },
//                   onClose: () {
//                     setState(() {
//                       _hideAllPopups();
//                     });
//                   },
//                 ),

//               if (_vm.showFocusPopup)
//                 FocusPopup(
//                   isVisible: _vm.showFocusPopup,
//                   selectedFocus: _vm.selectedFocus,
//                   onFocusSelected: (focus) {
//                     setState(() {
//                       _vm.selectFocus(focus);
//                     });
//                   },
//                   onClose: () {
//                     setState(() {
//                       _hideAllPopups();
//                     });
//                   },
//                 ),

//               if (_vm.showExposurePopup)
//                 ExposurePopup(
//                   isVisible: _vm.showExposurePopup,
//                   exposureValue: _vm.exposureValue,
//                   onChanged: (v) {
//                     setState(() {
//                       _vm.setExposure(v);
//                     });
//                   },
//                   onClose: () {
//                     setState(() {
//                       _hideAllPopups();
//                     });
//                   },
//                 ),

//               if (_vm.showCollagePopup)
//                 CollagePopup(
//                   isVisible: _vm.showCollagePopup,
//                   selectedLayout: _vm.selectedCollageLayout,
//                   onLayoutSelected: (layout) {
//                     setState(() {
//                       _vm.selectCollageLayout(layout);
//                     });
//                   },
//                   onClose: () {
//                     setState(() {
//                       _hideAllPopups();
//                     });
//                   },
//                 ),
//               */
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

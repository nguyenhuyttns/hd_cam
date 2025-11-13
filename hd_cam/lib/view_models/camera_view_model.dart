import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../services/white_balance_service.dart';

class CameraViewModel extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isLoading = true;
  String _error = '';
  int _currentCameraIndex = 0;

  // UI State - Controls
  bool _showTopControls = true;
  bool _showBottomControls = true;

  // UI State - Popups (chỉ 1 popup hiển thị tại 1 thời điểm)
  bool _showRatioPopup = false;
  bool _showTimerPopup = false;
  bool _showFilterPopup = false;
  bool _showMorePopup = false;
  bool _showGridPopup = false;
  bool _showWBPopup = false;

  // UI State - Settings
  bool _isFlashOn = false;
  String _selectedRatio = "Full";
  String _selectedTimer = "OFF";
  String _selectedGrid = "None";
  final WhiteBalanceService _whiteBalanceService = WhiteBalanceService();

  // Getters
  CameraController? get controller => _controller;
  List<CameraDescription> get cameras => _cameras;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get currentCameraIndex => _currentCameraIndex;
  
  bool get showTopControls => _showTopControls;
  bool get showBottomControls => _showBottomControls;
  
  bool get showRatioPopup => _showRatioPopup;
  bool get showTimerPopup => _showTimerPopup;
  bool get showFilterPopup => _showFilterPopup;
  bool get showMorePopup => _showMorePopup;
  bool get showGridPopup => _showGridPopup;
  bool get showWBPopup => _showWBPopup;
  
  bool get isFlashOn => _isFlashOn;
  String get selectedRatio => _selectedRatio;
  String get selectedTimer => _selectedTimer;
  String get selectedGrid => _selectedGrid;
  WhiteBalanceService get whiteBalanceService => _whiteBalanceService;

  // Initialize camera
  Future<void> initializeCamera() async {
    try {
      _setLoading(true);
      _clearError();
      
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _setError('No cameras available');
        return;
      }

      await _setupCamera(_currentCameraIndex);
    } catch (e) {
      _setError('Failed to initialize camera: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Setup camera with specific index
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
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to setup camera: $e');
    }
  }

  // Switch camera
  Future<void> switchCamera() async {
    if (_cameras.length <= 1) return;
    
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _setupCamera(_currentCameraIndex);
  }

  // Toggle flash
  Future<void> toggleFlash() async {
    if (_controller == null || !_isInitialized) return;
    
    try {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle flash: $e');
    }
  }

  // Popup management
  void toggleRatioPopup() {
    _hideAllPopups();
    _showRatioPopup = !_showRatioPopup;
    notifyListeners();
  }

  void toggleTimerPopup() {
    _hideAllPopups();
    _showTimerPopup = !_showTimerPopup;
    notifyListeners();
  }

  void toggleFilterPopup() {
    _hideAllPopups();
    _showFilterPopup = !_showFilterPopup;
    notifyListeners();
  }

  void toggleMorePopup() {
    _hideAllPopups();
    _showMorePopup = !_showMorePopup;
    notifyListeners();
  }

  void toggleGridPopup() {
    _hideAllPopups();
    _showGridPopup = !_showGridPopup;
    notifyListeners();
  }

  void toggleWBPopup() {
    _hideAllPopups();
    _showWBPopup = !_showWBPopup;
    notifyListeners();
  }

  void hideAllPopups() {
    _hideAllPopups();
    notifyListeners();
  }

  void _hideAllPopups() {
    _showRatioPopup = false;
    _showTimerPopup = false;
    _showFilterPopup = false;
    _showMorePopup = false;
    _showGridPopup = false;
    _showWBPopup = false;
  }

  // Settings
  void setRatio(String ratio) {
    _selectedRatio = ratio;
    hideAllPopups();
  }

  void setTimer(String timer) {
    _selectedTimer = timer;
    hideAllPopups();
  }

  void setGrid(String grid) {
    _selectedGrid = grid;
    hideAllPopups();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

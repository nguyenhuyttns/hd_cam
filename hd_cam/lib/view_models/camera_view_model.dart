import 'dart:io';
import '../services/white_balance_service.dart';

class CameraViewModel {
  // UI state
  bool showTopControls = true;
  bool showMidControls = true;
  bool showBottomControls = true;

  // Popup visibility
  bool showRatioPopup = false;
  bool showTimerPopup = false;
  bool showFilterPopup = false;
  bool showMorePopup = false;
  bool showAmpPopup = false;
  bool showWbPopup = false;
  bool showZoomPopup = false;
  bool showBrightnessPopup = false;
  bool showGridPopup = false;
  bool showFocusPopup = false;
  bool showExposurePopup = false;
  bool showCollagePopup = false;

  // Settings
  String selectedRatio = "16:9";
  bool isFlashOn = false;
  String selectedTimer = "OFF";
  String selectedFilterCategory = 'Popular';
  int selectedFilterIndex = 0;
  double currentZoom = 1.0;
  bool isLoading = false;
  bool isCapturing = false;
  double ampValue = 0.5;
  double brightnessValue = 0.5;
  double minZoom = 1.0;
  double maxZoom = 10.0;
  WhiteBalanceMode wbMode = WhiteBalanceMode.DEFAULT;
  String selectedFocus = 'A';
  String selectedGrid = 'None';
  double exposureValue = 0.0;
  String selectedCollageLayout = 'layout1';

  // NEW: Last captured photo path
  String? lastCapturedPhotoPath;

  // Derived
  bool get hasActivePopup =>
      showRatioPopup ||
      showTimerPopup ||
      showFilterPopup ||
      showMorePopup ||
      showAmpPopup ||
      showWbPopup ||
      showZoomPopup ||
      showBrightnessPopup ||
      showGridPopup ||
      showFocusPopup ||
      showExposurePopup ||
      showCollagePopup;

  bool get shouldHideTopControls => showRatioPopup || showTimerPopup;

  // Mutations (custom UI logic)
  void hideAllPopupsExcept(String popup) {
    showRatioPopup = popup == 'ratio';
    showTimerPopup = popup == 'timer';
    showFilterPopup = popup == 'filter';
    showMorePopup = popup == 'more';
    showAmpPopup = popup == 'amp';
    showWbPopup = popup == 'wb';
    showZoomPopup = popup == 'zoom';
    showBrightnessPopup = popup == 'brightness';
    showGridPopup = popup == 'grid';
    showFocusPopup = popup == 'focus';
    showExposurePopup = popup == 'exposure';
    showCollagePopup = popup == 'collage';

    if (popup == 'ratio' || popup == 'timer') {
      showTopControls = false;
    } else {
      showTopControls = true;
    }
  }

  void hideAllPopups() {
    showRatioPopup = false;
    showTimerPopup = false;
    showFilterPopup = false;
    showMorePopup = false;
    showAmpPopup = false;
    showWbPopup = false;
    showZoomPopup = false;
    showBrightnessPopup = false;
    showGridPopup = false;
    showFocusPopup = false;
    showExposurePopup = false;
    showCollagePopup = false;

    showTopControls = true;
  }

  void toggleFlash() {
    isFlashOn = !isFlashOn;
  }

  void selectRatio(String ratio) {
    selectedRatio = ratio;
    hideAllPopups();
  }

  void selectTimer(String timer) {
    selectedTimer = timer;
    hideAllPopups();
  }

  void changeFilterCategory(String category) {
    selectedFilterCategory = category;
  }

  void selectFilter(int index) {
    selectedFilterIndex = index;
    hideAllPopups();
  }

  void setAmp(double v) {
    ampValue = v;
  }

  void setBrightness(double v) {
    brightnessValue = v;
  }

  void selectWbMode(WhiteBalanceMode mode) {
    wbMode = mode;
    hideAllPopups();
  }

  void setZoom(double z) {
    currentZoom = z;
  }

  void selectFocus(String focus) {
    selectedFocus = focus;
    hideAllPopups();
  }

  void selectGrid(String grid) {
    selectedGrid = grid;
    hideAllPopups();
  }

  void setExposure(double v) {
    exposureValue = v;
  }

  void selectCollageLayout(String layout) {
    selectedCollageLayout = layout;
    hideAllPopups();
  }

  void setCapturing(bool capturing) {
    isCapturing = capturing;
  }

  void updateLastCapturedPhoto(String? path) {
    lastCapturedPhotoPath = path;
  }
}

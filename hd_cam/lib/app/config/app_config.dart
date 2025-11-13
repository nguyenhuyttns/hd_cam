class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'https://api.example.com';
  static const String apiVersion = 'v1';
  
  // App Configuration
  static const String appName = 'HD Camera';
  static const String appVersion = '1.0.0';
  
  // Storage Configuration
  static const String photoDirectoryName = 'HDCamera';
  static const int maxPhotoCount = 1000;
  static const int maxPhotoSizeMB = 50;
  
  // Camera Configuration
  static const int defaultCameraQuality = 100;
  static const bool enableHDR = true;
  static const bool enableFlash = true;
  
  // Feature Flags
  static const bool enableCollage = true;
  static const bool enablePhotoEdit = true;
  static const bool enableFilters = true;
}
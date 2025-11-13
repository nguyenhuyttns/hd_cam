import 'package:flutter/foundation.dart';
import '../services/photo_storage_service.dart';

class HomeViewModel extends ChangeNotifier {
  List<PhotoInfo> _recentPhotos = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  List<PhotoInfo> get recentPhotos => _recentPhotos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPhotos => _recentPhotos.isNotEmpty;

  // Initialize data
  Future<void> initialize() async {
    await loadRecentPhotos();
  }

  // Load recent photos
  Future<void> loadRecentPhotos() async {
    _setLoading(true);
    _clearError();
    
    try {
      final photos = await PhotoStorageService.getAllPhotos();
      _recentPhotos = photos.take(10).toList();
    } catch (e) {
      _errorMessage = 'Failed to load photos: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Refresh photos
  Future<void> refreshPhotos() async {
    await loadRecentPhotos();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import '../services/photo_storage_service.dart';

class GalleryViewModel extends ChangeNotifier {
  List<PhotoInfo> _photos = [];
  bool _isLoading = true;
  String _error = '';

  // Getters
  List<PhotoInfo> get photos => _photos;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasPhotos => _photos.isNotEmpty;
  bool get hasError => _error.isNotEmpty;

  // Initialize data
  Future<void> initialize() async {
    await loadPhotos();
  }

  // Load all photos
  Future<void> loadPhotos() async {
    _setLoading(true);
    _clearError();

    try {
      // Lấy ảnh từ bộ nhớ trong app
      final photos = await PhotoStorageService.getAllPhotos();
      _photos = photos;
    } catch (e) {
      _setError('Failed to load photos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh photos
  Future<void> refreshPhotos() async {
    await loadPhotos();
  }

  // Delete photo
  Future<bool> deletePhoto(PhotoInfo photoInfo) async {
    try {
      await PhotoStorageService.deletePhoto(photoInfo);
      _photos.removeWhere((photo) => photo.filePath == photoInfo.filePath);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete photo: $e');
      return false;
    }
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
}

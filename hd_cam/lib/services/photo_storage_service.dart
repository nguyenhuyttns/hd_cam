import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class PhotoStorageService {
  static const String _photosKey = 'saved_photos';
  
  // Lưu ảnh vào bộ nhớ trong app
  static Future<String?> savePhoto(File imageFile) async {
    try {
      // Tạo tên file theo format IMG_yyyyMMdd_HHmmss
      final now = DateTime.now();
      final fileName = 'IMG_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.jpg';
      
      // Lấy thư mục documents của app
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${directory.path}/photos');
      
      // Tạo thư mục photos nếu chưa có
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }
      
      // Copy file ảnh vào thư mục photos của app
      final savedFile = File('${photosDir.path}/$fileName');
      await imageFile.copy(savedFile.path);
      
      // Lưu thông tin ảnh vào SharedPreferences
      await _savePhotoInfo(fileName, savedFile.path, now);
      
      return fileName;
    } catch (e) {
      print('Error saving photo: $e');
      return null;
    }
  }
  
  // Lưu thông tin ảnh vào SharedPreferences
  static Future<void> _savePhotoInfo(String fileName, String filePath, DateTime createdAt) async {
    final prefs = await SharedPreferences.getInstance();
    final photosJson = prefs.getString(_photosKey) ?? '[]';
    final List<dynamic> photos = json.decode(photosJson);
    
    // Thêm ảnh mới vào đầu danh sách
    photos.insert(0, {
      'fileName': fileName,
      'filePath': filePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
    });
    
    // Lưu lại danh sách
    await prefs.setString(_photosKey, json.encode(photos));
  }
  
  // Lấy danh sách tất cả ảnh đã lưu
  static Future<List<PhotoInfo>> getAllPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photosJson = prefs.getString(_photosKey) ?? '[]';
      final List<dynamic> photos = json.decode(photosJson);
      
      List<PhotoInfo> photoInfos = [];
      
      for (var photo in photos) {
        final file = File(photo['filePath']);
        // Chỉ thêm vào danh sách nếu file vẫn tồn tại
        if (await file.exists()) {
          photoInfos.add(PhotoInfo(
            fileName: photo['fileName'],
            filePath: photo['filePath'],
            createdAt: DateTime.fromMillisecondsSinceEpoch(photo['createdAt']),
            file: file,
          ));
        }
      }
      
      // Sort theo thời gian tạo (mới nhất lên đầu)
      photoInfos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return photoInfos;
    } catch (e) {
      print('Error getting photos: $e');
      return [];
    }
  }
  
  // Xóa ảnh
  static Future<bool> deletePhoto(PhotoInfo photoInfo) async {
    try {
      // Xóa file
      if (await photoInfo.file.exists()) {
        await photoInfo.file.delete();
      }
      
      // Xóa khỏi SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final photosJson = prefs.getString(_photosKey) ?? '[]';
      final List<dynamic> photos = json.decode(photosJson);
      
      photos.removeWhere((photo) => photo['filePath'] == photoInfo.filePath);
      
      await prefs.setString(_photosKey, json.encode(photos));
      
      return true;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }
  
  // Xóa tất cả ảnh
  static Future<void> clearAllPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_photosKey);
      
      // Xóa thư mục photos
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${directory.path}/photos');
      if (await photosDir.exists()) {
        await photosDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing photos: $e');
    }
  }
  
  // Lấy số lượng ảnh đã lưu
  static Future<int> getPhotosCount() async {
    final photos = await getAllPhotos();
    return photos.length;
  }
}

class PhotoInfo {
  final String fileName;
  final String filePath;
  final DateTime createdAt;
  final File file;
  
  PhotoInfo({
    required this.fileName,
    required this.filePath,
    required this.createdAt,
    required this.file,
  });
}

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PhotoStorageService {
  static const String mediaBoxName = 'media_box';

  static Box<MediaModel> get _mediaBox => Hive.box<MediaModel>(mediaBoxName);

  // Lưu ảnh vào bộ nhớ trong app
  static Future<String?> savePhoto(File imageFile) async {
    try {
      // Tạo tên file theo format IMG_yyyyMMdd_HHmmss
      final now = DateTime.now();
      final fileName =
          'IMG_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.jpg';

      // Lấy thư mục documents của app
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${directory.path}/media');

      // Tạo thư mục media nếu chưa có
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      // Copy file ảnh vào thư mục media của app
      final savedFile = File('${mediaDir.path}/$fileName');
      await imageFile.copy(savedFile.path);

      // Lưu thông tin ảnh vào Hive
      await _savePhotoInfo(fileName, savedFile.path, now);

      return fileName;
    } catch (e) {
      print('Error saving photo: $e');
      return null;
    }
  }

  // Lưu video vào bộ nhớ trong app
  static Future<String?> saveVideo(File videoFile) async {
    try {
      print('🎥 [DEBUG] saveVideo called with: ${videoFile.path}');
      print('🎥 [DEBUG] Video file exists: ${await videoFile.exists()}');
      // Tạo tên file theo format VID_yyyyMMdd_HHmmss
      final now = DateTime.now();
      final fileName =
          'VID_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.mp4';

      // Lấy thư mục documents của app
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${directory.path}/media');

      // Tạo thư mục media nếu chưa có
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      // Copy file video vào thư mục media của app
      final savedFile = File('${mediaDir.path}/$fileName');
      print(
        '🎥 [DEBUG] Copying video from ${videoFile.path} to ${savedFile.path}',
      );
      await videoFile.copy(savedFile.path);
      print(
        '🎥 [DEBUG] Video copied successfully. New file exists: ${await savedFile.exists()}',
      );

      // Lưu thông tin video vào Hive
      final media = MediaModel(
        id: savedFile.path,
        fileName: fileName,
        filePath: savedFile.path,
        createdAt: now,
        mediaType: 'video',
      );

      await _mediaBox.put(media.id, media);
      print(
        '🎥 [DEBUG] Video metadata saved to Hive. Box length: ${_mediaBox.length}',
      );

      return fileName;
    } catch (e) {
      print('❌ [ERROR] Error saving video: $e');
      print('❌ [ERROR] Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Lưu thông tin ảnh vào SharedPreferences
  static Future<void> _savePhotoInfo(
    String fileName,
    String filePath,
    DateTime createdAt,
  ) async {
    final media = MediaModel(
      id: filePath,
      fileName: fileName,
      filePath: filePath,
      createdAt: createdAt,
      mediaType: 'photo',
    );

    await _mediaBox.put(media.id, media);
  }

  // Lấy danh sách tất cả ảnh đã lưu
  static Future<List<PhotoInfo>> getAllPhotos() async {
    try {
      List<PhotoInfo> photoInfos = [];

      for (final media in _mediaBox.values) {
        if (media.mediaType != 'photo') {
          continue;
        }

        final file = File(media.filePath);
        // Chỉ thêm vào danh sách nếu file vẫn tồn tại
        if (await file.exists()) {
          photoInfos.add(
            PhotoInfo(
              fileName: media.fileName,
              filePath: media.filePath,
              createdAt: media.createdAt,
              file: file,
            ),
          );
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

      // Xóa khỏi Hive
      await _mediaBox.delete(photoInfo.filePath);

      return true;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }

  // Xóa tất cả ảnh
  static Future<void> clearAllPhotos() async {
    try {
      final photos = await getAllPhotos();

      for (final photo in photos) {
        await deletePhoto(photo);
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

class MediaModel {
  final String id;
  final String fileName;
  final String filePath;
  final DateTime createdAt;
  final String mediaType; // 'photo' hoặc 'video'

  MediaModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.createdAt,
    required this.mediaType,
  });
}

class MediaModelAdapter extends TypeAdapter<MediaModel> {
  @override
  final int typeId = 0;

  @override
  MediaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final Map<int, dynamic> fields = {};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return MediaModel(
      id: fields[0] as String,
      fileName: fields[1] as String,
      filePath: fields[2] as String,
      createdAt: fields[3] as DateTime,
      mediaType: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MediaModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.mediaType);
  }
}

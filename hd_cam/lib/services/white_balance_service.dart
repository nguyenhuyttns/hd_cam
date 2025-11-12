import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

// Convert từ WhiteBalanceManager.kt của V169
enum WhiteBalanceMode {
  DEFAULT,
  FOGGY,
  DAYLIGHT,
  SPIKE,
  GLOAM
}

class WhiteBalanceService {
  WhiteBalanceMode _currentMode = WhiteBalanceMode.DEFAULT;
  
  WhiteBalanceMode get currentMode => _currentMode;
  
  void setWhiteBalance(WhiteBalanceMode mode) {
    _currentMode = mode;
  }
  
  // Convert từ Android Camera2 AWB modes sang Flutter
  String getCameraWhiteBalanceMode() {
    switch (_currentMode) {
      case WhiteBalanceMode.DEFAULT:
        return 'auto'; // CaptureRequest.CONTROL_AWB_MODE_AUTO
      case WhiteBalanceMode.FOGGY:
        return 'cloudy'; // CaptureRequest.CONTROL_AWB_MODE_CLOUDY_DAYLIGHT
      case WhiteBalanceMode.DAYLIGHT:
        return 'daylight'; // CaptureRequest.CONTROL_AWB_MODE_DAYLIGHT
      case WhiteBalanceMode.SPIKE:
        return 'fluorescent'; // CaptureRequest.CONTROL_AWB_MODE_FLUORESCENT
      case WhiteBalanceMode.GLOAM:
        return 'incandescent'; // CaptureRequest.CONTROL_AWB_MODE_INCANDESCENT
    }
  }
  
  // Convert từ GPUImageWhiteBalanceFilter.java - Temperature values
  double getTemperatureValue() {
    switch (_currentMode) {
      case WhiteBalanceMode.DEFAULT:
        return 5000.0; // Neutral temperature
      case WhiteBalanceMode.FOGGY:
        return 6500.0; // Cool temperature (cloudy)
      case WhiteBalanceMode.DAYLIGHT:
        return 5500.0; // Daylight temperature
      case WhiteBalanceMode.SPIKE:
        return 4000.0; // Cool fluorescent
      case WhiteBalanceMode.GLOAM:
        return 3200.0; // Warm incandescent
    }
  }
  
  // Convert từ GPUImageWhiteBalanceFilter.java - Tint values
  double getTintValue() {
    switch (_currentMode) {
      case WhiteBalanceMode.DEFAULT:
        return 0.0;
      case WhiteBalanceMode.FOGGY:
        return 10.0; // Slight magenta tint
      case WhiteBalanceMode.DAYLIGHT:
        return 0.0; // Neutral tint
      case WhiteBalanceMode.SPIKE:
        return -15.0; // Green tint for fluorescent
      case WhiteBalanceMode.GLOAM:
        return 5.0; // Slight magenta for warmth
    }
  }
  
  // Convert GPU shader logic sang Flutter Canvas processing
  Future<File> applyWhiteBalanceToImage(File originalFile) async {
    if (_currentMode == WhiteBalanceMode.DEFAULT) {
      return originalFile; // No processing needed
    }
    
    try {
      // Đọc ảnh gốc
      final Uint8List originalBytes = await originalFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(originalBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image originalImage = frameInfo.image;

      // Lấy temperature và tint values từ GPU shader logic
      final double temperature = _calculateTemperatureStrength();
      final double tint = _calculateTintStrength();
      
      // Tạo canvas để xử lý ảnh
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      
      // Vẽ ảnh gốc
      canvas.drawImage(originalImage, Offset.zero, Paint());
      
      // Áp dụng white balance effect
      if (temperature != 0.0 || tint != 0.0) {
        final Paint wbPaint = Paint()
          ..color = _getWhiteBalanceColor(temperature, tint)
          ..blendMode = _getBlendModeForWB();
        
        canvas.drawRect(
          Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
          wbPaint,
        );
      }
      
      // Tạo ảnh đã xử lý
      final ui.Picture picture = recorder.endRecording();
      final ui.Image processedImage = await picture.toImage(
        originalImage.width,
        originalImage.height,
      );
      
      // Convert thành bytes
      final ByteData? byteData = await processedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List processedBytes = byteData!.buffer.asUint8List();
      
      // Lưu file mới
      final String tempPath = '${originalFile.parent.path}/temp_wb_${DateTime.now().millisecondsSinceEpoch}.png';
      final File processedFile = File(tempPath);
      await processedFile.writeAsBytes(processedBytes);
      
      // Cleanup
      originalImage.dispose();
      processedImage.dispose();
      
      return processedFile;
      
    } catch (e) {
      print('Error applying white balance: $e');
      return originalFile;
    }
  }
  
  // Convert từ GPU shader setTemperature logic
  double _calculateTemperatureStrength() {
    final double temp = getTemperatureValue();
    final double factor = temp < 5000.0 ? 0.0004 : 0.00006;
    return (temp - 5000.0) * factor;
  }
  
  // Convert từ GPU shader setTint logic  
  double _calculateTintStrength() {
    final double tint = getTintValue();
    return tint / 100.0;
  }
  
  // Convert GPU warmFilter và RGB processing logic
  Color _getWhiteBalanceColor(double temperature, double tint) {
    // warmFilter từ GPU shader: vec3(0.93, 0.14, 0.0)
    const double warmR = 0.93;
    const double warmG = 0.14; 
    const double warmB = 0.0;
    
    // Tính toán RGB values dựa trên temperature
    double r, g, b;
    
    if (temperature > 0) {
      // Warm temperature
      r = 1.0 * (1.0 + temperature * warmR);
      g = 1.0 * (1.0 + temperature * warmG);
      b = 1.0 * (1.0 + temperature * warmB);
    } else {
      // Cool temperature  
      r = 1.0 * (1.0 - temperature.abs() * 0.2);
      g = 1.0 * (1.0 - temperature.abs() * 0.1);
      b = 1.0 * (1.0 + temperature.abs() * 0.3);
    }
    
    // Áp dụng tint (magenta-green axis)
    if (tint > 0) {
      // Magenta tint
      r = (r + tint * 0.2).clamp(0.0, 1.0);
      b = (b + tint * 0.2).clamp(0.0, 1.0);
    } else {
      // Green tint
      g = (g - tint * 0.2).clamp(0.0, 1.0);
    }
    
    // Clamp values
    r = r.clamp(0.0, 1.0);
    g = g.clamp(0.0, 1.0);
    b = b.clamp(0.0, 1.0);
    
    return Color.fromRGBO(
      (r * 255).round(),
      (g * 255).round(), 
      (b * 255).round(),
      0.3, // Alpha for blending
    );
  }
  
  BlendMode _getBlendModeForWB() {
    switch (_currentMode) {
      case WhiteBalanceMode.FOGGY:
        return BlendMode.multiply; // Cool effect
      case WhiteBalanceMode.DAYLIGHT:
        return BlendMode.overlay; // Neutral enhancement
      case WhiteBalanceMode.SPIKE:
        return BlendMode.colorBurn; // Strong fluorescent correction
      case WhiteBalanceMode.GLOAM:
        return BlendMode.softLight; // Warm gentle effect
      default:
        return BlendMode.overlay;
    }
  }
  
  // Preview overlay color cho camera preview
  Color? getPreviewOverlayColor() {
    if (_currentMode == WhiteBalanceMode.DEFAULT) {
      return null;
    }
    
    final double temperature = _calculateTemperatureStrength();
    final double tint = _calculateTintStrength();
    return _getWhiteBalanceColor(temperature, tint);
  }
  
  BlendMode getPreviewBlendMode() {
    return _getBlendModeForWB();
  }
}

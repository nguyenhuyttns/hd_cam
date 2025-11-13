import 'package:flutter/material.dart';
import '../../views/home/home_screen.dart';
import '../../views/camera/camera_screen.dart';
import '../../views/gallery/gallery_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String camera = '/camera';
  static const String gallery = '/gallery';
  
  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      camera: (context) => const V169CameraScreen(),
      gallery: (context) => const GalleryScreen(),
    };
  }
  
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case camera:
        return MaterialPageRoute(builder: (context) => const V169CameraScreen());
      case gallery:
        return MaterialPageRoute(builder: (context) => const GalleryScreen());
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}

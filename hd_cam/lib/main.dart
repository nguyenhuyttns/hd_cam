import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/photo_storage_service.dart';
import 'views/home/home_screen.dart';
import 'app/config/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MediaModelAdapter());
  await Hive.openBox<MediaModel>(PhotoStorageService.mediaBoxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HD Camera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

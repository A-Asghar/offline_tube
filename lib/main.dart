import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_tube/services/audio_service.dart';
import 'package:offline_tube/bottom_nav_bar/bottom_navbar.dart';
import 'package:offline_tube/services/navigation_service.dart';
import 'package:offline_tube/services/video_service.dart';
import 'package:offline_tube/util/video_extensions.dart';
import 'package:offline_tube/services/youtube_service.dart';

final GetIt getIt = GetIt.instance;
YoutubeService youtubeService = YoutubeService.instance;
VideoService videoService = VideoService.instance;

void main() async {
  getIt.registerSingleton<CustomAudioHandler>(await initAudioService());
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(VideoWrapperAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF151414),
        primaryColor: Colors.white,
      ),
      home: const BottomNavbar(),
      navigatorKey: NavigationService.navigatorKey,
    );
  }
}

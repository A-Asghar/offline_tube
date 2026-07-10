import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_tube/services/audio_service.dart';
import 'package:offline_tube/bottom_nav_bar/bottom_navbar.dart';
import 'package:offline_tube/services/current_playing_service.dart';
import 'package:offline_tube/services/downloads_service.dart';
import 'package:offline_tube/services/navigation_service.dart';
import 'package:offline_tube/services/video_service.dart';
import 'package:offline_tube/util/video_extensions.dart';
import 'package:offline_tube/services/youtube_service.dart';

final GetIt getIt = GetIt.instance;
YoutubeService youtubeService = YoutubeService.instance;
VideoService videoService = VideoService.instance;
CurrentPlayingService currentPlayingService = CurrentPlayingService();
DownloadsService downloadsService = DownloadsService.instance;

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
      debugShowCheckedModeBanner: false,
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

class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) => const MyContainer(),
        ),
      ),
    );
  }
}

class MyContainer extends StatelessWidget {
  const MyContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.red,
      ),
    );
  }
}

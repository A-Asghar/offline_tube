import 'package:offline_tube/main.dart';
import 'package:offline_tube/services/downloads_service.dart';
import 'package:offline_tube/util/util.dart';
import 'package:offline_tube/util/video_extensions.dart';
import 'package:stacked/stacked.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerViewModel extends BaseViewModel {
  final VideoWrapper video;

  late YoutubePlayerController controller;

  bool isEnded = false;

  bool isLoading = false;

  List<VideoWrapper> recommendedVideos = [];

  Channel? channelData;

  bool isDownloading = false;
  bool isDownloaded = false;

  VideoPlayerViewModel({required this.video});

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    _initPlayerController();

    // Optionally fetch recommended videos and channel data
    // await _getRecommended();
    // await _getChannelData();

    _checkDownloaded();

    isLoading = false;
    notifyListeners();
  }

  void _initPlayerController() {
    controller = YoutubePlayerController(
      initialVideoId: video.video.id.value,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  void markEnded() {
    isEnded = true;
    notifyListeners();
  }

  /// If you want to fetch recommended videos.
  // Future<void> _getRecommended() async {
  //   final result = await youtubeService.getRecommended(video);
  //   recommendedVideos = result ?? [];
  //   notifyListeners();
  // }

  /// If you want to fetch channel data.
  // Future<void> _getChannelData() async {
  //   channelData = await youtubeService.getChannelData(video.channelId.value);
  //   notifyListeners();
  // }

  void _checkDownloaded() {
    final downloads = videoService.downloadedVideos;
    isDownloaded = downloads.any(
      (e) => e.video.id.value == video.video.id.value,
    );
  }

  Future<void> handleDownload() async {
    if (isDownloaded || isDownloading) return;

    isDownloading = true;
    notifyListeners();

    try {
      DownloadingProgress downloadItem = DownloadingProgress(
        thumbUrl: video.video.thumbnails.mediumResUrl,
        title: video.video.title,
        progress: 0.0,
      );
      await downLoadToTemp(video.video.id.value, progress: downloadItem);
      await videoService.addToLocal(item: video.video.downloaded);
      videoService.downloadedVideos.add(video);

      isDownloaded = true;
      isDownloading = false;
      notifyListeners();
    } catch (e) {
      isDownloading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

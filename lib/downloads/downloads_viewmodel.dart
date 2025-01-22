import 'package:stacked/stacked.dart';
import 'package:audio_service/audio_service.dart';
import 'package:offline_tube/services/audio_service.dart';
import 'package:offline_tube/main.dart';
import 'package:offline_tube/util/util.dart';
import 'package:offline_tube/util/video_extensions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final _audioHandler = getIt<CustomAudioHandler>();

class DownloadsViewModel extends BaseViewModel {
  bool isLoading = false;
  List<VideoWrapper> items = [];

  VideoWrapper? _currentPlaying;
  VideoWrapper? get currentPlaying => _currentPlaying;
  set currentPlaying(VideoWrapper? value) {
    _currentPlaying = value;
    notifyListeners();
  }

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    _audioHandler.clear();

    await _getData();
    await _downloadData();

    isLoading = false;
    notifyListeners();
  }

  MediaItem _createMediaItem(String path, Video video) {
    return MediaItem(
      id: video.id.value,
      title: video.title,
      artist: video.author,
      artUri: Uri.parse(video.thumbnails.mediumResUrl),
      duration: video.duration,
      extras: {'url': path},
    );
  }

  Future<void> _downloadData() async {
    for (final videoWrapper in items) {
      final video = videoWrapper.video;
      final path = await downLoadToTemp(video.id.value);
      if (path == null) continue;
      await _audioHandler.addQueueItem(_createMediaItem(path, video));
    }
  }

  Future<void> _getData() async {
    items = videoService.downloadedVideos.toList();
    notifyListeners();
  }

  Future<void> onTapPlay(int index) async {
    await _audioHandler.skipToQueueItem(index);
    _audioHandler.play();
    currentPlaying = items[index];
  }

  Future<void> onTapDelete(int index) async {
    final videoWrapper = items[index];

    await videoService.removeFromLocal(videoWrapper);
    await deleteDownload(videoWrapper.video.id.value);

    _audioHandler.removeQueueItemAt(index);

    videoService.downloadedVideos.remove(videoWrapper);
    items.removeAt(index);

    notifyListeners();
  }
}

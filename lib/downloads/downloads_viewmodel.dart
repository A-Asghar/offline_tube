import 'package:offline_tube/services/current_playing_service.dart';
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

  bool get showCurrentPlaying => currentPlayingService.playing.value != null;
  MediaItem get currentPlaying => currentPlayingService.playing.value!;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    _audioHandler.clear();

    await _getData();
    await _downloadData();
    _listenToCurrentPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
    _listenToPlaybackState();

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

  Future<void> onTapItem(int index) async {
    await _audioHandler.skipToQueueItem(index);
    _audioHandler.play();
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

  void onPreviousTap() => _audioHandler.skipToPrevious();
  void onNextTap() => _audioHandler.skipToNext();
  void onTapPause() => _audioHandler.pause();
  void onSeek(Duration position) => _audioHandler.seek(position);
  void onTapPlay() => _audioHandler.play();

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = currentPlayingService.progressBarState.value;
      currentPlayingService.progressBarState.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = currentPlayingService.progressBarState.value;
      currentPlayingService.progressBarState.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((item) async {
      if (item == null) return;
      currentPlayingService.playing.value = item;
      notifyListeners();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        currentPlayingService.playPauseButtonState.value = ButtonState.loading;
      } else if (!isPlaying) {
        currentPlayingService.playPauseButtonState.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        currentPlayingService.playPauseButtonState.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }
}

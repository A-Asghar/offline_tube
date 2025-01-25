import 'dart:async';

import 'package:stacked/stacked.dart';

class DownloadsService with ListenableServiceMixin {
  DownloadsService._singleton();
  static final DownloadsService _instance = DownloadsService._singleton();
  static DownloadsService get instance => _instance;

  final _progressController =
      StreamController<Map<String, DownloadingProgress>>.broadcast();

  final Map<String, DownloadingProgress> _progress = {};

  Stream<Map<String, DownloadingProgress>> get progressStream =>
      _progressController.stream;

  Map<String, DownloadingProgress> get progress => _progress;

  void updateProgress(String videoId, DownloadingProgress value) {
    _progress[videoId] = value;
    _progressController.add(Map<String, DownloadingProgress>.from(_progress));
  }

  void remove(String id) {
    _progress.remove(id);
    _progressController.add(Map<String, DownloadingProgress>.from(_progress));
  }

  void dispose() {
    _progressController.close();
  }
}

class DownloadingProgress {
  String thumbUrl;
  String title;
  double progress;
  DownloadingProgress({
    this.thumbUrl = '',
    this.title = '',
    this.progress = 0.0,
  });
}

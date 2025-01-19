import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:offline_tube/main.dart';
import 'package:offline_tube/util/video_extensions.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  bool isLoading = false;
  bool isLoadingMore = false;

  final ScrollController scrollController = ScrollController();

  final Set<String> _existingVideoIds = {};
  Timer? _debounce;

  Future<void> init() async {
    scrollController.addListener(_onScroll);

    if (videoService.recommendedVideos.isEmpty) {
      await _init();
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        !isLoading) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 200), () {
        _loadMore();
      });
    }
  }

  Future<void> _init() async {
    isLoading = true;
    notifyListeners();

    await _getDownloadedVideos();
    await _getRecommended();

    isLoading = false;
    notifyListeners();
  }

  Future<void> _getDownloadedVideos() async {
    videoService.visitedVideos = await videoService.readFromLocal();

    final List<VideoWrapper> downloads =
        videoService.visitedVideos.where((e) => e.isDownloaded).toList();

    videoService.downloadedVideos = downloads.toSet();
    _existingVideoIds.addAll(downloads.map((video) => video.video.id.value));
  }

  Future<void> _getRecommended() async {
    if (videoService.recommendedVideos.isNotEmpty) return;

    final List<VideoWrapper> list = await _getRandom(2);

    final results = await Future.wait(
      list.map((e) => youtubeService.getRecommended(e.video)),
    );

    for (final r in results) {
      if (r == null) continue;
      final newVideos = _removeDuplicates(r.toList());
      videoService.recommendedVideos.addAll(
        newVideos.map((e) => e),
      );
      _existingVideoIds.addAll(newVideos.map((v) => v.video.id.value));
    }

    videoService.recommendedVideos.shuffle();
  }

  Future<void> _loadMore() async {
    isLoadingMore = true;
    notifyListeners();

    final List<VideoWrapper> list = await _getRandom(1);

    final results = await Future.wait(
      list.map((e) => youtubeService.getRecommended(e.video)),
    );

    for (final r in results) {
      if (r == null) continue;
      final newVideos = _removeDuplicates(r.toList());
      videoService.recommendedVideos.addAll(
        newVideos.map((e) => e),
      );
      _existingVideoIds.addAll(newVideos.map((v) => v.video.id.value));
    }

    isLoadingMore = false;
    notifyListeners();
  }

  Future<List<VideoWrapper>> _getRandom(int val) async {
    final List<VideoWrapper> videos = videoService.visitedVideos;
    if (videos.isEmpty) return [];
    final List<VideoWrapper> shuffled = List.from(videos)..shuffle(Random());
    return shuffled.take(val).toList();
  }

  List<VideoWrapper> _removeDuplicates(List<VideoWrapper> newVideos) {
    final result = <VideoWrapper>[];
    for (final video in newVideos) {
      if (!_existingVideoIds.contains(video.video.id.value)) {
        _existingVideoIds.add(video.video.id.value);
        result.add(video);
      }
    }
    return result;
  }

  void handleVideoTap(VideoWrapper video, BuildContext context) {
    handleVideoTap(video, context);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}

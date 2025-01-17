import 'dart:async';
import 'package:flutter/material.dart';
import 'package:offline_tube/main.dart';
import 'package:stacked/stacked.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchViewModel extends BaseViewModel {
  bool isLoading = false;
  bool isLoadingMore = false;
  String searchText = '';

  final ScrollController scrollController = ScrollController();

  List<Video>? searchResults;

  VideoSearchList? response;

  void init() {
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent &&
        !isLoadingMore) {
      loadMore();
    }
  }

  Future<void> handleSearch(String query) async {
    isLoading = true;
    notifyListeners();

    response = await _search(query);
    searchResults = response;
    searchText = query;

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (response == null) return;

    isLoadingMore = true;
    notifyListeners();

    response = await _search(searchText, response);
    searchResults?.addAll(response ?? []);

    isLoadingMore = false;
    notifyListeners();
  }

  Future<VideoSearchList?> _search(
    String query, [
    VideoSearchList? nextPage,
  ]) async {
    return await youtubeService.search(query: query, list: nextPage);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

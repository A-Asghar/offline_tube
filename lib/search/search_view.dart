import 'package:flutter/material.dart';
import 'package:offline_tube/home/widgets/video_list.dart';
import 'package:offline_tube/search/search_viewmodel.dart';
import 'package:offline_tube/search/widgets/search_bar.dart';
import 'package:offline_tube/widgets/shimmer_video_list.dart';
import 'package:offline_tube/widgets/video_item.dart';
import 'package:stacked/stacked.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchViewModel>.reactive(
      viewModelBuilder: () => SearchViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  CustomSearchBar(
                    onSearch: model.handleSearch,
                  ),
                  const SizedBox(height: 16),
                  if (model.isLoading)
                    const Expanded(child: ShimmerVideoList())
                  else
                    model.response == null
                        ? const SizedBox.shrink()
                        : Expanded(
                            child: VideoList(
                              videos: model.searchResults ?? [],
                              scrollController: model.scrollController,
                              onVideoTap: (video) =>
                                  handleVideoTap(video, context),
                              isLoadingMore: model.isLoadingMore,
                            ),
                          ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

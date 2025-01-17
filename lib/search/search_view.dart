import 'package:flutter/material.dart';
import 'package:offline_tube/search/search_viewmodel.dart';
import 'package:offline_tube/search/widgets/search_bar.dart';
import 'package:offline_tube/util/video_extensions.dart';
import 'package:offline_tube/widgets/loading_widget.dart';
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
                    const Expanded(child: Loading())
                  else
                    model.response == null
                        ? const SizedBox.shrink()
                        : Expanded(
                            child: ListView.builder(
                              controller: model.scrollController,
                              itemCount: model.searchResults?.length ?? 0,
                              itemBuilder: (context, index) {
                                final video = model.searchResults?[index];
                                if (video == null) {
                                  return const SizedBox.shrink();
                                }
                                return VideoItem(
                                  video: video,
                                  onTap: () => handleVideoTap(
                                    video.unDownloaded,
                                    context,
                                  ),
                                );
                              },
                            ),
                          ),
                  if (model.isLoadingMore) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

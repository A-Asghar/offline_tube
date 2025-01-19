import 'package:flutter/material.dart';
import 'package:offline_tube/home/home_viewmodel.dart';
import 'package:offline_tube/home/widgets/no_videos.dart';
import 'package:offline_tube/home/widgets/video_list.dart';
import 'package:offline_tube/main.dart';
import 'package:offline_tube/widgets/shimmer_video_item.dart';
import 'package:offline_tube/widgets/video_item.dart';
import 'package:stacked/stacked.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          body: SafeArea(
            child: model.isLoading
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListView(
                      children: [
                        for (int i = 0; i < 3; i++) const ShimmerVideoItem(),
                      ],
                    ),
                  )
                : videoService.recommendedVideos.isEmpty
                    ? const NoVideos()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: VideoList(
                          videos: videoService.recommendedVideos,
                          scrollController: model.scrollController,
                          isLoadingMore: model.isLoadingMore,
                          onVideoTap: (video) => handleVideoTap(
                            video,
                            context,
                          ),
                        ),
                      ),
          ),
        );
      },
    );
  }
}

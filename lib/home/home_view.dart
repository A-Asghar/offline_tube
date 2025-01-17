import 'package:flutter/material.dart';
import 'package:offline_tube/home/home_viewmodel.dart';
import 'package:offline_tube/home/widgets/video_list.dart';
import 'package:offline_tube/main.dart';
import 'package:offline_tube/widgets/loading_widget.dart';
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
                ? const Center(child: Loading())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: VideoList(
                            videos: videoService.recommendedVideos,
                            scrollController: model.scrollController,
                            onVideoTap: (video) =>
                                model.handleVideoTap(video, context),
                          ),
                        ),
                      ),
                      if (model.isLoadingMore)
                        Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Loading(),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

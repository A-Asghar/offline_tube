import 'package:flutter/material.dart';
import 'package:offline_tube/downloads/downloads_viewmodel.dart';
import 'package:offline_tube/widgets/shimmer_video_item.dart';
import 'package:stacked/stacked.dart';

import 'package:offline_tube/widgets/video_item.dart';

class DownloadsView extends StatelessWidget {
  const DownloadsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DownloadsViewModel>.reactive(
      viewModelBuilder: () => DownloadsViewModel(),
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
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: model.items.length,
                            itemBuilder: (context, index) {
                              final videoWrapper = model.items[index];
                              return VideoItem(
                                video: videoWrapper.video,
                                onTap: () => model.onTapPlay(index),
                                onTapDelete: () => model.onTapDelete(index),
                              );
                            },
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

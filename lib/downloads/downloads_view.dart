import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:offline_tube/downloads/downloads_viewmodel.dart';
import 'package:offline_tube/downloads/widgets/download_item.dart';
import 'package:offline_tube/util/video_extensions.dart';
import 'package:offline_tube/widgets/shimmer_video_list.dart';
import 'package:stacked/stacked.dart';

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
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ShimmerVideoList(),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        if (model.currentPlaying != null) ...[
                          _CurrentPlaying(item: model.currentPlaying!),
                          const SizedBox(height: 16),
                        ],
                        Expanded(
                          child: ListView.builder(
                            itemCount: model.items.length,
                            itemBuilder: (context, index) {
                              final videoWrapper = model.items[index];
                              return DownloadItem(
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

class _CurrentPlaying extends StatelessWidget {
  _CurrentPlaying({required this.item});
  final VideoWrapper item;

  final List<Icon> _icons = [
    const Icon(Icons.arrow_back_ios, color: Colors.white),
    const Icon(Icons.play_arrow, color: Colors.white),
    const Icon(Icons.arrow_forward_ios, color: Colors.white),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.white.withOpacity(0.1),
        //     blurRadius: 2,
        //     spreadRadius: 1,
        //     offset: const Offset(0, 0),
        //   ),
        // ],
      ),
      child: Column(
        children: [
          DownloadItem(
            video: item.video,
            onTap: () {},
            onTapDelete: null,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _icons.map((e) => e).toList(),
          )
        ],
      ),
    );
  }
}

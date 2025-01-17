import 'package:flutter/material.dart';
import 'package:offline_tube/util/video_extensions.dart';
import 'package:offline_tube/video_player/video_player_viewmodel.dart';
import 'package:offline_tube/video_player/widgets/download_button.dart';
import 'package:offline_tube/video_player/widgets/video_info_widget.dart';
import 'package:offline_tube/widgets/loading_widget.dart';
import 'package:offline_tube/widgets/video_item.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerView extends StatelessWidget {
  final VideoWrapper video;

  const VideoPlayerView({
    super.key,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VideoPlayerViewModel>.reactive(
      viewModelBuilder: () => VideoPlayerViewModel(video: video),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          body: SafeArea(
            child: model.isLoading
                ? const Loading()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (model.isEnded)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CachedNetworkImage(
                            imageUrl: model.video.video.thumbnails.maxResUrl,
                            cacheKey: model.video.video.thumbnails.maxResUrl,
                          ),
                        )
                      else
                        YoutubePlayer(
                          controller: model.controller,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.blueAccent,
                          aspectRatio: 16 / 9,
                          onEnded: (_) => model.markEnded(),
                        ),
                      const SizedBox(height: 12),
                      VideoInfoWidget(
                        video: model.video.video,
                        channel: model.channelData,
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: DownloadButton(),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ListView.builder(
                            itemCount: model.recommendedVideos.length,
                            itemBuilder: (context, index) {
                              final item = model.recommendedVideos[index];
                              return VideoItem(
                                video: item.video,
                                onTap: () => handleVideoTap(item, context),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

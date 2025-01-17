import 'package:flutter/material.dart';
import 'package:offline_tube/util/video_extensions.dart';
import 'package:offline_tube/widgets/video_item.dart';

class VideoList extends StatelessWidget {
  final List<VideoWrapper> videos;
  final ScrollController scrollController;
  final Function(VideoWrapper) onVideoTap;

  const VideoList({
    super.key,
    required this.videos,
    required this.scrollController,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey<String>('videoListView'),
      controller: scrollController,
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return VideoItem(
          key: ValueKey(video.video.id.value),
          video: video.video,
          onTap: () => onVideoTap(video),
        );
      },
    );
  }
}

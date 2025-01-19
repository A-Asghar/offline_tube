import 'package:flutter/material.dart';
import 'package:offline_tube/util/video_extensions.dart';
import 'package:offline_tube/widgets/shimmer_video_item.dart';
import 'package:offline_tube/widgets/video_item.dart';

class VideoList extends StatelessWidget {
  final List<VideoWrapper> videos;
  final ScrollController scrollController;
  final Function(VideoWrapper) onVideoTap;
  final bool isLoadingMore;

  const VideoList({
    super.key,
    required this.videos,
    required this.scrollController,
    required this.onVideoTap,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey<String>('videoListView'),
      controller: scrollController,
      itemCount: isLoadingMore ? videos.length + 1 : videos.length,
      itemBuilder: (context, index) {
        if (index == videos.length - 1) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent + 200,
            duration: const Duration(seconds: 1),
            curve: Curves.ease,
          );
        }
        if (isLoadingMore && index == videos.length) {
          return const ShimmerVideoItem();
        }
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

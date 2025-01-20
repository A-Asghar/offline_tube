import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:offline_tube/main.dart';
import 'package:offline_tube/util/util.dart';
import 'package:offline_tube/util/video_extensions.dart';
import 'package:offline_tube/video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoItem extends StatelessWidget {
  const VideoItem({
    super.key,
    required this.video,
    required this.onTap,
    this.onTapDelete,
  });
  final Video video;
  final Function() onTap;
  final Function()? onTapDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: video.thumbnails.mediumResUrl,
                      cacheKey: video.thumbnails.mediumResUrl,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.only(right: 4, bottom: 4),
                      child: Text(
                        formatDuration(
                          video.duration ?? const Duration(seconds: 0),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cutText(
                size: 80,
                text: video.title,
              ),
              maxLines: 2,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Text(
                  video.author,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '${formatCount(video.engagement.viewCount)} views',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                _MoreButton(),
              ],
            ),
            if (onTapDelete != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onTapDelete,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

Future<void> handleVideoTap(VideoWrapper video, BuildContext context) async {
  videoService.addToLocal(item: video);
  videoService.visitedVideos.add(video);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => VideoPlayerView(video: video),
    ),
  );
}

class _MoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          backgroundColor: Colors.black,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text(
                    'Download',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                    'Add to playlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.all(4),
        child: const Icon(
          Icons.more_vert,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

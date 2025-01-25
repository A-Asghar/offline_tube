import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:offline_tube/services/downloads_service.dart';
import 'package:offline_tube/util/util.dart';

class DownloadProgressItem extends StatelessWidget {
  const DownloadProgressItem({super.key, required this.item});
  final DownloadingProgress? item;

  @override
  Widget build(BuildContext context) {
    if (item == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: item!.thumbUrl,
                  height: 80,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item!.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: width * 0.9,
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: item!.progress,
                    borderRadius: BorderRadius.circular(12),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${(item!.progress * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

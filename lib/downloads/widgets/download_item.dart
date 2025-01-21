import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadItem extends StatelessWidget {
  const DownloadItem({
    super.key,
    required this.video,
    required this.onTapDelete,
    required this.onTap,
  });
  final Video video;
  final Future<void> Function() onTapDelete;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: video.thumbnails.mediumResUrl,
                height: 80,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Text(
                          video.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return DeleteDialog(onTapDelete: onTapDelete);
                              },
                            );
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteDialog extends StatefulWidget {
  final Future<void> Function() onTapDelete;

  const DeleteDialog({super.key, required this.onTapDelete});

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete video'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : const Text('Are you sure you want to delete this video?'),
      actions: _isLoading
          ? []
          : [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await widget.onTapDelete();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
    );
  }
}

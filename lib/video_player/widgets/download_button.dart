import 'package:flutter/material.dart';
import 'package:offline_tube/video_player/video_player_viewmodel.dart';
import 'package:stacked/stacked.dart';

class DownloadButton extends ViewModelWidget<VideoPlayerViewModel> {
  const DownloadButton({super.key});

  @override
  Widget build(BuildContext context, VideoPlayerViewModel viewModel) {
    return InkWell(
      onTap: () async {
        if (viewModel.isDownloaded) return;
        await viewModel.handleDownload();
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (viewModel.isDownloading)
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            else ...[
              Text(
                viewModel.isDownloaded ? 'Downloaded' : 'Download',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                viewModel.isDownloaded ? Icons.check : Icons.download_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

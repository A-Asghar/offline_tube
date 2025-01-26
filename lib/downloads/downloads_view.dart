import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:offline_tube/downloads/downloads_viewmodel.dart';
import 'package:offline_tube/downloads/widgets/buttons.dart';
import 'package:offline_tube/downloads/widgets/download_item.dart';
import 'package:offline_tube/downloads/widgets/download_item_shimmer.dart';
import 'package:offline_tube/downloads/widgets/download_progress_item.dart';
import 'package:offline_tube/downloads/widgets/seek_bar.dart';
import 'package:offline_tube/main.dart';
import 'package:offline_tube/services/downloads_service.dart';
import 'package:stacked/stacked.dart';

class DownloadsView extends StatefulWidget {
  const DownloadsView({super.key});

  @override
  State<DownloadsView> createState() => _DownloadsViewState();
}

class _DownloadsViewState extends State<DownloadsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<DownloadsViewModel>.reactive(
      viewModelBuilder: () => DownloadsViewModel(),
      disposeViewModel: false,
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          body: SafeArea(
            child: model.isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: DownloadShimmerList(),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        if (model.showCurrentPlaying) ...[
                          _CurrentPlaying(
                            item: model.currentPlaying,
                            onSeek: model.onSeek,
                            onNextTap: model.onNextTap,
                            onPreviousTap: model.onPreviousTap,
                            onTapPause: model.onTapPause,
                            onTapPlay: model.onTapPlay,
                          ),
                          const SizedBox(height: 16),
                        ],
                        StreamBuilder<Map<String, DownloadingProgress>>(
                          stream: downloadsService.progressStream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            final progress = snapshot.data!;
                            if (progress.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return SizedBox(
                              height: 160,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Downloading',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView(
                                      children: progress.keys
                                          .map(
                                            (k) => DownloadProgressItem(
                                              item: progress[k],
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: model.items.length,
                            itemBuilder: (context, index) {
                              final videoWrapper = model.items[index];
                              return DownloadItem(
                                video: videoWrapper.video,
                                onTap: () => model.onTapItem(index),
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
  const _CurrentPlaying({
    required this.item,
    required this.onSeek,
    required this.onTapPause,
    required this.onTapPlay,
    required this.onPreviousTap,
    required this.onNextTap,
  });
  final MediaItem item;
  final Function(Duration) onSeek;
  final Function() onTapPause;
  final Function() onTapPlay;
  final Function() onPreviousTap;
  final Function() onNextTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: item.artUri?.toString() ?? '',
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          StreamBuilder(
            stream: currentPlayingService.progressBarState.values,
            builder: (_, context) {
              return SeekBar(
                duration: currentPlayingService.progressBarState.value.total,
                position: currentPlayingService.progressBarState.value.current,
                onChangeEnd: onSeek,
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PreviousSongButton(
                onTap: onPreviousTap,
              ),
              PlayPauseButton(
                pause: onTapPause,
                play: onTapPlay,
              ),
              NextSongButton(
                onTap: onNextTap,
              )
            ],
          ),
        ],
      ),
    );
  }
}

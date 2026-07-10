import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:offline_tube/main.dart';
import 'package:offline_tube/services/downloads_service.dart';
import 'package:offline_tube/util/video_extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:pool/pool.dart';

class YoutubeService {
  YoutubeService._singleton();

  static final YoutubeService _instance = YoutubeService._singleton();

  static YoutubeService get instance => _instance;

  final YoutubeExplode _youtubeExplode = YoutubeExplode();
  static final Pool _pool = Pool(5);

  Future<VideoSearchList?> search({
    required String query,
    VideoSearchList? list,
  }) async {
    if (list != null) return await list.nextPage();

    return await _youtubeExplode.search.search(query);
  }

  Future<String?> downloadAudioToTemp(
    VideoWrapper video, {
    DownloadingProgress? progress,
  }) async {
    String videoId = video.video.id.value;
    return _pool.withResource(() async {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/temp_audio_$videoId';
        final file = File(filePath);

        if (file.existsSync() && file.lengthSync() > 0) {
          return filePath;
        }

        final manifest = await _youtubeExplode.videos.streamsClient.getManifest(
          VideoId(videoId),
        );
        final audioStreamInfo = manifest.audioOnly.sortByBitrate().firstOrNull;
        if (audioStreamInfo == null) return null;

        final size = audioStreamInfo.size.totalBytes;
        final stream =
            _youtubeExplode.videos.streamsClient.get(audioStreamInfo);

        final partFilePath = '$filePath.part';
        final partFile = File(partFilePath);
        if (partFile.existsSync()) {
          try {
            partFile.deleteSync();
          } catch (_) {}
        }

        final fileStream = partFile.openWrite();
        var downloaded = 0;
        final completer = Completer<String?>();

        StreamSubscription<List<int>> subscription;
        subscription = stream.listen(
          (data) {
            downloaded += data.length;
            final currentProgress = downloaded / size;
            progress?.progress = currentProgress;
            if (progress != null) {
              downloadsService.updateProgress(
                videoId,
                DownloadingProgress(
                  progress: currentProgress,
                  thumbUrl: progress.thumbUrl,
                  title: progress.title,
                ),
              );
            }

            fileStream.add(data);
          },
          onDone: () async {
            try {
              await fileStream.flush();
              await fileStream.close();
              if (partFile.existsSync()) {
                if (file.existsSync()) {
                  try {
                    file.deleteSync();
                  } catch (_) {}
                }
                await partFile.rename(filePath);
              }
              downloadsService.remove(videoId);
              downloadsService.handleDownloadComplete(video);
              if (!completer.isCompleted) {
                completer.complete(filePath);
              }
            } catch (e) {
              debugPrint('Error finishing download for $videoId: $e');
              if (!completer.isCompleted) {
                completer.complete(null);
              }
            }
          },
          onError: (e) async {
            debugPrint('Download error for $videoId: $e');
            try {
              await fileStream.close();
              if (partFile.existsSync()) {
                partFile.deleteSync();
              }
            } catch (_) {}
            downloadsService.remove(videoId);
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          },
          cancelOnError: true,
        );

        downloadsService.addSubscription(videoId, subscription);

        return completer.future;
      } catch (e) {
        debugPrint('Error downloading audio for $videoId: $e');
        return null;
      }
    });
  }

  Future<List<VideoWrapper>?> getRecommended(Video video) async {
    try {
      List<VideoWrapper>? related = await compute(
        fetchRecommendedVideos,
        VideoWrapper(video: video).toJson(),
      );

      if (related == null) return null;

      return related;
    } catch (_) {
      return null;
    }
  }

  Future<Channel?> getChannelData(String channelId) async {
    Channel? channel;
    try {
      channel = await _youtubeExplode.channels.get(channelId);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
    return channel;
  }

  void dispose() {
    _youtubeExplode.close();
  }

  // Future<MyData> getData(String videoId) async {
  //   var stopwatch = Stopwatch()..start();
  //   var yt = YoutubeExplode();
  //   var manifest = await yt.videos.streams.getManifest(videoId);
  //   var videoStreams = manifest.streams
  //       .where((s) => s is VideoOnlyStreamInfo)
  //       .cast<VideoOnlyStreamInfo>()
  //       .toList()
  //     ..sort((a, b) =>
  //         b.videoResolution.height.compareTo(a.videoResolution.height));
  //   var bestVideo = videoStreams.first;
  //   var audioStreams = manifest.streams
  //       .where((s) => s is AudioOnlyStreamInfo)
  //       .cast<AudioOnlyStreamInfo>()
  //       .toList()
  //     ..sort((a, b) => b.bitrate.compareTo(a.bitrate));
  //   var bestAudio = audioStreams.first;
  //   String videoUrl = bestVideo.url.toString();
  //   String audioUrl = bestAudio.url.toString();
  //   stopwatch.stop();
  //   print('getData executed in ${stopwatch.elapsedMilliseconds} ms');
  //   return MyData(audioUrl: audioUrl, videoUrl: videoUrl);
  // }
}

class MyData {
  final String audioUrl;
  final String videoUrl;
  MyData({required this.audioUrl, required this.videoUrl});
}

// Future<File?> getVideo(String videoId) async {
//   try {
//     StreamManifest manifest =
//         await _youtubeExplode.videos.streams.getManifest(videoId);
//     StreamInfo streamInfo = manifest.streams.firstWhere(
//       (e) => e.qualityLabel == '720p' || e.qualityLabel == '360p',
//     );
//     Stream<List<int>> stream = _youtubeExplode.videos.streams.get(streamInfo);

//     final tempDir = await getTemporaryDirectory();
//     final filePath = '${tempDir.path}/$videoId.mp4';
//     final file = File(filePath);

//     if (!await file.exists()) {
//       var fileStream = file.openWrite();
//       await stream.pipe(fileStream);
//       await fileStream.flush();
//       await fileStream.close();
//     }

//     return file;
//   } catch (e) {
//     debugPrint(e.toString());
//     return null;
//   }
// }

Future<List<VideoWrapper>?> fetchRecommendedVideos(
  Map<String, dynamic> args,
) async {
  try {
    VideoWrapper wrapper = VideoWrapper.fromJson(args);
    Video video = wrapper.video;
    final youtube = YoutubeExplode();

    RelatedVideosList? relatedVideos = await youtube.videos.getRelatedVideos(
      video,
    );

    if (relatedVideos == null) return null;

    List<VideoWrapper> summaries =
        relatedVideos.map((v) => VideoWrapper(video: v)).toList();

    youtube.close();
    return summaries;
  } catch (_) {
    return null;
  }
}

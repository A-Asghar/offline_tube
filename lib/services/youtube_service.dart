// lib/services/youtube_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  Future<String?> downloadAudioToTemp(String videoId) async {
    return _pool.withResource(() async {
      try {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/temp_audio_$videoId';
        final file = File(filePath);

        if (file.existsSync()) {
          return filePath;
        }

        final manifest = await _youtubeExplode.videos.streamsClient
            .getManifest(VideoId(videoId));
        final audioStreamInfo = manifest.audioOnly.sortByBitrate().firstOrNull;

        if (audioStreamInfo == null) {
          return null;
        }

        final stream =
            _youtubeExplode.videos.streamsClient.get(audioStreamInfo);
        final fileStream = file.openWrite();
        await stream.pipe(fileStream);
        await fileStream.flush();
        await fileStream.close();

        return filePath;
      } catch (e) {
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
    Map<String, dynamic> args) async {
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

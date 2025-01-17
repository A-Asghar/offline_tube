import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// In a real project, you'd run:
//    flutter pub run build_runner build
// to generate the part file (.g.dart) for a more
// direct mapping. But here's a manual approach.

@HiveType(typeId: 0)
class VideoWrapper {
  @HiveField(0)
  final bool isDownloaded;

  Video get video => _video!;
  Video? _video;

  VideoWrapper({
    required Video video,
    this.isDownloaded = false,
  }) : _video = video;

  Map<String, dynamic> toJson() {
    return {
      'video': _videoToJson(video),
      'isDownloaded': isDownloaded,
    };
  }

  factory VideoWrapper.fromJson(Map<String, dynamic> json) {
    return VideoWrapper(
      video: _videoFromJson(json['video'] as Map<String, dynamic>),
      isDownloaded: json['isDownloaded'] as bool? ?? false,
    );
  }

  /// Convert the youtube_explode_dart Video to JSON
  static Map<String, dynamic> _videoToJson(Video video) {
    return {
      'id': video.id.value,
      'title': video.title,
      'author': video.author,
      'channelId': video.channelId.value,
      'uploadDate': video.uploadDate?.toIso8601String(),
      'uploadDateRaw': video.uploadDateRaw,
      'publishDate': video.publishDate?.toIso8601String(),
      'description': video.description,
      'duration': video.duration?.inSeconds,
      'thumbnails': {
        'medium': video.thumbnails.mediumResUrl,
        'high': video.thumbnails.highResUrl,
        'max': video.thumbnails.maxResUrl,
      },
      'keywords': video.keywords.toList(),
      'engagement': {
        'viewCount': video.engagement.viewCount,
        'likeCount': video.engagement.likeCount,
        'dislikeCount': video.engagement.dislikeCount,
      },
      'isLive': video.isLive,
    };
  }

  /// Recreate the youtube_explode_dart Video from JSON
  static Video _videoFromJson(Map<String, dynamic> json) {
    return Video(
      VideoId(json['id'] as String),
      json['title'] as String,
      json['author'] as String,
      ChannelId(json['channelId'] as String),
      json['uploadDate'] == null
          ? null
          : DateTime.parse(json['uploadDate'] as String),
      json['uploadDateRaw'] as String?,
      json['publishDate'] == null
          ? null
          : DateTime.parse(json['publishDate'] as String),
      json['description'] as String,
      json['duration'] == null
          ? null
          : Duration(seconds: json['duration'] as int),
      // Make sure the ID matches your "id" field, not "videoId".
      ThumbnailSet(json['id'] as String),
      (json['keywords'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      Engagement(
        json['engagement']?['viewCount'] as int? ?? 0,
        json['engagement']?['likeCount'] as int?,
        json['engagement']?['dislikeCount'] as int?,
      ),
      json['isLive'] as bool? ?? false,
    );
  }
}

/// The custom TypeAdapter that stores VideoWrapper as JSON.
class VideoWrapperAdapter extends TypeAdapter<VideoWrapper> {
  @override
  final int typeId = 0;

  @override
  VideoWrapper read(BinaryReader reader) {
    // 1. Read a JSON string
    final jsonString = reader.readString();
    // 2. Decode to a Map
    final map = json.decode(jsonString) as Map<String, dynamic>;
    // 3. Convert to VideoWrapper
    return VideoWrapper.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, VideoWrapper obj) {
    // 1. Convert VideoWrapper to a JSON Map
    final map = obj.toJson();
    // 2. Encode Map as a JSON string
    final jsonString = json.encode(map);
    // 3. Write string
    writer.writeString(jsonString);
  }
}

extension DownloadedVideo on Video {
  VideoWrapper get downloaded => VideoWrapper(
        video: this,
        isDownloaded: true,
      );

  VideoWrapper get unDownloaded => VideoWrapper(video: this);
}

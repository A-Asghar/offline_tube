import 'package:hive/hive.dart';
import 'package:offline_tube/util/video_extensions.dart';

class VideoService {
  VideoService._singleton();
  static final VideoService _instance = VideoService._singleton();
  static VideoService get instance => _instance;

  List<VideoWrapper> recommendedVideos = [];
  Set<VideoWrapper> downloadedVideos = {};
  List<VideoWrapper> visitedVideos = [];

  static const String boxName = 'videos';

  Future<void> addToLocal({
    required VideoWrapper item,
  }) async {
    final box = await Hive.openBox<VideoWrapper>(boxName);

    final videoId = item.video.id.value;
    await box.put(videoId, item);
  }

  Future<List<VideoWrapper>> readFromLocal() async {
    final box = await Hive.openBox<VideoWrapper>(boxName);

    return box.values.toList();
  }

  Future<void> removeFromLocal(VideoWrapper item) async {
    final box = await Hive.openBox<VideoWrapper>(boxName);

    final videoId = item.video.id.value;
    await box.delete(videoId);
  }
}

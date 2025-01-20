import 'package:offline_tube/util/util.dart';
import 'package:stacked/stacked.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Playlist {
  final String name;
  final String id;
  final List<Video> videos;

  Playlist({
    this.name = '',
    this.id = '-1',
    this.videos = const [],
  });
}

class PlaylistService with ListenableServiceMixin {
  PlaylistService._singleton();
  static final PlaylistService _instance = PlaylistService._singleton();
  static PlaylistService get instance => _instance;

  final List<Playlist> _playlists = [];
  List<Playlist> get playlists => _playlists;

  void addPlaylist(String name) {
    String id = getRandomString(6);
    _playlists.add(Playlist(name: name, id: id));
    notifyListeners();
  }

  void removePlaylist(String id) {
    _playlists.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addVideoToPlaylist(Playlist playlist, Video video) {
    playlist.videos.add(video);
    notifyListeners();
  }

  void removeVideoFromPlaylist(Playlist playlist, Video video) {
    playlist.videos.remove(video);
    notifyListeners();
  }
}

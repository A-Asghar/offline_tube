import 'package:flutter/material.dart';
import 'package:offline_tube/playlist/playlist_viewmodel.dart';
import 'package:stacked/stacked.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => PlaylistViewmodel(),
      builder: (_, model, __) {
        return const Scaffold(
          body: Center(
            child: Text('Playlist View'),
          ),
        );
      },
    );
  }
}

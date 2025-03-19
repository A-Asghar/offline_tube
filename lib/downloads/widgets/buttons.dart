import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:offline_tube/main.dart';
import 'package:offline_tube/services/current_playing_service.dart';
import 'package:offline_tube/widgets/loading_widget.dart';

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({super.key, required this.onTap});
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/svg/back.svg',
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
        height: 22,
      ),
    );
  }
}

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key, required this.pause, required this.play});
  final Function() pause;
  final Function() play;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: StreamBuilder<ButtonState>(
        stream: currentPlayingService.playPauseButtonState.values,
        builder: (_, buttonState) {
          if (buttonState.data == ButtonState.loading) {
            return const Loading();
          }
          if (buttonState.data == ButtonState.playing) {
            return GestureDetector(
              onTap: pause,
              child: SvgPicture.asset(
                'assets/svg/pause (1).svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            );
          }
          if (buttonState.data == ButtonState.paused) {
            return GestureDetector(
              onTap: play,
              child: SvgPicture.asset(
                'assets/svg/play.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            );
          }
          return const Loading();
        },
      ),
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({super.key, required this.onTap});
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/svg/next.svg',
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
        height: 22,
      ),
    );
  }
}

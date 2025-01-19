import 'package:flutter/material.dart';
import 'package:offline_tube/widgets/shimmer_video_item.dart';

class ShimmerVideoList extends StatelessWidget {
  const ShimmerVideoList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (int i = 0; i < 3; i++) const ShimmerVideoItem(),
      ],
    );
  }
}

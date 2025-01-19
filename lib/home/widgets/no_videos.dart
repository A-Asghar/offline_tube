import 'package:flutter/material.dart';

class NoVideos extends StatelessWidget {
  const NoVideos({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Nothing to show',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

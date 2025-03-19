import 'package:flutter/material.dart';
import 'package:offline_tube/util/util.dart';
import 'package:shimmer/shimmer.dart';

class _DownloadItemShimmer extends StatelessWidget {
  const _DownloadItemShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
              width: 120,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Expanded(
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 15,
                    width: width * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DownloadShimmerList extends StatelessWidget {
  const DownloadShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (int i = 0; i < 8; i++) const _DownloadItemShimmer(),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerVideoItem extends StatelessWidget {
  const ShimmerVideoItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

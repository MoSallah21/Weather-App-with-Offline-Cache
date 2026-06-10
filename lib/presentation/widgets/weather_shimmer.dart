import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WeatherShimmer extends StatelessWidget {
  const WeatherShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest;
    final highlightColor = colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: double.infinity, height: 200),
            const SizedBox(height: 16),
            _ShimmerBox(width: 200, height: 24),
            const SizedBox(height: 12),
            _ShimmerBox(width: 140, height: 20),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _ShimmerBox(width: double.infinity, height: 80)),
                const SizedBox(width: 12),
                Expanded(child: _ShimmerBox(width: double.infinity, height: 80)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _ShimmerBox(width: double.infinity, height: 80)),
                const SizedBox(width: 12),
                Expanded(child: _ShimmerBox(width: double.infinity, height: 80)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
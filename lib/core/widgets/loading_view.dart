import 'package:flutter/material.dart';
import '../../app/theme/app_dimensions.dart';

class AppLoadingView extends StatelessWidget {
  final double height;
  const AppLoadingView({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class ShimmerLoadingList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  const ShimmerLoadingList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
          child: Container(
            height: itemHeight,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
          ),
        ),
      ),
    );
  }
}

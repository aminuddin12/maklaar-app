import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LocationShimmer extends StatelessWidget {
  const LocationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 15,
      separatorBuilder: (context, index) {
        return Container();
      },
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
          highlightColor: Theme.of(context).colorScheme.shimmerHighlightColor,
          child: Container(
            padding: EdgeInsets.all(5),
            width: double.maxFinite,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: context.color.textLightColor.withValues(alpha: 0.18),
              ),
            ),
          ),
        );
      },
    );
  }
}

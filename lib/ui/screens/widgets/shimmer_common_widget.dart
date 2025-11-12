import 'package:com.maklaar.app/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:flutter/material.dart';

class ShimmerCommonWidget extends StatelessWidget {
  const ShimmerCommonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomShimmer(
            height: 90,
            width: 90,
            borderRadius: 15,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  CustomShimmer(
                    height: 10,
                    width: c.maxWidth - 50,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const CustomShimmer(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomShimmer(
                    height: 10,
                    width: c.maxWidth / 1.2,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: CustomShimmer(
                      width: c.maxWidth / 4,
                    ),
                  ),
                ],
              );
            }),
          )
        ],
      ),
    );
  }
}

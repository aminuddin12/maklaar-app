import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class SkipButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const SkipButtonWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: FittedBox(
        fit: BoxFit.none,
        child: MaterialButton(
          onPressed: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          color: context.color.forthColor.withValues(alpha: 0.102),
          elevation: 0,
          height: 28,
          minWidth: 64,
          child: CustomText(
            "skip".translate(context),
            color: context.color.forthColor,
          ),
        ),
      ),
    );
  }
}

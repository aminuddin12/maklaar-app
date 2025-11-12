import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class LocationItem extends StatelessWidget {
  const LocationItem({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leadingIcon,
    this.showTrailingIcon = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? leadingIcon;
  final bool showTrailingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        onTap: onTap,
        dense: true,
        title: CustomText(
          title,
          textAlign: TextAlign.start,
          color: context.color.textDefaultColor,
          fontSize: context.font.normal,
          fontWeight: FontWeight.w600,
        ),
        subtitle: subtitle != null
            ? CustomText(
                subtitle!,
                textAlign: TextAlign.start,
                color: context.color.textDefaultColor,
                fontSize: context.font.small,
              )
            : null,
        leading: leadingIcon,
        trailing: showTrailingIcon
            ? SizedBox.square(
                dimension: 32,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.color.textLightColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: context.color.textDefaultColor,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

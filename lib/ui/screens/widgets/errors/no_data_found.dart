import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/app_icon.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class NoDataFound extends StatelessWidget {
  final double? height;
  final String? mainMessage;
  final String? subMessage;
  final VoidCallback? onTap;
  final double? mainMsgStyle;
  final double? subMsgStyle;
  final bool? showImage;
  final bool? showBtn;
  final String? btnName;

  const NoDataFound(
      {super.key,
      this.onTap,
      this.height,
      this.mainMessage,
      this.subMessage,
      this.mainMsgStyle,
      this.subMsgStyle,
      this.showImage,
      this.showBtn = false,
      this.btnName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? null,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showImage != false)
                UiUtils.getSvg(AppIcons.no_data_found, height: height ?? null),
              const SizedBox(
                height: 20,
              ),
              CustomText(
                mainMessage ?? "nodatafound".translate(context),
                fontSize: mainMsgStyle ?? context.font.extraLarge,
                color: context.color.territoryColor,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(
                height: 14,
              ),
              CustomText(
                subMessage ?? "sorryLookingFor".translate(context),
                fontSize: subMsgStyle ?? context.font.larger,
                textAlign: TextAlign.center,
              ),
              if (showBtn!)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: UiUtils.buildButton(context,
                      onPressed: onTap!,
                      buttonTitle: btnName ?? "",
                      height: 40,
                      width: MediaQuery.of(context).size.width / 1.5,
                      radius: 8),
                )
            ],
          ),
        ),
      ),
    );
  }
}

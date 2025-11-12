import 'package:com.maklaar.app/ui/screens/home/home_screen.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/app_icon.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class SomethingWentWrong extends StatelessWidget {
  const SomethingWentWrong({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: UiUtils.getSvg(AppIcons.somethingWentWrong));
  }
}

class NoChatFound extends StatelessWidget {
  const NoChatFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UiUtils.getSvg(AppIcons.no_chat_found),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: sidePadding),
            child: CustomText(
              "${"noChatFoundStartNewConversation".translate(context)}",
              fontSize: context.font.larger,
              textAlign: TextAlign.center,
              color: context.color.territoryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

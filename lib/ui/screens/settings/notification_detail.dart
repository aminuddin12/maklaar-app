import 'dart:developer';

import 'package:com.maklaar.app/app/routes.dart';
import 'package:com.maklaar.app/ui/screens/home/widgets/item_horizontal_card.dart';
import 'package:com.maklaar.app/ui/screens/settings/notifications.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/designs.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class NotificationDetail extends StatefulWidget {
  const NotificationDetail({super.key});

  @override
  State<NotificationDetail> createState() => _NotificationDetailState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (_) => const NotificationDetail());
  }
}

class _NotificationDetailState extends State<NotificationDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: "notifications".translate(context),
        showBackButton: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 13.0, vertical: 13.0),
        children: <Widget>[
          if (selectedNotification.image!.isNotEmpty)
            setNetworkImg(selectedNotification.image!, boxFit: BoxFit.cover),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: detailWidget(),
          ),
        ],
      ),
    );
  }

  Column detailWidget() {
    log('${selectedNotification.item}');
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          selectedNotification.title!,
          style: Theme.of(context).textTheme.titleMedium!.merge(
            const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          selectedNotification.message!,
          style: Theme.of(context).textTheme.bodySmall!,
        ),
        if (selectedNotification.item != null)
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.adDetailsScreen,
                arguments: {'slug': selectedNotification.item!.slug},
              );
            },
            child: ItemHorizontalCard(
              item: selectedNotification.item!,
              showLikeButton: false,
            ),
          ),
      ],
    );
  }
}

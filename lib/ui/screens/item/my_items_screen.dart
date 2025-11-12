import 'package:com.maklaar.app/ui/screens/item/my_item_tab_screen.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';

String selectItemStatus = "";

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => MyItemState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (_) => const ItemsScreen());
  }
}

class MyItemState extends State<ItemsScreen> with TickerProviderStateMixin {
  int offset = 0, total = 0;
  int selectTab = 0;
  final PageController _pageController = PageController();
  final List<Map<String, String>> sections = [
    {"title": "allAds", "status": ""},
    {"title": "featured", "status": "featured"},
    {"title": "live", "status": Constant.statusApproved},
    {"title": "expired", "status": Constant.statusExpired},
    {"title": "deactivate", "status": Constant.statusInactive},
    {"title": "underReview", "status": Constant.statusReview},
    {"title": "soldOut", "status": Constant.statusSoldOut},
    {"title": "permanentRejected", "status": Constant.statusPermanentRejected},
    {"title": "softRejected", "status": Constant.statusSoftRejected},
    {"title": "resubmitted", "status": Constant.statusResubmitted},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.secondaryColor,
      ),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(context, title: "myAds".translate(context)),
        body: Column(
          spacing: 10,
          children: [
            SizedBox(
              width: context.screenWidth,
              height: 50,
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: Constant.appContentPadding.copyWith(top: 10),
                itemBuilder: (context, index) {
                  Map<String, String> section = sections[index];
                  return customTab(
                    context,
                    isSelected: (selectTab == index),
                    onTap: () {
                      selectTab = index;
                      selectItemStatus = section["status"]!;
                      //itemScreenCurrentPage = index;
                      setState(() {});
                      _pageController.jumpToPage(index);
                    },
                    name: section['title']!.translate(context),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 8);
                },
                itemCount: sections.length,
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: RemoveGlow(),
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) {
                    //itemScreenCurrentPage = value;
                    selectTab = value;
                    setState(() {});
                  },
                  controller: _pageController,
                  children: List.generate(sections.length, (index) {
                    Map section = sections[index];

                    ///Here we pass both but logic will be in the cubit
                    return MyItemTab(getItemsWithStatus: section['status']);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customTab(
    BuildContext context, {
    required bool isSelected,
    required String name,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 110),
        height: 40,
        decoration: BoxDecoration(
          color: (isSelected
              ? (context.color.territoryColor)
              : Colors.transparent),
          border: Border.all(
            color: isSelected
                ? context.color.territoryColor
                : context.color.textLightColor,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomText(
              name,
              color: isSelected
                  ? context.color.buttonColor
                  : context.color.textColorDark,
              fontSize: context.font.large,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

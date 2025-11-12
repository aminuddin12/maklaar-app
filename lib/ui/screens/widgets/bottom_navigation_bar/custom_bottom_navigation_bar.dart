import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/app_icon.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';

/// Custom Navigation bar that gives space to the centerDocked FAB button
class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({required this.controller, super.key});

  final BottomNavigationController controller;

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final items = [
    _BottomNavigationItem(
      icon: AppIcons.homeNav,
      activeIcon: AppIcons.homeNavActive,
      label: 'homeTab',
    ),
    _BottomNavigationItem(
      icon: AppIcons.chatNav,
      activeIcon: AppIcons.chatNavActive,
      label: 'chat',
    ),
    // This null value is to be used for giving space at the center of bottom nav to avoid placing items behind the FAB
    null,
    _BottomNavigationItem(
      icon: AppIcons.myAdsNav,
      activeIcon: AppIcons.myAdsNavActive,
      label: 'myAdsTab',
    ),
    _BottomNavigationItem(
      icon: AppIcons.profileNav,
      activeIcon: AppIcons.profileNavActive,
      label: 'profileTab',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // We need SafeArea here because we are not using conventional BottomNavigationBar
    // widget, hence it will not automatically add padding on Android 15 edge-to-edge mode
    return SafeArea(
      child: SizedBox(
        height: kBottomNavigationBarHeight,
        child: ColoredBox(
          color: context.color.secondaryColor,
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, child) {
              final selectedIndex = widget.controller.index;
              // Track the index of each child.
              // We do it manually as we are using SizedBox and we don't want
              // it to occupy any index, hence that is why we can't use conventional
              // NavigationBar or BottomNavigationBar because they will assign index
              // to SizedBox also
              int itemIndex = 0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: items.map((item) {
                  if (item == null) return SizedBox(width: 25);
                  final index = itemIndex++;
                  return GestureDetector(
                    onTap: () {
                      if (item.label case == 'chat' || 'myAdsTab') {
                        UiUtils.checkUser(
                          onNotGuest: () {
                            widget.controller.changeIndex(index);
                          },
                          context: context,
                        );
                      } else {
                        widget.controller.changeIndex(index);
                      }
                    },
                    child: _BottomNavigationItemWidget(
                      item: item,
                      selected: selectedIndex == index,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A custom controller for [CustomBottomNavigationBar].
///
/// While it's technically possible to use the [PageController] from the main screen,
/// this controller encapsulates the state and interactions specific to the bottom navigation bar.
///
/// This keeps responsibilities clear: the bottom navigation bar manages its own state
/// and communicates intent, rather than directly controlling screen content.
///
/// NOTE: This controller is only valid because the `PageView` in `MainActivity`
/// uses `physics: NeverScrollableScrollPhysics()`.
///
/// As a result, the bottom navigation is the single source of truth for tab state,
/// and it drives the `PageView` directly.
///
/// If scroll physics were enabled (i.e., allowing swipe gestures),
/// this controller would become invalid, and synchronization would need to happen
/// via a shared [PageController] instead.
///
class BottomNavigationController extends ChangeNotifier {
  int index = 0;

  void changeIndex(int index) {
    this.index = index;
    notifyListeners();
  }
}

class _BottomNavigationItemWidget extends StatelessWidget {
  _BottomNavigationItemWidget({required this.item, required this.selected});

  final _BottomNavigationItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        UiUtils.getSvg(
          selected ? item.activeIcon : item.icon,
          color: selected
              ? null
              : context.color.textLightColor.withValues(alpha: .5),
        ),
        CustomText(
          item.label.translate(context),
          color: selected ? null : context.color.textLightColor,
        ),
      ],
    );
  }
}

class _BottomNavigationItem {
  _BottomNavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String icon;
  final String activeIcon;
  final String label;
}

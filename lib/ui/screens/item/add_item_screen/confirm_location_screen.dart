import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:com.maklaar.app/app/routes.dart';
import 'package:com.maklaar.app/data/cubits/item/manage_item_cubit.dart';
import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/ui/screens/item/my_item_tab_screen.dart';
import 'package:com.maklaar.app/ui/screens/widgets/location_map/location_map_controller.dart';
import 'package:com.maklaar.app/ui/screens/widgets/location_map/location_map_widget.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/app_icon.dart';
import 'package:com.maklaar.app/utils/cloud_state/cloud_state.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/helper_utils.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:com.maklaar.app/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

class ConfirmLocationScreen extends StatefulWidget {
  final bool? isEdit;
  final File? mainImage;
  final List<File>? otherImage;

  const ConfirmLocationScreen({
    Key? key,
    required this.isEdit,
    required this.mainImage,
    required this.otherImage,
  }) : super(key: key);

  static MaterialPageRoute route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;

    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (context) => ManageItemCubit(),
          child: ConfirmLocationScreen(
            isEdit: arguments?['isEdit'] ?? false,
            mainImage: arguments?['mainImage'],
            otherImage: arguments?['otherImage'],
          ),
        );
      },
    );
  }

  @override
  _ConfirmLocationScreenState createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends CloudState<ConfirmLocationScreen> {
  LeafLocation _location = LeafLocation();

  final LocationMapController _controller = LocationMapController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _location = _controller.data.location;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        Future.delayed(Duration(milliseconds: 500), () {
          return;
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: UiUtils.buildAppBar(
          context,
          onBackPress: () {
            Future.delayed(Duration(milliseconds: 500), () {
              Navigator.pop(context);
            });
          },
          showBackButton: true,
          title: "confirmLocation".translate(context),
        ),
        bottomNavigationBar: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            return BlocConsumer<ManageItemCubit, ManageItemState>(
              listener: (context, state) {
                if (state is ManageItemInProgress) {
                  LoadingWidgets.showLoader(context);
                } else if (state is ManageItemSuccess) {
                  LoadingWidgets.hideLoader(context);
                  myAdsCubitReference[getCloudData("edit_from")]?.editAds(
                    state.model,
                  );

                  Navigator.pushNamed(
                    context,
                    Routes.successItemScreen,
                    arguments: {'model': state.model, 'isEdit': widget.isEdit},
                  );
                } else if (state is ManageItemFail) {
                  HelperUtils.showSnackBarMessage(
                    context,
                    'defaultErrorMsg'.translate(context),
                  );
                  LoadingWidgets.hideLoader(context);
                }
              },
              builder: (context, state) {
                return UiUtils.buildButton(
                  context,
                  outerPadding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: 18.0,
                    right: 18,
                  ),
                  onTapDisabledButton: () {
                    HelperUtils.showSnackBarMessage(
                      context,
                      'Invalid Location',
                    );
                  },
                  onPressed: () async {
                    if (context.read<ManageItemCubit>().state
                        is ManageItemInProgress) {
                      return; // Prevent multiple API calls
                    }

                    try {
                      Map<String, dynamic> cloudData =
                          getCloudData("with_more_details") ?? {};

                      cloudData['address'] = _location.canonicalPath;
                      if (_location.latitude != null)
                        cloudData['latitude'] = _location.latitude;
                      if (_location.longitude != null)
                        cloudData['longitude'] = _location.longitude;
                      cloudData['country'] = _location.country?.canonical;
                      cloudData['city'] = _location.city?.canonical;
                      cloudData['state'] = _location.state?.canonical;
                      cloudData['area'] = _location.area?.canonical;
                      if (widget.isEdit ?? false) {
                        context.read<ManageItemCubit>().manage(
                          ManageItemType.edit,
                          cloudData,
                          widget.mainImage,
                          widget.otherImage!,
                        );
                        return;
                      } else {
                        context.read<ManageItemCubit>().manage(
                          ManageItemType.add,
                          cloudData,
                          widget.mainImage!,
                          widget.otherImage!,
                        );
                        return;
                      }
                    } catch (e, st) {
                      log('$e', name: 'Add Item');
                      log('$st', name: 'Add Item');
                    }
                  },
                  height: 48,
                  fontSize: context.font.large,
                  autoWidth: false,
                  radius: 8,
                  disabledColor: const Color.fromARGB(255, 104, 102, 106),
                  disabled: !_location.isValid,
                  width: double.maxFinite,
                  buttonTitle: "postNow".translate(context),
                );
              },
            );
          },
        ),
        body: bodyData(),
      ),
    );
  }

  Widget bodyData() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: LocationMapWidget(
                controller: _controller,
                showCircleArea: false,
              ),
            ),
            if (_controller.isReady)
              ColoredBox(
                color: context.color.backgroundColor,
                child: Padding(
                  padding: Constant.appContentPadding.copyWith(
                    top: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      SvgPicture.asset(
                        AppIcons.location,
                        height: 20,
                        width: 20,
                        colorFilter: ColorFilter.mode(
                          context.color.territoryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_location.primaryText != null)
                              CustomText(
                                _location.primaryText!,
                                color: context.color.textColorDark,
                                fontSize: context.font.normal,
                                fontWeight: FontWeight.w600,
                              ),
                            if (_location.secondaryText != null)
                              CustomText(
                                _location.secondaryText!,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                fontSize: context.font.small,
                                maxLines: 2,
                              ),
                          ],
                        ),
                      ),
                      if (Constant.mapProvider == 'free_api')
                        FilledButton(
                          onPressed: () async {
                            final location =
                                await Navigator.of(context).pushNamed(
                                      Routes.locationScreen,
                                      arguments: {
                                        'requires_exact_location': true,
                                      },
                                    )
                                    as LeafLocation?;
                            if (location == null) return;
                            _controller.updateLocation(location);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: context.color.territoryColor
                                .withValues(alpha: .1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            minimumSize: Size(70, 20),
                            fixedSize: Size(70, 25),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: CustomText(
                            'change'.translate(context),
                            color: context.color.territoryColor,
                            fontSize: context.font.small,
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              shimmerEffect(),
          ],
        );
      },
    );
  }

  Widget shimmerEffect() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          Padding(
            padding: Constant.appContentPadding,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
              highlightColor: Theme.of(
                context,
              ).colorScheme.shimmerHighlightColor,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                ),
                height: 20,
                width: MediaQuery.of(context).size.width * .5,
              ),
            ),
          ),
          Padding(
            padding: Constant.appContentPadding,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
              highlightColor: Theme.of(
                context,
              ).colorScheme.shimmerHighlightColor,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                ),
                height: 20,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

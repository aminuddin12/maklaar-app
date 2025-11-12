import 'package:com.maklaar.app/app/routes.dart';
import 'package:com.maklaar.app/data/cubits/location/leaf_location_cubit.dart';
import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/ui/screens/home/home_screen.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/app_icon.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/helper_utils.dart';
import 'package:com.maklaar.app/utils/hive_utils.dart';
import 'package:com.maklaar.app/utils/location_utility.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:com.maklaar.app/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  LocationPermissionScreenState createState() =>
      LocationPermissionScreenState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (_) => const LocationPermissionScreen());
  }
}

class LocationPermissionScreenState extends State<LocationPermissionScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.backgroundColor,
      ),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: Stack(
          children: [
            // Skip button at the top-right
            Positioned(
              top: MediaQuery.of(context).padding.top,
              right: sidePadding,
              child: FittedBox(
                fit: BoxFit.none,
                child: MaterialButton(
                  onPressed: () {
                    HelperUtils.killPreviousPages(context, Routes.main, {
                      "from": "login",
                    });
                  },
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
            ),

            // Centered content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 25),
                  UiUtils.getSvg(AppIcons.locationAccessIcon),
                  const SizedBox(height: 19),
                  CustomText(
                    "whatsYourLocation".translate(context),
                    fontSize: context.font.extraLarge,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CustomText(
                      'enjoyPersonalizedSellingAndBuyingLocationLbl'.translate(
                        context,
                      ),
                      fontSize: context.font.larger,
                      color: context.color.textDefaultColor.withValues(
                        alpha: 0.65,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 58),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 12,
                    ),
                    child: UiUtils.buildButton(
                      context,
                      showElevation: false,
                      buttonColor: context.color.territoryColor,
                      textColor: context.color.secondaryColor,
                      onPressed: () async {
                        try {
                          LoadingWidgets.showLoader(context);
                          final location = await LocationUtility().getLocation(
                            context,
                          );
                          if (location != null) {
                            context.read<LeafLocationCubit>().setLocation(
                              location,
                            );
                            HelperUtils.killPreviousPages(
                              context,
                              Routes.main,
                              {"from": "login"},
                            );
                          }
                        } on Exception catch (_) {
                          HelperUtils.showSnackBarMessage(
                            context,
                            'Unable to fetch the location',
                          );
                        } finally {
                          LoadingWidgets.hideLoader(context);
                        }
                      },
                      radius: 8,
                      height: 46,
                      buttonTitle: "findMyLocation".translate(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 12,
                    ),
                    child: UiUtils.buildButton(
                      context,
                      showElevation: false,
                      buttonColor: context.color.backgroundColor,
                      border: BorderSide(color: context.color.territoryColor),
                      textColor: context.color.territoryColor,
                      onPressed: () async {
                        final location =
                            await Navigator.pushNamed(
                                  context,
                                  Routes.locationScreen,
                                )
                                as LeafLocation?;

                        if (location != null) {
                          HiveUtils.setLocationV2(location: location);
                          context.read<LeafLocationCubit>().setLocation(
                            location,
                          );
                        }

                        HelperUtils.killPreviousPages(context, Routes.main, {
                          "from": "login",
                        });
                      },
                      radius: 8,
                      height: 46,
                      buttonTitle: "otherLocation".translate(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

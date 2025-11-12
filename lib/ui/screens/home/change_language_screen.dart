import 'package:com.maklaar.app/data/cubits/category/fetch_category_cubit.dart';
import 'package:com.maklaar.app/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:com.maklaar.app/data/cubits/chat/get_seller_chat_users_cubit.dart';
import 'package:com.maklaar.app/data/cubits/home/fetch_home_all_items_cubit.dart';
import 'package:com.maklaar.app/data/cubits/home/fetch_home_screen_cubit.dart';
import 'package:com.maklaar.app/data/cubits/location/leaf_location_cubit.dart';
import 'package:com.maklaar.app/data/cubits/slider_cubit.dart';
import 'package:com.maklaar.app/data/cubits/system/fetch_language_cubit.dart';
import 'package:com.maklaar.app/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:com.maklaar.app/data/cubits/system/language_cubit.dart';
import 'package:com.maklaar.app/data/model/system_settings_model.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/hive_utils.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:com.maklaar.app/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguagesListScreen extends StatefulWidget {
  const LanguagesListScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const LanguagesListScreen());
  }

  @override
  State<LanguagesListScreen> createState() => _LanguagesListScreenState();
}

class _LanguagesListScreenState extends State<LanguagesListScreen> {
  final String _currentLanguageCode = Constant.currentLanguageCode;
  bool hasLanguageChanged = false;

  void _onBackPressed() {
    if (hasLanguageChanged &&
        _currentLanguageCode != Constant.currentLanguageCode) {
      final location = context.read<LeafLocationCubit>().state;
      context.read<LeafLocationCubit>().refresh();

      // We don't need to wait for refresh to complete to call the below apis
      // because refresh is only for translation updates and the below apis
      // expects english or default values, hence we can rely on previous state
      // without any issue.
      //
      // We only call these apis here if the location is null in which case, the refresh()
      // function above will be No-Op hence the listener in home_screen will not be triggered.
      // If we remove this check then there are multiple api calls as the home screen
      // is also listening to the change in LeafLocationCubit and calling these apis accordingly
      // hence to avoid multiple calls we wrap it with this condition.
      if (location == null) {
        context.read<SliderCubit>().fetchSlider(context);
        context.read<FetchHomeScreenCubit>().fetch(location: location);
        context.read<FetchHomeAllItemsCubit>().fetch(location: location);
        context.read<FetchCategoryCubit>().fetchCategories();
        if (HiveUtils.isUserAuthenticated()) {
          context.read<GetSellerChatListCubit>().fetch();
          context.read<GetBuyerChatListCubit>().fetch();
        }
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    List setting =
        context.read<FetchSystemSettingsCubit>().getSetting(
              SystemSetting.language,
            )
            as List;

    var language = context.watch<LanguageCubit>().state;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPressed();
      },
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          onBackPress: _onBackPressed,
          title: "chooseLanguage".translate(context),
        ),
        body: BlocListener<FetchLanguageCubit, FetchLanguageState>(
          listener: (context, state) {
            if (state is FetchLanguageInProgress) {
              LoadingWidgets.showLoader(context);
            }
            if (state is FetchLanguageSuccess) {
              LoadingWidgets.hideLoader(context);

              Map<String, dynamic> map = state.toMap();

              print("map language data***$map");

              var data = map['file_name'];
              map['data'] = data;
              map.remove("file_name");

              HiveUtils.storeLanguage(map);
              context.read<LanguageCubit>().changeLanguages(map);
              hasLanguageChanged = true;
            }
            if (state is FetchLanguageFailure) {
              LoadingWidgets.hideLoader(context);
            }
          },
          child: SafeArea(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: setting.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                Color color =
                    (language as LanguageLoader).language['code'] ==
                        setting[index]['code']
                    ? context.color.territoryColor
                    : context.color.textLightColor.withValues(alpha: 0.03);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      onTap: () {
                        context.read<FetchLanguageCubit>().getLanguage(
                          setting[index]['code'],
                        );
                      },
                      leading: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(21),
                          child: UiUtils.imageType(
                            setting[index]['image'],
                            fit: BoxFit.contain,
                            width: 42,
                            height: 42,
                          ),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            setting[index]['name'],
                            color:
                                (language).language['code'] ==
                                    setting[index]['code']
                                ? context.color.buttonColor
                                : context.color.textColorDark,
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText(
                            setting[index]['name_in_english'],
                            color:
                                (language).language['code'] ==
                                    setting[index]['code']
                                ? context.color.buttonColor.withValues(
                                    alpha: 0.7,
                                  )
                                : context.color.textColorDark,
                            fontSize: context.font.small,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

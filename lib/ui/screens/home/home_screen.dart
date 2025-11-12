// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:com.maklaar.app/app/routes.dart';
import 'package:com.maklaar.app/data/cubits/category/fetch_category_cubit.dart';
import 'package:com.maklaar.app/data/cubits/chat/blocked_users_list_cubit.dart';
import 'package:com.maklaar.app/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:com.maklaar.app/data/cubits/favorite/favorite_cubit.dart';
import 'package:com.maklaar.app/data/cubits/home/fetch_home_all_items_cubit.dart';
import 'package:com.maklaar.app/data/cubits/home/fetch_home_screen_cubit.dart';
import 'package:com.maklaar.app/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:com.maklaar.app/data/cubits/location/leaf_location_cubit.dart';
import 'package:com.maklaar.app/data/cubits/slider_cubit.dart';
import 'package:com.maklaar.app/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:com.maklaar.app/data/model/home/home_screen_section_model.dart';
import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/data/model/system_settings_model.dart';
import 'package:com.maklaar.app/ui/screens/ad_banner_screen.dart';
import 'package:com.maklaar.app/ui/screens/home/slider_widget.dart';
import 'package:com.maklaar.app/ui/screens/home/widgets/category_widget_home.dart';
import 'package:com.maklaar.app/ui/screens/home/widgets/grid_list_adapter.dart';
import 'package:com.maklaar.app/ui/screens/home/widgets/home_search.dart';
import 'package:com.maklaar.app/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:com.maklaar.app/ui/screens/home/widgets/location_widget.dart';
import 'package:com.maklaar.app/ui/screens/native_ads_screen.dart';
import 'package:com.maklaar.app/ui/screens/widgets/errors/no_data_found.dart';
import 'package:com.maklaar.app/ui/screens/widgets/errors/no_internet.dart';
import 'package:com.maklaar.app/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:com.maklaar.app/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/api.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/designs.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/hive_utils.dart';
import 'package:com.maklaar.app/utils/notification/awsome_notification.dart';
import 'package:com.maklaar.app/utils/notification/notification_service.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';

const double sidePadding = 10;

class HomeScreen extends StatefulWidget {
  final String? from;

  const HomeScreen({super.key, this.from});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();


  /// =================================================================
  ///                       BAGIAN YANG DIPERBAIKI
  /// =================================================================
  @override
  void initState() {
    super.initState();
    initializeSettings();
    notificationPermissionChecker();
    LocalAwesomeNotification().init(context);
    ///////////////////////////////////////
    NotificationService.init(context);


    // 1. Panggil data yang TIDAK bergantung pada lokasi terlebih dahulu.
    context.read<SliderCubit>().fetchSlider(context);
    context.read<FetchCategoryCubit>().fetchCategories();

    // 2. Periksa apakah lokasi sudah ada dari sesi sebelumnya.
    final initialLocation = context.read<LeafLocationCubit>().state;

    // 3. JIKA lokasi sudah ada, langsung muat data yang bergantung padanya.
    if (initialLocation != null) {
      loadLocationDependentData(initialLocation);
    }
    //    JIKA lokasi belum ada (aplikasi baru dibuka), kita biarkan
    //    BlocListener di bawah yang akan memicunya nanti.

    // Panggil data khusus pengguna jika sudah login.
    if (HiveUtils.isUserAuthenticated()) {
      context.read<FavoriteCubit>().getFavorite();
      //fetchApiKeys();
      context.read<GetBuyerChatListCubit>().fetch();
      context.read<FetchJobApplicationCubit>().fetchApplications(
        itemId: 0,
        isMyJobApplications: true,
      );
      context.read<BlockedUsersListCubit>().blockedUsersList();
    }

    _scrollController.addListener(() {
      if (_scrollController.isEndReached()) {
        if (context.read<FetchHomeAllItemsCubit>().hasMoreData()) {
          context.read<FetchHomeAllItemsCubit>().fetchMore(
            location: HiveUtils.getLocationV2(),
          );
        }
      }
    });
  }


  /// Fungsi ini DIPINDAHKAN dari initState untuk menghindari duplikasi
  /// dan memastikan alur yang benar.
  void loadLocationDependentData(LeafLocation? location) {
    context.read<FetchHomeScreenCubit>().fetch(location: location);
    context.read<FetchHomeAllItemsCubit>().fetch(location: location);
  }
  /// Fungsi ini DIPINDAHKAN dari onRefresh untuk membuat alur yang lebih jelas.
  /// Sekarang onRefresh hanya memanggil satu fungsi ini.
  void refreshAllData() {
    // Panggil data yang tidak bergantung lokasi
    context.read<SliderCubit>().fetchSlider(context, forceRefresh: true);
    context.read<FetchCategoryCubit>().fetchCategories(forceRefresh: true);

    // Panggil data yang bergantung lokasi dengan lokasi saat ini
    loadLocationDependentData(context.read<LeafLocationCubit>().state);
  }

  // Fungsi loadInitialInfo yang lama sudah tidak diperlukan lagi.
  // void loadInitialInfo() { ... }

  /// =================================================================
  ///                     AKHIR BAGIAN YANG DIPERBAIKI
  /// =================================================================


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void initializeSettings() {
    final settingsCubit = context.read<FetchSystemSettingsCubit>();
    if (!bool.fromEnvironment(
      Constant.forceDisableDemoMode,
      defaultValue: false,
    )) {
      Constant.isDemoModeOn =
          settingsCubit.getSetting(SystemSetting.demoMode) ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<LeafLocationCubit, LeafLocation?>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, newLocation) {
        // PERUBAHAN: Saat lokasi berubah, panggil fungsi terpusat ini.
        loadLocationDependentData(newLocation);
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leadingWidth: double.maxFinite,
            leading: Padding(
              padding: EdgeInsetsDirectional.only(
                start: sidePadding,
                end: sidePadding,
              ),
              child: LocationWidget(),
            ),
            backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          ),
          backgroundColor: context.color.primaryColor,
          body: RefreshIndicator(
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            color: context.color.territoryColor,
            onRefresh: () async {
              // PERUBAHAN: onRefresh sekarang lebih bersih.
              refreshAllData();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              controller: _scrollController,
              padding: EdgeInsetsDirectional.only(bottom: 30),
              children: [
                BlocBuilder<FetchHomeScreenCubit, FetchHomeScreenState>(
                  builder: (context, state) {
                    if (state is FetchHomeScreenInProgress || state is FetchHomeScreenInitial) {
                      return shimmerEffect();
                    }
                    if (state is FetchHomeScreenSuccess) {
                      return homeScreenContent(state);
                    }
                    // PERBAIKAN: Tangani state failure
                    if (state is FetchHomeScreenFail) {
                      // Tampilkan widget error yang sesuai
                      return Center(
                        child: NoInternet(onRetry: () {
                          refreshAllData();
                        }),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
                const AllItemsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget homeScreenContent(FetchHomeScreenSuccess state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const HomeSearchField(),
        const SliderWidget(),
        const CategoryWidgetHome(),
        ...List.generate(state.sections.length, (index) {
          HomeScreenSection section = state.sections[index];
          if (state.sections.isNotEmpty) {
            return HomeSectionsAdapter(section: section);
          } else {
            return SizedBox.shrink();
          }
        }),
      ],
    );
  }

  Widget shimmerEffect() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: defaultPadding,
      ),
      child: Column(
        children: [
          CustomShimmer(height: 52, width: double.maxFinite, borderRadius: 10),
          SizedBox(height: 12),
          CustomShimmer(height: 170, width: double.maxFinite, borderRadius: 10),
          Container(
            height: 100,
            margin: EdgeInsetsDirectional.only(top: 12),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: index == 0 ? 0 : 8.0,
                  ),
                  child: const Column(
                    children: [
                      CustomShimmer(height: 70, width: 66, borderRadius: 10),
                      CustomShimmer(
                        height: 10,
                        width: 48,
                        margin: EdgeInsetsDirectional.only(top: 5),
                      ),
                      const CustomShimmer(
                        height: 10,
                        width: 60,
                        margin: EdgeInsetsDirectional.only(top: 2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [CustomShimmer(height: 20, width: 150)],
          ),
          Container(
            height: 214,
            margin: EdgeInsets.only(top: 10),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: index == 0 ? 0 : 10.0,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomShimmer(height: 147, width: 250, borderRadius: 10),
                      CustomShimmer(
                        height: 15,
                        width: 90,
                        margin: EdgeInsetsDirectional.only(top: 8),
                      ),
                      const CustomShimmer(
                        height: 14,
                        width: 230,
                        margin: EdgeInsetsDirectional.only(top: 8),
                      ),
                      const CustomShimmer(
                        height: 14,
                        width: 200,
                        margin: EdgeInsetsDirectional.only(top: 8),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            itemCount: 16,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.only(top: 20),
            itemBuilder: (context, index) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomShimmer(height: 147, borderRadius: 10),
                  CustomShimmer(
                    height: 15,
                    width: 70,
                    margin: EdgeInsetsDirectional.only(top: 8),
                  ),
                  const CustomShimmer(
                    height: 14,
                    margin: EdgeInsetsDirectional.only(top: 8),
                  ),
                  const CustomShimmer(
                    height: 14,
                    width: 130,
                    margin: EdgeInsetsDirectional.only(top: 8),
                  ),
                ],
              );
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisExtent: 215,
              crossAxisCount: 2, // Single column grid
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 15.0,
              // You may adjust this aspect ratio as needed
            ),
          ),
        ],
      ),
    );
  }


}

class AllItemsWidget extends StatelessWidget {
  const AllItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchHomeAllItemsCubit, FetchHomeAllItemsState>(
      builder: (context, state) {
        // TAMBAHKAN INI: Tangani state loading
        if (state is FetchHomeAllItemsInProgress) {
          // Tampilkan shimmer untuk GridView di bawah
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 20),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: 8, // Tampilkan beberapa shimmer
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 215,
                crossAxisCount: 2,
                mainAxisSpacing: 15.0,
                crossAxisSpacing: 15.0,
              ),
              itemBuilder: (context, index) {
                // Widget shimmer untuk setiap item grid
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmer(height: 147, borderRadius: 10),
                    CustomShimmer(height: 15, width: 70, margin: EdgeInsetsDirectional.only(top: 8)),
                    const CustomShimmer(height: 14, margin: EdgeInsetsDirectional.only(top: 8)),
                  ],
                );
              },
            ),
          );
        }

        if (state is FetchHomeAllItemsSuccess) {
          if (state.items.isNotEmpty) {
            final int crossAxisCount = 2;
            final int items = state.items.length;
            final int total =
                (items ~/ crossAxisCount) +
                (items % crossAxisCount != 0 ? 1 : 0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (Constant.isGoogleBannerAdsEnabled == "1") ...[
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: AdBannerWidget(), // Custom widget for banner ad
                  ),
                ] else ...[
                  SizedBox(height: 10),
                ],
                GridListAdapter(
                  type: ListUiType.List,
                  crossAxisCount: 2,
                  builder: (context, int index, bool isGrid) {
                    int itemIndex = index * crossAxisCount;
                    return SizedBox(
                      height: MediaQuery.sizeOf(context).height / 3.2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < crossAxisCount; ++i) ...[
                            Expanded(
                              child: itemIndex + 1 <= items
                                  ? ItemCard(item: state.items[itemIndex++])
                                  : SizedBox.shrink(),
                            ),
                            if (i != crossAxisCount - 1) SizedBox(width: 15),
                          ],
                        ],
                      ),
                    );
                  },
                  listSeparator: (context, index) {
                    if (index == 0 ||
                        index % Constant.nativeAdsAfterItemNumber != 0) {
                      return SizedBox(height: 15);
                    } else {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 5),
                          NativeAdWidget(type: TemplateType.medium),
                          //AdBannerWidget(),
                          SizedBox(height: 5),
                        ],
                      );
                    }
                  },
                  total: total,
                ),
                if (state.isLoadingMore) UiUtils.progress(),
              ],
            );
          } else {
            return NoDataFound(
              onTap: () async {
                final location =
                    await Navigator.pushNamed(context, Routes.locationScreen)
                        as LeafLocation?;
                if (location == null) return;

                context.read<LeafLocationCubit>().setLocation(location);
              },
              mainMsgStyle: context.font.larger,
              subMsgStyle: context.font.large,
              mainMessage: "noAdsFound".translate(context),
              subMessage: "noAdsAvailableInThisLocation".translate(context),
              showBtn: false,
              btnName: "changeLocation".translate(context),
            );
          }
        }
        if (state is FetchHomeAllItemsFail) {
          if (state.error is ApiException) {
            if (state.error.error == "no-internet") {
              return Center(child: NoInternet(onRetry: () {}));
            }
          }

          return const SomethingWentWrong();
        }
        return SizedBox.shrink();
      },
    );
  }
}

Future<void> notificationPermissionChecker() async {
  if (!(await Permission.notification.isGranted)) {
    await Permission.notification.request();
  }
}

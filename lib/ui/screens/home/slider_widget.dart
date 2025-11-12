import 'dart:async';

import 'package:com.maklaar.app/app/routes.dart';
import 'package:com.maklaar.app/data/cubits/slider_cubit.dart';
import 'package:com.maklaar.app/data/model/category_model.dart';
import 'package:com.maklaar.app/data/model/data_output.dart';
import 'package:com.maklaar.app/data/model/home/home_slider.dart';
import 'package:com.maklaar.app/data/model/item/item_model.dart';
import 'package:com.maklaar.app/data/repositories/item/item_repository.dart';
import 'package:com.maklaar.app/ui/screens/home/home_screen.dart';
import 'package:com.maklaar.app/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:com.maklaar.app/utils/helper_utils.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:com.maklaar.app/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart' as urllauncher;
import 'package:url_launcher/url_launcher.dart';
// Import your SliderCubit and other necessary dependencies

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<int> _bannerIndex = ValueNotifier(0);
   Timer? _timer;
   // int bannersLength = 0;
  final PageController _pageController = PageController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //_startAutoSlider();
  }

  @override
  void dispose() {
    _bannerIndex.dispose();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlider(int bannersLength) {
    // Set up a timer to automatically change the banner index
    _timer?.cancel();
    if (bannersLength <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted || !_pageController.hasClients) return;
      final int nextPage = _bannerIndex.value + 1;
      if (nextPage < bannersLength) {
        _bannerIndex.value = nextPage;
      } else {
        _bannerIndex.value = 0;
      }
      _pageController.animateToPage(
        _bannerIndex.value,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }


  /// =================================================================
  ///                       BAGIAN YANG DIPERBAIKI
  /// =================================================================
  ///
  /// Method `build` ini ditulis ulang untuk menangani state
  /// InProgress (loading), Success, dan Failure dengan benar.
  ///
  @override
  Widget build(BuildContext context) {
    super.build(context); // Diperlukan untuk AutomaticKeepAliveClientMixin

    return BlocBuilder<SliderCubit, SliderState>(
      builder: (context, SliderState state) {
        // 1. TANGANI STATE LOADING: Tampilkan placeholder.
        if (state is SliderFetchInProgress) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: sidePadding),
            child: const CustomShimmer(
              height: 170,
              borderRadius: 10,
            ),
          );
        }

        // 2. TANGANI STATE SUKSES: Tampilkan slider jika ada data.
        if (state is SliderFetchSuccess && state.sliderlist.isNotEmpty) {
          // Mulai timer otomatis setelah UI dipastikan memiliki data.
          _startAutoSlider(state.sliderlist.length);

          return SizedBox(
            height: 170,
            child: PageView.builder(
              itemCount: state.sliderlist.length,
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              onPageChanged: (index) {
                _bannerIndex.value = index;
              },
              itemBuilder: (context, index) {
                HomeSlider homeSlider = state.sliderlist[index];
                return InkWell(
                  onTap: () async {
                    sliderTap(homeSlider);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: sidePadding),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: UiUtils.getImage(
                        homeSlider.image ?? "",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        // PERBAIKAN: Tangani state failure
        if (state is SliderFetchFailure) {
          // Tampilkan pesan error atau widget kosong dengan tinggi yang sama
          return SizedBox(
              height: 170,
              child: Center(child: Text("Gagal memuat slider"))
          );
        }

        // 3. FALLBACK: Tangani semua state lain (Initial, Failure, atau Success tapi kosong).
        // Hentikan timer dan tampilkan widget kosong.
        _timer?.cancel();
        return SizedBox.shrink();
      },
    );
  }


  /// =================================================================
  ///                       BAGIAN YANG TIDAK DIUBAH
  /// =================================================================
  Future<void> sliderTap(HomeSlider homeSlider) async {
    if (homeSlider.thirdPartyLink != "") {
      await urllauncher.launchUrl(
        Uri.parse(homeSlider.thirdPartyLink!),
        mode: LaunchMode.externalApplication,
      );
    } else if (homeSlider.modelType!.contains("Category")) {
      if (homeSlider.model!.subCategoriesCount! > 0) {
        Navigator.pushNamed(
          context,
          Routes.subCategoryScreen,
          arguments: {
            "categoryList": <CategoryModel>[],
            "catName": homeSlider.model?.name?.localized,
            "catId": homeSlider.modelId,
            "categoryIds": [
              homeSlider.model!.parentCategoryId.toString(),
              homeSlider.modelId.toString(),
            ],
          },
        );
      } else {
        Navigator.pushNamed(
          context,
          Routes.itemsList,
          arguments: {
            'catID': homeSlider.modelId.toString(),
            'catName': homeSlider.model?.name?.localized,
            "categoryIds": [homeSlider.modelId.toString()],
          },
        );
      }
    } else {
      try {
        ItemRepository fetch = ItemRepository();

        LoadingWidgets.showLoader(context);

        DataOutput<ItemModel> dataOutput = await fetch.fetchItemFromItemId(
          homeSlider.modelId!,
        );

        Future.delayed(Duration.zero, () {
          LoadingWidgets.hideLoader(context);
          Navigator.pushNamed(
            context,
            Routes.adDetailsScreen,
            arguments: {"model": dataOutput.modelList[0]},
          );
        });
      } catch (e) {
        LoadingWidgets.hideLoader(context);
        HelperUtils.showSnackBarMessage(context, e.toString());
      }
    }
  }
}

import 'package:com.maklaar.app/app/routes.dart';
import 'package:com.maklaar.app/data/cubits/delete_advertisment_cubit.dart';
import 'package:com.maklaar.app/data/cubits/item/fetch_my_featured_items_cubit.dart';
import 'package:com.maklaar.app/data/cubits/utility/item_edit_global.dart';
import 'package:com.maklaar.app/data/model/item/item_model.dart';
import 'package:com.maklaar.app/data/repositories/item/advertisement_repository.dart';
import 'package:com.maklaar.app/ui/screens/home/widgets/item_horizontal_card.dart';
import 'package:com.maklaar.app/ui/screens/widgets/errors/no_data_found.dart';
import 'package:com.maklaar.app/ui/screens/widgets/errors/no_internet.dart';
import 'package:com.maklaar.app/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:com.maklaar.app/ui/screens/widgets/intertitial_ads_screen.dart';
import 'package:com.maklaar.app/ui/screens/widgets/shimmer_common_widget.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/api.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyAdvertisementScreen extends StatefulWidget {
  const MyAdvertisementScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (context) => FetchMyFeaturedItemsCubit(),
          child: const MyAdvertisementScreen(),
        );
      },
    );
  }

  @override
  State<MyAdvertisementScreen> createState() => _MyAdvertisementScreenState();
}

class _MyAdvertisementScreenState extends State<MyAdvertisementScreen> {
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    AdHelper.loadInterstitialAd();
    fetchMyFeaturedItems();

    _pageScrollController.addListener(_pageScroll);
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  void fetchMyFeaturedItems() {
    context.read<FetchMyFeaturedItemsCubit>().fetchMyFeaturedItems();
  }

  void _pageScroll() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchMyFeaturedItemsCubit>().hasMoreData()) {
        context.read<FetchMyFeaturedItemsCubit>().fetchMyFeaturedItemsMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AdHelper.showInterstitialAd();
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true, title: "myFeaturedAds".translate(context)),
      body: RefreshIndicator(
        onRefresh: () async {
          fetchMyFeaturedItems();
        },
        color: context.color.territoryColor,
        child:
            BlocBuilder<FetchMyFeaturedItemsCubit, FetchMyFeaturedItemsState>(
          builder: (context, state) {
            if (state is FetchMyFeaturedItemsInProgress) {
              return shimmerEffect();
            }
            if (state is FetchMyFeaturedItemsFailure) {
              if (state.errorMessage is ApiException) {
                if (state.errorMessage.errorMessage == "no-internet") {
                  return NoInternet(
                    onRetry: () {
                      fetchMyFeaturedItems();
                    },
                  );
                }
              }

              return const SomethingWentWrong();
            }
            if (state is FetchMyFeaturedItemsSuccess) {
              if (state.itemModel.isEmpty) {
                return NoDataFound(
                  onTap: () {
                    fetchMyFeaturedItems();
                  },
                );
              }

              return buildWidget(state);
            }
            return Container();
          },
        ),
      ),
    );
  }

  ListView shimmerEffect() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 12,
        );
      },
      itemBuilder: (context, index) {
        return ShimmerCommonWidget();
      },
    );
  }

  Widget buildWidget(FetchMyFeaturedItemsSuccess state) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _pageScrollController,
            itemCount: state.itemModel.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              ItemModel item = state.itemModel[index];

              item = context.watch<ItemEditCubit>().get(item);
              return BlocProvider(
                create: (context) =>
                    DeleteAdvertisementCubit(AdvertisementRepository()),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.adDetailsScreen,
                      arguments: {
                        'model': item,
                      },
                    );
                  },
                  child: ItemHorizontalCard(
                    item: item,
                  ),
                ),
              );
            },
          ),
        ),
        if (state.isLoadingMore) UiUtils.progress()
      ],
    );
  }
}

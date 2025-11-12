import 'package:com.maklaar.app/data/cubits/fetch_faqs_cubit.dart';
import 'package:com.maklaar.app/ui/screens/widgets/errors/no_data_found.dart';
import 'package:com.maklaar.app/ui/screens/widgets/errors/no_internet.dart';
import 'package:com.maklaar.app/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:com.maklaar.app/ui/screens/widgets/intertitial_ads_screen.dart';
import 'package:com.maklaar.app/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/api.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return const FaqsScreen();
      },
    );
  }

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  int _expandedItem = -1;

  @override
  void initState() {
    super.initState();
    AdHelper.loadInterstitialAd();
    context.read<FetchFaqsCubit>().fetchFaqs();
  }

  @override
  Widget build(BuildContext context) {
    AdHelper.showInterstitialAd();
    return RefreshIndicator(
      color: context.color.territoryColor,
      onRefresh: () async {
        context.read<FetchFaqsCubit>().fetchFaqs();
      },
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: "faqsLbl".translate(context),
        ),
        body: BlocBuilder<FetchFaqsCubit, FetchFaqsState>(
          builder: (context, state) {
            if (state is FetchFaqsInProgress) {
              return buildFaqsShimmer();
            }
            if (state is FetchFaqsFailure) {
              if (state.errorMessage is ApiException) {
                if (state.errorMessage.error == "no-internet") {
                  return NoInternet(
                    onRetry: () {
                      context.read<FetchFaqsCubit>().fetchFaqs();
                    },
                  );
                }
              }
              return const SomethingWentWrong();
            }
            if (state is FetchFaqsSuccess) {
              if (state.faqModel.isEmpty) {
                return const NoDataFound();
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsetsDirectional.only(top: 7, start: 15, end: 15),
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  );
                },
                itemCount: state.faqModel.length,
                itemBuilder: (context, index) {
                  final faq = state.faqModel[index];
                  return ExpansionPanelList(
                    children: [
                      ExpansionPanel(
                        isExpanded: _expandedItem == index,
                        backgroundColor: context.color.secondaryColor,
                        body: ListTile(
                          title: CustomText(
                            faq.answer.localized,
                            fontSize: context.font.normal,
                          ),
                        ),
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            title: CustomText(
                              faq.question.localized,
                              fontWeight: FontWeight.bold,
                              fontSize: context.font.normal,
                            ),
                          );
                        },
                        canTapOnHeader: true,
                      ),
                    ],
                    elevation: 0.0,
                    animationDuration: const Duration(milliseconds: 700),
                    expansionCallback: (int item, bool status) {
                      if (status) {
                        _expandedItem = index;
                      } else {
                        _expandedItem = -1;
                      }
                      setState(() {});
                    },
                  );
                },
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget buildFaqsShimmer() {
    return ListView.builder(
      itemCount: 7,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 7),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
          child: CustomShimmer(
            borderRadius: 0,
            width: double.infinity,
            height: 60,
          ),
        );
      },
    );
  }
}

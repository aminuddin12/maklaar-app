import 'package:com.maklaar.app/app/routes.dart';
import 'package:com.maklaar.app/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:com.maklaar.app/ui/screens/widgets/bottom_navigation_bar/hexagon_shape_border.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiamondFab extends StatelessWidget {
  const DiamondFab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchUserPackageLimitCubit, FetchUserPackageLimitState>(
      listener: (context, state) {
        if (state is FetchUserPackageLimitFailure) {
          UiUtils.noPackageAvailableDialog(context);
        }
        if (state is FetchUserPackageLimitInSuccess) {
          Navigator.pushNamed(
            context,
            Routes.selectCategoryScreen,
            arguments: <String, dynamic>{},
          );
        }
      },
      child: FloatingActionButton(
        onPressed: () {
          UiUtils.checkUser(
            onNotGuest: () {
              // Instead of calling the api everytime the button is pressed we can optimize
              // it to check whether the state is already success so we can directly navigate
              // but doing so will remove the correctness if the user's plan expired while the app
              // was open, then this will allow the item to be added or maybe not if the api
              // has such checks. Need to confirm.
              //
              // In either case, calling api on every button click is not ideal solution for this
              if (context.read<FetchUserPackageLimitCubit>().state
                  is FetchUserPackageLimitInProgress) {
                return;
              }
              context.read<FetchUserPackageLimitCubit>().fetchUserPackageLimit(
                packageType: Constant.itemTypeListing,
              );
            },
            context: context,
          );
        },
        backgroundColor: context.color.territoryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: HexagonBorderShape(),
        child: Icon(Icons.add),
      ),
    );
  }
}

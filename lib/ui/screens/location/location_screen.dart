import 'package:com.maklaar.app/data/cubits/location/location_search_cubit.dart';
import 'package:com.maklaar.app/ui/screens/location/widgets/location_list_picker.dart';
import 'package:com.maklaar.app/ui/screens/location/widgets/location_map_picker.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A gateway widget that displays the appropriate location picker based on the active map provider.
///
/// ### Behavior:
/// - **Free provider:**
///   Displays [LocationListPicker], which fetches location data from the database.
///
/// - **Paid provider:**
///   Displays [LocationMapPicker], which includes a map interface and enables
///   location search using the Places API.
///
/// This widget abstracts the logic of which picker to use, keeping upstream UI clean
/// and agnostic of the underlying provider.
class LocationScreen extends StatelessWidget {
  const LocationScreen({this.requiresExactLocation = false, super.key});
  final bool requiresExactLocation;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => LocationSearchCubit(),
        child: LocationScreen(
          requiresExactLocation:
              args?['requires_exact_location'] as bool? ?? false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFreeApi = Constant.mapProvider == 'free_api';
    return isFreeApi
        ? LocationListPicker(requiresExactLocation: requiresExactLocation)
        : LocationMapPicker();
  }
}

import 'package:com.maklaar.app/data/cubits/location/location_search_cubit.dart';
import 'package:com.maklaar.app/ui/screens/location/widgets/place_api_search_bar.dart';
import 'package:com.maklaar.app/ui/screens/widgets/location_map/location_map_controller.dart';
import 'package:com.maklaar.app/ui/screens/widgets/location_map/location_map_widget.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationMapPicker extends StatefulWidget {
  const LocationMapPicker({this.enableSearchBar = true, super.key});

  final bool enableSearchBar;
  @override
  State<LocationMapPicker> createState() => _LocationMapPickerState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider.value(
        value: args['search_cubit'] as LocationSearchCubit,
        child: LocationMapPicker(
          enableSearchBar: args['enable_search_bar'] as bool? ?? true,
        ),
      ),
    );
  }
}

class _LocationMapPickerState extends State<LocationMapPicker> {
  final LocationMapController _controller = LocationMapController();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<double> _radiusNotifier = ValueNotifier(
    Constant.minRadius,
  );

  bool get _hasValidRadiusRange => Constant.minRadius < Constant.maxRadius;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      // Set the persisted radius from Hive once the controller is ready.
      //
      // If the current radius equals [Constant.minRadius], update it with the
      // controller's latest radius value (usually restored from persistence).
      if (_radiusNotifier.value == Constant.minRadius) {
        _radiusNotifier.value = _controller.radius;
      }

      // Update the search bar text with the currently selected location.
      //
      // Triggered when the user taps on the map and the controller is ready.
      // Falls back to displaying "Global" if no location is selected.
      if (_controller.isReady) {
        final location = _controller.data.location;
        _searchController.text = location.isEmpty
            ? 'Global'
            : location.localizedPath;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _radiusNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText('nearbyListings'.translate(context)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: PlaceApiSearchBar(
            enabled: widget.enableSearchBar,
            controller: _searchController,
            onLocationSelected: (location) {
              _searchController.text = location.localizedPath;
              context.read<LocationSearchCubit>().selectLocation(
                placeId: location.placeId!,
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LocationMapWidget(controller: _controller),
                  BlocConsumer<LocationSearchCubit, LocationSearchState>(
                    listener: (context, state) {
                      if (state is LocationSearchSelected) {
                        _controller.updateLocation(state.location);
                      }
                    },
                    builder: (context, state) {
                      if (state is LocationSearchSelecting) {
                        return ColoredBox(
                          color: Colors.black12,
                          child: Center(child: UiUtils.progress()),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            if (_hasValidRadiusRange)
              ColoredBox(
                color: context.color.backgroundColor,
                child: ValueListenableBuilder(
                  valueListenable: _radiusNotifier,
                  builder: (context, value, index) {
                    return Padding(
                      padding: Constant.appContentPadding.copyWith(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                'selectAreaRange'.translate(context),
                                color: context.color.textDefaultColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              CustomText(
                                '${value.toInt()} ${"km".translate(context)}',
                                color: context.color.textDefaultColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 10,
                              activeTrackColor: context.color.territoryColor,
                              inactiveTrackColor: context.color.territoryColor
                                  .withValues(alpha: .2),
                              thumbColor: context.color.territoryColor,
                              padding: EdgeInsets.zero,
                              showValueIndicator: ShowValueIndicator.never,
                            ),
                            child: Slider(
                              value: value,
                              min: Constant.minRadius,
                              max: Constant.maxRadius,
                              divisions:
                                  (Constant.maxRadius - Constant.minRadius)
                                      .toInt(),
                              onChanged: (value) =>
                                  _radiusNotifier.value = value.roundToDouble(),
                              onChangeEnd: _controller.updateRadius,
                              label: '${value.toInt()}',
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                '${Constant.minRadius.toInt()}\t${"km".translate(context)}',
                                color: context.color.textDefaultColor,
                                fontWeight: FontWeight.w500,
                              ),
                              CustomText(
                                '${Constant.maxRadius.toInt()}\t${"km".translate(context)}',
                                color: context.color.textDefaultColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          UiUtils.buildButton(
                            context,
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pop(_controller.data.location);
                            },
                            height: 50,
                            buttonTitle: 'apply'.translate(context),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

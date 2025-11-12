import 'package:com.maklaar.app/data/cubits/location/location_search_cubit.dart';
import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/ui/screens/location/widgets/debounce_search_mixin.dart';
import 'package:com.maklaar.app/ui/screens/location/widgets/location_item.dart';
import 'package:com.maklaar.app/ui/screens/location/widgets/location_shimmer.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/app_icon.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A dynamic search bar that visually adapts based on focus state,
/// combining display and search behavior in one widget.
///
/// This widget mimics two distinct visual states (not actual widget states):
///
/// - **Unfocused:**
///   Acts like a card by applying a background fill color to the [TextField],
///   displaying the currently selected location.
///
/// - **Focused:**
///   Removes the fill and applies a focused border to resemble a standard [TextField],
///   allowing user input.
///
/// ### Behavior
/// - When focused, the current text is cleared and saved in a private [_previousText] variable.
/// - If the user un-focuses without typing anything new, the original text is restored.
/// - If the user types something, an [Overlay] is shown with live search results.
/// - The text field only updates when the user selects a location from the overlay.
///
/// > **Note:** The "card-like" appearance is achieved by filling the [TextField] background—no actual [Card] widget is used.
///
/// This is a more complex, interactive alternative to [LocationSearchBar],
/// useful when rich search UX and tighter visual control are required.
class PlaceApiSearchBar extends StatefulWidget {
  const PlaceApiSearchBar({
    required this.controller,
    required this.onLocationSelected,
    this.enabled = true,
    super.key,
  });

  final bool enabled;
  final TextEditingController controller;
  final ValueChanged<LeafLocation> onLocationSelected;

  @override
  State<PlaceApiSearchBar> createState() => _PlaceApiSearchBarState();
}

class _PlaceApiSearchBarState extends State<PlaceApiSearchBar>
    with DebounceSearchMixin {
  final FocusNode _focusNode = FocusNode();
  String? _previousText;

  final _layerLink = LayerLink();
  final OverlayPortalController _overlayPortalController =
      OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      // Handle focus transitions to preserve and restore text intelligently.
      //
      // When the field gains focus:
      // - Save the current text into [_previousText]
      // - Clear the text field to allow fresh input
      if (_focusNode.hasFocus) {
        _previousText = widget.controller.text;
        widget.controller.text = '';
      }
      // When the field loses focus and the user didn't type anything:
      // - Restore the original text from [_previousText]
      else if (widget.controller.text.isEmpty) {
        widget.controller.text = _previousText ?? '';
      }
      // When the user typed something new before un-focusing:
      // - Update [_previousText] with the latest input
      else {
        _previousText = widget.controller.text;
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void onDebouncedSearch(String? value) {
    context.read<LocationSearchCubit>().searchLocations(search: value);
  }

  /// Builds the overlay widget containing the search results list.
  ///
  /// This widget is anchored to the position of the search bar using a [CompositedTransformFollower].
  /// It follows the input field even if the widget moves (e.g., due to keyboard or layout shifts).
  ///
  /// ### Positioning
  /// - Anchored using [_layerLink], which must be shared with a [CompositedTransformTarget]
  ///   wrapping the search bar.
  /// - Appears slightly below the search bar using [offset].
  /// - Only shows when linked, preventing orphaned overlays.
  ///
  /// This is part of the overlay-based autocomplete UX and should be conditionally rendered
  /// only when search results are available.
  Widget _searchResults() {
    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      targetAnchor: Alignment.centerLeft,
      offset: Offset(0, 15),
      child: Padding(
        padding: Constant.appContentPadding,
        child: BlocBuilder<LocationSearchCubit, LocationSearchState>(
          builder: (context, state) {
            if (state is LocationSearchLoading) {
              return LocationShimmer();
            }
            if (state is LocationSearchSuccess) {
              return ListView.separated(
                itemCount: state.locations.length,
                itemBuilder: (context, index) {
                  final location = state.locations[index];
                  return LocationItem(
                    title: location.primaryText!,
                    subtitle: location.secondaryText,
                    onTap: () {
                      context.read<LocationSearchCubit>().clearSearch();
                      _focusNode.unfocus();
                      widget.onLocationSelected(location);
                    },
                    showTrailingIcon: false,
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  thickness: 1,
                  height: 0,
                  color: context.color.backgroundColor,
                ),
              );
            }

            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationSearchCubit, LocationSearchState>(
      listener: (context, state) {
        if (state is LocationSearchInitial) {
          if (_overlayPortalController.isShowing) {
            _overlayPortalController.hide();
          }
        } else {
          if (!_overlayPortalController.isShowing) {
            _overlayPortalController.show();
          }
        }
      },
      child: OverlayPortal(
        controller: _overlayPortalController,
        overlayChildBuilder: (context) => _searchResults(),
        child: CompositedTransformTarget(
          link: _layerLink,
          child: Padding(
            padding: Constant.appContentPadding.copyWith(bottom: 15),
            child: IgnorePointer(
              ignoring: !widget.enabled,
              child: ListenableBuilder(
                listenable: _focusNode,
                builder: (context, child) {
                  return TextField(
                    controller: widget.controller,
                    onChanged: onChanged,
                    focusNode: _focusNode,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(fontSize: context.font.normal),
                    decoration: InputDecoration(
                      filled: !_focusNode.hasFocus,
                      fillColor: context.color.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: context.color.territoryColor,
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 10.0),
                        child: UiUtils.getSvg(
                          AppIcons.location,
                          color: context.color.territoryColor,
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints.tight(
                        Size.square(30),
                      ),
                      isDense: true,
                      constraints: BoxConstraints.tight(Size.fromHeight(50)),
                    ),
                    onTapOutside: (_) {
                      if (_overlayPortalController.isShowing) return;
                      _focusNode.unfocus();
                      context.read<LocationSearchCubit>().clearSearch();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

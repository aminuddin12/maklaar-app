import 'package:com.maklaar.app/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/custom_filed_structure/option_item.dart';
import 'package:com.maklaar.app/ui/screens/widgets/dynamic_field.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:com.maklaar.app/utils/validator.dart';
import 'package:flutter/material.dart';

class CustomCheckboxField extends CustomField {
  @override
  String type = "checkbox";

  final List<OptionItem> options = List.empty(growable: true);
  final Set<String> selectedOptions = Set.identity();

  @override
  void init() {
    final englishValues = parameters['values'] as List;
    final translatedValues = parameters['translated_value'] as List?;
    final selectedValues = parameters['value'] as List? ?? [];

    for (int i = 0; i < englishValues.length; ++i) {
      final selected = selectedValues.contains(englishValues[i]);

      options.add(
        OptionItem(value: englishValues[i], label: translatedValues?[i]),
      );

      if (selected) {
        selectedOptions.add(options.last.value);
      }
    }
    super.init();
  }

  @override
  Widget render() {
    return CustomValidator<List>(
      validator: (List? value) {
        if (parameters['required'] != 1) {
          return null;
        }

        if (value?.isNotEmpty == true) {
          return null;
        }

        if (selectedOptions.isNotEmpty) {
          return null;
        }

        return "pleaseSelectValue".translate(context);
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (parameters['image'] != null) ...[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.color.territoryColor.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: FittedBox(
                        fit: BoxFit.none,
                        child: UiUtils.imageType(
                          parameters['image'],
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          color: context.color.textDefaultColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
                CustomText(
                  parameters['translated_name'] ?? parameters['name'],
                  fontSize: context.font.large,
                  fontWeight: FontWeight.w500,
                  color: context.color.textDefaultColor,
                ),
              ],
            ),
            SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: List.generate(options.length, (index) {
                    final option = options[index];
                    final isChecked = selectedOptions.contains(option.value);
                    return Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: index == 0 ? 0 : 4,
                        bottom: 4,
                        top: 4,
                        end: 4,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          if (isChecked) {
                            selectedOptions.remove(option.value);
                          } else {
                            selectedOptions.add(option.value);
                          }

                          AbstractField.fieldsData.addAll({
                            parameters['id'].toString(): selectedOptions
                                .toList(),
                          });

                          print(selectedOptions);
                          update(() {});
                          state.didChange(selectedOptions.toList());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.color.borderColor,
                              width: 1.5,
                            ),
                            color: isChecked
                                ? context.color.territoryColor.withValues(
                                    alpha: 0.1,
                                  )
                                : context.color.secondaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 14,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isChecked ? Icons.done : Icons.add,
                                  color: isChecked
                                      ? context.color.territoryColor
                                      : context.color.textColorDark,
                                ),
                                const SizedBox(width: 5),
                                CustomText(
                                  option.label,
                                  color: isChecked
                                      ? context.color.territoryColor
                                      : context.color.textDefaultColor
                                            .withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8.0,
                    ),
                    child: CustomText(
                      state.errorText ?? "",
                      color: context.color.error,
                      fontSize: context.font.small,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

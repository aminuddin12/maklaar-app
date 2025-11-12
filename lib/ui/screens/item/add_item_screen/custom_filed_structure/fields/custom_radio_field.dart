import 'package:com.maklaar.app/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/custom_filed_structure/option_item.dart';
import 'package:com.maklaar.app/ui/screens/widgets/dynamic_field.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:com.maklaar.app/utils/validator.dart';
import 'package:flutter/material.dart';

class CustomRadioField extends CustomField {
  @override
  String type = "radio";
  FormFieldState<String>? validation;

  final List<OptionItem> options = List.empty(growable: true);
  OptionItem? selectedOption;

  @override
  void init() {
    final englishValues = parameters['values'] as List;
    final translatedValues = parameters['translated_value'] as List?;
    final selectedValue = (parameters['value'] as List?)?.firstOrNull;

    for (int i = 0; i < englishValues.length; ++i) {
      final selected = englishValues[i] == selectedValue;

      options.add(
        OptionItem(value: englishValues[i], label: translatedValues?[i]),
      );

      if (selected) {
        selectedOption = options.last;
      }
    }
  }

  @override
  Widget render() {
    return CustomValidator<String>(
      initialValue: options.first.value,
      builder: (FormFieldState<String> state) {
        if (validation == null) {
          validation = state;
          Future.delayed(Duration.zero, () {
            update(() {});
          });
        }

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
                  color: context.color.textColorDark,
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
                    return Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: index == 0 ? 0 : 4,
                        end: 4,
                        bottom: 4,
                        top: 4,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          if (selectedOption == option) {
                            // Deselect if already selected
                            selectedOption = null;
                          } else {
                            // Select the tapped option
                            selectedOption = option;
                          }
                          //selectedRadioValue = element;
                          update(() {});
                          state.didChange(selectedOption?.value);

                          // selectedRadio.value = widget.radioValues?[index];
                          AbstractField.fieldsData.addAll({
                            parameters['id'].toString(): [
                              selectedOption?.value,
                            ],
                          });

                          print('${selectedOption?.value}');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.color.borderColor,
                              width: 1.5,
                            ),
                            color: selectedOption == option
                                ? context.color.territoryColor.withValues(
                                    alpha: 0.1,
                                  )
                                : context.color.secondaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            child: CustomText(
                              option.label,
                              color: (selectedOption == option
                                  ? context.color.territoryColor
                                  : context.color.textDefaultColor),
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
      validator: (String? value) {
        // Check if the field is required

        // Check if the value is null or empty (no selection made)
        if (parameters['required'] == 1 && selectedOption == null) {
          return "please_select_option".translate(
            context,
          ); // Return the error message if no selection
        }

        // If a valid selection is made, return null to indicate no error
        return null;
      },
    );
  }
}

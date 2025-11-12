import 'package:com.maklaar.app/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/custom_filed_structure/option_item.dart';
import 'package:com.maklaar.app/ui/screens/widgets/dynamic_field.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/app_icon.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomFieldDropdown extends CustomField {
  @override
  String type = "dropdown";
  String? selected;

  final List<OptionItem> options = List.empty(growable: true);

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
        this.selected = englishValues[i];
      }
    }
    super.init();
  }

  @override
  Widget render() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (parameters['image'] != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.color.territoryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: FittedBox(
                    fit: BoxFit.none,
                    child: UiUtils.imageType(
                      parameters['image'],
                      width: 20,
                      height: 20,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 1,
                    color: context.color.textLightColor.withValues(alpha: 0.18),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField(
                      validator: (value) {
                        if (parameters['required'] == 1 &&
                            (value == null || value.toString().isEmpty)) {
                          return 'field_required'.translate(context);
                        }
                        return null;
                      },
                      value: selected,
                      dropdownColor: context.color.secondaryColor,
                      isExpanded: true,
                      icon: SvgPicture.asset(
                        AppIcons.downArrow,
                        colorFilter: ColorFilter.mode(
                          context.color.textDefaultColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      decoration: InputDecoration(border: InputBorder.none),
                      //underline: SizedBox.shrink(),
                      isDense: true,
                      borderRadius: BorderRadius.circular(10),
                      style: TextStyle(
                        color: context.color.textDefaultColor.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: context.font.large,
                      ),
                      items: options.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.value,
                          child: CustomText(item.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        selected = value;
                        print(selected);
                        update(() {});
                        AbstractField.fieldsData.addAll({
                          parameters['id'].toString(): [selected],
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

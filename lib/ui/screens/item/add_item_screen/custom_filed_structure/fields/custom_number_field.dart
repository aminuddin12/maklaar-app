import 'package:com.maklaar.app/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';
import 'package:com.maklaar.app/ui/screens/widgets/custom_text_form_field.dart';
import 'package:com.maklaar.app/ui/screens/widgets/dynamic_field.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomNumberField extends CustomField {
  @override
  String type = "number";
  String initialValue = "";

  @override
  void init() {
    if (parameters['isEdit'] == true) {
      if (parameters['value'] != null) {
        if ((parameters['value'] as List).isNotEmpty) {
          initialValue = parameters['value'][0].toString();
          update(() {});
        }
      }
    }
    super.init();
  }

  @override
  Widget render() {
    final translated_name = parameters['translated_name'] ?? parameters['name'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Column(
        children: [
          Row(
            children: [
              if (parameters['image'] != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.color.territoryColor.withValues(alpha: 0.1),
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
                translated_name,
                fontSize: context.font.large,
                fontWeight: FontWeight.w500,
                color: context.color.textColorDark,
              ),
            ],
          ),
          SizedBox(height: 14),
          CustomTextFieldDynamic(
            initController: parameters['value'] != null ? true : false,
            value: initialValue,
            validator: CustomTextFieldValidator.minAndMixLen,
            maxLen: parameters['max_length'],
            minLen: parameters['min_length'],
            hintText: "",
            //"addNumerical".translate(context),
            formatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
            action: TextInputAction.next,
            keyboardType: TextInputType.number,
            required: parameters['required'] == 1 ? true : false,
            id: parameters['id'],
          ),
        ],
      ),
    );
  }
}

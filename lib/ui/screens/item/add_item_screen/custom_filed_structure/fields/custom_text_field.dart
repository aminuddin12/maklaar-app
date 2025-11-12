import 'package:com.maklaar.app/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';
import 'package:com.maklaar.app/ui/screens/widgets/custom_text_form_field.dart';
import 'package:com.maklaar.app/ui/screens/widgets/dynamic_field.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class CustomFieldText extends CustomField {
  @override
  String type = "textbox";
  String initialValue = "";

  @override
  void init() {
    print('Parameters: ${parameters.toString()}');

    // Restore value per language from AbstractField.fieldsData
    String compositeKey = '${parameters['id']}';
    if (parameters['language_id'] != null) {
      compositeKey = '${parameters['id']}_${parameters['language_id']}';
    }

    if (AbstractField.fieldsData.containsKey(compositeKey)) {
      var val = AbstractField.fieldsData[compositeKey];
      if (val is List && val.isNotEmpty) {
        initialValue = val[0].toString();
      } else {
        initialValue = "";
      }
    } else if (parameters['isEdit'] == true &&
        parameters['value'] != null &&
        parameters['value'] is List &&
        (parameters['value'] as List).isNotEmpty) {
      initialValue = parameters['value'][0].toString();
    } else {
      initialValue = "";
    }
    super.init();
  }

  @override
  Widget render() {
    return Column(
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
              (parameters['translated_name'] ?? parameters['name']) +
                  (parameters['language_name'] != null
                      ? ' (${parameters['language_name']})'
                      : ''),
              fontSize: context.font.large,
              fontWeight: FontWeight.w500,
              color: context.color.textColorDark,
            ),
          ],
        ),
        SizedBox(height: 14),
        CustomTextFieldDynamic(
          action: TextInputAction.newline,
          initController: parameters['value'] != null ? true : false,
          value: initialValue,
          hintText: "",
          //"writeSomething".translate(context),
          required: parameters['required'] == 1 ? true : false,
          id: parameters['id'],
          languageId: parameters['language_id'],
          maxLen: parameters['max_length'],
          maxLine: 3,
          minLen: parameters['min_length'],
          validator: CustomTextFieldValidator.minAndMixLen,
          keyboardType: TextInputType.multiline,
          capitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}

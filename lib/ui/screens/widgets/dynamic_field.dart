// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:com.maklaar.app/ui/screens/widgets/custom_text_form_field.dart';
//import 'package:file_icon/src/data.dart' as d;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Note: Here i have used abstract factory pattern and builder pattern
/// You can learn design patterns from internet
/// so don't be confuse
List kDoNotReBuildThese = [];
List kDoNotReBuildDropdown = [];

abstract class AbstractField {
  final BuildContext context;
  static Map<String, dynamic> fieldsData = {};
  static Map<String, dynamic> files = {};

  AbstractField(this.context);

  Widget createField(Map parameters);
}

class CustomTextFieldDynamic extends StatefulWidget {
  final String? value;
  final bool initController;
  final dynamic id;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? action;
  final List<TextInputFormatter>? formatters;
  final bool? required;
  final CustomTextFieldValidator? validator;
  final int? minLen;
  final int? maxLen;
  final int? maxLine;
  final int? minLine;
  final TextCapitalization? capitalization;
  final dynamic languageId;

  const CustomTextFieldDynamic({
    super.key,
    required this.initController,
    required this.value,
    this.id,
    required this.hintText,
    this.keyboardType,
    this.action,
    this.formatters,
    this.required,
    this.validator,
    this.minLen,
    this.maxLen,
    this.maxLine,
    this.minLine,
    this.capitalization,
    this.languageId,
  });

  @override
  State<CustomTextFieldDynamic> createState() => CustomTextFieldDynamicState();
}

class CustomTextFieldDynamicState extends State<CustomTextFieldDynamic> {
  TextEditingController? _controller;

  @override
  void didUpdateWidget(covariant CustomTextFieldDynamic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller != null && widget.value != oldWidget.value) {
      _controller!.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always initialize controller with the correct value for the current language/field
    String key = widget.id.toString();
    if (widget.languageId != null) {
      key = key + '_' + widget.languageId.toString();
    }
    String initialValue = '';
    if (AbstractField.fieldsData.containsKey(key)) {
      var val = AbstractField.fieldsData[key];
      if (val is List && val.isNotEmpty) {
        initialValue = val[0].toString();
      }
    } else if (widget.value != null) {
      initialValue = widget.value!;
    }
    _controller ??= TextEditingController(text: initialValue);
    if (_controller!.text != initialValue) {
      _controller!.text = initialValue;
    }
    return CustomTextFormField(
      hintText: widget.hintText,
      action: widget.action,
      formaters: widget.formatters,
      isRequired: widget.required,
      validator: widget.validator!,
      keyboard: widget.keyboardType,
      controller: _controller,
      maxLength: widget.maxLen,
      minLength: widget.minLen,
      maxLine: widget.maxLine,
      minLine: widget.minLine,
      capitalization: widget.capitalization,
      onChange: (value) {
        String key = widget.id.toString();
        if (widget.languageId != null) {
          key = key + '_' + widget.languageId.toString();
        }
        AbstractField.fieldsData.addAll(Map<String, dynamic>.from({
          key: [value]
        }));
      },
    );
  }
}

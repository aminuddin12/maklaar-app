import 'dart:convert';
import 'dart:io';

import 'package:com.maklaar.app/app/routes.dart';
import 'package:com.maklaar.app/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:com.maklaar.app/data/cubits/system/app_theme_cubit.dart';
import 'package:com.maklaar.app/data/cubits/system/fetch_language_cubit.dart';
import 'package:com.maklaar.app/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:com.maklaar.app/data/model/item/item_model.dart';
import 'package:com.maklaar.app/data/model/system_settings_model.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/select_category.dart';
import 'package:com.maklaar.app/ui/screens/widgets/dynamic_field.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/cloud_state/cloud_state.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddMoreDetailsScreen extends StatefulWidget {
  final bool? isEdit;
  final File? mainImage;

  final List<File>? otherImage;

  const AddMoreDetailsScreen({
    super.key,
    this.isEdit,
    this.mainImage,
    this.otherImage,
  });

  static MaterialPageRoute route(RouteSettings settings) {
    Map? args = settings.arguments as Map?;
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider.value(
          value: (args?['context'] as BuildContext)
              .read<FetchCustomFieldsCubit>(),
          child: AddMoreDetailsScreen(
            isEdit: args?['isEdit'],
            mainImage: args?['mainImage'],
            otherImage: args?['otherImage'],
          ),
        );
      },
    );
  }

  @override
  CloudState<AddMoreDetailsScreen> createState() =>
      _AddMoreDetailsScreenState();
}

class _AddMoreDetailsScreenState extends CloudState<AddMoreDetailsScreen>
    with TickerProviderStateMixin {
  List<CustomFieldBuilder> moreDetailDynamicFields = [];
  late final GlobalKey<FormState> _formKey;

  int selectedLangIndex = 0;
  List languages = [];
  String defaultLangCode = '';
  TabController? _tabController;

  void updateDynamicFields() {
    for (var field in moreDetailDynamicFields) {
      if (field.field['type'] == 'textbox' && languages.length > 1) {
        field.field['language_name'] = languages[selectedLangIndex]['name'];
        field.field['required'] =
            (selectedLangIndex == 0 && field.field['required'] == 1) ? 1 : 0;
        field.field['language_id'] = languages[selectedLangIndex]['id'];

        // Set value for the selected language in edit mode
        if (widget.isEdit ?? false) {
          ItemModel item = getCloudData('edit_request') as ItemModel;
          if (item.allTranslatedCustomFields != null) {
            var match = item.allTranslatedCustomFields!
                .where(
                  (translation) =>
                      translation['id'] == field.field['id'] &&
                      translation['language_id'] == field.field['language_id'],
                )
                .toList();
            if (match.isNotEmpty && match[0]['value'] != null) {
              field.field['value'] = match[0]['value'];
            } else {
              field.field['value'] = null; // Clear if not found
            }
          }
        }
        // Force re-init to update value
        field.init();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    Future.delayed(Duration.zero, () {
      moreDetailDynamicFields = context.read<FetchCustomFieldsCubit>().getFields().map((
        field,
      ) {
        Map<String, dynamic> fieldData = field.toMap();
        // Assuming 'getCloudData' returns the correct item based on 'edit_request'

        // Check if 'item' and 'item.customFields' are not null before accessing them
        if (widget.isEdit ?? false) {
          ItemModel item = getCloudData('edit_request') as ItemModel;

          // Use all_translated_custom_fields for all field types
          if (item.allTranslatedCustomFields != null) {
            // Find all entries for this field ID
            List<dynamic> fieldTranslations = item.allTranslatedCustomFields!
                .where((translation) => translation['id'] == field.id)
                .toList();
            // If language_id is present in fieldData, match it
            if (fieldData.containsKey('language_id')) {
              var langId = fieldData['language_id'];
              var match = fieldTranslations.firstWhere(
                (t) => t['language_id'] == langId,
                orElse: () => null,
              );
              if (match != null && match['value'] != null) {
                fieldData['value'] = match['value'];
              }
            } else if (fieldTranslations.isNotEmpty &&
                fieldTranslations[0]['value'] != null) {
              // If no language_id, just use the first match
              fieldData['value'] = fieldTranslations[0]['value'];
            }
          }
        }

        fieldData['isEdit'] = widget.isEdit == true;
        // For non-textbox fields, always use the original required value
        fieldData['required'] = field.toMap()['required'];
        CustomFieldBuilder customFieldBuilder = CustomFieldBuilder(fieldData);
        customFieldBuilder.stateUpdater(setState);
        customFieldBuilder.init();
        return customFieldBuilder;
      }).toList();
      updateDynamicFields();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    languages =
        context.watch<FetchSystemSettingsCubit>().getSetting(
              SystemSetting.language,
            )
            as List? ??
        [];
    defaultLangCode = context.watch<FetchSystemSettingsCubit>().getSetting(
      SystemSetting.defaultLanguage,
    );
    if (languages.isNotEmpty &&
        languages[0]['code'].toString() != defaultLangCode) {
      final defIndex = languages.indexWhere(
        (l) => l['code'] == defaultLangCode,
      );
      if (defIndex > 0) {
        final defLang = languages.removeAt(defIndex);
        languages.insert(0, defLang);
      }
    }
    // Check if there are any textbox fields
    final hasTextboxFields = context
        .read<FetchCustomFieldsCubit>()
        .getFields()
        .any((field) => field.type == 'textbox');
    if (languages.isEmpty) {
      return Center(child: Text('No languages available'));
    }
    if (hasTextboxFields && languages.length > 1) {
      _tabController ??= TabController(
        length: languages.length,
        vsync: this,
        initialIndex: 0,
      );
    } else {
      _tabController = null;
      selectedLangIndex = 0;
    }
    String selectedLangCode = languages[selectedLangIndex]['code'];
    bool isDefault = selectedLangCode == defaultLangCode;

    // Populate custom field translations if in edit mode
    if (widget.isEdit ?? false) {
      // Get all custom fields
      var customFields = context.read<FetchCustomFieldsCubit>().getFields();

      for (var field in customFields) {
        if (field.type == 'textbox') {
          var storedTranslations = getCloudData(
            "field_${field.id}_translations",
          );
          if (storedTranslations != null) {
            for (var translation in storedTranslations) {
              if (translation is Map<String, dynamic>) {
                int? languageId = translation['language_id'];
                List<dynamic>? value = translation['value'];

                if (languageId != null && value != null && value.isNotEmpty) {
                  // Create composite key for the field
                  String compositeKey = "${field.id}_$languageId";

                  // Store the value in AbstractField.fieldsData
                  AbstractField.fieldsData[compositeKey] = value;
                }
              }
            }
            // Clear the stored translations after populating
            clearCloudData("field_${field.id}_translations");
          }
        }
      }
    }

    return Scaffold(
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: "AdDetails".translate(context),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          boxShadow: context.read<AppThemeCubit>().isDarkMode()
              ? null
              : [
                  BoxShadow(
                    color: context.color.textLightColor.withValues(alpha: 0.01),
                    offset: Offset(0, -2),
                    blurRadius: 1,
                    spreadRadius: 0,
                  ),
                ],
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (languages.length > 1 && hasTextboxFields && isDefault) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: orangeColor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "allRequiredDefaultLangFilled".translate(context),
                        style: TextStyle(color: orangeColor, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(height: 10),
            ],
            UiUtils.buildButton(
              outerPadding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              context,
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Map itemDetailsScreenData = getCloudData("item_details");

                  // Build custom_field_translations for all languages (including default)
                  Map<String, Map<String, List>> customFieldTranslations = {};
                  for (int langIdx = 0; langIdx < languages.length; langIdx++) {
                    final langId = languages[langIdx]['id'].toString();
                    customFieldTranslations[langId] = {};
                    for (var field
                        in context
                            .read<FetchCustomFieldsCubit>()
                            .getFields()
                            .where((f) => f.type == 'textbox')) {
                      final fieldId = field.id.toString();
                      final compositeKey = fieldId + '_' + langId;
                      final value = AbstractField.fieldsData[compositeKey];
                      if (value != null &&
                          value is List &&
                          value.isNotEmpty &&
                          value[0].toString().isNotEmpty) {
                        customFieldTranslations[langId]![fieldId] = value;
                      }
                    }
                  }

                  // Only non-textbox fields in custom_fields
                  Map<String, List<dynamic>> nonTextboxFields = {};
                  for (var entry in AbstractField.fieldsData.entries) {
                    // Only add if the key does not match the textbox composite key pattern
                    // (i.e., does not match fieldId_langId for a textbox field)
                    bool isTextboxComposite = false;
                    for (var field
                        in context
                            .read<FetchCustomFieldsCubit>()
                            .getFields()
                            .where((f) => f.type == 'textbox')) {
                      final fieldId = field.id.toString();
                      for (var lang in languages) {
                        final langId = lang['id'].toString();
                        if (entry.key == fieldId + '_' + langId) {
                          isTextboxComposite = true;
                          break;
                        }
                      }
                      if (isTextboxComposite) break;
                    }
                    if (!isTextboxComposite) {
                      nonTextboxFields[entry.key] = entry.value is List
                          ? entry.value
                          : [entry.value];
                    }
                  }

                  final languageId =
                      (context.read<FetchLanguageCubit>().state
                              as FetchLanguageSuccess)
                          .id
                          .toString();
                  if (customFieldTranslations.containsKey(languageId)) {
                    customFieldTranslations[languageId]!.addAll(
                      nonTextboxFields,
                    );
                  } else {
                    customFieldTranslations[languageId] = nonTextboxFields;
                  }

                  itemDetailsScreenData['custom_field_translations'] = json
                      .encode(customFieldTranslations);

                  print(itemDetailsScreenData['custom_field_translations']);
                  print(
                    itemDetailsScreenData['custom_field_translations']
                        .runtimeType,
                  );

                  itemDetailsScreenData.addAll(AbstractField.files);

                  // Debug prints to verify file inclusion
                  print("Files being sent: ");
                  AbstractField.files.forEach((k, v) => print("  $k: $v"));
                  print("Payload: $itemDetailsScreenData");

                  addCloudData("with_more_details", itemDetailsScreenData);
                  screenStack++;
                  navigateToCustomLocation();
                }
              },
              height: 48,
              fontSize: context.font.large,
              buttonTitle: "next".translate(context),
            ),
          ],
        ),
      ),
      body: BlocConsumer<FetchCustomFieldsCubit, FetchCustomFieldState>(
        listener: (context, state) {
          if (state is FetchCustomFieldSuccess) {
            if (state.fields.isEmpty) {
              navigateToCustomLocation();
            }
          }
        },
        builder: (context, state) {
          if (state is FetchCustomFieldFail) {
            return Center(child: CustomText(state.error.toString()));
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasTextboxFields && languages.length > 1)
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: context.color.territoryColor,
                      unselectedLabelColor: context.color.textColorDark
                          .withValues(alpha: 0.5),
                      indicatorColor: context.color.territoryColor,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      onTap: (index) {
                        // Only validate when leaving the default language tab (index 0)
                        if (selectedLangIndex == 0 && index != 0) {
                          if (!(_formKey.currentState?.validate() ?? false)) {
                            // Prevent tab change if not valid
                            // Set the controller's index back to the previous value
                            _tabController?.animateTo(selectedLangIndex);
                            return;
                          }
                        }
                        setState(() {
                          selectedLangIndex = index;
                          updateDynamicFields();
                        });
                      },
                      tabs: languages.map((lang) {
                        final isDef = lang['code'] == defaultLangCode;
                        return Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(lang['name']),
                              if (isDef) ...[
                                SizedBox(width: 4),
                                Icon(
                                  Icons.check_box_rounded,
                                  color: context.color.territoryColor,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  if (hasTextboxFields && languages.length > 1)
                    SizedBox(height: 18),
                  CustomText(
                    "giveMoreDetailsAboutYourAds".translate(context),
                    fontSize: context.font.large,
                    fontWeight: FontWeight.w600,
                  ),
                  ...moreDetailDynamicFields
                      .where((field) {
                        // In default language, show all fields
                        if (isDefault) {
                          return true;
                        } else {
                          // For other languages, only show textbox fields
                          return field.field['type'] == 'textbox';
                        }
                      })
                      .map((field) {
                        field.stateUpdater(setState);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9.0),
                          child: field.build(context),
                        );
                      }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void navigateToCustomLocation() {
    Navigator.pushNamed(
      context,
      Routes.confirmLocationScreen,
      arguments: {
        "isEdit": widget.isEdit,
        "mainImage": widget.mainImage,
        "otherImage": widget.otherImage,
      },
    ).then((value) {
      screenStack--;

      if (value == "success") {
        screenStack = 0;
      }
    });
  }
}

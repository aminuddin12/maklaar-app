import 'dart:convert';

import 'package:com.maklaar.app/app/routes.dart';
import 'package:com.maklaar.app/data/cubits/seller/fetch_seller_verification_field.dart';
import 'package:com.maklaar.app/data/cubits/seller/fetch_verification_request_cubit.dart';
import 'package:com.maklaar.app/data/cubits/seller/send_verification_field_cubit.dart';
import 'package:com.maklaar.app/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:com.maklaar.app/data/model/system_settings_model.dart';
import 'package:com.maklaar.app/data/model/user/verification_request_model.dart';
import 'package:com.maklaar.app/ui/screens/home/home_screen.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';
import 'package:com.maklaar.app/ui/screens/widgets/custom_text_form_field.dart';
import 'package:com.maklaar.app/ui/screens/widgets/dynamic_field.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/cloud_state/cloud_state.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/helper_utils.dart';
import 'package:com.maklaar.app/utils/hive_utils.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:com.maklaar.app/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerVerificationScreen extends StatefulWidget {
  final bool isResubmitted;

  SellerVerificationScreen({super.key, required this.isResubmitted});

  @override
  CloudState<SellerVerificationScreen> createState() =>
      _SellerVerificationScreenState();

  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return MaterialPageRoute(
      builder: (context) {
        return SellerVerificationScreen(
          isResubmitted: arguments?["isResubmitted"],
        );
      },
    );
  }
}

class _SellerVerificationScreenState
    extends CloudState<SellerVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  double fillValue = 0.5;
  int page = 1;
  bool isBack = false;
  List<CustomFieldBuilder> moreDetailDynamicFields = [];
  final _scrollController = ScrollController();

  // For multi-language support
  int selectedLangIndex = 0;
  List languages = [];
  String defaultLangCode = '';
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    AbstractField.fieldsData.clear();
    AbstractField.files.clear();

    Future.delayed(Duration.zero, () {
      if (widget.isResubmitted == true) {
        context
            .read<FetchVerificationRequestsCubit>()
            .fetchVerificationRequests();
      }

      // Initialize language settings after the first build
      languages =
          context.read<FetchSystemSettingsCubit>().getSetting(
                SystemSetting.language,
              )
              as List? ??
          [];

      defaultLangCode = context.read<FetchSystemSettingsCubit>().getSetting(
        SystemSetting.defaultLanguage,
      );
    });

    nameController.text = (HiveUtils.getUserDetails().name) ?? "";
    emailController.text = HiveUtils.getUserDetails().email ?? "";
    phoneController.text = HiveUtils.getUserDetails().mobile ?? "";
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    _scrollController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        // Reached the bottom of the list
        FocusScope.of(context).unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isBack,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        if (page == 2) {
          page = 1;
          fillValue = 0.5;
        }
        setState(() {
          isBack = page != 2;
        });
      },
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          onBackPress: () {
            if (page == 2) {
              setState(() {
                page = 1;
                fillValue = 0.5;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        bottomNavigationBar: bottomBar(),
        body: mainBody(),
      ),
    );
  }

  Map<String, dynamic> convertToCustomFields(Map<dynamic, dynamic> fieldsData) {
    // Create a map to store translations for each field and language
    Map<String, Map<String, List>> verificationFieldTranslations = {};

    print(fieldsData);

    // Process fieldsData to separate language-specific entries
    fieldsData.forEach((key, value) {
      // Check if this is a composite key (fieldId_languageId)
      if (key.toString().contains('_')) {
        List<String> parts = key.toString().split('_');
        if (parts.length == 2) {
          String fieldId = parts[0];
          String langId = parts[1];

          // Initialize the language map if it doesn't exist
          verificationFieldTranslations[langId] ??= {};

          // Add the field value to the appropriate language map
          verificationFieldTranslations[langId]![fieldId] = value is List
              ? value
              : [value];
        }
      } else {
        // For non-textbox fields, add them to default language map
        String defaultLangId = languages[0]['id'].toString();
        verificationFieldTranslations[defaultLangId] ??= {};
        verificationFieldTranslations[defaultLangId]![key.toString()] =
            value is List ? value : [value];
      }
    });

    // Create the final data map
    Map<String, dynamic> data = {};

    // Add verification_field_translations if we have any
    if (verificationFieldTranslations.isNotEmpty) {
      data['verification_field_translations'] = json.encode(
        verificationFieldTranslations,
      );
    }

    print(data);

    return data
      ..removeWhere((key, value) => value == null); // Remove null entries
  }

  Widget bottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: sidePadding,
          vertical: 20,
        ),
        child: Column(
          spacing: 30,
          mainAxisSize: MainAxisSize.min,
          children: [
            UiUtils.buildButton(
              context,
              height: 46,
              radius: 8,
              onPressed: () {
                if (page == 1) {
                  setState(() {
                    page = 2;
                    fillValue = 1.0;
                    Future.delayed(Duration.zero, () {
                      context
                          .read<FetchSellerVerificationFieldsCubit>()
                          .fetchSellerVerificationFields();
                    });
                  });
                } else if (_formKey.currentState?.validate() ?? false) {
                  Map<String, dynamic> data = convertToCustomFields(
                    AbstractField.fieldsData,
                  );

                  Map<String, dynamic> files = AbstractField.files;

                  files.forEach((key, value) {
                    if (value is String) {
                      final uri = Uri.tryParse(value);
                      if (uri != null &&
                          uri.host.startsWith(RegExp(r'(https|http)'))) {
                        return;
                      }
                    }
                    if (key.startsWith('custom_field_files[') &&
                        key.endsWith(']')) {
                      String index = key.substring(
                        'custom_field_files['.length,
                        key.length - 1,
                      );
                      String newKey = 'verification_field_files[$index]';
                      data[newKey] = value;
                    } else {
                      // For other keys, add them unchanged
                      data[key] = value;
                    }
                  });
                  context.read<SendVerificationFieldCubit>().send(data: data);
                }
              },
              buttonTitle: "continue".translate(context),
            ),
            Center(
              child: InkWell(
                child: Text(
                  "skipForLater".translate(context),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    decoration: TextDecoration.underline,
                    color: context.color.textDefaultColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mainBody() {
    return BlocListener<SendVerificationFieldCubit, SendVerificationFieldState>(
      listener: (context, state) {
        if (state is SendVerificationFieldInProgress) {
          LoadingWidgets.showLoader(context);
        } else if (state is SendVerificationFieldSuccess) {
          LoadingWidgets.hideLoader(context);

          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushNamed(
                context,
                Routes.sellerVerificationComplteScreen,
              );
            }
          });
        } else if (state is SendVerificationFieldFail) {
          HelperUtils.showSnackBarMessage(context, state.error.toString());
          LoadingWidgets.hideLoader(context);
        }
      },
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 20),
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  'userVerification'.translate(context),
                  color: context.color.textDefaultColor,
                  fontSize: context.font.extraLarge,
                  fontWeight: FontWeight.w600,
                ),
                Spacer(),
                CustomText(
                  '${"stepLbl".translate(context)}\t$page\t${"of2Lbl".translate(context)}',
                  color: context.color.textLightColor,
                ),
              ],
            ),
            linearIndicator(),
            page == 1 ? firstPageVerification() : secondPageVerification(),
          ],
        ),
      ),
    );
  }

  Widget linearIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Center(
        child: Stack(
          children: [
            // First part (bottom progress indicator)
            LinearProgressIndicator(
              value: 0.5,
              borderRadius: BorderRadius.circular(2),
              // 50% of the total progress
              backgroundColor: Colors.grey[300],
              // Background color for the first part
              valueColor: AlwaysStoppedAnimation<Color>(
                context.color.backgroundColor,
              ),
              // Color for the first 50%
              minHeight: 4.0,
            ),
            // Second part (overlaying progress indicator for the remaining 50%)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fillValue,
                  // This limits the width of the second indicator to 50%
                  child: LinearProgressIndicator(
                    value: 1.0,
                    borderRadius: BorderRadius.circular(2),
                    // Full for the second half
                    backgroundColor: Colors.transparent,
                    // No background for the overlay
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.color.textDefaultColor,
                    ),
                    // Color for the second 50%
                    minHeight: 4.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget firstPageVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 16),
        CustomText(
          'personalInformation'.translate(context),
          color: context.color.textDefaultColor,
          fontSize: context.font.larger,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 8),
        CustomText(
          'pleaseProvideYourAccurateInformation'.translate(context),
          color: context.color.textDefaultColor,
          fontSize: context.font.large,
        ),
        SizedBox(height: 10),
        buildTextField(
          context,
          title: "fullName",
          hintText: "provideFullNameHere".translate(context),
          controller: nameController,
          //validator: CustomTextFieldValidator.nullCheck,
          readOnly: true,
        ),
        buildTextField(
          context,
          title: "phoneNumber",
          hintText: "phoneNumberHere".translate(context),
          controller: phoneController,
          readOnly: true,
          //validator: CustomTextFieldValidator.phoneNumber,
        ),
        buildTextField(
          context,
          title: "emailAddress",
          hintText: "emailAddressHere".translate(context),
          controller: emailController,
          readOnly: true,
          //validator: CustomTextFieldValidator.email,
        ),
      ],
    );
  }

  Widget buildTextField(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    //CustomTextFieldValidator? validator,
    bool? readOnly,
    required String hintText,
  }) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        CustomText(
          title.translate(context),
          color: context.color.textDefaultColor,
        ),
        CustomTextFormField(
          controller: controller,
          isReadOnly: readOnly,
          //validator: validator,
          hintText: hintText,
          fillColor: context.color.secondaryColor,
        ),
      ],
    );
  }

  // Helper method to update dynamic fields based on selected language
  void updateDynamicFields() {
    for (var field in moreDetailDynamicFields) {
      if (field.field['type'] == 'textbox' && languages.length > 1) {
        // Update field parameters
        field.field['language_name'] = languages[selectedLangIndex]['name'];
        field.field['required'] =
            (selectedLangIndex == 0 && field.field['required'] == 1) ? 1 : 0;
        field.field['language_id'] = languages[selectedLangIndex]['id'];
        field.field['isEdit'] = widget.isResubmitted;

        // Set value for the selected language in edit mode
        if (widget.isResubmitted) {
          var verificationState = context
              .read<FetchVerificationRequestsCubit>()
              .state;
          if (verificationState is FetchVerificationRequestSuccess) {
            List<VerificationFieldValues> verificationList =
                verificationState.data.verificationFieldValues!;

            var matchingFields = verificationList.where((e) {
              return e.verificationFieldId == field.field['id'] &&
                  e.languageId == field.field['language_id'];
            }).toList();

            if (matchingFields.isNotEmpty) {
              // Also set the value in the parameters for init
              field.field['value'] = [matchingFields[0].value!];
            } else {
              field.field['value'] = [];
            }
          }
        }

        // Force re-init to update value
        field.init(); // Initialize with updated parameters
      }
    }
    setState(() {}); // Trigger rebuild with updated fields
  }

  Widget secondPageVerification() {
    // Get languages from system settings
    languages =
        context.watch<FetchSystemSettingsCubit>().getSetting(
              SystemSetting.language,
            )
            as List? ??
        [];
    defaultLangCode = context.watch<FetchSystemSettingsCubit>().getSetting(
      SystemSetting.defaultLanguage,
    );

    // Ensure default language is first in the list
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
    final hasTextboxFields = moreDetailDynamicFields.any(
      (field) => field.field['type'] == 'textbox',
    );

    if (hasTextboxFields && languages.length > 1) {
      if (_tabController == null) {
        _tabController = TabController(
          length: languages.length,
          vsync: this,
          initialIndex: selectedLangIndex,
        );

        _tabController!.addListener(() {
          if (!_tabController!.indexIsChanging) {
            setState(() {
              selectedLangIndex = _tabController!.index;
              updateDynamicFields();
            });
          }
        });
      } else if (_tabController!.length != languages.length) {
        // Dispose old controller if language count changed
        _tabController!.dispose();
        _tabController = TabController(
          length: languages.length,
          vsync: this,
          initialIndex: selectedLangIndex < languages.length
              ? selectedLangIndex
              : 0,
        );

        _tabController!.addListener(() {
          if (!_tabController!.indexIsChanging) {
            setState(() {
              selectedLangIndex = _tabController!.index;
              updateDynamicFields();
            });
          }
        });
      }
    } else {
      if (_tabController != null) {
        _tabController!.dispose();
        _tabController = null;
      }
      selectedLangIndex = 0;
    }

    String selectedLangCode = languages.isNotEmpty
        ? languages[selectedLangIndex]['code']
        : '';
    bool isDefault = selectedLangCode == defaultLangCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 16),
        CustomText(
          'idVerification'.translate(context),
          color: context.color.textDefaultColor,
          fontSize: context.font.larger,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 8),
        CustomText(
          'selectDocumentToConfirmIdentity'.translate(context),
          color: context.color.textDefaultColor,
          fontSize: context.font.large,
        ),
        SizedBox(height: 10),
        // Language tabs if needed
        if (hasTextboxFields && languages.length > 1)
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: context.color.territoryColor,
            unselectedLabelColor: context.color.textColorDark.withValues(
              alpha: 0.5,
            ),
            indicatorColor: context.color.territoryColor,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            tabAlignment: TabAlignment.start,
            onTap: (index) {
              // Only validate when leaving the default language tab (index 0)
              if (selectedLangIndex == 0 && index != 0) {
                if (!(_formKey.currentState?.validate() ?? false)) {
                  // Prevent tab change if not valid
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
        if (hasTextboxFields && languages.length > 1) SizedBox(height: 18),
        // Warning message for default language
        if (languages.length > 1 && hasTextboxFields && isDefault) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
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
        ],
        BlocBuilder<
          FetchVerificationRequestsCubit,
          FetchVerificationRequestState
        >(
          builder: (context, verificationState) {
            return BlocConsumer<
              FetchSellerVerificationFieldsCubit,
              FetchSellerVerificationFieldState
            >(
              listener: (context, state) {
                if (state is FetchSellerVerificationFieldSuccess) {
                  moreDetailDynamicFields = state.fields.map<CustomFieldBuilder>((
                    field,
                  ) {
                    print(field);
                    Map<String, dynamic> fieldData = field.toMap();
                    if (widget.isResubmitted &&
                        verificationState is FetchVerificationRequestSuccess) {
                      List<VerificationFieldValues> verificationList =
                          verificationState.data.verificationFieldValues!;

                      // For textbox fields with multiple languages, we need to find values for each language
                      if (field.type == 'textbox' && languages.length > 1) {
                        // First set default value to empty to avoid showing default language value for all tabs
                        fieldData['value'] = [];

                        // Find matching field for current language
                        var matchingFields = verificationList
                            .where(
                              (e) =>
                                  e.verificationFieldId == field.id &&
                                  e.languageId ==
                                      languages[selectedLangIndex]['id'],
                            )
                            .toList();

                        if (matchingFields.isNotEmpty) {
                          print(matchingFields);
                          fieldData['value'] = [matchingFields[0].value!];
                          fieldData['isEdit'] = widget.isResubmitted;
                        }
                      } else {
                        // For non-textbox fields or when only one language
                        VerificationFieldValues? matchingField =
                            verificationList.any(
                              (e) => e.verificationFieldId == field.id,
                            )
                            ? verificationList.firstWhere(
                                (e) => e.verificationFieldId == field.id,
                              )
                            : null;
                        if (matchingField != null) {
                          fieldData['value'] = [matchingField.value!];
                          fieldData['isEdit'] = widget.isResubmitted;
                        }
                      }
                    }

                    // Set language-specific properties for textbox fields
                    if (field.type == 'textbox' && languages.length > 1) {
                      fieldData['language_name'] =
                          languages[selectedLangIndex]['name'];
                      fieldData['language_id'] =
                          languages[selectedLangIndex]['id'];
                      // Only make fields required in default language
                      fieldData['required'] =
                          (selectedLangIndex == 0 && fieldData['required'] == 1)
                          ? 1
                          : 0;
                      fieldData['isEdit'] = widget.isResubmitted;
                    }

                    CustomFieldBuilder customFieldBuilder = CustomFieldBuilder(
                      fieldData,
                    );
                    customFieldBuilder.stateUpdater(setState);
                    customFieldBuilder.init();
                    return customFieldBuilder;
                  }).toList();
                  setState(() {});
                }
              },
              builder: (context, state) {
                if (moreDetailDynamicFields.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: moreDetailDynamicFields.length,
                    itemBuilder: (context, index) {
                      final field = moreDetailDynamicFields[index];
                      field.stateUpdater(setState);

                      // In non-default languages, only show textbox fields
                      if (!isDefault && field.field['type'] != 'textbox') {
                        return SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9.0),
                        child: field.build(context),
                      );
                    },
                  );
                } else {
                  return SizedBox();
                }
              },
            );
          },
        ),
      ],
    );
  }
}

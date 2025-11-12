import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:com.maklaar.app/app/routes.dart';
import 'package:com.maklaar.app/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:com.maklaar.app/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:com.maklaar.app/data/model/category_model.dart';
import 'package:com.maklaar.app/data/model/item/item_model.dart';
import 'package:com.maklaar.app/data/model/system_settings_model.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/select_category.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/widgets/image_adapter.dart';
import 'package:com.maklaar.app/ui/screens/widgets/blurred_dialog_box.dart';
import 'package:com.maklaar.app/ui/screens/widgets/custom_text_form_field.dart';
import 'package:com.maklaar.app/ui/screens/widgets/dynamic_field.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/cloud_state/cloud_state.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/helper_utils.dart';
import 'package:com.maklaar.app/utils/hive_utils.dart';
import 'package:com.maklaar.app/utils/image_picker.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AddItemDetails extends StatefulWidget {
  final List<CategoryModel>? breadCrumbItems;
  final bool? isEdit;

  const AddItemDetails({super.key, this.breadCrumbItems, required this.isEdit});

  static Route route(RouteSettings settings) {
    Map<String, dynamic>? arguments =
        settings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (context) => FetchCustomFieldsCubit(),
          child: AddItemDetails(
            breadCrumbItems: arguments?['breadCrumbItems'],
            isEdit: arguments?['isEdit'],
          ),
        );
      },
    );
  }

  @override
  CloudState<AddItemDetails> createState() => _AddItemDetailsState();
}

class _AddItemDetailsState extends CloudState<AddItemDetails>
    with TickerProviderStateMixin {
  final PickImage _pickTitleImage = PickImage();
  final PickImage itemImagePicker = PickImage();
  String titleImageURL = "";
  List<dynamic> mixedItemImageList = [];
  List<int> deleteItemImageList = [];
  late final GlobalKey<FormState> _formKey;

  // Shared fields
  final TextEditingController adSlugController = TextEditingController();
  final TextEditingController adPriceController = TextEditingController();
  final TextEditingController adPhoneNumberController = TextEditingController();
  final TextEditingController adAdditionalDetailsController =
      TextEditingController();
  final TextEditingController minSalaryController = TextEditingController();
  final TextEditingController maxSalaryController = TextEditingController();

  // Language-specific fields
  Map<String, TextEditingController> adTitleControllers = {};
  Map<String, TextEditingController> adDescriptionControllers = {};

  int selectedLangIndex = 0;
  List languages = [];
  String defaultLangCode = '';
  TabController? _tabController;

  late List selectedCategoryList;
  ItemModel? item;

  // Flag to ensure translations are only populated once
  bool _translationsPopulated = false;

  // Store the English slug listener reference
  Function()? _englishSlugListener;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    AbstractField.fieldsData.clear();
    AbstractField.files.clear();
    if (widget.isEdit ?? false) {
      item = getCloudData('edit_request') as ItemModel;
      clearCloudData("item_details");
      clearCloudData("with_more_details");
      context.read<FetchCustomFieldsCubit>().fetchCustomFields(
        categoryIds: item!.allCategoryIds!,
      );

      // Set default language values
      adTitleControllers[defaultLangCode] = TextEditingController(
        text: item?.translatedName ?? "",
      );
      adSlugController.text = item?.slug ?? "";
      adDescriptionControllers[defaultLangCode] = TextEditingController(
        text: item?.translatedDescription ?? "",
      );

      // Store translations for later population when languages are available
      print("item?.translations***${item?.translations}");
      if (item?.translations != null) {
        // Store the translations data to populate later
        addCloudData("item_translations", item!.translations);
      }

      adPriceController.text = item?.price?.toString() ?? "";
      minSalaryController.text = item?.minSalary != null
          ? item?.minSalary.toString() ?? ""
          : "";
      maxSalaryController.text = item?.maxSalary != null
          ? item?.maxSalary.toString() ?? ""
          : "";
      adPhoneNumberController.text = item?.contact ?? "";
      adAdditionalDetailsController.text = item?.videoLink ?? "";
      titleImageURL = item?.image ?? "";
      List<String?>? list = item?.galleryImages?.map((e) => e.image).toList();
      mixedItemImageList.addAll([...list ?? []]);
      setState(() {});
    } else {
      List<int> ids = widget.breadCrumbItems!.map((item) => item.id!).toList();
      context.read<FetchCustomFieldsCubit>().fetchCustomFields(
        categoryIds: ids.join(','),
      );
      selectedCategoryList = ids;
      adPhoneNumberController.text = HiveUtils.getUserDetails().mobile ?? "";
      adTitleControllers[HiveUtils.getLanguage()['code']] =
          TextEditingController();
    }

    // --- Slug auto-generation logic ---
    // Will be set up in build() after languages are loaded

    _pickTitleImage.listener((p0) {
      titleImageURL = "";
      WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
        if (mounted) setState(() {});
      });
    });

    itemImagePicker.listener((images) {
      try {
        mixedItemImageList.addAll(List<dynamic>.from(images));
      } catch (e) {}

      setState(() {});
    });
  }

  @override
  void dispose() {
    adSlugController.dispose();
    adPriceController.dispose();
    adPhoneNumberController.dispose();
    adAdditionalDetailsController.dispose();
    minSalaryController.dispose();
    maxSalaryController.dispose();
    _tabController?.dispose();

    for (final controller in [
      ...adDescriptionControllers.values,
      ...adTitleControllers.values,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  void updateSlug() {
    String title = adTitleControllers[HiveUtils.getLanguage()['code']]!.text;
    String slug = generateSlug(title);
    adSlugController.text = slug;
    setState(() {});
  }

  String generateSlug(String title) {
    // Convert the title to lowercase
    String slug = title.toLowerCase();

    // Replace spaces with dashes
    slug = slug.replaceAll(' ', '-');

    // Remove invalid characters
    slug = slug.replaceAll(RegExp(r'[^a-z0-9\-]'), '');

    return slug;
  }

  bool isJobCategory() {
    return (widget.isEdit ?? false) && item!.category!.isJobCategory == 1 ||
        widget.breadCrumbItems != null &&
            widget.breadCrumbItems!.isNotEmpty &&
            widget.breadCrumbItems![0].isJobCategory == 1;
  }

  bool isPriceOptional() {
    return (widget.isEdit ?? false) && item!.category!.priceOptional == 1 ||
        widget.breadCrumbItems != null &&
            widget.breadCrumbItems!.isNotEmpty &&
            widget.breadCrumbItems![0].priceOptional == 1;
  }

  @override
  Widget build(BuildContext context) {
    languages =
        context.watch<FetchSystemSettingsCubit>().getSetting(
              SystemSetting.language,
            )
            as List? ??
        [];
    // Set defaultLangCode from system settings
    defaultLangCode = context.watch<FetchSystemSettingsCubit>().getSetting(
      SystemSetting.defaultLanguage,
    );

    // Ensure default language is first in the list (case-insensitive)
    if (languages.isNotEmpty &&
        (languages[0]['code']?.toString().toLowerCase() ?? '') !=
            (defaultLangCode.toLowerCase())) {
      final defIndex = languages.indexWhere(
        (l) =>
            (l['code']?.toString().toLowerCase() ?? '') ==
            defaultLangCode.toLowerCase(),
      );
      if (defIndex > 0) {
        final defLang = languages.removeAt(defIndex);
        languages.insert(0, defLang);
      }
    }
    if (languages.isEmpty) {
      return Center(child: Text('No languages available'));
    }
    _tabController ??= TabController(
      length: languages.length,
      vsync: this,
      initialIndex: 0,
    );
    // Initialize controllers for each language
    for (var lang in languages) {
      adTitleControllers[lang['code']] ??= TextEditingController();
      adDescriptionControllers[lang['code']] ??= TextEditingController();
    }

    // --- Slug auto-generation from English title ---
    final englishLang = languages.firstWhere(
      (lang) => (lang['code']?.toString().toLowerCase() ?? '') == 'en',
      orElse: () => null,
    );
    final isEnglishPresent = englishLang != null;
    if (isEnglishPresent) {
      final englishCode = englishLang['code'];
      // Remove previous listeners to avoid duplicates
      adTitleControllers[englishCode]!.removeListener(
        _englishSlugListener ?? () {},
      );
      _englishSlugListener = () {
        String title = adTitleControllers[englishCode]!.text;
        String slug = generateSlug(title);
        adSlugController.text = slug;
        setState(() {});
      };
      adTitleControllers[englishCode]!.addListener(_englishSlugListener!);
    }

    // Populate translations if in edit mode and not yet populated
    if ((widget.isEdit ?? false) && !_translationsPopulated) {
      if (item?.translations != null &&
          (item!.translations as List).isNotEmpty) {
        for (var lang in languages) {
          final langCode = lang['code'];
          final langId = lang['id'];
          var translation = (item!.translations as List).firstWhere(
            (t) => t is Map<String, dynamic> && t['language_id'] == langId,
            orElse: () => null,
          );
          if (translation != null && translation is Map<String, dynamic>) {
            adTitleControllers[langCode]?.text =
                translation['name'] ?? (item?.translatedName ?? "");
            adDescriptionControllers[langCode]?.text =
                translation['description'] ??
                (item?.translatedDescription ?? "");
          } else {
            // Fallback to default
            adTitleControllers[langCode]?.text = item?.name ?? "";
            adDescriptionControllers[langCode]?.text = item?.description ?? "";
          }
        }
        _translationsPopulated = true;
      } else {
        // If translations is blank, fill all with default, but ensure default language is always set
        for (var lang in languages) {
          final langCode = lang['code'];
          if (langCode == defaultLangCode) {
            adTitleControllers[langCode]?.text = item?.translatedName ?? "";
            adDescriptionControllers[langCode]?.text =
                item?.translatedDescription ?? "";
          } else {
            adTitleControllers[langCode]?.text = "";
            adDescriptionControllers[langCode]?.text = "";
          }
        }
        _translationsPopulated = true;
      }
    }

    String selectedLangCode = languages[selectedLangIndex]['code'];
    bool isDefault = selectedLangCode == defaultLangCode;

    return AnnotatedSafeArea(
      isAnnotated: true,
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          return;
        },
        child: Scaffold(
          appBar: UiUtils.buildAppBar(
            context,
            showBackButton: true,
            title: "AdDetails".translate(context),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (languages.length > 1)
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: soldOutButtonColor,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: CustomText(
                            (_formKey.currentState?.validate() ?? false
                                    ? "allRequiredDefaultLangFilled"
                                    : "pleaseFillDefaultLangRequiredMsg")
                                .translate(context),
                            color: soldOutButtonColor,
                            fontSize: context.font.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Container(
                color: Colors.transparent,
                child: UiUtils.buildButton(
                  context,
                  outerPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      List<File>? galleryImages = mixedItemImageList
                          .where(
                            (element) => element != null && element is File,
                          )
                          .map((element) => element as File)
                          .toList();

                      // Build translations map for name and description (as strings, all language IDs present)
                      Map<String, Map<String, String>> translations = {};

                      for (var lang in languages) {
                        final langId = lang['id'].toString(); // e.g., "1", "2"
                        final langCode = lang['code']; // e.g., "en", "fr"

                        if (langCode == defaultLangCode)
                          continue; // Skip default language

                        final name =
                            adTitleControllers[langCode]?.text.trim() ?? '';
                        final description =
                            adDescriptionControllers[langCode]?.text.trim() ??
                            '';

                        final langTranslations = <String, String>{};

                        if (name.isNotEmpty) {
                          langTranslations['name'] = name;
                        }
                        if (description.isNotEmpty) {
                          langTranslations['description'] = description;
                        }

                        if (langTranslations.isNotEmpty) {
                          translations[langId] = langTranslations;
                        }
                      }

                      print("translations***$translations");

                      if (_pickTitleImage.pickedFile == null &&
                          titleImageURL == "") {
                        UiUtils.showBlurredDialoge(
                          context,
                          dialoge: BlurredDialogBox(
                            title: "imageRequired".translate(context),
                            content: CustomText(
                              "selectImageYourItem".translate(context),
                            ),
                          ),
                        );
                        return;
                      }
                      addCloudData("item_details", {
                        "name": adTitleControllers[defaultLangCode]!.text,
                        "slug": adSlugController.text,
                        "description":
                            adDescriptionControllers[defaultLangCode]!.text,
                        if (widget.isEdit != true)
                          "category_id": selectedCategoryList.last,
                        if (widget.isEdit ?? false) "id": item?.id,
                        "price": adPriceController.text,
                        "contact": adPhoneNumberController.text,
                        "video_link": adAdditionalDetailsController.text,
                        if (widget.isEdit ?? false)
                          "delete_item_image_id": deleteItemImageList.join(','),
                        "all_category_ids": (widget.isEdit ?? false)
                            ? item!.allCategoryIds
                            : selectedCategoryList.join(','),
                        if (isJobCategory())
                          "min_salary": minSalaryController.text,
                        if (isJobCategory())
                          "max_salary": maxSalaryController.text,
                        "translations": json.encode(translations),
                      });

                      screenStack++;
                      if (context.read<FetchCustomFieldsCubit>().isEmpty()!) {
                        addDataToCloud("with_more_details");

                        Navigator.pushNamed(
                          context,
                          Routes.confirmLocationScreen,
                          arguments: {
                            "isEdit": widget.isEdit,
                            "mainImage": _pickTitleImage.pickedFile,
                            "otherImage": galleryImages,
                          },
                        );
                      } else {
                        Navigator.pushNamed(
                          context,
                          Routes.addMoreDetailsScreen,
                          arguments: {
                            "context": context,
                            "isEdit": widget.isEdit == true,
                            "mainImage": _pickTitleImage.pickedFile,
                            "otherImage": galleryImages,
                          },
                        ).then((value) {
                          screenStack--;
                        });
                      }
                    }
                  },
                  height: 48,
                  fontSize: context.font.large,
                  buttonTitle: "next".translate(context),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (languages.length > 1)
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: context.color.territoryColor,
                      unselectedLabelColor: context.color.textColorDark
                          .withValues(alpha: 0.5),
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
                          _formKey.currentState?.reset();
                        });
                      },
                      tabs: languages.map((lang) {
                        final isDef = lang['code'] == defaultLangCode;
                        return Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(lang['name']),
                              if (isDef &&
                                  (_formKey.currentState?.validate() ??
                                      false)) ...[
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
                  SizedBox(height: 18),
                  CustomText(
                    "youAreAlmostThere".translate(context),
                    fontSize: context.font.large,
                    fontWeight: FontWeight.w600,
                    color: context.color.textColorDark,
                  ),
                  SizedBox(height: 16),
                  if (widget.breadCrumbItems != null)
                    SizedBox(
                      height: 20,
                      width: context.screenWidth,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            bool isNotLast =
                                (widget.breadCrumbItems!.length - 1) != index;
                            return Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    _onBreadCrumbItemTap(index);
                                  },
                                  child: CustomText(
                                    widget.breadCrumbItems![index].name!,
                                    color: isNotLast
                                        ? context.color.textColorDark
                                        : context.color.territoryColor,
                                    firstUpperCaseWidget: true,
                                  ),
                                ),
                                if (index < widget.breadCrumbItems!.length - 1)
                                  CustomText(
                                    " > ",
                                    color: context.color.territoryColor,
                                  ),
                              ],
                            );
                          },
                          itemCount: widget.breadCrumbItems!.length,
                        ),
                      ),
                    ),
                  SizedBox(height: 18),
                  CustomText(
                    isDefault
                        ? "adTitle*".translate(context)
                        : "adTitle (${languages[selectedLangIndex]['name']})"
                              .translate(context),
                  ),
                  SizedBox(height: 10),
                  CustomTextFormField(
                    controller: adTitleControllers[selectedLangCode],
                    validator: isDefault
                        ? CustomTextFieldValidator.nullCheck
                        : null,
                    action: TextInputAction.next,
                    capitalization: TextCapitalization.sentences,
                    hintText: isDefault
                        ? "adTitleHere".translate(context)
                        : "adTitleHere (${languages[selectedLangIndex]['name']})"
                              .translate(context),
                    hintTextStyle: TextStyle(
                      color: context.color.textDefaultColor.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: context.font.normal,
                    ),
                  ),
                  SizedBox(height: 15),
                  CustomText(
                    isDefault
                        ? "descriptionLbl*".translate(context)
                        : "descriptionLbl (${languages[selectedLangIndex]['name']})"
                              .translate(context),
                  ),
                  SizedBox(height: 15),
                  CustomTextFormField(
                    controller: adDescriptionControllers[selectedLangCode],
                    validator: isDefault
                        ? CustomTextFieldValidator.nullCheck
                        : null,
                    action: TextInputAction.newline,
                    capitalization: TextCapitalization.sentences,
                    hintText: isDefault
                        ? "writeSomething".translate(context)
                        : "writeSomething (${languages[selectedLangIndex]['name']})"
                              .translate(context),
                    maxLine: 100,
                    minLine: 6,
                    hintTextStyle: TextStyle(
                      color: context.color.textDefaultColor.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: context.font.normal,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      CustomText("mainPicture".translate(context)),
                      const SizedBox(width: 3),
                      CustomText(
                        "maxSize".translate(context),
                        fontStyle: FontStyle.italic,
                        fontSize: context.font.small,
                      ),
                    ],
                  ),
                  CustomText(
                    "recommendedSize".translate(context),
                    fontStyle: FontStyle.italic,
                    fontSize: context.font.small,
                    color: context.color.textLightColor.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: 10),
                  Wrap(children: [...[], titleImageListener()]),
                  SizedBox(height: 10),
                  Row(
                    spacing: 3,
                    children: [
                      CustomText("otherPictures".translate(context)),
                      CustomText(
                        "max5Images".translate(context),
                        fontStyle: FontStyle.italic,
                        fontSize: context.font.small,
                      ),
                    ],
                  ),
                  CustomText(
                    "recommendedSize".translate(context),
                    fontStyle: FontStyle.italic,
                    fontSize: context.font.small,
                    color: context.color.textLightColor.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: 10),
                  itemImagesListener(),
                  SizedBox(height: 10),
                  CustomText(
                    isJobCategory()
                        ? "salary".translate(context)
                        : "price".translate(context),
                  ),
                  SizedBox(height: 10),
                  isJobCategory()
                      ? buildSalaryRange()
                      : CustomTextFormField(
                          controller: adPriceController,
                          action: TextInputAction.next,
                          fixedPrefix: ConstrainedBox(
                            constraints: BoxConstraints.tight(Size.square(24)),
                            child: Center(
                              child: CustomText(
                                Constant.currencySymbol,
                                fontSize: context.font.large,
                                color: context.color.textDefaultColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          formaters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d*'),
                            ),
                          ],
                          keyboard: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: isPriceOptional()
                              ? null
                              : CustomTextFieldValidator.nullCheck,
                          hintText: "0",
                          hintTextStyle: TextStyle(
                            color: context.color.textDefaultColor.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: context.font.normal,
                          ),
                        ),
                  SizedBox(height: 10),
                  CustomText("phoneNumber".translate(context)),
                  SizedBox(height: 10),
                  CustomTextFormField(
                    controller: adPhoneNumberController,
                    action: TextInputAction.next,
                    formaters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                    keyboard: TextInputType.phone,
                    validator: CustomTextFieldValidator.phoneNumber,
                    hintText: "phoneNumberAddHint".translate(context),
                    hintTextStyle: TextStyle(
                      color: context.color.textDefaultColor.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: context.font.normal,
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomText("videoLink".translate(context)),
                  SizedBox(height: 10),
                  CustomTextFormField(
                    controller: adAdditionalDetailsController,
                    validator: CustomTextFieldValidator.url,
                    hintText: "videoUrlAddHint".translate(context),
                    hintTextStyle: TextStyle(
                      color: context.color.textDefaultColor.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: context.font.normal,
                    ),
                  ),
                  SizedBox(height: 15),
                  CustomText(
                    "${"adSlug".translate(context)}\t(${"englishOnlyLbl".translate(context)})",
                  ),
                  SizedBox(height: 10),
                  CustomTextFormField(
                    controller: adSlugController,
                    onChange: (value) {
                      String slug = generateSlug(value);
                      adSlugController.value = TextEditingValue(
                        text: slug,
                        selection: TextSelection.fromPosition(
                          TextPosition(offset: slug.length),
                        ),
                      );
                    },
                    validator: CustomTextFieldValidator.slug,
                    action: TextInputAction.next,
                    hintText: "adSlugHere".translate(context),
                    hintTextStyle: TextStyle(
                      color: context.color.textDefaultColor.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: context.font.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onBreadCrumbItemTap(int index) {
    int popTimes = (widget.breadCrumbItems!.length - 1) - index;
    int current = index;
    int length = widget.breadCrumbItems!.length;

    for (int i = length - 1; i >= current + 1; i--) {
      widget.breadCrumbItems!.removeAt(i);
    }

    for (int i = 0; i < popTimes; i++) {
      Navigator.pop(context);
    }
    setState(() {});
  }

  Future<void> showImageSourceDialog(
    BuildContext context,
    Function(ImageSource) onSelected,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText('selectImageSource'.translate(context)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: CustomText('camera'.translate(context)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelected(ImageSource.camera);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: CustomText('gallery'.translate(context)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelected(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget titleImageListener() {
    return _pickTitleImage.listenChangesInUI((context, List<File>? files) {
      Widget currentWidget = Container();
      File? file = files?.isNotEmpty == true ? files![0] : null;

      if (titleImageURL.isNotEmpty) {
        currentWidget = GestureDetector(
          onTap: () {
            UiUtils.showFullScreenImage(
              context,
              provider: NetworkImage(titleImageURL),
            );
          },
          child: Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.all(5),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: UiUtils.getImage(titleImageURL, fit: BoxFit.cover),
          ),
        );
      }

      if (file != null) {
        currentWidget = GestureDetector(
          onTap: () {
            UiUtils.showFullScreenImage(context, provider: FileImage(file));
          },
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.all(5),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.file(file, fit: BoxFit.cover),
              ),
            ],
          ),
        );
      }

      return Wrap(
        children: [
          if (file == null && titleImageURL.isEmpty)
            DottedBorder(
              color: context.color.textLightColor,
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: GestureDetector(
                onTap: () {
                  showImageSourceDialog(context, (source) {
                    _pickTitleImage.resumeSubscription();
                    _pickTitleImage.pick(
                      pickMultiple: false,
                      context: context,
                      source: source,
                    );
                    _pickTitleImage.pauseSubscription();
                    titleImageURL = "";
                    setState(() {});
                  });
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: AlignmentDirectional.center,
                  height: 48,
                  child: CustomText(
                    "addMainPicture".translate(context),
                    color: context.color.textDefaultColor,
                    fontSize: context.font.normal,
                  ),
                ),
              ),
            ),
          Stack(
            children: [
              currentWidget,
              closeButton(context, () {
                _pickTitleImage.clearImage();
                titleImageURL = "";
                setState(() {});
              }),
            ],
          ),
          if (file != null || titleImageURL.isNotEmpty)
            uploadPhotoCard(
              context,
              onTap: () {
                showImageSourceDialog(context, (source) {
                  _pickTitleImage.resumeSubscription();
                  _pickTitleImage.pick(
                    pickMultiple: false,
                    context: context,
                    source: source,
                  );
                  _pickTitleImage.pauseSubscription();
                  titleImageURL = "";
                  setState(() {});
                });
              },
            ),
        ],
      );
    });
  }

  Widget itemImagesListener() {
    return itemImagePicker.listenChangesInUI((context, files) {
      Widget current = Container();

      current = Wrap(
        children: List.generate(mixedItemImageList.length, (index) {
          final image = mixedItemImageList[index];
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  HelperUtils.unfocus();
                  if (image is String) {
                    UiUtils.showFullScreenImage(
                      context,
                      provider: NetworkImage(image),
                    );
                  } else {
                    UiUtils.showFullScreenImage(
                      context,
                      provider: FileImage(image),
                    );
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.all(5),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ImageAdapter(image: image),
                ),
              ),
              closeButton(context, () {
                if (image is String) {
                  final matchingIndex = item!.galleryImages!.indexWhere(
                    (galleryImage) => galleryImage.image == image,
                  );

                  if (matchingIndex != -1) {
                    deleteItemImageList.add(
                      item!.galleryImages![matchingIndex].id!,
                    );

                    setState(() {});
                  } else {}
                }

                mixedItemImageList.removeAt(index);
                setState(() {});
              }),
            ],
          );
        }),
      );

      return Wrap(
        runAlignment: WrapAlignment.start,
        children: [
          if ((files == null || files.isEmpty) && mixedItemImageList.isEmpty)
            DottedBorder(
              color: context.color.textLightColor,
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: GestureDetector(
                onTap: () {
                  showImageSourceDialog(context, (source) {
                    itemImagePicker.pick(
                      pickMultiple: source == ImageSource.gallery,
                      context: context,
                      imageLimit: 5,
                      maxLength: mixedItemImageList.length,
                      source: source,
                    );
                  });
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: AlignmentDirectional.center,
                  height: 48,
                  child: CustomText(
                    "addOtherPicture".translate(context),
                    color: context.color.textDefaultColor,
                    fontSize: context.font.normal,
                  ),
                ),
              ),
            ),
          current,
          if (mixedItemImageList.length < 5)
            if (files != null && files.isNotEmpty ||
                mixedItemImageList.isNotEmpty)
              uploadPhotoCard(
                context,
                onTap: () {
                  showImageSourceDialog(context, (source) {
                    itemImagePicker.pick(
                      pickMultiple: source == ImageSource.gallery,
                      context: context,
                      imageLimit: 5,
                      maxLength: mixedItemImageList.length,
                      source: source,
                    );
                  });
                },
              ),
        ],
      );
    });
  }

  Widget closeButton(BuildContext context, Function onTap) {
    return PositionedDirectional(
      top: 6,
      end: 6,
      child: GestureDetector(
        onTap: () {
          onTap.call();
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.color.primaryColor.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(
              Icons.close,
              size: 24,
              color: context.color.textDefaultColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget uploadPhotoCard(BuildContext context, {required Function onTap}) {
    return GestureDetector(
      onTap: () {
        onTap.call();
      },
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.all(5),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: DottedBorder(
          color: context.color.textColorDark.withValues(alpha: 0.5),
          borderType: BorderType.RRect,
          radius: const Radius.circular(10),
          child: Container(
            alignment: AlignmentDirectional.center,
            child: CustomText("uploadPhoto".translate(context)),
          ),
        ),
      ),
    );
  }

  Widget buildSalaryRange() {
    return Row(
      children: <Widget>[
        Expanded(
          child: CustomTextFormField(
            controller: minSalaryController,
            action: TextInputAction.next,
            prefix: CustomText("${Constant.currencySymbol} "),
            formaters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
            keyboard: TextInputType.number,
            hintText: "minLbl".translate(context),
            hintTextStyle: TextStyle(
              color: context.color.textDefaultColor.withValues(alpha: 0.5),
              fontSize: context.font.normal,
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: CustomTextFormField(
            controller: maxSalaryController,
            action: TextInputAction.next,
            prefix: CustomText("${Constant.currencySymbol} "),
            formaters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
            keyboard: TextInputType.number,
            hintText: "maxLbl".translate(context),
            hintTextStyle: TextStyle(
              color: context.color.textDefaultColor.withValues(alpha: 0.5),
              fontSize: context.font.normal,
            ),
          ),
        ),
      ],
    );
  }

  void addDataToCloud(String key) {
    addCloudData(key, {
      "name": adTitleControllers[defaultLangCode]!.text,
      "slug": adSlugController.text,
      "description": adDescriptionControllers[defaultLangCode]!.text,
      if (widget.isEdit != true) "category_id": selectedCategoryList.last,
      if (widget.isEdit ?? false) "id": item?.id,
      "price": adPriceController.text,
      "contact": adPhoneNumberController.text,
      "video_link": adAdditionalDetailsController.text,
      if (widget.isEdit ?? false)
        "delete_item_image_id": deleteItemImageList.join(','),
      "all_category_ids": (widget.isEdit ?? false)
          ? item!.allCategoryIds
          : selectedCategoryList.join(','),
      if (isJobCategory()) "min_salary": minSalaryController.text,
      if (isJobCategory()) "max_salary": maxSalaryController.text,
    });
  }
}

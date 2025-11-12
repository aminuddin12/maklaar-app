import 'package:com.maklaar.app/ui/screens/ad_details_screen.dart';
import 'package:com.maklaar.app/ui/screens/advertisement/my_advertisment_screen.dart';
import 'package:com.maklaar.app/ui/screens/auth/login/forgot_password.dart';
import 'package:com.maklaar.app/ui/screens/auth/login/login_screen.dart';
import 'package:com.maklaar.app/ui/screens/auth/sign_up/mobile_signup_screen.dart';
import 'package:com.maklaar.app/ui/screens/auth/sign_up/signup_main_screen.dart';
import 'package:com.maklaar.app/ui/screens/auth/sign_up/signup_screen.dart';
import 'package:com.maklaar.app/ui/screens/blogs/blog_details.dart';
import 'package:com.maklaar.app/ui/screens/blogs/blogs_screen.dart';
import 'package:com.maklaar.app/ui/screens/chat/blocked_user_list_screen.dart';
import 'package:com.maklaar.app/ui/screens/faqs_screen.dart';
import 'package:com.maklaar.app/ui/screens/favorite_screen.dart';
import 'package:com.maklaar.app/ui/screens/filter_screen.dart';
import 'package:com.maklaar.app/ui/screens/home/category_list.dart';
import 'package:com.maklaar.app/ui/screens/home/change_language_screen.dart';
import 'package:com.maklaar.app/ui/screens/home/search_screen.dart';
import 'package:com.maklaar.app/ui/screens/home/widgets/categoryFilterScreen.dart';
import 'package:com.maklaar.app/ui/screens/home/widgets/posted_since_filter.dart';
import 'package:com.maklaar.app/ui/screens/home/widgets/sub_category_filter.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/add_item_details.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/confirm_location_screen.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/more_details.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/select_category.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/widgets/pdf_viewer.dart';
import 'package:com.maklaar.app/ui/screens/item/add_item_screen/widgets/success_item_screen.dart';
import 'package:com.maklaar.app/ui/screens/item/items_list.dart';
import 'package:com.maklaar.app/ui/screens/item/job_application/job_application_form.dart';
import 'package:com.maklaar.app/ui/screens/item/job_application/job_application_list_screen.dart';
import 'package:com.maklaar.app/ui/screens/item/my_items_screen.dart';
import 'package:com.maklaar.app/ui/screens/item/section_wise_item_screen.dart';
import 'package:com.maklaar.app/ui/screens/location/location_screen.dart';
import 'package:com.maklaar.app/ui/screens/location/widgets/location_map_picker.dart';
import 'package:com.maklaar.app/ui/screens/location_permission_screen.dart';
import 'package:com.maklaar.app/ui/screens/main_activity.dart';
import 'package:com.maklaar.app/ui/screens/my_review_screen.dart';
import 'package:com.maklaar.app/ui/screens/onboarding/onboarding_screen.dart';
import 'package:com.maklaar.app/ui/screens/seller/seller_intro_verification.dart';
import 'package:com.maklaar.app/ui/screens/seller/seller_profile.dart';
import 'package:com.maklaar.app/ui/screens/seller/seller_verification.dart';
import 'package:com.maklaar.app/ui/screens/seller/seller_verification_complete.dart';
import 'package:com.maklaar.app/ui/screens/settings/contact_us.dart';
import 'package:com.maklaar.app/ui/screens/settings/notification_detail.dart';
import 'package:com.maklaar.app/ui/screens/settings/notifications.dart';
import 'package:com.maklaar.app/ui/screens/settings/setting_pages.dart';
import 'package:com.maklaar.app/ui/screens/sold_out_bought_screen.dart';
import 'package:com.maklaar.app/ui/screens/splash_screen.dart';
import 'package:com.maklaar.app/ui/screens/sub_category/sub_category_screen.dart';
import 'package:com.maklaar.app/ui/screens/subscription/packages_list.dart';
import 'package:com.maklaar.app/ui/screens/subscription/transaction_history_screen.dart';
import 'package:com.maklaar.app/ui/screens/user_profile/edit_profile.dart';
import 'package:com.maklaar.app/ui/screens/widgets/maintenance_mode.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/hive_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Class containing all route names and navigation logic
class Routes {
  /// Authentication Routes
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String forgotPassword = 'forgotPassword';
  static const String signup = 'signup';
  static const String signupMainScreen = 'signUpMainScreen';
  static const String mobileSignUp = 'mobileSignUp';
  static const String completeProfile = 'complete_profile';

  /// Main Navigation Routes
  static const String main = 'main';
  static const String home = 'Home';
  static const String categories = 'Categories';
  static const String itemsList = 'itemsList';
  static const String addItem = 'addItem';

  /// Settings & Profile Routes
  static const String contactUs = 'ContactUs';
  static const String profileSettings = 'profileSettings';
  static const String notificationPage = 'notificationpage';
  static const String notificationDetailPage = 'notificationdetailpage';

  /// Feature Routes
  static const String filterScreen = 'filterScreen';
  static const String blogsScreenRoute = 'blogsScreenRoute';
  static const String subscriptionPackageListRoute =
      'subscriptionPackageListRoute';
  static const String maintenanceMode = '/maintenanceMode';
  static const String favoritesScreen = '/favoritescreen';
  static const String blogDetailsScreenRoute = '/blogDetailsScreenRoute';
  static const String myReviewsScreen = '/myReviewsScreenRoute';
  static const String sectionWiseItemsScreen = '/sectionWiseItemsScreen';

  /// Location & Category Routes
  static const String languageListScreenRoute = '/languageListScreenRoute';
  static const String searchScreenRoute = '/searchScreenRoute';
  static const String subCategoryScreen = '/subCategoryScreen';
  static const String categoryFilterScreen = '/categoryFilterScreen';
  static const String subCategoryFilterScreen = '/subCategoryFilterScreen';
  static const String postedSinceFilterScreen = '/postedSinceFilterScreen';
  static const String locationPermissionScreen = '/locationPermissionScreen';

  /// Item Management Routes
  static const String myAdvertisment = '/myAdvertisment';
  static const String transactionHistory = '/transactionHistory';
  static const String myItemScreen = '/myItemScreen';
  static const String pdfViewerScreen = '/pdfViewerScreen';
  static const String adDetailsScreen = '/adDetailsScreen';
  static const String successItemScreen = '/successItemScreen';

  /// Location Management Routes
  static const String locationScreen = '/locationScreen';
  static const String locationMapPicker = '/locationMapPicker';

  /// Seller Routes
  static const String sellerProfileScreen = '/sellerProfileScreen';
  static const String sellerIntroVerificationScreen =
      '/sellerIntroVerificationScreen';
  static const String sellerVerificationScreen = '/sellerVerificationScreen';
  static const String sellerVerificationComplteScreen =
      '/sellerVerificationCompleteScreen';

  /// Item Creation Routes
  static const String selectCategoryScreen = '/selectCategoryScreen';
  static const String selectNestedCategoryScreen =
      '/selectNestedCategoryScreen';
  static const String addItemDetails = '/addItemDetails';
  static const String addMoreDetailsScreen = '/addMoreDetailsScreen';
  static const String confirmLocationScreen = '/confirmLocationScreen';

  /// Other Routes
  static const String faqsScreen = '/faqsScreen';
  static const String soldOutBoughtScreen = '/soldOutBoughtScreen';
  static const String blockedUserListScreen = '/blockedUserListScreen';
  static const String jobApplicationForm = '/jobApplicationForm';
  static const String jobApplicationList = '/jobApplicationList';

  /// Route tracking
  static String currentRoute = '';
  static String previousRoute = '';

  /// Generates routes based on the provided settings
  static Route onGenerateRouted(RouteSettings routeSettings) {
    previousRoute = currentRoute;
    currentRoute = routeSettings.name ?? '';

    // Handle dynamic routes (product-details and seller)
    if (_isDynamicRoute(routeSettings.name)) {
      return _handleDynamicRoute(routeSettings);
    }

    // Handle static routes
    return _handleStaticRoute(routeSettings);
  }

  /// Checks if the route is a dynamic route
  static bool _isDynamicRoute(String? routeName) {
    return routeName?.contains('/ad-details/') == true ||
        routeName?.contains('/seller/') == true;
  }

  /// Handles dynamic routes (product-details and seller)
  static Route _handleDynamicRoute(RouteSettings routeSettings) {
    final uri = Uri.parse(routeSettings.name!);
    final pathSegments = uri.pathSegments;
    final type = pathSegments[0];
    final value = pathSegments[1];

    HiveUtils.setUserSkip();

    if (type == 'ad-details') {
      return _handleProductDetailsRoute(value);
    } else if (type == 'seller') {
      return _handleSellerRoute(value);
    }

    return _defaultRoute();
  }

  /// Handles product details route
  static Route _handleProductDetailsRoute(String value) {
    if (previousRoute.isEmpty) {
      return MaterialPageRoute(builder: (_) => SplashScreen(itemSlug: value));
    }

    if (currentRoute == adDetailsScreen) {
      Constant.navigatorKey.currentState?.pop();
    }

    return AdDetailsScreen.route(RouteSettings(arguments: {"slug": value}));
  }

  /// Handles seller route
  static Route _handleSellerRoute(String value) {
    if (previousRoute.isEmpty) {
      return MaterialPageRoute(builder: (_) => SplashScreen(sellerId: value));
    }

    if (currentRoute == sellerProfileScreen) {
      Constant.navigatorKey.currentState?.pop();
    }

    return SellerProfileScreen.route(
      RouteSettings(arguments: {"sellerId": int.parse(value)}),
    );
  }

  /// Handles static routes
  static Route _handleStaticRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return CupertinoPageRoute(builder: (_) => const OnboardingScreen());
      case main:
        return MainActivity.route(routeSettings);
      case login:
        return LoginScreen.route(routeSettings);
      case forgotPassword:
        return ForgotPasswordScreen.route(routeSettings);
      case signup:
        return SignupScreen.route(routeSettings);
      case signupMainScreen:
        return SignUpMainScreen.route(routeSettings);
      case mobileSignUp:
        return MobileSignUpScreen.route(routeSettings);
      case completeProfile:
        return UserProfileScreen.route(routeSettings);
      case sectionWiseItemsScreen:
        return SectionItemsScreen.route(routeSettings);
      case categories:
        return CategoryList.route(routeSettings);
      case subCategoryScreen:
        return SubCategoryScreen.route(routeSettings);
      case categoryFilterScreen:
        return CategoryFilterScreen.route(routeSettings);
      case subCategoryFilterScreen:
        return SubCategoryFilterScreen.route(routeSettings);
      case postedSinceFilterScreen:
        return PostedSinceFilterScreen.route(routeSettings);
      case maintenanceMode:
        return MaintenanceMode.route(routeSettings);
      case languageListScreenRoute:
        return LanguagesListScreen.route(routeSettings);
      case contactUs:
        return ContactUs.route(routeSettings);
      case locationPermissionScreen:
        return LocationPermissionScreen.route(routeSettings);
      case profileSettings:
        return SettingsPages.route(routeSettings);
      case filterScreen:
        return FilterScreen.route(routeSettings);
      case notificationPage:
        return Notifications.route(routeSettings);
      case notificationDetailPage:
        return NotificationDetail.route(routeSettings);
      case blogsScreenRoute:
        return BlogsScreen.route(routeSettings);
      case successItemScreen:
        return SuccessItemScreen.route(routeSettings);
      case jobApplicationForm:
        return JobApplicationForm.route(routeSettings);
      case jobApplicationList:
        return JobApplicationListScreen.route(routeSettings);
      case blogDetailsScreenRoute:
        return BlogDetails.route(routeSettings);
      case subscriptionPackageListRoute:
        return SubscriptionPackageListScreen.route(routeSettings);
      case favoritesScreen:
        return FavoriteScreen.route(routeSettings);
      case transactionHistory:
        return TransactionHistory.route(routeSettings);
      case blockedUserListScreen:
        return BlockedUserListScreen.route(routeSettings);
      case locationScreen:
        return LocationScreen.route(routeSettings);
      case locationMapPicker:
        return LocationMapPicker.route(routeSettings);
      case myAdvertisment:
        return MyAdvertisementScreen.route(routeSettings);
      case myItemScreen:
        return ItemsScreen.route(routeSettings);
      case searchScreenRoute:
        return SearchScreen.route(routeSettings);
      case itemsList:
        return ItemsList.route(routeSettings);
      case faqsScreen:
        return FaqsScreen.route(routeSettings);
      case selectCategoryScreen:
        return SelectCategoryScreen.route(routeSettings);
      case selectNestedCategoryScreen:
        return SelectNestedCategory.route(routeSettings);
      case addItemDetails:
        return AddItemDetails.route(routeSettings);
      case addMoreDetailsScreen:
        return AddMoreDetailsScreen.route(routeSettings);
      case confirmLocationScreen:
        return ConfirmLocationScreen.route(routeSettings);
      case adDetailsScreen:
        return AdDetailsScreen.route(routeSettings);
      case pdfViewerScreen:
        return PdfViewer.route(routeSettings);
      case soldOutBoughtScreen:
        return SoldOutBoughtScreen.route(routeSettings);
      case sellerProfileScreen:
        return SellerProfileScreen.route(routeSettings);
      case sellerIntroVerificationScreen:
        return SellerIntroVerificationScreen.route(routeSettings);
      case sellerVerificationScreen:
        return SellerVerificationScreen.route(routeSettings);
      case sellerVerificationComplteScreen:
        return SellerVerificationCompleteScreen.route(routeSettings);
      case myReviewsScreen:
        return MyReviewScreen.route(routeSettings);
      default:
        return _defaultRoute();
    }
  }

  /// Returns the default route
  static Route _defaultRoute() {
    return CupertinoPageRoute(builder: (context) => const Scaffold());
  }
}

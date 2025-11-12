import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:com.maklaar.app/settings.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum MessageType {
  success(successMessageColor),
  warning(warningMessageColor),
  error(errorMessageColor);

  final Color value;

  const MessageType(this.value);
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}

class HelperUtils {
  static String checkHost(String url) {
    if (url.endsWith("/")) {
      return url;
    } else {
      return "$url/";
    }
  }

  static Future<void> precacheSVG(List<String> urls) async {
    for (String imageUrl in urls) {
      try {
        var loader = SvgNetworkLoader(imageUrl);
        await svg.cache.putIfAbsent(
          loader.cacheKey(null),
          () => loader.loadBytes(null),
        );
      } on Exception catch (_) {
        break;
      }
    }
  }

  static int comparableVersion(String version) {
    //removing dot from version and parsing it into int
    String plain = version.replaceAll(".", "");

    return int.parse(plain);
  }

  static String nativeDeepLinkUrl(String type, String value) {
    return "https://${AppSettings.shareNavigationWebUrl}/$type/$value?share=true";
  }

  static void shareItem(BuildContext context, String type, String slug) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.backgroundColor,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: CustomText("copylink".translate(context)),
                onTap: () async {
                  String deepLink = nativeDeepLinkUrl(type, slug);

                  await Clipboard.setData(ClipboardData(text: deepLink));

                  Future.delayed(Duration.zero, () {
                    Navigator.pop(context);
                    HelperUtils.showSnackBarMessage(
                      context,
                      "copied".translate(context),
                    );
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: CustomText("share".translate(context)),
                onTap: () async {
                  String deepLink = nativeDeepLinkUrl(type, slug);
                  final box = context.findRenderObject() as RenderBox?;
                  String text =
                      "${"shareDetailsMsg".translate(context)}:\n$deepLink.";
                  await SharePlus.instance.share(
                    ShareParams(
                      text: text,
                      sharePositionOrigin:
                          box!.localToGlobal(Offset.zero) & box.size,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static dynamic showSnackBarMessage(
    BuildContext context,
    String message, {
    int messageDuration = 3,
    MessageType? type,
    bool isFloating = true,
    VoidCallback? onClose,
    SnackBarAction? snackBarAction,
  }) async {
    var snackBar = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(message, color: context.color.secondaryColor),
        behavior: (isFloating) ? SnackBarBehavior.floating : null,
        backgroundColor: type?.value ?? context.color.inverseThemeColor,
        duration: Duration(seconds: messageDuration),
        action: snackBarAction,
      ),
    );
    var snackBarClosedReason = await snackBar.closed;
    if (SnackBarClosedReason.values.contains(snackBarClosedReason)) {
      onClose?.call();
    }
  }

  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    if (bytes == 0) return '0${suffixes[0]}';
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

  static void killPreviousPages(BuildContext context, var nextpage, var args) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(nextpage, (route) => false, arguments: args);
  }

  static void goToNextPage(
    var nextpage,
    BuildContext bcontext,
    bool isreplace, {
    Map? args,
  }) {
    if (isreplace) {
      Navigator.of(bcontext).pushReplacementNamed(nextpage, arguments: args);
    } else {
      Navigator.of(bcontext).pushNamed(nextpage, arguments: args);
    }
  }

  static Widget checkVideoType(
    String url, {
    required Widget Function() onYoutubeVideo,
    required Widget Function() onOtherVideo,
  }) {
    if (isYoutubeVideo(url)) {
      return onYoutubeVideo.call();
    } else {
      return onOtherVideo.call();
    }
  }

  static bool isYoutubeVideo(String url) {
    List youtubeDomains = ["youtu.be", "youtube.com"];

    Uri uri = Uri.parse(url);
    var host = uri.host.toString().replaceAll("www.", "");

    return youtubeDomains.contains(host);
  }

  static Future<File> compressImageFile(File file) async {
    try {
      final int fileSize = await file.length();

      if (fileSize <= Constant.maxSizeInBytes) {
        return file;
      }

      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jp'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

      XFile? result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: Constant.uploadImageQuality,
        rotate: 0,
        keepExif: true,
      );

      return File(result!.path);
    } catch (e) {
      throw Exception("Error compressing image: $e");
    }
  }

  static void launchPathURL({
    required bool isTelephone,
    required bool isSMS,
    required bool isMail,
    required String value,
    required BuildContext context,
  }) async {
    late Uri redirectUri;

    if (isTelephone) {
      redirectUri = Uri.parse("tel:$value");
    } else if (isMail) {
      redirectUri = Uri(
        scheme: 'mailto',
        path: value,
        query:
            'subject=${Constant.appName}&body=${"mailMsgLbl".translate(context)}',
      );
    } else {
      redirectUri = Uri.parse("sms:$value");
    }

    if (await canLaunchUrl(redirectUri)) {
      await launchUrl(redirectUri);
    } else {
      throw 'Could not launch $redirectUri';
    }
  }
}

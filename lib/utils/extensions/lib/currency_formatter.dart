import 'package:com.maklaar.app/utils/constant.dart';
import 'package:intl/intl.dart';

extension NumberFormatter on double {
  String get currencyFormat {
    final formatted = this.decimalFormat;

    return Constant.currencyPositionIsLeft
        ? '${Constant.currencySymbol} $formatted'
        : '$formatted ${Constant.currencySymbol}';
  }

  String get decimalFormat {
    final supportsLocale = NumberFormat.localeExists(Constant.currentLocale);
    final numberFormat = NumberFormat.decimalPatternDigits(
      locale: supportsLocale ? Constant.currentLocale : Intl.defaultLocale,
      decimalDigits: 2,
    );
    return numberFormat.format(this);
  }
}

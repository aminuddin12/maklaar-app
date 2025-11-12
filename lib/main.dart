import 'package:com.maklaar.app/app/app.dart';
import 'package:com.maklaar.app/app/app_localization.dart';
import 'package:com.maklaar.app/app/app_theme.dart';
import 'package:com.maklaar.app/app/register_cubits.dart';
import 'package:com.maklaar.app/app/routes.dart';
import 'package:com.maklaar.app/data/cubits/system/app_theme_cubit.dart';
import 'package:com.maklaar.app/data/cubits/system/language_cubit.dart';
import 'package:com.maklaar.app/ui/screens/chat/chat_audio/globals.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/notification/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => initApp();

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  EntryPointState createState() => EntryPointState();
}

class EntryPointState extends State<EntryPoint> {
  final RegisterCubits _registerCubits = RegisterCubits();
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onBackgroundMessage(
      NotificationService.onBackgroundMessageHandler,
    );
    ChatGlobals.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _registerCubits.providers,
      child: Builder(
        builder: (BuildContext context) {
          return const App();
        },
      ),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    context.read<LanguageCubit>().loadCurrentLanguage();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme currentTheme = context.watch<AppThemeCubit>().state;
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, languageState) {
        return MaterialApp(
          initialRoute: Routes.splash,
          navigatorKey: Constant.navigatorKey,
          title: Constant.appName,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: Routes.onGenerateRouted,
          theme: appThemeData[currentTheme],
          builder: (context, child) {
            TextDirection direction = TextDirection.ltr;

            if (languageState is LanguageLoader) {
              direction = languageState.language['rtl']
                  ? TextDirection.rtl
                  : TextDirection.ltr;
            }
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: Directionality(textDirection: direction, child: child!),
            );
          },
          localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: loadLocalLanguageIfFail(languageState),
        );
      },
    );
  }

  dynamic loadLocalLanguageIfFail(LanguageState state) {
    if ((state is LanguageLoader)) {
      return Locale(state.language['code']);
    } else if (state is LanguageLoadFail) {
      return const Locale("en");
    }
  }
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/new_custom_drawer.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/firebase_options.dart';
import 'package:noted_mobile/pages/account/change_password.dart';
import 'package:noted_mobile/pages/account/forgot_password_screen.dart';
import 'package:noted_mobile/pages/account/login_screen.dart';
import 'package:noted_mobile/pages/account/profile_screen.dart';
import 'package:noted_mobile/pages/account/registration_screen.dart';
import 'package:noted_mobile/pages/account/forgot_password_verification_screen.dart';
import 'package:noted_mobile/pages/account/registration_verification_screen.dart';
import 'package:noted_mobile/pages/groups/group_detail_page.dart';
import 'package:noted_mobile/pages/groups/groups_list_screen.dart';
import 'package:noted_mobile/pages/notes/notes_list_screen.dart';
import 'package:noted_mobile/pages/notes/note_detail_screen.dart';
import 'package:noted_mobile/pages/notifications/notification_page.dart';
import 'package:noted_mobile/pages/home/splash_screen.dart';
import 'package:noted_mobile/utils/language.dart';
import 'package:noted_mobile/utils/noted_theme.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

void main() async {
  init();
  singleton.get<APIHelper>().initApiClient();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    name: "Noted",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  Locale savedLanguage = await LanguagePreferences.loadLanguage();

  runApp(EasyLocalization(
    supportedLocales: LanguagePreferences.languages,
    path: 'assets/translations',
    fallbackLocale: const Locale('fr', 'FRA'),
    startLocale: savedLanguage,
    assetLoader: JsonAssetLoader(),
    child: const ProviderScope(child: _EagerInitialization(child: MyApp())),
  ));
}

class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(internetStatusProvider);
    return child;
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final Color _primaryColor = Colors.grey;
  late StreamSubscription<InternetConnectionStatus> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription =
        InternetConnectionCheckerPlus().onStatusChange.listen((status) {
      setState(() {
        ref.read(internetStatusProvider.notifier).state =
            status == InternetConnectionStatus.connected;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOTED APP',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: _primaryColor,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: notedColorScheme,
        textTheme: notedTextTheme,
        appBarTheme: notedAppBarTheme,
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MyDrawer(),
        '/profile': (context) => const ProfilePage(),
        '/register': (context) => const RegistrationPage(),
        '/register-verification': (context) =>
            const RegistrationVerificationPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/forgot-password-verification': (context) =>
            const ForgotPasswordVerificationPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/latest-files': (context) => const LatestsFilesList(),
        '/groups': (context) => const GroupsListPage(),
        '/group-detail': (context) => const GroupDetailPage(),
        '/note-detail': (context) => const NoteDetail(),
        '/notif': (context) => const NotificationPage(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/custom_drawer.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/pages/change_password.dart';
import 'package:noted_mobile/pages/group_detail_page.dart';
import 'package:noted_mobile/pages/groups_list_screen.dart';
import 'package:noted_mobile/pages/forgot_password_screen.dart';
import 'package:noted_mobile/pages/forgot_password_verification_screen.dart';
import 'package:noted_mobile/pages/latest_files_screen.dart';
import 'package:noted_mobile/pages/login_screen.dart';
import 'package:noted_mobile/pages/note_detail_screen.dart';
import 'package:noted_mobile/pages/notification_page.dart';
import 'package:noted_mobile/pages/profile_screen.dart';
import 'package:noted_mobile/pages/registration_screen.dart';
import 'package:noted_mobile/pages/splash_screen.dart';
import 'package:noted_mobile/data/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  init();
  singleton.get<APIHelper>().initApiClient();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final Color _primaryColor = Colors.grey;
  final Color _accentColor = Colors.black;

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Login UI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: _primaryColor,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(secondary: _accentColor)
              .copyWith(primary: _primaryColor),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const MyCustomDrawer(),
          '/profile': (context) => const ProfilePage(),
          '/register': (context) => const RegistrationPage(),
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/forgot-password-verification': (context) =>
              const ForgotPasswordVerificationPage(),
          '/change-password': (context) => const ChangePasswordPage(),
          '/latest-files': (context) => const LatestFilesList(),
          '/groups': (context) => const GroupsListPage(),
          '/group-detail': (context) => const GroupDetailPage(),
          '/note-detail': (context) => const NoteDetail(),
          '/notif': (context) => const NotificationPage(),
        },
      ),
    );
  }
}

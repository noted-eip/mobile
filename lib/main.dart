import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/new_custom_drawer.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/firebase_options.dart';
import 'package:noted_mobile/pages/account/change_password.dart';
import 'package:noted_mobile/pages/account/forgot_password_screen.dart';
import 'package:noted_mobile/pages/account/login_screen.dart';
import 'package:noted_mobile/pages/account/profile_screen.dart';
import 'package:noted_mobile/pages/account/registration_screen.dart';
import 'package:noted_mobile/pages/account/forgot_password_verification_screen.dart';
import 'package:noted_mobile/pages/groups/group_detail_page.dart';
import 'package:noted_mobile/pages/groups/groups_list_screen.dart';
import 'package:noted_mobile/pages/notes/notes_list_screen.dart';
import 'package:noted_mobile/pages/notes/note_detail_screen.dart';
import 'package:noted_mobile/pages/notifications/notification_page.dart';
import 'package:noted_mobile/pages/home/splash_screen.dart';

void main() async {
  init();
  singleton.get<APIHelper>().initApiClient();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "Noted",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  final Color _primaryColor = Colors.grey;
  final Color _accentColor = Colors.black;

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOTED APP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
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
        '/home': (context) => const MyDrawer(),
        '/profile': (context) => const ProfilePage(),
        '/register': (context) => const RegistrationPage(),
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

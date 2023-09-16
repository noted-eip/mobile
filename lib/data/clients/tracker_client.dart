import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';

class TrackerService {
  ProviderRef<TrackerService> ref;
  TrackerService({required this.ref});

  Future<void> trackPage(TrackPage page) async {
    print("Tracking page: ${page.name}");
    // await ref.read(analyticsProvider).setCurrentScreen(screenName: page.name);
    await ref.read(analyticsProvider).logEvent(
          name: page.name,
        );
  }

  Future<void> trackEvent(TrackEvent event) async {
    await ref.read(analyticsProvider).logEvent(
          name: event.name,
          parameters: event.parameters,
        );
  }
}

enum TrackPage {
  login,
  home,
  profile,
  register,
  forgotPassword,
  forgotPasswordVerification,
  groupDetail,
  groupsList,
  notesList,
  noteDetail,
  notification,
  changePassword,
  test,
}

enum TrackEvent {
  appInstalled,
  appOpened,
}

extension TrackEventExtension on TrackEvent {
  String get name {
    switch (this) {
      case TrackEvent.appInstalled:
        return "app_installed";
      case TrackEvent.appOpened:
        return "app_opened";
      default:
        return "";
    }
  }

  Map<String, dynamic> get parameters {
    switch (this) {
      case TrackEvent.appInstalled:
        return {};
      case TrackEvent.appOpened:
        return {};
      default:
        return {};
    }
  }
}

extension TrackPageExtension on TrackPage {
  String get name {
    switch (this) {
      case TrackPage.login:
        return "login_screen";
      case TrackPage.home:
        return "home_screen";
      case TrackPage.profile:
        return "profile_screen";
      case TrackPage.register:
        return "register_screen";
      case TrackPage.forgotPassword:
        return "forgot_password_screen";
      case TrackPage.forgotPasswordVerification:
        return "forgot_password_verification_screen";
      case TrackPage.groupDetail:
        return "group_detail_screen";
      case TrackPage.groupsList:
        return "groups_list_screen";
      case TrackPage.notesList:
        return "notes_list_screen";
      case TrackPage.noteDetail:
        return "note_detail_screen";
      case TrackPage.notification:
        return "notification_screen";
      case TrackPage.changePassword:
        return "change_password_screen";
      case TrackPage.test:
        return "test_screen";
      default:
        return "unknown_screen";
    }
  }
}

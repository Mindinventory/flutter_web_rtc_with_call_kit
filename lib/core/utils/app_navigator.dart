import 'package:flutter/material.dart';
import '../../features/data/model/notification_payload.dart';
import '../../features/presentation/pages/audio_call_page.dart';
import '../../features/presentation/pages/authentication_page.dart';
import '../../features/presentation/pages/home_page.dart';
import '../../features/presentation/pages/login_page.dart';
import '../../features/presentation/pages/sign_up_page.dart';
import '../../features/presentation/pages/video_call_page.dart';

abstract class AppRoutes {
  static const String authenticationPage = "/";
  static const String loginPage = "/loginPage";
  static const String signUpPage = "/signUpPage";
  static const String homePage = "/homePage";
  static const String audioCallPage = "/audioCallPage";
  static const String videoCallPage = "/videoCallPage";
}

class AppNavigator {
  static Route<dynamic>? materialAppRoutes(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.authenticationPage:
        return _getMaterialPageRoute(
          widget: const AuthenticationPage(),
          settings: settings,
        );

      case AppRoutes.loginPage:
        return _getMaterialPageRoute(
          widget: const LoginPage(),
          settings: settings,
        );

      case AppRoutes.signUpPage:
        return _getMaterialPageRoute(
          widget: const SignUpPage(),
          settings: settings,
        );

      case AppRoutes.homePage:
        return _getMaterialPageRoute(
          widget: const HomePage(),
          settings: settings,
        );

      case AppRoutes.audioCallPage:
        return _getMaterialPageRoute(
          widget:
              AudioCallPage(data: settings.arguments as NotificationPayload),
          settings: settings,
          transparent: true,
        );

      case AppRoutes.videoCallPage:
        return _getMaterialPageRoute(
          widget: VideoCallPage(
            payload: settings.arguments as NotificationPayload,
          ),
          settings: settings,
        );

      default:
        return null;
    }
  }

  static _getMaterialPageRoute({
    required Widget widget,
    required RouteSettings settings,
    bool transparent = false,
  }) {
    return PageRouteBuilder(
      opaque: !transparent,
      settings: settings,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      pageBuilder: (context, animation, secondaryAnimation) => widget,
    );
  }
}

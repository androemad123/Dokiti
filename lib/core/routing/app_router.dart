import 'package:alhy_momken_task/core/routing/routes.dart';
import 'package:alhy_momken_task/features/home/home_screen_state.dart';
import 'package:alhy_momken_task/features/login/ui/login_screen.dart';
import 'package:alhy_momken_task/features/signUp/ui/sign_up_screen.dart';
import 'package:flutter/material.dart';

import '../../features/onboarding/onboarding_screen.dart';

class AppRouter {
  final bool showHome;
  AppRouter({
    required this.showHome,
  });

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.onBoardingScreen:
      // If showHome is true, skip onboarding and go to login
        if (showHome) {
          return MaterialPageRoute(builder: (_) => LoginScreen());
        }
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case Routes.homeScreenState:
        return MaterialPageRoute(builder: (_) => HomeScreenState());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case Routes.signUpScreen:
        return MaterialPageRoute(builder: (_) => SignUpScreen());
      default:
        return null;
    }
  }
}
import 'package:alhy_momken_task/core/routing/routes.dart';
import 'package:alhy_momken_task/features/home/home_screen_state.dart';
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
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case Routes.homeScreenState:
        return MaterialPageRoute(builder: (_) => HomeScreenState());
      default:
        return null;
    }
  }
}

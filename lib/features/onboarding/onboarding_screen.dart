
import 'package:alhy_momken_task/core/theming/styles.dart';
import 'package:alhy_momken_task/features/onboarding/ui/widgets/build_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/routing/routes.dart';
import '../../core/theming/theme_provider.dart';
import '../../core/widgets/app_text_btn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {

  const OnboardingScreen({super.key});


  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.primary,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.only(bottom: 200.h),
            child: PageView(
              onPageChanged: (index) {
                setState(() => isLastPage = index == 2);
              },
              controller: controller,
              children: const [
                BuildPage(
                  imageScale: 1,
                    imageHeight: 351,
                    imageWidth: double.maxFinite,
                    imagePath: 'assets/images/onboardin1.png',
                    title: "Simple way to manage",
                    subtitle:
                    """Create, save, manage your bookmarks, images, link, or documents just in one app.
                    """),
                BuildPage(
                  imageScale: 12,
                    imageHeight: 360,
                    imageWidth: double.maxFinite,
                    imagePath: "assets/images/onboardin2.png",
                    title: "Organize is easy",
                    subtitle:
                    "Say no to mess with grouped folders, add your tags, or just search with advanced filters"),
                BuildPage(
                  imageScale: 1,
                    imageWidth: 360,
                    imageHeight: 340,
                    imagePath: "assets/images/onboardin3.png",
                    title: "Safe and Secure",
                    subtitle:
                    "We believe privacy is a right. We won't sell your data, no ads, ever"),
              ],
            ),
          ),

          // Overlay Bottom Buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 40.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SmoothPageIndicator(
                  controller: controller,
                  count: 3,
                  effect:  ScaleEffect(
                      activeDotColor: Theme.of(context).colorScheme.onPrimary,
                      activeStrokeWidth: 1,
                      dotWidth: 12,
                      dotHeight: 7,
                      scale: 1.5,
                      dotColor: Theme.of(context).colorScheme.secondary,
                      spacing: 10),
                ),
                SizedBox(height: 20.h),
                isLastPage
                    ? Column(
                  children: [
                    AppTextBtn(
                      backGroundColor: Colors.white,
                      borderColor: Theme.of(context).colorScheme.primary,
                      buttonHeight: 56.h,
                      buttonWidth: 300.w,
                      buttonText: "Start",
                      textStyle: MyTextStyle.font16SemiBold(context),
                      onPressed: () async {
                        Navigator.pushReplacementNamed(
                            context, Routes.homeScreenState);
                        final prefs =
                        await SharedPreferences.getInstance();
                        prefs.setBool('showHome', true);
                      },
                      borderRadius: 10,
                    ),
                    SizedBox(height: 20.h),
                    AppTextBtn(
                      backGroundColor: Theme.of(context).colorScheme.secondary,
                      buttonHeight: 56.h,
                      buttonWidth: 300.w,
                      buttonText: "switch",
                      textStyle: MyTextStyle.font16SemiBold(context),
                      onPressed: () {
                        final themeProvider =
                        Provider.of<ThemeProvider>(context, listen: false);
                        themeProvider.toggleTheme(
                            themeProvider.themeMode != ThemeMode.dark);
                      },
                      borderRadius: 10,
                    ),
                  ],
                )
                    : Column(
                  children: [
                    AppTextBtn(
                      backGroundColor: Colors.white,
                      buttonHeight: 56.h,
                      buttonWidth: 300.w,
                      buttonText: "Next",
                      textStyle: MyTextStyle.font16SemiBold(context),
                      onPressed: () => controller.nextPage(
                          curve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 300)),
                    ),
                    SizedBox(height: 20.h),
                    AppTextBtn(
                      backGroundColor: Theme.of(context).colorScheme.secondary,
                      buttonHeight: 56.h,
                      buttonWidth: 300.w,
                      buttonText: "Skip",
                      textStyle: MyTextStyle.font16SemiBold(context),
                      onPressed: () => controller.jumpToPage(2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

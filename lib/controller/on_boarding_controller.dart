import 'package:customer/view/screens/Onboboarding/onboarding_items.dart';
import 'package:customer/view/screens/LandingScreen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  final items = OnboardingItems().items; // Onboarding data
  final pageController = PageController(); // Page controller
  final isLastPage = false.obs; // Reactive last page check

  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding", true);

    // Navigate to HomeContainer
    Get.off(() => const homeContainer(initialPage: 0));
  }

  void onPageChanged(int index) {
    isLastPage.value = items.length - 1 == index;
  }

  void skipToLastPage() {
    pageController.jumpToPage(items.length - 1);
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeIn,
    );
  }
}

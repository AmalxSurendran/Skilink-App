// ignore_for_file: invalid_use_of_protected_member, use_build_context_synchronously

import 'dart:developer';
import 'package:customer/view/screens/Onboboarding/onboarding_view.dart';
import 'package:customer/view/screens/LandingScreen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer/utils/api.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  var profileData = <String, dynamic>{}.obs;
  var isLoading = true.obs;
  var isDeleting = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? customerId = prefs.getString('customer_id');

      if (customerId == null) {
        isLoading.value = false;
        return;
      }

      final response =
          await http.get(Uri.parse('${Api.getProfileDetails}/$customerId'));

      if (response.statusCode == 200) {
        profileData.value = json.decode(response.body);
        log('profile data: ${profileData.value}');
        isLoading.value = false;
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  void updateProfileData(String username) {
    profileData.value['username'] = username;
    profileData.update('username', (_) => username, ifAbsent: () => username);
    update();
  }

  Future<void> deleteUserAccount(BuildContext context) async {
    isDeleting.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? customerId = prefs.getString('customer_id');

      if (customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer ID not found')),
        );
        isDeleting.value = false;
        return;
      }

      final response = await http.patch(
        Uri.parse('${Api.deleteAccount}/$customerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await prefs.remove('customer_id');
        await prefs.remove('logged_in_status');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );

        // Navigate to HomeContainerScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const homeContainer(initialPage: 1)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete account')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login screen and restart
    Get.offAll(() => OnboardingView());
  }
}

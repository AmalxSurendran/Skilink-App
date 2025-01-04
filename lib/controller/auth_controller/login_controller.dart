// ignore_for_file: non_constant_identifier_names, avoid_print, prefer_const_constructors

import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:customer/controller/booking%20controller/booking_controller.dart';
import 'package:customer/controller/home_controller.dart';
import 'package:customer/controller/profile%20controller/profile_controller.dart';
import 'package:customer/view/screens/auth/login.dart';
import 'package:customer/view/screens/LandingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/api.dart';

class AuthLoginController extends GetxController {
  var countryCodes = <Map<String, dynamic>>[].obs;
  var selectedCountryCode = ''.obs;
  var selectedCountryCode_POST = ''.obs;
  var isLoading = false.obs;
  var isObscure = true.obs;
  bool isAlertDialogVisible = false;
  final Connectivity _connectivity = Connectivity();

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initConnectivity();
    _loadCountryCodes();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      return;
    }
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile)) {
      if (isAlertDialogVisible) {
        Get.back(); // Dismiss the alert dialog
        isAlertDialogVisible = false;
      }
    } else {
      if (!isAlertDialogVisible) {
        Get.dialog(
          const AlertDialog(
            title: Text("No Internet Connection"),
            content: Text("Please check your internet connection."),
          ),
        );
        isAlertDialogVisible = true;
      }
    }
  }

  Future<void> _loadCountryCodes() async {
    final url = Api.getCountryCodes;
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        countryCodes.value = data.map((item) {
          return {
            "id": item["id"].toString(),
            "country_name": item["country_name"],
            "country_code_phone": item["country_code_phone"],
          };
        }).toList();
        if (countryCodes.isNotEmpty) {
          selectedCountryCode_POST.value = countryCodes.first['id']!;
          selectedCountryCode.value = countryCodes.first['country_code_phone']!;
        }
      } else {
        throw Exception('Failed to load country codes');
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isObscure.value = !isObscure.value;
  }

  void submit() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (phone.isEmpty) {
      Get.snackbar('Error', 'Phone number is required.');
      return;
    }

    if (!_validatePassword(password)) {
      Get.snackbar('Error', 'Password must meet the complexity requirements.');
      return;
    }

    final formData = {
      'phone': phone,
      'country_code': selectedCountryCode_POST.value,
      'password': password,
    };

    await _sendFormData(formData);
  }

  Future<void> _sendFormData(Map<String, dynamic> formData) async {
    final url = Api.customerLogin;
    isLoading.value = true;
    try {
      final response = await http.post(Uri.parse(url), body: formData);
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('customer_id', responseData['id'].toString());
        await prefs.setInt('logged_in_status', 1);

        // Update and fetch data in HomeController
        HomeController homeController = Get.put(HomeController());
        homeController.isLoggedIn.value = true;
        homeController.fetchData();

        // Notify BookingController about login
        BookingController bookingController = Get.put(BookingController());
        bookingController.isLoggedIn.value = true;
        bookingController.refreshData();

        // Fetch updated profile data
        ProfileController profileController = Get.put(ProfileController());
        await profileController.fetchProfile();

        Get.offAll(() {
          final controller = Get.put(HomeController());
          controller.bottomNavIndex.value = 0; // Reset to Home tab
          return homeContainer(initialPage: 0);
        });
      } else {
        _handleLoginErrors(response.statusCode, responseData);
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Failed to login. Please try again later.');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleLoginErrors(int statusCode, Map<String, dynamic> responseData) {
    switch (statusCode) {
      case 404:
        Get.snackbar('Error', responseData['error'] ?? 'User not found');
        break;
      case 401:
        Get.snackbar('Error', 'Password incorrect');
        break;
      case 403:
        Get.snackbar('Error', 'User is blocked');
        break;
      default:
        Get.snackbar('Error', 'An unexpected error occurred.');
    }
  }

  bool _validatePassword(String password) {
    return password.isNotEmpty;
  }

  Future<void> logout() async {
    try {
      log('Starting logout process');
      final prefs = await SharedPreferences.getInstance();
      log('SharedPreferences keys before clear: ${prefs.getKeys()}');

      await prefs.clear();
      log('SharedPreferences keys after clear: ${prefs.getKeys()}');

      phoneController.clear();
      passwordController.clear();
      selectedCountryCode_POST.value = '';
      selectedCountryCode.value = '';
      log('State variables cleared');

      // Reset controllers
      HomeController homeController = Get.put(HomeController());
      homeController.isLoggedIn.value = false;

      BookingController bookingController = Get.put(BookingController());
      bookingController.isLoggedIn.value = false;

      log('Navigating to OnboardingView');
      Get.offAll(() => AuthLogin());
    } catch (e) {
      log('Logout failed: $e');
      Get.snackbar('Error', 'Failed to logout. Please try again.');
    }
  }
}

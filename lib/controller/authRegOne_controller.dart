// ignore_for_file: avoid_print, non_constant_identifier_names, file_names

import 'dart:convert';
import 'dart:developer';
import 'package:customer/view/screens/auth/authRegotp.dart';
import 'package:get/get.dart';
import 'package:customer/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthregoneController extends GetxController {
  var countryCodes = <Map<String, dynamic>>[].obs;
  var selectedCountryCode = ''.obs;
  var selectedCountryCode_POST = ''.obs;
  var isLoading = true.obs;
  var isAlertDialogVisible = false.obs;
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadCountryCodes();
  }

  Future<void> loadCountryCodes() async {
    final url = Api.getCountryCodes; // Replace with your API URL
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
          selectedCountryCode.value = countryCodes.first['country_code_phone']!;
          selectedCountryCode_POST.value = countryCodes.first['id']!;
        }
        isLoading.value = false;
      } else {
        throw Exception('Failed to load country codes');
      }
    } catch (e) {
      print(e);
      isLoading.value = false;
    }
  }

  // Method to show country code picker
  void showCountryCodePicker() {
    Get.bottomSheet(
      ListView(
        children: countryCodes.map((country) {
          return ListTile(
            title: Text(
                '${country['country_name']} (${country['country_code_phone']})'),
            onTap: () {
              selectedCountryCode.value = country['country_code_phone'];
              selectedCountryCode_POST.value = country['id'];
              Get.back();
            },
          );
        }).toList(),
      ),
    );
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    isLoading.value = true;
    final phone = phoneController.text;
    // If all validations pass, send the data
    final formData = {
      "phone": phone,
      "country_code": selectedCountryCode_POST.value,
    };
    log('Auth reg one: $formData');
    try {
      final response = await http.post(
        Uri.parse(Api.regOne),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(formData),
      );
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final id = responseData['id'];
        log('Auth reg one: $responseData');
        // Save ID to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('tempId', id);
        // Navigate to another screen

        Get.off(() => AuthRegOtp());
      } else if (response.statusCode == 400) {
        // Handle the case where the phone number is already registered
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['error'] ?? 'Phone number already registered';
        showErrorDialog(errorMessage);
      } else {
        // Handle other errors
        showErrorDialog('Failed to create customer');
      }
    } catch (e) {
      showErrorDialog('Error sending formData: $e');
    }

    isLoading.value = false;
  }

  void showErrorDialog(String message) {
    Get.defaultDialog(
      title: 'Error',
      middleText: message,
      textConfirm: 'OK',
      onConfirm: () => Get.back(),
    );
  }
}

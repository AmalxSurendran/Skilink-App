// ignore_for_file: file_names

import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:customer/view/screens/auth/login.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../app/generalImports.dart';
import '../../utils/api.dart';

class ResetPasswordController extends GetxController {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Observables for the state
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;
  var redirectionFlag = true.obs;
  final autoValidate = false.obs;

  bool isAlertDialogVisible = false;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    initConnectivity();
    resetFields();
    clearTextFields();
    clearTextFields(); // Clear text fields when the controller initializes
  }

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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

  // Method to reset the form fields
  void resetFields() {
    password.value = '';
    confirmPassword.value = '';
  }

  // Method to clear text fields
  void clearTextFields() {
    passwordController.text = '';
    confirmPasswordController.text = '';
    update(); // Notify widgets to rebuild with updated values
  }

  // Methods for password validation
  bool containsUppercase(String value) {
    return value.contains(RegExp(r'[A-Z]'));
  }

  bool containsLowercase(String value) {
    return value.contains(RegExp(r'[a-z]'));
  }

  bool containsDigit(String value) {
    return value.contains(RegExp(r'[0-9]'));
  }

  bool containsSpecialCharacter(String value) {
    return value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  //reset password
  Future<void> resetPassword(String newPassword, BuildContext context) async {
    isLoading.value = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerId = prefs.getString('customer_id');

    if (customerId == null) {
      customerId = prefs.getInt('tempId').toString();

      redirectionFlag.value = false;
    }

    var apiUrl = Uri.parse(Api.resetPassword);

    var body = jsonEncode({
      'id': customerId,
      'password': newPassword,
      'password_confirmation': confirmPasswordController.text,
    });

    log('Reset Password: $body');
    var client = http.Client();

    try {
      var response = await client.patch(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        Get.offAll(() => AuthLogin());
        log('Reset password successful:  ${response.body}');
        Get.snackbar('Success', 'Password reset successfully');
      } else {
        log('Failed to reset password. Error: ${response.body}');
        Get.snackbar('Error', 'Failed to reset password');
      }
    } catch (e) {
      log('Error during reset password: $e');
      Get.snackbar('Error', 'An error occurred');
    } finally {
      client.close();

      isLoading.value = false;
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must include at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must include at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must include at least one digit';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must include at least one special character';
    }
    return null;
  }
}

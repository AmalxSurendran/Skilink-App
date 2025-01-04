// ignore_for_file: file_names, avoid_print

import 'dart:developer';
import 'package:customer/app/generalImports.dart';
import 'package:customer/view/screens/auth/resetPasswordScreen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../utils/api.dart';

class ForgetPasswordOTPController extends GetxController {
  var otpControllers = List.generate(6, (index) => TextEditingController()).obs;
  var focusNodes = List.generate(6, (index) => FocusNode()).obs;
  var isLoading = false.obs;

  void submitOTP() async {
    if (!validateOTP()) {
      return;
    }

    String otpData =
        otpControllers.map((controller) => controller.text).join('');

    final prefs = await SharedPreferences.getInstance();
    final int? tempId = prefs.getInt('tempId');

    if (tempId == null) {
      showErrorDialog('Customer ID not found');
      return;
    }

    isLoading.value = true;

    String? ph = prefs.getString('ph');
    final map = <String, dynamic>{};
    map['id'] = tempId.toString();
    map['otp_data'] = otpData;
    map['ph'] = ph;

    try {
      final response = await http.post(
        Uri.parse(Api.verifyPasswordOtp), // Replace with your actual API URL
        body: map,
      );

      print('API Response: ${response.body}'); // Print API response

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final customerId = responseData['id'];

        await prefs.setInt('tempId', customerId);

        // Navigate to the Reset Password screen

        Get.off(() => const ResetPasswordScreen());
      } else {
        print(response.statusCode);
        log(response.body);
        showErrorDialog('Failed to verify OTP');
      }
    } catch (e) {
      showErrorDialog('Error verifying OTP: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool validateOTP() {
    // Validate OTP fields
    for (var controller in otpControllers) {
      if (controller.text.isEmpty) {
        showErrorDialog('Please enter OTP');
        return false;
      }
    }
    return true;
  }

  void showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    for (var node in focusNodes) {
      node.addListener(() {});
    }
  }

  @override
  void onClose() {
    super.onClose();
    for (var node in focusNodes) {
      node.dispose();
    }
  }
}

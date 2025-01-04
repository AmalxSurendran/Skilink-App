// ignore_for_file: file_names, avoid_print

import 'dart:developer';

import 'package:customer/app/generalImports.dart';
import 'package:customer/view/screens/auth/authRegThree.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../utils/api.dart';

class AuthRegOtpController extends GetxController {
  final otpControllers = List.generate(6, (index) => TextEditingController());
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  late List<FocusNode> focusNodes;

  @override
  void onInit() {
    super.onInit();
    focusNodes = List.generate(6, (index) => FocusNode());
  }

  @override
  void onClose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  Future<void> submitOTP() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    String otpData =
        otpControllers.map((controller) => controller.text).join('');
    print('Auth Reg OTP Data: $otpData');

    final prefs = await SharedPreferences.getInstance();
    final int? tempId = prefs.getInt('tempId');

    if (tempId == null) {
      showErrorDialog('Customer ID not found');
      return;
    }

    isLoading.value = true;

    final formData = {
      "id": tempId.toString(),
      "otp_data": otpData,
    };
    print('Auth Reg otp API formData: $formData');
    try {
      final response = await http.post(
        Uri.parse(Api.regTwo),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(formData),
      );

      print('Auth Reg otp API Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('Auth Reg otp Data: $responseData');
        final customerId = responseData['id'];

        prefs.setInt('tempId', customerId);

        Get.off(() => const authRegThree());
      } else {
        print('Failed to verify OTP: ${response.body}');
        showErrorDialog('Failed to verify OTP');
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      showErrorDialog('Error verifying OTP: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showErrorDialog(String message) {
    Get.defaultDialog(
      title: 'Error',
      middleText: message,
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
  }
}

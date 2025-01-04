// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:customer/app/generalImports.dart';
import 'package:customer/controller/auth_controller/authRegOne_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthRegisterOne extends StatelessWidget {
  const AuthRegisterOne({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthregoneController controller = Get.put(AuthregoneController());

    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: whiteColor,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: controller
                      .showCountryCodePicker, // Calling the method here
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          controller.selectedCountryCode.value.isNotEmpty
                              ? controller.selectedCountryCode.value
                              : 'Select Country Code',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required.';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Invalid Phone.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: blackColor),
                  onPressed:
                      controller.isLoading.value ? null : controller.submit,
                  child: Obx(() {
                    return controller.isLoading.value
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CupertinoActivityIndicator(
                                  color: whiteColor, radius: 10),
                              SizedBox(width: 8),
                              Text(
                                'Sending...',
                                style: TextStyle(color: whiteColor),
                              ),
                            ],
                          )
                        : const Text(
                            'Send OTP',
                            style: TextStyle(color: whiteColor),
                          );
                  }),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.5),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'By Registering means you agree with ',
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: const TextStyle(
                                fontSize: 15, color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await launchUrl(
                                    Uri.parse(terms_and_conditions));
                              },
                          ),
                          const TextSpan(
                            text: ' and ',
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                                fontSize: 15, color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await launchUrl(Uri.parse(privacy_policy));
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}

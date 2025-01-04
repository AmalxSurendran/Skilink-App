// ignore_for_file: file_names, non_constant_identifier_names

import 'package:customer/app/generalImports.dart';
import 'package:customer/controller/auth_controller/forgotPassword_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  final controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            title: null,
            backgroundColor: whiteColor,
          ),
          body: controller.isLoading.value
              ? const Center(
                  child: CupertinoActivityIndicator(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Reset Password",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22)),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.bottomSheet(
                              ListView(
                                children:
                                    controller.countryCodes.map((country) {
                                  return ListTile(
                                    title: Text(
                                        '${country['country_name']} (${country['country_code_phone']})'),
                                    onTap: () {
                                      controller.selectedCountryCode.value =
                                          country['country_code_phone'];
                                      controller.selectedCountryCode_POST
                                          .value = country['id'];
                                      Get.back();
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  controller.selectedCountryCode.isNotEmpty
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
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: blackColor),
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.submit,
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
                        SizedBox(height: Get.height * 0.5),
                      ],
                    ),
                  ),
                ),
        ));
  }
}

// ignore_for_file: file_names

import 'package:customer/controller/auth_controller/login_controller.dart';
import 'package:customer/utils/colors.dart';
import 'package:customer/view/screens/auth/authRegOne.dart';
import 'package:customer/view/screens/auth/forgetPassword.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthLogin extends StatelessWidget {
  final controller = Get.put(AuthLoginController());
  AuthLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: null,
        centerTitle: true,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/skilinkmain.png',
                          height: MediaQuery.of(context).size.height * 0.06,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "SkiLink",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView(
                              children: controller.countryCodes.map((country) {
                                return ListTile(
                                  title: Text(
                                    '${country['country_name']} (${country['country_code_phone']})',
                                  ),
                                  onTap: () {
                                    controller.selectedCountryCode.value =
                                        country['country_code_phone'];
                                    controller.selectedCountryCode_POST.value =
                                        country['id'];
                                    Get.back();
                                  },
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: Row(
                          children: [
                            Obx(() => Text(
                                  controller.selectedCountryCode.isNotEmpty
                                      ? controller.selectedCountryCode.value
                                      : 'Select Country Code',
                                  style: const TextStyle(fontSize: 16),
                                )),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller.phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => TextField(
                        controller: controller.passwordController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.vpn_key),
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isObscure.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        obscureText: controller.isObscure.value,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.to(() => ForgotPassword());
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.to(() => const AuthRegisterOne());
                          },
                          child: const Text(
                            'Not registered? Click here',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: blackColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

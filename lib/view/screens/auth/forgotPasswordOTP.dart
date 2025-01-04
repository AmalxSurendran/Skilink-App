// ignore_for_file: file_names

import 'package:customer/app/generalImports.dart';
import 'package:customer/controller/forgotPasswordOTP_controller.dart';
import 'package:get/get.dart';

class ForgetPasswordOTP extends StatelessWidget {
  const ForgetPasswordOTP({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordOTPController());

    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: whiteColor,
      ),
      body: Obx(
        () {
          return controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Enter OTP',
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            6,
                            (index) => SizedBox(
                              width: 50,
                              height: 50,
                              child: TextFormField(
                                controller: controller.otpControllers[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                obscureText: false,
                                maxLength: 1,
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    FocusScope.of(context).requestFocus(
                                        controller.focusNodes[index + 1]);
                                  }
                                },
                                focusNode: controller.focusNodes[index],
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: blackColor),
                          onPressed: controller.submitOTP,
                          child: const Text(
                            'Submit OTP',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: whiteColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}

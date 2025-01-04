// ignore_for_file: file_names

import 'package:customer/controller/username_edit_controller.dart';
import 'package:customer/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditUsernameScreen extends StatelessWidget {
  final String currentUsername;
  final int customerId;

  const EditUsernameScreen(this.currentUsername, this.customerId, {super.key});

  @override
  Widget build(BuildContext context) {
    final EditUsernameController controller = Get.put(EditUsernameController());

    // Set initial username in the controller
    controller.usernameController.value.text = currentUsername;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: const Text('Edit Username', style: TextStyle(color: blackColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(
              () => TextField(
                controller: controller.usernameController.value,
                decoration: InputDecoration(
                  labelText: 'Username',
                  errorText: controller.errorMessage.value,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => controller.isLoading.value
                  ? const CupertinoActivityIndicator()
                  : SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: blackColor),
                        onPressed: () => controller.updateUsername(
                            customerId, currentUsername),
                        child: const Text('Update Username',
                            style: TextStyle(
                                color: whiteColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

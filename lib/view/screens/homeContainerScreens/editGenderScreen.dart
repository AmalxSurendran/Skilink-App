// ignore_for_file: prefer_const_constructors, file_names

import 'package:customer/controller/profile%20controller/gender_edit_controller.dart';
import 'package:customer/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditGenderScreen extends StatelessWidget {
  final int currentGender;
  final int customerId;

  const EditGenderScreen(this.currentGender, this.customerId, {super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize GenderController
    final GenderController genderController = Get.put(GenderController());

    // Set the initial gender value only once when the screen is first built
    genderController.selectedGender.value ??= currentGender;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text('Edit Gender', style: TextStyle(color: blackColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Male Radio Button
            ListTile(
              title: Text('Male', style: TextStyle(fontSize: 14.0)),
              leading: Obx(() {
                return Radio<int>(
                  value: 1,
                  groupValue: genderController.selectedGender.value,
                  onChanged: (int? value) {
                    if (value != null) {
                      genderController.selectedGender.value = value;
                    }
                  },
                );
              }),
            ),
            // Female Radio Button
            ListTile(
              title: Text('Female', style: TextStyle(fontSize: 14.0)),
              leading: Obx(() {
                return Radio<int>(
                  value: 2,
                  groupValue: genderController.selectedGender.value,
                  onChanged: (int? value) {
                    if (value != null) {
                      genderController.selectedGender.value = value;
                    }
                  },
                );
              }),
            ),
            // Other Radio Button
            ListTile(
              title: Text('Other', style: TextStyle(fontSize: 14.0)),
              leading: Obx(() {
                return Radio<int>(
                  value: 3,
                  groupValue: genderController.selectedGender.value,
                  onChanged: (int? value) {
                    if (value != null) {
                      genderController.selectedGender.value = value;
                    }
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            Obx(() {
              return genderController.isLoading.value
                  ? CupertinoActivityIndicator()
                  : SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: blackColor),
                        onPressed: genderController.selectedGender.value != null
                            ? () => genderController.updateGender(customerId)
                            : null,
                        child: Text('Update Gender',
                            style: TextStyle(
                                color: whiteColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    );
            }),
            Obx(() {
              if (genderController.errorMessage.value != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    genderController.errorMessage.value!,
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              return SizedBox();
            }),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: file_names

import 'package:customer/controller/address_add_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';

class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(AddAddressController()); // Initialize the controller

    return Scaffold(
      backgroundColor: lightPrimaryColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                controller: controller.addressLineController,
                decoration: const InputDecoration(labelText: 'Address Line'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => controller.getCountryList(),
                child: AbsorbPointer(
                  child: Obx(
                    () => TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: controller.selectedCountryName.value,
                          selection: TextSelection.collapsed(
                              offset:
                                  controller.selectedCountryName.value.length),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please select country';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (controller.selectedCountryId.value.isNotEmpty) {
                    controller
                        .getStatesByCountry(controller.selectedCountryId.value);
                  } else {
                    Get.snackbar('Error', 'Please select a country first');
                  }
                },
                child: AbsorbPointer(
                  child: Obx(
                    () => TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'State',
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: controller.selectedStateName.value,
                          selection: TextSelection.collapsed(
                              offset:
                                  controller.selectedStateName.value.length),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please select state';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter pincode';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.districtController,
                decoration: const InputDecoration(labelText: 'District'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter district';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Obx(
                () => controller.isLoading.value
                    ? const Center(child: CupertinoActivityIndicator())
                    : ElevatedButton(
                        onPressed: controller.submitForm,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: blackColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          textStyle: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 5.0,
                        ),
                        child: const Text('Save Address'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

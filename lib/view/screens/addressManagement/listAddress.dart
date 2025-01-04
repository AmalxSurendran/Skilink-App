// ignore_for_file: file_names

import 'package:customer/controller/address_list_controller.dart';
import 'package:customer/view/screens/addressManagement/addAddress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/utils/colors.dart';

class ListAddress extends StatelessWidget {
  const ListAddress({super.key});

  @override
  Widget build(BuildContext context) {
    final ListAddressController controller = Get.put(ListAddressController());

    return Scaffold(
      backgroundColor: lightPrimaryColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: whiteColor,
        title: null,
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (controller.addresses.isEmpty) {
            return const Center(child: Text('No Address available'));
          }

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'My Addresses',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.addresses.length,
                  itemBuilder: (context, index) {
                    var address = controller.addresses[index];
                    return GestureDetector(
                      onTap: () =>
                          controller.updateAddressStatus(address['id']),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: controller.getAddressBackgroundColor(
                              address['address_status']),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Address Line: ${address['address_line']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (controller.isLoading.value &&
                                        controller.deletingAddressId.value ==
                                            address['id'])
                                      const CupertinoActivityIndicator(),
                                    if (address['address_status'] == 1)
                                      const Icon(Icons.circle,
                                          color: Colors.green, size: 12),
                                    if (address['address_status'] == 2)
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => controller
                                            .deleteAddress(address['id']),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                buildRichText(
                                    'Country: ', address['country_name']),
                                buildRichText('State: ', address['state_name']),
                                buildRichText(
                                    'District: ', address['district']),
                                buildRichText('Pincode: ', address['pincode']),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddAddressScreen and refresh addresses after returning
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAddressScreen()),
          ).then((_) => controller.loadCustomerAddresses());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  RichText buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value,
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: file_names

import 'package:customer/app/generalImports.dart';
import 'package:customer/controller/partner%20controller/partner_details_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PartnerDetailsScreen extends StatelessWidget {
  final int partnerId;
  final int partnerServiceId;

  const PartnerDetailsScreen({
    super.key,
    required this.partnerId,
    required this.partnerServiceId,
  });

  @override
  Widget build(BuildContext context) {
    final PartnerDetailsController controller = Get.put(
      PartnerDetailsController(
          partnerId: partnerId, partnerServiceId: partnerServiceId),
    );

    return Scaffold(
      backgroundColor: lightPrimaryColor,
      appBar: AppBar(
        title: null,
        backgroundColor: whiteColor,
      ),
      body: Obx(() {
        if (controller.partnerDetails.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final partner = controller.partnerDetails.value!;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Column(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        partner.gender == 1
                            ? 'assets/malepic.png'
                            : 'assets/femalepic.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text(partner.partnerName),
                    Text(partner.gender == 1 ? 'Male' : 'Female'),
                    Text(
                      '${partner.countryName}, ${partner.stateName}, ${partner.district}, ${partner.pincode}',
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text(partner.bio, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Booking Service: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Expanded(
                          child: Text(
                            partner.serviceName,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow
                                .ellipsis, // If text is too long, show ellipsis
                            maxLines: 1, // Ensure only one line
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Wrap(
                      spacing: 8.0,
                      children: controller.remarkOptions
                          .map((option) => GestureDetector(
                                onTap: () {
                                  controller.remarkController.text = controller
                                          .remarkController.text.isEmpty
                                      ? option
                                      : '${controller.remarkController.text}, $option';
                                },
                                child: Chip(
                                  label: Text(option),
                                  backgroundColor: primaryColor,
                                  labelStyle:
                                      const TextStyle(color: blackColor),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller.remarkController,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      minLines: 3,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    const Text('My service delivery address',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      child: Card(
                        color: primaryLightColor,
                        elevation:
                            4, // Set elevation to 0 to avoid double shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Same curve radius as BoxDecoration
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              16.0), // Adjust padding as needed
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Address Line: ${partner.customerAddress}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow
                                    .ellipsis, // If text is too long, it will be cut off with ellipsis
                                maxLines: 2, // To limit the number of lines
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Country: ${partner.countryName}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'State: ${partner.stateName}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'District: ${partner.district}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pincode: ${partner.pincode}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.isLoading.value) {
          return const SizedBox.shrink(); // Hide button when loading
        }

        return Padding(
          padding: const EdgeInsets.only(left: 28, bottom: 16),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          controller.selectDate(context); // Open date picker
                        },
                        icon: const Icon(Icons.date_range),
                      ),
                      Obx(() {
                        return Text(
                          controller.selectedDateString.value.isNotEmpty
                              ? controller.selectedDateString.value
                              : "Select Date",
                        );
                      }),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: controller.selectedDateString.value.isEmpty
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Booking'),
                                  content: const Text(
                                      'Do you want to book this service?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    Obx(() {
                                      return ElevatedButton(
                                        onPressed: controller.isLoading.value
                                            ? null
                                            : controller.bookNow,
                                        child: controller.isLoading.value
                                            ? const CupertinoActivityIndicator()
                                            : const Text('Book Now'),
                                      );
                                    }),
                                  ],
                                );
                              },
                            );
                          },
                    child: const Text("Continue Booking"),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

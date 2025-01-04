// ignore_for_file: file_names

import 'package:customer/controller/booking_details_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';

class BookingDetailsPage extends StatelessWidget {
  final int bookingId;

  const BookingDetailsPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingDetailsController(bookingId: bookingId));

    return Scaffold(
      backgroundColor: lightPrimaryColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: const Text('Booking Details'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text('Error: ${controller.errorMessage}'));
        }

        final booking = controller.bookingDetails;

        // Safe extraction of data
        final partnerName = booking['partner_name'] ?? 'Unknown';
        final gender = booking['gender'] ?? 'Unknown';
        final country = booking['partner_country_name'] ?? '';
        final state = booking['partner_state_name'] ?? '';
        final pincode = booking['partner_pincode'] ?? '';
        final district = booking['partner_district'] ?? '';
        final bookingStatus = booking['booking_status'] ?? 0;
        final serviceName = booking['service_name'] ?? 'Unknown Service';
        final serviceThumbnail = booking['service_thumbnail'] ?? '';
        final addressLine = booking['customer_address_line'] ?? 'No Address';
        final countryName = booking['customer_country_name'] ?? 'Unknown';
        final stateName = booking['customer_state_name'] ?? 'Unknown';
        final districtName = booking['customer_district'] ?? 'Unknown';
        final pincodeName = booking['customer_pincode'] ?? 'Unknown';
        final remark = booking['booking_remark'] ?? 'No remark available';
        final dateForService = booking['date_for_service'] ?? 'Not specified';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        AssetImage(controller.getGenderImage(gender)),
                    radius: 50,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Partner details',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(partnerName),
                      Text('Gender: $gender'),
                      Text('$country, $state, $pincode, $district'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                            text: 'Booking status: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        TextSpan(
                          text: controller.getStatusText(bookingStatus),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: controller.getStatusColor(bookingStatus)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Text('Requested service:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Image.network(
                          "${filesurl}services_thumbnail/$serviceThumbnail",
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width * 0.12,
                          height: MediaQuery.of(context).size.width * 0.12),
                      const SizedBox(width: 8),
                      Text(serviceName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Text('My service delivery address',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.date_range, size: 18),
                  const SizedBox(width: 8),
                  const Text("Booked for the date: "),
                  Text(dateForService,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dateForService == 'Not specified'
                              ? Colors.grey
                              : Colors.green)),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: primaryLightColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddressRow('Address Line:', addressLine),
                      _buildAddressRow('Country:', countryName),
                      _buildAddressRow('State:', stateName),
                      _buildAddressRow('District:', districtName),
                      _buildAddressRow('Pincode:', pincodeName),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Text('Remark:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(remark, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        return FloatingActionButton(
          onPressed: controller.makePhoneCall,
          backgroundColor:
              controller.isPhoneAvailable.value ? Colors.green : Colors.grey,
          child: const Icon(Icons.phone, color: Colors.white),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Helper function to build address rows
  Widget _buildAddressRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: '$label ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black)),
          TextSpan(text: value, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}

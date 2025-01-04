// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:customer/app/generalImports.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/api.dart';

class BookingDetailsController extends GetxController {
  var bookingDetails = <String, dynamic>{}.obs;
  var isLoading = false.obs;
  var isPhoneAvailable = false.obs;
  var phoneData = ''.obs;
  var errorMessage = ''.obs;

  final int bookingId;

  // Connectivity management
  var isConnected = true.obs;

  BookingDetailsController({required this.bookingId});

  @override
  void onInit() {
    super.onInit();
    fetchBookingDetails(bookingId);
  }

  Future<void> fetchBookingDetails(int bookingId) async {
    isLoading.value = true;
    final url = Uri.parse('${Api.getBookingDetails}/$bookingId');
    log('Fetching booking details from: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        log('Decoded Response: $jsonData');

        bookingDetails.value = jsonData;
        isPhoneAvailable.value =
            jsonData['phone'] != 'N/A' && jsonData['phone'] != null;
        phoneData.value = jsonData['phone'] ?? '';
      } else {
        errorMessage.value = 'Failed to load booking details';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Method to handle phone call
  Future<void> makePhoneCall() async {
    if (phoneData.value == 'N/A' || phoneData.value.isEmpty) {
      Get.defaultDialog(
        title: 'Cannot Make Call',
        middleText: 'Please wait until partner accepts your request.',
        textCancel: 'OK',
        onCancel: () {
          Get.back();
        },
      );
    } else {
      String url = 'tel:${phoneData.value}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  // Connectivity change listener
  void updateConnectionStatus(bool isConnected) {
    this.isConnected.value = isConnected;
  }

  // String _formatDateForService(String dateString) {
  //   DateTime now = DateTime.now();
  //   DateTime dateForService = DateTime.parse(dateString);
  //   String formattedDate;

  //   if (dateForService.year == now.year &&
  //       dateForService.month == now.month &&
  //       dateForService.day == now.day) {
  //     formattedDate = 'Today';
  //   } else if (dateForService.year == now.year &&
  //       dateForService.month == now.month &&
  //       dateForService.day == now.day - 1) {
  //     formattedDate = 'Yesterday';
  //   } else if (dateForService.year == now.year &&
  //       dateForService.month == now.month &&
  //       dateForService.day == now.day + 1) {
  //     formattedDate = 'Tomorrow';
  //   } else {
  //     formattedDate = DateFormat('dd MMMM yyyy').format(dateForService);
  //   }

  //   return formattedDate;
  // }

  String getGenderImage(String gender) {
    return gender == 'Male' ? 'assets/malepic.png' : 'assets/femalepic.png';
  }

  String getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Pending';
      case 2:
        return 'Ongoing';
      case 3:
        return 'Rejected';
      case 4:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.red;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

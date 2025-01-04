// ignore_for_file: unrelated_type_equality_checks

import 'dart:developer';

import 'package:customer/app/generalImports.dart';
import 'package:customer/model/PartnerDetails.dart';
import 'package:customer/utils/api.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class PartnerDetailsController extends GetxController {
  final int partnerId;
  final int partnerServiceId;

  Rx<PartnerDetails?> partnerDetails = Rx<PartnerDetails?>(null);
  RxBool isLoading = false.obs;
  RxBool showBookNow = false.obs;
  TextEditingController remarkController = TextEditingController();
  late int customerId;
  late int customerAddressId;
  RxBool isAlertDialogVisible = false.obs;
  RxList<String> remarkOptions = <String>[].obs;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  RxString selectedDateString = ''.obs;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  PartnerDetailsController({
    required this.partnerId,
    required this.partnerServiceId,
  });

  @override
  void onInit() {
    super.onInit();
    tz.initializeTimeZones();
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    initConnectivity();
    fetchCustomerId();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      return;
    }

    if (!Get.isRegistered<PartnerDetailsController>()) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    if (result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile)) {
      if (isAlertDialogVisible.value) {
        isAlertDialogVisible.value = false;
        Get.back();
      }
    } else {
      if (!isAlertDialogVisible.value) {
        isAlertDialogVisible.value = true;
        Get.dialog(
          const AlertDialog(
            title: Text("No Internet Connection"),
            content: Text("Please check your internet connection."),
          ),
          barrierDismissible: false,
        );
      }
    }
  }

  Future<void> fetchCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String? customerIdString = prefs.getString('customer_id');
      if (customerIdString != null) {
        customerId = int.parse(customerIdString);
        partnerDetails.value = await fetchPartnerDetails();
      } else {
        throw Exception('Customer ID not found');
      }
    } catch (e) {
      // Handle error (e.g., show a dialog or log the error)
    }
  }

  Future<PartnerDetails?> fetchPartnerDetails() async {
    final response = await http.get(
      Uri.parse(
        '${Api.getPartnerDetails}?partner_id=$partnerId&partner_service_id=$partnerServiceId&customer_id=$customerId',
      ),
    );

    if (response.statusCode == 200) {
      try {
        var data = PartnerDetails.fromJson(jsonDecode(response.body));

        remarkOptions.value =
            List<String>.from(jsonDecode(response.body)['tags']);
        customerAddressId = data.customerAddress.id;
        return data;
      } catch (e) {
        throw Exception('Failed to parse partner details: $e');
      }
    } else {
      throw Exception('Failed to load partner details');
    }
  }

  Future<void> bookNow() async {
    if (await _connectivity.checkConnectivity() == ConnectivityResult.none) {
      Get.snackbar('Error', 'No internet connection');
      return; // Early exit if no connection
    }

    isLoading.value = true;

    final response = await http.post(
      Uri.parse(Api.bookService),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'customer_address_id': customerAddressId,
        'remark': remarkController.text,
        'partner_id': partnerId,
        'partner_service_id': partnerServiceId,
        'customer_id': customerId,
        'service_date': selectedDate.value!.toIso8601String(),
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      isLoading.value = false;
      Get.back();
      Get.snackbar(
        'Success',
        'Service booked successfully',
      );
      await Future.delayed(const Duration(seconds: 2));
    } else {
      isLoading.value = false;
      log('Error status code: ${response.statusCode}');
      log('Error response: ${response.body}');
      Get.snackbar('Error', 'Failed to book service');
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final tz.TZDateTime kolkataTime = tz.TZDateTime.from(
        picked,
        tz.getLocation('Asia/Kolkata'),
      );
      selectedDate.value = kolkataTime;
      selectedDateString.value = DateFormat('yyyy-MM-dd').format(kolkataTime);
    }
  }
}

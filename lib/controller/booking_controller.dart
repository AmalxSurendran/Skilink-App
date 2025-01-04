// ignore_for_file: invalid_use_of_protected_member

import 'dart:developer';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../utils/api.dart';

class BookingController extends GetxController {
  var bookings = <dynamic>[].obs;
  var isLoading = false.obs;
  var hasMore = true.obs;
  var currentPage = 1.obs;
  var isLoggedIn = false.obs;
  var bookingData = <String, dynamic>{}.obs;
  late SharedPreferences _prefs;
  var errorMessage = ''.obs;

  final int perPage = 10;

  @override
  void onInit() {
    super.onInit();
    initSharedPreferences();

    // Observe changes in login state
    ever(isLoggedIn, (loggedIn) {
      if (loggedIn == true) {
        refreshData();
      }
    });
  }

  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    String? customerId = _prefs.getString('customer_id');
    isLoggedIn.value = customerId != null;

    if (isLoggedIn.value) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;
    String customerId = _prefs.getString('customer_id') ?? "";
    String url =
        '${Api.getBookings}?customer_id=$customerId&page=${currentPage.value}';
    log("Fetching bookings from: $url");

    try {
      final response = await http.get(Uri.parse(url));
      log('bookin url : $url');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        bookingData.value = jsonData;
        log('Booking data: ${bookingData.value}');
        log('Booking data length:${jsonData['data'].length}');
        if (jsonData['data'].isEmpty) {
          hasMore.value = false; // No more data
        } else {
          bookings.addAll(jsonData['data']);
          currentPage.value++;

          if (jsonData['data'].length < perPage) {
            hasMore.value = false;
          }
        }
      } else {
        errorMessage.value = 'Failed to load bookings';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Refreshes the data by resetting necessary variables
  Future<void> refreshData() async {
    currentPage.value = 1;
    bookings.clear();
    hasMore.value = true; // Resetting hasMore to true for a fresh load
  }
}

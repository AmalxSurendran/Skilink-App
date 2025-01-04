// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:customer/app/generalImports.dart';
import 'package:customer/utils/api.dart';
import 'package:get/get.dart';

class SpecificServicePartnersController extends GetxController {
  var ServicePartners = <dynamic>[].obs;
  var isLoading = false.obs;
  var isFetching = false.obs;
  var page = 1.obs;
  var myServicePincode = "none".obs;
  var isAlertDialogVisible = false.obs;
  var connectionStatus = [ConnectivityResult.none].obs;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final int serviceId;

  SpecificServicePartnersController({
    required this.serviceId,
  });

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    initConnectivity();
    fetchPartners();

    // Watch for changes in the pincode and refetch the partners if needed
    ever(myServicePincode, (_) async {
      page.value = 1; // Reset the page number to 1 when the pincode changes
      log("Pincode updated: ${myServicePincode.value}"); // Debug the updated pincode
      await fetchPartners(); // Refetch the data whenever the pincode changes
    });
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      return;
    }

    _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    connectionStatus.value = result;
    if (result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile)) {
      if (isAlertDialogVisible.value) {
        isAlertDialogVisible.value = false;
      }
    } else {
      if (!isAlertDialogVisible.value) {
        isAlertDialogVisible.value = true;
      }
    }
  }

  Future<void> fetchPartners() async {
    if (isFetching.value) {
      log("Already fetching..."); // Debug if we're in the middle of a fetch
      return;
    }

    log("Fetching partners..."); // Debug to confirm fetch is being triggered
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerID = prefs.getString('customer_id');

    isFetching.value = true;
    isLoading.value = true;

    try {
      final queryParams = {
        'page': page.toString(),
        'service_id': serviceId.toString(),
        'customer_id': customerID,
        'pincode': myServicePincode.value, // Include pincode in the request
      };

      final Uri uri = Uri.parse(Api.listSpecificServicePartners)
          .replace(queryParameters: queryParams);

      log("API URL: ${uri.toString()}"); // Debugging the full URL to check parameters

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        final partnersData = parsed['partners']['data'];

        // Clear previous data before adding the new data
        if (page.value == 1) {
          ServicePartners.clear();
        }

        // Add new partners data
        ServicePartners.addAll(partnersData);
        myServicePincode.value =
            parsed['pincode']; // Update pincode in the controller
        page.value++;

        log("Partners fetched: ${ServicePartners.length} items"); // Debug fetched data length

        isLoading.value = false;
        isFetching.value = false;
      } else {
        _showErrorSnackBar('Failed to fetch partners. Please try again.');
        isLoading.value = false;
        isFetching.value = false;
      }
    } catch (e) {
      _showErrorSnackBar(
          'Failed to connect to the server. Please check your internet connection.');
      isLoading.value = false;
      isFetching.value = false;
    }
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar('Error', message);
  }
}

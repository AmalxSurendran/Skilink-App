import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:customer/app/generalImports.dart';
import 'package:customer/controller/profile%20controller/profile_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:customer/utils/api.dart';

class GenderController extends GetxController {
  var selectedGender = Rx<int?>(null);
  var isLoading = false.obs;
  var errorMessage = Rx<String?>(null);

  List<ConnectivityResult> connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    initConnectivity();
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  Future<void> initConnectivity() async {
    try {
      connectionStatus = await _connectivity.checkConnectivity();
    } on PlatformException {
      return;
    }
    _updateConnectionStatus(connectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    connectionStatus = result;
    if (connectionStatus.contains(ConnectivityResult.none)) {
      showNoInternetConnectionDialog();
    }
  }

  void showNoInternetConnectionDialog() {
    Get.dialog(
      const AlertDialog(
        title: Text('No Internet Connection'),
        content: Text('Please check your internet connection and try again.'),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> updateGender(int customerId) async {
    if (selectedGender.value == null) return;

    if (selectedGender.value == customerId) {
      Get.snackbar('Info', 'No changes made');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final response = await http.patch(
      Uri.parse('${Api.updateGender}/$customerId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'gender': selectedGender.value!,
      }),
    );

    isLoading.value = false;
    if (response.statusCode == 200) {
      log('StatusCode: ${response.statusCode}');
      final result = json.decode(response.body);
      log('Gender change : $result');
      ProfileController controller = Get.find();

      controller.profileData['gender'] = selectedGender.value;
      // Debugging output to confirm if these lines are executed
      log('Executing snackbar with message: ${result['message']}');
      Get.back();
      Get.snackbar('Success', result['message']);

      // Debugging output for back navigation
      log('Navigating back');
    } else {
      log('Failed to update gender. Showing error snackbar');
      Get.snackbar('Error', 'Failed to update gender');
      errorMessage.value = 'Failed to update gender';
    }
  }
}

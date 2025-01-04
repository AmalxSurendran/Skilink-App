// Controller for HomeContainer
import 'dart:async';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:customer/app/generalImports.dart';
import 'package:customer/utils/api.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final int initialPage;
  late PageController pageController;
  final bottomNavIndex = 0.obs;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool isAlertDialogVisible = false;
  var banners = [].obs;
  var services = [].obs;
  var addressStatus = false.obs;
  var customerExistStatus = false.obs;
  var isLoggedIn = false.obs;
  var isLoading = true.obs;

  HomeController({this.initialPage = 0});

  @override
  void onInit() {
    super.onInit();

    bottomNavIndex.value = initialPage;
    pageController = PageController(initialPage: initialPage);
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    initConnectivity();
    checkLoginStatus();
    fetchData();
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    pageController.dispose();
    super.onClose();
  }

  void updateIndex(int index) {
    bottomNavIndex.value = index;
    pageController.jumpToPage(index);
  }

  Future<void> refreshData() async {
    fetchData();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      return;
    }
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile)) {
      if (isAlertDialogVisible) {
        Get.back(); // Dismiss the alert dialog
        isAlertDialogVisible = false;
      }
    } else {
      if (!isAlertDialogVisible) {
        Get.dialog(
          const AlertDialog(
            title: Text("No Internet Connection"),
            content: Text("Please check your internet connection."),
          ),
        );
        isAlertDialogVisible = true;
      }
    }
  }

  Future<bool> onWillPop(BuildContext context) async {
    return (await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? loggedInStatus = prefs.getInt('logged_in_status') ?? 0;
    isLoggedIn.value = loggedInStatus == 1;
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerId = prefs.getString('customer_id') ?? "";

    String apiUrl = Api.getGuestHome;
    if (isLoggedIn.value) {
      apiUrl += '/$customerId';
    }

    log("login apiurl: $apiUrl");
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        banners.value = data['banners'];
        services.value = data['services'];
        addressStatus.value = data['extra']['address_status'];
        customerExistStatus.value = data['extra']['customer_exist_status'];
        isLoading.value = false;
      } else {
        log('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      isLoading.value = false;
    }
  }
}

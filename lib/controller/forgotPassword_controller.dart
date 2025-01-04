// ignore_for_file: non_constant_identifier_names, avoid_print, file_names

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:customer/app/generalImports.dart';
import 'package:customer/utils/api.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../view/screens/auth/forgotPasswordOTP.dart';

// Controller for Forgot Password
class ForgotPasswordController extends GetxController {
  var countryCodes = <Map<String, dynamic>>[].obs;
  var selectedCountryCode = ''.obs;
  var selectedCountryCode_POST = ''.obs;
  var isLoading = true.obs;
  bool isAlertDialogVisible = false;
  final Connectivity _connectivity = Connectivity();

  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    initConnectivity();
    loadCountryCodes();
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

  Future<void> loadCountryCodes() async {
    final url = Api.getCountryCodes; // Replace with your API URL
    try {
      final response = await http.get(Uri.parse(url));
      print("Country codes API response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        countryCodes.value = data.map((item) {
          return {
            "id": item["id"].toString(),
            "country_name": item["country_name"],
            "country_code_phone": item["country_code_phone"],
          };
        }).toList();
        if (countryCodes.isNotEmpty) {
          selectedCountryCode_POST(countryCodes.first['id']!);
          selectedCountryCode(countryCodes.first['country_code_phone']!);
        }
      } else {
        print("Failed to load country codes: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading country codes: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final phone = phoneController.text;

    // Prepare form data
    final formData = {
      "phone": phone,
      "country_code": selectedCountryCode_POST.value,
    };

    try {
      final response = await http.post(
        Uri.parse(Api.resetPasswordOtp),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(formData),
      );

      print("Submit API response: ${response.body}");

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final id = responseData['id'];

        // Save ID to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('tempId', id);
        await prefs.setString('ph', phone.trim());

        // Navigate to ForgetPasswordOTP screen
        Get.to(() => const ForgetPasswordOTP());
      } else {
        showErrorDialog('Failed to create customer');
      }
    } catch (e) {
      print("Error submitting data: $e");
      showErrorDialog('Error sending formData: $e');
    }
  }

  void showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

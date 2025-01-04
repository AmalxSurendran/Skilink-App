// ignore_for_file: avoid_print

import 'package:customer/app/generalImports.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../../utils/api.dart';

class AddAddressController extends GetxController {
  var isLoading = false.obs;
  var selectedCountryId = ''.obs;
  var selectedCountryName = ''.obs;
  var selectedStateId = ''.obs;
  var selectedStateName = ''.obs;
  var customerId = ''.obs;

  final TextEditingController addressLineController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController districtController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadCustomerPreferences();
  }

  Future<void> _loadCustomerPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    customerId.value = prefs.getString('customer_id') ?? '';
  }

  Future<void> getCountryList() async {
    try {
      var response = await http.get(Uri.parse(Api.countryListAddress));
      if (response.statusCode == 200) {
        var countries = json.decode(response.body);
        showCountryPicker(countries);
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  Future<void> getStatesByCountry(String countryId) async {
    try {
      var response =
          await http.get(Uri.parse('${Api.stateListAddress}/$countryId'));
      if (response.statusCode == 200) {
        var states = json.decode(response.body);
        showStatePicker(states);
      } else {
        throw Exception('Failed to load states');
      }
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  // Show Country Picker using GetX
  void showCountryPicker(List countries) {
    double height = MediaQuery.of(Get.context!).size.height * 0.9;

    Get.bottomSheet(
      Container(
        height: height,
        color: Colors.white,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Select Country",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(countries[index]['country_name']),
                    onTap: () {
                      selectedCountryId.value =
                          countries[index]['id'].toString();
                      selectedCountryName.value =
                          countries[index]['country_name'];
                      Get.back(); // Close the bottom sheet
                      // Optionally load states for the selected country
                      getStatesByCountry(selectedCountryId.value);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show State Picker using GetX

  void showStatePicker(List states) {
    double height = MediaQuery.of(Get.context!).size.height * 0.9;

    Get.bottomSheet(
      Container(
        height: height,
        color: Colors.white,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Select State",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: states.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(states[index]['state_name']),
                    onTap: () {
                      selectedStateId.value = states[index]['id'].toString();
                      selectedStateName.value = states[index]['state_name'];
                      Get.back(); // Close the bottom sheet
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitForm() async {
    if (addressLineController.text.isNotEmpty &&
        pincodeController.text.isNotEmpty &&
        districtController.text.isNotEmpty &&
        selectedStateId.value.isNotEmpty &&
        selectedCountryId.value.isNotEmpty) {
      // Set loading to true
      isLoading.value = true;

      // Prepare the payload for submission
      var payload = {
        'address_line': addressLineController.text,
        'pincode': pincodeController.text,
        'district': districtController.text,
        'customer_id': customerId.value,
        'state_id': selectedStateId.value,
        'country_id': selectedCountryId.value,
      };

      try {
        var url = Uri.parse(Api.addAddressCustomer);
        var response = await http.post(url, body: payload);

        if (response.statusCode == 201) {
          log('Address submitted successfully');
          await savePincode(pincodeController.text);

          Get.back();

          // Clear the text fields after submission
          addressLineController.clear();
          pincodeController.clear();
          districtController.clear();

          Get.snackbar(
            'Success',
            'Address saved successfully',
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          log('Failed to submit address. Error: ${response.reasonPhrase}');
          Get.snackbar(
            'Error',
            'Failed to save address',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        log('Error submitting address: $e');
        Get.snackbar(
          'Error',
          'Error: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        // Hide the loading indicator
        isLoading.value = false;
      }
    } else {
      // Show error snackbar if any of the fields are empty
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> savePincode(String pincode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pincode', pincode);
    log('Pincode saved in SharedPreferences: $pincode');
  }
}

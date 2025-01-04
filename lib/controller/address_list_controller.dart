import 'dart:convert';
import 'dart:developer';
import 'package:customer/controller/partner_search_list_controller.dart';
import 'package:customer/controller/service_partner_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer/utils/api.dart';

class ListAddressController extends GetxController {
  var addresses = <dynamic>[].obs; // List of addresses
  var isLoading = false.obs; // Loading state
  var deletingAddressId = Rx<int?>(null); // Deleting address ID

  @override
  void onInit() {
    super.onInit();
    loadCustomerAddresses();
  }

  Future<void> loadCustomerAddresses() async {
    isLoading.value = true;
    try {
      String? customerId = await getCustomerId();
      if (customerId != null) {
        final list = await fetchCustomerAddresses(customerId);
        addresses.assignAll(list); // Use assignAll to replace the list
      } else {
        _showErrorSnackBar('Customer ID not found');
      }
    } catch (error) {
      _showErrorSnackBar('Failed to load customer addresses');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('customer_id');
  }

  Future<List<dynamic>> fetchCustomerAddresses(String customerId) async {
    final response = await http.get(
      Uri.parse('${Api.listAddress}/$customerId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load customer addresses');
    }
  }

  Future<void> updateAddressStatus(int addressId) async {
    isLoading.value = true; // Start the loading state
    try {
      final response = await http.patch(
        Uri.parse('${Api.updateCustomerAddress}/$addressId'),
      );

      if (response.statusCode == 200) {
        print('updateAddressStatus: ${response.statusCode}');
        var updatedPincode = ''; // Assuming it's updated here
        Get.back(
            result:
                updatedPincode); // Make sure this is called after the API response is handled

        await loadCustomerAddresses(); // Reload the addresses
        SpecificServicePartnersController controller = Get.find();
        await controller.fetchPartners(); // Ensure this completes first

        PartnerListController controlller = Get.put(PartnerListController());
        if (controlller.partners.isEmpty) {
        } else {
          _showSuccessSnackBar('Address status updated successfully');
        }
      } else {
        log('Failed to update address status: ${response.statusCode}');
        _showErrorSnackBar('Failed to update address status. ${response.body}');
      }
    } catch (e) {
      log('Error while updating address status: $e');
      _showErrorSnackBar('Failed to update address status');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(int addressId) async {
    deletingAddressId.value = addressId;
    isLoading.value = true;

    try {
      final response = await http.patch(
        Uri.parse('${Api.deleteAddress}/$addressId'),
      );

      if (response.statusCode == 200) {
        await loadCustomerAddresses();
        _showSuccessSnackBar('Address deleted successfully');
      } else {
        _showErrorSnackBar('Failed to delete address');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to delete address');
    } finally {
      isLoading.value = false;
      deletingAddressId.value = null;
    }
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar('Error', message, backgroundColor: Colors.red);
  }

  void _showSuccessSnackBar(String message) {
    Get.snackbar('Success', message, backgroundColor: Colors.green);
  }

  Color getAddressBackgroundColor(int addressStatus) {
    return addressStatus == 1 ? Colors.yellow.shade200 : Colors.white;
  }
}

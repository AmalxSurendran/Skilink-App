import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:customer/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PartnerListController extends GetxController {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  var isLoading = false.obs;
  var countries = <dynamic>[].obs;
  var states = <dynamic>[].obs;
  List<dynamic> partners = [];
  Timer? debounceTimer;
  RxString searchText = ''.obs;

  // Use RxInt for reactive variables
  var totalResults = 0.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;

  var selectedCountryId = ''.obs;
  var selectedStateId = ''.obs;
  var district = ''.obs;
  var pincode = ''.obs;
  var myPincode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCountries();
    searchController
        .addListener(onSearchTextChanged); // Listen for text changes
  }

  @override
  void onClose() {
    searchController.removeListener(onSearchTextChanged);
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void onSearchTextChanged() {
    searchText.value = searchController.text.trim(); // Update RxString

    if (debounceTimer != null) {
      debounceTimer!.cancel();
    }

    // Start a new timer that will trigger the filtering after 300ms of inactivity
    debounceTimer = Timer(const Duration(milliseconds: 300), () {
      filterPartners();
    });
  }

  // Clear existing partners and fetch new filtered list
  void filterPartners() {
    partners.clear();
    currentPage.value = 1; // Reset to first page
    fetchPartners(); // Fetch partners again with updated filters
  }

  void fetchCountries() async {
    isLoading.value = true;

    try {
      final response = await http.get(Uri.parse(Api.countryListAddress));
      if (response.statusCode == 200) {
        countries.value =
            json.decode(response.body); // Update observable using '.value'
        isLoading.value = false;
      } else {
        log('Failed to load countries: ${response.statusCode}');
        isLoading.value = false;
      }
    } catch (e) {
      log('Error loading countries: $e');
      isLoading.value = false;
    }
  }

  // void _fetchStatesByCountry(String countryId) async {
  //   isLoading.value = true;

  //   try {
  //     final response =
  //         await http.get(Uri.parse(Api.stateListAddress + '/$countryId'));
  //     if (response.statusCode == 200) {
  //       states.value =
  //           json.decode(response.body); // Update observable using '.value'
  //       isLoading.value = false;
  //     } else {
  //       log('Failed to load states: ${response.statusCode}');
  //       isLoading.value = false;
  //     }
  //   } catch (e) {
  //     log('Error loading states: $e');
  //     isLoading.value = false;
  //   }
  // }

  void fetchPartners() async {
    isLoading.value = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerID = prefs.getString('customer_id');

    try {
      final Map<String, dynamic> queryParams = {
        'page': currentPage.toString(),
        'search_term': searchController.value.text,
        'customer_id': customerID ?? '',
      };

      if (selectedCountryId.isNotEmpty) {
        queryParams['country'] = selectedCountryId;
      }
      if (selectedStateId.isNotEmpty) queryParams['state'] = selectedStateId;
      if (district.isNotEmpty) queryParams['district'] = district;
      if (pincode.isNotEmpty) queryParams['pincode'] = pincode;

      final Uri uri =
          Uri.parse(Api.searchPartners).replace(queryParameters: queryParams);

      final response = await http.get(uri);
      log('fetchPartners: ${uri.toString()}');

      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        log('API Response: ${response.body}');

        // Update myPincode
        myPincode.value = parsed['pincode']?.toString() ?? '';
        log('My pincode: ${myPincode.value}');

        final partnersData = parsed['partners'];
        currentPage.value =
            int.tryParse(partnersData['current_page'].toString()) ?? 1;
        totalPages.value =
            int.tryParse(partnersData['last_page'].toString()) ?? 1;

        // Update partners list
        if (currentPage.value == 1) {
          partners.assignAll(partnersData['data']);
        } else {
          partners.addAll(partnersData['data']);
        }
      } else {
        log('Failed to fetch partners: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching partners: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

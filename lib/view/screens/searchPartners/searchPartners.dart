// ignore_for_file: unnecessary_null_comparison, prefer_const_constructors, file_names

import 'dart:developer';

import 'package:customer/controller/partner_search_list_controller.dart';
import 'package:customer/view/screens/searchPartners/PartnerDeatilsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../addressManagement/listAddress.dart';

class PartnerListPage extends StatelessWidget {
  PartnerListPage({super.key});

  final controller = Get.put(PartnerListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPrimaryColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildSearchBar(),
              _buildPincodeDisplay(context),
              _buildSearchText(),
              _buildPartnersList(context),
            ],
          ),
          if (controller.isLoading.value && controller.partners.isEmpty)
            const Center(child: CupertinoActivityIndicator()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: null,
      backgroundColor: whiteColor,
    );
  }

  // Widget _buildSearchBar() {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
  //     child: Card(
  //       elevation: 4,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 12),
  //         child: TextField(
  //           controller: controller.searchController,
  //           focusNode: controller.searchFocusNode,
  //           onChanged: (text) => controller.onSearchTextChanged(),
  //           decoration: InputDecoration(
  //             border: InputBorder.none,
  //             hintText: 'Search by services...',
  //             suffixIcon: IconButton(
  //               icon: Icon(Icons.search),
  //               onPressed: () {
  //                 controller.searchFocusNode.unfocus();
  //                 controller.filterPartners();
  //               },
  //             ),
  //             contentPadding: EdgeInsets.symmetric(vertical: 16),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller.searchController,
            focusNode: controller.searchFocusNode,
            onChanged: (text) => controller.onSearchTextChanged(),
            onSubmitted: (text) {
              controller.onSearchTextChanged();
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search by services...',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  controller.onSearchTextChanged();
                },
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPincodeDisplay(BuildContext context) {
    return Obx(() {
      return controller.myPincode.value.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on),
                      Text("Pincode: "),
                      Text(
                        controller.myPincode.value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  ElevatedButton.icon(
                    icon: Icon(Icons.arrow_forward_sharp, color: primaryColor),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: blackColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListAddress()),
                      );
                    },
                    label: Text(
                      "Choose pincode",
                      style: TextStyle(color: whiteColor),
                    ),
                  ),
                ],
              ),
            )
          : Container();
    });
  }

  Widget _buildSearchText() {
    return Obx(() {
      log('Search Text: ${controller.searchText.value}');
      return controller.searchText.value.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'You are searching for "${controller.searchText.value}"',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            )
          : Container();
    });
  }

  Widget _buildPartnersList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.partners.isEmpty) {
        return const Center(child: CupertinoActivityIndicator());
      }

      return Expanded(
        child: controller.partners.isEmpty
            ? _buildEmptyState(context)
            : _buildPartnerListView(context),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/char.png',
              fit: BoxFit.cover,
            ),
            const Text(
              'Search services...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerListView(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!controller.isLoading.value &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadMorePartners();
        }
        return true;
      },
      child: ListView.builder(
        itemCount: controller.partners.length + 1,
        itemBuilder: (context, index) {
          if (index < controller.partners.length) {
            var partner = controller.partners[index];
            log('partner card: $partner');
            controller.fetchPartners;
            return _buildPartnerCard(context, partner);
          } else {
            return _buildLoadMoreIndicator();
          }
        },
      ),
    );
  }

  Widget _buildPartnerCard(BuildContext context, dynamic partner) {
    String subtitleText = partner['bio'] != null
        ? partner['bio'].substring(
            0, partner['bio'].length < 100 ? partner['bio'].length : 100)
        : '';

    return GestureDetector(
      onTap: () => _navigateToPartnerDetails(context, partner),
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildGenderImage(partner['gender']),
                  ),
                  SizedBox(width: 16),
                  _buildPartnerDetails(partner, subtitleText, context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPartnerDetails(BuildContext context, dynamic partner) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartnerDetailsScreen(
          partnerId: partner['partner_id'],
          partnerServiceId: partner['partner_service_id'],
        ),
      ),
    );
  }

  Widget _buildPartnerDetails(
      dynamic partner, String subtitleText, BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                margin: EdgeInsets.only(right: 8),
              ),
              Text(
                partner['full_name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildPartnerInfoRow(partner, context),
          SizedBox(height: 8),
          Text(
            subtitleText,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Row _buildPartnerInfoRow(dynamic partner, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.person, size: 12, color: Colors.grey[600]),
            SizedBox(width: 4),
            Text(
              _getGenderText(partner['gender']),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.05),
        Text(
          partner['service_name'],
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: greenColor),
        ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(
      () {
        return controller.isLoading.value
            ? const Center(child: CupertinoActivityIndicator())
            : Container();
      },
    );
  }

  void _loadMorePartners() {
    controller.currentPage++;
    controller.fetchPartners();
  }

  Widget _buildGenderImage(int gender) {
    String imagePath;

    if (gender == 1) {
      imagePath = 'assets/malepic.png';
    } else if (gender == 2 || gender == 3) {
      imagePath = 'assets/femalepic.png';
    } else {
      imagePath = 'assets/defaultpic.png';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(imagePath, width: 40, height: 40, fit: BoxFit.cover),
    );
  }

  String _getGenderText(int gender) {
    switch (gender) {
      case 1:
        return 'Male';
      case 2:
      case 3:
        return 'Female';
      default:
        return 'Unspecified';
    }
  }
}

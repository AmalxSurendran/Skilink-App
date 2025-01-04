// ignore_for_file: prefer_interpolation_to_compose_strings, file_names

import 'package:carousel_slider/carousel_slider.dart';
import 'package:customer/controller/home_controller.dart';
import 'package:customer/view/screens/searchPartners/searchPartners.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../addressManagement/listAddress.dart';
import '../auth/login.dart';
import '../searchPartners/specificServicePartners.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPrimaryColor,
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CupertinoActivityIndicator())
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: Get.height * 0.03,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: _buildSearchBar(),
                      ),
                      if (controller.banners.isNotEmpty)
                        _buildBannersCarousel(),
                      if (!controller.addressStatus.value)
                        Center(child: _buildAddressStatusCard()),
                      if (!controller.customerExistStatus.value)
                        Center(child: _buildLoginStatusCard()),
                      SizedBox(height: Get.height * 0.03),
                      _buildServicesHeader(),
                      SizedBox(height: Get.height * 0.03),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: _buildServicesGrid(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (!controller.addressStatus.value) {
            Get.dialog(
              AlertDialog(
                title: const Text('Alert'),
                content: const Text('Please add address'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            Get.to(() => PartnerListPage());
          }
        },
        child: SizedBox(
          height: Get.height * 0.08,
          width: Get.width * 0.9,
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  SizedBox(width: Get.width * 0.02),
                  const Text("Search any services...",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: lightGreyColor)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannersCarousel() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: CarouselSlider.builder(
        itemCount: controller.banners.length,
        options: CarouselOptions(
          height: 160,
          enableInfiniteScroll: true,
          autoPlay: true,
          viewportFraction: 0.8,
          enlargeCenterPage: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
        ),
        itemBuilder: (context, index, _) {
          final banner = controller.banners[index];
          return GestureDetector(
            onTap: () {
              // String redirectionUrl = banner['redirection_url'];
              // Add navigation logic here
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "${filesurl}banners_thumbnail/" + banner['banner_path'],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressStatusCard() {
    return SizedBox(
      height: Get.height * 0.08,
      width: Get.width * 0.9,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: const Icon(Icons.error, color: warningRedColor),
          title: const Text('Delivery Address'),
          trailing: ElevatedButton(
            onPressed: () {
              if (!controller.isLoggedIn.value) {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Please Login'),
                    content:
                        const Text('You need to login to access this feature.'),
                    actions: [
                      TextButton(
                          onPressed: () => Get.back(), child: const Text('OK')),
                    ],
                  ),
                );
              } else {
                Get.to(() => const ListAddress());
              }
            },
            child: const Text("Continue"),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginStatusCard() {
    return SizedBox(
      height: Get.height * 0.08,
      width: Get.width * 0.9,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: const Icon(Icons.error, color: warningRedColor),
          title: const Text('Please login'),
          trailing: ElevatedButton(
            onPressed: () => Get.to(() => AuthLogin()),
            child: const Text("Continue"),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesHeader() {
    return const Padding(
      padding: EdgeInsets.only(left: 30),
      child:
          Text("All services", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildServicesGrid() {
    return Obx(
      () => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.65,
          crossAxisCount: 4,
        ),
        itemCount: controller.services.length,
        itemBuilder: (context, index) {
          final service = controller.services[index];
          return GestureDetector(
            onTap: () {
              if (controller.addressStatus.value &&
                  controller.isLoggedIn.value) {
                Get.to(() => SpecificServicePartners(
                      serviceId: service['id'],
                      serviceName: service['service_name'] as String,
                    ));
              } else {
                Get.dialog(
                  AlertDialog(
                    title: Text(controller.addressStatus.value
                        ? 'Please login'
                        : 'Please add address'),
                    actions: [
                      TextButton(
                          onPressed: () => Get.back(), child: const Text('OK')),
                    ],
                  ),
                );
              }
            },
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: whiteColor,
                  backgroundImage: NetworkImage(
                      "${filesurl}services_thumbnail/" +
                          service['service_thumbnail']),
                  radius: 30,
                ),
                const SizedBox(height: 5),
                Text(service['service_name'],
                    maxLines: 2, textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }
}

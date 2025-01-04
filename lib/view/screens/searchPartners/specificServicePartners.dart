// ignore_for_file: file_names

import 'package:customer/app/generalImports.dart';
import 'package:customer/controller/service_partner_list_controller.dart';
import 'package:customer/view/screens/addressManagement/listAddress.dart';
import 'package:customer/view/screens/searchPartners/PartnerDeatilsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SpecificServicePartners extends StatelessWidget
    with WidgetsBindingObserver {
  final int serviceId;
  final String serviceName;

  const SpecificServicePartners({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    final SpecificServicePartnersController controller =
        Get.put(SpecificServicePartnersController(serviceId: serviceId));

    return Scaffold(
      backgroundColor: lightPrimaryColor,
      appBar: AppBar(
        title: null,
        backgroundColor: whiteColor,
      ),
      body: Obx(() {
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                controller.myServicePincode.value != 'none'
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on),
                                const Text("Pincode : "),
                                Text(
                                  controller.myServicePincode.value,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: greenColor),
                                ),
                              ],
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.05),
                            ElevatedButton.icon(
                                icon: const Icon(Icons.arrow_forward_sharp,
                                    color: primaryColor),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: blackColor),
                                onPressed: () async {
                                  // Navigate to ListAddress screen
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ListAddress()),
                                  );

                                  // If there's a new pincode from ListAddress, update the pincode
                                  if (result != null &&
                                      result !=
                                          controller.myServicePincode.value) {
                                    controller.myServicePincode.value = result;
                                  }
                                },
                                label: const Text("choose pincode",
                                    style: TextStyle(color: whiteColor)))
                          ],
                        ),
                      )
                    : Container(),
                Expanded(
                  child: controller.isLoading.value &&
                          controller.ServicePartners.isEmpty
                      ? const Center(child: CupertinoActivityIndicator())
                      : controller.ServicePartners.isEmpty
                          ? const Center(
                              child: Text('No partners found.',
                                  style: TextStyle(fontSize: 18)))
                          : ListView.builder(
                              itemCount: controller.ServicePartners.length,
                              itemBuilder: (context, index) {
                                var partner = controller.ServicePartners[index];
                                String subtitleText = partner['bio'] != null
                                    ? (partner['bio'].length <= 60
                                        ? partner['bio']
                                        : partner['bio'].substring(0, 60) +
                                            '...')
                                    : '';

                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to Partner Details Screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PartnerDetailsScreen(
                                          partnerId: partner['partner_id'],
                                          partnerServiceId:
                                              partner['partner_service_id'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: _buildGenderImage(
                                                    partner['gender']),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration:
                                                              const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.green,
                                                          ),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 8),
                                                        ),
                                                        Text(
                                                          partner['full_name'],
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Row(
                                                          children: [
                                                            Icon(Icons.person,
                                                                size: 12,
                                                                color: Colors
                                                                    .grey[600]),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              _getGenderText(
                                                                  partner[
                                                                      'gender']),
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                          .grey[
                                                                      600]),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.05),
                                                        Text(
                                                          serviceName,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  greenColor),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.01),
                                                    Text(
                                                      subtitleText,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
            if (controller.isLoading.value &&
                controller.ServicePartners.isEmpty)
              const Center(child: CupertinoActivityIndicator()),
          ],
        );
      }),
    );
  }

  String _getGenderText(int gender) {
    if (gender == 1) {
      return 'Male';
    } else if (gender == 2 || gender == 3) {
      return 'Female';
    } else {
      return 'Not Available';
    }
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
      borderRadius: BorderRadius.circular(25),
      child: Image.asset(
        imagePath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      ),
    );
  }
}

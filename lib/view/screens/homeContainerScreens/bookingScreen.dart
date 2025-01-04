// ignore_for_file: file_names

import 'package:customer/controller/booking%20controller/booking_controller.dart';
import 'package:customer/view/screens/auth/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../utils/colors.dart';
import '../homeContainerScreens/bookingDetailsScreen.dart';

class BookingScreen extends StatelessWidget {
  final BookingController bookingController = Get.put(BookingController());
  BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPrimaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Obx(() {
              if (bookingController.isLoading.value) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (bookingController.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Text(
                    'Error: ${bookingController.errorMessage.value}',
                  ),
                );
              } else if (bookingController.bookings.isEmpty) {
                return Center(
                  // Wrap everything inside a Center widget
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center vertically
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Center horizontally
                    children: [
                      Image.asset(
                        'assets/char.png',
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 15), // Spacing between elements
                      const Text(
                        'Please log in to view your Bookings.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20), // Add space before button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AuthLogin()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blackColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Login now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    shrinkWrap: true, // Prevents infinite height
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookingController.bookings.length +
                        (bookingController.hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == bookingController.bookings.length) {
                        // Show loading indicator only if there's more data to load
                        return bookingController.isLoading.value &&
                                bookingController.hasMore.value
                            ? _buildLoadingIndicator()
                            : const SizedBox();
                      } else {
                        return _buildBookingTile(
                            context, bookingController.bookings[index]);
                      }
                    },
                  ),
                );

                // Loading Indicator Widget
                // Widget _buildLoadingIndicator() {
                //   return const Padding(
                //     padding: EdgeInsets.all(8.0),
                //     child: Center(child: CupertinoActivityIndicator()),
                //   );
                // }
              }
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(child: CupertinoActivityIndicator()),
    );
  }

  Widget _buildBookingTile(BuildContext context, dynamic booking) {
    final statusInfo = _getStatusInfo(
        booking['booking_status'] ?? 0); // Default to 0 (Unknown status)
    final dateForService = _formatDateForService(booking['partner']
            ['date_for_service'] ??
        ''); // Default to empty string if date is missing
    final genderText = _getGenderText(
        booking['partner']['gender'] ?? 'Unknown'); // Default to 'Unknown'
    final genderImage = _getGenderImage(
        booking['partner']['gender'] ?? 'Unknown'); // Default to 'Unknown'

    return GestureDetector(
      onTap: () => _navigateToBookingDetails(context, booking['booking_id']),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(backgroundImage: AssetImage(genderImage)),
              title: Text(
                  '${booking['partner']['full_name'] ?? 'Unknown'}'), // Default to 'Unknown' if full_name is null
              subtitle: _buildSubtitle(genderText, dateForService),
              trailing: _buildStatusText(statusInfo),
            ),
            const Divider(height: 1, thickness: 1, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Row _buildSubtitle(String genderText, String dateForService) {
    return Row(
      children: [
        Text(
          genderText,
        ),
        const SizedBox(width: 16),
        // Date
        Icon(
          Icons.date_range,
          size: 18,
          color: dateForService == 'Today' ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          dateForService.isNotEmpty
              ? dateForService
              : 'No date available', // Handle empty date
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: dateForService == 'Today' ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Text _buildStatusText(Map<String, dynamic> statusInfo) {
    return Text(
      statusInfo['text'] ?? 'Unknown Status', // Default text if status is null
      style: TextStyle(
        color: statusInfo['color'] ??
            Colors.black, // Default color if status is null
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _getGenderImage(String gender) {
    if (gender == 'Male') {
      return 'assets/malepic.png';
    } else if (gender == 'Female') {
      return 'assets/femalepic.png';
    } else {
      return 'assets/defaultpic.png'; // Default image if gender is unknown
    }
  }

  String _getGenderText(String gender) {
    if (gender == 'Male') {
      return 'Male';
    } else if (gender == 'Female') {
      return 'Female';
    } else {
      return 'Unknown'; // Default text when gender is missing
    }
  }

  String _formatDateForService(String dateString) {
    if (dateString.isEmpty) return 'No service date available';

    try {
      DateTime now = DateTime.now();
      DateTime dateForService = DateTime.parse(dateString);

      if (dateForService.isAtSameMomentAs(now)) {
        return 'Today';
      } else if (dateForService
          .isAtSameMomentAs(now.subtract(const Duration(days: 1)))) {
        return 'Yesterday';
      } else if (dateForService
          .isAtSameMomentAs(now.add(const Duration(days: 1)))) {
        return 'Tomorrow';
      } else {
        return DateFormat('dd MMMM yyyy').format(dateForService);
      }
    } catch (e) {
      return 'Invalid date'; // If parsing fails
    }
  }

  void _navigateToBookingDetails(BuildContext context, int bookingId) {
    Get.to(() => BookingDetailsPage(bookingId: bookingId));
  }

  Map<String, dynamic> _getStatusInfo(int status) {
    switch (status) {
      case 1:
        return {'text': 'Pending', 'color': colorPending};
      case 2:
        return {'text': 'Ongoing', 'color': colorOngoing};
      case 3:
        return {'text': 'Rejected', 'color': colorRejected};
      case 4:
        return {'text': 'Completed', 'color': colorCompleted};
      default:
        return {
          'text': 'Unknown',
          'color': colorUnknown
        }; // Default for unknown status
    }
  }
}

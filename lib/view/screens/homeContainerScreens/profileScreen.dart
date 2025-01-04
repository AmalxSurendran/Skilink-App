// ignore_for_file: file_names

import 'package:customer/app/generalImports.dart';
import 'package:customer/controller/auth_controller/login_controller.dart';
import 'package:customer/controller/profile%20controller/profile_controller.dart';
import 'package:customer/controller/auth_controller/passwordReset_controller.dart';
import 'package:customer/view/screens/addressManagement/listAddress.dart';
import 'package:customer/view/screens/auth/resetPasswordScreen.dart';
import 'package:customer/view/screens/homeContainerScreens/editUsernameScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/login.dart';
import 'deleteAccountScreen.dart';
import 'editGenderScreen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final authController = Get.put(AuthLoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPrimaryColor,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Obx(
            () {
              // Observe `isLoading` here
              if (controller.isLoading.value) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              } else if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                    child: Text('Error: ${controller.errorMessage.value}'));
              } else if (controller.profileData.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/char.png',
                        fit: BoxFit.cover,
                      ),
                      const Text(
                        'Please log in to view your profile.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
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
                return ProfileDetails(
                  profileData: controller.profileData,
                  onDelete: controller.deleteUserAccount,
                  isDeleting: controller.isDeleting.value,
                  onLogout: authController.logout,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final Future<void> Function(BuildContext) onDelete;
  final Future<void> Function() onLogout;
  final bool isDeleting; // New parameter for deletion loading

  const ProfileDetails({
    super.key,
    required this.profileData,
    required this.onDelete,
    required this.isDeleting,
    required this.onLogout,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username
            ListTile(
              title: const Text('Username'),
              subtitle: Text(profileData['username']),
              trailing: const Icon(Icons.edit),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditUsernameScreen(
                          profileData['username'], profileData['id'])),
                );
              },
            ),
            const Divider(),
            // Phone
            ListTile(
              title: const Text('Phone'),
              subtitle: Text(
                  '${profileData['country_code_phone']} ${profileData['phone']}'),
            ),
            const Divider(),
            // Gender
            ListTile(
              title: const Text('Gender'),
              subtitle: Text(
                _getGenderText(
                  int.parse(
                    profileData['gender'].toString(),
                  ),
                ),
              ),
              trailing: const Icon(Icons.edit),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditGenderScreen(
                          profileData['gender'], profileData['id'])),
                );
              },
            ),

            const Divider(),
            // Reset Password Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: const BoxDecoration(
                    color: blackColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.vpn_key,
                    color: primaryColor,
                  ),
                ),
                title: const Text('Reset Password'),
                onTap: () {
                  Get.to(() => const ResetPasswordScreen())?.then((_) {
                    final controller = Get.find<ResetPasswordController>();
                    controller.clearTextFields();
                  });
                },
              ),
            ),
            // Manage Address Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: const BoxDecoration(
                      color: blackColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: primaryColor,
                    )),
                title: const Text('Manage Address'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ListAddress()),
                  );
                },
              ),
            ),
            const Divider(),
            // Additional Pages Section
            ListTile(
              leading: const Icon(Icons.privacy_tip), // Icon for Privacy Policy
              title: const Text('Privacy Policy'),
              onTap: () async {
                await launchUrl(Uri.parse(privacy_policy));
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.description), // Icon for Terms and Services
              title: const Text('Terms and Services'),
              onTap: () async {
                await launchUrl(Uri.parse(terms_and_conditions));
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail), // Icon for Contact Us
              title: const Text('Contact Us'),
              onTap: () async {
                await launchUrl(Uri.parse(contact_us));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info), // Icon for About Us
              title: const Text('About Us'),
              onTap: () async {
                await launchUrl(Uri.parse(about_us));
              },
            ),
            ListTile(
                leading: const Icon(Icons.logout), // Icon for About Us
                title: const Text('logout'),
                onTap: onLogout),
            ListTile(
              title: const Text(
                'Permanently Delete Account',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              leading: const Icon(Icons.delete, color: Colors.red),
              trailing: isDeleting
                  ? const CupertinoActivityIndicator()
                  : const Icon(Icons.navigate_next, color: Colors.red),
              onTap: isDeleting
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DeleteAccountScreen()),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  String _getGenderText(int gender) {
    switch (gender) {
      case 1:
        return 'Male';
      case 2:
        return 'Female';
      case 3:
        return 'Other';
      default:
        return 'Unknown';
    }
  }
}

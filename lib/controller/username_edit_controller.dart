import 'dart:developer';

import 'package:customer/app/generalImports.dart';
import 'package:customer/controller/profile_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:customer/utils/api.dart';

class EditUsernameController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = Rx<String?>(null);
  var usernameController = TextEditingController().obs;

  // This function will be called to update the username.
  Future<void> updateUsername(int customerId, String currentUsername) async {
    // If username is the same, no update needed
    if (usernameController.value.text == currentUsername) {
      Get.snackbar('Info', 'No changes made');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final response = await http.patch(
      Uri.parse('${Api.updateFullName}/$customerId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': usernameController.value.text,
      }),
    );

    isLoading.value = false;

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      log('username change : $result');
      Get.back();
      ProfileController controller = Get.find();
      controller.updateProfileData(usernameController.value.text);
      log(usernameController.value.text);
      // Show a success message
      Get.snackbar(
        'Success',
        result['message'] ?? 'Username updated successfully',
      );

      // Navigate back to the previous screen
    } else {
      // Show an error message if the update failed
      Get.snackbar(
        'Error',
        'Failed to update username',
      );

      errorMessage.value = 'Failed to update username';
    }
  }
}

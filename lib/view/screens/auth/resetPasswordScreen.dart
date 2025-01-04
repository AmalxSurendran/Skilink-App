// import 'package:customer/app/generalImports.dart';
// import 'package:customer/controller/reset_controller.dart';
// import 'package:get/get.dart';

// class ResetPasswordScreen extends StatefulWidget {
//   const ResetPasswordScreen({super.key});

//   @override
//   _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ResetPasswordController());
//     final _formKey = GlobalKey<FormState>();
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: whiteColor,
//         title: null,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           autovalidateMode: controller.autoValidate
//               ? AutovalidateMode.always
//               : AutovalidateMode.disabled,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               TextFormField(
//                 controller: controller.passwordController,
//                 obscureText: !controller.isPasswordVisible.value,
//                 decoration: InputDecoration(
//                   labelText: 'New Password',
//                   suffixIcon: IconButton(
//                     icon: Icon(controller.isPasswordVisible.value
//                         ? Icons.visibility
//                         : Icons.visibility_off),
//                     onPressed: () {
//                       setState(() {
//                         controller.isPasswordVisible.value =
//                             !controller.isPasswordVisible.value;
//                       });
//                     },
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a password';
//                   }
//                   if (value.length < 8) {
//                     return 'Password must be at least 8 characters long';
//                   }
//                   if (!_containsUppercase(value)) {
//                     return 'Password must include at least one uppercase letter';
//                   }
//                   if (!_containsLowercase(value)) {
//                     return 'Password must include at least one lowercase letter';
//                   }
//                   if (!_containsDigit(value)) {
//                     return 'Password must include at least one digit';
//                   }
//                   if (!_containsSpecialCharacter(value)) {
//                     return 'Password must include at least one special character';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: controller.confirmPasswordController,
//                 obscureText: !controller.isPasswordVisible.value,
//                 decoration: InputDecoration(
//                   labelText: 'Confirm Password',
//                   suffixIcon: IconButton(
//                     icon: Icon(controller.isPasswordVisible.value
//                         ? Icons.visibility
//                         : Icons.visibility_off),
//                     onPressed: () {
//                       setState(() {
//                         controller.isPasswordVisible.value =
//                             !controller.isPasswordVisible.value;
//                       });
//                     },
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value != controller.passwordController.text) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               controller.isLoading.value
//                   ? Center(child: CircularProgressIndicator())
//                   : ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           elevation: 4, backgroundColor: blackColor),
//                       onPressed: () {
//                         if (_formKey.currentState!.validate()) {
//                           String newPassword =
//                               controller.passwordController.text;
//                           controller.resetPassword(
//                               newPassword, context); // Call the API method
//                         } else {
//                           setState(() {
//                             controller.autoValidate = true;
//                           });
//                         }
//                       },
//                       child: Text(
//                         'Reset Password',
//                         style: TextStyle(
//                             color: whiteColor, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   bool _containsUppercase(String value) {
//     return value.contains(RegExp(r'[A-Z]'));
//   }

//   bool _containsLowercase(String value) {
//     return value.contains(RegExp(r'[a-z]'));
//   }

//   bool _containsDigit(String value) {
//     return value.contains(RegExp(r'[0-9]'));
//   }

//   bool _containsSpecialCharacter(String value) {
//     return value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
//   }
// }

// ignore_for_file: no_leading_underscores_for_local_identifiers, file_names

import 'package:customer/controller/auth_controller/passwordReset_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResetPasswordController());
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(
          () => Form(
            key: _formKey,
            autovalidateMode: controller.autoValidate.value
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        controller.isPasswordVisible.toggle();
                      },
                    ),
                  ),
                  validator: (value) {
                    return controller.validatePassword(value);
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.confirmPasswordController,
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        controller.isPasswordVisible.toggle();
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != controller.passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                controller.isLoading.value
                    ? const Center(child: CupertinoActivityIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            controller.autoValidate.value = true;
                            controller.clearTextFields;
                            controller.resetPassword(
                              controller.passwordController.text,
                              context,
                            );
                          } else {
                            controller.autoValidate.value = true;
                          }
                        },
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
